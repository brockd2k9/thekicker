extends "res://tests/test_case.gd"
## The team database (TeamDatabase, data/teams): loading, the validator,
## Hoboken as every career's start, old-save team migration (save version 8),
## and a full career on the database teams.

const SIM := preload("res://tools/career_sim.gd")
const OLD_CAREERS := ["career_v0_minimal.json", "career_v1_stage_end.json", "career_v2_hs_junior.json",
	"career_v2_college.json", "career_v3_college.json", "career_v4_college.json",
	"career_v5_benched.json", "career_v7_followers.json"]


# --- made-up data for loader / validator tests ---------------------------------------------

static func _leagues() -> Dictionary:
	return {"start_team": "home_hs", "levels": {
		"high_school": {"divisions": {"HS": {"conferences": ["Test League"]}}},
		"college": {"divisions": {"FBS": {"tier": "top", "conferences": ["Big"]},
			"JUCO": {"tier": "juco", "conferences": ["Juco"]}}},
		"pro": {"divisions": {"PRO": {"conferences": ["Pros"]}}}}}


static func _team(id: String, abbr: String, div: String, conf: String, extra := {}) -> Dictionary:
	var t := {"id": id, "name": id.capitalize(), "nickname": "Cats", "abbr": abbr, "division": div,
		"conference": conf, "colors": ["Navy", "Gold"]}
	t.merge(extra, true)
	return t


static func _raw() -> Dictionary:
	return {
		"high_school": [_team("home_hs", "HOM", "HS", "Test League"), _team("away_hs", "AWY", "HS", "Test League")],
		"college": [_team("big_u", "BU", "FBS", "Big", {"ratings": {"prestige": 90}}),
			_team("small_u", "SU", "FBS", "Big", {"ratings": {"prestige": 60}}),
			_team("juco_a", "JA", "JUCO", "Juco"), _team("juco_b", "JB", "JUCO", "Juco")],
		"pro": [_team("pro_a", "PA", "PRO", "Pros", {"strength": 70}), _team("pro_b", "PB", "PRO", "Pros")],
	}


const PALETTE := {"navy": "#14213d", "gold": "#d4a017"}


func _errors_for(raw: Dictionary, leagues := _leagues()) -> PackedStringArray:
	TeamDatabase.load_data(raw, leagues, PALETTE)
	var r: Dictionary = TeamDatabase.validate()
	TeamDatabase.load_files()
	return r["errors"]


func _has(errors: PackedStringArray, part: String) -> bool:
	for e in errors:
		if part in e:
			return true
	return false


# --- the real data --------------------------------------------------------------------------

func test_real_data_loads_and_validates() -> void:
	TeamDatabase.load_files()
	var r: Dictionary = TeamDatabase.validate()
	eq(r["errors"].size(), 0, "no errors in data/teams: %s" % [r["errors"]])
	check(TeamDatabase.high_schools().size() >= 2, "high schools")
	check(TeamDatabase.colleges().size() >= 2, "colleges")
	check(TeamDatabase.jucos().size() >= 2, "junior colleges")
	check(TeamDatabase.pro_teams().size() >= 2, "pro teams")
	for t in TeamDatabase.colleges():
		check(str(t["tier"]) in ["top", "mid", "small"], "%s has a recruiting tier" % t["id"])
	for lv in TeamDatabase.LEVELS:
		for t in TeamDatabase.teams(lv):
			for k in ["id", "name", "mascot", "short", "town", "colors", "strength", "conference", "division"]:
				check(t.has(k), "%s has %s" % [t["id"], k])
			check(str(t["colors"][0]).begins_with("#") and str(t["colors"][1]).begins_with("#"), "%s colors are hex" % t["id"])
			check(float(t["strength"]) > 0.0 and float(t["strength"]) <= 100.0, "%s strength 0-100" % t["id"])


func test_hoboken_is_a_real_high_school() -> void:
	TeamDatabase.load_files()
	var h := TeamDatabase.start_team()
	eq(TeamDatabase.start_team_id(), "hoboken_hs", "start team id")
	eq(str(h.get("name", "")), "Hoboken High School", "name")
	eq(str(h.get("level", "")), "high_school", "level")
	eq(str(h.get("short", "")), "HOB", "scoreboard abbreviation")
	check(TeamDatabase.conference_mates(h).size() >= 10, "Hoboken has a league to play")


func test_team_record_fields() -> void:
	TeamDatabase.load_data(_raw(), _leagues(), PALETTE)
	var b := TeamDatabase.team("big_u")
	eq(b["colors"], ["#14213d", "#d4a017"], "color names resolve to hex")
	eq(b["color_names"], ["Navy", "Gold"], "names kept")
	eq(b["short"], "BU", "short = abbr")
	eq(b["mascot"], "Cats", "mascot = nickname")
	eq(b["tier"], "top", "tier from the division")
	eq(float(b["strength"]), TeamDatabase.DERIVED_MAX, "best prestige -> top derived strength")
	eq(float(TeamDatabase.team("small_u")["strength"]), TeamDatabase.DERIVED_MIN, "worst prestige -> bottom")
	eq(float(TeamDatabase.team("pro_a")["strength"]), 70.0, "explicit strength kept")
	eq(float(TeamDatabase.team("pro_b")["strength"]), TeamDatabase.DEFAULT_STRENGTH, "default strength")
	eq(TeamDatabase.colleges().size(), 2, "colleges leave out JUCO")
	eq(TeamDatabase.jucos().size(), 2, "jucos")
	check(TeamDatabase.team("nope").is_empty(), "unknown id -> {}")
	TeamDatabase.team("big_u")["name"] = "Changed"
	eq(TeamDatabase.team("big_u")["name"], "Big U", "lookups are copies")
	TeamDatabase.load_files()


# --- validator ------------------------------------------------------------------------------

func test_validator_accepts_good_data() -> void:
	eq(_errors_for(_raw()).size(), 0, "clean made-up data: %s" % [_errors_for(_raw())])


func test_validator_duplicate_id() -> void:
	var raw := _raw()
	raw["pro"].append(_team("big_u", "XX", "PRO", "Pros"))
	check(_has(_errors_for(raw), "duplicate id"), "duplicate id reported")


func test_validator_missing_required_fields() -> void:
	var raw := _raw()
	raw["college"][0].erase("abbr")
	raw["college"][1]["name"] = ""
	var e := _errors_for(raw)
	check(_has(e, "'big_u' (Big U): missing required field 'abbr'"), "missing abbr names the team: %s" % [e])
	check(_has(e, "missing required field 'name'"), "empty name")


func test_validator_unknown_division_and_conference() -> void:
	var raw := _raw()
	raw["college"][0]["conference"] = "Made Up Conference"
	raw["college"][1]["division"] = "D9"
	var e := _errors_for(raw)
	check(_has(e, "unknown conference 'Made Up Conference'"), "unknown conference")
	check(_has(e, "unknown division 'D9'"), "unknown division")


func test_validator_abbreviation_collision() -> void:
	var raw := _raw()
	raw["high_school"][1]["abbr"] = "HOM"
	check(_has(_errors_for(raw), "abbreviation 'HOM' collides"), "same abbr in one conference")


func test_validator_unplaced_team() -> void:
	var raw := _raw()
	raw["high_school"][1].erase("conference")
	check(_has(_errors_for(raw), "'away_hs' (Away Hs): missing required field 'conference'"), "team not in a league")


func test_validator_colors_rivals_start_team() -> void:
	var raw := _raw()
	raw["pro"][0]["colors"] = ["Plaid"]
	raw["pro"][1]["rival"] = {"name": "Nobody FC"}
	var lg := _leagues()
	lg["start_team"] = "big_u"
	var e := _errors_for(raw, lg)
	check(_has(e, "unknown color 'Plaid'"), "unknown color")
	check(_has(e, "rival 'Nobody FC'"), "unknown rival")
	check(_has(e, "must be a high school"), "start team must be a high school")


func test_validator_empty_level() -> void:
	var raw := _raw()
	raw["pro"] = []
	check(_has(_errors_for(raw), "pro: needs at least 2 teams"), "a level with no teams")


# --- Hoboken start ----------------------------------------------------------------------------

func test_every_new_career_starts_at_hoboken() -> void:
	TeamDatabase.load_files()
	var m := CareerManager.create(0, "Test Kicker", 3, {"skin": 0, "hair": 0})
	var c := m.data
	eq(str(c.team["id"]), "hoboken_hs", "team")
	eq(str(c.team["name"]), "Hoboken High School", "name")
	eq(str(c.team["short"]), "HOB", "abbreviation")
	eq(str(c.player["hometown"]), "Hoboken", "hometown")
	check(str(c.route[0].get("text", "")).contains("Hoboken High School"), "route starts at Hoboken")
	# Conference opponents first: a 21-school league fills a high school season.
	for e in c.schedule:
		if str(e.get("type", "")) == "regular":
			var opp: Dictionary = e["opponent"]
			check(TeamDatabase.has_team(str(opp["id"])), "opponent %s is in the database" % opp["id"])
			eq(str(opp.get("conference", "")), str(c.team.get("conference", "")), "league opponent")
			check(str(opp["id"]) != "hoboken_hs", "never plays itself")


# --- old saves --------------------------------------------------------------------------------

func test_old_saves_move_to_database_teams() -> void:
	TeamDatabase.load_files()
	for name in OLD_CAREERS:
		var raw := fixture(name)
		var c := CareerData.from_dict(CareerSave._migrate(fixture(name)))
		eq(c.to_dict()["career_version"], CareerData.VERSION, name + " version")
		check(TeamDatabase.has_team(str(c.team.get("id", ""))), "%s: team %s is in the database" % [name, c.team.get("id")])
		if c.stage == CareerData.STAGE_HIGH_SCHOOL:
			eq(str(c.team["id"]), "hoboken_hs", name + ": high school becomes Hoboken")
		eq(str(c.player.get("hometown", "")), "Hoboken", name + ": hometown")
		for e in c.schedule:
			if e.get("opponent") is Dictionary and not (e["opponent"] as Dictionary).is_empty():
				check(TeamDatabase.has_team(str(e["opponent"]["id"])), "%s: opponent %s" % [name, e["opponent"]["id"]])
		for off in c.offers:
			var s := TeamDatabase.team(str(off["school"]))
			check(not s.is_empty(), "%s: offer from %s" % [name, off["school"]])
			eq(str(s.get("tier", "")), str(off.get("tier", "")), "%s: offer keeps its tier" % name)
		var tt := Relationships.tyler_team(c)
		if not tt.is_empty():
			check(TeamDatabase.has_team(str(tt["id"])), "%s: Tyler's team %s" % [name, tt["id"]])
		eq(JSON.stringify(c.to_dict()["history"]), JSON.stringify(raw.get("history", [])), name + ": history kept")


func test_old_college_keeps_tier_and_offer_type() -> void:
	var raw := fixture("career_v2_college.json")
	var c := CareerData.from_dict(CareerSave._migrate(fixture("career_v2_college.json")))
	eq(str(c.team["tier"]), str(raw["team"]["tier"]), "same recruiting tier")
	eq(str(c.team.get("offer_type", "")), str(raw["team"].get("offer_type", "")), "offer type kept")
	eq(str(c.team["id"]), "abilene_university", "eastmont -> legacy_ids.json")


func test_migration_is_stable() -> void:
	var once := CareerSave._migrate(fixture("career_v2_hs_junior.json"))
	var c := CareerData.from_dict(once)
	var again := CareerData.from_dict(CareerSave._migrate(c.to_dict()))
	eq(JSON.stringify(again.to_dict()), JSON.stringify(c.to_dict()), "a migrated save loads unchanged")


# --- a full career on the database ------------------------------------------------------------

func test_full_career_high_school_to_pro() -> void:
	TeamDatabase.load_files()
	var sim = SIM.new()
	sim._kt = load("res://tuning/kick_tuning.tres")
	var reached := {}
	for n in 4:
		sim._rng.seed = 1000 + n
		var out: Dictionary = sim._play_career("mixed", n)
		for st in out["reached"]:
			reached[st] = true
	sim.free()
	for st in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_COLLEGE, CareerData.STAGE_PRO]:
		check(reached.has(st), "a career reached %s" % st)

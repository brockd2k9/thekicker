extends "res://tests/test_case.gd"
## The team database (TeamDatabase, data/teams): loading, the validator,
## Hoboken as every career's start, old-save team migration (save versions 10 and 11),
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


func _warnings_for(raw: Dictionary) -> PackedStringArray:
	TeamDatabase.load_data(raw, _leagues(), PALETTE)
	var r: Dictionary = TeamDatabase.validate()
	TeamDatabase.load_files()
	return r["warnings"]


func test_stadium_repeating_a_school_word() -> void:
	eq(TeamDatabase.stadium_repeats_school_word("Burlington Burlington Timberhawks Field",
		"Burlington Valley University"), "Burlington", "town twice")
	eq(TeamDatabase.stadium_repeats_school_word("Prairie View Prairie Stadium", "Brazos Prairie University"),
		"Prairie", "a school word twice, not side by side")
	eq(TeamDatabase.stadium_repeats_school_word("bossier city Bossier Cranes Field",
		"Bossier City Regional University"), "Bossier", "case doesn't matter")
	eq(TeamDatabase.stadium_repeats_school_word("Burlington Timberhawks Field", "Burlington Valley University"),
		"", "the town once is fine")
	eq(TeamDatabase.stadium_repeats_school_word("Beaver Falls Beaver Stadium", "Geneva Valley University"),
		"", "a repeat that isn't in the school name")
	eq(TeamDatabase.stadium_repeats_school_word("Field of Field", "University of Field"), "Field",
		"short words (of) never count; Field does")
	var raw := _raw()
	raw["college"][0]["stadium"] = {"name": "Big Big Bowl"}
	raw["college"][1]["stadium"] = {"name": "Small Arena"}
	var w := _warnings_for(raw)
	check(_has(w, "'big_u' (Big U): stadium name 'Big Big Bowl' repeats 'Big' from the school name"),
		"warning names the team, the stadium and the word: %s" % [w])
	check(not _has(w, "small_u"), "no warning for a clean stadium")
	raw["college"][1]["stadium"] = {"name": "Arena Arena"}
	check(_has(_warnings_for(raw), "'small_u' (Small U): stadium name repeats a word ('Arena Arena')"),
		"other doubled words still warn")


func test_real_stadium_names_are_clean() -> void:
	TeamDatabase.load_files()
	var r: Dictionary = TeamDatabase.validate()
	var stadium: Array = Array(r["warnings"]).filter(func(x: String) -> bool: return "stadium name" in x)
	# Left for review (data/teams/import_report.md): Prairie View Prairie
	# Stadium repeats a school word; Beaver Falls Beaver Stadium doesn't.
	eq(stadium.size(), 1, "only the stadium left for review warns: %s" % [stadium])
	check(stadium.size() == 1 and "Prairie View Prairie Stadium" in str(stadium[0]), "Prairie View")
	for t in TeamDatabase.colleges():
		if t["division"] == "D2":
			eq(str(t["stadium"]["name"]), "%s %s Field" % [t["city"], t["nickname"]], str(t["id"]))


func test_pro_league() -> void:
	TeamDatabase.load_files()
	var pros := TeamDatabase.pro_teams()
	eq(pros.size(), 32, "32 clubs")
	var confs := {}
	var abbrs := {}
	for t in pros:
		check(not bool(t.get("placeholder", false)), "%s is real data" % t["id"])
		check(str(t["division"]) in ["AFC", "NFC"], "%s: AFC / NFC" % t["id"])
		check(str(t["conference"]).begins_with(str(t["division"]) + " "), "%s: conference inside its division" % t["id"])
		confs[t["conference"]] = int(confs.get(t["conference"], 0)) + 1
		check(not abbrs.has(t["short"]), "%s: abbreviation %s unique" % [t["id"], t["short"]])
		abbrs[t["short"]] = true
		check(float(t["strength"]) >= 55.0 and float(t["strength"]) <= 75.0, "%s: strength in the pro range" % t["id"])
		check(TeamDatabase.has_team(str(t.get("rival", {}).get("id", ""))), "%s: rival is a club" % t["id"])
	eq(confs.size(), 8, "8 divisions")
	for k in confs:
		eq(confs[k], 4, "%s has 4 clubs" % k)
	var ny := TeamDatabase.team("new_york_guardians")
	eq([ny["name"], ny["mascot"], ny["short"], ny["town"]], ["New York Guardians", "Guardians", "NYG", "New York"], "NY")
	eq(str(TeamDatabase.team("new_york_empire")["short"]), "NYE", "second New York club")
	eq(CareerUi.league_line(ny), "AFC East", "pro league line")
	eq(CareerUi.league_line(TeamDatabase.team("florida_university")), "FBS - Southern Athletic Conference", "college")


func test_pro_schedule_plays_the_division_first() -> void:
	var c := CareerData.create("Pro", CareerTuning.get_default())
	c.stage = CareerData.STAGE_PRO
	c.team = Progression.team_from(TeamDatabase.team("buffalo_bisons"), CareerData.STAGE_PRO)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var regular: Array = CareerManager.build_schedule(c, CareerTuning.get_default(), rng).filter(
		func(e: Dictionary) -> bool: return e["type"] == "regular")
	for i in 3:
		eq(str(regular[i]["opponent"]["conference"]), "AFC East", "game %d: a division rival" % (i + 1))
	for e in regular:
		check(str(e["opponent"]["id"]) != "buffalo_bisons", "never plays itself")


# A save from before the pro league: placeholder club ids everywhere.
static func _old_pro_save(version: int) -> Dictionary:
	var d := fixture("career_v7_followers.json")
	d["career_version"] = version
	d["stage"] = CareerData.STAGE_PRO
	d["team"] = {"id": "metro_monarchs", "name": "Metro Monarchs", "mascot": "Monarchs", "short": "MET",
		"town": "Metro City", "colors": ["#3a0ca3", "#f8c537"], "strength": 72.0, "tier": "", "level": "pro"}
	d["contract"] = {"team": "metro_monarchs", "team_name": "Metro Monarchs", "years_left": 2, "salary": 900000, "how": "drafted"}
	d["draft_result"] = {"round": 3, "kind": "drafted", "team": "metro_monarchs", "team_name": "Metro Monarchs"}
	d["tryout"] = {"purpose": "challenge", "team": "metro_monarchs", "team_name": "Charity kick"}
	d["flags"]["failed_tryouts"] = ["bayou_gators"]
	d["offers"] = []
	for e in d["schedule"]:
		if e.get("opponent") is Dictionary:
			e["opponent"] = {"id": "harbor_hammers", "name": "Harbor Hammers", "short": "HAM", "level": "pro"}
	d["people"] = {"rival": {"known": true, "name": "Tyler Brooks", "stage": "high_school", "value": 40.0,
		"week_change": 0.0, "team": {"id": "desert_vipers", "name": "Desert Vipers", "short": "DSV", "stage": "pro"}}}
	return d


func test_placeholder_pro_ids_migrate() -> void:
	TeamDatabase.load_files()
	for version in [7, 8, 9, 10]:
		var d := CareerSave._migrate(_old_pro_save(version))
		var who := "v%d save" % version
		eq(int(d["career_version"]), CareerData.VERSION, who + " version")
		eq(str(d["team"]["id"]), "new_york_guardians", who + " team")
		eq(str(d["team"]["name"]), "New York Guardians", who + " team name")
		eq(str(d["team"]["short"]), "NYG", who + " abbreviation")
		eq([d["contract"]["team"], d["contract"]["team_name"]], ["new_york_guardians", "New York Guardians"], who + " contract")
		eq(int(d["contract"]["salary"]), 900000, who + " contract kept")
		eq([d["draft_result"]["team"], d["draft_result"]["team_name"]], ["new_york_guardians", "New York Guardians"],
			who + " draft")
		eq([d["tryout"]["team"], d["tryout"]["team_name"]], ["new_york_guardians", "Charity kick"],
			who + " a challenge keeps its title")
		eq(d["flags"]["failed_tryouts"], ["new_orleans_voodoo"], who + " failed tryouts")
		eq(str(d["people"]["rival"]["team"]["id"]), "arizona_scorpions", who + " Tyler")
		for e in d["schedule"]:
			if e.get("opponent") is Dictionary:
				eq(str(e["opponent"]["id"]), "baltimore_admirals", who + " opponent")
				eq(str(e["opponent"]["conference"]), "AFC North", who + " opponent rebuilt")
		var c := CareerData.from_dict(d)
		check(TeamDatabase.has_team(str(c.team["id"])), who + " loads")


func test_legacy_pro_ids_cover_every_placeholder() -> void:
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CareerSave.LEGACY_IDS))
	var seen := {}
	eq((legacy["pro"] as Dictionary).size(), 12, "12 placeholder clubs")
	for old in legacy["pro"]:
		var id := str(legacy["pro"][old])
		check(TeamDatabase.has_team(id) and TeamDatabase.team(id)["level"] == "pro", "%s -> %s is a club" % [old, id])
		check(not seen.has(id), "%s used once" % id)
		seen[id] = true
		check(not TeamDatabase.has_team(str(old)), "%s is gone from the data" % old)


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
		eq(history_json(c.to_dict()["history"]), history_json(raw.get("history", [])), name + ": history kept")


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

class_name CareerSave
extends RefCounted
## Career save slots: one JSON file per slot in the user data folder,
##   user://career_slot_1.json .. user://career_slot_3.json
## Same safety as the main save (SaveStore.write_json: temp file, then swap;
## a corrupt file is copied to .bad). Each file carries "career_version";
## when CareerData's layout changes, bump CareerData.VERSION and add a step
## to _migrate().
## The main save remembers the last slot played (GameState.career_data).

const SLOT_COUNT := 3
const PATH_FORMAT := "user://career_slot_%d.json"


static func path(slot: int) -> String:
	return PATH_FORMAT % slot


static func exists(slot: int) -> bool:
	return FileAccess.file_exists(path(slot))


## The career in a slot, or null if the slot is empty or unreadable.
static func load_slot(slot: int) -> CareerData:
	var raw: Variant = SaveStore.read_json(path(slot))
	if not (raw is Dictionary):
		return null
	var c := CareerData.from_dict(_migrate(raw))
	c.slot = slot
	return c


## Writes the career to its slot (c.slot) and remembers it as the last played.
static func save(c: CareerData) -> bool:
	if c.slot == 0:
		return false  # slot 0 = an in-memory career (balance simulator); never saved
	if c.slot < 1 or c.slot > SLOT_COUNT:
		push_warning("CareerSave: bad slot %d" % c.slot)
		return false
	c.updated = int(Time.get_unix_time_from_system())
	var ok := SaveStore.write_json(path(c.slot), c.to_dict())
	if ok and int(GameState.career_data.get("last_slot", 0)) != c.slot:
		GameState.career_data["last_slot"] = c.slot
		GameState.save_game()
	return ok


static func delete_slot(slot: int) -> void:
	if exists(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path(slot)))
	if int(GameState.career_data.get("last_slot", 0)) == slot:
		GameState.career_data["last_slot"] = 0
		GameState.save_game()


## The slot "Continue Career" should open (0 = none).
static func last_slot() -> int:
	var s := int(GameState.career_data.get("last_slot", 0))
	return s if exists(s) else 0


## Short description for the slot list, e.g. {"empty": false, "name": "...",
## "line": "High School  -  Season 2, Week 5", "record": "4-0"}.
static func summary(slot: int) -> Dictionary:
	var c := load_slot(slot)
	if c == null:
		return {"empty": true}
	return {
		"empty": false,
		"name": c.display_name(),
		"stage": c.stage,
		"season": c.season,
		"week": c.week,
		"record": "%d-%d" % [int(c.record["w"]), int(c.record["l"])],
		"updated": c.updated,
	}


const LEGACY_IDS := "res://data/teams/legacy_ids.json"


static func _migrate(d: Dictionary) -> Dictionary:
	var v := int(d.get("career_version", 0))
	# Version 0 -> 1: nothing to convert.
	# Version 1 -> 2 (Stage 5): "Senior year complete" (phase stage_end) was a
	# placeholder; those careers continue at the senior-year recruiting screen.
	# New fields (gpa, tryout, route...) get their defaults in from_dict.
	if v < 2:
		if str(d.get("phase", "")) == "stage_end":
			d["phase"] = "recruiting"
		v = 2
	# Version 2 -> 3: relationships (people, former_people). Nothing to convert:
	# CareerData.from_dict creates the current stage's cast at 50 (neutral, no
	# effect) and puts Tyler Brooks on the team he'd have moved on to.
	if v < 3:
		v = 3
	# Version 3 -> 4: skill points, field goal range, kick trust. Range comes
	# from Power, so it needs nothing. Skill points: a starting grant for the
	# seasons already played. Team standing (new cast member): 50, nudged by
	# career field goal % (from_dict reads _team_start once).
	if v < 4:
		var t := CareerTuning.get_default()
		var stage := str(d.get("stage", CareerData.STAGE_HIGH_SCHOOL))
		var sp := t.sp_migrate_hs_per_season * maxi(int(d.get("season_in_stage", 1)), 1)
		if stage in [CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE]:
			sp = t.sp_migrate_college
		elif stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT, CareerData.STAGE_RETIRED]:
			sp = t.sp_migrate_pro
		d["skill_points"] = int(d.get("skill_points", sp))
		var tot: Variant = d.get("career_totals", {})
		var att := int(tot.get("fg_att", 0)) if tot is Dictionary else 0
		var made := int(tot.get("fg_made", 0)) if tot is Dictionary else 0
		var team := 50.0
		if att > 0:
			team = clampf(50.0 + (float(made) / att - 0.75) * 40.0, 35.0, 65.0)
		d["_team_start"] = team
		v = 4
	# Version 4 -> 5: benching (CareerData.bench). Nothing to convert: an old
	# save starts never benched, and the backup kicker joins the cast hidden.
	if v < 5:
		v = 5
	# Version 5 -> 6: the per-kick log (CareerData.kick_log). Past kicks were
	# never logged, so it starts empty; Stats shows "-" where it would need them.
	if v < 6:
		d["kick_log"] = []
		v = 6
	# Version 6 -> 7: followers. Old saves start with a small following for
	# their stage and seasons played (CareerTuning followers_migrate_*).
	if v < 7:
		var t := CareerTuning.get_default()
		var stage := str(d.get("stage", CareerData.STAGE_HIGH_SCHOOL))
		var pro := 0
		var hist: Variant = d.get("history", [])
		if hist is Array:
			for h in hist:
				if h is Dictionary and str(h.get("stage", "")) == CareerData.STAGE_PRO:
					pro += 1
		if stage == CareerData.STAGE_PRO:
			pro += 1
		var n := Followers.migrate_start(stage, int(d.get("season_in_stage", 1)), pro, t)
		d["followers"] = int(d.get("followers", n))
		d["social"] = {"peak": n, "best_tier": Followers.tier_of(n, t)}
		v = 7
	# Version 7 -> 8: the team database (data/teams, TeamDatabase). The old
	# built-in teams are gone: the player's high school becomes Hoboken High
	# School (every career starts there now), and other old team ids map to
	# database teams by data/teams/legacy_ids.json (_migrate_teams).
	if v < 8:
		_migrate_teams(d)
		v = 8
	if v > CareerData.VERSION:
		push_warning("CareerSave: career is from a newer version (%d)" % v)
	d["career_version"] = CareerData.VERSION
	return d


## Version 8: replaces old built-in team ids with team database ids wherever
## the save names a team (the player's team, the schedule, offers, a tryout,
## failed tryouts, Tyler's team). The player's own high school is always
## Hoboken; past results and history lines keep the names they were played
## under. Junior college and pro ids didn't change.
static func _migrate_teams(d: Dictionary) -> void:
	var legacy: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEGACY_IDS)) \
		if FileAccess.file_exists(LEGACY_IDS) else {}
	var hs: Dictionary = legacy.get("high_school", {}) if legacy is Dictionary else {}
	var col: Dictionary = legacy.get("college", {}) if legacy is Dictionary else {}
	var map := func(id: String) -> String:
		return str(hs.get(id, col.get(id, id)))
	# A saved team dict rebuilt from the database (its extra keys, such as
	# offer_type, are kept). Unknown ids are left as they are.
	var rebuild := func(t: Dictionary, new_id: String) -> Dictionary:
		var rec := TeamDatabase.team(new_id)
		if rec.is_empty():
			return t
		var out := t.duplicate(true)
		out.merge(Progression.team_from(rec, str(t.get("level", rec.get("level", "")))), true)
		return out
	var team: Variant = d.get("team", {})
	if team is Dictionary and not (team as Dictionary).is_empty():
		var id := str(team.get("id", ""))
		var stage := str(d.get("stage", CareerData.STAGE_HIGH_SCHOOL))
		if hs.has(id) or (stage == CareerData.STAGE_HIGH_SCHOOL and not TeamDatabase.has_team(id)):
			d["team"] = rebuild.call(team, TeamDatabase.start_team_id())
		elif col.has(id):
			d["team"] = rebuild.call(team, str(col[id]))
	var player: Variant = d.get("player", {})
	if player is Dictionary:
		player["hometown"] = str(TeamDatabase.start_team().get("city", player.get("hometown", "")))
	var sched: Variant = d.get("schedule", [])
	if sched is Array:
		for e in sched:
			if e is Dictionary and e.get("opponent") is Dictionary:
				var oid := str(e["opponent"].get("id", ""))
				if map.call(oid) != oid:
					e["opponent"] = rebuild.call(e["opponent"], map.call(oid))
	var offers: Variant = d.get("offers", [])
	if offers is Array:
		for off in offers:
			if off is Dictionary and col.has(str(off.get("school", ""))):
				off["school"] = str(col[str(off["school"])])
				off["name"] = str(TeamDatabase.team(str(off["school"])).get("name", off.get("name", "")))
	var tryout: Variant = d.get("tryout", {})
	if tryout is Dictionary and col.has(str(tryout.get("team", ""))):
		tryout["team"] = str(col[str(tryout["team"])])
		tryout["team_name"] = str(TeamDatabase.team(str(tryout["team"])).get("name", tryout.get("team_name", "")))
	var flags: Variant = d.get("flags", {})
	if flags is Dictionary and flags.get("failed_tryouts") is Array:
		flags["failed_tryouts"] = (flags["failed_tryouts"] as Array).map(func(x: Variant) -> String: return map.call(str(x)))
	var people: Variant = d.get("people", {})
	if people is Dictionary:
		for k in people:
			var pt: Variant = people[k].get("team") if people[k] is Dictionary else null
			if pt is Dictionary and map.call(str(pt.get("id", ""))) != str(pt.get("id", "")):
				var rec := TeamDatabase.team(map.call(str(pt["id"])))
				if not rec.is_empty():
					pt["id"] = str(rec["id"])
					pt["name"] = str(rec["name"])
					pt["short"] = str(rec["short"])

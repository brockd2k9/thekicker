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
	# Version 7 -> 8: savings. Old saves start with an estimate from the pro
	# seasons already played (Savings.migrate_start).
	if v < 8:
		var t := CareerTuning.get_default()
		var est := Savings.migrate_start(d, t)
		d["savings"] = int(d.get("savings", est))
		d["money_log"] = {"salary": est, "peak": est}
		v = 8
	# Version 8 -> 9: the team database (data/teams, TeamDatabase). The old
	# built-in teams are gone: the player's high school becomes Hoboken High
	# School (every career starts there now), and other old team ids map to
	# database teams by data/teams/legacy_ids.json (_migrate_teams).
	# (The team database was developed as save version 8 on its own branch;
	# savings took 8 first, so the database steps are 9-11.)
	if v < 9:
		_migrate_teams(d)
		v = 9
	# Version 9 -> 10: the pro league (32 clubs) replaced the 12 placeholder
	# clubs; their ids map by legacy_ids.json "pro" (_migrate_pro_teams).
	if v < 10:
		_migrate_pro_teams(d)
		v = 10
	# Version 10 -> 11: all-time records (CareerData.records starts empty) and
	# each season's team id in history, for the record books: found by the
	# saved team name (seasons played before the team database keep "").
	if v < 11:
		var hist: Variant = d.get("history", [])
		if hist is Array:
			for h in hist:
				if h is Dictionary and str(h.get("team_id", "")) == "":
					h["team_id"] = RecordBook.team_id_by_name(str(h.get("team", "")))
		v = 11
	if v > CareerData.VERSION:
		push_warning("CareerSave: career is from a newer version (%d)" % v)
	d["career_version"] = CareerData.VERSION
	return d


static func _legacy(section: String) -> Dictionary:
	var legacy: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEGACY_IDS)) \
		if FileAccess.file_exists(LEGACY_IDS) else {}
	var m: Variant = legacy.get(section, {}) if legacy is Dictionary else {}
	return m if m is Dictionary else {}


## Version 8: the team database replaced the old built-in teams. The
## player's own high school is always Hoboken; other old high school and
## college ids map by legacy_ids.json (_remap_team_ids).
static func _migrate_teams(d: Dictionary) -> void:
	var hs := _legacy("high_school")
	var team: Variant = d.get("team", {})
	if team is Dictionary and not (team as Dictionary).is_empty():
		var id := str(team.get("id", ""))
		var stage := str(d.get("stage", CareerData.STAGE_HIGH_SCHOOL))
		if hs.has(id) or (stage == CareerData.STAGE_HIGH_SCHOOL and not TeamDatabase.has_team(id)):
			d["team"] = _rebuild_team(team, TeamDatabase.start_team_id())
	var player: Variant = d.get("player", {})
	if player is Dictionary:
		player["hometown"] = str(TeamDatabase.start_team().get("city", player.get("hometown", "")))
	var ids := hs.duplicate()
	ids.merge(_legacy("college"))
	_remap_team_ids(d, ids)


## Version 9: the 12 placeholder pro clubs became the league's 32 clubs.
static func _migrate_pro_teams(d: Dictionary) -> void:
	_remap_team_ids(d, _legacy("pro"))


## A saved team dict rebuilt from the database (its extra keys, such as
## offer_type, are kept). Unknown ids are left as they are.
static func _rebuild_team(t: Dictionary, new_id: String) -> Dictionary:
	var rec := TeamDatabase.team(new_id)
	if rec.is_empty():
		return t
	var out := t.duplicate(true)
	out.merge(Progression.team_from(rec, str(t.get("level", rec.get("level", "")))), true)
	return out


## Replaces old team ids (ids: old -> new) wherever a save names a team: the
## player's team, the schedule, offers, a tryout, the draft result, the
## contract, failed tryouts and Tyler's team. Names saved with them follow;
## past results and history lines keep the names they were played under.
static func _remap_team_ids(d: Dictionary, ids: Dictionary) -> void:
	if ids.is_empty():
		return
	var new_name := func(id: String, fallback: Variant) -> String:
		return str(TeamDatabase.team(id).get("name", fallback))
	var team: Variant = d.get("team", {})
	if team is Dictionary and ids.has(str(team.get("id", ""))):
		d["team"] = _rebuild_team(team, str(ids[str(team["id"])]))
	var sched: Variant = d.get("schedule", [])
	if sched is Array:
		for e in sched:
			if e is Dictionary and e.get("opponent") is Dictionary and ids.has(str(e["opponent"].get("id", ""))):
				e["opponent"] = _rebuild_team(e["opponent"], str(ids[str(e["opponent"]["id"])]))
	var offers: Variant = d.get("offers", [])
	if offers is Array:
		for off in offers:
			if off is Dictionary and ids.has(str(off.get("school", ""))):
				off["school"] = str(ids[str(off["school"])])
				off["name"] = new_name.call(str(off["school"]), off.get("name", ""))
	# {team, team_name} records. A kick challenge's team_name is its title.
	for key in ["tryout", "draft_result", "contract"]:
		var r: Variant = d.get(key, {})
		if r is Dictionary and ids.has(str(r.get("team", ""))):
			r["team"] = str(ids[str(r["team"])])
			if r.has("team_name") and str(r.get("purpose", "")) != "challenge":
				r["team_name"] = new_name.call(str(r["team"]), r["team_name"])
	var flags: Variant = d.get("flags", {})
	if flags is Dictionary and flags.get("failed_tryouts") is Array:
		flags["failed_tryouts"] = (flags["failed_tryouts"] as Array).map(func(x: Variant) -> String:
			return str(ids.get(str(x), str(x))))
	var people: Variant = d.get("people", {})
	if people is Dictionary:
		for k in people:
			var pt: Variant = people[k].get("team") if people[k] is Dictionary else null
			if pt is Dictionary and ids.has(str(pt.get("id", ""))):
				var rec := TeamDatabase.team(str(ids[str(pt["id"])]))
				if not rec.is_empty():
					pt["id"] = str(rec["id"])
					pt["name"] = str(rec["name"])
					pt["short"] = str(rec["short"])

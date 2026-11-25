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
	# Version 8 -> 9: Daily Challenge claim ids (CareerData.daily_claims). No
	# daily reward was ever added to an older career, so it starts empty.
	if v < 9:
		d["daily_claims"] = []
		v = 9
	if v > CareerData.VERSION:
		push_warning("CareerSave: career is from a newer version (%d)" % v)
	d["career_version"] = CareerData.VERSION
	return d

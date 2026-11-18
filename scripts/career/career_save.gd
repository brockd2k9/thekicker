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
	if v > CareerData.VERSION:
		push_warning("CareerSave: career is from a newer version (%d)" % v)
	d["career_version"] = CareerData.VERSION
	return d

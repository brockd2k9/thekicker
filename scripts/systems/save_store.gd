class_name SaveStore
extends RefCounted
## Reads/writes the single save file as JSON in the user data folder:
##   user://kicker_save.json
## (Android: app-private storage. Windows: %APPDATA%/Godot/app_userdata/Kicker.
##  Linux: ~/.local/share/godot/app_userdata/Kicker. macOS: ~/Library/Application
##  Support/Godot/app_userdata/Kicker.)
##
## Layout (version 4):
##   { "version": 4, "stats": {...}, "achievements": {...}, "settings": {...},
##     "career": {"last_slot": 0}, "daily": {...} }
## "daily" is the Daily Challenge (streak, today's attempt, claimed days,
## rewards waiting for a career, clock guard; see DailyChallenge.to_dict()).
## "career" only remembers the last-played career slot (for "Continue Career").
## Each career is its own file, user://career_slot_N.json (see CareerSave), so
## a broken career file can never touch these all-time stats.
## When the layout changes: bump VERSION and add a step to _migrate().
## read_json() / write_json() are shared with CareerSave.

const VERSION := 4
const PATH := "user://kicker_save.json"


func load_data() -> Dictionary:
	var parsed: Variant = read_json(PATH)
	if not (parsed is Dictionary):
		return _empty()
	return _migrate(parsed)


func save_data(data: Dictionary) -> bool:
	data["version"] = VERSION
	return write_json(PATH, data)


## Reads a JSON file in user://. Returns null if it doesn't exist. A file that
## exists but can't be parsed is copied to <path>.bad (for debugging) and null
## is returned, so the caller starts fresh.
static func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		push_warning("SaveStore: could not read %s, starting fresh" % path)
		DirAccess.copy_absolute(ProjectSettings.globalize_path(path),
			ProjectSettings.globalize_path(path + ".bad"))
		return null
	return parsed


## Writes to a temp file first, then swaps it in, so a crash mid-write can't
## destroy the old save. path must be directly in user://.
static func write_json(path: String, data: Dictionary) -> bool:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveStore: can't write %s (%s)" % [tmp, error_string(FileAccess.get_open_error())])
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	if dir.file_exists(path.get_file()):
		dir.remove(path.get_file())
	return dir.rename(tmp.get_file(), path.get_file()) == OK


func _empty() -> Dictionary:
	return {"version": VERSION, "stats": {}, "achievements": {}, "settings": {},
		"career": {"last_slot": 0}, "daily": {}}


func _migrate(d: Dictionary) -> Dictionary:
	var v := int(d.get("version", 0))
	# Version 0 -> 1: nothing to convert; missing sections are filled in below.
	# Version 1 -> 2: "career" was a reserved null; it now remembers the last
	# career slot (the careers themselves are separate files).
	if v < 2:
		if not (d.get("career") is Dictionary):
			d["career"] = {"last_slot": 0}
		v = 2
	# Version 2 -> 3: the Daily Challenge ("daily"). Older saves start with no
	# streak and nothing claimed (DailyChallenge.from_dict fills the defaults).
	if v < 3:
		if not (d.get("daily") is Dictionary):
			d["daily"] = {}
		v = 3
	# Version 3 -> 4: Daily Challenge rewards became weekly (one payout on the
	# 7th successful day in a row). The week is the streak mod 7, so a streak in
	# progress lands on its day of the week with nothing to convert; earlier
	# per-day rewards still waiting in "pending" still pay out (by claim id).
	# New: "payout_days" (weeks paid), empty for old saves.
	if v < 4:
		var dd: Variant = d.get("daily")
		if dd is Dictionary and not (dd.get("payout_days") is Array):
			dd["payout_days"] = []
		v = 4
	if v > VERSION:
		push_warning("SaveStore: save is from a newer version (%d)" % v)
	for key in ["stats", "achievements", "settings", "daily"]:
		if not (d.get(key) is Dictionary):
			d[key] = {}
	if not (d.get("career") is Dictionary):
		d["career"] = {"last_slot": 0}
	d["version"] = VERSION
	return d

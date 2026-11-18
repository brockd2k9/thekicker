class_name SaveStore
extends RefCounted
## Reads/writes the single save file as JSON in the user data folder:
##   user://kicker_save.json
## (Android: app-private storage. Windows: %APPDATA%/Godot/app_userdata/Kicker.
##  Linux: ~/.local/share/godot/app_userdata/Kicker. macOS: ~/Library/Application
##  Support/Godot/app_userdata/Kicker.)
##
## Layout (version 1):
##   { "version": 1, "stats": {...}, "achievements": {...}, "settings": {...},
##     "career": null }
## "career" is reserved for Career Mode (player stats, schedule, season).
## When the layout changes: bump VERSION and add a step to _migrate().

const VERSION := 1
const PATH := "user://kicker_save.json"


func load_data() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return _empty()
	var text := FileAccess.get_file_as_string(PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		# Corrupt file: keep a copy for debugging and start fresh.
		push_warning("SaveStore: could not read %s, starting fresh" % PATH)
		DirAccess.copy_absolute(ProjectSettings.globalize_path(PATH),
			ProjectSettings.globalize_path(PATH + ".bad"))
		return _empty()
	return _migrate(parsed)


## Writes to a temp file first, then swaps it in, so a crash mid-write can't
## destroy the old save.
func save_data(data: Dictionary) -> bool:
	data["version"] = VERSION
	var tmp := PATH + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveStore: can't write %s (%s)" % [tmp, error_string(FileAccess.get_open_error())])
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	if dir.file_exists(PATH.get_file()):
		dir.remove(PATH.get_file())
	return dir.rename(tmp.get_file(), PATH.get_file()) == OK


func _empty() -> Dictionary:
	return {"version": VERSION, "stats": {}, "achievements": {}, "settings": {}, "career": null}


func _migrate(d: Dictionary) -> Dictionary:
	var v := int(d.get("version", 0))
	# Version 0 -> 1: nothing to convert yet; just fill in missing sections.
	# Future example:
	#   if v < 2:
	#       d["stats"]["new_field"] = 0
	#       v = 2
	if v > VERSION:
		push_warning("SaveStore: save is from a newer version (%d)" % v)
	for key in ["stats", "achievements", "settings"]:
		if not (d.get(key) is Dictionary):
			d[key] = {}
	if not d.has("career"):
		d["career"] = null
	d["version"] = VERSION
	return d

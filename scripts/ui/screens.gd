class_name Screens
extends RefCounted
## Scene paths and navigation between screens.

const MAIN_MENU := "res://scenes/screens/main_menu.tscn"
const PRACTICE := "res://scenes/screens/practice.tscn"
const CHALLENGE := "res://scenes/screens/challenge.tscn"
const CAREER := "res://scenes/screens/career_placeholder.tscn"
const STATS := "res://scenes/screens/stats.tscn"
const ACHIEVEMENTS := "res://scenes/screens/achievements.tscn"
const SETTINGS := "res://scenes/screens/settings.tscn"
## Debug builds only: edit career stats and watch the kick profile.
const CAREER_DEBUG := "res://scenes/screens/career_debug.tscn"
const CAREER_DEBUG_KICKS := "res://scenes/screens/career_debug_kicks.tscn"


static func go(path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	# The kick scene may leave slow motion or pause on.
	Engine.time_scale = 1.0
	tree.paused = false
	tree.change_scene_to_file.call_deferred(path)

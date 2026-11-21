class_name Screens
extends RefCounted
## Scene paths and navigation between screens.

const MAIN_MENU := "res://scenes/screens/main_menu.tscn"
const PRACTICE := "res://scenes/screens/practice.tscn"
const CHALLENGE := "res://scenes/screens/challenge.tscn"
const CAREER := "res://scenes/screens/career_menu.tscn"
const CAREER_NEW := "res://scenes/screens/career_new.tscn"
const CAREER_HUB := "res://scenes/screens/career_hub.tscn"
const CAREER_SCENARIO := "res://scenes/screens/career_scenario.tscn"
const CAREER_OUTLOOK := "res://scenes/screens/career_outlook.tscn"
const CAREER_GAME := "res://scenes/screens/career_game.tscn"
const CAREER_RESULTS := "res://scenes/screens/career_results.tscn"
const CAREER_SEASON := "res://scenes/screens/career_season.tscn"
const CAREER_STATS := "res://scenes/screens/career_stats.tscn"
const CAREER_PEOPLE := "res://scenes/screens/career_people.tscn"
const CAREER_SKILLS := "res://scenes/screens/career_skills.tscn"
## Hub → Stats: kicking stats by season and level.
const CAREER_KICKING := "res://scenes/screens/career_kicking.tscn"
## Hub → Recruiting: recruiting points and interested schools.
const CAREER_RECRUITING_BOARD := "res://scenes/screens/career_recruiting_board.tscn"
const CAREER_RECRUITING := "res://scenes/screens/career_recruiting.tscn"
const CAREER_TRYOUT := "res://scenes/screens/career_tryout.tscn"
const CAREER_DRAFT := "res://scenes/screens/career_draft.tscn"
const CAREER_CONTRACT := "res://scenes/screens/career_contract.tscn"
const CAREER_RETIRED := "res://scenes/screens/career_retired.tscn"
const CAREER_TUTORIAL := "res://scenes/screens/career_tutorial.tscn"
const STATS := "res://scenes/screens/stats.tscn"
const ACHIEVEMENTS := "res://scenes/screens/achievements.tscn"
const SETTINGS := "res://scenes/screens/settings.tscn"
## Debug builds only: edit career stats and watch the kick profile.
const CAREER_DEBUG := "res://scenes/screens/career_debug.tscn"
const CAREER_DEBUG_KICKS := "res://scenes/screens/career_debug_kicks.tscn"
const CAREER_DRILL := "res://scenes/screens/career_drill.tscn"
const CAREER_HALL := "res://scenes/screens/career_hall.tscn"


static func go(path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	# The kick scene may leave slow motion or pause on.
	Engine.time_scale = 1.0
	tree.paused = false
	# Short fade between screens (autoload ScreenFade); plain switch without it.
	var fade := tree.root.get_node_or_null("ScreenFade")
	if fade != null:
		fade.go(path)
	else:
		tree.change_scene_to_file.call_deferred(path)

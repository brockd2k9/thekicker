class_name MenuScreen
extends Control
## Base for the menu screens. Subclasses build their UI in _build(column).
## Back (Android back button, Esc on desktop) returns to the main menu.

@export var title: String = ""


func _ready() -> void:
	_apply_look()
	_play_music()
	var col := BrandUi.frame(self, title) if _uses_brand() else UiKit.build_frame(self, title)
	_build(col)


## True for screens moved to the broadcast design system (BrandUi.frame and
## the brand components); the rest keep the older look until they move.
func _uses_brand() -> bool:
	return false


func _build(_col: VBoxContainer) -> void:
	pass


## This screen's music cue (AudioManager.CUES); &"" keeps whatever plays.
## Menus play the menu music; career screens override.
func music_cue() -> StringName:
	return &"menu"


## Asks AudioManager for this screen's music (no restart if it's already
## playing). Screens with a one-shot on arrival override this.
func _play_music() -> void:
	var cue := music_cue()
	if cue != &"":
		AudioManager.play_music(cue)


## Palette for this screen. Menus use the default; career screens override.
func _apply_look() -> void:
	UiKit.reset_palette()


func go_back() -> void:
	Screens.go(Screens.MAIN_MENU)


## Standard Back button for the bottom of a screen (thumb reach).
func add_back_button(col: VBoxContainer) -> Button:
	var b: Button = BrandUi.button("Back", go_back, "secondary", "back") if _uses_brand() \
		else UiKit.button("Back", go_back, UiKit.SECONDARY, "back")
	col.add_child(b)
	return b


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_requested()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_requested()


func _on_back_requested() -> void:
	# A confirmation dialog is open: Back closes it instead.
	var modal := get_node_or_null("Modal")
	if modal != null:
		modal.queue_free()
		return
	go_back()

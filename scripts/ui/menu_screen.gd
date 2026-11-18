class_name MenuScreen
extends Control
## Base for the menu screens. Subclasses build their UI in _build(column).
## Back (Android back button, Esc on desktop) returns to the main menu.

@export var title: String = ""


func _ready() -> void:
	var col := UiKit.build_frame(self, title)
	_build(col)


func _build(_col: VBoxContainer) -> void:
	pass


func go_back() -> void:
	Screens.go(Screens.MAIN_MENU)


## Standard Back button for the bottom of a screen (thumb reach).
func add_back_button(col: VBoxContainer) -> Button:
	var b := UiKit.button("Back", go_back)
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

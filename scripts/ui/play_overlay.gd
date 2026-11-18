class_name PlayOverlay
extends CanvasLayer
## Sits on top of the kick scene in Practice and Challenge: a small pause button
## (top-center, clear of the HUD labels and of the swipe area) and the pause
## menu. Modes put their own modals (e.g. Challenge results) here too.
## The root ignores the mouse so swipes still reach SwipeInput; only the
## button and open modals take touches.

## Pause menu "quit" label, e.g. "Quit Run".
var quit_text := "Main Menu"

var root: Control
var _pause_button: Button


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.theme = UiKit.theme()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(safe)
	UiKit.apply_safe_area(safe, 18)
	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(top)

	_pause_button = Button.new()
	_pause_button.text = "II"
	_pause_button.custom_minimum_size = Vector2(76, 60)
	_pause_button.focus_mode = Control.FOCUS_NONE
	_pause_button.add_theme_font_size_override("font_size", 28)
	var box := UiKit._box(Color(0, 0, 0, 0.4), 12)
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	_pause_button.add_theme_stylebox_override("normal", box)
	_pause_button.add_theme_stylebox_override("hover", box)
	_pause_button.pressed.connect(pause)
	top.add_child(_pause_button)


func is_modal_open() -> bool:
	return root.get_node_or_null("Modal") != null


func pause() -> void:
	if is_modal_open():
		return
	get_tree().paused = true
	var v := UiKit.modal(root, "PAUSED")
	var modal := UiKit.modal_root(v)
	var resume := UiKit.button("Resume", func() -> void:
		modal.queue_free()
		get_tree().paused = false)
	v.add_child(resume)
	v.add_child(UiKit.button(quit_text, Screens.go.bind(Screens.MAIN_MENU)))
	if not OS.has_feature("mobile"):
		resume.grab_focus.call_deferred()


## Android back / Esc: open the pause menu, or close it if open.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_back()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()


func _back() -> void:
	var modal := root.get_node_or_null("Modal")
	if modal == null:
		pause()
	elif get_tree().paused:
		modal.queue_free()
		get_tree().paused = false
	# Other modals (results) stay; they have their own buttons.


## Hide the pause button (e.g. once a run is over).
func set_pause_enabled(on: bool) -> void:
	_pause_button.visible = on

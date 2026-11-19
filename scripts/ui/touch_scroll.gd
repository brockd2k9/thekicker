class_name TouchScroll
extends ScrollContainer
## A ScrollContainer you can drag-scroll on a phone even when the finger lands
## on a button or a panel inside it.
##
## Godot only drag-scrolls a ScrollContainer from events that reach it, and a
## Button (or PanelContainer) stops them by default. Every control added inside
## this container is switched to MOUSE_FILTER_PASS so the drag gets through,
## and a button whose press turns into a drag is cancelled (it doesn't fire).
## Sliders and text fields keep their own drag handling.

## How far (px) a finger may move and still count as a tap on a button.
## The list starts scrolling at the same distance.
const TAP_SLOP := 14.0


func _ready() -> void:
	scroll_deadzone = int(TAP_SLOP)
	get_tree().node_added.connect(_on_node_added)
	_adopt_tree(self)


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


func _enter_tree() -> void:
	if is_node_ready() and not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)


func _on_node_added(n: Node) -> void:
	if n is Control and is_ancestor_of(n):
		_adopt(n)


func _adopt_tree(n: Node) -> void:
	for c in n.get_children():
		if c is Control:
			_adopt(c)
		_adopt_tree(c)


func _adopt(c: Control) -> void:
	if c is Range or c is LineEdit or c is TextEdit:
		return  # scrollbars, sliders, text fields drag on their own
	if c is BaseButton:
		c.mouse_filter = Control.MOUSE_FILTER_PASS
		if not c.has_meta(&"touch_scroll"):
			c.set_meta(&"touch_scroll", true)
			c.gui_input.connect(_button_input.bind(c))
	elif c.mouse_filter == Control.MOUSE_FILTER_STOP:
		c.mouse_filter = Control.MOUSE_FILTER_PASS


## Remembers where a press started; once it moves past TAP_SLOP the press is
## cancelled (toggling disabled clears BaseButton's press state).
static func _button_input(e: InputEvent, b: BaseButton) -> void:
	if not (e is InputEventMouse or e is InputEventScreenTouch or e is InputEventScreenDrag):
		return
	var down: bool = (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT) \
			or e is InputEventScreenTouch
	# Screen position: the button itself moves once the list scrolls.
	var at: Vector2 = b.get_global_transform_with_canvas() * (e.position as Vector2)
	if down:
		if e.pressed:
			b.set_meta(&"press_at", at)
		else:
			b.remove_meta(&"press_at")
		return
	if not (e is InputEventMouseMotion or e is InputEventScreenDrag) or not b.has_meta(&"press_at"):
		return
	if (b.get_meta(&"press_at") as Vector2).distance_to(at) > TAP_SLOP:
		b.remove_meta(&"press_at")
		if not b.disabled:
			b.disabled = true
			b.disabled = false

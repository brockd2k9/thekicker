class_name RecordRow
extends PanelContainer
## One row of a record list (scenes/ui/record_row.tscn): rank, name, team ·
## year(s), value. Rows are pooled by the Records Book screen and refilled
## with show_entry(), so switching lists doesn't rebuild the scroll list.

@onready var _rank: Label = %Rank
@onready var _name: Label = %Name
@onready var _sub: Label = %Sub
@onready var _value: Label = %Value
@onready var _you: Control = %You

var _box_mine: StyleBoxFlat
var _box_plain: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box_plain = UiKit.panel_box()
	_box_plain.content_margin_top = 10
	_box_plain.content_margin_bottom = 10
	_box_mine = UiKit.panel_box(UiKit.ACCENT, Color(UiKit.ACCENT, 0.2))
	_box_mine.content_margin_top = 10
	_box_mine.content_margin_bottom = 10
	_box_mine.border_color = UiKit.ACCENT
	_box_mine.set_border_width_all(2)
	_rank.theme_type_variation = UiTokens.FONT_BANNER
	_rank.add_theme_font_size_override("font_size", 34)
	_value.theme_type_variation = UiTokens.FONT_DISPLAY
	_value.add_theme_font_size_override("font_size", 34)
	_name.add_theme_font_size_override("font_size", 28)
	_sub.add_theme_font_size_override("font_size", 22)
	_sub.add_theme_color_override("font_color", UiKit.MUTED)
	var you := UiKit.chip("YOU", UiKit.ACCENT, true, "", 20)
	_you.add_child(you)


## e: a RecordBook.ranked() entry; cat: its category; tied: the rank is shared.
func show_entry(e: Dictionary, cat: String, tied: bool) -> void:
	var mine := bool(e.get("mine", false))
	add_theme_stylebox_override("panel", _box_mine if mine else _box_plain)
	_rank.text = ("T%d" if tied else "%d") % int(e["rank"])
	_rank.add_theme_color_override("font_color", UiKit.ACCENT if int(e["rank"]) == 1 or mine else UiKit.TEXT)
	_name.text = str(e["name"])
	var parts := PackedStringArray([team_text(e["teams"]), str(e["years"])])
	if int(e.get("seasons", 1)) > 1:
		parts.append("%d seasons" % int(e["seasons"]))
	if bool(e.get("current", false)):
		parts.append("in progress")
	_sub.text = "  ·  ".join(parts)
	_value.text = RecordBook.value_text(float(e["value"]), cat)
	_value.add_theme_color_override("font_color", UiKit.ACCENT if mine else UiKit.TEXT)
	_you.visible = mine


## A team name, or abbreviations when a pro kicker played for several.
static func team_text(ids: Array) -> String:
	if ids.size() == 1:
		return str(TeamDatabase.team(str(ids[0])).get("name", ids[0]))
	var out := PackedStringArray()
	for id in ids:
		out.append(str(TeamDatabase.team(str(id)).get("short", id)))
	return "/".join(out)

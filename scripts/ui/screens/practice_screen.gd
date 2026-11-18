extends Node
## Practice: the original free-kick loop (random kicks forever), with a pause
## menu on top. No mode rules: field_goal_game.gd runs exactly as in Phase 1.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")


func _ready() -> void:
	add_child(FIELD_GOAL.instantiate())
	add_child(PlayOverlay.new())

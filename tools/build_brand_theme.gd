extends Node
## Writes assets/ui/brand_theme.tres from BrandTheme.build() (which reads
## Brand, the one palette / type / spacing file). The game builds the theme in
## code; the .tres is the same theme for the Godot editor. Run after editing
## Brand (test_brand checks they match):
##   godot --headless --path . res://tools/build_brand_theme.tscn


func _ready() -> void:
	var err := ResourceSaver.save(BrandTheme.build(), BrandTheme.PATH)
	print("brand theme: %s -> %s" % [BrandTheme.PATH, "saved" if err == OK else "error %d" % err])
	get_tree().quit(0 if err == OK else 1)

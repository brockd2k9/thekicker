class_name UiIcons
extends RefCounted
## The game's icon names, mapped onto the one icon family (BrandIcons:
## Material Symbols Sharp, filled; one style, one weight). Screens keep using
## these names (UiIcons.rect("health", ...)); the drawing is BrandIcons'.

## Old icon name -> BrandIcons name.
const MAP := {
	"accuracy": "target", "achievements": "cup", "ambition": "flag", "armband": "medal", "back": "back",
	"ball": "football", "book": "book", "calendar": "calendar", "career": "work", "challenge": "timer",
	"charisma": "star", "check": "check", "clipboard": "clipboard", "community": "heart_hand", "cross": "close",
	"down": "down", "driven": "flame", "energy": "energy", "fast": "fast", "film": "film",
	"film_student": "film", "flame": "flame", "fun": "mood", "handshake": "handshake", "health": "heart",
	"heart_hand": "heart_hand", "home": "home", "info": "info", "intelligence": "brain", "leadership": "medal",
	"lock": "lock", "mic": "mic", "money": "money", "next": "next", "pause": "pause", "pencil": "pencil",
	"perfectionist": "target", "play": "play", "plus": "plus", "power": "rocket", "practice": "repeat",
	"range": "range", "resilience": "shield", "romance": "heart", "school": "school", "settings": "settings",
	"skill": "upgrade", "social": "team", "stats": "stats", "team": "team", "toughness": "strength",
	"trash": "trash", "whistle": "whistle", "wind": "wind",
}

## Trait id -> icon (traits.json). Unknown traits get "charisma" (a star).
const TRAITS := {
	"driven": "ambition", "fan_favorite": "charisma", "team_captain": "armband",
	"film_student": "film", "media_savvy": "mic", "community_pillar": "heart_hand",
	"perfectionist": "accuracy", "field_general": "clipboard",
}

## Scenario category (scenarios_*.json) -> icon.
const CATEGORIES := {
	"career": "career", "social": "social", "school": "book", "training": "toughness",
	"team": "handshake", "media": "mic", "health": "health", "work": "money",
	"romance": "heart_hand", "family": "home", "trait": "charisma", "money": "money",
	"community": "heart_hand",
}


static func has(id: String) -> bool:
	return MAP.has(id) or BrandIcons.PATHS.has(id)


## The BrandIcons name for a game icon name (unknown names: a star).
static func brand_name(id: String) -> String:
	if MAP.has(id):
		return MAP[id]
	return id if BrandIcons.PATHS.has(id) else "star"


static func texture(id: String, color: Color = Brand.WHITE, size: int = 48) -> Texture2D:
	return BrandIcons.texture(brand_name(id), color, size)


## A TextureRect showing the icon at `size` px (ignores the mouse).
static func rect(id: String, color: Color = Brand.WHITE, size: int = 40) -> TextureRect:
	var r := TextureRect.new()
	r.texture = texture(id, color, size)
	r.custom_minimum_size = Vector2(size, size)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func for_trait(id: String) -> String:
	return TRAITS.get(id, "charisma")


static func for_category(cat: String) -> String:
	return CATEGORIES.get(cat, "info")

class_name UiIcons
extends RefCounted
## Original vector icons (simple SVG written here, no third-party art),
## rasterized at runtime with Image.load_svg_from_string and cached.
## UiIcons.texture(&"accuracy", Color.WHITE, 40) -> Texture2D
## Every icon is drawn in a 48x48 box; "C" in the markup is the color.

const S := 'fill="none" stroke="C" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"'

const SHAPES := {
	# --- life ---
	"health": '<path fill="C" d="M24 42 C10 32 4 25 4 16 C4 9 9 5 15 5 C19 5 22 7 24 10 C26 7 29 5 33 5 C39 5 44 9 44 16 C44 25 38 32 24 42Z"/>',
	"energy": '<path fill="C" d="M28 2 L8 28 H21 L18 46 L40 18 H27 Z"/>',
	"fun": '<circle cx="24" cy="24" r="19" S/><circle cx="17" cy="19" r="3" fill="C"/><circle cx="31" cy="19" r="3" fill="C"/><path d="M14 28 Q24 38 34 28" S/>',
	"social": '<circle cx="17" cy="15" r="7" fill="C"/><path fill="C" d="M3 42 C3 30 9 25 17 25 C25 25 31 30 31 42Z"/><circle cx="33" cy="17" r="6" fill="C" opacity="0.7"/><path fill="C" opacity="0.7" d="M33 26 C40 26 45 30 45 40 H34 C34 33 32 29 29 27 C30 26 31 26 33 26Z"/>',
	# --- football ---
	"power": '<ellipse cx="30" cy="24" rx="15" ry="10" transform="rotate(-30 30 24)" fill="C"/><path d="M3 18 H13 M2 26 H11 M4 34 H13" S/>',
	"accuracy": '<circle cx="24" cy="24" r="19" S/><circle cx="24" cy="24" r="11" S/><circle cx="24" cy="24" r="4" fill="C"/>',
	"resilience": '<path fill="C" d="M24 3 L42 10 V22 C42 33 34 41 24 45 C14 41 6 33 6 22 V10 Z"/>',
	"toughness": '<path d="M12 24 H36" S/><rect x="4" y="14" width="8" height="20" rx="2" fill="C"/><rect x="36" y="14" width="8" height="20" rx="2" fill="C"/><rect x="0" y="19" width="4" height="10" rx="1" fill="C"/><rect x="44" y="19" width="4" height="10" rx="1" fill="C"/>',
	# --- personality ---
	"charisma": '<path fill="C" d="M24 3 L30 17 L45 18 L33 28 L37 43 L24 35 L11 43 L15 28 L3 18 L18 17 Z"/>',
	"ambition": '<path d="M10 44 V5" S/><path fill="C" d="M12 6 H40 L33 15 L40 24 H12 Z"/>',
	"leadership": '<path fill="C" d="M4 38 V12 L15 22 L24 7 L33 22 L44 12 V38 Z"/><rect x="4" y="40" width="40" height="5" rx="2" fill="C"/>',
	"intelligence": '<path fill="C" d="M24 3 C14 3 8 10 8 18 C8 25 13 29 16 33 V36 H32 V33 C35 29 40 25 40 18 C40 10 34 3 24 3Z"/><rect x="17" y="39" width="14" height="6" rx="2" fill="C"/>',
	# --- menu ---
	"career": '<path fill="C" d="M12 4 H36 V16 C36 24 31 29 24 30 C17 29 12 24 12 16 Z"/><path d="M12 9 H5 C5 18 9 21 13 21 M36 9 H43 C43 18 39 21 35 21" S/><rect x="21" y="29" width="6" height="8" fill="C"/><rect x="13" y="37" width="22" height="7" rx="2" fill="C"/>',
	"challenge": '<circle cx="24" cy="27" r="17" S/><path d="M24 27 L31 19" S/><rect x="19" y="2" width="10" height="5" rx="2" fill="C"/><path d="M38 10 L42 6" S/>',
	"practice": '<path d="M24 46 V27 M8 27 H40 M8 27 V3 M40 27 V3" S/>',
	"stats": '<rect x="4" y="26" width="10" height="18" rx="2" fill="C"/><rect x="19" y="14" width="10" height="30" rx="2" fill="C"/><rect x="34" y="4" width="10" height="40" rx="2" fill="C"/>',
	"achievements": '<path fill="C" opacity="0.65" d="M13 2 H22 L28 18 H19 Z M26 2 H35 L29 18 H20 Z"/><circle cx="24" cy="31" r="14" fill="C"/><path fill="#00000055" d="M24 23 L26.5 28.5 L32 29 L28 33 L29 39 L24 36 L19 39 L20 33 L16 29 L21.5 28.5 Z"/>',
	"settings": '<path fill="C" d="M20 3 H28 L29 9 L34 11 L39 7 L44 13 L39 18 L41 22 L46 23 V29 L41 30 L39 35 L43 40 L37 45 L33 41 L28 43 L27 47 H21 L20 43 L15 41 L10 45 L4 39 L9 34 L7 30 L2 29 V23 L7 22 L9 17 L4 12 L10 6 L15 10 L19 8 Z"/><circle cx="24" cy="26" r="7" fill="#000000aa"/>',
	"home": '<path fill="C" d="M24 4 L45 23 H39 V44 H29 V31 H19 V44 H9 V23 H3 Z"/>',
	# --- misc ---
	"lock": '<rect x="8" y="20" width="32" height="25" rx="4" fill="C"/><path d="M15 21 V14 C15 8 19 4 24 4 C29 4 33 8 33 14 V21" S/>',
	"check": '<path d="M6 25 L18 37 L42 11" fill="none" stroke="C" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>',
	"cross": '<path d="M10 10 L38 38 M38 10 L10 38" fill="none" stroke="C" stroke-width="6" stroke-linecap="round"/>',
	"play": '<path fill="C" d="M12 5 L42 24 L12 43 Z"/>',
	"pause": '<rect x="9" y="6" width="11" height="36" rx="3" fill="C"/><rect x="28" y="6" width="11" height="36" rx="3" fill="C"/>',
	"back": '<path d="M30 6 L12 24 L30 42" fill="none" stroke="C" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>',
	"next": '<path d="M18 6 L36 24 L18 42" fill="none" stroke="C" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>',
	"fast": '<path fill="C" d="M4 8 L24 24 L4 40 Z M24 8 L44 24 L24 40 Z"/>',
	"wind": '<path d="M4 16 H30 C35 16 37 12 35 9 C33 6 28 7 28 11 M4 26 H38 C43 26 45 31 42 34 C39 37 35 35 35 32 M4 36 H22" S/>',
	"calendar": '<rect x="4" y="8" width="40" height="36" rx="4" S/><path d="M4 18 H44 M14 3 V12 M34 3 V12" S/><rect x="12" y="25" width="8" height="7" fill="C"/>',
	"school": '<path fill="C" d="M24 6 L46 17 L24 28 L2 17 Z"/><path d="M11 23 V33 C11 37 17 40 24 40 C31 40 37 37 37 33 V23 L24 30 Z" fill="C"/><path d="M42 19 V33" S/>',
	"money": '<rect x="2" y="12" width="44" height="26" rx="4" S/><circle cx="24" cy="25" r="6" fill="C"/>',
	"whistle": '<circle cx="18" cy="28" r="13" fill="C"/><rect x="24" y="15" width="22" height="9" rx="3" fill="C"/><circle cx="18" cy="28" r="4" fill="#00000077"/>',
	"ball": '<ellipse cx="24" cy="24" rx="21" ry="13" transform="rotate(-35 24 24)" fill="C"/><path d="M17 31 L31 17 M20 24 L24 28 M24 20 L28 24" stroke="#00000088" stroke-width="3" stroke-linecap="round"/>',
	"film": '<rect x="4" y="9" width="40" height="30" rx="3" fill="C"/><path fill="#00000077" d="M8 13 h5 v5 h-5z M8 30 h5 v5 h-5z M35 13 h5 v5 h-5z M35 30 h5 v5 h-5z"/><path fill="#00000077" d="M20 17 L30 24 L20 31 Z"/>',
	"mic": '<rect x="16" y="3" width="16" height="26" rx="8" fill="C"/><path d="M9 22 C9 31 16 36 24 36 C32 36 39 31 39 22 M24 36 V45 M16 45 H32" S/>',
	"clipboard": '<rect x="8" y="7" width="32" height="38" rx="4" S/><rect x="16" y="3" width="16" height="8" rx="2" fill="C"/><path d="M15 21 L20 26 L15 31 M28 21 L34 31 M34 21 L28 31" S/>',
	"handshake": '<path fill="C" d="M2 18 L12 12 L22 16 L30 12 L46 18 V30 L38 30 L28 40 C26 42 23 42 21 40 L10 30 H2 Z"/>',
	"armband": '<circle cx="24" cy="24" r="20" fill="C"/><path d="M31 16 C28 13 25 12 22 13 C16 14 13 19 13 24 C13 29 16 34 22 35 C25 36 28 35 31 32" fill="none" stroke="#000000aa" stroke-width="5" stroke-linecap="round"/>',
	"trash": '<path d="M6 11 H42 M18 11 V5 H30 V11" S/><path fill="C" d="M10 15 H38 L35 45 H13 Z"/>',
	"plus": '<path d="M24 6 V42 M6 24 H42" fill="none" stroke="C" stroke-width="6" stroke-linecap="round"/>',
	"info": '<circle cx="24" cy="24" r="20" fill="C"/><rect x="21" y="20" width="6" height="16" rx="2" fill="#000000aa"/><circle cx="24" cy="13" r="3.5" fill="#000000aa"/>',
	"flame": '<path fill="C" d="M24 2 C27 12 38 17 38 30 C38 39 31 46 24 46 C17 46 10 39 10 30 C10 23 14 19 17 15 C18 21 20 24 23 25 C22 17 22 9 24 2Z"/>',
	"pencil": '<path fill="C" d="M32 5 L43 16 L17 42 L4 45 L7 32 Z"/>',
	"book": '<path fill="C" d="M4 8 C12 6 19 7 23 11 V44 C19 40 12 39 4 41 Z M44 8 C36 6 29 7 25 11 V44 C29 40 36 39 44 41 Z"/>',
	"heart_hand": '<path fill="C" d="M24 26 C16 20 12 16 12 11 C12 7 15 4 18 4 C21 4 23 6 24 8 C25 6 27 4 30 4 C33 4 36 7 36 11 C36 16 32 20 24 26Z"/><path fill="C" d="M2 34 L12 30 H26 C29 30 29 35 26 35 H18 M2 34 V44 H30 L46 34 C46 30 42 29 40 31 L30 36"/>',
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

static var _cache: Dictionary = {}


static func has(id: String) -> bool:
	return SHAPES.has(id)


static func texture(id: String, color: Color = Color.WHITE, size: int = 48) -> Texture2D:
	var key := "%s|%s|%d" % [id, color.to_html(), size]
	if _cache.has(key):
		return _cache[key]
	var body: String = SHAPES.get(id, SHAPES["charisma"])
	body = body.replace(" S/>", " " + S + "/>").replace('"C"', '"#%s"' % color.to_html(false))
	if color.a < 1.0:
		body = '<g opacity="%.2f">%s</g>' % [color.a, body]
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 48 48">%s</svg>' % body
	var img := Image.new()
	var err := img.load_svg_from_string(svg, float(size) / 48.0)
	var tex: Texture2D
	if err == OK:
		tex = ImageTexture.create_from_image(img)
	else:
		tex = PlaceholderTexture2D.new()
	_cache[key] = tex
	return tex


## A TextureRect showing the icon at `size` px (ignores the mouse).
static func rect(id: String, color: Color = Color.WHITE, size: int = 40) -> TextureRect:
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

class_name UiTokens
extends RefCounted
## The one place for the game's look: palettes (colors), spacing, radii, sizes
## and fonts. Change a value here and every screen follows. UiKit turns these
## into the Theme and widgets; nothing else should hard-code colors.
##
## Style: "Night Broadcast", a night-game stadium (deep backgrounds, floodlight
## glow, gold accent) with broadcast graphics (slanted buttons, lower-third
## headers, tickers, color bars on cards).
## Career Mode swaps the palette by stage: Friday night (high school), Saturday
## (junior college / college), Sunday broadcast (pro). Team colors are added
## on top by UiKit.set_team().

# --- fonts (resources in assets/fonts, wired up in assets/ui/kicker_theme.tres) -----

const THEME_PATH := "res://assets/ui/kicker_theme.tres"
## Theme type variations for Labels (see kicker_theme.tres).
const FONT_BODY := &""             # Barlow SemiBold (theme default)
const FONT_DISPLAY := &"Display"   # Oswald Bold: headings, buttons, numbers
const FONT_BANNER := &"Banner"     # Anton: logo, result banners, scoreboards
const FONT_CONDENSED := &"Condensed"  # Barlow Condensed: chips, tickers

# --- sizes (720x1280 base viewport) -------------------------------------------------

const COLUMN_WIDTH := 640.0
## Minimum tap target. 88 px is about 9 mm on a phone.
const TAP_MIN := 88.0
const BUTTON_HEIGHT := 96.0
const MARGIN := 28
const GAP := 16          # between blocks in a column
const GAP_SMALL := 8     # inside rows
const PAD := 22          # inside panels (left/right)
const PAD_V := 16        # inside panels (top/bottom)

const RADIUS := 14       # panels and cards
const RADIUS_BUTTON := 10
const RADIUS_CHIP := 8
## Broadcast slant of buttons and chips (StyleBoxFlat.skew.x).
const SKEW := 0.16
## Colored bar on top of cards (broadcast style).
const CARD_BAR := 5
## Left stripe on secondary buttons.
const BUTTON_STRIPE := 6

const FONT_SIZE := 32
const FONT_TITLE := 56
const FONT_HEADING := 40
const FONT_SECTION := 24
const FONT_SMALL := 24
const FONT_BUTTON := 36

# --- motion (seconds) -----------------------------------------------------------------

const FADE_OUT := 0.12
const FADE_IN := 0.2
const PRESS_SCALE := 0.95
const BAR_TWEEN := 0.6

# --- palettes -------------------------------------------------------------------------

## mood: which backdrop Backdrop draws ("night", "saturday", "broadcast").
const NIGHT := {
	"name": "Friday Night",
	"mood": "night",
	"bg_top": Color("#10204a"), "bg_bottom": Color("#03060d"),
	"panel": Color(0.07, 0.11, 0.23, 0.92), "panel_edge": Color("#2c406f"),
	"panel_hi": Color(1, 1, 1, 0.07),
	"button": Color("#16244d"), "button_edge": Color("#33497d"),
	"text": Color("#f4f7ff"), "muted": Color("#9aa7c7"),
	"accent": Color("#ffb81c"), "accent_text": Color("#1a1205"),
	"alt": Color("#e10600"),       # broadcast red: ticker tags, "live" marks
	"good": Color("#3ee08f"), "bad": Color("#ff5a4e"), "warn": Color("#ffc857"),
	"danger": Color("#c8322a"),
	"life": Color("#35d6c4"), "football": Color("#ffb81c"), "personality": Color("#a18bff"),
	"glow": 0.45,
}

const SATURDAY := {
	"name": "Saturday",
	"mood": "saturday",
	"bg_top": Color("#46112a"), "bg_bottom": Color("#0c0307"),
	"panel": Color(0.2, 0.06, 0.11, 0.9), "panel_edge": Color("#723147"),
	"panel_hi": Color(1, 0.9, 0.8, 0.07),
	"button": Color("#4a1528"), "button_edge": Color("#7c3a50"),
	"text": Color("#fff6ee"), "muted": Color("#d2b0b4"),
	"accent": Color("#ff8a2a"), "accent_text": Color("#210b00"),
	"alt": Color("#f5e6c8"),       # cream
	"good": Color("#4fe39a"), "bad": Color("#ff6a5c"), "warn": Color("#ffd27a"),
	"danger": Color("#c8322a"),
	"life": Color("#3fd8c8"), "football": Color("#ffab4a"), "personality": Color("#c79bff"),
	"glow": 0.4,
}

const SUNDAY := {
	"name": "Sunday Broadcast",
	"mood": "broadcast",
	"bg_top": Color("#1d2029"), "bg_bottom": Color("#07080b"),
	"panel": Color(0.12, 0.13, 0.17, 0.95), "panel_edge": Color("#3a404e"),
	"panel_hi": Color(1, 1, 1, 0.05),
	"button": Color("#2a2f3b"), "button_edge": Color("#454c5c"),
	"text": Color("#ffffff"), "muted": Color("#a7adbb"),
	"accent": Color("#e8170f"), "accent_text": Color("#ffffff"),
	"alt": Color("#ffffff"),
	"good": Color("#22d36b"), "bad": Color("#ff4438"), "warn": Color("#ffcc33"),
	"danger": Color("#a8180f"),
	"life": Color("#00c2ff"), "football": Color("#f2b632"), "personality": Color("#ff4f98"),
	"glow": 0.3,
}

## Career stage -> palette.
static func for_stage(stage: String) -> Dictionary:
	match stage:
		"college", "juco":
			return SATURDAY
		"pro", "free_agent":
			return SUNDAY
	return NIGHT

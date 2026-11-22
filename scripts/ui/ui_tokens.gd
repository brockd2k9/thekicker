class_name UiTokens
extends RefCounted
## The one place for the game's look: palettes (colors), spacing, radii, sizes
## and fonts. Change a value here and every screen follows. UiKit turns these
## into the Theme and widgets; nothing else should hard-code colors.
##
## Style: the broadcast design system (Brand: strictly red, black and white).
## These tokens are the older names the screens use; their values come from
## Brand, which is the one place to change the look.

# --- fonts (resources in assets/fonts, wired up in assets/ui/kicker_theme.tres) -----

const THEME_PATH := "res://assets/ui/kicker_theme.tres"
## Theme type variations for Labels (see kicker_theme.tres).
const FONT_BODY := &""             # Barlow Regular (the theme default; Brand "Body")
const FONT_DISPLAY := &"Subhead"   # Barlow Condensed Bold: headings, buttons, values
const FONT_BANNER := &"Display"    # Barlow Condensed ExtraBold: big numbers, scores
const FONT_CONDENSED := &"Eyebrow" # Barlow Condensed Bold, tracked: chips, captions

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

const RADIUS := 0 # panels and cards
const RADIUS_BUTTON := 0 
const RADIUS_CHIP := 0 
## Broadcast slant of buttons and chips (StyleBoxFlat.skew.x).
const SKEW := 0.0
## Colored bar on top of cards (broadcast style).
const CARD_BAR := 4 
## Left stripe on secondary buttons.
const BUTTON_STRIPE := 0 

const FONT_SIZE := 32 
const FONT_TITLE := 60 
const FONT_HEADING := 48 
const FONT_SECTION := 28 
const FONT_SMALL := 28 
const FONT_BUTTON := 40 

# --- motion (seconds) -----------------------------------------------------------------

const FADE_OUT := 0.08 
const FADE_IN := 0.15 
const PRESS_SCALE := 0.97 
const BAR_TWEEN := 0.3 

# --- palette -------------------------------------------------------------------------
# One palette for every screen and stage, from Brand (red, black, white, greys).
# The old names (NIGHT / SATURDAY / SUNDAY) stay so screens keep compiling;
# they are all the broadcast palette now. Stage and team identity show as
# small team-color accents only.

## mood: kept for older code ("broadcast": the black background with its faint texture).
const BROADCAST := {
	"name": "Broadcast",
	"mood": "broadcast",
	"bg_top": Brand.INK_0, "bg_bottom": Brand.INK_0,
	"panel": Brand.INK_1, "panel_edge": Brand.LINE,
	"panel_hi": Brand.TEXTURE,
	"button": Brand.INK_2, "button_edge": Brand.LINE,
	"text": Brand.WHITE, "muted": Brand.GREY,
	"accent": Brand.RED_HOT, "accent_text": Brand.WHITE,
	"alt": Brand.WHITE,
	"good": Brand.WHITE, "bad": Brand.RED_HOT, "warn": Brand.RED_HOT,
	"danger": Brand.RED_DEEP,
	"life": Brand.WHITE, "football": Brand.WHITE, "personality": Brand.WHITE,
	"glow": 0.0,
}
const NIGHT := BROADCAST
const SATURDAY := BROADCAST
const SUNDAY := BROADCAST


## Career stage -> palette (the same for every stage).
static func for_stage(_stage: String) -> Dictionary:
	return BROADCAST

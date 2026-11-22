class_name Brand
extends RefCounted
## The broadcast UI system: THE one file for colors, type, spacing, shape and
## motion. Strictly red, black and white (plus greys); team colors only as
## small accents (a stripe or a block), passed in at runtime. Nothing else in
## the UI may hard-code a color: BrandTheme and the components read from here.
##
## Look: modern TV sports broadcast graphics. Hard angles and clipped corners,
## bold condensed headings, big white numerals, thin red rules, a faint
## diagonal texture on dark panels. Flat and graphic: no glow, gloss,
## gradients or heavy shadows.
##
## Sizes are in the 720x1280 base viewport (stretch mode canvas_items). On a
## 390 pt wide phone 1 pt = 1.85 px, so the smallest text (CAPTION, 28 px) is
## about 15 pt (14 pt on a 360 pt phone).

# --- palette ---------------------------------------------------------------------------
# Blacks for layering, from the screen back to the most raised surface.

## Screen background.
const INK_0 := Color("#060607")
## Panels and cards.
const INK_1 := Color("#0f0f10")
## Raised surfaces: rows, secondary buttons, tiles.
const INK_2 := Color("#18181a")
## Hover / pressed surfaces, bar tracks.
const INK_3 := Color("#232325")
## Dividers and inner strokes.
const LINE := Color("#303033")
## Strong strokes (outlined chips, hovered secondary buttons).
const LINE_STRONG := Color("#4b4b4f")
## Secondary text (AA on every ink).
const GREY := Color("#a2a2a6")
## Disabled text and icons (not meant to be read closely).
const GREY_DIM := Color("#616165")
## Primary text and numbers.
const WHITE := Color("#ffffff")
## The one hue: primary actions and key highlights only.
const RED := Color("#e0101e")
## Hovered primary actions; red text on black (AA).
const RED_HOT := Color("#ff2d38")
## Pressed primary actions.
const RED_DEEP := Color("#a30914")
## Dim overlay behind popups.
const SCRIM := Color(0.024, 0.024, 0.027, 0.86)
## The diagonal panel texture (white lines at this alpha).
const TEXTURE := Color(1, 1, 1, 0.022)

## Every palette color by name (the gallery, the contrast test).
const PALETTE := {"INK_0": INK_0, "INK_1": INK_1, "INK_2": INK_2, "INK_3": INK_3, "LINE": LINE,
	"LINE_STRONG": LINE_STRONG, "GREY": GREY, "GREY_DIM": GREY_DIM, "WHITE": WHITE, "RED": RED,
	"RED_HOT": RED_HOT, "RED_DEEP": RED_DEEP}

## Text / background pairs the UI uses, each checked for WCAG contrast:
## [text, background, minimum ratio] (4.5 normal text, 3.0 large / bold 24+ px).
const TEXT_PAIRS := [
	["WHITE", "INK_0", 4.5], ["WHITE", "INK_1", 4.5], ["WHITE", "INK_2", 4.5], ["WHITE", "INK_3", 4.5],
	["GREY", "INK_0", 4.5], ["GREY", "INK_1", 4.5], ["GREY", "INK_2", 4.5], ["GREY", "INK_3", 4.5],
	["WHITE", "RED", 4.5], ["WHITE", "RED_DEEP", 4.5], ["WHITE", "RED_HOT", 3.0],
	["RED_HOT", "INK_0", 4.5], ["RED_HOT", "INK_1", 4.5], ["RED_HOT", "INK_2", 4.5],
	["INK_0", "WHITE", 4.5],
]

# --- type ----------------------------------------------------------------------------
# One bold condensed sans for headings and numbers (Barlow Condensed), one
# clean sans for body (Barlow). Both SIL Open Font License (assets/fonts/OFL-*.txt).

const FONT_HEAD := "res://assets/fonts/BarlowCondensed-Bold.ttf"
const FONT_NUMBER := "res://assets/fonts/BarlowCondensed-ExtraBold.ttf"
const FONT_BODY := "res://assets/fonts/Barlow-Regular.ttf"
const FONT_BODY_STRONG := "res://assets/fonts/Barlow-Medium.ttf"

## The type scale: the only sizes the UI uses. name: [font, px, uppercase].
## Label theme type variations of the same names (BrandTheme).
const TYPE := {
	"Hero": [FONT_NUMBER, 128, false],      # the one big number on a screen
	"Display": [FONT_NUMBER, 84, false],    # stat tile numbers, scores
	"Title": [FONT_HEAD, 60, true],         # screen titles
	"Heading": [FONT_HEAD, 48, true],       # popup and section-lead titles
	"Subhead": [FONT_HEAD, 40, true],       # card titles, row values
	"Body": [FONT_BODY, 32, false],         # reading text
	"BodyStrong": [FONT_BODY_STRONG, 32, false],  # row titles, emphasis
	"Caption": [FONT_BODY_STRONG, 28, false],     # secondary lines (the minimum)
	"Eyebrow": [FONT_HEAD, 28, true],       # labels over numbers, chips, tabs
}
## Button text (condensed, uppercase).
const BUTTON_TYPE := [FONT_HEAD, 40]
## Letter spacing (px) for uppercase condensed labels.
const TRACKING := 1
## Smallest text size allowed anywhere.
const MIN_TEXT := 28

# --- spacing and size ----------------------------------------------------------------

## The content column (portrait phone width minus margins; centered on wide windows).
const COLUMN := 640.0
## Screen edge margin (plus the safe area on phones).
const MARGIN := 28
## Spacing scale: only these gaps.
const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 16
const SPACE_4 := 24
const SPACE_5 := 32
const SPACE_6 := 48
## Inside panels.
const PAD_X := 24
const PAD_Y := 18
## Minimum tap target (about 9 mm on a phone).
const TAP := 88.0
const BUTTON_H := 96.0
const ROW_H := 104.0
const BAR_H := 14.0

# --- shape ---------------------------------------------------------------------------

## Corner clip on buttons and cards (top-left and bottom-right, like a lower third).
const CUT := 18
const CUT_SMALL := 10
## Inner stroke width.
const STROKE := 2
## The thin red rule under headers and on accent cards.
const RULE := 4
## Accent stripe width (warnings, team, pressed rows).
const STRIPE := 6
## Diagonal texture line spacing (px).
const TEXTURE_STEP := 7

# --- motion (seconds; snappy, never bouncy) ------------------------------------------

const T_PRESS := 0.08
const T_FAST := 0.12
const T_BASE := 0.15
const T_COUNT := 0.5
const PRESS_SCALE := 0.97


# --- helpers -------------------------------------------------------------------------

## WCAG contrast ratio of two opaque colors.
static func contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func _luminance(c: Color) -> float:
	var ch := func(v: float) -> float:
		return v / 12.92 if v <= 0.03928 else pow((v + 0.055) / 1.055, 2.4)
	return 0.2126 * ch.call(c.r) + 0.7152 * ch.call(c.g) + 0.0722 * ch.call(c.b)


## A team color as a small accent: kept as is when it stands out from the inks,
## otherwise lightened until it does (a stripe must be visible on black).
static func team_accent(c: Color) -> Color:
	var out := c
	for i in 6:
		if contrast(out, INK_1) >= 2.0:
			break
		out = out.lightened(0.2)
	return out

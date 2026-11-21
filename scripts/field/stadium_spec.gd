class_name StadiumSpec
extends RefCounted
## What a stadium looks like, for FieldBuilder (and the sideline warmup).
## Built from boxes, planes and the crowd shader like the original stadium; no
## models or textures. StadiumSpec.new() is that original stadium exactly
## (Practice mode keeps it). Career games get a tier from Stadiums.
##
## Fields:
##   tier         id, e.g. "hs_1", "college_top", "pro_3" ("default": the original)
##   decks        seating deck lengths up the slope (m), stacked bottom to top
##   wall_height  front wall under the first deck (m); bleachers: a low rail
##   bleachers    aluminum bleachers (pale seats, no suites, no roof)
##   stand_width  width of the end stands (m)
##   wings        stands along both sidelines too (a bowl)
##   suite_band   the band between decks is dark glass suites (else concrete)
##   roof_rim     a pale rim above the top deck
##   press_box    a small box on top of the stands (high school, small college)
##   lights       "poles" (4 poles), "towers" (2 towers) or "ring" (a lit roof ring)
##   empty_seats  share of empty seats (the crowd shader)
##   scoreboard   "none", "small" (on posts by the end zone), "board", "video"
##   night        night sky, darker ambient light, brighter light panels
##                (no real-time lights added)
##   hash_x       hash marks' distance from the middle of the field (m) by stage
##   crowd_level  0-1, how loud the crowd is: a hook for crowd sound later
##                (FieldBuilder.crowd_level(); nothing plays it yet)

const HASH_HS := 8.13  # high school: field split in thirds (53'4" apart)
const HASH_COLLEGE := 6.1  # college: 40 ft apart
const HASH_PRO := 2.82  # pro: 18'6" apart, in line with the uprights
const LIGHTS := ["poles", "towers", "ring"]
const SCOREBOARDS := ["none", "small", "board", "video"]

var tier := "default"
var decks: Array[float] = [46.0, 30.0]
var wall_height := 2.6
var bleachers := false
var stand_width := 200.0
var wings := false
var suite_band := true
var roof_rim := true
var press_box := false
var lights := "towers"
var empty_seats := 0.08
var scoreboard := "none"
var night := false
var hash_x := 3.12
var crowd_level := 0.8
## The home crowd's colors [primary, secondary] (empty: the default blue and
## orange) and the end zone color (alpha 0: the default navy).
var crowd_colors: Array = []
var endzone := Color(0, 0, 0, 0)


## Every tier by id (the night flag is set per game by Stadiums).
static func preset(id: String) -> StadiumSpec:
	var s := StadiumSpec.new()
	s.tier = id
	match id:
		"hs_1":  # aluminum bleachers, four light poles
			s.set_shape([12.0], 1.1, 80.0, true)
			s.lights = "poles"
			s.empty_seats = 0.55
			s.scoreboard = "small"
			s.hash_x = HASH_HS
			s.crowd_level = 0.3
		"hs_2":  # a wall, one deck and a press box
			s.set_shape([18.0], 1.8, 120.0)
			s.press_box = true
			s.lights = "poles"
			s.empty_seats = 0.35
			s.scoreboard = "small"
			s.hash_x = HASH_HS
			s.crowd_level = 0.45
		"hs_3":  # two small decks and a scoreboard
			s.set_shape([20.0, 12.0], 2.2, 150.0)
			s.press_box = true
			s.lights = "towers"
			s.empty_seats = 0.2
			s.scoreboard = "board"
			s.hash_x = HASH_HS
			s.crowd_level = 0.55
		"juco":  # bleachers
			s.set_shape([14.0], 1.2, 100.0, true)
			s.lights = "poles"
			s.empty_seats = 0.5
			s.scoreboard = "small"
			s.hash_x = HASH_COLLEGE
			s.crowd_level = 0.35
		"college_small":  # one deck
			s.set_shape([26.0], 2.4, 150.0)
			s.press_box = true
			s.empty_seats = 0.3
			s.scoreboard = "board"
			s.hash_x = HASH_COLLEGE
			s.crowd_level = 0.55
		"college_mid":  # two decks and a board
			s.set_shape([34.0, 20.0], 2.6, 180.0)
			s.suite_band = true
			s.empty_seats = 0.15
			s.scoreboard = "board"
			s.hash_x = HASH_COLLEGE
			s.crowd_level = 0.7
		"college_top":  # a three-deck bowl and a video board
			s.set_shape([46.0, 30.0, 18.0], 2.6, 220.0)
			s.suite_band = true
			s.roof_rim = true
			s.wings = true
			s.empty_seats = 0.04
			s.scoreboard = "video"
			s.hash_x = HASH_COLLEGE
			s.crowd_level = 0.95
		"pro_1":
			s.set_shape([40.0, 24.0], 2.6, 190.0)
			s.suite_band = true
			s.roof_rim = true
			s.empty_seats = 0.12
			s.scoreboard = "video"
			s.hash_x = HASH_PRO
			s.crowd_level = 0.75
		"pro_2":
			s.set_shape([46.0, 30.0], 2.6, 210.0)
			s.suite_band = true
			s.roof_rim = true
			s.wings = true
			s.empty_seats = 0.06
			s.scoreboard = "video"
			s.hash_x = HASH_PRO
			s.crowd_level = 0.85
		"pro_3":
			s.set_shape([50.0, 32.0, 20.0], 2.8, 230.0)
			s.suite_band = true
			s.roof_rim = true
			s.wings = true
			s.lights = "ring"
			s.empty_seats = 0.02
			s.scoreboard = "video"
			s.hash_x = HASH_PRO
			s.crowd_level = 1.0
		_:
			s.tier = "default"
	return s


## Every preset id (tests, the layout check).
static func preset_ids() -> Array[String]:
	return ["hs_1", "hs_2", "hs_3", "juco", "college_small", "college_mid", "college_top",
		"pro_1", "pro_2", "pro_3"]


func set_shape(deck_lengths: Array, wall: float, width: float, is_bleachers := false) -> void:
	decks.clear()
	for d in deck_lengths:
		decks.append(float(d))
	wall_height = wall
	stand_width = width
	bleachers = is_bleachers
	suite_band = false
	roof_rim = false


## Draw calls this stadium adds over the empty field (one per box or plane;
## the original stadium is 10). Tests keep each tier inside its budget.
func draw_calls() -> int:
	var n := 2  # front wall + trim
	n += decks.size() * 2 - 1  # each deck, and a band between decks
	if roof_rim:
		n += 1
	if press_box:
		n += 2
	if wings:
		n += 4  # wall + deck on each sideline
	match lights:
		"poles":
			n += 8
		"ring":
			n += 1
		_:
			n += 4
	match scoreboard:
		"small":
			n += 3
		"board", "video":
			n += 2
	return n

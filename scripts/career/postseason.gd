class_name Postseason
extends RefCounted
## The postseason after each regular season (numbers: PostseasonConfig,
## res://tuning/postseason.tres).
##
## It reuses the weekly loop: when the last scheduled week ends,
## CareerManager.end_week() calls advance(), which either ends the season or
## appends the next postseason game to the schedule as one more week
## ({type: "playoff", postseason: "playoff"/"bowl", round, round_name, final}).
## That week runs like any other (scenarios, Outlook, the game in the kick
## scene, Results), with more pressure and no ties. Win and the next round is
## appended; lose and the season ends (PHASE_SEASON_END).
##
## Postseason games don't count in the regular-season record (CareerData.record,
## which recruiting / draft / qualifying read): they're counted in
## CareerData.postseason (this season) and postseason_career (career). Kicks
## count in the season and career kicking stats like any game.
##
## Flags for scenario writers (CareerContent.ENGINE_FLAGS), reset each season:
##   made_playoffs      qualified for a playoff bracket this season
##   bowl_game          a college team going to a bowl this season
##   in_postseason      still alive in the postseason (cleared when it ends)
##   championship_game  this week's game is a final (bracket or bowl)
##   eliminated         lost a postseason game this season
##   missed_postseason  the regular season wasn't good enough
##   won_championship   won the bracket's final this season (kept through the
##                      offseason after it)
## Career-long metrics: playoff_appearances, championships, postseason_wins.

const PATH := "res://tuning/postseason.tres"
const SEASON_FLAGS := ["made_playoffs", "bowl_game", "in_postseason", "championship_game",
	"eliminated", "missed_postseason", "won_championship"]

static var _cached: PostseasonConfig


static func config() -> PostseasonConfig:
	if _cached == null:
		var r: Variant = load(PATH) if ResourceLoader.exists(PATH) else null
		_cached = r if r is PostseasonConfig else PostseasonConfig.new()
	return _cached


## Tests / tools: use these numbers instead of the file (null = back to the file).
static func use_config(cfg: PostseasonConfig) -> void:
	_cached = cfg


static func is_postseason(e: Dictionary) -> bool:
	return str(e.get("type", "")) == "playoff"


## A new season: nothing decided yet, the season flags off.
static func new_season(c: CareerData) -> void:
	c.postseason = {}
	for f in SEASON_FLAGS:
		c.flags[f] = false


## (W + T/2) / games of the regular season (0 with no games).
static func win_share(record: Dictionary) -> float:
	var g := int(record.get("w", 0)) + int(record.get("l", 0)) + int(record.get("t", 0))
	if g <= 0:
		return 0.0
	return (int(record.get("w", 0)) + 0.5 * int(record.get("t", 0))) / float(g)


## What this regular season earns: "playoff", "bowl" or "" (season over).
static func qualify(c: CareerData) -> String:
	var g := config()
	var share := win_share(c.record)
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL:
			return "playoff" if share >= g.hs_playoff_min - 0.0001 else ""
		CareerData.STAGE_JUCO:
			return "playoff" if share >= g.juco_playoff_min - 0.0001 else ""
		CareerData.STAGE_COLLEGE:
			if share >= g.college_playoff_min - 0.0001:
				return "playoff"
			return "bowl" if share >= g.college_bowl_min - 0.0001 else ""
		CareerData.STAGE_PRO:
			return "playoff" if share >= g.pro_playoff_min - 0.0001 else ""
	return ""


## The round names for this stage's bracket (a bowl is one game).
static func rounds(c: CareerData, kind: String) -> PackedStringArray:
	if kind == "bowl":
		return PackedStringArray([str(c.postseason.get("name", "Bowl Game"))])
	var g := config()
	var r: PackedStringArray
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL:
			r = g.hs_rounds
		CareerData.STAGE_JUCO:
			r = g.juco_rounds
		CareerData.STAGE_COLLEGE:
			r = g.college_rounds
		_:
			r = g.pro_rounds
	return r if not r.is_empty() else PackedStringArray(["Championship"])


## Extra game parameters for a postseason week (merged into
## Progression.game_params): no ties, more pressure.
static func adjust_params(p: Dictionary, e: Dictionary) -> Dictionary:
	if not is_postseason(e):
		return p
	var g := config()
	p["no_tie"] = true
	var extra := g.pressure_bonus + g.pressure_per_round * int(e.get("round", 0))
	if bool(e.get("final", false)):
		extra += g.final_pressure_bonus
	p["pressure_bonus"] = float(p.get("pressure_bonus", 0.0)) + extra
	return p


## The regular season (or the last postseason game) is over: decide what's next.
## Appends the next postseason game to c.schedule, or ends the postseason.
## Returns {event: "missed" / "qualified" / "advanced" / "eliminated" /
## "champion" / "bowl_won" / "bowl_lost" / "", text}. Called by
## CareerManager.end_week() once c.week is past the schedule.
static func advance(c: CareerData, rng: RandomNumberGenerator, t: CareerTuning) -> Dictionary:
	if not (c.stage in [CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO, CareerData.STAGE_COLLEGE,
			CareerData.STAGE_PRO]):
		return {"event": "", "text": ""}
	var ps := c.postseason
	if ps.is_empty():
		return _start(c, rng)
	if str(ps.get("status", "")) != "alive" or c.schedule.is_empty():
		return {"event": "", "text": ""}
	var last: Dictionary = c.schedule.back()
	var res: Variant = last.get("result")
	if not is_postseason(last) or not (res is Dictionary):
		return {"event": "", "text": ""}
	var kind := str(ps.get("kind", "playoff"))
	var name := str(last.get("round_name", ""))
	var opp: Dictionary = last.get("opponent", {})
	var won := str(res.get("outcome", "L")) == "W"  # (a tie can't happen; it would count as a loss)
	ps["games"].append({"round": int(last.get("round", 0)), "name": name, "opponent": opp.get("name", ""),
		"us": int(res.get("us", 0)), "them": int(res.get("them", 0)), "outcome": "W" if won else "L"})
	var car := career(c)
	c.flags["championship_game"] = false
	if not won:
		ps["l"] = int(ps.get("l", 0)) + 1
		car["losses"] = int(car["losses"]) + 1
		ps["status"] = "bowl_lost" if kind == "bowl" else "eliminated"
		c.flags["in_postseason"] = false
		c.flags["eliminated"] = true
		var txt := "Season over: lost the %s to %s, %d-%d." % [name, opp.get("name", "them"),
			int(res.get("us", 0)), int(res.get("them", 0))]
		ps["text"] = txt
		return {"event": ps["status"], "text": txt}
	ps["w"] = int(ps.get("w", 0)) + 1
	car["wins"] = int(car["wins"]) + 1
	if bool(last.get("final", false)):
		c.flags["in_postseason"] = false
		var txt: String
		if kind == "bowl":
			ps["status"] = "bowl_won"
			car["bowl_wins"] = int(car["bowl_wins"]) + 1
			txt = "%s champions! You beat %s, %d-%d." % [name, opp.get("name", "them"),
				int(res.get("us", 0)), int(res.get("them", 0))]
		else:
			ps["status"] = "champion"
			car["titles"] = int(car["titles"]) + 1
			car["title_list"].append({"stage": c.stage, "season": c.season, "name": name,
				"team": c.team.get("name", "")})
			c.flags["won_championship"] = true
			SkillPoints.earn(c, config().title_skill_points, "Championship")
			txt = "CHAMPIONS! You won the %s, %d-%d over %s." % [name, int(res.get("us", 0)),
				int(res.get("them", 0)), opp.get("name", "them")]
		ps["text"] = txt
		return {"event": ps["status"], "text": txt}
	var nxt := _append(c, int(last.get("round", 0)) + 1, rng)
	return {"event": "advanced", "text": "You won! Next: the %s against %s." % [nxt.get("round_name", ""),
		nxt.get("opponent", {}).get("name", "")]}


static func _start(c: CareerData, rng: RandomNumberGenerator) -> Dictionary:
	var kind := qualify(c)
	var car := career(c)
	if kind == "":
		c.postseason = {"kind": "none", "status": "missed", "w": 0, "l": 0, "games": [],
			"text": "No postseason this year (%s)." % _rec(c.record)}
		c.flags["missed_postseason"] = true
		return {"event": "missed", "text": str(c.postseason["text"])}
	c.postseason = {"kind": kind, "status": "alive", "w": 0, "l": 0, "games": []}
	if kind == "bowl":
		var names := config().bowl_names
		c.postseason["name"] = names[rng.randi_range(0, names.size() - 1)] if not names.is_empty() else "Bowl Game"
		car["bowls"] = int(car["bowls"]) + 1
		c.flags["bowl_game"] = true
	else:
		car["appearances"] = int(car["appearances"]) + 1
		var by: Dictionary = car["by_stage"]
		by[c.stage] = int(by.get(c.stage, 0)) + 1
		c.flags["made_playoffs"] = true
	c.flags["in_postseason"] = true
	var e := _append(c, 0, rng)
	var txt := ("Bowl bound! %s vs %s." if kind == "bowl" else "You made the playoffs! %s vs %s.") % [
		e.get("round_name", ""), e.get("opponent", {}).get("name", "")]
	c.postseason["text"] = txt
	return {"event": "qualified", "text": txt}


## Appends postseason round `i` to the schedule and returns the entry.
static func _append(c: CareerData, i: int, rng: RandomNumberGenerator) -> Dictionary:
	var g := config()
	var kind := str(c.postseason.get("kind", "playoff"))
	var names := rounds(c, kind)
	i = clampi(i, 0, names.size() - 1)
	var final := i == names.size() - 1
	# A strong opponent you haven't met this postseason.
	var met := {}
	for e in c.schedule:
		if is_postseason(e):
			met[str(e.get("opponent", {}).get("id", ""))] = true
	var pool := Progression.opponents(c).filter(func(s: Dictionary) -> bool:
		return not met.has(str(s.get("id", ""))))
	if pool.is_empty():
		pool = Progression.opponents(c)
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("strength", 50)) > float(b.get("strength", 50)))
	var top := pool.slice(0, maxi(g.opponent_pool, 1))
	var opp: Dictionary = Progression.team_from(top[rng.randi_range(0, top.size() - 1)], c.stage) \
		if not top.is_empty() else {"id": "", "name": "Opponent", "strength": 60.0}
	opp["strength"] = clampf(float(opp.get("strength", 50)) + g.opponent_strength_bonus
		+ g.opponent_strength_per_round * i, 20.0, 95.0)
	var e := {"week": c.schedule.size() + 1, "type": "playoff", "postseason": kind, "round": i,
		"round_name": names[i], "final": final, "home": rng.randf() < g.home_chance,
		"opponent": opp, "result": null}
	c.schedule.append(e)
	c.flags["championship_game"] = final
	return e


## Career postseason totals (filled in on first use, so old saves work).
static func career(c: CareerData) -> Dictionary:
	var car := c.postseason_career
	for k in ["appearances", "bowls", "bowl_wins", "titles", "wins", "losses"]:
		car[k] = int(car.get(k, 0))
	if not (car.get("by_stage") is Dictionary):
		car["by_stage"] = {}
	if not (car.get("title_list") is Array):
		car["title_list"] = []
	return car


## The season's progression bonus from the postseason (recruiting for HS /
## JUCO, draft for college, retention for pro).
static func progress_bonus(c: CareerData) -> float:
	var g := config()
	var w := int(c.postseason.get("w", 0))
	var title := str(c.postseason.get("status", "")) == "champion"
	match c.stage:
		CareerData.STAGE_HIGH_SCHOOL, CareerData.STAGE_JUCO:
			return g.recruiting_per_win * w + (g.recruiting_title if title else 0.0)
		CareerData.STAGE_COLLEGE:
			return g.draft_per_win * w + (g.draft_title if title else 0.0)
		CareerData.STAGE_PRO:
			return g.retention_per_win * w + (g.retention_title if title else 0.0)
	return 0.0


## One line for the season summary / history ("" = nothing to say).
static func summary_text(ps: Dictionary) -> String:
	match str(ps.get("status", "")):
		"missed":
			return "Missed the postseason"
		"champion":
			var last: Array = ps.get("games", [])
			return "Won the %s" % (str(last.back().get("name", "title")) if not last.is_empty() else "title")
		"bowl_won":
			return "Won the %s" % str(ps.get("name", "bowl game"))
		"bowl_lost":
			return "Lost the %s" % str(ps.get("name", "bowl game"))
		"eliminated":
			var g: Array = ps.get("games", [])
			return "Lost in the %s" % (str(g.back().get("name", "postseason")) if not g.is_empty() else "postseason")
		"alive":
			return "In the postseason"
	return ""


static func _rec(r: Dictionary) -> String:
	var s := "%d-%d" % [int(r.get("w", 0)), int(r.get("l", 0))]
	return s + ("-%d" % int(r.get("t", 0)) if int(r.get("t", 0)) > 0 else "")

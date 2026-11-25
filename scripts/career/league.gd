class_name League
extends RefCounted
## The league around the player's team (numbers: LeagueConfig,
## res://tuning/league.tres). The teams are the team database's
## (TeamDatabase, data/teams) and nothing else.
##
## One league per stage (high school, junior college, college, pro), stored in
## CareerData.league and made new when the stage changes (or a college player
## moves to another level, FBS / FCS / D2). Every team has a conference and a
## division (high school and college: the conference is the division; pro:
## AFC / NFC and "AFC East") and a strength rating that drifts between
## seasons. Each season every team gets a full schedule (division, conference
## and outside games, byes). The player's games are the real ones (the kick
## scene / GameSim); every other game is simulated at the end of its week
## (after_week) from the two teams' strength plus randomness.
##
## Standings (wins, losses, ties, division / conference records, points,
## streaks) are worked out from the stored results whenever they're needed, so
## the save holds only the schedule and the scores. Ties in the standings go
## through break_tie() (head-to-head, division record, conference record,
## point differential). The postseason field and its seeds come from the
## standings (qualification()), and the playoff bracket's other games are
## simulated as the player's postseason goes on (bracket_opponent(), finish()).
##
## Save layout (team details come from the team database by id):
##   {v, stage, scope (college: "FBS" ...), seed, season,
##    ids: [team id per slot], str: [strength per slot], div: [division per slot],
##    divs: [[division name, conference index], ...], confs: [conference name, ...],
##    custom: {id: team} (a team the database doesn't have: an old save's),
##    weeks: [[home, away, home, away, ...] per week], scores: [[home pts, away pts, ...] or [] per week],
##    post: {season, ccg, field, bracket, bowls}}

const PATH := "res://tuning/league.tres"
const VERSION := 2

static var _cached: LeagueConfig


static func config() -> LeagueConfig:
	if _cached == null:
		var r: Variant = load(PATH) if ResourceLoader.exists(PATH) else null
		_cached = r if r is LeagueConfig else LeagueConfig.new()
	return _cached


## Tests / tools: use these numbers instead of the file (null = back to the file).
static func use_config(cfg: LeagueConfig) -> void:
	_cached = cfg


static func has_league(stage: String) -> bool:
	return not config().structure(stage).is_empty()


# --- the league -------------------------------------------------------------------------

## A new league for the career's stage from the team database (college: the
## player's level only). No schedule yet (prepare_season).
static func create(c: CareerData) -> Dictionary:
	var pid := str(c.team.get("id", ""))
	var seed := hash("%s|%s|%d|%s|%d" % [str(c.player.get("name", "")), c.stage, c.season, pid, c.created])
	var scope := _scope(c)
	var lg := {"v": VERSION, "stage": c.stage, "scope": scope, "seed": seed, "season": 0,
		"ids": [], "str": [], "div": [], "divs": [], "confs": [], "custom": {}, "weeks": [], "scores": [], "post": {}}
	var pool := _pool(c.stage, scope)
	var known := pool.any(func(s: Dictionary) -> bool: return str(s.get("id", "")) == pid)
	if not known and pid != "":
		# A team the database doesn't have (an old save): it joins the league.
		var own := _slim(c.team)
		lg["custom"][pid] = own
		pool.append(own)
	var conf_index := {}
	var div_index := {}
	for s in pool:
		var g := _groups(s, c.stage)
		if not conf_index.has(g[0]):
			conf_index[g[0]] = (lg["confs"] as Array).size()
			lg["confs"].append(g[0])
		var dkey := "%s|%s" % [g[0], g[1]]
		if not div_index.has(dkey):
			div_index[dkey] = (lg["divs"] as Array).size()
			lg["divs"].append([g[1], conf_index[g[0]]])
		lg["ids"].append(str(s.get("id", "")))
		lg["str"].append(snappedf(float(s.get("strength", 50.0)), 0.1))
		lg["div"].append(div_index[dkey])
	var p := index_of(lg, pid)
	if p >= 0:
		lg["str"][p] = snappedf(float(c.team.get("strength", lg["str"][p])), 0.1)
	return lg


## Start of a season (CareerManager._start_season): a league for this stage
## (new when the stage or college level changed), strengths drifted for a new
## season, the player's team in it, and a fresh schedule. False when the stage
## has no league.
static func prepare_season(c: CareerData, t: CareerTuning) -> bool:
	if not has_league(c.stage):
		return false
	var lg := c.league
	if not valid(lg, c.stage) or str(lg.get("scope", "")) != _scope(c):
		lg = create(c)
		c.league = lg
	elif int(lg["season"]) != c.season and int(lg["season"]) > 0:
		drift(lg, c.season)
	_ensure_player(c, lg)
	var p := player_index(c)
	lg["str"][p] = snappedf(float(c.team.get("strength", lg["str"][p])), 0.1)
	lg["season"] = c.season
	lg["post"] = {}
	_build_season(lg, t)
	return true


## The player's schedule (CareerData.schedule entries) from the league's.
static func player_schedule(c: CareerData) -> Array:
	var lg := c.league
	var p := player_index(c)
	var out: Array = []
	for w in (lg["weeks"] as Array).size():
		var g := _game_of(lg, w, p)
		if g.is_empty():
			out.append({"week": w + 1, "type": "bye", "result": null})
		else:
			var opp := int(g[1]) if int(g[0]) == p else int(g[0])
			out.append({"week": w + 1, "type": "regular", "home": int(g[0]) == p,
				"opponent": team(lg, opp), "result": null})
	return out


## A save without a league (made before leagues): make one for this stage and
## fit it around the schedule already being played (same opponents where
## they're in the league, same byes), with the weeks already finished simulated.
static func migrate(c: CareerData, t: CareerTuning) -> void:
	if not has_league(c.stage) or valid(c.league, c.stage):
		return
	var lg := create(c)
	c.league = lg
	lg["season"] = c.season
	_build_season(lg, t)
	var regular := c.schedule.filter(func(e: Dictionary) -> bool: return not Postseason.is_postseason(e))
	if regular.is_empty():
		return
	# Same number of weeks as the schedule being played.
	var weeks: Array = lg["weeks"]
	weeks.resize(regular.size())
	for w in weeks.size():
		if weeks[w] == null:
			weeks[w] = []
	var scores: Array = []
	for w in weeks.size():
		scores.append([])
	lg["scores"] = scores
	align_to_schedule(c)
	var done := c.week - 1 if c.phase in [CareerManager.PHASE_WEEK_START, CareerManager.PHASE_SCENARIO,
		CareerManager.PHASE_OUTLOOK, CareerManager.PHASE_GAME, CareerManager.PHASE_RESULTS] else weeks.size()
	for w in mini(done, weeks.size()):
		after_week(c, w + 1)


## True if `lg` is a usable league for `stage`.
static func valid(lg: Dictionary, stage: String) -> bool:
	if lg.is_empty() or str(lg.get("stage", "")) != stage or int(lg.get("v", 0)) != VERSION:
		return false
	var n := (lg.get("ids", []) as Array).size() if lg.get("ids") is Array else 0
	return n > 1 and lg.get("str") is Array and (lg["str"] as Array).size() == n \
		and lg.get("div") is Array and (lg["div"] as Array).size() == n \
		and lg.get("divs") is Array and lg.get("confs") is Array \
		and lg.get("weeks") is Array and lg.get("scores") is Array


## True when the league is this season's and has results: qualifying is by the
## standings. (Otherwise Postseason qualifies by the record, as before leagues.)
static func active(c: CareerData) -> bool:
	var lg := c.league
	if not valid(lg, c.stage) or int(lg["season"]) != c.season or player_index(c) < 0:
		return false
	for s in lg["scores"]:
		if not (s as Array).is_empty():
			return true
	return false


## Between seasons: every team drifts a little (random), and a little back
## toward the league average, so the league doesn't stay frozen.
static func drift(lg: Dictionary, season: int) -> void:
	var g := config()
	var rng := _rng(lg, "drift%d" % season)
	var strs: Array = lg["str"]
	var mean := 0.0
	for s in strs:
		mean += float(s)
	mean /= maxf(strs.size(), 1)
	for i in strs.size():
		var s := float(strs[i])
		s += rng.randf_range(-g.strength_drift, g.strength_drift) + (mean - s) * g.strength_regression
		strs[i] = snappedf(clampf(s, g.strength_min, g.strength_max), 0.1)


## The league for the save file: weeks and scores as base64 bytes (every
## team slot and score fits in a byte), which keeps a 160-team college league
## to about half the size. unpack() reverses it; anything else is kept as is.
static func pack(lg: Dictionary) -> Dictionary:
	if lg.is_empty() or size(lg) > 255:
		return lg.duplicate(true)
	var out := lg.duplicate(true)
	for k in ["weeks", "scores"]:
		var rows: Array = []
		for row in lg.get(k, []):
			var bytes := PackedByteArray()
			for v in row:
				bytes.append(clampi(int(v), 0, 255))
			rows.append(Marshalls.raw_to_base64(bytes))
		out[k] = rows
	out["packed"] = 1
	return out


static func unpack(d: Dictionary) -> Dictionary:
	if int(d.get("packed", 0)) != 1:
		return d
	var out := d.duplicate(true)
	out.erase("packed")
	for k in ["weeks", "scores"]:
		var rows: Array = []
		for row in d.get(k, []):
			var arr: Array = []
			for b in Marshalls.base64_to_raw(str(row)):
				arr.append(int(b))
			rows.append(arr)
		out[k] = rows
	return out


# --- teams and groups -------------------------------------------------------------------

static func size(lg: Dictionary) -> int:
	return (lg.get("ids", []) as Array).size()


static func index_of(lg: Dictionary, id: String) -> int:
	return (lg.get("ids", []) as Array).find(id)


static func player_index(c: CareerData) -> int:
	return index_of(c.league, str(c.team.get("id", "")))


## Division of a slot (an index into lg.divs).
static func div_of(lg: Dictionary, i: int) -> int:
	return int(lg["div"][i])


static func conf_of(lg: Dictionary, i: int) -> int:
	return int(lg["divs"][div_of(lg, i)][1])


static func division_count(lg: Dictionary) -> int:
	return (lg["divs"] as Array).size()


static func conference_count(lg: Dictionary) -> int:
	return (lg["confs"] as Array).size()


static func division_teams(lg: Dictionary, div: int) -> Array:
	var out: Array = []
	for i in size(lg):
		if int(lg["div"][i]) == div:
			out.append(i)
	return out


static func conference_teams(lg: Dictionary, conf: int) -> Array:
	var out: Array = []
	for i in size(lg):
		if conf_of(lg, i) == conf:
			out.append(i)
	return out


## The divisions of a conference, in order.
static func conference_divisions(lg: Dictionary, conf: int) -> Array:
	var out: Array = []
	for d in division_count(lg):
		if int(lg["divs"][d][1]) == conf:
			out.append(d)
	return out


## True when divisions are whole conferences (high school, college).
static func flat(lg: Dictionary) -> bool:
	for d in division_count(lg):
		if str(lg["divs"][d][0]) != str(lg["confs"][int(lg["divs"][d][1])]):
			return false
	return true


## A team as a schedule opponent (Progression.team_from) with its league strength.
static func team(lg: Dictionary, i: int) -> Dictionary:
	var info := _info(lg, str(lg["ids"][i]))
	var out := Progression.team_from(info, str(lg["stage"]))
	out["strength"] = float(lg["str"][i])
	return out


## "American Football Conference" / "AFC"; college: "Great Lakes Conference" /
## "Great Lakes".
static func conference_name(lg: Dictionary, conf: int, short := false) -> String:
	var name := str(lg["confs"][conf]) if conf >= 0 and conf < conference_count(lg) else "Conference %d" % (conf + 1)
	if str(lg["stage"]) == CareerData.STAGE_PRO:
		return name if short else str(TeamDatabase.division_info("pro", name).get("name", name))
	if short:
		for suffix in [" Conference", " League", " Collegiate", " Division", " Association"]:
			if name.ends_with(suffix) and name.length() > suffix.length() + 3:
				return name.trim_suffix(suffix)
	return name


static func division_name(lg: Dictionary, div: int) -> String:
	return str(lg["divs"][div][0]) if div >= 0 and div < division_count(lg) else "Division %d" % (div + 1)


## Which teams a career's league holds: "" (the whole stage) or the college
## level ("FBS", "FCS", "D2").
static func _scope(c: CareerData) -> String:
	if c.stage != CareerData.STAGE_COLLEGE:
		return ""
	var d := str(c.team.get("division", ""))
	if d == "":
		d = str(TeamDatabase.team(str(c.team.get("id", ""))).get("division", ""))
	return d if d != "" else "FBS"


static func _pool(stage: String, scope: String) -> Array:
	match stage:
		CareerData.STAGE_COLLEGE:
			var all: Array = TeamDatabase.colleges()
			var mine := all.filter(func(s: Dictionary) -> bool: return str(s.get("division", "")) == scope)
			return mine if mine.size() >= 2 else all
		CareerData.STAGE_JUCO:
			return TeamDatabase.jucos()
		CareerData.STAGE_PRO:
			return TeamDatabase.pro_teams()
	return TeamDatabase.high_schools()


## [conference, division] of a team record. Pro: the data's division is the
## conference (AFC) and its conference the division (AFC East).
static func _groups(s: Dictionary, stage: String) -> Array:
	var conf := str(s.get("conference", ""))
	if stage == CareerData.STAGE_PRO:
		var big := str(s.get("division", ""))
		return [big if big != "" else "League", conf if conf != "" else "Division"]
	if conf == "":
		conf = "Independents"
	return [conf, conf]


static func _info(lg: Dictionary, id: String) -> Dictionary:
	var custom: Dictionary = lg.get("custom", {})
	if custom.has(id):
		return custom[id]
	var t: Dictionary = TeamDatabase.team(id)
	if not t.is_empty():
		return t
	return {"id": id, "name": id.capitalize(), "town": id.capitalize(), "mascot": "", "short": id.left(3).to_upper()}


static func _slim(t: Dictionary) -> Dictionary:
	var out := {}
	for k in ["id", "name", "mascot", "short", "town", "colors", "strength", "tier", "division", "conference"]:
		if t.has(k):
			out[k] = t[k]
	return out


## The player's team isn't in the league (it joined from outside it): it
## joins, in the division whose name it carries (else the first).
static func _ensure_player(c: CareerData, lg: Dictionary) -> void:
	var pid := str(c.team.get("id", ""))
	if pid == "" or index_of(lg, pid) >= 0:
		return
	var info: Dictionary = TeamDatabase.team(pid)
	if info.is_empty():
		info = _slim(c.team)
		lg["custom"][pid] = info
	var g := _groups(info, c.stage)
	var div := 0
	for d in division_count(lg):
		if str(lg["divs"][d][0]) == str(g[1]):
			div = d
	lg["ids"].append(pid)
	lg["str"].append(snappedf(float(c.team.get("strength", 50.0)), 0.1))
	lg["div"].append(div)


# --- the schedule ----------------------------------------------------------------------

static func _build_season(lg: Dictionary, t: CareerTuning) -> void:
	var st := config().structure(str(lg["stage"]))
	var rng := _rng(lg, "schedule")
	var divs: Array = []
	var confs: Array = []
	for i in size(lg):
		divs.append(div_of(lg, i))
		confs.append(conf_of(lg, i))
	lg["weeks"] = generate_schedule(divs, confs, t.games_for(str(lg["stage"])), int(st.get("division_games", 0)),
		bool(st.get("rematches", false)), int(st.get("conference_games", 0)), t.byes_per_season,
		t.bye_week_earliest, t.bye_week_latest, rng)
	var scores: Array = []
	for w in (lg["weeks"] as Array).size():
		scores.append([])
	lg["scores"] = scores


## Every team's games, week by week: an Array (one per week) of flat
## [home, away, home, away, ...] team slots. divs / confs: each team's
## division and conference. Each team plays `games` games: div_games in its
## division (again, home and away swapped, only with rematches), conf_games
## against its conference's other divisions, the rest against anyone else it
## hasn't played. The season is games + byes weeks (a week more only if no
## schedule fits); teams sit in their bye weeks, mostly between earliest and
## latest. An odd team count, or a group too small for its games, leaves a
## team a game short (one more bye).
static func generate_schedule(divs: Array, confs: Array, games: int, div_games: int, rematches: bool,
		conf_games: int, byes: int, earliest: int, latest: int, rng: RandomNumberGenerator) -> Array:
	var n := divs.size()
	var div_size := {}
	for d in divs:
		div_size[d] = int(div_size.get(d, 0)) + 1
	var edges: Array = []
	var met := {}
	var deg: Array = []
	deg.resize(n)
	deg.fill(0)
	# 1. Division games.
	var need: Array = []
	for i in n:
		var others := int(div_size[divs[i]]) - 1
		need.append(mini(games, div_games if rematches else mini(div_games, others)) if others > 0 else 0)
	var same_div := func(a: int, b: int) -> bool: return divs[a] == divs[b]
	var div_meet := func(a: int, _b: int) -> int:
		if not rematches:
			return 1
		return maxi(ceili(float(div_games) / maxf(float(div_size[divs[a]]) - 1.0, 1.0)), 1)
	var once := func(_a: int, _b: int) -> int: return 1
	var thrice := func(_a: int, _b: int) -> int: return 3
	var same_conf := func(a: int, b: int) -> bool: return confs[a] == confs[b] and divs[a] != divs[b]
	var other_conf := func(a: int, b: int) -> bool: return confs[a] != confs[b]
	var anyone := func(_a: int, _b: int) -> bool: return true
	# Whole round robins first (pro: twice through the division), then the rest.
	var members := {}
	for i in n:
		if not members.has(divs[i]):
			members[divs[i]] = []
		members[divs[i]].append(i)
	for d in members:
		var team_list: Array = members[d]
		var others := team_list.size() - 1
		if others <= 0:
			continue
		var legs := mini(int(need[team_list[0]]) / others, 1 if not rematches else 99)
		for leg in legs:
			for x in team_list.size():
				for y in range(x + 1, team_list.size()):
					var a: int = team_list[x]
					var b: int = team_list[y]
					edges.append([a, b])
					var key := mini(a, b) * n + maxi(a, b)
					met[key] = int(met.get(key, 0)) + 1
					deg[a] = int(deg[a]) + 1
					deg[b] = int(deg[b]) + 1
		for i in team_list:
			need[i] = int(need[i]) - legs * others
	_phase(n, need, deg, edges, met, rng, same_div, div_meet)
	# 2. The conference's other divisions.
	need = []
	for i in n:
		need.append(mini(conf_games, games - int(deg[i])))
	_phase(n, need, deg, edges, met, rng, same_conf, once)
	# 3. Outside the conference, then anyone not met yet; then trade games
	# around so the last teams short of games get new opponents; then
	# anyone (rematches) as a last resort.
	for step in [[other_conf, once], [anyone, once]]:
		need = []
		for i in n:
			need.append(games - int(deg[i]))
		_phase(n, need, deg, edges, met, rng, step[0], step[1])
	_repair(n, games, deg, edges, met, divs)
	need = []
	for i in n:
		need.append(games - int(deg[i]))
	_phase(n, need, deg, edges, met, rng, anyone, thrice)
	# Weeks: games + byes, more only if nothing fits.
	var w_count := games + maxi(byes, 0)
	var maxdeg := 0
	for d in deg:
		maxdeg = maxi(maxdeg, int(d))
	w_count = maxi(w_count, maxdeg + (1 if n % 2 == 1 else 0))
	var weeks_of: PackedInt32Array
	for attempt in 4:
		weeks_of = _color(edges, n, w_count, earliest - 1, latest - 1, rng)
		if not weeks_of.is_empty() or edges.is_empty():
			break
		w_count += 1
		push_warning("League: no %d-week schedule found, trying %d weeks" % [w_count - 1, w_count])
	var weeks: Array = []
	for w in w_count:
		weeks.append([])
	for e in edges.size():
		weeks[weeks_of[e]].append_array([int(edges[e][0]), int(edges[e][1])])
	_balance_homes(weeks, n)
	return weeks


## One pairing phase: the team with the most games still to place plays the
## allowed team with the most still to place (Havel-Hakimi; random ties), up
## to max_meet games between two teams. A team nobody can take gives up the
## rest of this phase (later phases pick it up).
static func _phase(n: int, need: Array, deg: Array, edges: Array, met: Dictionary, rng: RandomNumberGenerator,
		allowed: Callable, max_meet: Callable) -> void:
	while true:
		var a := -1
		var start := rng.randi_range(0, n - 1)
		for k in n:
			var i := (start + k) % n
			if int(need[i]) > 0 and (a < 0 or int(need[i]) > int(need[a])):
				a = i
		if a < 0:
			return
		var b := -1
		var b_met := 0
		start = rng.randi_range(0, n - 1)
		for k in n:
			var j := (start + k) % n
			if j == a or int(need[j]) <= 0 or not allowed.call(a, j):
				continue
			var m := int(met.get(mini(a, j) * n + maxi(a, j), 0))
			if m >= int(max_meet.call(a, j)):
				continue
			if b < 0 or m < b_met or (m == b_met and int(need[j]) > int(need[b])):
				b = j
				b_met = m
		if b < 0:
			need[a] = 0
			continue
		edges.append([a, b])
		var key := mini(a, b) * n + maxi(a, b)
		met[key] = int(met.get(key, 0)) + 1
		need[a] = int(need[a]) - 1
		need[b] = int(need[b]) - 1
		deg[a] = int(deg[a]) + 1
		deg[b] = int(deg[b]) + 1


## Teams still short of games, whose possible opponents are all used up:
## break an existing non-division game c-d and pair a-c, b-d (or a-c, a-d) with teams
## they haven't met.
static func _repair(n: int, games: int, deg: Array, edges: Array, met: Dictionary, divs: Array) -> void:
	var key := func(x: int, y: int) -> int: return mini(x, y) * n + maxi(x, y)
	for guard in n * games:
		var short: Array = []
		for i in n:
			if int(deg[i]) < games:
				short.append(i)
		if short.is_empty():
			return
		var a: int = short[0]
		var b: int = short[1] if short.size() > 1 else a
		if a == b and games - int(deg[a]) < 2:
			return
		var done := false
		for k in edges.size():
			var c := int(edges[k][0])
			var d := int(edges[k][1])
			if c in [a, b] or d in [a, b] or divs[c] == divs[d]:
				continue  # (division games stay)
			for pair in [[c, d], [d, c]]:
				var x: int = pair[0]
				var y: int = pair[1]
				if met.has(key.call(a, x)) or met.has(key.call(b, y)):
					continue
				edges.remove_at(k)
				met[key.call(c, d)] = int(met[key.call(c, d)]) - 1
				if int(met[key.call(c, d)]) <= 0:
					met.erase(key.call(c, d))
				for pr in [[a, x], [b, y]]:
					edges.append(pr)
					met[key.call(pr[0], pr[1])] = int(met.get(key.call(pr[0], pr[1]), 0)) + 1
				deg[a] = int(deg[a]) + 1
				deg[b] = int(deg[b]) + 1
				done = true
				break
			if done:
				break
		if not done:
			return


## Puts every game in a week so no team plays twice in a week (min-conflicts
## search), preferring weeks lo..hi for the weeks a team sits out. Returns
## the week of each game, or empty if it found nothing.
static func _color(edges: Array, n: int, w_count: int, lo: int, hi: int, rng: RandomNumberGenerator) -> PackedInt32Array:
	var e_count := edges.size()
	var occ := PackedInt32Array()
	occ.resize(n * w_count)
	var at: Array = []  # n * w_count lists of game indexes
	for k in n * w_count:
		at.append([])
	var wk := PackedInt32Array()
	wk.resize(e_count)
	var cost := func(o: int, w: int) -> int:
		return maxi(o - 1, 0) * 20 + (1 if o == 0 and (w < lo or w > hi) else 0)
	var delta := func(e: int, w2: int) -> int:
		var w1 := wk[e]
		if w1 == w2:
			return 0
		var d := 0
		for x in edges[e]:
			var o1 := occ[int(x) * w_count + w1]
			var o2 := occ[int(x) * w_count + w2]
			d += cost.call(o1 - 1, w1) - cost.call(o1, w1) + cost.call(o2 + 1, w2) - cost.call(o2, w2)
		return d
	var place := func(e: int, w: int) -> void:
		for x in edges[e]:
			occ[int(x) * w_count + w] += 1
			(at[int(x) * w_count + w] as Array).append(e)
		wk[e] = w
	var lift := func(e: int) -> void:
		var w := wk[e]
		for x in edges[e]:
			occ[int(x) * w_count + w] -= 1
			(at[int(x) * w_count + w] as Array).erase(e)
	var clash := func(e: int) -> bool:
		var w := wk[e]
		return occ[int(edges[e][0]) * w_count + w] > 1 or occ[int(edges[e][1]) * w_count + w] > 1
	# Greedy start: each game in its cheapest week.
	var order: Array = range(e_count)
	Progression.shuffle(order, rng)
	for e in order:
		var best := -1
		var best_c := 0
		for w in w_count:
			var c := 0
			for x in edges[e]:
				var o := occ[int(x) * w_count + w]
				c += cost.call(o + 1, w) - cost.call(o, w)
			if best < 0 or c < best_c or (c == best_c and rng.randf() < 0.3):
				best = w
				best_c = c
		place.call(e, best)
	var bad := {}
	for e in e_count:
		if clash.call(e):
			bad[e] = true
	var it := 0
	var limit := 400 * maxi(e_count, 1)
	while not bad.is_empty() and it < limit:
		it += 1
		var keys := bad.keys()
		var e: int = keys[rng.randi_range(0, keys.size() - 1)]
		var w1 := wk[e]
		var target := -1
		if rng.randf() < 0.08:
			target = rng.randi_range(0, w_count - 1)
		else:
			var best_d := 0
			for w in w_count:
				if w == w1:
					continue
				var d: int = delta.call(e, w)
				if target < 0 or d < best_d or (d == best_d and rng.randf() < 0.4):
					target = w
					best_d = d
		if target == w1 or target < 0:
			continue
		lift.call(e)
		place.call(e, target)
		for x in edges[e]:
			for w in [w1, target]:
				for g in at[int(x) * w_count + w]:
					if clash.call(g):
						bad[g] = true
					else:
						bad.erase(g)
	if not bad.is_empty():
		return PackedInt32Array()
	# Byes into lo..hi: swap two weeks along the chain of games starting at a
	# team that sits outside the window (a Kempe chain: still one game a week).
	if lo <= hi and lo < w_count:
		for k in 60 * n:
			var x := rng.randi_range(0, n - 1)
			var a := -1
			for w in w_count:
				if occ[x * w_count + w] == 0 and (w < lo or w > hi):
					a = w
					break
			if a < 0:
				continue
			var b := rng.randi_range(lo, mini(hi, w_count - 1))
			if occ[x * w_count + b] == 0:
				continue
			var chain := _chain(edges, at, w_count, x, a, b)
			var touched := {}
			for e in chain:
				for t in edges[e]:
					touched[int(t)] = true
			var before := 0
			for t in touched:
				for w in [a, b]:
					before += cost.call(occ[int(t) * w_count + w], w)
			for e in chain:
				var w := wk[e]
				lift.call(e)
				place.call(e, b if w == a else a)
			var after := 0
			for t in touched:
				for w in [a, b]:
					after += cost.call(occ[int(t) * w_count + w], w)
			if after > before:
				for e in chain:
					var w := wk[e]
					lift.call(e)
					place.call(e, b if w == a else a)
	return wk


## The games in weeks a and b linked to team x (each team plays at most once
## a week, so it's a path): swapping their weeks keeps the schedule valid.
static func _chain(edges: Array, at: Array, w_count: int, x: int, a: int, b: int) -> Array:
	var out: Array = []
	var seen := {}
	var team := x
	var w := b
	while true:
		var games: Array = at[team * w_count + w]
		if games.is_empty():
			break
		var e: int = games[0]
		if seen.has(e):
			break
		seen[e] = true
		out.append(e)
		team = int(edges[e][1]) if int(edges[e][0]) == team else int(edges[e][0])
		w = a if w == b else b
	return out


## Home and away: a rematch swaps the host; otherwise the team with fewer
## home games so far hosts.
static func _balance_homes(weeks: Array, count: int) -> void:
	var homes: Array = []
	homes.resize(count)
	homes.fill(0)
	var hosted := {}
	for pairs in weeks:
		for q in range(0, (pairs as Array).size(), 2):
			var a := int(pairs[q])
			var b := int(pairs[q + 1])
			var key := mini(a, b) * count + maxi(a, b)
			var host := a
			if hosted.has(key):
				host = b if int(hosted[key]) == a else a
			elif int(homes[b]) < int(homes[a]):
				host = b
			hosted[key] = host
			pairs[q] = host
			pairs[q + 1] = b if host == a else a
			homes[host] = int(homes[host]) + 1
	# Then swap single meetings where the host has 2+ more home games.
	var meetings := {}
	for pairs in weeks:
		for q in range(0, (pairs as Array).size(), 2):
			var key := mini(int(pairs[q]), int(pairs[q + 1])) * count + maxi(int(pairs[q]), int(pairs[q + 1]))
			meetings[key] = int(meetings.get(key, 0)) + 1
	for pass_i in 4:
		for pairs in weeks:
			for q in range(0, (pairs as Array).size(), 2):
				var h := int(pairs[q])
				var v := int(pairs[q + 1])
				var key := mini(h, v) * count + maxi(h, v)
				if int(meetings[key]) == 1 and int(homes[h]) - int(homes[v]) >= 2:
					pairs[q] = v
					pairs[q + 1] = h
					homes[h] = int(homes[h]) - 1
					homes[v] = int(homes[v]) + 1


static func _game_of(lg: Dictionary, w: int, i: int) -> Array:
	var pairs: Array = lg["weeks"][w]
	for q in range(0, pairs.size(), 2):
		if int(pairs[q]) == i or int(pairs[q + 1]) == i:
			return [int(pairs[q]), int(pairs[q + 1]), q / 2]
	return []


## A team's season, week by week: [{week, opp (-1 = bye), home, us, them
## (-1 = not played)}].
static func team_schedule(lg: Dictionary, i: int) -> Array:
	var out: Array = []
	for w in (lg["weeks"] as Array).size():
		var g := _game_of(lg, w, i)
		if g.is_empty():
			out.append({"week": w + 1, "opp": -1, "home": false, "us": -1, "them": -1})
			continue
		var home := int(g[0]) == i
		var sc: Array = lg["scores"][w] if w < (lg["scores"] as Array).size() else []
		var us := -1
		var them := -1
		if not sc.is_empty():
			us = int(sc[int(g[2]) * 2 + (0 if home else 1)])
			them = int(sc[int(g[2]) * 2 + (1 if home else 0)])
		out.append({"week": w + 1, "opp": int(g[1]) if home else int(g[0]), "home": home, "us": us, "them": them})
	return out


## Makes the league's schedule match the player's (CareerData.schedule): same
## opponent, home / away and byes in every regular week. Used for the rival
## (Relationships.schedule_tyler) and for old saves. Other teams' games are
## swapped around to keep everyone at one game a week.
static func align_to_schedule(c: CareerData) -> void:
	var lg := c.league
	var p := player_index(c)
	if p < 0:
		return
	for e in c.schedule:
		if Postseason.is_postseason(e):
			continue
		var w := int(e.get("week", 0)) - 1
		if w < 0 or w >= (lg["weeks"] as Array).size():
			continue
		var want := -1
		if str(e.get("type", "")) == "regular":
			want = index_of(lg, str(e.get("opponent", {}).get("id", "")))
			if want < 0 or want == p:
				continue  # an opponent outside the league: keep the league's
		_force(lg, w, p, want, bool(e.get("home", true)))
		if want >= 0:
			e["opponent"] = team(lg, want)


static func _force(lg: Dictionary, w: int, p: int, q: int, home: bool) -> void:
	var pairs: Array = lg["weeks"][w]
	var partner := func(i: int) -> int:
		for k in range(0, pairs.size(), 2):
			if int(pairs[k]) == i:
				return int(pairs[k + 1])
			if int(pairs[k + 1]) == i:
				return int(pairs[k])
		return -1
	var drop := func(i: int) -> void:
		for k in range(0, pairs.size(), 2):
			if int(pairs[k]) == i or int(pairs[k + 1]) == i:
				pairs.remove_at(k)
				pairs.remove_at(k)
				return
	var cur: int = partner.call(p)
	var loose: Array = []
	if cur >= 0:
		drop.call(p)
		loose.append(cur)
	if q >= 0:
		var qp: int = partner.call(q)
		if qp >= 0:
			drop.call(q)
			if qp != p:
				loose.append(qp)
		loose.erase(q)
		pairs.append_array([p, q] if home else [q, p])
	# Teams left without a game this week play each other (or a team off).
	var idle: Array = []
	for i in size(lg):
		if i != p and i != q and partner.call(i) < 0 and not (i in loose):
			idle.append(i)
	while not loose.is_empty():
		var a: int = loose.pop_front()
		var b := -1
		if not loose.is_empty():
			b = loose.pop_front()
		elif not idle.is_empty():
			b = idle.pop_front()
		if b >= 0:
			pairs.append_array([a, b])


# --- results ----------------------------------------------------------------------------

## End of a regular-season week (CareerManager.end_week): the player's game
## goes in with its real score, every other game is simulated.
static func after_week(c: CareerData, week: int) -> void:
	var lg := c.league
	if not valid(lg, c.stage) or int(lg["season"]) != c.season:
		return
	var w := week - 1
	if w < 0 or w >= (lg["weeks"] as Array).size() or not (lg["scores"][w] as Array).is_empty():
		return
	var p := player_index(c)
	var mine: Variant = null
	for e in c.schedule:
		if int(e.get("week", 0)) == week and not Postseason.is_postseason(e):
			mine = e.get("result")
	var tie_ok := tie_allowed(str(lg["stage"]))
	var rng := _rng(lg, "week%d" % week)
	var pairs: Array = lg["weeks"][w]
	var sc: Array = []
	for q in range(0, pairs.size(), 2):
		var h := int(pairs[q])
		var a := int(pairs[q + 1])
		if (h == p or a == p) and mine is Dictionary:
			var us := int(mine.get("us", 0))
			var them := int(mine.get("them", 0))
			sc.append_array([us, them] if h == p else [them, us])
		else:
			sc.append_array(sim_score(float(lg["str"][h]), float(lg["str"][a]), true, rng, tie_ok))
	lg["scores"][w] = sc


## Can a regular-season game end tied at this stage (its overtime rule)?
static func tie_allowed(stage: String) -> bool:
	return not (stage in [CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO])


## A simulated final score [home, away] from the two strengths.
static func sim_score(home_str: float, away_str: float, home_field: bool, rng: RandomNumberGenerator,
		tie_ok: bool) -> Array:
	var g := config()
	var diff := home_str - away_str + (g.sim_home_edge if home_field else 0.0)
	var a := _points(g.sim_mean_points + diff * g.sim_points_per_strength + rng.randfn(0.0, g.sim_points_sd))
	var b := _points(g.sim_mean_points - diff * g.sim_points_per_strength + rng.randfn(0.0, g.sim_points_sd))
	if a == b and not (tie_ok and rng.randf() < g.sim_tie_keep):
		# Overtime: the stronger side wins it more often.
		var p_home := 1.0 / (1.0 + exp(-diff / 10.0))
		if rng.randf() < p_home:
			a += 3
		else:
			b += 3
	return [a, b]


static func _points(x: float) -> int:
	var v := maxi(roundi(x), 0)
	return 0 if v == 1 else v  # nobody scores exactly 1


# --- standings --------------------------------------------------------------------------

## Every team's regular-season line: [{w, l, t, dw, dl, dt, cw, cl, ct, pf,
## pa, streak ("W3"), games [[opp, pf, pa], ...]}], by slot.
static func standings(lg: Dictionary) -> Array:
	var out: Array = []
	for i in size(lg):
		out.append({"w": 0, "l": 0, "t": 0, "dw": 0, "dl": 0, "dt": 0, "cw": 0, "cl": 0, "ct": 0,
			"pf": 0, "pa": 0, "streak": "", "games": [], "_res": []})
	for w in (lg["weeks"] as Array).size():
		var sc: Array = lg["scores"][w] if w < (lg["scores"] as Array).size() else []
		if sc.is_empty():
			continue
		var pairs: Array = lg["weeks"][w]
		for q in range(0, pairs.size(), 2):
			var h := int(pairs[q])
			var a := int(pairs[q + 1])
			_add_game(lg, out, h, a, int(sc[q]), int(sc[q + 1]))
			_add_game(lg, out, a, h, int(sc[q + 1]), int(sc[q]))
	for r in out:
		var res: Array = r["_res"]
		if not res.is_empty():
			var last: String = res.back()
			var n := 0
			for i in range(res.size() - 1, -1, -1):
				if res[i] != last:
					break
				n += 1
			r["streak"] = "%s%d" % [last, n]
		r.erase("_res")
	return out


static func _add_game(lg: Dictionary, st: Array, i: int, opp: int, pf: int, pa: int) -> void:
	var r: Dictionary = st[i]
	var k := "w" if pf > pa else ("l" if pf < pa else "t")
	r[k] = int(r[k]) + 1
	if div_of(lg, i) == div_of(lg, opp):
		r["d" + k] = int(r["d" + k]) + 1
	if conf_of(lg, i) == conf_of(lg, opp):
		r["c" + k] = int(r["c" + k]) + 1
	r["pf"] = int(r["pf"]) + pf
	r["pa"] = int(r["pa"]) + pa
	r["games"].append([opp, pf, pa])
	r["_res"].append(k.to_upper())


## Win share (W + T/2) / games; 0 with no games. prefix "d" / "c" for the
## division / conference record.
static func pct(r: Dictionary, prefix := "") -> float:
	var w := int(r.get(prefix + "w", 0))
	var l := int(r.get(prefix + "l", 0))
	var t := int(r.get(prefix + "t", 0))
	return 0.0 if w + l + t == 0 else (w + 0.5 * t) / float(w + l + t)


static func record_text(r: Dictionary, prefix := "") -> String:
	var s := "%d-%d" % [int(r.get(prefix + "w", 0)), int(r.get(prefix + "l", 0))]
	return s + ("-%d" % int(r.get(prefix + "t", 0)) if int(r.get(prefix + "t", 0)) > 0 else "")


## Teams in order: best win share first, ties broken by break_tie().
static func rank(lg: Dictionary, st: Array, teams: Array) -> Array:
	var sorted := teams.duplicate()
	sorted.sort_custom(func(a: int, b: int) -> bool: return pct(st[a]) > pct(st[b]))
	var out: Array = []
	var i := 0
	while i < sorted.size():
		var group: Array = [sorted[i]]
		var j := i + 1
		while j < sorted.size() and is_equal_approx(pct(st[sorted[j]]), pct(st[sorted[i]])):
			group.append(sorted[j])
			j += 1
		out.append_array(break_tie(lg, st, group))
		i = j
	return out


## THE tiebreaker: orders teams with the same win share. In order:
##   1. head-to-head: win share in games between the tied teams (only if every
##      tied team played at least one of the others)
##   2. division record (only if all the tied teams are in one division)
##   3. conference record (only if all are in one conference)
##   4. point differential
##   5. a coin flip (fixed per league and season, so it never changes)
## As soon as a step splits the group, each smaller group starts again from
## step 1 (so a three-way tie that drops one team becomes a two-team tie).
static func break_tie(lg: Dictionary, st: Array, tied: Array) -> Array:
	if tied.size() <= 1:
		return tied.duplicate()
	var same_div := tied.all(func(i: int) -> bool: return div_of(lg, i) == div_of(lg, tied[0]))
	var same_conf := tied.all(func(i: int) -> bool: return conf_of(lg, i) == conf_of(lg, tied[0]))
	var steps: Array = [func(i: int) -> Variant: return _h2h(st, tied, i)]
	if same_div:
		steps.append(func(i: int) -> Variant: return pct(st[i], "d"))
	if same_conf:
		steps.append(func(i: int) -> Variant: return pct(st[i], "c"))
	steps.append(func(i: int) -> Variant: return float(int(st[i]["pf"]) - int(st[i]["pa"])))
	for step in steps:
		var vals := {}
		var usable := true
		for i in tied:
			var v: Variant = step.call(i)
			if v == null:
				usable = false
				break
			vals[i] = float(v)
		if not usable:
			continue
		var order := tied.duplicate()
		order.sort_custom(func(a: int, b: int) -> bool: return vals[a] > vals[b])
		var groups: Array = []
		for i in order:
			if groups.is_empty() or not is_equal_approx(float(vals[groups.back()[0]]), float(vals[i])):
				groups.append([i])
			else:
				groups.back().append(i)
		if groups.size() > 1:
			var out: Array = []
			for g in groups:
				out.append_array(break_tie(lg, st, g))
			return out
	var coin := tied.duplicate()
	var salt := int(lg.get("seed", 0)) + int(lg.get("season", 0))
	coin.sort_custom(func(a: int, b: int) -> bool: return hash([salt, a]) < hash([salt, b]))
	return coin


## Head-to-head win share among `group` (null if some team played none of the others).
static func _h2h(st: Array, group: Array, i: int) -> Variant:
	var w := 0.0
	var g := 0
	for x in st[i]["games"]:
		if int(x[0]) in group and int(x[0]) != i:
			g += 1
			w += 1.0 if int(x[1]) > int(x[2]) else (0.5 if int(x[1]) == int(x[2]) else 0.0)
	for j in group:
		if j == i:
			continue
		var met := false
		for x in st[j]["games"]:
			if int(x[0]) in group and int(x[0]) != j:
				met = true
				break
		if not met:
			return null
	return null if g == 0 else w / g


## One division in order.
static func division_order(lg: Dictionary, st: Array, div: int) -> Array:
	return rank(lg, st, division_teams(lg, div))


# --- seeding and qualifying -------------------------------------------------------------

## The postseason field from the standings: {sides: [[slot, ...] in seed order],
## bowls: [slot, ...] (college), out: [[slot, ...] best-first, per side],
## champions: {conf: slot} (college)}.
## champions: college conference champions already decided (else projected).
static func field(lg: Dictionary, st: Array, champions := {}) -> Dictionary:
	var s := config().structure(str(lg["stage"]))
	if str(lg["stage"]) == CareerData.STAGE_COLLEGE:
		return _college_field(lg, st, s, champions)
	var groups: Array = []
	if bool(s.get("by_conference", true)) and conference_count(lg) > 1:
		for c in conference_count(lg):
			groups.append(conference_divisions(lg, c))
	else:
		groups.append(range(division_count(lg)))
	var sides: Array = []
	var outs: Array = []
	var q := int(s.get("qualifiers_per_division", 1))
	var wc := int(s.get("wildcards", 0))
	for divs in groups:
		var places: Array = []  # places[k] = teams that finished k+1 in their division
		var rest: Array = []
		for k in q:
			places.append([])
		for div in divs:
			var order := division_order(lg, st, div)
			for k in order.size():
				if k < q:
					places[k].append(order[k])
				else:
					rest.append(order[k])
		var side: Array = []
		for p in places:
			side.append_array(rank(lg, st, p))
		var others := rank(lg, st, rest)
		side.append_array(others.slice(0, wc))
		sides.append(side)
		outs.append(others.slice(wc))
	return {"sides": sides, "out": outs, "bowls": [], "champions": {}}


## College conference champions: the title game winners where there was one
## (`champions`), else the conference's best team; independents have none.
static func _college_champions(lg: Dictionary, st: Array, s: Dictionary, champions: Dictionary) -> Dictionary:
	var champs := {}
	for c in conference_count(lg):
		if champions.has(c):
			champs[c] = int(champions[c])
		elif not _independent(lg, c, s):
			champs[c] = rank(lg, st, conference_teams(lg, c))[0]
	return champs


static func _independent(lg: Dictionary, conf: int, s: Dictionary) -> bool:
	var suffix := str(s.get("independent", ""))
	return suffix != "" and str(lg["confs"][conf]).ends_with(suffix)


static func _college_field(lg: Dictionary, st: Array, s: Dictionary, champions: Dictionary) -> Dictionary:
	var champs := _college_champions(lg, st, s, champions)
	var poll := poll_order(lg, st, champs.values())
	var auto := poll.filter(func(i: int) -> bool: return i in champs.values()).slice(0, int(s.get("auto_bids", 0)))
	var size_f := mini(int(s.get("field", 12)), poll.size())
	var field_teams: Array = auto.duplicate()
	for i in poll:
		if field_teams.size() >= size_f:
			break
		if not (i in field_teams):
			field_teams.append(i)
	var seeded := poll.filter(func(i: int) -> bool: return i in field_teams)
	var rest := poll.filter(func(i: int) -> bool: return not (i in field_teams))
	var bowls: Array = []
	for i in rest:
		if bowls.size() >= int(s.get("bowl_slots", 0)):
			break
		if pct(st[i]) >= float(s.get("bowl_min", 0.5)) - 0.0001:
			bowls.append(i)
	if bowls.size() % 2 == 1:
		bowls.pop_back()
	var out := rest.filter(func(i: int) -> bool: return not (i in bowls))
	return {"sides": [seeded], "out": [out], "bowls": bowls, "champions": champs}


## College ranking: win share x 100, plus schedule strength, plus a bonus for
## conference champions; ties by break_tie().
static func poll_order(lg: Dictionary, st: Array, champs: Array) -> Array:
	var g := config()
	var score := {}
	for i in size(lg):
		var r: Dictionary = st[i]
		var sos := 50.0
		if not (r["games"] as Array).is_empty():
			sos = 0.0
			for x in r["games"]:
				sos += float(lg["str"][int(x[0])])
			sos /= (r["games"] as Array).size()
		score[i] = snappedf(pct(r) * 100.0 + (sos - 50.0) * g.college_poll_schedule_weight
			+ (g.college_poll_champion_bonus if i in champs else 0.0), 0.01)
	var all: Array = range(size(lg))
	all.sort_custom(func(a: int, b: int) -> bool: return score[a] > score[b])
	var out: Array = []
	var i := 0
	while i < all.size():
		var group: Array = [all[i]]
		var j := i + 1
		while j < all.size() and is_equal_approx(float(score[all[j]]), float(score[all[i]])):
			group.append(all[j])
			j += 1
		out.append_array(break_tie(lg, st, group))
		i = j
	return out


## Qualifying for the player, from this season's standings (Postseason._start):
##   {} - no league decision (no league or no results): use the record
##   {kind: "conference", opponent, home, name, conference} - the player's
##        conference title game comes first (college)
##   {kind: "playoff", seed, start_round, bye, side, division_champion, ...}
##   {kind: "bowl", opponent, ...}
##   {kind: "", place, reason} - season over
## Also sets lg.post (the field, bracket, conference title games) once.
static func qualification(c: CareerData) -> Dictionary:
	if not active(c):
		return {}
	var lg := c.league
	var st := standings(lg)
	var p := player_index(c)
	var s := config().structure(c.stage)
	var post := _post(lg)
	var div_champ: bool = division_order(lg, st, div_of(lg, p))[0] == p
	var base := {"division_champion": div_champ, "conference_champion": false}
	var champions := {}
	if c.stage == CareerData.STAGE_COLLEGE and bool(s.get("title_game", false)):
		if not post.has("ccg"):
			post["ccg"] = _title_pairs(lg, st)
		for g in post["ccg"]:
			if (p == int(g[1]) or p == int(g[2])) and (g as Array).size() < 5:
				var res := _player_result(c, "conference", 0)
				if res.is_empty():
					var opp := int(g[2]) if p == int(g[1]) else int(g[1])
					return base.merged({"kind": "conference", "opponent": team(lg, opp), "opponent_index": opp,
						"home": p == int(g[1]), "conference": int(g[0]),
						"name": "%s Championship" % conference_name(lg, int(g[0]))})
				var won := str(res.get("outcome", "L")) == "W"
				var us := int(res.get("us", 0))
				var them := int(res.get("them", 0))
				g.append_array([us, them] if p == int(g[1]) else [them, us])
				if not won and us >= them:
					g[3 if p == int(g[1]) else 4] = mini(us, them) - 1  # a loss stays a loss
		for g in post["ccg"]:
			if (g as Array).size() < 5:
				g.append_array(sim_score(float(lg["str"][int(g[1])]), float(lg["str"][int(g[2])]), false,
					_rng(lg, "ccg%d" % int(g[0])), false))
			champions[int(g[0])] = int(g[1]) if int(g[3]) > int(g[4]) else int(g[2])
		base["conference_champion"] = champions.values().has(p)
	if not post.has("field"):
		var f := field(lg, st, champions)
		post["field"] = f["sides"]
		post["bowls"] = f["bowls"]
		post["bracket"] = make_bracket(f["sides"])
	var sides: Array = post["field"]
	for k in sides.size():
		var seed := (sides[k] as Array).find(p)
		if seed >= 0:
			var r0 := _first_round(c, lg, p)
			return base.merged({"kind": "playoff", "seed": seed + 1, "side": k, "start_round": _offset(c) + r0,
				"bye": r0 > 0, "field": _field_size(post)})
	var bowls: Array = post.get("bowls", [])
	var bi := bowls.find(p)
	if bi >= 0:
		var opp: int = bowls[bi + 1] if bi % 2 == 0 else bowls[bi - 1]
		return base.merged({"kind": "bowl", "opponent": team(lg, opp), "opponent_index": opp})
	return base.merged({"kind": "", "reason": miss_reason(c)})


## "3rd in the Ridge District" / "2 spots out" for a season that ended without a postseason.
static func miss_reason(c: CareerData) -> String:
	var lg := c.league
	var st := standings(lg)
	var p := player_index(c)
	var order := division_order(lg, st, div_of(lg, p))
	var place := order.find(p) + 1
	return "%s in the %s" % [ordinal(place), division_name(lg, div_of(lg, p))]


static func ordinal(n: int) -> String:
	var suf := "th"
	if n % 100 < 11 or n % 100 > 13:
		suf = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return "%d%s" % [n, suf]


## College conference title games: [[conf, home (better), away], ...] for
## each conference with at least title_min teams (not independents): its top
## two (results appended as [.., home pts, away pts] once played).
static func _title_pairs(lg: Dictionary, st: Array) -> Array:
	var s := config().structure(str(lg["stage"]))
	var out: Array = []
	for c in conference_count(lg):
		var teams := conference_teams(lg, c)
		if teams.size() < int(s.get("title_min", 6)) or _independent(lg, c, s):
			continue
		var top := rank(lg, st, teams)
		out.append([c, top[0], top[1]])
	return out


static func _post(lg: Dictionary) -> Dictionary:
	var post: Dictionary = lg.get("post", {}) if lg.get("post") is Dictionary else {}
	if int(post.get("season", -1)) != int(lg["season"]):
		post = {"season": int(lg["season"])}
	lg["post"] = post
	return post


## The player's result in a postseason week of this kind / round ({} = not played).
static func _player_result(c: CareerData, kind: String, round_i: int) -> Dictionary:
	for e in c.schedule:
		if Postseason.is_postseason(e) and str(e.get("postseason", "")) == kind \
				and (kind == "conference" or int(e.get("round", -1)) == round_i) and e.get("result") is Dictionary:
			return e["result"]
	return {}


# --- the bracket ------------------------------------------------------------------------

## A single-elimination bracket from seeded sides: each side is a block of
## P slots (P = the next power of two) in standard seed order (1 v P, ...);
## empty slots are byes (-1). Sides meet in the last rounds.
## {slots: [...], w: [[winners of round 0], ...], sc: [[scores of round 0], ...]}.
static func make_bracket(sides: Array) -> Dictionary:
	var biggest := 1
	for sd in sides:
		biggest = maxi(biggest, (sd as Array).size())
	var p := _pow2(biggest)
	var k := _pow2(maxi(sides.size(), 1))
	var order := seed_order(p)
	var slots: Array = []
	for s in k:
		var side: Array = sides[s] if s < sides.size() else []
		for seed in order:
			slots.append(side[seed - 1] if seed - 1 < side.size() else -1)
	return {"slots": slots, "w": [], "sc": []}


## Standard bracket order for p seeds: 4 -> [1, 4, 2, 3], 8 -> [1, 8, 4, 5, 2, 7, 3, 6].
static func seed_order(p: int) -> Array:
	var order: Array = [1]
	var n := 1
	while n < p:
		n *= 2
		var nxt: Array = []
		for s in order:
			nxt.append_array([s, n + 1 - s])
		order = nxt
	return order


static func _pow2(x: int) -> int:
	var p := 1
	while p < x:
		p *= 2
	return p


static func bracket_rounds(br: Dictionary) -> int:
	var n := (br.get("slots", []) as Array).size()
	var r := 0
	while n > 1:
		n /= 2
		r += 1
	return r


## Postseason round names index of bracket round 0 (bracket rounds line up
## with the last PostseasonConfig round names; more rounds than names get
## numbered names at the front, see round_names()).
static func _offset(c: CareerData) -> int:
	var br: Dictionary = _post(c.league).get("bracket", {})
	return maxi(Postseason.rounds(c, "playoff").size() - bracket_rounds(br), 0)


## The round names for this season's playoff (Postseason's, padded at the front
## with "Playoffs: Round N" if the bracket has more rounds than names).
static func round_names(c: CareerData) -> PackedStringArray:
	var names := Postseason.rounds(c, "playoff")
	if not active(c):
		return names
	var br: Dictionary = _post(c.league).get("bracket", {})
	var extra := bracket_rounds(br) - names.size()
	if br.is_empty() or extra <= 0:
		return names
	var out := PackedStringArray()
	for i in extra:
		out.append("Playoffs: Round %d" % (i + 1))
	out.append_array(names)
	return out


## Seed (1-based) of a slot in this season's field, 0 if not in it.
static func seed_of(lg: Dictionary, i: int) -> int:
	for side in _post(lg).get("field", []):
		var k := (side as Array).find(i)
		if k >= 0:
			return k + 1
	return 0


## The first bracket round the player actually plays (after byes).
static func _first_round(c: CareerData, lg: Dictionary, p: int) -> int:
	var br: Dictionary = _post(lg)["bracket"]
	for r in bracket_rounds(br):
		_resolve(c, lg, r)
		var slots: Array = br["slots"] if r == 0 else br["w"][r - 1]
		var k := slots.find(p)
		if k < 0:
			return r
		if int(slots[k ^ 1]) >= 0:
			return r
	return 0


## The player's opponent for postseason round `names_i` (names index), as a
## schedule opponent with {seed} added; {} when there's no bracket (old saves,
## bowls) so Postseason picks one as before.
static func bracket_opponent(c: CareerData, names_i: int) -> Dictionary:
	if not active(c):
		return {}
	var lg := c.league
	var br: Dictionary = _post(lg).get("bracket", {})
	if br.is_empty():
		return {}
	var r := names_i - _offset(c)
	if r < 0 or r >= bracket_rounds(br) or not _resolve(c, lg, r):
		return {}
	var slots: Array = br["slots"] if r == 0 else br["w"][r - 1]
	var p := player_index(c)
	var k := slots.find(p)
	if k < 0 or int(slots[k ^ 1]) < 0:
		return {}
	var opp := int(slots[k ^ 1])
	var t := team(lg, opp)
	t["seed"] = seed_of(lg, opp)
	t["my_seed"] = seed_of(lg, p)
	return t


## Plays the bracket up to (not including) round `upto`: other games are
## simulated, the player's come from their postseason weeks. False if a
## player's game in those rounds hasn't been played yet.
static func _resolve(c: CareerData, lg: Dictionary, upto: int) -> bool:
	var br: Dictionary = _post(lg).get("bracket", {})
	if br.is_empty():
		return false
	var p := player_index(c)
	while (br["w"] as Array).size() < upto:
		var r := (br["w"] as Array).size()
		var slots: Array = br["slots"] if r == 0 else br["w"][r - 1]
		var winners: Array = []
		var scores: Array = []
		for k in range(0, slots.size(), 2):
			var a := int(slots[k])
			var b := int(slots[k + 1])
			if a < 0 or b < 0:
				winners.append(maxi(a, b))
				scores.append_array([0, 0])
				continue
			if a == p or b == p:
				var res := _player_result(c, "playoff", _offset(c) + r)
				if res.is_empty():
					return false
				var us := int(res.get("us", 0))
				var them := int(res.get("them", 0))
				var won := str(res.get("outcome", "L")) == "W"
				winners.append(p if won else (b if a == p else a))
				scores.append_array([us, them] if a == p else [them, us])
				continue
			var sc := sim_score(float(lg["str"][a]), float(lg["str"][b]), true, _rng(lg, "br%d_%d" % [r, k]), false)
			winners.append(a if int(sc[0]) > int(sc[1]) else b)
			scores.append_array(sc)
		br["w"].append(winners)
		br["sc"].append(scores)
	return true


## The postseason is over for the player (or they missed it): play out the
## rest of the bracket so the champion is known. Returns the champion's slot (-1 if none).
static func finish(c: CareerData) -> int:
	if not active(c):
		return -1
	var lg := c.league
	var br: Dictionary = _post(lg).get("bracket", {})
	if br.is_empty():
		qualification(c)
		br = _post(lg).get("bracket", {})
		if br.is_empty():
			return -1
	# The player's unplayed rounds (eliminated earlier) no longer include them.
	_resolve(c, lg, bracket_rounds(br))
	var w: Array = br["w"]
	return int(w.back()[0]) if not w.is_empty() and not (w.back() as Array).is_empty() else -1


## Field size of this season's playoff.
static func _field_size(post: Dictionary) -> int:
	var n := 0
	for s in post.get("field", []):
		n += (s as Array).size()
	return n


# --- the playoff picture ----------------------------------------------------------------

## Who's in and who's out right now: {show, final, sides: [{name, in: [slot],
## out: [slot]}], bowls: [slot], player: {in, seed, bowl}}. Projected from
## the current standings (college conference champions projected too) until
## the field is set.
static func picture(c: CareerData) -> Dictionary:
	var lg := c.league
	if not valid(lg, c.stage) or int(lg["season"]) != c.season:
		return {"show": false}
	var g := config()
	var played := 0
	for sc in lg["scores"]:
		if not (sc as Array).is_empty():
			played += 1
	var regular := (lg["weeks"] as Array).size()
	var post := _post(lg)
	var final := post.has("field")
	var show := final or played >= mini(g.playoff_picture_from_week, regular)
	var st := standings(lg)
	var f: Dictionary
	if final:
		f = {"sides": post["field"], "bowls": post.get("bowls", []), "out": []}
		var inside := {}
		for sd in post["field"]:
			for i in sd:
				inside[i] = true
		for b in post.get("bowls", []):
			inside[b] = true
		var outs: Array = []
		for sd in field(lg, st, _champions(post))["out"]:
			outs.append((sd as Array).filter(func(i: int) -> bool: return not inside.has(i)))
		f["out"] = outs
	else:
		f = field(lg, st)
	var sides: Array = []
	var s := config().structure(c.stage)
	for k in (f["sides"] as Array).size():
		var name := "Playoff field"
		if bool(s.get("by_conference", false)) and c.stage != CareerData.STAGE_COLLEGE and conference_count(lg) > 1:
			name = conference_name(lg, k)
		var outs: Array = f["out"][k] if k < (f["out"] as Array).size() else []
		sides.append({"name": name, "in": f["sides"][k], "out": outs.slice(0, g.playoff_picture_bubble)})
	var p := player_index(c)
	var me := {"in": false, "seed": 0, "bowl": (f["bowls"] as Array).has(p)}
	for sd in f["sides"]:
		var k := (sd as Array).find(p)
		if k >= 0:
			me = {"in": true, "seed": k + 1, "bowl": false}
	return {"show": show, "final": final, "played": played, "regular": regular, "sides": sides,
		"bowls": f["bowls"], "player": me}


static func _champions(post: Dictionary) -> Dictionary:
	var out := {}
	for g in post.get("ccg", []):
		if (g as Array).size() >= 5:
			out[int(g[0])] = int(g[1]) if int(g[3]) > int(g[4]) else int(g[2])
	return out


## One line for the Hub: "Playoff picture: in as the #3 seed" ("" = too early).
static func picture_line(c: CareerData) -> String:
	var pic := picture(c)
	if not bool(pic.get("show", false)):
		return ""
	var me: Dictionary = pic["player"]
	var when := "Playoff field" if bool(pic.get("final", false)) else "Playoff picture"
	if bool(me.get("in", false)):
		return "%s: in, #%d seed" % [when, int(me["seed"])]
	if bool(me.get("bowl", false)):
		return "%s: bowl bound" % when
	var p := player_index(c)
	for side in pic["sides"]:
		var k := (side["out"] as Array).find(p)
		if k >= 0:
			return "%s: out, %s team below the line" % [when, ordinal(k + 1)]
	return "%s: out" % when


static func _rng(lg: Dictionary, salt: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash("%d|%d|%s" % [int(lg.get("seed", 0)), int(lg.get("season", 0)), salt])
	return r

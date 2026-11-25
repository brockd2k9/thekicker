class_name League
extends RefCounted
## The league around the player's team (numbers: LeagueConfig,
## res://tuning/league.tres; names: res://data/career/league_teams.json).
##
## One league per stage (high school, junior college, college, pro), stored in
## CareerData.league and made new when the stage changes. Every team has a slot
## (conference, division) and a strength rating that drifts between seasons.
## Each season every team gets a full schedule (division, conference,
## nonconference games and byes). The player's games are the real ones (the
## kick scene / GameSim); every other game is simulated at the end of its week
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
## Save layout (compact; team details come from world.json / league_teams.json):
##   {v, stage, seed, season, n, m, d,          conferences, divisions per conference, teams per division
##    ids: [team id per slot], str: [strength per slot], custom: {id: team} (made-up names only),
##    weeks: [[home, away, home, away, ...] per week], scores: [[home pts, away pts, ...] or [] per week],
##    post: {season, ccg, field, bracket, bowls}}
## Slot i is conference i / (m*d), division i / d (counted across the league).

const PATH := "res://tuning/league.tres"
const DATA := "league_teams.json"
const VERSION := 1

static var _cached: LeagueConfig


static func config() -> LeagueConfig:
	if _cached == null:
		var r: Variant = load(PATH) if ResourceLoader.exists(PATH) else null
		_cached = r if r is LeagueConfig else LeagueConfig.new()
	return _cached


## Tests / tools: use these numbers instead of the file (null = back to the file).
static func use_config(cfg: LeagueConfig) -> void:
	_cached = cfg


## This stage's names and filler teams from league_teams.json.
static func stage_data(stage: String) -> Dictionary:
	var d: Variant = CareerContent.file(DATA).get(stage, {})
	return d if d is Dictionary else {}


static func has_league(stage: String) -> bool:
	return not config().structure(stage).is_empty()


# --- the league -------------------------------------------------------------------------

## A new league for the career's stage, with the player's team and every
## world.json team of the stage in it. No schedule yet (prepare_season).
static func create(c: CareerData) -> Dictionary:
	var st := config().structure(c.stage)
	var n := int(st["conferences"])
	var m := int(st["divisions"])
	var d := int(st["teams"])
	var cap := m * d
	var seed := hash("%s|%s|%d|%s|%d" % [str(c.player.get("name", "")), c.stage, c.season,
		str(c.team.get("id", "")), c.created])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var lg := {"v": VERSION, "stage": c.stage, "seed": seed, "season": 0, "n": n, "m": m, "d": d,
		"ids": [], "str": [], "custom": {}, "weeks": [], "scores": [], "post": {}}
	# Candidates: the player's team, then world.json, then the filler teams.
	var world := _world_pool(c.stage)
	var pid := str(c.team.get("id", ""))
	var player_info := {}
	for s in world:
		if str(s.get("id", "")) == pid:
			player_info = s
	if player_info.is_empty():
		player_info = c.team.duplicate(true)
		lg["custom"][pid] = _slim(player_info)
	var firsts: Array = [player_info]
	var others: Array = world.filter(func(s: Dictionary) -> bool: return str(s.get("id", "")) != pid)
	Progression.shuffle(others, rng)
	firsts.append_array(others)
	firsts = firsts.slice(0, n * cap)
	var taken := {}
	for s in firsts:
		taken[str(s.get("id", ""))] = true
	var fill: Array = []
	for s in stage_data(c.stage).get("teams", []):
		if s is Dictionary and not taken.has(str(s.get("id", ""))):
			fill.append(s)
	# Into conferences: preferred conference while there's room, then the emptiest.
	var confs: Array = []
	for i in n:
		confs.append([])
	var floating: Array = []
	for group in [firsts, fill]:
		floating.clear()
		for s in group:
			var pref := int(s.get("conference", -1))
			if pref >= 0 and pref < n and (confs[pref] as Array).size() < cap:
				confs[pref].append(s)
			else:
				floating.append(s)
		for s in floating:
			var best := -1
			for i in n:
				if (confs[i] as Array).size() < cap and (best < 0 or (confs[i] as Array).size() < (confs[best] as Array).size()):
					best = i
			if best >= 0:
				confs[best].append(s)
	# Still short: made-up teams from the name pools.
	var made := 0
	for i in n:
		while (confs[i] as Array).size() < cap:
			var t := _pool_team(c.stage, made, rng, lg)
			made += 1
			lg["custom"][str(t["id"])] = t
			confs[i].append(t)
	# Deal each conference into its divisions (world teams spread out first).
	for i in n:
		var members: Array = confs[i]
		var divs: Array = []
		for v in m:
			divs.append([])
		for k in members.size():
			divs[k % m].append(members[k])
		for v in m:
			var dv: Array = divs[v]
			Progression.shuffle(dv, rng)
			for s in dv:
				lg["ids"].append(str(s.get("id", "")))
				lg["str"].append(snappedf(float(s.get("strength", 50.0)), 0.1))
	var p := index_of(lg, pid)
	if p >= 0:
		lg["str"][p] = snappedf(float(c.team.get("strength", lg["str"][p])), 0.1)
	return lg


## Start of a season (CareerManager._start_season): a league for this stage
## (new when the stage changed), strengths drifted for a new season, the
## player's team in it, and a fresh schedule. False when the stage has no league.
static func prepare_season(c: CareerData, t: CareerTuning) -> bool:
	if not has_league(c.stage):
		return false
	var lg := c.league
	if not valid(lg, c.stage):
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


## A save without a league (made before leagues, or a hand-edited file): make
## one for this stage and fit it around the schedule already being played
## (same opponents, same byes), with the weeks already finished simulated.
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
	var size := int(lg.get("n", 0)) * int(lg.get("m", 0)) * int(lg.get("d", 0))
	return size > 0 and lg.get("ids") is Array and (lg["ids"] as Array).size() == size \
		and lg.get("str") is Array and (lg["str"] as Array).size() == size \
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


# --- teams ------------------------------------------------------------------------------

static func size(lg: Dictionary) -> int:
	return (lg.get("ids", []) as Array).size()


static func index_of(lg: Dictionary, id: String) -> int:
	return (lg.get("ids", []) as Array).find(id)


static func player_index(c: CareerData) -> int:
	return index_of(c.league, str(c.team.get("id", "")))


static func conf_of(lg: Dictionary, i: int) -> int:
	return i / (int(lg["m"]) * int(lg["d"]))


## Division across the whole league (0 .. n*m-1).
static func div_of(lg: Dictionary, i: int) -> int:
	return i / int(lg["d"])


static func division_teams(lg: Dictionary, div: int) -> Array:
	var d := int(lg["d"])
	return range(div * d, div * d + d)


static func conference_teams(lg: Dictionary, conf: int) -> Array:
	var k := int(lg["m"]) * int(lg["d"])
	return range(conf * k, conf * k + k)


## A team as a schedule opponent (Progression.team_from) with its league strength.
static func team(lg: Dictionary, i: int) -> Dictionary:
	var info := _info(lg, str(lg["ids"][i]))
	var out := Progression.team_from(info, str(lg["stage"]))
	out["strength"] = float(lg["str"][i])
	return out


static func conference_name(lg: Dictionary, conf: int, short := false) -> String:
	var list: Array = stage_data(str(lg["stage"])).get("conferences", [])
	if conf < list.size() and list[conf] is Dictionary:
		var e: Dictionary = list[conf]
		return str(e.get("short" if short else "name", e.get("name", "")))
	return "%s %d" % [_word(lg, "conference_word", "Conference"), conf + 1]


static func division_name(lg: Dictionary, div: int) -> String:
	var m := int(lg["m"])
	var list: Array = stage_data(str(lg["stage"])).get("divisions", [])
	var c := div / m
	if c < list.size() and list[c] is Array and div % m < (list[c] as Array).size():
		return str(list[c][div % m])
	return "%s %d" % [_word(lg, "division_word", "Division"), div + 1]


## "Region" / "Conference", "District" / "Division".
static func word(lg: Dictionary, key: String) -> String:
	return _word(lg, key + "_word", "Conference" if key == "conference" else "Division")


static func _word(lg: Dictionary, key: String, fallback: String) -> String:
	return str(stage_data(str(lg.get("stage", ""))).get(key, fallback))


static func _world_pool(stage: String) -> Array:
	match stage:
		CareerData.STAGE_COLLEGE:
			return CareerContent.colleges()
		CareerData.STAGE_JUCO:
			return CareerContent.jucos()
		CareerData.STAGE_PRO:
			return CareerContent.pro_clubs()
	return CareerContent.high_schools()


static func _info(lg: Dictionary, id: String) -> Dictionary:
	var custom: Dictionary = lg.get("custom", {})
	if custom.has(id):
		return custom[id]
	for s in _world_pool(str(lg["stage"])):
		if str(s.get("id", "")) == id:
			return s
	for s in stage_data(str(lg["stage"])).get("teams", []):
		if s is Dictionary and str(s.get("id", "")) == id:
			return s
	return {"id": id, "name": id.capitalize(), "town": id.capitalize(), "mascot": "", "short": id.left(3).to_upper()}


static func _slim(t: Dictionary) -> Dictionary:
	var out := {}
	for k in ["id", "name", "mascot", "short", "town", "colors", "strength", "tier"]:
		if t.has(k):
			out[k] = t[k]
	return out


## A made-up team from the name pools (when league_teams.json runs out).
static func _pool_team(stage: String, k: int, rng: RandomNumberGenerator, lg: Dictionary) -> Dictionary:
	var all := CareerContent.file(DATA)
	var towns: Array = all.get("town_pool", ["Springfield"])
	var mascots: Array = all.get("mascot_pool", ["Tigers"])
	var town := str(towns[k % towns.size()])
	var mascot := str(mascots[(k * 7 + 3) % mascots.size()])
	if k >= towns.size():
		town += " " + str(k / towns.size() + 1)
	var id := "pool_%s_%d" % [stage, k]
	var suffix: String = {CareerData.STAGE_HIGH_SCHOOL: " High", CareerData.STAGE_JUCO: " Community College",
		CareerData.STAGE_COLLEGE: " University"}.get(stage, "")
	var base: float = {CareerData.STAGE_PRO: 62.0, CareerData.STAGE_COLLEGE: 55.0, CareerData.STAGE_JUCO: 44.0}.get(stage, 50.0)
	var t := {"id": id, "name": (town + suffix) if suffix != "" else "%s %s" % [town, mascot], "mascot": mascot,
		"short": town.left(3).to_upper(), "town": town, "strength": snappedf(base + rng.randf_range(-10, 10), 0.1),
		"colors": ["#%06x" % (rng.randi() & 0xffffff), "#%06x" % (rng.randi() & 0xffffff)]}
	if stage == CareerData.STAGE_COLLEGE:
		t["tier"] = "mid"
	elif stage == CareerData.STAGE_JUCO:
		t["tier"] = "juco"
	return t


## The player's team joined a club outside the league (or a hand-edited save):
## it takes the slot of a filler team (a world.json team only if it must).
static func _ensure_player(c: CareerData, lg: Dictionary) -> void:
	var pid := str(c.team.get("id", ""))
	if index_of(lg, pid) >= 0:
		return
	var world := {}
	for s in _world_pool(c.stage):
		world[str(s.get("id", ""))] = true
	var slot := -1
	for i in size(lg):
		if not world.has(str(lg["ids"][i])):
			slot = i
			break
	if slot < 0:
		slot = 0
	var known := false
	for s in _world_pool(c.stage):
		known = known or str(s.get("id", "")) == pid
	if not known:
		lg["custom"][pid] = _slim(c.team)
	lg["ids"][slot] = pid
	lg["str"][slot] = snappedf(float(c.team.get("strength", 50.0)), 0.1)


# --- the schedule ----------------------------------------------------------------------

static func _build_season(lg: Dictionary, t: CareerTuning) -> void:
	var st := config().structure(str(lg["stage"]))
	var rng := _rng(lg, "schedule%d" % int(lg["season"]))
	lg["weeks"] = generate_schedule(int(lg["n"]), int(lg["m"]), int(lg["d"]), int(st.get("division_games", 0)),
		int(st.get("conference_games", 0)), t.games_per_season, t.byes_per_season, t.bye_week_earliest,
		t.bye_week_latest, rng, int(lg["season"]))
	var scores: Array = []
	for w in (lg["weeks"] as Array).size():
		scores.append([])
	lg["scores"] = scores


## Every team's games, week by week: an Array (one per week) of flat
## [home, away, home, away, ...] team slots. n conferences x m divisions x d
## teams (d even). Each team plays `games` games: div_games in its division
## (round robin, again with home and away swapped if more), conf_games against
## the conference's other divisions, the rest against other conferences.
## Each team has `byes` byes, a division at a time, in weeks earliest..latest
## (division games moved to the last weeks of the season).
static func generate_schedule(n: int, m: int, d: int, div_games: int, conf_games: int, games: int, byes: int,
		earliest: int, latest: int, rng: RandomNumberGenerator, season := 0) -> Array:
	d += d % 2
	div_games = clampi(div_games, 0, games)
	conf_games = clampi(conf_games, 0, games - div_games)
	var non_games := games - div_games - conf_games
	# Turn impossible kinds into possible ones.
	if non_games > 0 and n < 2:
		conf_games += non_games
		non_games = 0
	if conf_games > 0 and m < 2:
		if n >= 2:
			non_games += conf_games
		else:
			div_games += conf_games
		conf_games = 0
	var shift := absi(season)
	var rounds_div: Array = []
	for k in div_games:
		rounds_div.append(_div_round(n, m, d, k))
	var rounds_conf: Array = []
	for k in conf_games:
		rounds_conf.append(_conf_round(n, m, d, k, shift, rng))
	var rounds_non: Array = []
	for k in non_games:
		rounds_non.append(_non_round(n, m, d, k, shift, rng))
	# Weeks 1..games: division rounds in the bye window (so byes can take
	# them), nonconference first, conference games in between.
	var pos := {}
	var free: Array = range(1, games + 1)
	var lo := clampi(earliest, 1, maxi(games, 1))
	var hi := clampi(latest, lo, maxi(games, 1))
	var window: Array = range(lo, hi + 1)
	var div_pos: Array = []
	if not rounds_div.is_empty():
		var want := mini(rounds_div.size(), window.size())
		for j in want:
			div_pos.append(window[roundi(float(j) * (window.size() - 1) / maxf(want - 1, 1)) if want > 1 else window.size() / 2])
		var uniq: Array = []
		for p in div_pos:
			if not (p in uniq):
				uniq.append(p)
		div_pos = uniq
		var back := games
		while div_pos.size() < rounds_div.size() and back >= 1:
			if not (back in div_pos):
				div_pos.append(back)
			back -= 1
		div_pos.sort()
	for p in div_pos:
		free.erase(p)
	var weeks: Array = []
	weeks.resize(games)
	for j in div_pos.size():
		weeks[int(div_pos[j]) - 1] = rounds_div[j]
	var j := 0
	for r in rounds_non + rounds_conf:
		weeks[int(free[j]) - 1] = r
		j += 1
	for w in games:
		if weeks[w] == null:
			weeks[w] = []
	# Byes: each division gives up `byes` of its division weeks (in the window)
	# and plays those games in the weeks added at the end.
	if byes > 0:
		var cands: Array = div_pos.filter(func(p: int) -> bool: return p >= lo and p <= hi)
		if cands.size() < byes:
			cands = div_pos.duplicate()
		if cands.size() < byes:
			# No division weeks to spare: everybody gets the same week off.
			for b in byes:
				weeks.insert(clampi((lo + hi) / 2 - 1 + b, 0, weeks.size()), [])
		else:
			var extra: Array = []
			for b in byes:
				extra.append([])
			for div in n * m:
				var start := (div * byes + shift) % cands.size()
				for b in byes:
					var w := int(cands[(start + b) % cands.size()]) - 1
					var keep: Array = []
					var moved: Array = []
					var pairs: Array = weeks[w]
					for q in range(0, pairs.size(), 2):
						if int(pairs[q]) / d == div:
							moved.append_array([pairs[q], pairs[q + 1]])
						else:
							keep.append_array([pairs[q], pairs[q + 1]])
					weeks[w] = keep
					extra[b].append_array(moved)
			weeks.append_array(extra)
	_balance_homes(weeks, n * m * d)
	return weeks


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


## Round robin (circle method) of d positions: round r's pairs [[a, b], ...].
static func _rr(d: int, r: int) -> Array:
	var out: Array = []
	var rot: Array = []
	for i in d - 1:
		rot.append((i + r) % (d - 1))
	out.append([d - 1, rot[0]] if r % 2 == 0 else [rot[0], d - 1])
	for i in range(1, d / 2):
		var a: int = rot[i]
		var b: int = rot[d - 1 - i]
		out.append([a, b] if (i + r) % 2 == 0 else [b, a])
	return out


static func _div_round(n: int, m: int, d: int, k: int) -> Array:
	var r := k % (d - 1)
	var flip := (k / (d - 1)) % 2 == 1
	var out: Array = []
	for div in n * m:
		for pr in _rr(d, r):
			var a: int = div * d + int(pr[0])
			var b: int = div * d + int(pr[1])
			out.append_array([b, a] if flip else [a, b])
	return out


static func _conf_round(n: int, m: int, d: int, k: int, shift: int, rng: RandomNumberGenerator) -> Array:
	if m % 2 == 1:
		return _random_round(n * m * d, func(a: int, b: int) -> bool:
			return a / (m * d) == b / (m * d) and a / d != b / d, rng)
	var pattern := (k / d + shift) % (m - 1)
	var off := (k + shift) % d
	var out: Array = []
	for c in n:
		for pr in _rr(m, pattern):
			var va: int = c * m + int(pr[0])
			var vb: int = c * m + int(pr[1])
			for s in d:
				var a := va * d + s
				var b := vb * d + (s + off) % d
				out.append_array([a, b] if (s + k) % 2 == 0 else [b, a])
	return out


static func _non_round(n: int, m: int, d: int, k: int, shift: int, rng: RandomNumberGenerator) -> Array:
	if n % 2 == 1:
		return _random_round(n * m * d, func(a: int, b: int) -> bool: return a / (m * d) != b / (m * d), rng)
	var per := m * d
	var pattern := (k / per + shift) % (n - 1)
	var rem := k % per
	var dshift := (rem / d + shift) % m
	var off := rem % d
	var out: Array = []
	for pr in _rr(n, pattern):
		var ca: int = int(pr[0])
		var cb: int = int(pr[1])
		for v in m:
			var va := ca * m + v
			var vb := cb * m + (v + dshift) % m
			for s in d:
				var a := va * d + s
				var b := vb * d + (s + off) % d
				out.append_array([a, b] if (s + v + k) % 2 == 0 else [b, a])
	return out


## Everybody paired once, pairs allowed by `ok` (random; a fallback for odd
## numbers of conferences or divisions).
static func _random_round(count: int, ok: Callable, rng: RandomNumberGenerator) -> Array:
	for attempt in 200:
		var order: Array = range(count)
		Progression.shuffle(order, rng)
		var used := {}
		var out: Array = []
		var good := true
		for a in order:
			if used.has(a):
				continue
			var found := -1
			for b in order:
				if b != a and not used.has(b) and (attempt > 150 or ok.call(a, b)):
					found = b
					break
			if found < 0:
				good = false
				break
			used[a] = true
			used[found] = true
			out.append_array([a, found])
		if good:
			return out
	return []


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
	var n := int(lg["n"])
	var m := int(lg["m"])
	if str(lg["stage"]) == CareerData.STAGE_COLLEGE:
		return _college_field(lg, st, s, champions)
	var sides: Array = []
	var outs: Array = []
	var groups: Array = []
	if bool(s.get("by_conference", true)):
		for c in n:
			groups.append(range(c * m, c * m + m))
	else:
		groups.append(range(0, n * m))
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


static func _college_field(lg: Dictionary, st: Array, s: Dictionary, champions: Dictionary) -> Dictionary:
	var n := int(lg["n"])
	var m := int(lg["m"])
	var champs := {}
	for c in n:
		if champions.has(c):
			champs[c] = int(champions[c])
		else:
			var winners: Array = []
			for v in m:
				winners.append(division_order(lg, st, c * m + v)[0])
			champs[c] = rank(lg, st, winners)[0]
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
	if c.stage == CareerData.STAGE_COLLEGE and bool(s.get("title_game", false)) and int(lg["m"]) >= 2:
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


## College conference title games: [[conf, home (better), away], ...]
## (results appended as [.., home pts, away pts] once played).
static func _title_pairs(lg: Dictionary, st: Array) -> Array:
	var out: Array = []
	var m := int(lg["m"])
	for c in int(lg["n"]):
		var winners: Array = []
		for v in m:
			winners.append(division_order(lg, st, c * m + v)[0])
		var top := rank(lg, st, winners)
		if top.size() >= 2:
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
		if bool(s.get("by_conference", false)) and c.stage != CareerData.STAGE_COLLEGE:
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

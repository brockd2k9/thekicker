class_name KickTrust
extends RefCounted
## Every field goal and extra point you kick moves the head coach and your Team
## standing. Misses cost more than makes earn; how much depends on how much the
## kick mattered (game winner > go-ahead > tying > close and late > high
## pressure > 4th quarter > routine), how hard it was (missing a chip shot hurts
## most, missing near the edge of your range least), and extra points count
## less. Resilience softens misses (both), Leadership softens them with the Team.
##
## Too many misses (CareerTuning "Relationships", "Too many misses"): a slump
## costs the coach's trust, sets the kicking_slump flag (story scenes such as
## HS_142 can follow), and starts coach doubt: shorter and fewer field goal
## calls for a few weeks (GameSim), explained on the Game Day Outlook.
##
## The game screen runs step() on a view() copy to show each kick's change as it
## happens; finish_game() runs apply_game() on the same kicks, so the save gets
## exactly what was shown (and a quit-and-replay can't count kicks twice).
## Backup kicks (you sat out) don't count.


## A working copy of what the kicks change, from the career as it is now.
static func view(c: CareerData) -> Dictionary:
	return {"coach": Relationships.value(c, "coach"), "team": Relationships.value(c, Relationships.TEAM),
		"has_coach": c.people.has("coach"), "has_team": c.people.has(Relationships.TEAM),
		"recent": c.recent_fg.duplicate(), "att": int(c.season_stats.get("fg_att", 0)),
		"made": int(c.season_stats.get("fg_made", 0)), "doubt": not c.coach_doubt.is_empty(),
		"slump": false, "res": c.stat("resilience"), "lead": c.stat("leadership"),
		"miss_mult": maxf(1.0 + Perks.total(c, "trust_miss"), 0.0),
		"team_mult": maxf(1.0 + Perks.total(c, "team_miss"), 0.0)}


## One kick. Updates `v` and returns {coach, team, reason, slump} (changes as
## floats; slump: this kick started a slump). range: today's field goal range.
static func step(v: Dictionary, k: Dictionary, range: float, t: CareerTuning) -> Dictionary:
	var kind := str(k.get("kind", ""))
	var out := {"coach": 0.0, "team": 0.0, "reason": "", "slump": false}
	if not (kind in ["fg", "pat"]) or k.get("backup", false):
		return out
	var made: bool = k.get("made", false)
	var sit := situation(k, t)
	var yd := int(k.get("yards", 0))
	var diff := 1.0
	var easy := kind == "pat" or yd <= t.kick_easy_yards or yd <= range * t.kick_easy_range_frac
	var edge := kind == "fg" and yd >= range - t.kick_edge_yards
	if easy:
		diff = t.kick_easy_make_mult if made else t.kick_easy_miss_mult
	elif edge:
		diff = t.kick_edge_make_mult if made else t.kick_edge_miss_mult
	var kmult := 1.0
	if kind == "pat":
		kmult = t.kick_pat_make_mult if made else t.kick_pat_miss_mult
	var m := float(sit["mult"]) * diff * kmult
	var coach := 0.0
	var team := 0.0
	if made:
		coach = t.kick_make_coach * m
		team = t.kick_make_team * m
		if float(v["coach"]) < Relationships.NEUTRAL:
			coach *= 1.0 + t.kick_recovery_resilience * float(v["res"]) / 100.0
		if v["doubt"]:
			coach *= t.kick_doubt_make_mult
	else:
		var soft := (1.0 - t.kick_resilience_soften * float(v["res"]) / 100.0) * float(v.get("miss_mult", 1.0))
		coach = t.kick_miss_coach * m * soft
		team = t.kick_miss_team * m * soft * (1.0 - t.kick_leadership_soften * float(v["lead"]) / 100.0) \
			* float(v.get("team_mult", 1.0))
	out["reason"] = reason(k, made, sit, easy, edge)
	if kind == "fg":
		var recent: Array = v["recent"]
		recent.append(made)
		while recent.size() > t.kick_window:
			recent.pop_front()
		v["att"] = int(v["att"]) + 1
		v["made"] = int(v["made"]) + (1 if made else 0)
		if not v["doubt"] and is_slump(recent, int(v["att"]), int(v["made"]), t):
			out["slump"] = true
			v["slump"] = true
			v["doubt"] = true
			coach += t.kick_slump_coach
		elif v["doubt"] and made and recent.size() >= t.kick_window and misses(recent) <= t.doubt_clear_misses:
			v["doubt"] = false
			out["doubt_cleared"] = true
	if not v["has_coach"]:
		coach = 0.0
	if not v["has_team"]:
		team = 0.0
	# Changes are what actually moves (values stay 0..100).
	var c0 := float(v["coach"])
	var t0 := float(v["team"])
	v["coach"] = clampf(c0 + coach, 0.0, 100.0)
	v["team"] = clampf(t0 + team, 0.0, 100.0)
	out["coach"] = float(v["coach"]) - c0
	out["team"] = float(v["team"]) - t0
	return out


## The situation multiplier and its name: the largest that applies.
static func situation(k: Dictionary, t: CareerTuning) -> Dictionary:
	var label := str(k.get("label", ""))
	var q := int(k.get("q", 0))
	var d := int(k.get("us", 0)) - int(k.get("them", 0))
	var pts := 3 if str(k.get("kind", "")) == "fg" else 1
	var best := {"mult": 1.0, "id": "routine"}
	var cand := []
	if "GAME WINNER" in label:
		cand.append([t.kick_mult_game_winner, "game_winner"])
	if q == 4 and d <= 0 and d + pts > 0:
		cand.append([t.kick_mult_go_ahead, "go_ahead"])
	if (q == 4 and d + pts == 0) or "TO TIE" in label:
		cand.append([t.kick_mult_tying, "tying"])
	if q == 4 and absi(d) <= t.kick_close_points:
		cand.append([t.kick_mult_close_late, "close_late"])
	if float(k.get("pressure", 0.0)) >= t.kick_high_pressure:
		cand.append([t.kick_mult_high_pressure, "pressure"])
	if q == 4:
		cand.append([t.kick_mult_q4, "q4"])
	for cnd in cand:
		if float(cnd[0]) > float(best["mult"]):
			best = {"mult": float(cnd[0]), "id": cnd[1]}
	return best


## "Missed a go-ahead kick." / "Made a 52-yard field goal."
static func reason(k: Dictionary, made: bool, sit: Dictionary, easy: bool, edge: bool) -> String:
	var kind := str(k.get("kind", ""))
	var yd := int(k.get("yards", 0))
	var what := "an extra point" if kind == "pat" else "a %d-yard field goal" % yd
	match str(sit["id"]):
		"game_winner":
			return "Game winner!" if made else "Missed a game-winning kick."
		"go_ahead":
			return "Go-ahead kick." if made else "Missed a go-ahead kick."
		"tying":
			return "Tied it up." if made else "Missed a tying kick."
		"close_late":
			return "Came through late in a close game." if made else "Missed late in a close game."
		"pressure":
			return "Made %s under pressure." % what if made else "Missed %s under pressure." % what
	if not made and kind == "pat":
		return "Missed an extra point."
	if not made and easy:
		return "Missed a short kick (%d yd)." % yd
	if not made and edge:
		return "Missed at the edge of your range (%d yd)." % yd
	if made and edge:
		return "Long make (%d yd)." % yd
	return ("Made %s." if made else "Missed %s.") % what


static func misses(recent: Array) -> int:
	return recent.filter(func(b: bool) -> bool: return not b).size()


## Too many misses: the recent window, or the season FG%.
static func is_slump(recent: Array, att: int, made: int, t: CareerTuning) -> bool:
	if recent.size() >= t.kick_window and misses(recent) >= t.kick_window_misses:
		return true
	return att >= t.kick_season_min_att and float(made) / att < t.kick_season_pct


## "Coach -4, Team -3" (changes rounded; zero parts left out).
static func change_text(coach: float, team: float) -> String:
	var parts := PackedStringArray()
	if roundi(coach) != 0:
		parts.append("Coach %+d" % roundi(coach))
	if roundi(team) != 0:
		parts.append("Team %+d" % roundi(team))
	return ", ".join(parts)


## After a game: the same steps on the real career. Returns {coach, team,
## lines: [text], slump}. The week's totals go to c.trust_week (Results).
static func apply_game(c: CareerData, kicks: Array, range: float, t: CareerTuning) -> Dictionary:
	var v := view(c)
	var total := {"coach": 0.0, "team": 0.0, "lines": [], "slump": false}
	var biggest := 0.0
	var big_line := ""
	for k in kicks:
		var r := step(v, k, range, t)
		if str(r["reason"]) == "":
			continue
		total["coach"] = float(total["coach"]) + float(r["coach"])
		total["team"] = float(total["team"]) + float(r["team"])
		var size := absf(float(r["coach"])) + absf(float(r["team"]))
		if size > biggest:
			biggest = size
			big_line = str(r["reason"])
		if r["slump"]:
			total["slump"] = true
	Relationships.apply(c, {"coach": total["coach"], Relationships.TEAM: total["team"]})
	c.recent_fg = v["recent"]
	if total["slump"]:
		start_doubt(c, t)
	elif not v["doubt"]:
		c.coach_doubt = {}
	if big_line != "":
		(total["lines"] as Array).append(big_line)
	c.trust_week = {"coach": total["coach"], "team": total["team"], "lines": total["lines"]}
	return total


## A slump: coach doubt for a few weeks, and the story flag.
static func start_doubt(c: CareerData, t: CareerTuning) -> void:
	var miss := misses(c.recent_fg)
	var why := "%d of your last %d field goals missed" % [miss, c.recent_fg.size()] \
		if c.recent_fg.size() >= t.kick_window and miss >= t.kick_window_misses \
		else "%d%% on field goals this season" % roundi(Progression.fg_pct(c.season_stats) * 100.0)
	c.coach_doubt = {"weeks_left": t.doubt_weeks, "reason": why}
	c.flags["kicking_slump"] = true
	c.flags["kick_slumps"] = int(c.flags.get("kick_slumps", 0)) + 1


## End of week: doubt counts down.
static func end_week(c: CareerData) -> void:
	if c.coach_doubt.is_empty():
		return
	c.coach_doubt["weeks_left"] = int(c.coach_doubt.get("weeks_left", 0)) - 1
	if int(c.coach_doubt["weeks_left"]) <= 0:
		c.coach_doubt = {}
		c.notice = "The coach's doubts have faded: he'll call your full range again."


## The coach's longest field goal call today.
static func coach_limit(c: CareerData, p: KickProfile, t: CareerTuning) -> int:
	var lim := p.fg_range - t.coach_range_margin_yd + Relationships.coach_range_yd(c, t) \
		+ Perks.total(c, "coach_range_yd")
	if not c.coach_doubt.is_empty():
		lim -= t.doubt_range_yd
	return floori(minf(lim, p.fg_range) + 0.001)

class_name KickChallenge
extends RefCounted
## Kick challenges: a scenario choice with a "kick_challenge" block (a
## showcase, camp, combine, competition, kicker battle or tryout) is played as
## real kicks in the kick scene, through the same flow as the bench audition
## (CareerData.tryout, purpose "challenge", TryoutMode, the tryout screen).
##
##   "kick_challenge": {"kind": "showcase", "title": "REGIONAL SHOWCASE",
##     "distances": [30, 35, 38, 42, 45], "need": 3, "pressure": "medium",
##     "wind": "breezy", "kickoffs": {"count": 2, "min_yards": 65},
##     "on_pass": {...}, "on_fail": {...}}
##
## The choice's own fields apply when it's picked (costs, story flags, a
## modifier like heavy_legs that affects the kicks); on_pass or on_fail after
## the kicks (ScenarioEngine.apply_effects: the same fields as a choice).
## need counts field goals and kickoffs together. Distances are clamped to the
## field goal range - 1 (like the audition).
## Challenge kicks earn no game skill points, never count in season stats and
## never change Coach / Team unless the scenario says so (rel in a block).
## Rewards: only what on_pass / on_fail say; a pass with no "followers" gets
## the kind's default buzz; every kick made adds sp_perfect_challenge skill
## points (source "Challenge") and buzz_perfect_challenge.
## Numbers: CareerTuning "Kick Challenges".

const KINDS := ["showcase", "camp", "combine", "competition", "battle", "tryout"]
const PRESSURES := ["low", "medium", "high"]
const WINDS := ["calm", "breezy", "windy"]
## Fields a block (on_pass / on_fail) may hold: the choice effect fields.
const BLOCK_FIELDS := ["result", "stats", "skill_points", "recruiting", "draft", "retention", "grades", "rel",
	"modifiers", "set_flags", "follow_up", "followers", "followers_exact", "conduct", "deal", "suspend_weeks", "recast", "money"]
const SP_SOURCE := "Challenge"


static func of(ch: Dictionary) -> Dictionary:
	return ch.get("kick_challenge", {}) if ch.get("kick_challenge") is Dictionary else {}


static func pressure(kc: Dictionary, t: CareerTuning) -> float:
	match str(kc.get("pressure", "medium")):
		"low":
			return t.challenge_pressure_low
		"high":
			return t.challenge_pressure_high
	return t.challenge_pressure_medium


static func wind_max(kc: Dictionary, t: CareerTuning) -> float:
	match str(kc.get("wind", "breezy")):
		"calm":
			return t.challenge_wind_calm
		"windy":
			return t.challenge_wind_windy
	return t.challenge_wind_breezy


## The field goal distances, clamped to range - 1 (and challenge_min_yards).
static func distances(kc: Dictionary, range: float, t: CareerTuning) -> Array:
	var cap := maxi(floori(range + 0.001) - 1, t.challenge_min_yards)
	var out: Array = []
	for d in kc.get("distances", []):
		out.append(clampi(int(d), t.challenge_min_yards, cap))
	return out


static func kickoffs(kc: Dictionary) -> Dictionary:
	var ko: Dictionary = kc.get("kickoffs", {}) if kc.get("kickoffs") is Dictionary else {}
	if int(ko.get("count", 0)) <= 0:
		return {}
	return {"count": int(ko["count"]), "min_yards": float(ko.get("min_yards", 60.0))}


static func total(kc: Dictionary) -> int:
	return (kc.get("distances", []) as Array).size() + int(kickoffs(kc).get("count", 0))


static func need(kc: Dictionary) -> int:
	return clampi(int(kc.get("need", 3)), 1, maxi(total(kc), 1))


## The tryout record (CareerData.tryout) for a challenge.
## return_phase: where the week continues afterwards (scenario / offseason).
static func tryout(c: CareerData, kc: Dictionary, scenario_id: String, choice: int, range: float,
		return_phase: String, seed: int, t: CareerTuning) -> Dictionary:
	var stage := "pro" if c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] else \
		("high_school" if c.stage == CareerData.STAGE_HIGH_SCHOOL else "college")
	return {"title": str(kc.get("title", str(kc.get("kind", "challenge")).to_upper())),
		"kind": str(kc.get("kind", "competition")), "distances": distances(kc, range, t),
		"need": need(kc), "pressure": pressure(kc, t), "wind_max": wind_max(kc, t),
		"kickoffs": kickoffs(kc), "stage": stage, "purpose": "challenge",
		"team": str(c.team.get("id", "")), "team_name": str(kc.get("title", "")).capitalize(),
		"scenario": scenario_id, "choice": choice, "return_phase": return_phase,
		"results": [], "made": 0, "taken": 0, "seed": seed}


## Made so far (field goals and kickoffs) from the saved results.
static func made(tr: Dictionary) -> int:
	return (tr.get("results", []) as Array).count(true)


## The challenge's kicks are done: apply on_pass or on_fail (plus the kind's
## default followers on a pass, and the perfect-challenge bonus). Returns
## {"passed", "made", "kicks", "need", "perfect", "out": apply_effects result}.
static func finish(c: CareerData, tr: Dictionary, t: CareerTuning) -> Dictionary:
	var ch := choice_of(tr)
	var kc := of(ch)
	var n := made(tr)
	var kicks := (tr.get("results", []) as Array).size()
	var passed := n >= int(tr.get("need", need(kc)))
	var block: Dictionary = (kc.get("on_pass" if passed else "on_fail", {}) as Dictionary).duplicate(true)
	if passed and not block.has("followers") and not block.has("followers_exact"):
		block["followers"] = default_buzz(str(tr.get("kind", "")), t)
	var out := ScenarioEngine.apply_effects(c, block, t, str(CareerContent.scenario(str(tr.get("scenario", ""))).get("title", "")))
	var perfect := kicks > 0 and n == kicks and kicks >= TryoutMode.total_kicks(tr)
	if perfect:
		SkillPoints.earn(c, t.sp_perfect_challenge, SP_SOURCE)
		out["skill_points"] = int(out.get("skill_points", 0)) + t.sp_perfect_challenge
		out["followers"] = int(out.get("followers", 0)) + Followers.gain(c, t.buzz_perfect_challenge, "Perfect challenge", t)
	return {"passed": passed, "made": n, "kicks": kicks, "need": int(tr.get("need", 3)), "perfect": perfect,
		"out": out}


static func choice_of(tr: Dictionary) -> Dictionary:
	var s := CareerContent.scenario(str(tr.get("scenario", "")))
	var choices: Array = s.get("choices", [])
	var i := int(tr.get("choice", -1))
	return choices[i] if i >= 0 and i < choices.size() else {}


static func default_buzz(kind: String, t: CareerTuning) -> float:
	match kind:
		"showcase":
			return t.buzz_challenge_showcase
		"camp":
			return t.buzz_challenge_camp
		"combine":
			return t.buzz_challenge_combine
		"competition":
			return t.buzz_challenge_competition
		"battle":
			return t.buzz_challenge_battle
		"tryout":
			return t.buzz_challenge_tryout
	return 0.0


# --- scenario card ------------------------------------------------------------------

## "Kick challenge: make 3 of 5, 30-45 yd (+2 kickoffs, 65+ yd)" for this kicker.
static func summary(kc: Dictionary, range: float, t: CareerTuning) -> String:
	var d := distances(kc, range, t)
	var text := "Kick challenge: make %d of %d" % [need(kc), total(kc)]
	if not d.is_empty():
		text += ", %d-%d yd" % [int(d.min()), int(d.max())] if d.min() != d.max() else ", %d yd" % int(d[0])
	var ko := kickoffs(kc)
	if not ko.is_empty():
		text += " (incl. %d kickoff%s, %d+ yd)" % [int(ko["count"]), "" if int(ko["count"]) == 1 else "s",
			roundi(float(ko["min_yards"]))]
	return text


## A block's rewards in a few words: "+6 Recruiting, +2 skill points, +40 followers".
static func block_text(c: CareerData, block: Dictionary, t: CareerTuning, pass_default := 0.0) -> String:
	var parts := PackedStringArray()
	for k in ["recruiting", "draft", "retention"]:
		if block.has(k) and float(block[k]) != 0.0:
			parts.append("%+d %s" % [roundi(float(block[k])), {"recruiting": "Recruiting", "draft": "Draft stock",
				"retention": "Standing"}[k]])
	if block.has("grades") and float(block["grades"]) != 0.0:
		parts.append("%+.1f GPA" % float(block["grades"]))
	var sp := roundi(float(block.get("skill_points", 0)) * t.sp_scenario_scale)
	if sp != 0:
		parts.append("%+d skill point%s" % [sp, "" if absi(sp) == 1 else "s"])
	var b := block.duplicate()
	if pass_default != 0.0 and not b.has("followers") and not b.has("followers_exact"):
		b["followers"] = pass_default
	var fans := Followers.choice_preview(c, b, t)
	if fans != 0:
		parts.append(Followers.change_text(fans))
	for id in (block.get("rel", {}) as Dictionary):
		parts.append("%s %+d" % [Relationships.name_of(c, str(id)), roundi(float(block["rel"][id]))])
	var stats := 0
	for g in (block.get("stats", {}) as Dictionary):
		stats += (block["stats"][g] as Dictionary).size()
	if stats > 0:
		parts.append("stat changes")
	return ", ".join(parts) if not parts.is_empty() else "nothing"


# --- validation (the engine's own content check) ------------------------------------

static func problems(where: String, ch: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var kc: Variant = ch.get("kick_challenge")
	if not (kc is Dictionary):
		out.append("%s: kick_challenge must be an object" % where)
		return out
	if not (str(kc.get("kind", "")) in KINDS):
		out.append("%s: kick_challenge kind must be one of %s" % [where, ", ".join(KINDS)])
	var d: Variant = kc.get("distances", [])
	if not (d is Array) or (d as Array).size() < 2 or (d as Array).size() > 8 \
			or (d as Array).any(func(x: Variant) -> bool: return not (x is float or x is int) or float(x) < 20.0 or float(x) > 60.0):
		out.append("%s: kick_challenge distances must be 2-8 numbers, 20-60" % where)
	if not (kc.get("need") is float or kc.get("need") is int) or int(kc["need"]) < 1 or int(kc["need"]) > total(kc):
		out.append("%s: kick_challenge need must be 1..%d" % [where, total(kc)])
	if kc.has("pressure") and not (str(kc["pressure"]) in PRESSURES):
		out.append("%s: kick_challenge pressure must be low, medium or high" % where)
	if kc.has("wind") and not (str(kc["wind"]) in WINDS):
		out.append("%s: kick_challenge wind must be calm, breezy or windy" % where)
	if kc.has("kickoffs"):
		var ko: Variant = kc["kickoffs"]
		if not (ko is Dictionary) or int(ko.get("count", 0)) < 0 or int(ko.get("count", 0)) > 3:
			out.append("%s: kick_challenge kickoffs needs count 0-3 (and min_yards)" % where)
	if str(kc.get("title", "")).length() > 24:
		out.append("%s: kick_challenge title is over 24 characters" % where)
	for b in ["on_pass", "on_fail"]:
		var blk: Variant = kc.get(b)
		if not (blk is Dictionary):
			out.append("%s: kick_challenge needs %s" % [where, b])
			continue
		if str(blk.get("result", "")) == "":
			out.append("%s: %s needs a result" % [where, b])
		for k in blk:
			if not (str(k) in BLOCK_FIELDS):
				out.append("%s: %s can't have '%s'" % [where, b, k])
	return out

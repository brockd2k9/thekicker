class_name ScenarioEngine
extends RefCounted
## Picks and applies off-field scenarios (data in data/career/scenarios_*.json;
## the field reference is the "_doc" at the top of scenarios_hs.json).
##
## pick() fills a week in this order:
##   1. story scenarios in the last week of their window (soft story beats
##      that haven't come up yet; until then they're boosted random picks)
##   2. follow-ups that are due (queued by an earlier choice)
##   3. story beats due now (guaranteed scenarios at a set season/week)
##   4. weighted random picks from the eligible pool
## 1-3 are "forced": at most max_forced_per_week of them; the rest wait (follow-ups
## stay queued, beats stay due) except a story scenario, whose window is over.
## Draft scenarios (no text or choices yet) are never picked.
## Eligibility: stage, when (season/bye/offseason), week and season ranges,
## requirements (stats, traits, flags, any_of), one-time, cooldown, and the
## repetition guard (per-season cap). Weights shrink for a category each time
## it already appeared this season, and for social categories while Social is
## low. No two scenarios of the same category in one week.
## Numbers: CareerTuning "Scenario Picks".
## apply_choice(): stat changes through CareerStats (the same rules the screen
## previews), game-day modifiers, flags, follow-ups and the logs.

const CATEGORIES := ["social", "school", "training", "health", "work", "media", "family",
	"money", "team", "romance", "community", "career"]
## Choice fields that move progression numbers instead of stats:
## recruiting / draft / retention points, and grades (GPA points, 0-4 scale).
const PROGRESS_KEYS := ["recruiting", "draft", "retention", "grades"]
## Dev hook for the balance simulator: when a Dictionary, every choice's
## progress changes add up here by key. null in the game.
static var progress_tally: Variant = null


# --- requirements -------------------------------------------------------------------

## requires: {min: {stat: n}, max: {stat: n}, traits: [all of], any_traits: [one of],
## (min/max also take "recruiting", "draft", "retention", "gpa", "age"),
## flags: [all set], any_flags: [one set], not_flags: [unset],
## followers_tier: tier id (this tier or higher), max_followers_tier: tier id
## (this tier or lower), (min/max also take "followers", a count),
## any_of: [requires, ...] (one must pass)}.
static func requirements_met(c: CareerData, req: Dictionary) -> bool:
	if req.has("followers_tier") or req.has("max_followers_tier"):
		var t := CareerTuning.get_default()
		var tier := Followers.tier(c, t)
		if req.has("followers_tier") and tier < Followers.tier_index(str(req["followers_tier"])):
			return false
		if req.has("max_followers_tier") and tier > Followers.tier_index(str(req["max_followers_tier"])):
			return false
	for k in req.get("min", {}):
		if c.metric(k) < float(req["min"][k]):
			return false
	for k in req.get("max", {}):
		if c.metric(k) > float(req["max"][k]):
			return false
	for t in req.get("traits", []):
		if not c.has_trait(str(t)):
			return false
	var any_t: Array = req.get("any_traits", [])
	if not any_t.is_empty() and not any_t.any(func(t: Variant) -> bool: return c.has_trait(str(t))):
		return false
	for f in req.get("flags", []):
		if not c.flags.get(str(f), false):
			return false
	var any_f: Array = req.get("any_flags", [])
	if not any_f.is_empty() and not any_f.any(func(f: Variant) -> bool: return c.flags.get(str(f), false)):
		return false
	for f in req.get("not_flags", []):
		if c.flags.get(str(f), false):
			return false
	var any_of: Array = req.get("any_of", [])
	if not any_of.is_empty() and not any_of.any(func(r: Variant) -> bool: return requirements_met(c, r)):
		return false
	return true


## "Team Captain or Leadership 60+" (empty if no trait/personality gate).
static func requirement_text(req: Dictionary) -> String:
	var parts := PackedStringArray()
	if req.has("followers_tier"):
		var i := Followers.tier_index(str(req["followers_tier"]))
		if i > 0:
			parts.append(Followers.tier_label(i, CareerTuning.get_default()))
	if req.has("min") and (req["min"] as Dictionary).has("followers"):
		parts.append("%s followers" % Followers.round_count(int(req["min"]["followers"])))
	if req.has("min") and (req["min"] as Dictionary).has("savings"):
		parts.append("%s saved" % Savings.text(int(req["min"]["savings"])))
	if req.has("max") and (req["max"] as Dictionary).has("savings"):
		parts.append("under %s saved" % Savings.text(int(req["max"]["savings"]) + 1))
	for t in req.get("traits", []):
		parts.append(_trait_name(t))
	var any_t: Array = req.get("any_traits", [])
	if not any_t.is_empty():
		parts.append(" or ".join(PackedStringArray(any_t.map(_trait_name))))
	for k in req.get("min", {}):
		if CareerData.group_of(k) == CareerData.PERSONALITY:
			parts.append("%s %d+" % [CareerData.STAT_NAMES[k], int(req["min"][k])])
		elif str(k).begins_with("rel_"):
			parts.append("%s %d+" % [_person_word(str(k)), int(req["min"][k])])
	for k in req.get("max", {}):
		if str(k).begins_with("rel_"):
			parts.append("%s under %d" % [_person_word(str(k)), int(req["max"][k]) + 1])
	var any_of: Array = req.get("any_of", [])
	if not any_of.is_empty():
		var alts := PackedStringArray()
		for r in any_of:
			var t := requirement_text(r)
			if t != "":
				alts.append(t)
		if not alts.is_empty():
			parts.append(" or ".join(alts))
	return " + ".join(parts)


## "Head Coach", "Tyler Brooks": a person in requirement text.
static func _person_word(key: String) -> String:
	var d := Relationships.def(key.substr(4))
	return str(d.get("name", {}).get("fixed", d.get("role", key)))


static func _trait_name(id: Variant) -> String:
	return str(CareerContent.trait_def(str(id)).get("name", id))


## Why a choice is locked ("" = available). A choice's "lock_text" replaces the
## generated text (flag requirements have no wording of their own).
static func choice_lock(c: CareerData, ch: Dictionary) -> String:
	var req: Dictionary = ch.get("requires", {})
	if req.is_empty() or requirements_met(c, req):
		return ""
	if str(ch.get("lock_text", "")) != "":
		return "Requires " + str(ch["lock_text"])
	var t := requirement_text(req)
	return "Requires " + (t if t != "" else "more experience")


# --- eligibility --------------------------------------------------------------------

## when: "season" (game week), "bye" or "offseason". forced: a due follow-up or
## story beat (skips the random-only rules: cooldown, season cap, beat/follow-up flags).
static func is_eligible(c: CareerData, s: Dictionary, when: String, tuning: CareerTuning,
		forced := false) -> bool:
	var id := str(s.get("id", ""))
	if s.get("draft", false):
		return false
	if not (c.stage in s.get("stages", [])):
		return false
	if not (when in s.get("when", ["season", "bye"])):
		return false
	if not forced and (s.get("follow_up_only", false) or s.has("beat")):
		return false
	var weeks: Variant = s.get("weeks")
	if weeks is Array and weeks.size() == 2 and when != "offseason":
		if c.week < int(weeks[0]) or c.week > int(weeks[1]):
			return false
	var seasons: Variant = s.get("seasons")
	if seasons is Array and seasons.size() == 2:
		if c.season_in_stage < int(seasons[0]) or c.season_in_stage > int(seasons[1]):
			return false
	var log: Dictionary = c.scenario_log.get(id, {})
	if not log.is_empty():
		if bool(s.get("once", false)) or s.has("beat"):
			return false
		# once_per_club: once at each club (old log entries: seen at this club).
		if bool(s.get("once_per_club", false)) and _club_key(c) in (log.get("clubs", [_club_key(c)]) as Array):
			return false
		if not forced and c.week_index - int(log.get("last_week_index", -999)) < int(s.get("cooldown", 0)):
			return false
	if not forced and int(c.season_log.get("ids", {}).get(id, 0)) >= tuning.max_scenario_repeats_per_season:
		return false
	return requirements_met(c, s.get("requires", {}))


## The club a once_per_club scene counts against (team id, else name).
static func _club_key(c: CareerData) -> String:
	var id := str(c.team.get("id", ""))
	return id if id != "" else str(c.team.get("name", ""))


static func weight(c: CareerData, s: Dictionary, tuning: CareerTuning) -> float:
	var w := maxf(float(s.get("weight", 1.0)), 0.0)
	var cat := str(s.get("category", ""))
	w *= pow(tuning.category_repeat_decay, int(c.season_log.get("cats", {}).get(cat, 0)))
	if s.get("story", false):
		w *= tuning.story_weight_mult
	if cat in tuning.social_categories and c.stat("social") < tuning.low_social_threshold:
		w *= tuning.low_social_weight_mult
	return w


## A story beat is due at its season_in_stage, from its week on (or in that
## offseason), until it has been seen once.
static func beat_due(c: CareerData, s: Dictionary, when: String) -> bool:
	var beat: Variant = s.get("beat")
	if not (beat is Dictionary) or c.scenario_log.has(str(s.get("id", ""))):
		return false
	if c.season_in_stage != int(beat.get("season_in_stage", 1)):
		return false
	if when == "offseason":
		return "offseason" in s.get("when", [])
	return c.week >= int(beat.get("week", 1))


## A story scenario ("story": true) is forced in the last week of its window if
## it hasn't been seen: week weeks[1] of its last season (seasons[1]), or that
## season's offseason for an offseason-only one. Before that it's a normal
## random pick with its weight times story_weight_mult.
static func story_due(c: CareerData, s: Dictionary, when: String) -> bool:
	if not s.get("story", false) or c.scenario_log.has(str(s.get("id", ""))):
		return false
	var seasons: Variant = s.get("seasons")
	if not (seasons is Array and seasons.size() == 2) or c.season_in_stage != int(seasons[1]):
		return false
	if s.get("when", []) == ["offseason"]:
		return when == "offseason"
	var weeks: Variant = s.get("weeks")
	return when != "offseason" and weeks is Array and weeks.size() == 2 and c.week == int(weeks[1])


# --- picking -------------------------------------------------------------------------

## The week's scenario ids: due follow-ups, story beats, then weighted random
## picks up to `count`. Forced ones are always included (even past count).
static func pick(c: CareerData, when: String, count: int, rng: RandomNumberGenerator,
		tuning: CareerTuning) -> Array:
	var out: Array = []
	var cats := {}
	var cap := tuning.max_forced_per_week
	# 1. Story scenarios in the last week of their window.
	for s in CareerContent.live_scenarios():
		if out.size() < cap and story_due(c, s, when) and is_eligible(c, s, when, tuning, true):
			out.append(str(s["id"]))
			cats[str(s.get("category", ""))] = true
	# 2. Due follow-ups (over the cap they stay queued for next week).
	for q in c.queued_scenarios.duplicate():
		if int(q.get("due", 0)) > c.week_index:
			continue
		var s := CareerContent.scenario(str(q["id"]))
		if s.is_empty() or not (c.stage in s.get("stages", [])):
			c.queued_scenarios.erase(q)  # gone, or a different stage now
		elif out.size() < cap and is_eligible(c, s, when, tuning, true) and not (s["id"] in out):
			c.queued_scenarios.erase(q)
			out.append(str(s["id"]))
			cats[str(s.get("category", ""))] = true
	# 3. Story beats (over the cap they stay due next week).
	for s in CareerContent.live_scenarios():
		if out.size() < cap and beat_due(c, s, when) and is_eligible(c, s, when, tuning, true) \
				and not (s["id"] in out):
			out.append(str(s["id"]))
			cats[str(s.get("category", ""))] = true
	# 4. Weighted random.
	var pool: Array = []
	for s in CareerContent.live_scenarios():
		if not (s["id"] in out) and is_eligible(c, s, when, tuning):
			pool.append(s)
	while out.size() < count:
		var options: Array = pool
		if tuning.no_repeat_category_in_week:
			options = pool.filter(func(s: Dictionary) -> bool: return not cats.has(str(s.get("category", ""))))
		var total := 0.0
		for s in options:
			total += weight(c, s, tuning)
		if options.is_empty() or total <= 0.0:
			break
		var r := rng.randf() * total
		var chosen: Dictionary = options[options.size() - 1]
		for s in options:
			r -= weight(c, s, tuning)
			if r <= 0.0:
				chosen = s
				break
		out.append(str(chosen["id"]))
		cats[str(chosen.get("category", ""))] = true
		pool.erase(chosen)
	return out


# --- applying ------------------------------------------------------------------------

## Applies choice `index` of scenario `id`. Returns {"applied": stat changes,
## "new_traits": [...], "result": text, "modifiers": [...], "follow_up": id,
## "relationships": {person id: change}, "skill_points": n, "followers": change}.
static func apply_choice(c: CareerData, id: String, index: int, tuning: CareerTuning) -> Dictionary:
	var s := CareerContent.scenario(id)
	var choices: Array = s.get("choices", [])
	if index < 0 or index >= choices.size():
		push_warning("ScenarioEngine: bad choice %d for '%s'" % [index, id])
		return {}
	var ch: Dictionary = choices[index]
	if choice_lock(c, ch) != "":
		push_warning("ScenarioEngine: choice %d of '%s' is locked" % [index, id])
		return {}
	var imp := impact(s)
	var vars := Relationships.text_vars(c)
	var title := CareerContent.fill(str(s.get("title", "")), vars)
	var tier_before := Followers.tier(c, tuning)
	var out := apply_effects(c, ch, tuning, title, imp)
	out["impact"] = imp
	out["tier_up"] = Followers.tier(c, tuning) > tier_before
	if ch.get("kick_challenge") is Dictionary:
		out["challenge"] = true
	out["reasons"] = result_reasons(ch, out, imp, tuning)
	_remember(c, s, ch, out, vars, tuning)
	# Wrong (or good) decisions feed the kick nerves (crooked swipes cost more).
	KickNerves.on_choice(c, ch, tuning)
	var log: Dictionary = c.scenario_log.get(id, {"times": 0})
	log["times"] = int(log.get("times", 0)) + 1
	log["last_week_index"] = c.week_index
	log["last_choice"] = index
	if bool(s.get("once_per_club", false)):
		var clubs: Array = log.get("clubs", [])
		if not (_club_key(c) in clubs):
			clubs.append(_club_key(c))
		log["clubs"] = clubs
	c.scenario_log[id] = log
	var ids: Dictionary = c.season_log["ids"]
	ids[id] = int(ids.get(id, 0)) + 1
	var cats: Dictionary = c.season_log["cats"]
	var cat := str(s.get("category", ""))
	cats[cat] = int(cats.get(cat, 0)) + 1
	# A kick challenge (out["challenge"], above): the top-level effects apply
	# now; on_pass / on_fail after the kicks (KickChallenge, CareerManager.start_challenge).
	return out


## Applies one block of effects (a choice, or a kick challenge's on_pass /
## on_fail): stats, skill points, progress, game-day modifiers, relationships,
## followers, flags and a follow-up. Returns what happened (apply_choice's keys).
## reason: what a suspension notice names (the scenario's title).
## imp: the scene's impact (scales the stat changes, impact_scale_*).
static func apply_effects(c: CareerData, ch: Dictionary, tuning: CareerTuning, reason := "",
		imp := "normal") -> Dictionary:
	var applied := CareerStats.apply(c, scaled_stats(ch.get("stats", {}), tuning, imp), tuning)
	var sp := SkillPoints.from_choice(c, float(ch.get("skill_points", 0)), tuning) \
		if ch.has("skill_points") else 0
	var progress := progress_changes(ch, tuning)
	# In-season choices come every week: a longer season has more of them, so
	# their progress counts season_scale as much (offseason ones don't change).
	if c.phase != "offseason":
		var sc := tuning.season_scale(c.stage)
		for k in progress:
			progress[k] = float(progress[k]) * sc
	if progress_tally is Dictionary:
		for k in progress:
			progress_tally[k] = float(progress_tally.get(k, 0.0)) + float(progress[k])
	c.recruiting_score = clampf(c.recruiting_score + float(progress.get("recruiting", 0.0)), 0.0, 100.0)
	c.draft_score = clampf(c.draft_score + float(progress.get("draft", 0.0)), 0.0, 100.0)
	c.retention_bonus += float(progress.get("retention", 0.0))
	c.gpa = clampf(c.gpa + float(progress.get("grades", 0.0)), 0.0, 4.0)
	var mods: Array = []
	for m in ch.get("modifiers", []):
		if not (str(m) in c.week_modifiers):
			c.week_modifiers.append(str(m))
		mods.append(str(m))
	var rel := Relationships.apply(c, ch.get("rel", {}))
	var fans := Followers.from_choice(c, ch, tuning)
	var money := Savings.from_choice(c, ch)
	var set_flags: Dictionary = ch.get("set_flags", {})
	for f in set_flags:
		c.flags[f] = set_flags[f]
	Reputation.on_flags(c, set_flags, tuning)
	if ch.has("suspend_weeks"):
		Reputation.suspend(c, int(ch["suspend_weeks"]), reason, tuning)
	if ch.get("recast") is Array:
		Relationships.recast(c, ch["recast"], tuning)
	var follow := ""
	var fu: Variant = ch.get("follow_up")
	if fu is String:
		fu = {"id": fu}
	if fu is Dictionary and fu.has("id"):
		follow = str(fu["id"])
		c.queued_scenarios.append({"id": follow, "due": c.week_index + maxi(int(fu.get("weeks", 1)), 1)})
	return {"applied": applied, "new_traits": applied.get("new_traits", []),
		"result": str(ch.get("result", "")), "modifiers": mods, "follow_up": follow,
		"progress": progress, "relationships": rel, "skill_points": sp, "followers": fans,
		"money": money}


## A choice's stat changes with the football ones scaled by
## scenario_football_scale (skill points are the main football growth now),
## then every stat by the scene's impact (impact_scale_minor / normal / major).
static func scaled_stats(stats: Dictionary, tuning: CareerTuning, imp := "normal") -> Dictionary:
	var fb_scale := tuning.scenario_football_scale
	var all := impact_scale(imp, tuning)
	if (is_equal_approx(fb_scale, 1.0) or not stats.has(CareerData.FOOTBALL)) and is_equal_approx(all, 1.0):
		return stats
	var out := stats.duplicate(true)
	for g in out:
		if not (out[g] is Dictionary):
			continue
		var grp: Dictionary = out[g]
		for k in grp:
			grp[k] = float(grp[k]) * all * (fb_scale if g == CareerData.FOOTBALL else 1.0)
	return out


# --- impact, results and callbacks ------------------------------------------------------

const IMPACTS := ["minor", "normal", "major"]
## Dev hook for the balance simulator: true = scenes with no "impact" tag get
## guess_impact() instead of "normal" (an estimate of the story session's tags).
static var impact_guess := false


## A scene's impact: its "impact" field ("minor" / "normal" / "major"), default "normal".
static func impact(s: Dictionary) -> String:
	var v := str(s.get("impact", ""))
	if v in IMPACTS:
		return v
	return guess_impact(s) if impact_guess else "normal"


static func impact_scale(imp: String, t: CareerTuning) -> float:
	match imp:
		"minor":
			return t.impact_scale_minor
		"major":
			return t.impact_scale_major
	return t.impact_scale_normal


## A rough impact for an untagged scene (the simulator's estimate; the data's
## own tag always wins): major = a story beat or a scene where a choice can
## suspend, cause a scandal, move draft stock or set character flags; minor =
## a repeatable scene whose choices set no flags, move no money or draft /
## recruiting points, carry no conduct and move no one by result_rel_min.
static func guess_impact(s: Dictionary) -> String:
	if s.has("beat"):
		return "major"
	var t := CareerTuning.get_default()
	var minor := not bool(s.get("once", false)) and not bool(s.get("story", false))
	for ch in s.get("choices", []):
		if ch.has("suspend_weeks") or str(ch.get("conduct", "")) == "scandal" or ch.has("draft") \
				or (ch.get("set_flags", {}) as Dictionary).has(Reputation.CONCERNS):
			return "major"
		if not (ch.get("set_flags", {}) as Dictionary).is_empty() or ch.has("money") or ch.has("conduct") \
				or ch.has("recruiting") or ch.has("follow_up") or ch.has("kick_challenge"):
			minor = false
		for p in (ch.get("rel", {}) as Dictionary):
			if absf(float(ch["rel"][p])) >= t.result_rel_min:
				minor = false
	return "minor" if minor else "normal"


## Why the full result screen shows for a choice (empty = a quick toast only):
## always for a major scene; never for a minor one (except a suspension, a new
## trait or a kick challenge, which always show); for a normal scene, when the
## choice crosses one of CareerTuning's "Scenario Impact" thresholds.
## out: apply_effects' result (with "tier_up" when followers reached a new tier).
static func result_reasons(ch: Dictionary, out: Dictionary, imp: String, t: CareerTuning) -> Array:
	var r: Array = []
	if ch.has("suspend_weeks"):
		r.append("suspension")
	if not (out.get("new_traits", []) as Array).is_empty():
		r.append("trait")
	if ch.get("kick_challenge") is Dictionary:
		r.append("challenge")
	if imp == "major":
		r.append("major")
	if imp != "normal":
		return r
	if not (ch.get("set_flags", {}) as Dictionary).is_empty():
		r.append("flag")
	if ch.has("conduct"):
		r.append("conduct")
	if float(ch.get("draft", 0.0)) != 0.0:
		r.append("draft")
	if absf(float(ch.get("recruiting", 0.0))) >= t.result_recruiting_min:
		r.append("recruiting")
	if absi(int(out.get("money", 0))) >= t.result_money_min:
		r.append("money")
	for p in (ch.get("rel", {}) as Dictionary):
		if absf(float(ch["rel"][p])) >= t.result_rel_min:
			r.append("relationship")
			break
	if absf(Followers.choice_buzz(ch, t)) >= t.result_followers_min or bool(out.get("tier_up", false)):
		r.append("followers")
	if ch.get("deal") is Dictionary:
		r.append("deal")
	if str(out.get("follow_up", "")) != "":
		r.append("follow_up")
	return r


## A choice with a real downside (its card shows direction only, no numbers):
## "risky": true / false in the data decides; otherwise any choice in a major
## scene, a kick challenge, bad conduct or a scandal, a suspension, character
## concerns, a money loss of result_money_min or more, someone dropping by
## result_rel_min or more, or followers buzz of -result_followers_min or worse.
static func is_risky(ch: Dictionary, imp: String, t: CareerTuning) -> bool:
	if ch.has("risky"):
		return bool(ch["risky"])
	if imp == "major" or ch.get("kick_challenge") is Dictionary or ch.has("suspend_weeks"):
		return true
	if str(ch.get("conduct", "")) in ["bad", "scandal"]:
		return true
	if bool((ch.get("set_flags", {}) as Dictionary).get(Reputation.CONCERNS, false)):
		return true
	if int(ch.get("money", 0)) <= -t.result_money_min:
		return true
	for p in (ch.get("rel", {}) as Dictionary):
		if float(ch["rel"][p]) <= -t.result_rel_min:
			return true
	return Followers.choice_buzz(ch, t) <= -t.result_followers_min


## The stakes chips for a choice card: [{kind, label, icon, dir, value}], dir
## 1 = gain, -1 = loss, 0 = both; value = exact text ("+5", "$50K") or "" (mixed,
## or hidden on a risky choice). Kinds, in order: football (football stats,
## skill points, recruiting / draft / pro standing, game-day modifiers), life,
## personality, grades, relationships (one per person), money, fans, conduct.
static func stakes(c: CareerData, ch: Dictionary, imp: String, t: CareerTuning) -> Array:
	var hide := is_risky(ch, imp, t)
	var out: Array = []
	var pv := CareerStats.preview(c, scaled_stats(ch.get("stats", {}), t, imp), t)
	# Football: attribute changes, skill points, progress and game-day modifiers.
	var fb: Array = []
	for k in pv.get(CareerData.FOOTBALL, {}):
		fb.append(float(pv[CareerData.FOOTBALL][k]))
	var sp := roundi(float(ch.get("skill_points", 0)) * t.sp_scenario_scale)
	if sp != 0:
		fb.append(float(sp))
	var prog := progress_changes(ch, t)
	for k in ["recruiting", "draft", "retention"]:
		if prog.has(k):
			fb.append(float(prog[k]))
	for m in ch.get("modifiers", []):
		var fx: Dictionary = CareerContent.modifier(str(m)).get("effects", {})
		if not fx.is_empty():
			fb.append(1.0 if KickProfile.net_good(fx) else -1.0)
	_add_stake(out, "football", "Football", "ball", fb, "", hide)
	for g in [CareerData.LIFE, CareerData.PERSONALITY]:
		var vals: Array = []
		var sum := 0.0
		for k in pv.get(g, {}):
			vals.append(float(pv[g][k]))
			sum += float(pv[g][k])
		var single := vals.size() == 1
		_add_stake(out, g, "Life" if g == CareerData.LIFE else "Personality",
			"health" if g == CareerData.LIFE else "charisma", vals, ("%+d" % roundi(sum)) if single else "", hide)
	if prog.has("grades"):
		_add_stake(out, "grades", "Grades", "book", [float(prog["grades"])], "%+.2f GPA" % float(prog["grades"]), hide)
	var rel: Dictionary = ch.get("rel", {})
	for p in rel:
		var d := float(rel[p])
		if absf(d) < 0.5:
			continue
		_add_stake(out, "rel", Relationships.name_of(c, str(p)),
			str(Relationships.def(str(p)).get("icon", "social")), [d], "%+d" % roundi(d), hide)
	var money := Savings.preview(c, ch)
	if money != 0:
		_add_stake(out, "money", "Money", "money", [float(money)],
			("+" if money > 0 else "−") + Savings.text(absi(money)), hide)
	var fans := Followers.choice_preview(c, ch, t)
	if fans != 0:
		_add_stake(out, "fans", "Fans", "social", [float(fans)],
			("+" if fans > 0 else "−") + Followers.round_count(absi(fans)), hide)
	var cond: Array = []
	match str(ch.get("conduct", "")):
		"good":
			cond.append(1.0)
		"bad", "scandal":
			cond.append(-1.0)
	if ch.has("suspend_weeks"):
		cond.append(-1.0)
	var flags: Dictionary = ch.get("set_flags", {})
	if bool(flags.get(Reputation.CONCERNS, false)):
		cond.append(-1.0)
	if bool(flags.get(Reputation.REBUILT, false)):
		cond.append(1.0)
	_add_stake(out, "conduct", "Conduct", "resilience", cond, "", true)
	return out


static func _add_stake(out: Array, kind: String, label: String, icon: String, vals: Array, exact: String,
		hide: bool) -> void:
	var up := vals.any(func(v: Variant) -> bool: return float(v) > 0.0)
	var down := vals.any(func(v: Variant) -> bool: return float(v) < 0.0)
	if not up and not down:
		return
	var dir := 0 if (up and down) else (1 if up else -1)
	out.append({"kind": kind, "label": label, "icon": icon, "dir": dir,
		"value": "" if (hide or dir == 0) else exact.replace("-", "\u2212")})


## Remembers a choice: the Hub's "Recent choices" (CareerData.choice_log, newest
## last, choice_log_size kept) and, for each flag it sets and its follow-up,
## where it came from (CareerData.choice_sources: the "Because you..." line).
static func _remember(c: CareerData, s: Dictionary, ch: Dictionary, out: Dictionary, vars: Dictionary,
		t: CareerTuning) -> void:
	c.choice_sources.erase("@" + str(s.get("id", "")))  # this follow-up has fired
	var title := CareerContent.fill(str(s.get("title", "")), vars)
	var label := CareerContent.fill(str(ch.get("label", "")), vars)
	var applied: Dictionary = (out.get("applied", {}) as Dictionary).duplicate(true)
	applied.erase("new_traits")
	c.choice_log.append({"id": str(s.get("id", "")), "title": title, "label": label,
		"result": CareerContent.fill(str(ch.get("result", "")), vars), "stage": c.stage,
		"season": c.season, "week": c.week, "phase": c.phase, "impact": str(out.get("impact", "normal")),
		"shown": not (out.get("reasons", []) as Array).is_empty(), "applied": applied,
		"rel": (out.get("relationships", {}) as Dictionary).duplicate(), "money": int(out.get("money", 0)),
		"followers": int(out.get("followers", 0)), "skill_points": int(out.get("skill_points", 0))})
	while c.choice_log.size() > maxi(t.choice_log_size, 1):
		c.choice_log.pop_front()
	var src := {"title": title, "label": label, "callback": CareerContent.fill(str(ch.get("callback", "")), vars),
		"week_index": c.week_index}
	var flags: Dictionary = ch.get("set_flags", {})
	for f in flags:
		if flags[f] is bool and not flags[f]:
			c.choice_sources.erase(str(f))
		else:
			c.choice_sources[str(f)] = src.duplicate()
	if str(out.get("follow_up", "")) != "":
		c.choice_sources["@" + str(out["follow_up"])] = src.duplicate()


## The "Because you..." line for a scene that fires from an earlier choice: a
## follow-up of that choice, or a scene that requires a flag it set (requires
## flags / any_flags, also inside any_of). The most recent matching choice
## wins. Its "callback" text ("put homework first") reads "Because you put
## homework first."; without one: Because you chose "Finish the assignment
## first" in Homework or the Field. "" = no earlier choice behind it.
static func because(c: CareerData, s: Dictionary) -> String:
	var keys: Array = ["@" + str(s.get("id", ""))]
	_flag_keys(s.get("requires", {}), keys)
	var best: Dictionary = {}
	for k in keys:
		var src: Variant = c.choice_sources.get(str(k))
		if src is Dictionary and c.flags.get(str(k), true) and (best.is_empty()
				or int(src.get("week_index", 0)) > int(best.get("week_index", 0))):
			best = src
	if best.is_empty():
		return ""
	var cb := str(best.get("callback", "")).strip_edges().trim_suffix(".")
	if cb != "":
		return "Because you %s." % cb
	return "Because you chose \"%s\" in %s." % [str(best.get("label", "")), str(best.get("title", ""))]


static func _flag_keys(req: Variant, keys: Array) -> void:
	if not (req is Dictionary):
		return
	for f in req.get("flags", []) + req.get("any_flags", []):
		if not (str(f) in keys):
			keys.append(str(f))
	for r in req.get("any_of", []):
		_flag_keys(r, keys)


## A choice's progression changes: {"recruiting": 4, "grades": 0.2, ...},
## recruiting and draft points scaled by scenario_recruiting_scale /
## scenario_draft_scale (CareerTuning: the story's many recruiting and draft
## choices add up over a career).
static func progress_changes(ch: Dictionary, t: CareerTuning = null) -> Dictionary:
	if t == null:
		t = CareerTuning.get_default()
	var out := {}
	for k in PROGRESS_KEYS:
		if ch.has(k) and float(ch[k]) != 0.0:
			var v := float(ch[k])
			if k == "recruiting":
				v *= t.scenario_recruiting_scale
			elif k == "draft":
				v *= t.scenario_draft_scale
			out[k] = v
	return out

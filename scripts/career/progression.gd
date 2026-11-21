class_name Progression
extends RefCounted
## Career progression rules: recruiting, academics, college offers, the draft,
## pro contracts, poor seasons, and what each stage's games look like.
## Pure logic over CareerData; CareerManager decides when to call it.
## Tables live in data/career/progression.json, weights in CareerTuning
## ("Academics", "Recruiting", "Draft", "Pro Contracts", "Career End",
## "Stage Difficulty").

const OFFER_FULL := "full"
const OFFER_PARTIAL := "partial"
const OFFER_WALK_ON := "walk_on"
const OFFER_NAMES := {"full": "Full scholarship", "partial": "Partial scholarship",
	"walk_on": "Preferred walk-on"}
const TIERS := ["top", "mid", "small"]


static func rules() -> Dictionary:
	return CareerContent.progression()


static func tier(id: String) -> Dictionary:
	if id == "juco":
		return rules().get("juco", {})
	return rules().get("college_tiers", {}).get(id, {})


# --- season numbers -----------------------------------------------------------------

static func fg_pct(stats: Dictionary) -> float:
	var att := int(stats.get("fg_att", 0))
	return float(stats.get("fg_made", 0)) / att if att > 0 else 0.0


## Sum of a "recruiting" / "draft" / "retention" bonus over the unlocked traits.
static func trait_bonus(c: CareerData, key: String) -> float:
	var b := 0.0
	for id in c.traits:
		b += float(CareerContent.trait_def(str(id)).get("passive", {}).get(key, 0.0))
	return b


## A season with a bad field goal percentage (enough attempts to count).
static func is_poor_season(c: CareerData, t: CareerTuning) -> bool:
	var s := c.season_stats
	return int(s.get("fg_att", 0)) >= t.poor_min_attempts and fg_pct(s) < t.poor_fg_pct


static func _leg(c: CareerData) -> float:
	return (c.stat("power") + c.stat("accuracy")) * 0.5


## Recruiting points earned by this high school / junior college season.
static func recruiting_gain(c: CareerData, t: CareerTuning) -> float:
	var s := c.season_stats
	var w := t.juco_recruiting_weight if c.stage == CareerData.STAGE_JUCO else \
		float(t.recruiting_season_weights[clampi(c.season_in_stage - 1, 0, t.recruiting_season_weights.size() - 1)])
	var pct := (fg_pct(s) - 0.65) * 100.0 if int(s.get("fg_att", 0)) > 0 else -5.0
	var g := t.recruiting_base + t.recruiting_fg_pct * pct \
		+ t.recruiting_long * maxf(float(s.get("long", 0)) - 35.0, 0.0) \
		+ t.recruiting_record * (int(c.record["w"]) - int(c.record["l"])) \
		+ t.recruiting_leg * (_leg(c) - 50.0) \
		+ t.recruiting_range * maxf(KickRange.fg_range(c, t) - t.recruiting_range_from, 0.0)
	return w * g + trait_bonus(c, "recruiting") + coach_rec(c, t)


## The coach's recommendation (relationship), final HS / junior college season only.
static func coach_rec(c: CareerData, t: CareerTuning) -> float:
	var final := (c.stage == CareerData.STAGE_HIGH_SCHOOL and c.season_in_stage >= t.high_school_seasons) \
		or (c.stage == CareerData.STAGE_JUCO and c.season_in_stage >= t.juco_seasons)
	return Relationships.coach_recommendation(c, t) if final else 0.0


## Draft points earned by this college season (times the school's exposure).
static func draft_gain(c: CareerData, t: CareerTuning) -> float:
	var s := c.season_stats
	var w := float(t.draft_season_weights[clampi(c.season_in_stage - 1, 0, t.draft_season_weights.size() - 1)])
	var pct := (fg_pct(s) - 0.7) * 100.0 if int(s.get("fg_att", 0)) > 0 else -5.0
	var g := t.draft_base + t.draft_fg_pct * pct \
		+ t.draft_long * maxf(float(s.get("long", 0)) - 40.0, 0.0) \
		+ t.draft_record * (int(c.record["w"]) - int(c.record["l"])) \
		+ t.draft_leg * (_leg(c) - t.draft_leg_from) \
		+ t.draft_range * maxf(KickRange.fg_range(c, t) - t.draft_range_from, 0.0)
	var exposure := float(tier(str(c.team.get("tier", "mid"))).get("exposure", 1.0))
	return w * g * exposure + trait_bonus(c, "draft") + Relationships.draft_recommendation(c, t)


## Pro retention (0-100) for the season just played.
static func retention(c: CareerData, t: CareerTuning) -> float:
	var s := c.season_stats
	var pct := (fg_pct(s) - t.retention_fg_ref) * 100.0 if int(s.get("fg_att", 0)) > 0 else 0.0
	var r := 50.0 + t.retention_fg_pct * pct \
		+ t.retention_long * maxf(float(s.get("long", 0)) - 45.0, 0.0) \
		+ t.retention_clutch * int(s.get("game_winners", 0)) \
		- t.retention_age * maxf(float(c.age) - 32.0, 0.0) \
		+ t.retention_range * maxf(KickRange.fg_range(c, t) - t.retention_range_from, 0.0) \
		+ c.retention_bonus + trait_bonus(c, "retention") + Reputation.retention_adjust(c, t)
	return clampf(r, 0.0, 100.0)


## End-of-season GPA drift from Intelligence.
static func gpa_drift(c: CareerData, t: CareerTuning) -> float:
	return t.gpa_intelligence_drift * (c.stat("intelligence") - 50.0) / 50.0 \
		+ Relationships.teacher_gpa(c, t)


# --- offers -------------------------------------------------------------------------

## Array.shuffle() uses the global RNG; this one uses the career's seeded rng,
## so the balance simulator gives the same results for the same seed.
static func shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


## Offer type a tier would make at this recruiting score ("" = none).
static func offer_type(score: float, tier_id: String) -> String:
	var tr := tier(tier_id)
	var o: Dictionary = rules().get("offers", {})
	var margin := score - float(tr.get("min_recruiting", 100))
	if margin >= float(o.get("full_margin", 12)):
		return OFFER_FULL
	if margin >= 0.0:
		return OFFER_PARTIAL
	if margin >= float(o.get("walk_on_margin", -12)):
		return OFFER_WALK_ON
	return ""


## A teacher who vouches for you (relationship) adds a little grace.
static func gpa_ok(c: CareerData, tier_id: String) -> bool:
	return c.gpa + Relationships.teacher_grace(c, CareerTuning.get_default()) \
		>= float(tier(tier_id).get("min_gpa", 0.0))


## Adds this season's new offers (and withdraws ones you've fallen far below).
## Returns {"new": [offers], "rescinded": [offers], "blocked_by_gpa": [tier ids]}.
static func update_offers(c: CareerData, rng: RandomNumberGenerator) -> Dictionary:
	var o: Dictionary = rules().get("offers", {})
	var out := {"new": [], "rescinded": [], "blocked_by_gpa": []}
	for off in c.offers.duplicate():
		var margin := c.recruiting_score - float(tier(str(off["tier"])).get("min_recruiting", 0))
		if margin < float(o.get("rescind_margin", -15)) or not gpa_ok(c, str(off["tier"])):
			c.offers.erase(off)
			out["rescinded"].append(off)
	var limits: Array = o.get("max_new_by_season", [0, 1, 2, 4, 4])
	var max_new := int(o.get("juco_max_new", 4)) if c.stage == CareerData.STAGE_JUCO else \
		int(limits[clampi(c.season_in_stage, 0, limits.size() - 1)])
	var have := {}
	for off in c.offers:
		have[str(off["school"])] = true
	for tier_id in TIERS:
		if out["new"].size() >= max_new:
			break
		var kind := offer_type(c.recruiting_score, tier_id)
		if kind == "":
			continue
		if not gpa_ok(c, tier_id):
			out["blocked_by_gpa"].append(tier_id)
			continue
		var schools := CareerContent.colleges().filter(func(s: Dictionary) -> bool:
			return s.get("tier", "") == tier_id and not have.has(str(s["id"])))
		# The most interested schools offer first (school_interest), so the
		# Recruiting screen's order and the offers agree. The shuffle only
		# breaks ties.
		shuffle(schools, rng)
		var interest := {}
		for s in schools:
			interest[str(s["id"])] = school_interest(c, s)
		schools.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return float(interest[str(a["id"])]) > float(interest[str(b["id"])]))
		for s in schools.slice(0, mini(int(o.get("per_tier", 2)), max_new - out["new"].size())):
			var off := {"school": str(s["id"]), "name": str(s["name"]), "tier": tier_id, "type": kind,
				"season": c.season}
			c.offers.append(off)
			out["new"].append(off)
			have[str(s["id"])] = true
	# Best offers first.
	c.offers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return offer_rank(a) > offer_rank(b))
	return out


## How interested a college is in you, 0-100 (Recruiting screen; also which
## school in a tier makes that tier's offer). 50 is where its tier starts
## offering (offer_type: recruiting points == the tier's minimum), about +/- 2.5
## per recruiting point near there (leveling off toward 6..94), plus a fixed
## per-school lean (-6..+6, from the school and the career) so schools in a
## tier differ. An offer keeps a school at least at
## the matching interest; a GPA below the tier's minimum caps it (they can't
## offer). Computed, never saved.
static func school_interest(c: CareerData, school: Dictionary) -> float:
	var tier_id := str(school.get("tier", "small"))
	var margin := c.recruiting_score - float(tier(tier_id).get("min_recruiting", 100))
	# About 2.5 per point near the bar, leveling off toward 94 far above or 6
	# far below it, so the per-school lean always separates schools in a tier
	# (no ties at a cap).
	var v := 50.0 + 44.0 * tanh(margin / 18.0) + school_lean(c, str(school.get("id", "")))
	var off := {}
	for o in c.offers:
		if str(o.get("school", "")) == str(school.get("id", "")):
			off = o
	if not off.is_empty():
		v = maxf(v, {"full": 85.0, "partial": 65.0, "walk_on": 45.0}.get(str(off.get("type", "")), 45.0))
	elif not gpa_ok(c, tier_id):
		v = minf(v, 35.0)
	return clampf(v, 0.0, 100.0)


## A school's fixed lean toward this career, -6..+6.
static func school_lean(c: CareerData, school_id: String) -> float:
	return float(absi(hash("%s|%d" % [school_id, c.created])) % 13) - 6.0


static func offer_rank(off: Dictionary) -> int:
	var t := 3 - TIERS.find(str(off.get("tier", "small")))
	var k: int = {"full": 3, "partial": 2, "walk_on": 1}.get(str(off.get("type", "")), 0)
	return t * 10 + k


## Fallbacks when choosing a college: walk-on tryouts at schools that didn't
## offer (GPA permitting), and junior college. Empty when the career is over.
static func fallback_options(c: CareerData, t: CareerTuning) -> Array:
	var out: Array = []
	if c.poor_streak >= t.career_end_poor_streak and c.offers.is_empty():
		return out
	var offered := {}
	for off in c.offers:
		offered[str(off["school"])] = true
	for tier_id in ["mid", "small"]:
		if not gpa_ok(c, tier_id):
			continue
		var schools := CareerContent.colleges().filter(func(s: Dictionary) -> bool:
			return s.get("tier", "") == tier_id and not offered.has(str(s["id"])) \
				and not (str(s["id"]) in c.flags.get("failed_tryouts", [])))
		if not schools.is_empty():
			var s: Dictionary = schools[0]
			out.append({"kind": "walk_on_tryout", "school": str(s["id"]), "name": str(s["name"]), "tier": tier_id})
	if c.stage == CareerData.STAGE_HIGH_SCHOOL:
		out.append({"kind": "juco"})
	return out


# --- draft and contracts ----------------------------------------------------------

## {round (0 = undrafted), kind: drafted / camp / open, team, team_name}.
static func draft(c: CareerData, rng: RandomNumberGenerator) -> Dictionary:
	var d: Dictionary = rules().get("draft", {})
	var clubs := CareerContent.pro_clubs()
	var club: Dictionary = clubs[rng.randi_range(0, clubs.size() - 1)]
	# Character on draft day (Reputation): concerns cost stock; rebuilt clears it.
	var adj := Reputation.draft_adjust(c, CareerTuning.get_default())
	var score := c.draft_score + adj
	var out := {"round": 0, "kind": "open", "team": str(club["id"]), "team_name": str(club["name"]),
		"character": adj, "character_state": Reputation.state(c)}
	for r in d.get("rounds", []):
		if score >= float(r["min"]):
			out["round"] = int(r["round"])
			out["kind"] = "drafted"
			return out
	if score >= float(d.get("udfa_min", 45)):
		out["kind"] = "camp"
	return out


## A contract dict: {team, team_name, years_left, salary, how}.
static func contract(team_id: String, how: String, round_n: int = 0, years := 0, salary := 0) -> Dictionary:
	var k: Dictionary = rules().get("contracts", {})
	var club := CareerContent.team_by_id(team_id)
	match how:
		"drafted":
			years = int(k.get("rookie_years", {}).get(str(round_n), 3))
			salary = int(k.get("rookie_salary", {}).get(str(round_n), 800000))
		"camp":
			years = int(k.get("camp_years", 2))
			salary = int(k.get("min_salary", 750000))
		"free_agent":
			years = int(k.get("free_agent_years", 1))
			salary = int(k.get("min_salary", 750000))
	return {"team": team_id, "team_name": str(club.get("name", team_id)), "years_left": years,
		"salary": salary, "how": how}


## Re-sign offer at the end of a contract: {years, salary}.
static func resign_offer(score: float, rng: RandomNumberGenerator) -> Dictionary:
	var k: Dictionary = rules().get("contracts", {})
	var yrs: Array = k.get("resign_years", [1, 3])
	return {"years": rng.randi_range(int(yrs[0]), int(yrs[1])),
		"salary": int(float(k.get("resign_salary_base", 800000)) + float(k.get("resign_salary_per_point", 40000)) * maxf(score - 50.0, 0.0))}


static func money(n: int) -> String:
	if n >= 1000000:
		return "$%.2fM" % (n / 1000000.0)
	return "$%dK" % roundi(n / 1000.0)


# --- teams and games ------------------------------------------------------------------

## A team dict for CareerData.team / opponents from any world.json entry.
static func team_from(s: Dictionary, level: String) -> Dictionary:
	var out := {"id": s.get("id", ""), "name": s.get("name", "Team"), "mascot": s.get("mascot", ""),
		"short": s.get("short", "???"), "town": s.get("town", ""),
		"colors": s.get("colors", ["#1f3a8a", "#f2b632"]), "strength": float(s.get("strength", 50)),
		"tier": s.get("tier", ""), "level": level}
	# Optional (story data): stadium capacity and name (Stadiums).
	for k in ["capacity", "stadium"]:
		if s.has(k):
			out[k] = s[k]
	return out


## Who you can play this stage.
static func opponents(c: CareerData) -> Array:
	var pool: Array
	match c.stage:
		CareerData.STAGE_COLLEGE:
			# Mostly your own tier, a few from the others.
			pool = CareerContent.colleges()
		CareerData.STAGE_JUCO:
			pool = CareerContent.jucos()
		CareerData.STAGE_PRO:
			pool = CareerContent.pro_clubs()
		_:
			pool = CareerContent.high_schools()
	return pool.filter(func(s: Dictionary) -> bool: return s.get("id", "") != c.team.get("id", ""))


## Game parameters for this stage (and college tier):
## {fg_min, fg_max, pat, pressure_bonus, wind_max, posts, width,
##  kickoff_spot, touchback_spot, kickoff_oob_spot}.
static func game_params(c: CareerData, t: CareerTuning) -> Dictionary:
	var p := {"fg_min": t.hs_fg_min_yards, "fg_max": t.hs_fg_max_yards, "pat": t.hs_pat_yards,
		"pressure_bonus": 0.0, "wind_max": t.game_wind_max_mph, "posts": "high_school",
		"width": t.goal_width_high_school}
	match c.stage:
		CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO:
			var tr := tier(str(c.team.get("tier", "juco")) if c.stage == CareerData.STAGE_COLLEGE else "juco")
			p = {"fg_min": t.college_fg_min_yards,
				"fg_max": mini(t.college_fg_max_yards, int(tr.get("fg_max_yards", t.college_fg_max_yards))),
				"pat": t.college_pat_yards, "pressure_bonus": t.college_pressure_bonus + float(tr.get("pressure_bonus", 0.0)),
				"wind_max": t.college_wind_max_mph, "posts": "college", "width": t.goal_width_college}
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			p = {"fg_min": t.pro_fg_min_yards, "fg_max": t.pro_fg_max_yards, "pat": t.pro_pat_yards,
				"pressure_bonus": t.pro_pressure_bonus, "wind_max": t.pro_wind_max_mph, "posts": "pro",
				"width": t.goal_width_pro}
	# Overtime rules (GameSim): high school (Kansas plan), college, pro.
	p["ot"] = "pro" if c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] else \
		("college" if c.stage in [CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO] else "hs")
	# Kickoff rules for this stage (KickoffRules, built by CareerGameMode).
	match c.stage:
		CareerData.STAGE_COLLEGE, CareerData.STAGE_JUCO:
			p.merge({"kickoff_spot": t.kickoff_spot_yards_college, "touchback_spot": t.touchback_spot_college,
				"kickoff_oob_spot": t.kickoff_oob_spot_college})
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT:
			p.merge({"kickoff_spot": t.kickoff_spot_yards_pro, "touchback_spot": t.touchback_spot_pro,
				"kickoff_oob_spot": t.kickoff_oob_spot_pro})
		_:
			p.merge({"kickoff_spot": t.kickoff_spot_yards, "touchback_spot": t.touchback_spot_hs,
				"kickoff_oob_spot": t.kickoff_oob_spot_hs})
	return p


## The kick scene's look for a game: posts style/width/colors and uniforms
## (see field_goal_game.gd set_look()).
static func look(stage_posts: String, width: float, team: Dictionary, opponent: Dictionary) -> Dictionary:
	var home: Array = team.get("colors", ["#1f3a8a", "#f2b632"])
	var away: Array = opponent.get("colors", ["#a4161a", "#111111"])
	return {"posts": stage_posts, "width": width,
		"accent": Color.from_string(str(home[0]), Color.NAVY_BLUE),
		"accent2": Color.from_string(str(home[1]), Color.GOLD),
		"home": [Color.from_string(str(home[0]), Color.NAVY_BLUE), Color.from_string(str(home[1]), Color.GOLD)],
		"away": [Color.from_string(str(away[0]), Color.DARK_RED), Color.from_string(str(away[1]), Color.BLACK)]}

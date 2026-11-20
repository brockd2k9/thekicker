class_name Followers
extends RefCounted
## Social media followers: a real follower count (CareerData.followers) that
## grows with good kicks, game winners, perfect games, good seasons, viral
## moments, winning the bench audition and scenario choices (posting, charity,
## media, helping teammates, good conduct), and shrinks with bad conduct,
## scandals, a missed game winner and being benched. Never below 0.
##
## Players only ever see real counts ("+120 followers", "2.4K followers",
## "Hometown Hero"). Internally an event is worth some "buzz", and the stage
## turns buzz into followers (CareerTuning followers_per_buzz_*): the same moment
## is a few dozen followers in high school and thousands in the pros. A
## scenario choice's "followers" field is buzz; "followers_exact" is a raw count.
##
## Tiers (CareerTuning.follower_tiers) unlock scenarios (requires.followers_tier
## / max_followers_tier) and give small, capped effects: skill points and Team
## the first time you reach a tier, Fun / Social in a big week, a season-end
## progress bonus, pro salary, a little pressure in close 4th quarters (fans
## are watching), and brand deals (a choice's "deal").
## Numbers: CareerTuning "Followers". State: CareerData.followers / social.

const TIER_IDS := ["local", "hometown_hero", "rising_star", "campus_celebrity", "verified",
	"fan_favorite", "household_name"]
const TIER_NAMES := ["Local Name", "Hometown Hero", "Rising Star", "Campus Celebrity", "Verified",
	"Fan Favorite", "Household Name"]
const RISING_STAR := 2
## Skill point sources (SkillPoints.earn text; the simulator's SP-by-source report).
const SP_TIER := "Follower milestone"
const SP_DEAL := "Brand deal"
const DEAL_KINDS := ["sp", "range", "fun"]

## Dev hooks for the balance simulator (never set in the game):
## effects_off: followers still count, but give nothing (tier rewards, weekly
## Fun / Social, progress bonus, salary, fan pressure, deals).
static var effects_off := false
## Extra buzz on every scenario choice, standing in for the story session's
## followers / conduct tags until they exist (estimates only).
static var sim_choice_buzz := 0.0


# --- counts and tiers ----------------------------------------------------------------

static func count(c: CareerData) -> int:
	return c.followers


static func tier_of(n: int, t: CareerTuning) -> int:
	var tier := 0
	for i in t.follower_tiers.size():
		if n >= t.follower_tiers[i]:
			tier = i
	return mini(tier, TIER_IDS.size() - 1)


static func tier(c: CareerData, t: CareerTuning) -> int:
	return tier_of(c.followers, t)


static func tier_index(id: String) -> int:
	return TIER_IDS.find(id)


static func tier_name(i: int) -> String:
	return TIER_NAMES[clampi(i, 0, TIER_NAMES.size() - 1)]


## Followers needed for tier i.
static func threshold(i: int, t: CareerTuning) -> int:
	return t.follower_tiers[clampi(i, 0, t.follower_tiers.size() - 1)]


## "Rising Star (5K followers)".
static func tier_label(i: int, t: CareerTuning) -> String:
	return "%s (%s followers)" % [tier_name(i), round_count(threshold(i, t))]


## A round number the short way: 500, 5K, 25K, 2M.
static func round_count(n: int) -> String:
	if n >= 1000000 and n % 100000 == 0:
		return ("%.1fM" % (n / 1000000.0)).replace(".0M", "M")
	if n >= 1000 and n % 100 == 0:
		return ("%.1fK" % (n / 1000.0)).replace(".0K", "K")
	return short(n)


## Display count: exact under 10,000 ("950", "2,400"), then "12.5K" / "85K" /
## "340K", then "1.2M".
static func short(n: int) -> String:
	var a := absi(n)
	var s := ""
	if a < 10000:
		s = _commas(a)
	elif a < 1000000:
		s = ("%.1fK" % (a / 1000.0)).replace(".0K", "K") if a < 100000 else "%dK" % floori(a / 1000.0)
	else:
		s = ("%.1fM" % (a / 1000000.0)).replace(".0M", "M")
	return ("-" if n < 0 else "") + s


## "+120 followers" / "-3,400 followers".
static func change_text(n: int) -> String:
	return "%s%s follower%s" % ["+" if n >= 0 else "-", short(absi(n)), "" if absi(n) == 1 else "s"]


static func _commas(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out


# --- buzz -> followers -----------------------------------------------------------------

## Followers per buzz at this stage.
static func per_buzz(c: CareerData, t: CareerTuning) -> float:
	match c.stage:
		CareerData.STAGE_JUCO:
			return t.followers_per_buzz_juco
		CareerData.STAGE_COLLEGE:
			return t.followers_per_buzz_college
		CareerData.STAGE_FREE_AGENT:
			return t.followers_per_buzz_free_agent
		CareerData.STAGE_PRO, CareerData.STAGE_RETIRED:
			return t.followers_per_buzz_pro
	return t.followers_per_buzz_hs


## Followers from `buzz` (gains get the Charisma bonus).
static func from_buzz(c: CareerData, buzz: float, t: CareerTuning) -> int:
	var n := buzz * per_buzz(c, t)
	if buzz > 0.0:
		n *= 1.0 + t.buzz_charisma_bonus * c.stat("charisma") / 100.0
	return roundi(n)


## Adds `buzz` worth of followers under `text`. Returns the change.
static func gain(c: CareerData, buzz: float, text: String, t: CareerTuning) -> int:
	if is_zero_approx(buzz):
		return 0
	return add(c, from_buzz(c, buzz, t), text, t, buzz)


## Adds a raw follower change (never below 0) and its line for this week's
## Results, the season's sources, the peak, and a new tier's rewards.
## buzz: the buzz behind it (for the week's Fun / Social); 0 for exact counts
## (worked out from the count).
static func add(c: CareerData, n: int, text: String, t: CareerTuning, buzz := 0.0) -> int:
	n = maxi(n, -c.followers)
	if n == 0:
		return 0
	if is_zero_approx(buzz):
		buzz = n / maxf(per_buzz(c, t), 1.0)
	c.followers += n
	var s := c.social
	s["peak"] = maxi(int(s.get("peak", 0)), c.followers)
	s["season_gain"] = int(s.get("season_gain", 0)) + n
	var src: Dictionary = s.get("season_sources", {})
	src[text] = int(src.get(text, 0)) + n
	s["season_sources"] = src
	var week: Array = s.get("week", [])
	var found := false
	for e in week:
		if str(e.get("text", "")) == text:
			e["n"] = int(e.get("n", 0)) + n
			e["buzz"] = float(e.get("buzz", 0.0)) + buzz
			found = true
	if not found:
		week.append({"text": text, "n": n, "buzz": buzz})
	s["week"] = week
	_check_tier(c, t)
	return n


## The first time at a tier: a notice, skill points (capped a season) and Team.
static func _check_tier(c: CareerData, t: CareerTuning) -> void:
	var now := tier(c, t)
	var best := int(c.social.get("best_tier", 0))
	if now <= best:
		return
	c.social["best_tier"] = now
	if effects_off:
		return
	var sp := 0
	for i in now - best:
		sp += t.tier_up_sp
	sp = _sp_room(c, sp, t)
	SkillPoints.earn(c, sp, SP_TIER)
	c.social["sp_season"] = int(c.social.get("sp_season", 0)) + sp
	if c.people.has(Relationships.TEAM):
		Relationships.apply(c, {Relationships.TEAM: t.tier_up_team * (now - best)})
	_notice(c, "New follower milestone: %s, %s followers.%s" % [tier_name(now), short(c.followers),
		(" Sponsors send gear: +%d skill points." % sp) if sp > 0 else ""])


static func _sp_room(c: CareerData, sp: int, t: CareerTuning) -> int:
	return clampi(sp, 0, maxi(t.followers_sp_season_cap - int(c.social.get("sp_season", 0)), 0))


static func _notice(c: CareerData, text: String) -> void:
	c.notice = text if c.notice == "" else c.notice + " " + text


## This week's follower lines for Results: [{text, n}].
static func week_lines(c: CareerData) -> Array:
	return c.social.get("week", [])


static func week_total(c: CareerData) -> int:
	var n := 0
	for e in week_lines(c):
		n += int(e.get("n", 0))
	return n


# --- games ----------------------------------------------------------------------------

## Followers from one finished game's kicks (yours; the backup's don't count).
## A made game winner or a very long make may go viral; a missed game winner
## may turn into a viral blooper (rare). Returns the change.
static func from_game(c: CareerData, kicks: Array, range: float, rng: RandomNumberGenerator,
		t: CareerTuning) -> int:
	var made := 0
	var long := 0
	var clutch := 0
	var winners := 0
	var missed_winner := false
	var att := 0
	var all_made := true
	var viral := {}
	for k in kicks:
		var kind := str(k.get("kind", ""))
		if not (kind in ["fg", "pat"]) or k.get("backup", false):
			continue
		att += 1
		var winner := "GAME WINNER" in str(k.get("label", ""))
		if not k.get("made", false):
			all_made = false
			if kind == "fg" and winner:
				missed_winner = true
			continue
		if kind != "fg":
			continue
		made += 1
		var yd := int(k.get("yards", 0))
		var buzz := t.buzz_make
		if yd >= t.long_make_yards or yd >= range - t.sp_long_range_yd:
			long += 1
			buzz += t.buzz_long_make
		if float(k.get("pressure", 0.0)) >= t.clutch_pressure:
			clutch += 1
			buzz += t.buzz_clutch_make
		if winner:
			winners += 1
			buzz += t.buzz_game_winner
		# One viral moment a game at most: the first that rolls it.
		if viral.is_empty():
			var chance := t.viral_chance_game_winner if winner else (t.viral_chance_long if yd >= t.viral_long_yards else 0.0)
			if chance > 0.0 and rng.randf() < chance:
				viral = {"yards": yd, "winner": winner, "buzz": buzz}
	var total := 0
	total += gain(c, made * t.buzz_make, "Field goals made", t)
	total += gain(c, long * t.buzz_long_make, "Long makes", t)
	total += gain(c, clutch * t.buzz_clutch_make, "Clutch makes", t)
	total += gain(c, winners * t.buzz_game_winner, "Game winner", t)
	if all_made and att >= 2:
		total += gain(c, t.buzz_perfect_game, "Perfect game", t)
	if not viral.is_empty():
		var what := "%d-yard %s" % [int(viral["yards"]), "game winner" if viral["winner"] else "field goal"]
		var n := gain(c, float(viral["buzz"]) * (t.viral_mult - 1.0), "Viral: your %s" % what, t)
		total += n
		c.social["virals"] = int(c.social.get("virals", 0)) + 1
		_notice(c, "VIRAL: your %s is all over social media. %s." % [what, change_text(n)])
	if missed_winner:
		var loss := t.buzz_missed_game_winner
		total += gain(c, loss, "Missed game winner", t)
		if rng.randf() < t.viral_miss_chance:
			var n := gain(c, loss * (t.viral_miss_mult - 1.0), "Your miss went viral", t)
			total += n
			_notice(c, "Your missed game winner is going around online. %s." % change_text(n))
	return total


# --- scenario choices --------------------------------------------------------------

## A choice's followers: "followers" (buzz, scaled by stage), "followers_exact"
## (a raw count) and "conduct" (good / bad / scandal), plus a brand "deal".
## Returns the change.
static func from_choice(c: CareerData, ch: Dictionary, t: CareerTuning) -> int:
	var total := 0
	if sim_choice_buzz != 0.0 and ch.has("label"):
		total += gain(c, sim_choice_buzz, "Choices (estimate)", t)
	var buzz := choice_buzz(ch, t)
	if not is_zero_approx(buzz):
		total += gain(c, buzz, "Choices", t)
	if ch.has("followers_exact"):
		total += add(c, int(ch["followers_exact"]), "Choices", t)
	if str(ch.get("conduct", "")) == "scandal":
		end_deals(c, "scandal")
	if ch.get("deal") is Dictionary and not effects_off:
		add_deal(c, ch["deal"], t)
	return total


## A choice's buzz: "followers" plus its conduct's.
static func choice_buzz(ch: Dictionary, t: CareerTuning) -> float:
	var buzz := float(ch.get("followers", 0.0))
	match str(ch.get("conduct", "")):
		"good":
			buzz += t.buzz_conduct_good
		"bad":
			buzz += t.buzz_conduct_bad
		"scandal":
			buzz += t.buzz_conduct_scandal
	return buzz


## What a choice would change, for the scenario card (the Charisma bonus included).
static func choice_preview(c: CareerData, ch: Dictionary, t: CareerTuning) -> int:
	var n := from_buzz(c, choice_buzz(ch, t), t) + int(ch.get("followers_exact", 0))
	return maxi(n, -c.followers)


# --- brand deals -------------------------------------------------------------------

## deal: {id, name, kind: sp / range / fun, value, seasons}. At most deals_max at
## once; the same deal again just renews it.
static func add_deal(c: CareerData, deal: Dictionary, t: CareerTuning) -> bool:
	var kind := str(deal.get("kind", ""))
	if not (kind in DEAL_KINDS):
		push_warning("Followers: unknown deal kind '%s'" % kind)
		return false
	var deals: Array = c.social.get("deals", [])
	var id := str(deal.get("id", ""))
	deals = deals.filter(func(d: Dictionary) -> bool: return str(d.get("id", "")) != id)
	if deals.size() >= t.deals_max:
		return false
	deals.append({"id": id, "name": str(deal.get("name", "a sponsor")), "kind": kind,
		"value": float(deal.get("value", 1.0)), "seasons_left": maxi(int(deal.get("seasons", 1)), 1)})
	c.social["deals"] = deals
	return true


static func deals(c: CareerData) -> Array:
	return c.social.get("deals", [])


## Ends every deal (a scandal, a new stage). why: "scandal" adds a notice.
static func end_deals(c: CareerData, why := "") -> void:
	if deals(c).is_empty():
		return
	if why == "scandal":
		_notice(c, "Your sponsors drop you: %s." % ", ".join(PackedStringArray(deals(c).map(
			func(d: Dictionary) -> String: return str(d.get("name", ""))))))
	c.social["deals"] = []


## Field goal range from "range" deals (KickRange adds it like a perk).
static func deal_yards(c: CareerData) -> float:
	var yd := 0.0
	for d in deals(c):
		if str(d.get("kind", "")) == "range":
			yd += float(d.get("value", 0.0))
	return yd


# --- the week and the season ------------------------------------------------------

## End of week (CareerManager.end_week): brand deals (skill points, Fun, an
## Energy cost), the week's Fun / Social from followers, then a fresh week.
## Returns the stat changes to apply.
static func end_week(c: CareerData, t: CareerTuning) -> Dictionary:
	var ch := {}
	for d in deals(c):
		ch["energy"] = float(ch.get("energy", 0.0)) + t.deal_energy_week
		match str(d.get("kind", "")):
			"fun":
				ch["fun"] = float(ch.get("fun", 0.0)) + float(d.get("value", 1.0))
			"sp":
				var sp := _sp_room(c, roundi(float(d.get("value", 1.0))), t)
				SkillPoints.earn(c, sp, SP_DEAL)
				c.social["sp_season"] = int(c.social.get("sp_season", 0)) + sp
	var buzz := 0.0
	for e in week_lines(c):
		buzz += float(e.get("buzz", 0.0))
	if effects_off:
		c.social["week"] = []
		return ch
	if buzz >= t.buzz_week_good:
		ch["fun"] = float(ch.get("fun", 0.0)) + t.followers_week_fun
		ch["social"] = float(ch.get("social", 0.0)) + t.followers_week_social
	elif buzz <= t.buzz_week_bad:
		ch["fun"] = float(ch.get("fun", 0.0)) + t.followers_week_bad_fun
	c.social["week"] = []
	return ch


## End of season (CareerManager.end_season): the season's buzz from FG%, and
## the progress bonus (recruiting / draft / retention points). Returns
## {"followers": change, "progress": bonus}.
static func season_end(c: CareerData, t: CareerTuning) -> Dictionary:
	var n := 0
	var s := c.season_stats
	if int(s.get("fg_att", 0)) >= t.poor_min_attempts:
		var pct := Progression.fg_pct(s)
		if pct >= t.sp_great_season_pct:
			n = gain(c, t.buzz_great_season, "Great season", t)
		elif pct >= t.sp_good_season_pct:
			n = gain(c, t.buzz_good_season, "Good season", t)
	return {"followers": n, "progress": progress_bonus(c, t)}


## Recruiting / draft / retention points from your following (small, capped).
static func progress_bonus(c: CareerData, t: CareerTuning) -> float:
	if effects_off:
		return 0.0
	var cap := t.followers_standing_cap if c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] \
		else t.followers_progress_cap
	return minf(maxf(tier(c, t) - 1, 0) * t.followers_progress_per_tier, cap)


## A new season: deals count down, the season's numbers start over.
static func new_season(c: CareerData) -> void:
	var left: Array = []
	for d in deals(c):
		d["seasons_left"] = int(d.get("seasons_left", 1)) - 1
		if int(d["seasons_left"]) > 0:
			left.append(d)
	c.social["deals"] = left
	c.social["season_gain"] = 0
	c.social["season_sources"] = {}
	c.social["sp_season"] = 0
	c.social["week"] = []


## Pro salary with the followers bump (+followers_salary_per_tier a tier, capped).
static func salary(c: CareerData, base: int, t: CareerTuning) -> int:
	return roundi(base * (1.0 + salary_bonus(c, t)))


static func salary_bonus(c: CareerData, t: CareerTuning) -> float:
	if effects_off:
		return 0.0
	return minf(tier(c, t) * t.followers_salary_per_tier, t.followers_salary_cap)


## Fans are watching: extra pressure on kicks in a close 4th quarter.
static func fan_pressure(c: CareerData, t: CareerTuning) -> float:
	if effects_off:
		return 0.0
	return minf(maxf(tier(c, t) - RISING_STAR, 0) * t.fan_pressure_per_tier, t.fan_pressure_cap)


# --- save migration ------------------------------------------------------------------

## Starting followers for a save from before followers (CareerSave, v6 -> 7).
static func migrate_start(stage: String, season_in_stage: int, pro_seasons: int, t: CareerTuning) -> int:
	match stage:
		CareerData.STAGE_JUCO:
			return t.followers_migrate_juco
		CareerData.STAGE_COLLEGE:
			return t.followers_migrate_college + t.followers_migrate_college_per_season * maxi(season_in_stage - 1, 0)
		CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT, CareerData.STAGE_RETIRED:
			return t.followers_migrate_pro + t.followers_migrate_pro_per_season * maxi(pro_seasons - 1, 0)
	return t.followers_migrate_hs + t.followers_migrate_hs_per_season * maxi(season_in_stage - 1, 0)

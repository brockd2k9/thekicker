class_name Reputation
extends RefCounted
## Character reputation (story flags the college "wrong path" sets) and
## suspensions (a choice's "suspend_weeks").
##
##   character_concerns  set by a bad choice after an earlier warning; a
##                       recovery scene can clear it (sets it to false).
##   rebuilt_reputation  set when the player earns their way back.
## Concerns cost draft stock on draft day (rep_concerns_draft) and standing in
## the first pro seasons (rep_concerns_retention). A rebuilt reputation clears
## the draft penalty (rep_rebuilt_draft, 0 = none) and adds a little early pro
## standing (rep_rebuilt_retention): the way back is clearly worth taking.
## Rebuilt wins when both flags are set.
##
## suspend_weeks: n (capped at suspend_max_weeks, 3; in the pros
## suspend_max_weeks_pro, a season; carried across seasons) on a choice: you sit out
## your next n games the way academic ineligibility does (CareerManager
## _bench_game): no kicks, no game skill points, no followers from kicks, and
## the weeks don't count toward benching or slumps. Practice still counts.
## Numbers: CareerTuning "Reputation". State: CareerData.flags, CareerData.suspension.

const CONCERNS := "character_concerns"
const REBUILT := "rebuilt_reputation"
## Story flag: dismissed from the team, carried out at season end (pros: a
## release; college: out of the program and the draft, to the open tryout).
const DISMISSED := "dismissed"


## What "dismissed" means for this player (Hub notice, season summary); ""
## where it does nothing (high school and junior college).
static func dismissed_text(c: CareerData) -> String:
	match c.stage:
		CareerData.STAGE_PRO:
			return "DISMISSED: the team will release you at the end of the season, however you kick."
		CareerData.STAGE_COLLEGE:
			return "DISMISSED: at the end of the season you leave the program, and you won't be drafted. " \
				+ "Your way back is an open tryout."
	return ""


## Dismissed and it will be carried out (college and the pros only).
static func is_dismissed(c: CareerData) -> bool:
	return bool(c.flags.get(DISMISSED, false)) and c.stage in [CareerData.STAGE_COLLEGE, CareerData.STAGE_PRO]

## Dev hook for the balance simulator: true = reputation and suspensions have
## no effect (before / after comparisons). Never set in the game.
static var off := false


## "concerns", "rebuilt" or "" (nothing on record).
static func state(c: CareerData) -> String:
	if bool(c.flags.get(REBUILT, false)):
		return "rebuilt"
	if bool(c.flags.get(CONCERNS, false)):
		return "concerns"
	return ""


## Draft stock added on draft day (negative = a penalty).
static func draft_adjust(c: CareerData, t: CareerTuning) -> float:
	if off:
		return 0.0
	match state(c):
		"concerns":
			return t.rep_concerns_draft
		"rebuilt":
			return t.rep_rebuilt_draft
	return 0.0


## Pro standing (retention) added in the first rep_pro_seasons pro seasons.
static func retention_adjust(c: CareerData, t: CareerTuning) -> float:
	if off:
		return 0.0
	var pro := c.history.filter(func(h: Dictionary) -> bool:
		return str(h.get("stage", "")) == CareerData.STAGE_PRO).size()
	if pro >= t.rep_pro_seasons:  # history doesn't hold this season yet
		return 0.0
	match state(c):
		"concerns":
			return t.rep_concerns_retention
		"rebuilt":
			return t.rep_rebuilt_retention
	return 0.0


## After a choice set flags: say what a reputation change means (Hub notice,
## and a line on this week's Results).
static func on_flags(c: CareerData, set_flags: Dictionary, t: CareerTuning) -> void:
	var text := ""
	if set_flags.get(DISMISSED, false):
		text = dismissed_text(c)
		if text != "":
			c.notice = text if c.notice == "" else c.notice + " " + text
		return
	if set_flags.get(REBUILT, false):
		text = "You've rebuilt your reputation. Scouts and teams notice: no character penalty on draft day%s." \
			% (", and a little extra standing early in the pros" if t.rep_rebuilt_retention > 0.0 else "")
	elif set_flags.has(CONCERNS) and not set_flags[CONCERNS]:
		text = "The character concerns are behind you: no draft-day penalty now."
	elif set_flags.get(CONCERNS, false):
		text = "Character concerns: scouts have heard. On draft day it costs you %d draft stock, and early pro " \
			% roundi(-t.rep_concerns_draft) + "standing takes a hit. Earn your way back to clear it."
	if text == "":
		return
	c.notice = text if c.notice == "" else c.notice + " " + text
	c.flags["reputation_week"] = c.week_index
	c.flags["reputation_text"] = text


## The reputation line for this week's Results ("" if nothing changed this week).
static func week_text(c: CareerData) -> String:
	if int(c.flags.get("reputation_week", -1)) != c.week_index:
		return ""
	return str(c.flags.get("reputation_text", ""))


# --- suspensions ------------------------------------------------------------------------

static func suspended(c: CareerData) -> bool:
	return not off and int(c.suspension.get("weeks_left", 0)) > 0


## A choice's suspend_weeks: sit out the next n games (capped). reason: shown
## in the notice ("The Balcony Dare").
static func suspend(c: CareerData, n: int, reason: String, t: CareerTuning) -> void:
	var cap := max_weeks(c, t)
	n = clampi(n, 0, cap)
	if n <= 0 or off:
		return
	var left := mini(int(c.suspension.get("weeks_left", 0)) + n, cap)
	c.suspension = {"weeks_left": left, "weeks": left, "reason": reason}
	c.suspensions_total += 1
	var text := "SUSPENDED for %d game%s%s. You sit out: no kicks, no game skill points (practice still counts)." \
		% [left, "" if left == 1 else "s", (" (%s)" % reason) if reason != "" else ""]
	c.notice = text if c.notice == "" else c.notice + " " + text


## The longest suspension at this stage: suspend_max_weeks (3), or
## suspend_max_weeks_pro (a season) in the pros.
static func max_weeks(c: CareerData, t: CareerTuning) -> int:
	return t.suspend_max_weeks_pro if c.stage in [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT] \
		else t.suspend_max_weeks


## One suspended game has been sat out. Returns the games left.
static func served(c: CareerData) -> int:
	var left := maxi(int(c.suspension.get("weeks_left", 0)) - 1, 0)
	c.suspension["weeks_left"] = left
	if left == 0:
		c.notice = "Your suspension is over: you're back on the field this week."
	return left

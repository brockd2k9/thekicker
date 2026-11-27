class_name DailyChallenge
extends RefCounted
## The Daily Challenge: one kick a day, a streak of successful days, and a
## weekly skill point payout. Pure rules + saved state (GameState owns one, saves it in
## the main save under "daily" and delivers rewards to the career).
##
## Day rules (DailyClock.day_number is the only definition of a day):
##   * one scenario per day (DailyScenario, seeded by the day), one attempt;
##     after a miss, ad_retries_per_day retries with a rewarded ad;
##   * success: the streak grows (or starts at 1) and the day is claimed right
##     away, in the same save as the result (claimed_days remembers every
##     claimed day). Days 1-6 of a week pay nothing; the success that completes
##     a week (every week_days-th day of the streak) pays the week's skill
##     points at once (payout_days: never twice). The week is the streak mod
##     week_days, so a payout starts the next week at day 1, a broken streak
##     resets it to 0 and the streak saver brings it back;
##   * a day without a success breaks the streak when the next day starts;
##     after exactly one missed day the streak saver can restore it (rewarded
##     ad, once per streak, only on the day you come back);
##   * a kick that was struck but never judged (app closed mid-flight) is a miss.
## Clock guard: the last time seen and the highest day seen are saved; a clock
## that steps back (now earlier than last seen, beyond a tolerance) is flagged,
## and while the day is earlier than a day already seen the challenge is
## locked (no kicks, no claims).
## Daily kicks never count in My Stats, career stats, records or achievements
## (GameState.UNRECORDED_MODES has &"daily").

signal changed

const MODE := &"daily"
const NO_DAY := -1000000
## Bounded history: claimed days and claim ids kept.
const KEEP_CLAIMS := 120

var tuning: DailyTuning
var clock: DateSource
var ads: AdService

# --- saved ---
var streak: int = 0
var longest: int = 0
var last_completed_day: int = NO_DAY
## Today's challenge: {day, tier, attempts, struck, result, retry_used,
## retry_ready, claimed, reward, sp_to}. result: "" / "missed" / "failed" / "success".
var today: Dictionary = {}
## Streak saver: offered {streak, day} after one missed day; used once per streak.
var saver_offer: Dictionary = {}
var saver_used: bool = false
var claimed_days: Array = []
## Days whose success completed a week and paid it (save v4).
var payout_days: Array = []
## Claimed skill points not yet in a career: [{id, sp, day}].
var pending: Array = []
## Totals: days played (at least one kick), days completed, kicks, makes,
## skill points earned, weeks completed.
var stats: Dictionary = {"played": 0, "completed": 0, "kicks": 0, "makes": 0, "sp": 0, "weeks": 0}
var last_seen_unix: int = 0
var max_day_seen: int = NO_DAY
## The day the "today's challenge" popup was last shown.
var popup_day: int = NO_DAY
## Debug builds: days added to the clock ("Advance day" on the Daily screen).
var debug_shift_days: int = 0

# --- not saved ---
## The clock went backward this session (shown on the Daily screen).
var clock_back := false
var _scenario: Dictionary = {}


func _init(t: DailyTuning = null, c: DateSource = null, a: AdService = null) -> void:
	tuning = t if t != null else DailyTuning.get_default()
	clock = c if c != null else DateSource.new()
	ads = a if a != null else AdService.create(tuning)


# --- time ---------------------------------------------------------------------------------

func now_unix() -> int:
	return clock.now_unix() + debug_shift_days * DailyClock.SECONDS_PER_DAY


func current_day() -> int:
	return DailyClock.day_number(now_unix(), clock.utc_offset_minutes(), tuning.day_start_hour)


func seconds_to_reset() -> int:
	return DailyClock.seconds_to_next_day(now_unix(), clock.utc_offset_minutes(), tuning.day_start_hour)


## The device clock is behind a day already played: nothing can be played or
## claimed until it catches up.
func is_locked() -> bool:
	return max_day_seen != NO_DAY and current_day() < max_day_seen


## Call on app start, on screens that show the challenge, and before any
## action. Rolls over to a new day (a fresh challenge, streak break check),
## settles a kick that was struck but never judged, and runs the clock guard.
## tier: the player's skill tier right now (used only for a new day).
## Returns true if anything changed (save it).
func refresh(tier: int) -> bool:
	var dirty := false
	var now := now_unix()
	if not clock.is_trusted() and last_seen_unix > 0 and now + tuning.clock_back_tolerance_sec < last_seen_unix:
		clock_back = true
	if is_locked():
		changed.emit()
		return false
	var day := current_day()
	if now > last_seen_unix:
		last_seen_unix = now
		dirty = true
	if day > max_day_seen:
		max_day_seen = day
		dirty = true
	# A kick struck but never judged (closed mid-flight) counts as a miss.
	if bool(today.get("struck", false)):
		_judge(false)
		dirty = true
	if int(today.get("day", NO_DAY)) != day:
		today = {"day": day, "tier": clampi(tier, 0, DailyScenario.TIERS.size() - 1), "attempts": 0,
			"struck": false, "result": "", "retry_used": 0, "retry_ready": false, "claimed": false,
			"reward": 0, "sp_to": ""}
		_scenario = {}
		dirty = true
	if _check_streak(day):
		dirty = true
	if dirty:
		changed.emit()
	return dirty


## A streak whose last success is older than yesterday is broken. With exactly
## one day missed (and the saver not used this streak) the saver is offered
## for today only.
func _check_streak(day: int) -> bool:
	var dirty := false
	if streak > 0 and last_completed_day < day - 1:
		if tuning.streak_saver_enabled and not saver_used and last_completed_day == day - 2:
			saver_offer = {"streak": streak, "day": day}
		streak = 0
		dirty = true
	if not saver_offer.is_empty() and int(saver_offer.get("day", NO_DAY)) != day:
		saver_offer = {}
		dirty = true
	return dirty


# --- the challenge ------------------------------------------------------------------------

func scenario() -> Dictionary:
	if _scenario.is_empty() or int(_scenario.get("day", NO_DAY)) != int(today.get("day", NO_DAY)):
		_scenario = DailyScenario.generate(int(today.get("day", current_day())), int(today.get("tier", 0)), tuning)
	return _scenario


## "locked" (clock behind), "ready" (not kicked yet), "retry" (a retry is
## granted), "missed" (missed, a retry may be possible), "failed" (no kicks
## left today), "done" (success, reward claimed).
func status() -> String:
	if is_locked():
		return "locked"
	match str(today.get("result", "")):
		"success":
			return "done"
		"failed":
			return "failed"
		"missed":
			return "retry" if bool(today.get("retry_ready", false)) else "missed"
	return "ready"


func can_kick() -> bool:
	return status() in ["ready", "retry"]


## Nothing tried yet today: the "NEW" badge.
func is_new() -> bool:
	return status() == "ready"


func max_attempts() -> int:
	return 1 + maxi(tuning.ad_retries_per_day, 0)


func attempts_left() -> int:
	if status() == "done":
		return 0
	return maxi(max_attempts() - int(today.get("attempts", 0)), 0)


## The kick has left the foot: it counts from now (saved by the caller), so
## quitting before the result is a miss, not a free retry.
func begin_kick() -> bool:
	if not can_kick():
		return false
	if int(today.get("attempts", 0)) == 0:
		stats["played"] = int(stats.get("played", 0)) + 1
	today["attempts"] = int(today.get("attempts", 0)) + 1
	today["struck"] = true
	today["retry_ready"] = false
	changed.emit()
	return true


## The struck kick's result. Success claims the reward (returned; 0 = no
## reward). Save right after: the result and the claim go in one write.
func finish_kick(success: bool) -> int:
	if not bool(today.get("struck", false)):
		return 0
	var sp := _judge(success)
	changed.emit()
	return sp


func _judge(success: bool) -> int:
	today["struck"] = false
	stats["kicks"] = int(stats.get("kicks", 0)) + 1
	if not success:
		today["result"] = "failed" if int(today.get("attempts", 0)) >= max_attempts() else "missed"
		return 0
	stats["makes"] = int(stats.get("makes", 0)) + 1
	stats["completed"] = int(stats.get("completed", 0)) + 1
	today["result"] = "success"
	var day := int(today.get("day", NO_DAY))
	if last_completed_day == day - 1 and streak > 0:
		streak += 1
	elif last_completed_day != day:
		streak = 1
		saver_used = false  # a new streak gets its own saver
	last_completed_day = day
	longest = maxi(longest, streak)
	return claim()


## Claims today's success once (the day is marked claimed) and, if it
## completes a week, pays the week. Returns the skill points paid (0 on days
## 1-6, or when already claimed).
func claim() -> int:
	var day := int(today.get("day", NO_DAY))
	if str(today.get("result", "")) != "success" or bool(today.get("claimed", false)) or day in claimed_days:
		return 0
	today["claimed"] = true
	today["reward"] = 0
	claimed_days.append(day)
	while claimed_days.size() > KEEP_CLAIMS:
		claimed_days.pop_front()
	return _pay_week_if_due(day)


## The week's payout when today's success made the streak a full week: queued
## for the career (GameState delivers it), once per day (payout_days).
func _pay_week_if_due(day: int) -> int:
	if not tuning.is_week_end(streak) or day in payout_days:
		return 0
	var sp := tuning.reward_for(streak)
	payout_days.append(day)
	while payout_days.size() > KEEP_CLAIMS:
		payout_days.pop_front()
	today["reward"] = sp
	today["week_paid"] = true
	if sp > 0:
		pending.append({"id": week_id(day), "sp": sp, "day": day})
	stats["sp"] = int(stats.get("sp", 0)) + sp
	stats["weeks"] = int(stats.get("weeks", 0)) + 1
	return sp


## The payout's claim id (the career remembers it). Old per-day rewards used
## "daily-<day>"; those still deliver.
static func week_id(day: int) -> String:
	return "week-%d" % day


## Did today's success pay a week?
func week_paid_today() -> bool:
	return status() == "done" and bool(today.get("week_paid", false))


# --- the week --------------------------------------------------------------------------------

## Successful days in the current week (0..week_days-1): the streak mod
## week_days. Right after a payout it's 0 (a new week starts).
func week_progress() -> int:
	return streak % maxi(tuning.week_days, 1)


## Days still to make (today included if not done) to earn the week's points.
func days_to_payout() -> int:
	return tuning.week_days - week_progress()


## The payout the current week is working toward.
func next_payout() -> int:
	return tuning.week_reward(streak / maxi(tuning.week_days, 1) + 1)


## Which day of the week today's kick is (1..week_days), done or not.
func week_day_today() -> int:
	if status() == "done":
		var p := week_progress()
		return tuning.week_days if p == 0 else p
	return week_progress() + 1


# --- retry (rewarded ad) ------------------------------------------------------------------

## A retry can be offered after a miss: retries left today and either ads on
## this platform or the no-ads rule "free".
func retry_offered() -> bool:
	return status() == "missed" and int(today.get("retry_used", 0)) < tuning.ad_retries_per_day \
		and (ads.platform_has_ads() or tuning.no_ads_rule == "free")


## The retry needs an ad (false: the no-ads rule gives it free).
func retry_needs_ad() -> bool:
	return ads.platform_has_ads()


## After the rewarded ad (or free on a no-ads platform): one more kick today.
func grant_retry() -> bool:
	if not retry_offered():
		return false
	today["retry_used"] = int(today.get("retry_used", 0)) + 1
	today["retry_ready"] = true
	changed.emit()
	return true


# --- streak saver --------------------------------------------------------------------------

func saver_offered() -> bool:
	return not is_locked() and not saver_offer.is_empty() and int(saver_offer.get("day", NO_DAY)) == current_day() \
		and not saver_used and tuning.streak_saver_enabled \
		and (ads.platform_has_ads() or tuning.no_ads_rule == "free")


## The streak the saver would bring back.
func saver_streak() -> int:
	return int(saver_offer.get("streak", 0))


## Restores the broken streak (after the ad). If today is already done, today
## stacks on top. Returns the restored streak.
func restore_streak() -> int:
	if not saver_offered():
		return 0
	var day := current_day()
	var done_today := last_completed_day == day
	streak = saver_streak() + (streak if done_today else 0)
	if not done_today:
		last_completed_day = day - 1  # bridges the missed day (it earns nothing)
	longest = maxi(longest, streak)
	saver_used = true
	saver_offer = {}
	# Restored on top of today's success: if that completes a week, pay it now.
	if done_today and str(today.get("result", "")) == "success":
		_pay_week_if_due(day)
	changed.emit()
	return streak


func decline_saver() -> void:
	saver_offer = {}
	changed.emit()


# --- rewards -------------------------------------------------------------------------------

## Skill points waiting for a career.
func pending_sp() -> int:
	var n := 0
	for p in pending:
		n += int(p.get("sp", 0))
	return n


## Adds pending rewards to a career, once per claim id (the career remembers
## the ids, so a crash between the two saves can't pay twice). Returns the
## points added. The caller saves the career, then drops the delivered
## entries with clear_delivered() and saves the main file.
func deliver_to(c: CareerData) -> int:
	var n := 0
	for p in pending:
		var id := str(p.get("id", ""))
		if id == "" or id in c.daily_claims:
			continue
		SkillPoints.earn(c, int(p.get("sp", 0)), tuning.sp_source_text)
		c.daily_claims.append(id)
		n += int(p.get("sp", 0))
	while c.daily_claims.size() > KEEP_CLAIMS:
		c.daily_claims.pop_front()
	return n


## Drops pending entries that are now in this career.
func clear_delivered(c: CareerData) -> void:
	pending = pending.filter(func(p: Dictionary) -> bool: return not (str(p.get("id", "")) in c.daily_claims))


## The week track: week_days slots, the prize on the last one, as
## [{n (day of the week), state, prize, sp}]. state: "done" (made, filled red),
## "today" (today's kick, not made yet), "next". After a payout the track is a
## fresh week (nothing done; tomorrow is day 1).
func track() -> Array:
	var len := maxi(tuning.week_days, 1)
	var done := week_progress()
	var out: Array = []
	for n in range(1, len + 1):
		var state := "next"
		if n <= done:
			state = "done"
		elif n == done + 1 and can_kick_today():
			state = "today"
		out.append({"n": n, "state": state, "prize": n == len, "sp": next_payout() if n == len else 0})
	return out


## Today's kick is still to be made (ready, missed with a retry, or retry).
func can_kick_today() -> bool:
	return status() in ["ready", "retry", "missed"]


func success_rate() -> int:
	var played := int(stats.get("played", 0))
	return roundi(100.0 * int(stats.get("completed", 0)) / played) if played > 0 else 0


## Show the "today's challenge" popup (once a day, when there's a kick to take).
func wants_popup() -> bool:
	return not is_locked() and popup_day != current_day() and status() == "ready"


func mark_popup() -> void:
	popup_day = current_day()


# --- save ------------------------------------------------------------------------------------

func to_dict() -> Dictionary:
	return {"streak": streak, "longest": longest, "last_completed_day": last_completed_day,
		"today": today.duplicate(true), "saver_offer": saver_offer.duplicate(), "saver_used": saver_used,
		"claimed_days": claimed_days.duplicate(), "payout_days": payout_days.duplicate(),
		"pending": pending.duplicate(true),
		"stats": stats.duplicate(), "last_seen_unix": last_seen_unix, "max_day_seen": max_day_seen,
		"popup_day": popup_day, "debug_shift_days": debug_shift_days}


func from_dict(d: Dictionary) -> void:
	streak = maxi(int(_num(d, "streak", 0)), 0)
	longest = maxi(int(_num(d, "longest", 0)), streak)
	last_completed_day = int(_num(d, "last_completed_day", NO_DAY))
	today = d.get("today", {}) if d.get("today") is Dictionary else {}
	saver_offer = d.get("saver_offer", {}) if d.get("saver_offer") is Dictionary else {}
	saver_used = bool(d.get("saver_used", false))
	claimed_days = []
	if d.get("claimed_days") is Array:
		for x in d["claimed_days"]:
			claimed_days.append(int(x))
	payout_days = []
	if d.get("payout_days") is Array:
		for x in d["payout_days"]:
			payout_days.append(int(x))
	pending = []
	if d.get("pending") is Array:
		for p in d["pending"]:
			if p is Dictionary and str(p.get("id", "")) != "":
				pending.append({"id": str(p["id"]), "sp": int(p.get("sp", 0)), "day": int(p.get("day", 0))})
	stats = {"played": 0, "completed": 0, "kicks": 0, "makes": 0, "sp": 0, "weeks": 0}
	if d.get("stats") is Dictionary:
		for k in stats:
			stats[k] = int(_num(d["stats"], k, 0))
	last_seen_unix = int(_num(d, "last_seen_unix", 0))
	max_day_seen = int(_num(d, "max_day_seen", NO_DAY))
	popup_day = int(_num(d, "popup_day", NO_DAY))
	debug_shift_days = int(_num(d, "debug_shift_days", 0)) if OS.is_debug_build() else 0
	# JSON numbers come back as floats: normalize today's ints.
	for k in ["day", "tier", "attempts", "retry_used", "reward"]:
		if today.has(k):
			today[k] = int(_num(today, k, 0))
	_scenario = {}


static func _num(d: Dictionary, k: String, fallback: float) -> float:
	var v: Variant = d.get(k)
	return float(v) if (v is float or v is int) else fallback

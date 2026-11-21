class_name Fatigue
extends RefCounted
## Low Energy hurts, and rest is a real choice.
##
##   Tired (Energy under low_energy_threshold, 40): the kick penalty KickProfile
##     already had (range, wobble), plus injury chance (up to low_energy_injury
##     at Energy 0, on top of the base chance).
##   Exhausted (Energy under exhausted_energy, 20, at the end of a week): a
##     further temporary penalty (range, aim spread) and a "Running on empty"
##     warning on the Hub and the Outlook.
##   Permanent loss: only on the second exhausted week in a row, after the
##     warning: fatigue_loss_points of Power and Toughness for each further
##     exhausted week, at most fatigue_loss_season_cap times a season. Bought
##     back with skill points like any attribute point (Skills shows "lost to
##     exhaustion"). Separate from aging (maintenance protects against aging).
##   Temporary penalties end as soon as Energy recovers.
##
## Weekly practice intensity (Hub): light (more Energy, no practice skill
## points), normal, hard (less Energy, +skill points, a little injury risk).
## Good habits: good_habits_weeks weeks in a row ending at good_habits_energy+
## pays good_habits_sp (at most good_habits_season_cap a season).
## Numbers: CareerTuning "Fatigue". State: CareerData.fatigue.

const INTENSITIES := ["light", "normal", "hard"]
const LOSS_STATS := ["power", "toughness"]
const SP_HABITS := "Good habits"


static func practice(c: CareerData) -> String:
	var p := str(c.fatigue.get("practice", "normal"))
	return p if p in INTENSITIES else "normal"


static func set_practice(c: CareerData, intensity: String) -> void:
	if intensity in INTENSITIES:
		c.fatigue["practice"] = intensity


static func exhausted(c: CareerData, t: CareerTuning) -> bool:
	return c.stat("energy") < t.exhausted_energy


## The warning is up: last week ended exhausted (one more costs attributes).
static func warned(c: CareerData) -> bool:
	return int(c.fatigue.get("exhausted_weeks", 0)) >= 1


## Weekly practice skill points for this intensity (normal: what the game
## always gave; tired normal practice still gives less).
static func practice_sp(c: CareerData, t: CareerTuning) -> int:
	var tired := c.stat("energy") < t.low_energy_threshold
	var base := t.sp_weekly_practice_tired if tired else t.sp_weekly_practice
	match practice(c):
		"light":
			return 0
		"hard":
			return base + t.practice_hard_sp
	return base


## End of a week (CareerManager.end_week, before the weekly recovery):
## exhaustion, the warning, permanent loss, good habits. Returns the Energy
## change from this week's practice intensity (added to the weekly recovery).
static func end_week(c: CareerData, t: CareerTuning) -> Dictionary:
	var energy := c.stat("energy")
	var f := c.fatigue
	if energy < t.exhausted_energy:
		f["exhausted_weeks"] = int(f.get("exhausted_weeks", 0)) + 1
		if int(f["exhausted_weeks"]) == 1:
			_notice(c, "RUNNING ON EMPTY: you ended the week exhausted. Rest this week (light practice, rest " +
				"choices): one more exhausted week costs attribute points.")
		elif int(f.get("loss_season_n", 0)) < t.fatigue_loss_season_cap:
			f["loss_season_n"] = int(f.get("loss_season_n", 0)) + 1
			var lost: Dictionary = f.get("lost", {})
			var parts := PackedStringArray()
			for s in LOSS_STATS:
				var before := c.stat(s)
				c.set_stat(s, maxf(before - t.fatigue_loss_points, 0.0))
				var d := before - c.stat(s)
				if d > 0.0:
					lost[s] = float(lost.get(s, 0.0)) + d
					parts.append("-%d %s" % [roundi(d), CareerData.STAT_NAMES[s].replace("Kicking ", "")])
			f["lost"] = lost
			f["lost_total"] = float(f.get("lost_total", 0.0)) + t.fatigue_loss_points * LOSS_STATS.size()
			if not parts.is_empty():
				_notice(c, "EXHAUSTED AGAIN: %s. Win them back with skill points; rest to stop it." % ", ".join(parts))
	else:
		f["exhausted_weeks"] = 0
	# Good habits: weeks in a row ending well rested.
	if energy >= t.good_habits_energy:
		f["rested_weeks"] = int(f.get("rested_weeks", 0)) + 1
		if int(f["rested_weeks"]) >= t.good_habits_weeks:
			f["rested_weeks"] = 0
			if int(f.get("habits_season_n", 0)) < t.good_habits_season_cap:
				f["habits_season_n"] = int(f.get("habits_season_n", 0)) + 1
				SkillPoints.earn(c, t.good_habits_sp, SP_HABITS)
	else:
		f["rested_weeks"] = 0
	c.fatigue = f
	match practice(c):
		"light":
			return {"energy": t.practice_light_energy}
		"hard":
			return {"energy": t.practice_hard_energy}
	return {}


## A new season: the season caps start over.
static func new_season(c: CareerData) -> void:
	c.fatigue["loss_season_n"] = 0
	c.fatigue["habits_season_n"] = 0


## Points of `stat` lost to exhaustion over the career (Skills).
static func lost(c: CareerData, stat: String) -> float:
	return float((c.fatigue.get("lost", {}) as Dictionary).get(stat, 0.0))


static func _notice(c: CareerData, text: String) -> void:
	c.notice = text if c.notice == "" else c.notice + " " + text

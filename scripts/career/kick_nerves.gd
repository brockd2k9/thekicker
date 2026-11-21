class_name KickNerves
extends RefCounted
## Career "nerves": when off-field life goes badly, a crooked swipe costs more.
## The result is ONE number, straightness_penalty_mult (1 = normal), that
## scales only the sideways miss of a crooked swipe (KickModifiers ->
## KickController.build_shot). Straight swipes, power, distance and wind are
## never touched. Career only (KickProfile sets it; Practice / Challenge don't).
##
## Sources (added, then clamped to [nerves_min_mult, nerves_max_mult]):
##   energy     Energy below nerves_energy_threshold
##   life       Health, Fun, Social each below nerves_life_threshold
##   decisions  wrong choices (conduct bad / scandal, character_concerns or
##              dismissed set); stored, fades week by week and with good choices
##   slump      after nerves_slump_misses misses in a row or a bad stretch; out
##              only after nerves_slump_exit_clean straight makes in a row. Each
##              clean kick eases it a little. In a slump energy and life count
##              nerves_slump_amplify times as much.
## Every number: CareerTuning "Kick Nerves". State: CareerData.nerves =
## {decisions, bad_week, slump, clean_run, miss_run, recent}.

const LIFE_KEYS := ["health", "fun", "social"]


## {mult, energy, life, decisions, slump, in_slump, clean_run, status}.
## energy / life are already amplified when in a slump.
static func breakdown(c: CareerData, t: CareerTuning) -> Dictionary:
	var n := c.nerves
	var in_slump := bool(n.get("slump", false))
	var amp := t.nerves_slump_amplify if in_slump else 1.0
	var energy := t.nerves_energy_max * CareerTuning.lowness(c.stat("energy"), t.nerves_energy_threshold) * amp
	var life := 0.0
	for k in LIFE_KEYS:
		life += t.nerves_life_max * CareerTuning.lowness(c.stat(k), t.nerves_life_threshold)
	life *= amp
	var decisions := clampf(float(n.get("decisions", 0.0)), 0.0, t.nerves_decision_cap)
	var slump := 0.0
	var run := int(n.get("clean_run", 0))
	if in_slump:
		slump = t.nerves_slump_extra * maxf(1.0 - t.nerves_slump_ease * run, t.nerves_slump_floor)
	var mult := clampf(1.0 + energy + life + decisions + slump, t.nerves_min_mult, t.nerves_max_mult)
	var status := ""
	if in_slump:
		status = "In a slump"
	elif mult >= t.nerves_shaky_at:
		status = "Shaky"
	return {"mult": mult, "energy": energy, "life": life, "decisions": decisions, "slump": slump,
		"in_slump": in_slump, "clean_run": run, "status": status}


## One line for the debug overlay / Career Debug screen.
static func debug_text(b: Dictionary, t: CareerTuning) -> String:
	var s := "Nerves x%.2f = 1 + energy %.2f + life %.2f + decisions %.2f + slump %.2f" % [
		float(b["mult"]), float(b["energy"]), float(b["life"]), float(b["decisions"]), float(b["slump"])]
	if b["in_slump"]:
		s += "  (slump: %d/%d clean)" % [int(b["clean_run"]), t.nerves_slump_exit_clean]
	return s


## Short player-facing reason for the Game Day Outlook, e.g. "Low energy, a slump".
static func reasons(b: Dictionary) -> String:
	var parts := PackedStringArray()
	if float(b["energy"]) > 0.0:
		parts.append("low energy")
	if float(b["life"]) > 0.0:
		parts.append("life off the field")
	if float(b["decisions"]) > 0.0:
		parts.append("recent choices")
	if b["in_slump"]:
		parts.append("a kicking slump")
	return ", ".join(parts)


## After a scenario choice. choice: the choice's data (conduct, set_flags).
static func on_choice(c: CareerData, choice: Dictionary, t: CareerTuning) -> void:
	var flags: Dictionary = choice.get("set_flags", {}) if choice.get("set_flags", {}) is Dictionary else {}
	var add := 0.0
	match str(choice.get("conduct", "")):
		"bad":
			add += t.nerves_bad_choice
		"scandal":
			add += t.nerves_scandal_choice
	if flags.get(Reputation.CONCERNS, false) or flags.get(Reputation.DISMISSED, false):
		add += t.nerves_negative_flag
	var good: bool = str(choice.get("conduct", "")) == "good" or bool(flags.get(Reputation.REBUILT, false)) \
		or (flags.has(Reputation.CONCERNS) and not flags[Reputation.CONCERNS])
	var d := float(c.nerves.get("decisions", 0.0))
	if add > 0.0:
		d += add
		c.nerves["bad_week"] = c.week_index
	elif good:
		d -= t.nerves_good_choice
	c.nerves["decisions"] = clampf(d, 0.0, t.nerves_decision_cap)


## End of week: the decisions part fades if this week had no wrong choice.
static func end_week(c: CareerData, t: CareerTuning) -> void:
	if int(c.nerves.get("bad_week", -1)) == c.week_index:
		return
	c.nerves["decisions"] = maxf(float(c.nerves.get("decisions", 0.0)) - t.nerves_decision_fade_week, 0.0)


## After a game: your field goals and extra points, in order (backup kicks
## don't count). A kick is clean if made and "straight" (GameSim stores it from
## the kick scene; unknown = straight). Enters / leaves the slump; returns
## "entered", "left" or "".
static func after_game(c: CareerData, kicks: Array, t: CareerTuning) -> String:
	var n := c.nerves
	var recent: Array = n.get("recent", [])
	var change := ""
	for k in kicks:
		if not (str(k.get("kind", "")) in ["fg", "pat"]) or k.get("backup", false):
			continue
		var made: bool = k.get("made", false)
		var clean := made and bool(k.get("straight", true))
		recent.append(made)
		while recent.size() > t.nerves_slump_window:
			recent.pop_front()
		n["miss_run"] = 0 if made else int(n.get("miss_run", 0)) + 1
		n["clean_run"] = int(n.get("clean_run", 0)) + 1 if clean else 0
		if not n.get("slump", false):
			var bad_stretch := recent.size() >= t.nerves_slump_window \
				and float(recent.count(true)) / recent.size() < t.nerves_slump_pct
			if int(n["miss_run"]) >= t.nerves_slump_misses or bad_stretch:
				n["slump"] = true
				n["clean_run"] = 0
				change = "entered"
		elif int(n["clean_run"]) >= t.nerves_slump_exit_clean:
			# Out, with a fresh start (so the old misses can't drag you straight back in).
			n["slump"] = false
			n["clean_run"] = 0
			n["miss_run"] = 0
			recent.clear()
			change = "left"
	n["recent"] = recent
	match change:
		"entered":
			_notice(c, "You're in a slump: crooked swipes cost you more. String %d straight makes together to shake it, and look after your energy." % t.nerves_slump_exit_clean)
		"left":
			_notice(c, "You're out of the slump.")
	return change


static func _notice(c: CareerData, text: String) -> void:
	c.notice = text if c.notice == "" else c.notice + " " + text

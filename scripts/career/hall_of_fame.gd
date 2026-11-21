class_name HallOfFame
extends RefCounted
## The Hall of Fame vote (R10), decided at retirement. Pro seasons only (free
## agency seasons with games count too). Every number: CareerTuning "Hall of Fame".
##
##   Longevity  hof_per_season a pro season, at most hof_season_cap
##   Accuracy   with hof_min_attempts+ pro attempts: hof_acc_above a point of pro
##              FG% above hof_acc_ref; hof_acc_below a point under it, at most
##              hof_acc_below_cap off
##   Volume     hof_per_made per pro field goal made
##   Clutch     hof_per_game_winner per pro game winner (overtime counts), at
##              most hof_clutch_cap
##   Distance   hof_per_long50 per pro make of 50+ yards (at most hof_long50_cap),
##              plus hof_long60_bonus for a pro long of 60+
##   Fame       up to hof_fame_max by the best followers tier reached
##   Character  hof_per_suspension a suspension, hof_concerns for character
##              concerns at retirement, hof_dismissed if ever dismissed
##
## Tiers by score: first_ballot (hof_first_ballot+), inducted (hof_inducted+),
## finalist (hof_finalist+), ring_of_honor (hof_ring_of_honor+: by the club you
## played most pro seasons for), none. Thresholds are provisional until the kick
## retune settles FG% (retune step 3).
##
## Story signals (CareerData.flags, set at retirement): hall_of_fame_earned
## (first ballot or inducted), hall_of_fame_tier (the tier id, a string), and
## one true flag per tier: hof_first_ballot / hof_inducted / hof_finalist /
## hof_ring_of_honor.

const TIERS := ["none", "ring_of_honor", "finalist", "inducted", "first_ballot"]
const TIER_NAMES := {"none": "Not elected", "ring_of_honor": "Ring of Honor", "finalist": "Finalist",
	"inducted": "Hall of Fame", "first_ballot": "First-ballot Hall of Famer"}
const PRO_STAGES := [CareerData.STAGE_PRO, CareerData.STAGE_FREE_AGENT]


## {eligible, score, tier, lines [{label, detail, points}], club, seasons,
## made, att, pct}. eligible: played at least one pro season.
static func evaluate(c: CareerData, t: CareerTuning) -> Dictionary:
	var seasons := 0
	var made := 0
	var att := 0
	var gw := 0
	var long := 0
	var clubs := {}
	for h in c.history:
		if not (str(h.get("stage", "")) in PRO_STAGES):
			continue
		var s: Dictionary = h.get("stats", {})
		if str(h.get("stage", "")) == CareerData.STAGE_FREE_AGENT and int(s.get("games", 0)) == 0:
			continue
		seasons += 1
		made += int(s.get("fg_made", 0))
		att += int(s.get("fg_att", 0))
		gw += int(s.get("game_winners", 0))
		long = maxi(long, int(s.get("long", 0)))
		var team := str(h.get("team", ""))
		clubs[team] = int(clubs.get(team, 0)) + 1
	var long50 := 0
	for k in c.kick_log:
		if str(k.get("kind", "")) == "fg" and str(k.get("stage", "")) in PRO_STAGES \
				and int(k.get("made", 0)) == 1 and int(k.get("yd", 0)) >= 50:
			long50 += 1
	var pct := 100.0 * made / att if att > 0 else 0.0
	var lines: Array = []
	lines.append(_line("Longevity", "%d pro season%s" % [seasons, "" if seasons == 1 else "s"],
		minf(seasons * t.hof_per_season, t.hof_season_cap)))
	var acc := 0.0
	var acc_detail := "%d%% on %d attempts" % [roundi(pct), att]
	if att < t.hof_min_attempts:
		acc_detail += " (needs %d)" % t.hof_min_attempts
	elif pct >= t.hof_acc_ref:
		acc = (pct - t.hof_acc_ref) * t.hof_acc_above
	else:
		acc = -minf((t.hof_acc_ref - pct) * t.hof_acc_below, t.hof_acc_below_cap)
	lines.append(_line("Accuracy", acc_detail, acc))
	lines.append(_line("Volume", "%d field goal%s made" % [made, "" if made == 1 else "s"], made * t.hof_per_made))
	lines.append(_line("Clutch", "%d game winner%s" % [gw, "" if gw == 1 else "s"],
		minf(gw * t.hof_per_game_winner, t.hof_clutch_cap)))
	var dist := minf(long50 * t.hof_per_long50, t.hof_long50_cap) + (t.hof_long60_bonus if long >= 60 else 0.0)
	lines.append(_line("Distance", "%d makes of 50+ yards, long %d" % [long50, long], dist))
	var best := int(c.social.get("best_tier", 0))
	var top := maxi(Followers.TIER_IDS.size() - 1, 1)
	lines.append(_line("Fame", "%s" % Followers.tier_name(best), roundf(t.hof_fame_max * best / float(top))))
	var character := c.suspensions_total * t.hof_per_suspension
	var why := PackedStringArray()
	if c.suspensions_total > 0:
		why.append("%d suspension%s" % [c.suspensions_total, "" if c.suspensions_total == 1 else "s"])
	if Reputation.state(c) == "concerns":
		character += t.hof_concerns
		why.append("character concerns")
	if bool(c.flags.get("was_dismissed", false)) or bool(c.flags.get("dismissed", false)):
		character += t.hof_dismissed
		why.append("dismissed")
	lines.append(_line("Character", ", ".join(why) if not why.is_empty() else "clean record", character))
	var score := 0.0
	for l in lines:
		score += float(l["points"])
	var club := ""
	var most := 0
	for team in clubs:
		if int(clubs[team]) > most:
			most = int(clubs[team])
			club = str(team)
	return {"eligible": seasons > 0, "score": roundi(score), "tier": tier_for(roundi(score), t) if seasons > 0 else "none",
		"lines": lines, "club": club, "seasons": seasons, "made": made, "att": att, "pct": snappedf(pct, 0.1)}


static func tier_for(score: int, t: CareerTuning) -> String:
	if score >= t.hof_first_ballot:
		return "first_ballot"
	if score >= t.hof_inducted:
		return "inducted"
	if score >= t.hof_finalist:
		return "finalist"
	if score >= t.hof_ring_of_honor:
		return "ring_of_honor"
	return "none"


static func earned(tier: String) -> bool:
	return tier in ["first_ballot", "inducted"]


## The story signals (see the header).
static func set_flags(c: CareerData, hof: Dictionary) -> void:
	var tier := str(hof.get("tier", "none"))
	c.flags["hall_of_fame_earned"] = earned(tier)
	c.flags["hall_of_fame_tier"] = tier
	for id in TIERS:
		if id != "none":
			c.flags["hof_" + id] = id == tier


## "Hall of Fame", "Ring of Honor (Metro Monarchs)".
static func tier_text(hof: Dictionary) -> String:
	var tier := str(hof.get("tier", "none"))
	var name: String = TIER_NAMES.get(tier, "Not elected")
	if tier == "ring_of_honor" and str(hof.get("club", "")) != "":
		name += " (%s)" % hof["club"]
	return name


static func _line(label: String, detail: String, points: float) -> Dictionary:
	return {"label": label, "detail": detail, "points": roundi(points)}

class_name Savings
extends RefCounted
## Savings / net worth: a score and a story hook. It never buys skill points,
## attributes or anything that changes a kick.
##
##   Each pro season: the salary minus taxes (savings_tax_rate) and the agent's
##     fee (savings_agent_fee) goes in at the season end.
##   A scenario choice's "money" field (whole dollars, + or -) adds or takes
##     away, at any stage (a summer job, a fine, a bad investment).
##   Savings never go below $0: a cost bigger than your savings takes what's there.
##   Scenarios can require a savings level: requires {"min": {"savings": 1000000}}
##     (or "max").
## State: CareerData.savings (dollars) and CareerData.money_log {salary,
## choices_in, choices_out, peak}. Numbers: CareerTuning "Savings".

## The biggest "money" a single choice may carry (validator).
const MAX_CHOICE := 50000000


## This pro season's pay after taxes and the agent's fee (0 outside the pros).
static func season_net(c: CareerData, t: CareerTuning) -> int:
	if c.stage != CareerData.STAGE_PRO:
		return 0
	var salary := float(int(c.contract.get("salary", 0)))
	return roundi(salary * maxf(1.0 - t.savings_tax_rate - t.savings_agent_fee, 0.0))


## Season end (CareerManager.end_season, pros): the season's pay goes in.
static func pay_season(c: CareerData, t: CareerTuning) -> int:
	var n := season_net(c, t)
	if n > 0:
		add(c, n)
		c.money_log["salary"] = int(c.money_log.get("salary", 0)) + n
	return n


## A choice's "money": the actual change (a cost stops at $0).
static func from_choice(c: CareerData, ch: Dictionary) -> int:
	if not ch.has("money"):
		return 0
	var n := add(c, int(ch["money"]))
	var key := "choices_in" if n >= 0 else "choices_out"
	c.money_log[key] = int(c.money_log.get(key, 0)) + absi(n)
	return n


## What a choice would change (the scenario card).
static func preview(c: CareerData, ch: Dictionary) -> int:
	return maxi(int(ch.get("money", 0)), -c.savings)


## Adds n (may be negative); savings stay at $0 or more. Returns the change.
static func add(c: CareerData, n: int) -> int:
	var before := c.savings
	c.savings = maxi(c.savings + n, 0)
	c.money_log["peak"] = maxi(int(c.money_log.get("peak", 0)), c.savings)
	return c.savings - before


## "$1.25M", "$350K", "$900" (no sign).
static func text(n: int) -> String:
	var a := absi(n)
	if a >= 1000000:
		return "$%.2fM" % (a / 1000000.0)
	if a >= 1000:
		return "$%dK" % roundi(a / 1000.0)
	return "$%d" % a


## "+$350K" / "-$1.20M".
static func change_text(n: int) -> String:
	return ("+" if n >= 0 else "-") + text(n)


## Problems with a choice's "money" field (CareerContent.validate).
static func problems(where: String, ch: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	if not ch.has("money"):
		return out
	var m: Variant = ch["money"]
	if not (m is int or m is float) or float(m) != floorf(float(m)) or absf(float(m)) > MAX_CHOICE:
		out.append("%s: money must be a whole number of dollars, -%d..%d" % [where, MAX_CHOICE, MAX_CHOICE])
	return out


## Old saves (version 7): an estimate from the pro seasons played at the
## current salary (or the league minimum).
static func migrate_start(d: Dictionary, t: CareerTuning) -> int:
	var seasons := 0
	var hist: Variant = d.get("history", [])
	if hist is Array:
		for h in hist:
			if h is Dictionary and str(h.get("stage", "")) == CareerData.STAGE_PRO:
				seasons += 1
	var contract: Variant = d.get("contract", {})
	var salary := 750000
	if contract is Dictionary and int(contract.get("salary", 0)) > 0:
		salary = int(contract["salary"])
	return roundi(seasons * salary * maxf(1.0 - t.savings_tax_rate - t.savings_agent_fee, 0.0))

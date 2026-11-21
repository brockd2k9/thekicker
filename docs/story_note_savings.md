# Savings and the `money` field (R3, for the story session)

Gameplay side is on main (save version 8). Rules: `scripts/career/savings.gd`.

## What the game does
- Each pro season's salary, minus taxes (37%) and the agent's fee (3%), goes into savings at the
  season end: 60% of the salary (a $1M season saves $600K). Salaries run about $750K-$1.5M.
- Savings never go below $0. A cost bigger than the savings takes what's there; the choice card
  shows the capped amount.
- Shown: a "$X saved" chip on the Hub, "+$250K" / "-$1.20M" chips on choice cards and results,
  the season summary and the career summary.
- Money never buys skill points, attributes or anything that changes a kick.

## Fields
| Where | Field | Value |
|---|---|---|
| A choice, or a kick challenge's `on_pass` / `on_fail` | `money` | Whole dollars, positive or negative, -50,000,000 to 50,000,000. A choice with only `money` counts as a change. |
| `requires` (`min` / `max`) | `savings` | Dollars. `{"min": {"savings": 1000000}}` locks with "Requires $1.00M saved"; `{"max": {"savings": 99999}}` reads "under $100K saved". |

Examples:
- `"money": -400000` (the advisor's "investment"), `"money": 250000` (a signing bonus or an ad).
- A scene for kickers with savings: `"requires": {"min": {"savings": 2000000}}`.

## What you'll need to change on your side
- `tools/import_scenarios.py`: add `"money"` to the allowed choice fields (line 99) and copy it
  through where `suspend_weeks` / `recast` are copied (around line 152); validate a whole number
  within +-50,000,000 if you like (the game's validator does).
- `WRITING_GUIDE.md` "Money": the "don't write money fields yet" note can go. Amounts in the scene
  text can still stay in words, since the card shows the number.

Scale guide: a rookie's whole first season saves about $450K-$600K; a long careful career ends
with several million (see PLAYTEST.md "Savings" for the simulator table).

# Story session handoff: followers and kick challenges

The gameplay session has built the engine for both features (save version 7). Nothing in the
scenario data uses them yet. This file lists exactly what the story session needs to change:
- the importer (`tools/import_scenarios.py`)
- the validator and flag-graph checks
- `convert_hs_graph.py` and the template
- `WRITING_GUIDE.md` and the `_doc` block in `scenarios_hs.json`
- the scenario content

The engine's own in-game content check (`CareerContent.validate`) already accepts and checks every
field below. Exact JSON for every conversion is in `tests/fixtures/kick_challenge_conversions.json`;
the engine tests load each one, validate it, and play a pass and a fail.

Numbers marked "now" are current tuning values (`tuning/career_tuning.tres`, groups "Followers" and
"Kick Challenges"). Stage 3 (simulator tuning) may change them. Write the field values below, never
follower counts, so scenarios stay right when the numbers change.

---

## 1. Importer: requirement names to accept

`tools/import_scenarios.py` keeps a list of allowed requirement names (`METRICS`). Add:

| Name | Where | Value |
|---|---|---|
| `followers` | inside `requires.min` / `requires.max` | a follower count (number) |
| `followers_tier` | directly in `requires` (also inside `any_of`) | tier id: this tier **or higher** |
| `max_followers_tier` | directly in `requires` (also inside `any_of`) | tier id: this tier **or lower** |

Tier ids, in order: `local` (0), `hometown_hero` (500), `rising_star` (5K), `campus_celebrity`
(25K), `verified` (100K), `fan_favorite` (500K), `household_name` (2M).

Rules:
- Error on an unknown tier id, and when `followers_tier` is above `max_followers_tier`.
- Warn when a tier can't be reached at the scenario's stages:
  - `high_school`: at most `rising_star`
  - `college` / `juco`: at most `verified`
  - `pro`: any tier
- Prefer tiers over `min.followers`: tiers survive retuning.
- The game writes the lock text itself ("Requires Rising Star (5K followers)"); `lock_text` still overrides it.

## 2. New choice fields

| Field | Type | Meaning |
|---|---|---|
| `followers` | number -20..20 | Followers by **scale**: the engine multiplies by the stage (see section 4). The main field. |
| `followers_exact` | number | An exact follower count, not scaled by stage and with no Charisma bonus. Only for one-off moments where the number itself is the story ("your post hits 5,000"). |
| `conduct` | `"good"` / `"bad"` / `"scandal"` | Moral weight. Now: good +3, bad -4, scandal -15 on the same scale, added to `followers`. A scandal also ends the player's brand deals. |
| `deal` | object | A brand deal (below). At most one per choice. |
| `kick_challenge` | object | Real kicks (section 3). At most one per scenario. |

`deal`:
```json
"deal": {"id": "ridgeline_sports", "name": "Ridgeline Sports", "kind": "sp", "value": 1, "seasons": 1}
```

| Key | Rule |
|---|---|
| `id` | unique across all scenarios |
| `kind` | `sp` (skill points a week, value 1), `range` (field goal yards while active, value 0.5-1) or `fun` (Fun a week, value 1-2) |
| `seasons` | 1-2 |

How deals work:
- The player can hold at most 2 deals.
- Each deal costs 1 Energy a week (photo shoots).
- Deals end after `seasons`, at a new stage, or with a scandal.

Validator: `followers` in -20..20; `followers_exact` is a number (warn above 10,000 in high school,
100,000 in college, 1,000,000 in the pros); `conduct` is one of the three values; `deal` follows the
table above.

## 3. `kick_challenge`

```json
"kick_challenge": {
  "kind": "showcase",
  "title": "REGIONAL SHOWCASE",
  "distances": [30, 35, 38, 42, 45],
  "need": 3,
  "pressure": "medium",
  "wind": "breezy",
  "kickoffs": {"count": 2, "min_yards": 65},
  "on_pass": { ... },
  "on_fail": { ... }
}
```

| Field | Rule |
|---|---|
| `kind` | `showcase`, `camp`, `combine`, `competition`, `battle`, `tryout`. A pass with no `followers` gets the kind's default. Now (on the same scale): showcase 4, camp 3, combine 6, competition 5, battle 1, tryout 2. |
| `title` | caps, 24 characters or fewer; shown on the scoreboard |
| `distances` | 2-8 field goals, whole numbers 20-60. The engine clamps each to the player's field goal range - 1 (like the bench audition). |
| `need` | 1..(field goals + kickoffs). **Kickoffs count toward `need`.** |
| `pressure` | `low` / `medium` / `high` (now 0.2 / 0.35 / 0.5; it also builds 0.08 a kick). Default `medium`. |
| `wind` | `calm` / `breezy` / `windy` (now max 3 / 8 / 14 mph). Default `breezy`. |
| `kickoffs` | optional: `count` 0-3, `min_yards`. A kickoff counts as made if it carries `min_yards` or lands deep / for a touchback. Use for combines only. |
| `on_pass`, `on_fail` | both required, each with a `result` |

There is no `weather` field (it was in the proposal but isn't built). Ask if you need it.

**What `on_pass` / `on_fail` may contain** (the same effect fields as a choice): `result` (required),
`stats`, `skill_points`, `recruiting`, `draft`, `retention`, `grades`, `rel`, `modifiers`,
`set_flags`, `follow_up`, `followers`, `followers_exact`, `conduct`, `deal`. Anything else is an
error.

**When each part applies:**
- The choice's own (top-level) fields apply **when the player picks it, before kicking**: costs
  (Energy), story flags, and a modifier that should affect the kicks (`heavy_legs` really makes the
  kicks harder). The top-level `result` is optional; if present it's shown before the kicks.
- `on_pass` or `on_fail` applies after the kicks.
- Put the rewards in `on_pass`, so picking the choice doesn't guarantee them.

**Rules for writers:**
- The fail block is milder than skipping, never a punishment. The validator should warn when
  `on_fail` has `followers` below -5, or when `on_fail` has `bench_weeks` (not supported: there's no
  benching from challenges).
- Every choice still needs a game-day modifier: at top level, or in **both** blocks.
- **Story flags** the graph depends on (`expected_flags`, `leads_to` flags) go at top level or in
  **both** blocks. A flag only in `on_pass` is set only when the player passes.
- Challenge kicks never give game skill points, never count in season stats, and never change Coach
  or Team unless a block has `rel`.
- Every kick made adds +1 skill point (shown as "Challenge" in the skill-point breakdown) and a few
  followers.

**Stage guide:**

| Stage | Distances | Need |
|---|---|---|
| High school | 25-45 | 3 of 5 (2 of 4 for an easy camp) |
| College | 32-50 | 3 of 5 |
| Pro | 38-55 | 3 of 5 |

## 4. `followers` vs `followers_exact` (what the writer enters, what the player sees)

Followers per point of `followers`, now: high school 10, junior college 40, college 120, free agent 600, pros
1,200. A gain is shown with up to +20% from Charisma, so these are the lowest values; losses aren't
boosted.

| Stage | The writer enters | The player sees |
|---|---|---|
| High school | `"followers": 1` (posts a training clip) | "+10 followers" |
| High school | `"conduct": "good"` (helps a teammate find his playbook) | "+30 followers" |
| High school | `"followers_exact": 2000` (the crossbar clip blows up) | "+2,000 followers" |
| College | `"followers": 2` (campus podcast guest) | "+240 followers" |
| College | `"conduct": "bad"` (mocks a walk-on online) | "-480 followers" |
| College | `"followers": 6` (charity kick-a-thon goes well) | "+720 followers" |
| Pros | `"followers": 3` (autograph session) | "+3,600 followers" |
| Pros | `"conduct": "scandal"` (a public fight) | "-18K followers", and sponsors drop the player |
| Pros | `"followers_exact": 250000` (Super Bowl ad) | "+250K followers" |

Use `followers` for nearly everything: it scales by stage, so the same choice text works wherever it
appears. Use `followers_exact` only when the count itself is part of the story, and keep it believable
for the stage.

The player never sees the word "points" for followers. Never write "points" in result text about
followers; the game shows the counts itself.

## 5. Flag-graph checker

Everywhere the checker collects "flags a choice sets" (expected-flag checks, `leads_to`, "required
but never set", "set too late"), also read `kick_challenge.on_pass.set_flags` and
`kick_challenge.on_fail.set_flags`. The engine's own check already does this.

`convert_hs_graph.py` must keep `kick_challenge`, `followers`, `followers_exact`, `conduct` and
`deal` unchanged (round trip), and the template should show one example of each.

## 6. Conversions to apply

Exact JSON for each is in `tests/fixtures/kick_challenge_conversions.json` (replace the whole choice).
The other choices in each scenario don't change.

| Scenario | Choice | Challenge | Pass | Fail |
|---|---|---|---|---|
| `hs_showcase` | 0 "Compete for a top ranking" | showcase, 30-45, need 3, medium, breezy | today's rewards + followers 4 | +2 Recruiting, +1 SP |
| `hs_scholarship_camp` | 0 "The big showcase camp" (`camp_showcase` stays at top level) | camp, 35-50, need 3, high | today's rewards + followers 5 | +3 Recruiting, +2 SP |
| `hs_scholarship_camp` | 1 "A smaller regional camp" (`camp_regional` stays at top level) | camp, 28-38, need 2 of 4, low, calm | today's rewards | +2 Recruiting, +2 SP |
| `HS_040` | 0 "Enter and compete" (`heavy_legs` at top level: tired legs) | showcase, 30-43, need 3 | +2 Recruiting, +2 SP, followers 3 | +1 Recruiting |
| `HS_121` | 0 "Go where they want you" (`prioritized_recruiting_interest` **stays at top level**) | camp, 33-47, need 3 | +5 Recruiting, +3 SP, flag `camp_impressed` | +2 Recruiting, +2 SP |
| `HS_016` | 0 "Ask your family to help pay" | camp, 25-34, need 2 of 4, low, calm | +2 Recruiting, +3 SP | +2 SP |
| `hs_kicker_battle` | 0 "Win it in practice" | battle, 30-45, need 3 | today's rewards + Coach +3 | `stressed`, Coach -2, flag `lost_kicker_battle` |
| `col_walkon_battle` | 0 "Outkick the scholarship guy" | battle, 35-47, need 3, high | today's rewards + Coach +4 | `stressed`, Coach -2, flag **`lost_walkon_battle`** (for a follow-up) |
| `col_combine_invite` | 0, relabeled "Kick for the scouts" | combine, 38-52 + 2 kickoffs (65+ yd), need 4 of 7, high, calm | +6 Draft, +2 SP, followers 6 | +1 Draft, followers -1 |

Notes:
- **Combine timing:** `col_combine_invite` happens in week 9, but the combine is after the season.
  Please make choice 0 a pre-combine workout in front of scouts (the converted label and text already
  read that way), or move the scenario to the offseason.
- **Failed kicker battles** are mild, with no bench (a bench needs a starting job to lose). Write a
  follow-up for `lost_walkon_battle` if you like.
- **Drafts to write as challenges:** `HS_056` The Last-Minute Scholarship Camp and `HS_077` The
  Kicking Challenge.
- **Not converted:**
  - `HS_075` and `trait_youth_camp`: coaching kids, not competing
  - `trait_private_coach`: lessons
  - `HS_116`: a crossbar challenge needs crossbar detection; give it `followers` instead (+5 for the clip, +2 for the training post)

## 7. Tagging pass on existing scenarios

Add `conduct` (and `followers` where it fits) to choices that clearly are:
- **good:** helping a teammate, charity, owning a mistake, standing up for someone. Examples: HS_003
  "Step in and help him find it", HS_139 "Own what you said", HS_129 "Give it to {parent}". **Good
  moral choices must be rewarded with followers too**, not only fame-seeking ones.
- **bad:** mocking, cheating, steering a teammate wrong. Examples: HS_003 "Laugh along", HS_120
  "Steer him wrong".
- **scandal:** rare and public only.
- **posting / media / charity:** `followers` 1-4. Example: HS_116.

## 8. New scenarios to write

Each one needs a real tradeoff (time, Energy, Coach thinks you're distracted, an awkward moment), so
followers open choices rather than hand out free rewards.

| Scenario | Stage | `requires` | Suggested fields |
|---|---|---|---|
| **Autograph session** at a youth league / mall | HS, then pros | `followers_tier: hometown_hero` (HS); `verified` (pros) | `followers` 2-3; a choice to stay late (+Social, -Energy) or leave on time |
| **Podcast guest** (campus or local sports podcast) | college, pros | `followers_tier: rising_star` (college); `verified` (pros) | `followers` 2-4; a risky choice (hot take) with `conduct: "bad"` or Coach -2 |
| **Brand deal / NIL deal** (local sporting-goods shop, then a national brand) | HS (local), college (NIL), pros | `rising_star` (HS); `campus_celebrity` (college); `verified` (pros) | `deal` (kind `range`, `sp` or `fun`); a choice to turn it down to stay focused (+Coach) |
| **Awards show** | pros | `followers_tier: fan_favorite` | `followers` 4-6; Fun +, Energy -; a choice to skip it for training (+SP) |
| **Pro Bowl skills contest** (longest field goal) | pros | `followers_tier: fan_favorite` | `kick_challenge` kind `competition`, `[45, 50, 53, 55, 58]`, need 2, high, windy; pass `followers` 8; fail mild |
| Charity kick-a-thon (optional) | college | `followers_tier: campus_celebrity` | `kick_challenge` kind `competition`, easy; `conduct: "good"` at top level |
| "Nobody knows you yet" (optional) | HS | `max_followers_tier: local` | a first-post scenario |

## 9. `WRITING_GUIDE.md`

Add:
- the follower scale and tier table (section 1 and 4)
- when to use `conduct` vs `followers` vs `followers_exact`
- the kick challenge format, what goes at top level vs in the blocks, the stage distance table
- "fail is milder than skipping"
- the combine timing note

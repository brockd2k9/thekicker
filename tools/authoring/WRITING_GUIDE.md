# Kicker: scenario writing guide

You're writing off-field scenarios for **Kicker**, a football game where the player is a
placekicker going from high school freshman to the pros. Each week the player meets 1-2 short
scenarios and picks a choice; choices change their stats, set up how they kick on game day, and
can move the story along. This guide is everything a writer (person or AI) needs. Give this whole
file plus the template entries you want written to whoever is writing.

## The workflow

1. Copy a template to a work folder so regenerating can't overwrite you:
   `tools/authoring/hs_template_freshman.json` (25, start here) or `hs_template_all.json` (all 150)
   → e.g. `tools/authoring/work/freshman.json`.
2. Fill in `category`, `text` and `choices`. Leave `id`, `title` and `_info` alone.
   Unwritten entries can stay blank; they're skipped.
3. Check: `python3 tools/import_scenarios.py tools/authoring/work/freshman.json --dry-run`
4. Fix every ERROR it prints (warnings and lint notes are advice), then run it again without `--dry-run`.
   Lint notes catch style slips: he/she on a gender-neutral placeholder, a cast name written by hand,
   curly quotes, a game kick or its result, and a choice that beats another on every number (or all
   but one). `python3 tools/lint_scenarios.py` runs the same checks on scenarios already imported.
   For college scenes it also checks wrong-path choices (`conduct` bad or scandal must cost something
   lasting and must not win), party and peer-pressure scenes (there must be a clean "no") and results that
   show the player drinking or using. Titles are checked like text.
5. Run the game's tests: `godot --headless --path . res://tests/run_tests.tscn`, then play it.

`tools/authoring/examples.json` has three finished scenarios to copy from.

## One scenario

```json
{
  "id": "HS_005",                 // don't change
  "title": "The First Rival",     // don't change (the game keeps its own title)
  "_info": { ... },               // read-only: when it happens, requirements, flags, people
  "category": "team",
  "text": "{tyler}, the other freshman kicker, drills four straight from forty yards...",
  "choices": [ { ... }, { ... }, { ... } ]
}
```

- **category**: one of `social`, `school`, `training`, `health`, `work`, `media`, `family`,
  `money`, `team`, `romance`, `community`, `career`.
- **text**: the setup, 1-3 short sentences, second person ("you"), present tense, no choice hints.
- **choices**: 2-4 (3 is the norm). The template already has one choice per flag the scenario must
  set (see below), with that flag filled in.
- Optional: `"weight": 2` (more likely to come up; default 1), `"cooldown": 4` (weeks before it
  can repeat; scenarios are one-time by default anyway), `"when": ["bye"]` / `["offseason"]` (default:
  game weeks and byes; not for story events). An offseason comes *after* a season, and the last
  season of high school and of college has none (recruiting or the draft follows the last game), so
  an offseason scene in that season never comes up: use late weeks instead.

## `_info` (read-only, it tells you what the scenario has to do)

| Field | Meaning |
|---|---|
| `when` | Season and weeks it can happen ("Freshman year (season 1), weeks 1-5") |
| `story` | A story event: it is guaranteed to happen in its window |
| `requires` | What the player must have done first (flags) for it to appear at all |
| `must_set_flags` | **Every one of these must be set by some choice** (the importer checks) |
| `people` | Who's in the scene; their choices have a `rel` slot for them |
| `unlocked_by` / `leads_to` | The story chain: which scenario's flag opens this one, and what this one's flags do later: "unlocks HS_034 ... when helped_freshman", "blocks HS_034 ... when bullied_freshman", or "leads to ... (flavor only)" when the later scenario is open to everyone anyway |
| `notes`, `follow_up_hints` | Extra instructions (e.g. HS_160's locked choices) |

## One choice

```json
{
  "label": "Ask him to work on kicks together",       // the button, 2-7 words, an action
  "result": "He looks surprised, then shrugs. ...",   // what happened, 1-2 sentences
  "stats": {"football": {"accuracy": 1}, "personality": {"charisma": 1, "leadership": 1}},
  "skill_points": 2,                                  // optional: skill points earned
  "modifiers": ["focused"],                           // game-day modifier, at least one
  "set_flags": {"befriended_tyler": true},            // story flags (from must_set_flags)
  "rel": {"rival": 8}                                 // relationship changes
}
```

Optional choice fields: `"skill_points": 2` (see below), `"recruiting": 3` (recruiting points),
`"grades": 0.1` (GPA points),
`"requires"` + `"lock_text"` (a locked choice), `"follow_up": {"id": "...", "weeks": 2}`.
Empty slots and zeros left from the template are fine; the importer drops them.

### Choice rules (all checked except the last two)

1. **Every choice changes at least one stat** and **has at least one game-day modifier**.
2. **No choice is strictly best.** Each choice gives something and costs something. The importer
   warns when one choice beats another in every stat.
3. **The morally good choice is rewarded**, maybe not right away: standing up for someone, being
   honest, owning a mistake should pay off in Leadership/Charisma, relationships, a better story
   flag, or a later scenario, even if it costs Social or Fun today. Bad behavior can look fun
   short-term but should cost something that matters (relationships, Leadership, a worse chain).
4. Every choice is something a reasonable teen might do; no strawman options. Peer pressure must
   always have a decline option.

## Stats: scale and ranges

Stats run 0-100. Life stats swing a lot week to week; football stats grow mostly through **skill
points** the player earns and spends (see below); personality stats shape who the player becomes
(traits unlock at 55-60).

| Group | Stats | Typical per choice | Allowed (hard limit) |
|---|---|---|---|
| `life` | `health`, `energy`, `fun`, `social` | ±3 to ±8 (big night out: energy -15) | -20 to +15 |
| `football` | `power`, `accuracy`, `resilience`, `toughness` | +1 to +2 (rarely +3; -1 for a bad habit) | -2 to +5 |
| `personality` | `charisma`, `ambition`, `leadership`, `intelligence` | ±1 to ±3 | -4 to +6 |
| `recruiting` | recruiting points (0-100 score) | +2 to +5 | -3 to +8 |
| `grades` | GPA points (0-4 scale) | ±0.05 to ±0.2 | -0.2 to +0.4 |

2-5 stat changes per choice reads best. Positive football changes are valuable: use them for
real practice, film study, or learning from a mistake. Keep them small: skill points are the main
football reward now.

### Skill points (`skill_points`, optional)

Football attributes (Power, Accuracy, Resilience, Toughness) grow mainly through skill points:
the player earns them for kicks, practice and choices, then spends them on the Skills screen.
A choice can award them with `"skill_points": n` (a whole number, -2 to +6):

| Choice | Typical `skill_points` |
|---|---|
| Real practice, extra reps, film study, a training camp (category `training`) | +2 to +4 |
| Other choices where the kicker works on their game or learns from a mistake | +1 to +3 |
| Skipping practice / a bad habit (rare) | -1 or -2 |
| Everything else | leave it out |

It counts as a change for rule 1 below, and the choice card shows it as a chip. Leave it out
(or 0) when the choice isn't about getting better. Skill points and a small direct football
change can go together (`"football": {"accuracy": 1}` plus `"skill_points": 2`).

What the stats do: Power = field goal and kickoff range (a new freshman kicks 40 yards, a great
pro mid-60s); Accuracy = aim; Resilience = composure under pressure;
Toughness = wind and injuries; Energy, Health and Social hurt your kicking when low; Fun keeps
Resilience growing; Intelligence raises GPA.

## Game-day modifiers

Each choice sets how the player feels at the next game (a bye or offseason choice carries to the
next game). Pick what the choice would really do to someone the night before or the week of a game.

| Modifier | Effect on kicks | Use for |
|---|---|---|
| `rested` | cleaner aim, steadier | a good night's sleep, taking it easy |
| `focused` | calmer under pressure, steadier | studying, preparing, a clear head |
| `confident` | calmer under pressure, more time to kick | a win off the field, praise, standing up for yourself |
| `inspired` | calmer under pressure, a little more power | doing the right thing, support from people you care about |
| `dialed_in` | cleaner aim | extra technical work |
| `warmed_up` | cleaner aim, a little more power | good pre-game routine (rare in scenarios) |
| `loose` | slightly cleaner aim | relaxed, fun but not late |
| `fresh_legs` | a little more power | rest for the legs |
| `scouted` | less wind effect | studying conditions, film of the field |
| `pumped_up` | more power, shakier aim | hype, anger, rivalry |
| `spotlight` | more pressure, a little more power | media attention, big crowd expectations |
| `stressed` | pressure hits harder | conflict, worry, drama |
| `distracted` | more pressure, less time to kick | guilt, unresolved trouble, phone blowing up |
| `tired` | shakier, less power | a late shift, short sleep |
| `drained` | shakier, less time to kick | emotionally exhausting week |
| `late_night` | much shakier, less power, worse aim | up very late (big cost, use for real late nights) |
| `heavy_legs` | less power | overtraining legs |
| `cold_leg` | less power, worse aim | skipping warmup, kicking cold |
| `sore` | less power, worse aim, injury risk | playing through pain, overdoing it |

## Relationships (`rel`)

Ten people (one of them is your teammates as a group), each with a value 0-100 that starts at 50. Values change the game: a trusted coach
calms your kicks and sends you out for longer tries; a good holder means cleaner kicks; family keeps
your energy up; friends keep your fun and social life up; a teacher helps grades; Tyler as a friend
steadies you, as a rival pushes you to improve.

| `rel` id | Who | Placeholder |
|---|---|---|
| `coach` | Head coach (later: special teams coach) | `{coach}` → "Coach Rourke" |
| `team` | Your teammates as a group (Team standing; every made or missed kick moves it too) | `{team}` → "Teammates" |
| `holder` | Your holder | `{holder}` |
| `backup` | The backup kicker behind you on the depth chart (new each stage); takes your field goals if the coach benches you. Hidden until a scenario first gives them a `rel` change | `{backup}` |
| `teacher` | A teacher (college: academic advisor; none in the pros) | `{teacher}` → "Ms. Alvarez" |
| `best_friend` | Your best friend | `{best_friend}` |
| `rival` | **Tyler Brooks**, a kicker on your team; friend or rival by your choices | `{tyler}` (or `{rival}`) |
| `parent` | Dad | `{parent}` → "Dad" |
| `sibling` | Your little brother | `{sibling}` |
| `love_interest` | Someone special (first name only; keep it sweet, teen-appropriate) | `{love_interest}` |

- **Range per choice: -15 to +15. Typical: ±3 to ±8.** ±10 and up for a big moment (a betrayal,
  a real sacrifice for someone).
- `coach` and `team` also move with every field goal and extra point the player kicks (misses
  cost more than makes earn). Owning a missed kick in a scenario (`"rel": {"coach": 4}`) is how a
  player wins trust back. When field goal misses pile up the game sets the flag `kicking_slump`
  (HS_142 "The Coach Wants an Explanation" can then appear).
- Only give `rel` to people actually in the scene. The template pre-fills a 0 slot for each person
  in `_info.people`; leave 0 to skip.
- Tyler, someone special and the backup kicker stay hidden from the player until a scenario first
  gives them a `rel` change, so their first scene should include one.
- **The new quarterback** (HS_111, HS_132, HS_137; `_info.people: new_qb`) is a teammate with story
  flags only, no `rel`. Don't use `{...}` for him; give him a name in the text if you like, and
  keep it the same across his three scenes.
- Use placeholders for cast names; never write a cast member's name by hand (names are different
  in every career). Placeholders work in text, labels, results and lock_text.
- **Pronouns:** never use he/she (him, her, his, hers) for `{coach}`, `{teacher}`, `{holder}`,
  `{backup}`, `{best_friend}` or `{love_interest}`: their names come from mixed lists (a teacher can be
  "Ms. Alvarez" or "Mr. Okoye"), so a gendered pronoun is wrong in some careers. Use "they" or
  rephrase (repeat the placeholder, or write the line from "you"). `{tyler}` (Tyler Brooks),
  `{sibling}` (your little brother) and `{parent}` (Dad) are always male: "he" is fine for them.

## Flags (story memory)

- `set_flags` is how a choice is remembered: later scenarios check flags (`_info.leads_to`).
- **Use the flags in `_info.must_set_flags`**, each on the choice where it fits (the template
  already put one per choice; move them if another choice fits better). Two choices may set the
  same flag. A choice can set no flag (the "neutral" option).
- Don't invent flags: the importer rejects a flag that isn't expected here or used anywhere (that
  catches typos). If a new story thread needs a new flag, ask for it to be added to the graph.
- `{"some_flag": false}` clears a flag (rarely needed).

## Locked choices

A choice can require something; the player sees it greyed out with a lock and the reason:

```json
"requires": {"min": {"rel_coach": 55}}             // "Requires Head Coach 55+"
"requires": {"min": {"leadership": 55}}            // "Requires Leadership 55+"
"requires": {"flags": ["recruiting_values_clear"]}, "lock_text": "a clear recruiting plan"
                                                   // "Requires a clear recruiting plan"
```

`min` / `max` take any stat, `recruiting`, `gpa`, or `rel_<person>`. A flag requirement must have a
`lock_text` (players never see flag names). Keep at least two choices unlocked. HS_160 (The Next
Chapter) is built from locked choices: one per story ending the player earned, plus one open choice.

## Follow-ups

A choice can queue a short sequel a few weeks later: `"follow_up": {"id": "HS_003F", "weeks": 2}`.
The sequel is a new scenario in the same file with `"follow_up_only": true` and a new id (the
scenario's id plus `F`, e.g. `HS_003F`); give it a title, category, text and 2-3 choices. Use
follow-ups for direct consequences of one choice. To open a *graph* scenario (one with its own id
in the template), set the flag it requires instead.

## College (the COL_* story graph)

College scenarios are storylines from college life, not sequels to high school. Templates:
`tools/authoring/college_template_all.json`. The graph comes from `tools/college_graph/college_design.json`
(`python3 tools/college_graph/make_college_graph.py` regenerates the drafts in
`data/career/scenarios_college.json`, keeping what's written). Everything above still applies; this adds:

**The cast in college.** `{coach}` is the special teams coach, `{holder}` and `{backup}` are new people,
and `{teacher}` is the academic advisor (all new each stage). `{parent}`, `{sibling}`, `{best_friend}`,
`{love_interest}` and `{tyler}` carry over. `{coach}`'s relationship feeds the draft score, so a coach
hit is a real cost here. Other people (a head coach, a scout, a roommate) are named in the text or left
unnamed; never give them `{...}`.

**What college choices can move.**
- `"draft": n` (-10 to +6): draft points. College builds the draft score that decides the draft round.
- `"grades"`: GPA. Below 2.0 the player is academically ineligible and sits out games.
- `"conduct": "good" / "bad" / "scandal"`: followers and reputation. Bad and scandal cost followers; a
  scandal also ends the player's brand deals. Every wrong-path choice has one.
- `"followers": n` (-20 to +20, scaled by stage), `"followers_exact"`, and `"deal"`
  (`{"id", "name", "kind": "sp" / "range" / "fun", "value", "seasons"}`) for brand deals.
- `requires` can also use `"followers_tier"` / `"max_followers_tier"` (local, hometown_hero, rising_star,
  campus_celebrity, verified, fan_favorite, household_name).

**`"draft": true` versus `"draft": 3`.** Two different things share a name. On a *scenario*,
`"draft": true` means "not written yet" (the graph files use it; never put it in an import). On a
*choice*, `"draft": 3` means draft points. The importer rejects `"draft": true` on a choice and any
`"draft"` at scenario level.

**Parties, drinking and peer pressure.** Most college players are under 21, and the game never shows the
player drinking or using anything, at any age.
1. A scene can say there's drinking at a party (that's college), but no choice result shows the player
   drinking, using or getting drunk, and nothing is played for laughs or as a reward.
2. Every party or peer-pressure scene has a clean "no" with its own upside, written so the player isn't
   mocked for taking it.
3. The wrong choice is about the player's decision (staying out until 3 a.m. before a lift, covering for a
   teammate, taking a booster's cash), and its consequences are concrete: the coach finds out, scouts
   hear about it, a strike flag is set. It never describes a substance's effect.
4. A wrong choice may tempt (fun, social, Team today) but always costs something that lasts: negative
   `draft`, a `{coach}` or Team hit, or a flag a later scene reads. It never wins on every number.
5. The blocked-word list (`data/career/content_rules.json`) is unchanged: write around it.

**Mental health.** Pressure, panic, burnout and homesickness are real themes. There is always a healthy
option (a counselor, the trainer, a teammate, family), it is never mocked, and brushing it off is a
choice with a cost, not a moral failing.

**The wrong path.** Bad choices set *strike* flags (`missed_curfew`, `took_improper_benefit`,
`academic_shortcut`... the list is in the design file). A strike opens The Coach's Office; owning it or
deflecting leads to The Pattern / The Second Strike, then The Final Warning; the worst choices set
`character_concerns` (the label scouts and the pros see), and The Long Way Back clears it and sets
`rebuilt_reputation`. Each step clears every strike flag, so only a new strike opens the next one. A
choice that sets a strike must have `"conduct": "bad"` or `"scandal"` (the importer checks).
**Adding a strike** means adding it to `strike_flags` and to the `any_flags` of the four steps in the
design file, regenerating, and re-importing COL_036, COL_071, COL_017 and COL_086 so their choices
clear it too: the importer rejects a step that clears some strikes but not all, and the graph check
warns about one already in the game.

**High school callbacks** are only ever locked choices inside an open scene (`requires` + `lock_text`),
never a gate: a player without the flag still gets the whole scene. The template pre-shapes them.

**Things the game doesn't have.** No redshirts, transfers, bowl games or early draft entry: write those
as other players' stories or as temptations, never as something that happens to the player. As in high
school, never describe a game kick or its result.

## Content rules (teen audience)

- No drugs, alcohol, vaping or smoking for the player; no sexual content; no graphic violence; no
  gambling. Parties are fine, but nothing illegal for the player.
- Romance stays sweet: dates, dances, nerves, a breakup.
- Fights: a scuffle can be threatened, and walking away is always an option; no injuries described.
- No slurs or real-world brands, teams or people.
- The importer blocks words from `data/career/content_rules.json` (e.g. beer, vape, gun, gamble).

## Style

- Short. A scenario is read in ten seconds on a phone.
- Specific football and high school details beat generic drama (the snap, the holder's laces, the
  bus ride, film sessions, the guidance counselor).
- Results show consequences, not lectures. Let the stats and later scenarios carry the moral.
- Vary the tone: funny, tense, warm, awkward.

## For an AI writer

Paste this guide, then: *"Fill in category, text and choices for these template entries. Follow
every rule in the guide. Return only the JSON in the same format."* Paste a few template entries
(5-10 at a time works best), then run the importer with `--dry-run` on the result and send back
any errors to fix.

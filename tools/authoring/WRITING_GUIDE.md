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
  game weeks and byes; not for story events).

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

Nine people (the ninth is your teammates as a group), each with a value 0-100 that starts at 50. Values change the game: a trusted coach
calms your kicks and sends you out for longer tries; a good holder means cleaner kicks; family keeps
your energy up; friends keep your fun and social life up; a teacher helps grades; Tyler as a friend
steadies you, as a rival pushes you to improve.

| `rel` id | Who | Placeholder |
|---|---|---|
| `coach` | Head coach (later: special teams coach) | `{coach}` → "Coach Rourke" |
| `team` | Your teammates as a group (Team standing; every made or missed kick moves it too) | `{team}` → "Teammates" |
| `holder` | Your holder | `{holder}` |
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
- Tyler and someone special stay hidden from the player until a scenario first gives them a `rel`
  change, so their first scene should include one.
- **The new quarterback** (HS_111, HS_132, HS_137; `_info.people: new_qb`) is a teammate with story
  flags only, no `rel`. Don't use `{...}` for him; give him a name in the text if you like, and
  keep it the same across his three scenes.
- Use placeholders for cast names; never write a cast member's name by hand (names are different
  in every career). Placeholders work in text, labels, results and lock_text.
- **Pronouns:** never use he/she (him, her, his, hers) for `{coach}`, `{teacher}`, `{holder}`,
  `{best_friend}` or `{love_interest}`: their names come from mixed lists (a teacher can be
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

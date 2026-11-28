# Scenario impact, callbacks and the reading popup (for the scenario session)

The scenario popup now reads like a scene instead of a form. This note is what
a writer needs to tag scenes so the game treats them right. Every field here is
optional; untagged scenes behave as "normal".

## How the popup reads

* Headline (the title), then the setup in **beats** of at most about 120
  characters (2 to 3 lines on a phone). Longer text is split at sentence ends
  and revealed one beat at a time (tap to continue; a tap mid line finishes it).
  Write sentences that end cleanly so the beats land.
* The **key phrase** is highlighted in red. Default: the last sentence (the
  choice the player faces), or its last clause when that sentence runs over 90
  characters. Pick your own with `key`.
* The **speaker strip** (portrait tile, name, role tag) shows the first cast
  member the text names (`{coach}`, `{love_interest}`...). Pick another with
  `speaker`, or `"speaker": ""` for none.
* Choice cards show the **label only** plus stakes chips: Football, Life,
  Personality, Grades, one chip per person, Money, Fans, Conduct. Safe choices
  show the number (`Coach Vance +5`, `Money +$50K`); risky ones show direction
  only (`+`, `−`, `±` when it goes both ways). Keep labels short: they now carry
  the whole choice.

## Scene fields

| Field | Values | What it does |
|---|---|---|
| `impact` | `"minor"`, `"normal"` (default), `"major"` | How hard the scene hits. See below. **Not `weight`**: `weight` already exists and is the pick frequency (a number). |
| `key` | a phrase copied exactly from `text` | The highlighted phrase. |
| `speaker` | a cast id, or `""` | The speaker strip. |

## Choice fields

| Field | Values | What it does |
|---|---|---|
| `callback` | the rest of "Because you ..." (90 characters at most, no "Because") | When a later scene fires because of this choice, it shows "Because you skipped the party for extra reps." under the headline. |
| `risky` | `true` / `false` | Force the card to hide or show exact numbers. |

**Callbacks.** A later scene "fires from" a choice when it requires a flag the
choice set (`requires.flags`, `any_flags`, also inside `any_of`) or is the
choice's `follow_up`. The most recent such choice wins. With no `callback`
text, the line reads: Because you chose "Finish the assignment first" in
Homework or the Field?. So every flag gated scene already gets a reminder;
`callback` makes it read naturally. Write it in the past tense, second person
implied: `"put homework ahead of extra reps"`.

## Impact: what each value does

| | minor | normal | major |
|---|---|---|---|
| After a pick | toast with the changes only | full result **only when a rule below triggers**, else the toast | full result always |
| Stat changes (life, football, personality) | × 0.75 | × 1.0 | × 1.35 |
| Choice cards | numbers on safe choices | numbers on safe choices | direction only on every choice |
| Look | normal | normal | darker screen, red frame, MAJOR MOMENT tag, slower reveal, sound and haptic |

A suspension, a new trait and a kick challenge always get the full screen,
even in a minor scene. Relationships, money, followers, flags and progress
points are never scaled by impact; only stats are.

**Normal scene: the full result shows when the choice** (CareerTuning,
"Scenario Impact"):

| Rule | Threshold |
|---|---|
| sets or clears any flag | any `set_flags` |
| has a conduct tag | any `conduct` |
| suspends | any `suspend_weeks` |
| moves draft points | any `draft` |
| moves recruiting points | 3 or more either way (`result_recruiting_min`) |
| moves money | $100,000 or more either way (`result_money_min`) |
| moves one relationship | 6 or more either way (`result_rel_min`) |
| moves followers | buzz 4 or more either way (`result_followers_min`), or reaches a new follower tier |
| signs a brand deal, queues a follow up | always |

**Rules of thumb for tagging**

* **minor**: everyday texture that repeats (lunch, a study session, a small
  favor). No flags, no conduct, no money. Each choice must trade something; the
  lint flags a minor scene where one choice wins on every number
  (`best_choice`, "minor scene").
* **normal**: most scenes.
* **major**: turning points the player should feel: signing day decisions, a
  scandal, a contract year blowup, a family crisis, the first time a scout
  calls. Aim for about 1 in 15 scenes.

**Risky** (direction only, no numbers) is automatic for: every choice in a
major scene, a kick challenge, bad or scandal conduct, a suspension, character
concerns, losing $100,000 or more, a person dropping 6 or more, followers buzz
of −4 or worse. Use `"risky": true` for a choice whose danger is in the story
rather than the numbers.

## Tools

* `python3 tools/import_scenarios.py <file>` accepts `impact`, `key`,
  `speaker` (scene) and `callback`, `risky` (choice) and checks them.
* `python3 tools/lint_scenarios.py --all --only best_choice,dominated` lists
  one sided scenes. Today: 0 `best_choice`, 0 `dominated` across all 1,224
  written scenes.
* `godot --headless res://tools/career_sim.tscn -- impact=guess` simulates with
  estimated tags for untagged scenes (`ScenarioEngine.guess_impact`); the
  report's "Scenario impact" table shows how often the full result appears.

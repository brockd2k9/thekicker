# Pro stage scoping (story graph)

Scoping only: nothing here is written or generated yet. Engine facts below were read from
`scripts/career/` on main (career_manager, scenario_engine, career_data, bench, kick_trust,
followers, relationships) and `docs/story_handoff_followers_challenges.md`.

## 0. What the pro stage is today

- **Length.** A pro career ends at `pro_age_cap` 38 (checked at each season's end), after
  `free_agent_attempts` 2 failed tryouts, after `career_end_poor_streak` 3, or when the player
  chooses to retire on the contract or draft screen. Players reach the pros at about 22, so the
  longest career is about **16 pro seasons**. A year in free agency also costs a year of age.
  **20 seasons needs `pro_age_cap` of about 42 (a gameplay tuning change).** The plan below works
  for either cap: veteran scenes gate on age, not season count.
- **Pacing.** About 1.4 scenarios a game week, 2 in the bye and 2 in the offseason, so about
  **18 scenario slots a season** and about 290 (16 seasons) to 360 (20 seasons) for a long career.
- **Contract loop.** At season end: released (retention below 35), re-sign offer (contract over,
  retention 50+), not re-signed, or continue. Released / not re-signed players go to free agency:
  one open tryout a year with a club they haven't failed with. **There are no trades, holdouts,
  extensions mid-contract or comebacks after retirement.** A move to a new club happens only
  through release and re-signing elsewhere.
- **A new club is a new stage entry.** Signing with a club calls `_enter_stage(pro)`, which
  resets `season_in_stage` to 0, replaces the per-stage cast (coach, holder, backup, team) with
  new people, and ends every brand deal. So `"seasons"` in a pro scenario means *seasons with this
  club*, not seasons in the pros. Persistent cast: parent, sibling, best_friend, love_interest,
  rival ({tyler}).
- **Existing content.** 13 pro scenarios in `scenarios_pro.json` (9 hand-written, plus the 4 that read the
  college wrong path). The engine only loads the files listed in `CareerContent.SCENARIO_FILES`, so a pro story graph goes in
  `scenarios_pro.json` with PRO_* ids, the same way COL_* went into `scenarios_college.json`.
- **Kick challenges** (new, from gameplay): a choice can carry `kick_challenge` (real kicks,
  pass / fail outcomes with their own `set_flags`). Ideal for tryouts, contract-year auditions,
  a comeback workout, the skills contest.

## 1. Career-state triggers: what `requires` can read

`requires` reads: `min` / `max` on stats, `age`, `retention`, `draft`, `recruiting`, `gpa`,
`followers` and `rel_<person>`; `traits` / `any_traits`; `flags` / `any_flags` / `not_flags`;
`followers_tier` / `max_followers_tier`; `any_of`. A scenario's own fields add `stages`
(`pro`; `free_agent` gets no weekly scenarios), `seasons` (with this club), `weeks` and `when`
(season / bye / offseason).

| Trigger | Readable now? | How, or what's missing |
|---|---|---|
| Age, veteran years, decline | **Yes** | `min` / `max` `age` (aging starts at 30) |
| Retention (standing with the club) | **Yes**, with a lag | `min` / `max` `retention`: the score is recomputed only at season end, so mid-season it is last season's |
| Season number | **Partly** | `seasons` = seasons *with this club*. Career pro seasons: **no** |
| First season in a new city | **Yes** | `seasons: [1, 1]` plus `min age` or a flag (a rookie and a veteran newcomer both have season 1) |
| Slump | **Partly** | engine flag `kicking_slump` (and `kick_slumps`, a count) from KickTrust. Sticky: it means "ever had one", never "in one now" |
| Coach losing faith | **Partly** | engine flag `coach_lost_faith` (sticky) |
| Benched / won the job back / lost the audition | **Partly** | engine flags `benched`, `benched_for_tyler`, `won_job_back`, `lost_audition` (sticky) |
| Hot streak, a run of makes or misses | **No** | `recent_fg` / `fg_history` exist but aren't readable |
| Season FG%, in a slump right now, benched right now, injured | **No** | `bench.weeks_left`, `coach_doubt`, `injury` exist but aren't readable |
| Contract year, years left, salary, how signed | **No** | `contract.years_left`, `salary` exist but aren't readable |
| Released before, number of clubs | **Partly** | engine flag `failed_tryouts` (list) and `fa_attempts` only |
| Award lists (Pro Bowl, All-Pro) | **No system** | closest: `followers_tier` (`fan_favorite`) and the handoff's skills-contest kick challenge |
| A younger kicker brought in | **Partly** | the per-club `{backup}` and the bench system; no "competition" state |
| Trades, holdouts, extensions | **No system** | |
| Forced out / retirement / comeback | **No scenes possible** | retirement and free agency are screens, not weeks; no scenario runs there |
| City / club name in text | **No** | clubs have `name` and `town` in `world.json`, but only cast names are placeholders |

**Workaround that needs no code:** a repeatable scene that requires a sticky engine flag and
clears it on every choice (`"kicking_slump": false`) fires once per *new* slump, because the
engine sets the flag again next time. This works for slumps, benching and lost faith. **Needs a
gameplay OK first:** I need to confirm that no engine code reads those flags after setting them.

**Gameplay request (small, data-read only):** add these keys to `CareerData.metric()` so `min` / `max` can read them:
`pro_seasons` (career), `contract_years_left`, `salary`, `fg_streak` (+n makes / -n misses in a
row), `season_fg_pct`, `benched_now`, `slump_now`, `injured_now`, `clubs` (count). Set engine
flags at transitions: `contract_year` (season start with 1 year left), `re_signed`, `released`,
`signed_new_club`. Add `{club}` and `{town}` placeholders. Optional: `pro_age_cap` 42 for 20 seasons.
Trades, holdouts and comebacks would be new systems; I'd leave them out (like redshirts in
college) and write them as other players' stories or as temptations.

## 2. Money

**There is no money stat.** Salary exists only inside `contract` (shown on the contract screen,
bumped by followers tier); nothing accumulates, and no choice field can cost money. Brand deals
can't stand in for debt: they end on a scandal or a new club and use deal slots.

**Without a gameplay change**, money scenes can show loss through:
- flags that later scenes read (`lost_savings`, `bad_venture`, `advisor_stole`,
  `honest_advisor`, `paid_family_debts`)
- stress costs (fun, energy, `stressed`), relationship costs (parent, love_interest), and
  retention costs (distraction)
- `followers` and `conduct` for public embarrassments (a failed restaurant, a lawsuit).

They read well but nothing on the Hub shows the fortune shrinking.

**Recommended gameplay change:** a `savings` number in CareerData.
- Add each pro season's salary minus a flat cut for taxes and agent.
- Add a choice field `money`: a fraction of savings, e.g. `-0.4` for the stolen fortune, or a fixed amount.
- Make `savings` readable in `min` / `max`, and show it on the Hub and in the career summary
  ("Net worth at retirement").

It's about the size of the `followers` field. Until then, write money scenes with flags and stress
costs so they work now, and add `money` values when it lands (the same approach as the suspension request).

## 3. Repeating over 16-20 seasons

Scenario text is fixed (only cast names fill in), each scene fires at most twice a season, and
categories decay within a season. Three kinds of scene:

1. **One-time chapters (`once`, about 100):** milestones that happen once in a life:
   - the rookie arrival and first contract
   - the first release, the first new city, moving the family
   - a wedding, the first child
   - the advisor who steals, the restaurant
   - the comeback workout, the retirement decision
   - the rival's chapters, the mentoring arc, the pro wrong-path steps

   Each gates on state (age, flags, retention), not on a fixed year, so it lands wherever the
   career is.
2. **Age-banded variants (about 30, 10 situations x 3 versions):** the same situation in a
   rookie (21-25), prime (26-30) and veteran (31+) version, each its own one-time id with
   different text and stakes. For example, *Contract Year*:
   - rookie: "prove you belong"
   - prime: "the big payday"
   - veteran: "one more year, for less"

   Other situations: the slump, the new kicker in camp, the media day, family money asks,
   the holdout talk (as a temptation), the new city.
3. **State-driven repeatables (about 20, not `once`, `cooldown` 10-20 weeks):** a scene that
   re-fires whenever its state comes back. Examples: the slump talk, the hot-streak attention,
   benched again, the old friend asking for money, the rookie asking for advice, the contract year.

   Each clears its trigger flag so it waits for the next occurrence. Each has 3-4 locked choices
   that open with experience (`kick_slumps` count, age, flags from earlier chapters), so the tenth
   slump reads differently from the first.

**A gameplay option that would help:** `once_per_club`, a once that resets on a new club, for
arrival scenes (new locker room, new holder, new city) that should play at every club.

## 4. The pro wrong path

It mirrors college, with the league as the authority:
- pro strike flags lead to a team fine, then league discipline, then release
- a `character_concerns` equivalent the next club reads
- a long-way-back step

College flags set severity:
- `character_concerns` / `last_chance`: the club has less patience, and the first pro strike skips straight to discipline.
- `rebuilt_reputation` / `took_responsibility_scout`: the club gives the benefit of the doubt.
- `owned_mistake`: a locked "I've been here before" choice.

Same rules as college:
- the player is never shown using anything
- every pressure scene has a clean "no"
- wrong choices tempt but cost something lasting (retention, the coach, flags, and `money` once it exists)

Without a suspension mechanic, discipline lands as retention hits, which can mean release (retention below 35).

## 5. Proposed size and spread

**About 150 PRO_* scenes**, the same scale as high school and college:

| Group | Scenes | Includes |
|---|---|---|
| Arrival and rookie years | 15 | camp, rookie duties, first contract, the veteran who helps or hazes |
| Performance states | 20 | slump, hot streak, benched, new kicker in camp, award buzz, the skills contest |
| Contract and business | 20 | contract year, re-sign, release, free-agency tryout scenes (in the offseason before / after), a new club, moving cities |
| Money | 18 | big checks, family asks, agents good and bad, advisors (one steals), ventures (restaurant, dealership, a friend's start-up; one good one), lawsuits, taxes |
| People | 25 | partner and marriage, kids, parent aging, sibling, old friends who show up, mentoring a kicker or holder, {tyler} |
| Locker room and the business | 17 | flawed teammates, a coach fired midseason, loyalty vs the paycheck, a strike-year-style labor fight told through teammates |
| Wrong path (pro) | 15 | the temptations and the 4-5 steps above |
| Veteran and the end | 20 | decline, the younger kicker, the last contract, planned retirement, forced out, the comeback workout (as a kick challenge before the retirement screen), the farewell |

About 50 of these are age-banded variants or repeatables, so a 16-20 season career sees about
110-130 different scenes plus repeats.

**Tone:** a locker room of flawed adults; a business that treats players as replaceable; loyalty
against the paycheck. Original scenes only. No game or kick results in text, the pronoun rule,
`{parent}` not "Dad", and the same lint.

## 6. Open decisions

1. Raise `pro_age_cap` for 20-season careers? (gameplay)
2. Add `savings` and the `money` field? (gameplay; recommended)
3. Expose the career-state metrics and transition flags in section 1? (gameplay; recommended)
4. Allow scenes to clear the sticky engine flags (`kicking_slump`, `benched`, `coach_lost_faith`)?
   (gameplay confirmation)
5. `once_per_club`? (gameplay; optional)
6. Spouse and kids: reuse `love_interest` as the partner (a pro role "Partner") and keep kids in
   text, or add new cast members (people.json plus their weekly effects in code)?

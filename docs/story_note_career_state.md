# For the story session: readable career state (stage 5A)

Everything here is engine-side and on main. Your importer / validator need to accept the new metric
names, `once_per_club`, and the new engine flags (list at the end).

## "Right now" metrics (`requires.min` / `requires.max`, also inside `any_of`)

| Name | Value |
|---|---|
| `slump_now` | 1 while the coach doubts your kicking (a slump), else 0 |
| `benched_now` | 1 while benched (the backup has your field goals), else 0 |
| `injured_now` | 1 while injured, else 0 |
| `fg_streak` | your field goals in a row in games: +n makes / -n misses (extra points don't count) |
| `season_fg_pct` | this season's field goal %, 0-100 (0 before the first attempt) |
| `pro_seasons` | pro seasons finished (career total) |
| `contract_years_left` | years left on the pro contract (0 outside the pros) |
| `clubs` | pro clubs played for (career total) |

Examples: `"requires": {"min": {"slump_now": 1}}` (only during a slump),
`"requires": {"max": {"fg_streak": -3}}` (three misses in a row), `"min": {"clubs": 2}`.

## Game-set flags (read with `requires.flags` / `not_flags`)

| Flag | True when |
|---|---|
| `contract_year` | this pro season started with 1 contract year left (false otherwise) |
| `re_signed` | the player re-signed: true through the next season, then false |
| `signed_new_club` | the player signed with a pro club after playing for another one: true through the first season there |
| `released` | released or not re-signed, ever (stays true) |
| `was_dismissed` | a `dismissed` flag was carried out (stays true) |

`pro_clubs` is a list of club names the engine keeps (use the `clubs` metric instead).

## Placeholders

`{club}`: the player's team (the school in high school and college, the club in the pros).
`{town}`: its town.

## `once_per_club` (scenario field)

`"once_per_club": true`: the scene plays once at each club. After the player joins a new club
(college, junior college, a new pro club) it can play again. Old saves: a scene already seen counts
as seen at the current club. Use it for arrival scenes (new locker room, new holder, new city).

## `dismissed` (story flag)

Set `"set_flags": {"dismissed": true}` after a severe wrong-path run. It acts at season end:
- **Pros:** released, however well the player kicked (the contract screen says "You were
  dismissed from the team"). Then free agency as usual.
- **College:** out of the program at the end of that season (any season, not only senior year) and
  out of the draft: draft day sends the player to an open tryout. The draft screen says why.
- **High school / junior college:** no effect (don't set it there).
The player sees a red notice and a "Dismissed" chip on the Hub the moment it's set, and a line on
the season summary. The engine clears `dismissed` after carrying it out and sets `was_dismissed`.

## Clearing the slump and bench flags

Scenes may clear `kicking_slump`, `coach_lost_faith` and `benched` (set them to false). **The
engine's state wins:** while the coach still doubts you, a bad stretch is still fresh, or you're
still benched, the engine sets them back to true (after every choice and at the start of each week).
Once the slump or bench is over, clearing sticks. For "right now", use `slump_now` / `benched_now`.
`kick_slumps` is a count: leave it alone. `benched_for_tyler`, `won_job_back`, `lost_audition` are
"it happened" markers the engine never reads: clear them freely.

## Engine flags list (for your graph validator)

walk_on, juco, failed_tryouts, fa_attempts, recruiting_update, traits_reported, kicking_slump,
kick_slumps, coach_lost_faith, benched, benched_for_tyler, won_job_back, lost_audition,
contract_year, re_signed, released, signed_new_club, pro_clubs, was_dismissed, reputation_week,
reputation_text (the last two: internal, for the Results line).

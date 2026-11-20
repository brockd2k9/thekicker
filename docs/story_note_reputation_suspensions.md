# For the story session: reputation flags and `suspend_weeks`

The engine now reads the college wrong-path flags and a new choice field (`scripts/career/reputation.gd`;
numbers in `tuning/career_tuning.tres`, group "Reputation"). Nothing to change in existing scenes for
the flags. `suspend_weeks` is new: your importer, validator and template need to accept it.

## The two flags

| Flag | Set it | What the player gets |
|---|---|---|
| `character_concerns: true` | a bad choice after an earlier warning (as now) | **-8 draft stock on draft day**, and **-6 pro standing** in the first 2 pro seasons. A red "Character concerns" chip on the Hub, a notice when it's set, and a line on the draft screen. |
| `character_concerns: false` | a recovery scene | the penalty is gone ("The character concerns are behind you") |
| `rebuilt_reputation: true` | the player earns the way back | **no draft penalty** (it wins over `character_concerns`), and **+2 pro standing** in the first 2 pro seasons. A green "Rebuilt reputation" chip, a notice, and a draft-screen line. |

The engine tells the player what each one means: a notice on the Hub and a line on that week's
Results the moment the flag is set. Don't explain numbers in result text.

Simulator, same kickers on draft day: drafted 46% with a clean record, 37% with concerns, 46% with
a rebuilt reputation. So the way back pays off fully on draft day, plus the early pro standing.

**Please check the wrong path's own draft points.** Careers that reach draft day with concerns are
drafted 2% of the time even with the engine penalty turned off, and the few that reach "rebuilt"
(6-10 per 360 careers) were not drafted either. The scenes' own `"draft": -N` values already sink
these careers. For the way back to feel worth it, give the recovery and rebuilt scenes some draft
stock back (for example `"draft": 3` to `5` on the rebuilt choice), or soften the earlier penalties.

`scouts_red_flag` and `college_warning` / `owned_mistake` have no engine effect (story only).

## `suspend_weeks`

A choice field (also allowed in a kick challenge's `on_pass` / `on_fail`):

```json
{"label": "Get in the car", "suspend_weeks": 2, "conduct": "bad", "set_flags": {"...": true}, ...}
```

| Rule | |
|---|---|
| Value | a whole number, **1-3** (the engine caps it at 3, also when suspensions stack) |
| When | the player sits out their **next n games**: picked during a game week, that week's game is the first; picked in the offseason, week 1 is the first. Byes don't count. |
| The game | played without the player, like sitting out for grades: no kicks, no game skill points, no followers from kicks; it never counts as a benched week or toward a slump. Practice skill points still count. Fun -4, Social -2, Team -2 per game. |
| Notice | "SUSPENDED for 2 games (The Balcony Dare). You sit out: ..." on the Hub (the scenario's title is the reason), a red SUSPENDED banner on the Hub while it lasts, and "You sat out: suspended (...)" on Results. |
| A new stage | clears it |

Importer / validator: accept `suspend_weeks` on choices and in `on_pass` / `on_fail`; error unless it's
a whole number 1-3. Use it only for the worst choices (it costs real games), usually together with
`conduct: "bad"` or `"scandal"`. The template and `WRITING_GUIDE.md` should show one example.

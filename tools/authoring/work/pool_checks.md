# Checks after the cross-era pool (before eras 5 and 6)

Content at the time of the checks: 1071 written scenes, 706 of 828 PRO written (eras 1-4 complete, cross-era pool 106 of 108, eras 5 and 6 not started). PRO_123 The Card Game and PRO_170 The Office Pool are held as drafts: each one's bad choice would show the player gambling for winnings.

## 1. 20-season repeat check

Long-career copy of the game (releases switched off, careers end after 21 pro seasons), 4 seeds, 215 pro careers, 213 of them reaching 20+ seasons. The game itself was not changed.

| Seasons | Careers | Scenes per season | PRO graph | other pro | shared/trait | Already seen earlier in the career | Scenes seen 3+ times by end of band |
|---|---|---|---|---|---|---|---|
| 1-5 | 215 | 18.0 | 84% | 7% | 9% | 6% | 1.2 |
| 6-10 | 215 | 18.0 | 86% | 5% | 8% | 12% | 3.9 |
| 11-15 | 215 | 18.0 | 84% | 5% | 10% | 18% | 8.4 |
| 16-21 | 215 | 17.7 | 54% | 17% | 30% | 65% | 25.4 |

Seasons 1-15 hold up (6%, 12%, 18% repeats). Seasons 16-21 jump to 65% because pro season 16 falls at age 36-37 in every long career, so seasons 17-21 are ages 38-42: era 5 and era 6, which are still empty. That band is the gap eras 5 and 6 are meant to fill.

Most repeated scenes, average times seen per 20-season career by the end of each band:

- **1-5:** Offseason Training 2.8, Summer Break 2.1, PRO_205 The Offseason Plan 0.8, Holder Chemistry 0.7.
- **6-10:** Offseason Training 3.2, Summer Break 2.5, Holder Chemistry 2.1, Family and Finances 1.0, PRO_205 1.0.
- **11-15:** Offseason Training 5.2, Summer Break 3.8, Holder Chemistry 3.3, Family and Finances 1.7, PRO_067 Family Asks for Money 1.3, PRO_206 The Film Room 1.3, PRO_207 The Fan Letter 1.3.
- **16-21:** Offseason Training 9.5, Holder Chemistry 8.5, Summer Break 8.4, Family and Finances 5.0, PRO_067 4.4, PRO_207 4.3, Trade Rumors 4.2, Team Hospital Visit 4.2, PRO_083 Old Friend's Ticket Requests 4.2, Postgame Questions 3.8.

The two shared offseason scenes and Holder Chemistry are the ones to watch even after eras 5 and 6 land: one each per offseason is by design, but Holder Chemistry at 8.5 is a hand-written repeatable with one text.

## 2. Flag audit

Full listing: `tools/authoring/work/flag_audit.md`. The reachability check is static: it follows requirements and flags, and treats ages, seasons, standing and followers as reachable.

**Flags read that nothing sets: 2**, both because of the held drafts: `pro_casual_bet` (PRO_170) and `pro_gambling_debt` (PRO_123). PRO_124, PRO_125, PRO_126 and PRO_268 list them among their "any strike" flags, so nothing breaks; those two routes simply don't exist yet.

**Flags set that nothing reads: 102.**
- **High school (62):** mostly the upstream high school graph's choice flags, plus recruit_impressed_*, camp_regional and camp_showcase.
- **College (21):** the pivot flags kept for pro callbacks that no pro scene reads yet: asked_for_honesty, drove_teammates_home, held_teammate_accountable, hid_panic, hosted_recruit_well, left_party_early, recommitted, refused_improper_help, reported_runner, reported_tampering, told_trainer_col, took_mental_health_day and waited_for_agents. Also caught_yourself, owned_it_again, found_another_ride, ready_for_pros, still_proving_it and scouts_accuracy / scouts_interview / scouts_power.
- **Pro (19):** business_fraud_victim, enjoying_single_life, fired_agent, froze_out_veteran, hired_private_coach, lived_modestly, paid_family_debt, pro_captain, pro_caught_with_package, pro_hearing_done, radio_show, repaired_relationship, reported_bookie, reported_package, saved_big_check, saved_rookie_check, spent_rookie_check, sued_advisor and tyler_division_rival.
- Most of these suit callbacks in eras 5 and 6 and the R10 epilogue. None of them blocks anything.

**Reachability:**
- **Any player:** all 1071 written scenes are reachable.
- **No wrong-path flags** (never takes a bad or scandal choice or a strike):
  - 26 scenes unreachable, every one a wrong-path follow-up: the college discipline chain (COL_017, 036, 071, 078, 084, 086, 106), the pro discipline and affair chains (PRO_124-130, 160-162, 165, 172, 174, 175, 268), and the college-history pro scenes (PRO_015, pro_old_crowd, pro_rookie_symposium, pro_reporters_question).
  - No clean scene is cut off.
  - 11 locked choices never open for this player. All of them are wrong-path callbacks, for example PRO_121 'Remember how that ended' (street_race).
- **No wrong path, with a partner from the start of the pros:**
  - Adds only the 5 single-player scenes: PRO_152, 153, 154, 345 and 581.
  - PRO_174 also drops; it's the single-player hearing, and its partnered twin PRO_175 takes over.
- **No wrong path, never with a partner:** 78 pro scenes unreachable, all gated on a partner, marriage, engagement or a child (became_parent needs a partner). Nothing else drops.
- **Each college wrong-path ending, then clean in the pros:** no pro scene is lost compared with a clean college player.
  - Every ending opens PRO_015, pro_reporters_question and pro_rookie_symposium.
  - The character_concerns endings also open pro_old_crowd and the locks PRO_042 'Ask {coach} what they heard' and PRO_124 'Say you've been here before'.
  - Endings checked:
    1. Warned and owned it (college_warning, owned_mistake): 717 of 733 pro scenes reachable.
    2. Character concerns: 718 of 733.
    3. Red flag with the scouts: 718 of 733.
    4. Rebuilt reputation: 718 of 733.
    5. Took responsibility at the red-flag interview (scouts_red_flag, took_responsibility_scout): 717 of 733.

Found while writing the pool and fixed before import: several pool scenes assumed a partner or children for players who may have neither (PRO_018, 039, 045, 046, 096, 120, 211, 244, 246, 252, 257, 282). They now use {parent}, {sibling} or {best_friend} where the scene has no partner requirement.

## 3. Scenes that name a specific age, club, city or season number

Scan of every written scene (titles, premises, labels, results) in all stages. **No real club, league or city names anywhere**: clubs and towns only appear as `{club}` and `{town}`. The only proper names are invented people (for example the high school coach Ray Hollis).

Numbers that don't describe the player (a holder's six years, a fan's thirty years in the same seat, forty pages of a contract, a teammate who is twenty-two, kick distances, times of day) are left out below. Everything that states the player's own age, years in the league, years with a club or a past event is listed against the scene's requirements.

### Doesn't fit every career the scene can fire in (suggested fix in brackets)

| Scene | Says | Fires at | Problem |
|---|---|---|---|
| PRO_038 Contract Year: One More | "At thirty-six" | ages 35-37 | wrong at 35 and 37 [drop the number: "This late in a career"] |
| PRO_072 Broke at Thirty-Three | title | ages 30-33 | wrong at 30-32 [retitle "Broke at Thirty-Something" or "Broke in Your Prime"] |
| PRO_133 The Younger Kicker in Camp | "At thirty-five" | ages 35-37 | [drop the number] |
| PRO_140 The Comeback Workout | "signed this summer at thirty-five" | ages 34-37 | [drop "at thirty-five"] |
| PRO_180 The Veteran Slump | "A slump at thirty-five" | ages 35-37 | [drop the number] |
| PRO_185 Still Got It | "A month without a miss at thirty-six" | ages 35-37 | [drop the number] |
| PRO_197 The Veteran Signing | "signed you at thirty-six" | ages 35-37 | [drop the number] |
| PRO_259 The Recovery Clinic | "your thirty-six-year-old leg ... feel twenty-eight" | ages 34-37 | [say "your veteran leg ... feel ten years younger"] |
| PRO_416 The Retirement Rumors | "You're thirty-one" | ages 30-33 | [drop the sentence] |
| PRO_444 The Training Load | "At thirty-six you have to choose" | ages 34-37 | [drop the number] |
| PRO_692 Doubts at Thirty | title | ages 30-33 | [retitle "Doubts in Your Thirties"] |
| PRO_693 The Thirty-Something Streak | "better than ever at thirty-two" | ages 30-33 | [drop the number; the title "Thirty-Something" already fits] |
| PRO_695 Hurt at Thirty | title | ages 30-33 | [retitle "Hurt in Your Thirties"] |
| PRO_696 The New Club at Thirty | title and "at thirty-one" | ages 30-33 | title and text disagree, both wrong at most ages [retitle; drop the number] |
| PRO_754 The Halfway Point | "You're thirty-two" | ages 30-33, 8+ seasons | [drop the sentence] |
| PRO_766 The Thirty-Fifth Birthday | title | ages 34-37 | right only at 34 or 35 [narrow to age 35 in the design, or retitle "The Birthday"] |
| PRO_221 The Anniversary | "Ten years married" | married, ages 30-33 | needs a wedding at 20-23, which only a college marriage gives [say "Years married"] |
| PRO_097 The Reunion | high school reunion, "Twenty years" | ages 34-37 | twenty years after high school is about 38 [say "The reunion"] |
| PRO_302 The Owner's Funeral | "The owner who signed you fourteen years ago" | 10+ pro seasons | wrong at 10-13 seasons, and for anyone who changed clubs [say "the owner who gave you your first real contract here"] |
| PRO_800 The Fan Who Has Seen Every Game | a fan at every home game "sixteen seasons, in the same seat" | ages 34-37 | needs 16 seasons with one club [say "for years"] |
| PRO_807 The Trainer's Retirement | a trainer who "has taped your ankle ... for nine seasons" | ages 34-37 | needs 9 seasons with one club [say "for years"] |
| PRO_630 The Fourth Season | title | ages 26-29 | a late starter or long free agent can be in season 1-3 [retitle, or require pro_seasons 4 max 4] |
| PRO_634 The Specialist Who Retires | "The punter you've worked beside for six years" | ages 26-29 | 6 years at the same club by 26-29 is rare [say "for years"] |
| PRO_632 The Raise | "Your second contract is real money" | ages 26-29, no requirement | assumes a re-signing that may not have happened [require re_signed, or say "Your new contract"] |
| PRO_265 The Grudge | "The general manager who released you two years ago" | ages 34-37, no requirement | assumes a release that may not have happened [require the released flag] |
| PRO_404 The Mentor's Retirement | "the coach who rebuilt your swing in your second season" | ages 30-33 | wrong for anyone who has changed clubs since [say "years ago"] |
| PRO_435 The Backup Role | "the one you held the clipboard for at twenty-two" | ages 34-37 | assumes a backup year at 22 [say "as a rookie"] |
| PRO_319 Ten Years | "Ten years in the league", "start the eleventh year" | 10+ pro seasons, no max | fires late for long careers [add max pro_seasons 10, or say "A decade in the league"] |

### Fits, but worth knowing

- PRO_131 "You turn thirty in camp" fires only at 30. Fine.
- PRO_008 "four years of college" (rookie, ages 21-25): a JUCO or transfer route has fewer college years. Could say "all through college".
- PRO_135 "a third of what you made five years ago" and PRO_305 "a lineman you played beside for six years" (ages 34-37): wrong only for very late starters.
- PRO_446 "community work for twelve years", PRO_752 "locker room DJ for six years", PRO_795 "the charity game you've hosted for ten years": plausible at those ages, but they assume one club for that long. A softer "for years" would fit everyone.
- College season 4 scenes COL_114 "lived with for four years", COL_115 / COL_133 "four years ago", COL_117 "camp two years ago", and COL_096 "three years of holds" (season 3): right for a four-year player, slightly off for a JUCO transfer who joined later.
- The repeatables I just wrote (PRO_200-213) and the wind-down chain use no ages; their experience locks say "after six seasons in the league" and fire only then.

## Update after the variants and eras 5 and 6

**Repeat check, final content** (202 careers, all 20+ seasons):

| Seasons | Already seen earlier in the career | Scenes seen 3+ times by end of band |
|---|---|---|
| 1-5 | 3% (was 6%) | 0.1 (was 1.2) |
| 6-10 | 11% (was 12%) | 1.9 (was 3.9) |
| 11-15 | 17% (was 18%) | 6.3 (was 8.4) |
| 16-21 | 31% (was 65%) | 17.0 (was 25.4) |

- The variants cut the most-seen text from Offseason Training 9.5, Holder Chemistry 8.5 and Summer Break 8.4 per career to at most 1.9 for any single variant text.
- Each family still shows about 9-10 times per career in total.
- Most repeated scenes now: Family and Finances 3.7, PRO_067 Family Asks for Money 3.3, Team Hospital Visit 3.3, PRO_207 The Fan Letter 3.2.

**Flag audit, final content:**
- 0 flags read that nothing sets.
- 62 flags set that nothing reads, all of them high school. Every pro and college flag is now read, mostly by locked callbacks in eras 5 and 6.
- No college wrong-path ending loses a pro scene.

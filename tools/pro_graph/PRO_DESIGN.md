# PRO story graph design (skeleton)

Skeleton for review: only the six tone-check scenes are written (`tools/authoring/work/pro_tone_check.json`, not imported); nothing is generated into the game data. Source: `pro_design.json` (regenerate this file with `make_pro_design_md.py`). Scoping and engine facts: `PRO_SCOPING.md`.

**Timing.** The game has no pro season count, so scenes gate on **age** and on **seasons with the current club** (the count restarts at every new club). Kinds:
- **once**: one time per career.
- **variant**: one of an age-banded set (rookie, prime, veteran).
- **repeat**: re-fires on its trigger, with a 15-week cooldown.

**Waits on** the consolidated gameplay request:
- R1: no age cap (open)
- R3: savings + money field (open)
- R4: transition flags + right-now metrics (landed: slump_now, benched_now, injured_now, fg_streak, season_fg_pct, pro_seasons, contract_years_left, clubs; flags contract_year, re_signed, released, signed_new_club)
- R5: {club} / {town} (landed)
- R6: once_per_club (landed)
- R7: season-end dismissal: set dismissed (landed)
- R8: recast {love_interest} (open)
- R9: longer pro suspensions (open)

R2 changes numbers only; no scene waits on it. Money scenes (R3) are written now with flags and stress costs and get `money` values later.

**Pro strike flags** (the team-discipline steps PRO_124-128 read and clear only these): `stayed_out_pro`, `pro_night_out`, `pro_unapproved_supplement`, `pro_bar_fight`, `pro_shared_inside_info`, `pro_party_house`, `pro_reckless_driving`, `pro_online_rant`, `pro_gambling_debt`, `pro_banned_substance`, `pro_night_before`, `pro_late_meeting`, `pro_casual_bet`, `pro_betting_scandal`, `pro_solicitation`.
**Relationship strike flags** (the cheating storyline PRO_155-163; never read by team discipline): `pro_cheated`, `affair_public`.
College flags set severity through locked choices.

**Totals:** 175 scenes. **172 can be written now**: 147 need nothing new, and 25 are money scenes written with flags and stress costs. **3 are blocked** until R1, R4, R5, R6, R7 or R8 lands. Kinds: 150 once, 17 repeat, 5 variant, 3 per_club.

| Waits on | Scenes |
|---|---|
| R1 | 2: 143, 144 |
| R3 | 25: 003, 007, 026, 031, 040, 056, 057, 059, 060, 061, 062, 063, 064, 065, 066, 067, 068, 069, 070, 071, 072, 073, 123, 135, 163 |
| R8 | 1: 151 |

**Chains:**
- Rookie: PRO_001 → PRO_002 → PRO_003 → PRO_004 → PRO_005 → PRO_006 → PRO_007 → PRO_008 → PRO_009 → PRO_010 → PRO_011 → PRO_012 → PRO_013 → PRO_014 → PRO_015
- Slump: PRO_016 → PRO_017 → PRO_024 → PRO_025 → PRO_027 → PRO_035
- Benched: PRO_018 → PRO_019
- Streak: PRO_020 → PRO_021 → PRO_033
- Awards: PRO_022 → PRO_023
- Competition: PRO_029 → PRO_030 → PRO_032
- Business: PRO_031 → PRO_052 → PRO_053 → PRO_054 → PRO_103 → PRO_104 → PRO_105 → PRO_106
- Media: PRO_034 → PRO_107 → PRO_108 → PRO_109 → PRO_110
- Contract: PRO_036 → PRO_037 → PRO_038 → PRO_039 → PRO_040 → PRO_041 → PRO_055
- New club: PRO_042 → PRO_043 → PRO_044 → PRO_045 → PRO_046 → PRO_047 → PRO_051
- Agent: PRO_048 → PRO_049 → PRO_050
- Money: PRO_056 → PRO_057 → PRO_058 → PRO_059 → PRO_060 → PRO_061 → PRO_062 → PRO_063 → PRO_064 → PRO_065 → PRO_066 → PRO_067 → PRO_068 → PRO_069 → PRO_070 → PRO_071 → PRO_072 → PRO_073
- Partner: PRO_074 → PRO_075 → PRO_079 → PRO_095 → PRO_096 → PRO_151
- Family: PRO_076 → PRO_077 → PRO_078 → PRO_080 → PRO_081 → PRO_082 → PRO_146
- Friends: PRO_083 → PRO_084 → PRO_097 → PRO_098
- Rival: PRO_085 → PRO_086 → PRO_087
- Mentor: PRO_088 → PRO_089
- Teammates: PRO_090 → PRO_091 → PRO_092 → PRO_093
- Locker room: PRO_099 → PRO_100 → PRO_101 → PRO_102 → PRO_111 → PRO_112 → PRO_113 → PRO_114 → PRO_115
- Wrong path: PRO_116 → PRO_117 → PRO_118 → PRO_119 → PRO_120 → PRO_121 → PRO_122 → PRO_123 → PRO_129 → PRO_130
- Wrong path step: PRO_124 → PRO_125 → PRO_126 → PRO_127 → PRO_128
- Veteran: PRO_131 → PRO_132 → PRO_133 → PRO_134 → PRO_135 → PRO_136 → PRO_143 → PRO_144 → PRO_145 → PRO_147 → PRO_150
- Retirement: PRO_137 → PRO_138
- Forced out: PRO_139 → PRO_148
- After: PRO_141 → PRO_142 → PRO_149
- Single: PRO_152 → PRO_153 → PRO_154
- Temptation: PRO_155 → PRO_156 → PRO_157 → PRO_158 → PRO_159 → PRO_160 → PRO_161 → PRO_162 → PRO_163
- Banned substance: PRO_164 → PRO_165
- Late: PRO_167 → PRO_168 → PRO_169
- Betting: PRO_170 → PRO_171 → PRO_172
- Solicitation: PRO_173 → PRO_174 → PRO_175

## Arrival and rookie years (15)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_001 | Rookie Camp | age 21-25, club season 1, weeks 1-2, story | once |  |  | rebuilt_reputation, trained_with_alum |  |
| PRO_002 | The Veteran Kicker | age 21-26, club season 1, weeks 1-4 | once |  | learned_from_veteran, froze_out_veteran |  |  |
| PRO_003 | The First Check | age 21-26, club season 1 | once |  | saved_rookie_check, spent_rookie_check, paid_family_debt | saved_first_paycheck, helped_family_financially | R3 money values |
| PRO_004 | Rookie Duties | age 21-25, club season 1 | once |  |  | ended_tradition, kept_tradition_alive |  |
| PRO_005 | The Long Snapper | age 21-27, club seasons 1-2 | once |  | trusted_snapper |  |  |
| PRO_006 | The First Road Trip | age 21-25, club season 1 | once |  | stayed_out_pro |  |  |
| PRO_007 | Where You Live | age 21-26, club season 1 | once |  | lived_modestly, lived_large |  | R3 money values |
| PRO_008 | Homesick in {town} | age 21-25, club season 1 | once |  |  | promised_to_call_home |  |
| PRO_009 | The Practice Squad Friend | age 21-27, club seasons 1-2 | once |  |  |  |  |
| PRO_010 | Meeting the Owner | age 21-26, club season 1 | once |  |  |  |  |
| PRO_011 | The Quote | age 21-26, club seasons 1-2 | once |  |  | handled_old_post, online_incident |  |
| PRO_012 | Your First Autograph Line | age 21-26, club seasons 1-2 | once |  |  |  |  |
| PRO_013 | Rookie Year Ends | age 21-26, club season 1, offseason | once |  |  |  |  |
| PRO_014 | The Second-Year Wall | age 22-27, club season 2, weeks 1-4 | once |  |  |  |  |
| PRO_015 | The Rookie Symposium Call | age 21-26, club seasons 1-2 | once | owned_mistake / rebuilt_reputation / took_responsibility_scout |  |  |  |

- **PRO_001 Rookie Camp**: Camp opens with four kickers on the roster and one job. The veteran special teams coordinator calls you by the wrong name twice.
- **PRO_002 The Veteran Kicker**: The kicker whose job you're taking has been here eleven years. He can make your first month easy or impossible.
- **PRO_003 The First Check**: Your first real paycheck lands, and it has more zeros than {parent} made in a year.
- **PRO_004 Rookie Duties**: The veterans hand the rookies a list: breakfast for the unit every Friday, the luggage, the karaoke on the team plane. Some of it is fun. One item isn't.
- **PRO_005 The Long Snapper**: The long snapper has been in the league fourteen years and has opinions about everything, including your warmup.
- **PRO_006 The First Road Trip**: First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies. *(Pressure scene: clean no. The wrong choice sets pro strike stayed_out_pro.)*
- **PRO_007 Where You Live**: Half the roster lives in the same glass tower downtown. The rent is a quarter of your salary.
- **PRO_008 Homesick in {town}**: Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.
- **PRO_009 The Practice Squad Friend**: The receiver you've been eating lunch with since camp gets cut on a Tuesday morning. He's still in the parking lot at noon.
- **PRO_010 Meeting the Owner**: The owner throws a party for the rookies at his house and spends twenty minutes telling you what kickers are worth.
- **PRO_011 The Quote**: You said something careless to a beat reporter about the veteran you replaced, and it's the headline.
- **PRO_012 Your First Autograph Line**: A kid in a jersey with your number on it is first in line. You didn't know they made your number.
- **PRO_013 Rookie Year Ends**: The season's over. The locker room empties in an afternoon, and you realize you have no idea what pros do in the offseason.
- **PRO_014 The Second-Year Wall**: Year two. The novelty is gone, the scouting reports on you are thicker, and your legs feel every one of last season's kicks.
- **PRO_015 The Rookie Symposium Call**: A former teammate from college calls from his rookie symposium: they told a story about someone who sounds a lot like you. *(College callback scene: opens only for players with a college comeback; pairs with pro_rookie_symposium.)*

## Performance states (20)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_016 | The Slump | any | repeat |  |  | saw_sports_psych, leaned_on_support |  |
| PRO_017 | The Coach Loses Faith | any | repeat |  |  |  |  |
| PRO_018 | Benched | any | repeat |  |  |  |  |
| PRO_019 | The Job Back | any | repeat |  |  |  |  |
| PRO_020 | The Hot Streak | any | repeat |  |  |  |  |
| PRO_021 | Don't Talk About It | any | once |  |  |  |  |
| PRO_022 | The Watch List | age 23-40 | once | tier fan_favorite |  |  |  |
| PRO_023 | The Skills Contest | any | once | tier fan_favorite |  |  |  |
| PRO_024 | Talk Radio | any | once |  |  |  |  |
| PRO_025 | The Yips | any | once |  |  | saw_sports_psych, got_help_panic |  |
| PRO_026 | The Private Kicking Coach | offseason | once |  | hired_private_coach | vetted_trainer, trained_with_alum | R3 money values |
| PRO_027 | The Film That Hurts | any | once |  |  |  |  |
| PRO_028 | Kicking Hurt | any | repeat |  |  | committed_to_recovery, hid_injury |  |
| PRO_029 | The Backup Wants Your Job | any | once |  |  |  |  |
| PRO_030 | The New Holder Midseason | any | once |  |  |  |  |
| PRO_031 | The Incentive Clause | any | once |  |  |  | R3 money values |
| PRO_032 | The Kicker Brought In | age 27-32, weeks 1-3 | variant |  |  |  |  |
| PRO_033 | Playing for a Contract | any | once |  |  |  |  |
| PRO_034 | The Kick Everyone Saw | any | once |  |  |  |  |
| PRO_035 | The Bad Week | any | once |  |  |  |  |

- **PRO_016 The Slump**: Three weeks of misses in practice and the coaches have stopped talking to you about it, which is worse. *(Repeatable (cooldown 15 weeks). Locks open with experience (kick_slumps, age).)*
- **PRO_017 The Coach Loses Faith**: {coach} watches your warmup with folded arms and doesn't say a word.
- **PRO_018 Benched**: You're inactive this week. Your name is on the board, and your helmet is in your locker. *(Every engine flag is sticky from high school, so the present-state check is needed.)*
- **PRO_019 The Job Back**: You're active again. The kicker who replaced you is clearing out his stall.
- **PRO_020 The Hot Streak**: You haven't missed in a month, and everyone wants to talk about it except you.
- **PRO_021 Don't Talk About It**: The specialists have a superstition: nobody says the streak out loud. A rookie just said it.
- **PRO_022 The Watch List**: Your name is on the national list for the league's best kicker, and the team's PR staff has eleven requests for you.
- **PRO_023 The Skills Contest**: The league invites you to the long-distance contest at the all-star week. *(kick_challenge (competition) per the gameplay handoff.)*
- **PRO_024 Talk Radio**: The afternoon talk show has a segment called 'Cut the Kicker', and your {parent} listens to it every day.
- **PRO_025 The Yips**: Your foot won't swing through the ball in practice. Not tired, not hurt, just stuck.
- **PRO_026 The Private Kicking Coach**: A private coach who rebuilt three pro kickers offers you his offseason, for a price.
- **PRO_027 The Film That Hurts**: {coach} plays every miss of your season back to back in an empty meeting room.
- **PRO_028 Kicking Hurt**: Your plant leg is sore in a way the trainers can't find on a scan.
- **PRO_029 The Backup Wants Your Job**: {backup} is on the practice squad and has been kicking very well where the coaches can see.
- **PRO_030 The New Holder Midseason**: {holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick.
- **PRO_031 The Incentive Clause**: Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.
- **PRO_032 The Kicker Brought In**: The club signs a kicker with a bigger leg and a lower salary, and puts him at the locker next to yours. *(Prime-age version; PRO_133 is the veteran version.)*
- **PRO_033 Playing for a Contract**: Every kick in practice now feels like a negotiation.
- **PRO_034 The Kick Everyone Saw**: A clip of you in a practice-field trick shot goes around the league. *(Practice clip only; no game result.)*
- **PRO_035 The Bad Week**: You snapped at {holder}, ignored {coach} and skipped the team meal. It's been that kind of week.

## Contract and business (20)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_036 | Contract Year: Prove It | age 22-26 | variant |  |  |  |  |
| PRO_037 | Contract Year: The Payday | age 27-31 | variant |  |  |  |  |
| PRO_038 | Contract Year: One More | age 32+ | variant |  |  |  |  |
| PRO_039 | The Re-Sign Call | any | repeat |  |  |  |  |
| PRO_040 | The Hometown Discount | any | once |  |  |  | R3 money values |
| PRO_041 | The Holdout Talk | any | once |  |  |  |  |
| PRO_042 | Starting Over | club season 1, weeks 1-3 | once | failed_tryouts |  |  |  |
| PRO_043 | New Club, New Locker Room | club season 1, weeks 1-2 | per_club |  |  |  |  |
| PRO_044 | The New Holder | club season 1, weeks 1-4 | per_club |  |  |  |  |
| PRO_045 | Moving the Family | club season 1, offseason | per_club |  |  |  |  |
| PRO_046 | The Family Stays Behind | club season 1 | once |  |  |  |  |
| PRO_047 | Your Old Team Comes to Town | any | once |  |  |  |  |
| PRO_048 | The Agent's Bigger Client | any | once |  | agent_neglect |  |  |
| PRO_049 | Firing Your Agent | any | once | agent_neglect | fired_agent |  |  |
| PRO_050 | The Good Agent | any | once |  | good_agent |  |  |
| PRO_051 | The Tryout Hotel | club season 1 | once |  |  |  |  |
| PRO_052 | The Teammate Traded Away | any | once |  |  |  |  |
| PRO_053 | The Head Coach Is Fired | any | once |  |  |  |  |
| PRO_054 | The General Manager's Nephew | any | once |  |  |  |  |
| PRO_055 | Loyalty or the Paycheck | any | once |  |  | stayed_loyal, explored_options |  |

- **PRO_036 Contract Year: Prove It**: It's the last year of your rookie deal, and the front office wants to see one more season before they talk.
- **PRO_037 Contract Year: The Payday**: This is the contract that sets up your family for life, if you earn it this season.
- **PRO_038 Contract Year: One More**: At your age, the next contract is one year at a time, and everyone in the building knows it.
- **PRO_039 The Re-Sign Call**: The club wants you back. Your agent wants to wait for the market.
- **PRO_040 The Hometown Discount**: The club offers less than the market, and asks you to take it because you're family here.
- **PRO_041 The Holdout Talk**: Your agent says the only way to get paid is to stay home from camp. *(A temptation, not a mechanic: the game has no holdouts. Holding firm costs retention and the coach.)*
- **PRO_042 Starting Over**: The last club let you go. A week ago you were cleaning out a locker; today you're in a stranger's locker room in a city you've never visited. *(Opens after any release or cut (the engine's failed_tryouts list), in the first weeks at the next club. Tone-check scene (being cut at the end of camp).)*
- **PRO_043 New Club, New Locker Room**: First day at {club}. Your name is on tape above a locker that still has someone else's sticker on it.
- **PRO_044 The New Holder**: {holder} spins the laces differently than anyone you've worked with.
- **PRO_045 Moving the Family**: The new contract is in {town}. Your partner has a job and friends where you live now.
- **PRO_046 The Family Stays Behind**: You'll be in {town} during the season, and your family will be a flight away.
- **PRO_047 Your Old Team Comes to Town**: Your old club is on the schedule. Half the locker room over there still texts you.
- **PRO_048 The Agent's Bigger Client**: Your agent just signed a star quarterback, and your calls go to voicemail.
- **PRO_049 Firing Your Agent**: Your agent has missed two deadlines this year. Firing him means starting over with someone new.
- **PRO_050 The Good Agent**: An agent with six clients asks for an hour to show you a plan with no flash in it at all.
- **PRO_051 The Tryout Hotel**: You got the job at a Tuesday tryout. Now you live in a hotel by the airport until somebody says otherwise.
- **PRO_052 The Teammate Traded Away**: The club traded your holder's best friend at midnight. He found out from his phone. *(Other players get traded; the player can't be.)*
- **PRO_053 The Head Coach Is Fired**: The head coach is fired after a team meeting. {coach}'s office lights are on late.
- **PRO_054 The General Manager's Nephew**: The new general manager is the owner's nephew, and he has opinions about kickers.
- **PRO_055 Loyalty or the Paycheck**: Another club would pay you double. This one gave you your first chance.

## Money (18)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_056 | The Big Check | age 24-34 | once |  | saved_big_check, spent_big_check |  | R3 money values |
| PRO_057 | The Honest Advisor | any | once |  | honest_advisor |  | R3 money values |
| PRO_058 | The Advisor With the Yacht | any | once |  | trusted_flashy_advisor | good_agent, honest_advisor |  |
| PRO_059 | The Missing Money | any | once | trusted_flashy_advisor | advisor_stole, hid_the_loss |  | R3 money values (-0.4) |
| PRO_060 | The Lawsuit | any | once | advisor_stole | sued_advisor |  | R3 money values |
| PRO_061 | The Restaurant | any | once |  | opened_restaurant |  | R3 money values |
| PRO_062 | The Restaurant Is Failing | any | once | opened_restaurant | bad_venture | honest_advisor | R3 money values |
| PRO_063 | The Car Dealership | any | once |  | dealership_partner |  | R3 money values |
| PRO_064 | The Friend's Start-Up | any | once |  | invested_in_friend |  | R3 money values |
| PRO_065 | The Start-Up Calls | any | once | invested_in_friend |  | honest_advisor | R3 money values |
| PRO_066 | The Tax Letter, Pro | any | once |  |  | saved_first_paycheck | R3 money values |
| PRO_067 | Family Asks for Money | any | repeat |  |  |  | R3 money values |
| PRO_068 | The Cousin Nobody Remembers | any | once |  |  |  | R3 money values |
| PRO_069 | {parent}'s House | any | once |  |  | helped_family_financially | R3 money values |
| PRO_070 | The Foundation | any | once |  | started_foundation |  | R3 money values |
| PRO_071 | The Watch, the Car, the Chain | any | once |  |  |  | R3 money values |
| PRO_072 | Broke at Thirty-Three | age 31+ | once | advisor_stole / bad_venture / spent_big_check / lived_large / hid_the_loss |  |  | R3 money values + savings check |
| PRO_073 | The Pension Meeting | any | once |  |  |  | R3 money values |

- **PRO_056 The Big Check**: The signing bonus clears. Your phone lights up with cousins.
- **PRO_057 The Honest Advisor**: A financial advisor recommended by your snapper walks you through a plan so boring it's almost funny.
- **PRO_058 The Advisor With the Yacht**: A financial advisor who manages three teammates invites you onto his boat and talks about 'real returns'.
- **PRO_059 The Missing Money**: Your accounts are lighter than they should be, and the advisor isn't answering. *(Works now with flags and stress; the stolen 40% lands with R3.)*
- **PRO_060 The Lawsuit**: Your lawyer says you can sue the advisor. It'll take three years and your name will be in every story.
- **PRO_061 The Restaurant**: An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night.
- **PRO_062 The Restaurant Is Failing**: The steakhouse is losing money every week, and your name is on the sign.
- **PRO_063 The Car Dealership**: A dealership wants you as a partner: your face on the billboards, your money in the lot.
- **PRO_064 The Friend's Start-Up**: {best_friend} is starting a company and asks you to be the first investor.
- **PRO_065 The Start-Up Calls**: {best_friend}'s company is either about to make it or about to fold, and they need one more check. *(The one good venture: it can pay off.)*
- **PRO_066 The Tax Letter, Pro**: You owe taxes in every state you played a road game in, and your old accountant didn't file most of them.
- **PRO_067 Family Asks for Money**: {sibling} needs money and doesn't want {parent} to know.
- **PRO_068 The Cousin Nobody Remembers**: Someone from your hometown with your last name and a business idea is waiting by your car.
- **PRO_069 {parent}'s House**: You could pay off {parent}'s mortgage this week. He's told you not to, twice.
- **PRO_070 The Foundation**: Your charity foundation's director is spending more on galas than on kids.
- **PRO_071 The Watch, the Car, the Chain**: The locker room has a dress code nobody wrote down, and it costs about your rookie salary.
- **PRO_072 Broke at Thirty-Three**: The money's gone faster than the career, and you have a mortgage, a family and maybe three seasons.
- **PRO_073 The Pension Meeting**: The players' union holds a meeting about pensions and retirement plans. Six players show up.

## People (25)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_074 | The Proposal | any | once | made_long_distance_work / committed_to_relationship / new_partner; not engaged / married; rel_love_interest 55+ | engaged |  |  |
| PRO_075 | The Wedding | offseason | once | engaged | married |  |  |
| PRO_076 | The Due Date | any | once | married / engaged | became_parent |  |  |
| PRO_077 | First Day of School | age 27+ | once | became_parent |  |  |  |
| PRO_078 | The Recital | any | repeat | became_parent |  |  |  |
| PRO_079 | Your Partner's Career | any | once | married / engaged |  |  |  |
| PRO_080 | {parent} Is Getting Older | age 28+ | once |  |  |  |  |
| PRO_081 | {parent}'s Last Season in the Stands | age 32+ | once |  |  |  |  |
| PRO_082 | {sibling}'s Own Shot | any | once |  |  | went_home_for_dad, came_clean_tape |  |
| PRO_083 | The Old Friend's Ticket Requests | any | repeat |  |  |  |  |
| PRO_084 | The Coach Who Taught You | offseason | once |  |  | earned_coach_confidence, repaired_coach_trust |  |
| PRO_085 | {tyler} in the Same Division | any | once |  | tyler_division_rival | tyler_mutual_respect, congratulated_tyler, trash_talked_tyler |  |
| PRO_086 | {tyler} Gets Cut | age 27+ | once |  |  |  |  |
| PRO_087 | {tyler}'s Second Act | age 33+ | once |  |  |  |  |
| PRO_088 | The Rookie Kicker You Mentor | age 30+ | once |  | mentored_rookie_kicker | mentored_backup, mentored_younger_student |  |
| PRO_089 | The Mentee Takes Your Job | age 33+ | once | mentored_rookie_kicker |  |  |  |
| PRO_090 | The Holder's Last Season | age 28+ | once |  |  |  |  |
| PRO_091 | The Snapper Retires | age 27+ | once | trusted_snapper |  |  |  |
| PRO_092 | A Teammate in Trouble | any | repeat |  |  |  |  |
| PRO_093 | The Concussion | any | once |  |  |  |  |
| PRO_094 | The Letter From a Kid | any | once |  |  | community_volunteer |  |
| PRO_095 | The Tabloid | any | once | married |  |  |  |
| PRO_096 | The Marriage on the Road | any | once | married | marriage_strained |  |  |
| PRO_097 | The Reunion | age 28-40, offseason | once |  |  |  |  |
| PRO_098 | A College Teammate's Wedding | age 24-34, offseason | once |  |  | roommate_pact, roommate_cold_war |  |

- **PRO_074 The Proposal**: You've been carrying a ring around for three weeks, waiting for the right moment that won't come during a season.
- **PRO_075 The Wedding**: The wedding is in the offseason. The guest list is a fight.
- **PRO_076 The Due Date**: The baby is due the same week as a road game across the country.
- **PRO_077 First Day of School**: Your kid's first day of school is a Thursday practice.
- **PRO_078 The Recital**: A school recital, a road trip, and a kid who has asked three times if you'll be there.
- **PRO_079 Your Partner's Career**: Your partner has been offered the job of a lifetime, in a city with no team.
- **PRO_080 {parent} Is Getting Older**: {parent} forgets the name of a neighbor he's known for twenty years.
- **PRO_081 {parent}'s Last Season in the Stands**: {parent} says this is the last season he'll make the drive to watch you.
- **PRO_082 {sibling}'s Own Shot**: {sibling} has a tryout of his own, and he wants you there.
- **PRO_083 The Old Friend's Ticket Requests**: {best_friend} asks for tickets every week and brings a different stranger every time. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_084 The Coach Who Taught You**: Your high school coach is retiring, and the school wants you to speak at the dinner.
- **PRO_085 {tyler} in the Same Division**: {tyler} signs with a division rival, and the media has already made the graphic.
- **PRO_086 {tyler} Gets Cut**: {tyler} is released on a Monday. He calls you before his agent.
- **PRO_087 {tyler}'s Second Act**: {tyler} is in the broadcast booth now, and he's calling your games.
- **PRO_088 The Rookie Kicker You Mentor**: The club drafts a kicker and asks you to show the rookie how things work, knowing what that means.
- **PRO_089 The Mentee Takes Your Job**: The kicker you taught is better than you now, and {coach} wants to tell you before the depth chart comes out.
- **PRO_090 The Holder's Last Season**: {holder} is retiring after this season and wants every hold to count.
- **PRO_091 The Snapper Retires**: The long snapper you've trusted for years is done, and he asks you to speak at his farewell.
- **PRO_092 A Teammate in Trouble**: A teammate's arrest is on every channel. He asks you to vouch for him at the hearing. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_093 The Concussion**: A teammate who has had too many concussions is hiding another one, and you saw it happen.
- **PRO_094 The Letter From a Kid**: A letter from a kid in a hospital you visited years ago: he's walking now.
- **PRO_095 The Tabloid**: A gossip site prints a story about your marriage that's mostly made up.
- **PRO_096 The Marriage on the Road**: You've been home eleven nights since August, and your partner has stopped asking when you'll be back.
- **PRO_097 The Reunion**: Your high school reunion is the weekend after the season, and everyone wants to know what the league is like.
- **PRO_098 A College Teammate's Wedding**: Your old college roommate is getting married, and he wants you to give a toast.

## Locker room and the business (17)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_099 | The Locker Room Fight | any | repeat |  |  |  |  |
| PRO_100 | The Quarterback's Ego | any | once |  |  |  |  |
| PRO_101 | The Veteran Who Can't Let Go | any | once |  |  |  |  |
| PRO_102 | The Players-Only Meeting | any | once |  |  |  |  |
| PRO_103 | The Player Rep | any | once |  | player_rep |  |  |
| PRO_104 | The Labor Fight | any | once | player_rep |  |  |  |
| PRO_105 | The Injured Teammate | any | once |  |  |  |  |
| PRO_106 | The Owner's Gala | any | once |  |  |  |  |
| PRO_107 | The Podcast | any | once | tier verified |  |  |  |
| PRO_108 | The Autograph Session | any | repeat | tier verified |  |  |  |
| PRO_109 | The Awards Show | any | once | tier fan_favorite |  |  |  |
| PRO_110 | The National Deal | any | once | tier verified |  |  |  |
| PRO_111 | The Leak | any | once |  |  |  |  |
| PRO_112 | The Specialists' Dinner | any | once |  |  |  |  |
| PRO_113 | The Playoff Push | weeks 8-11 | repeat |  |  |  |  |
| PRO_114 | A Season Going Nowhere | weeks 6-11 | repeat |  |  |  |  |
| PRO_115 | The Trick Play | any | once |  |  |  |  |

- **PRO_099 The Locker Room Fight**: Two starters are swinging at each other by the cold tub, and the rookies are watching you. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_100 The Quarterback's Ego**: The franchise quarterback blames the special teams in a press conference.
- **PRO_101 The Veteran Who Can't Let Go**: A thirty-six-year-old linebacker is getting cut, and he hasn't figured it out yet.
- **PRO_102 The Players-Only Meeting**: The team captains call a meeting about the coach, and they want your vote.
- **PRO_103 The Player Rep**: The team needs a union representative, and nobody wants to be the one management remembers.
- **PRO_104 The Labor Fight**: The league and the union are fighting over the next agreement, and the owners are talking about replacement players. *(Told through teammates; no strike mechanic.)*
- **PRO_105 The Injured Teammate**: A teammate who tore his knee for the team is cut the day he's cleared to practice.
- **PRO_106 The Owner's Gala**: Black tie, the owner's charity, and a donor who wants a photo and a favor.
- **PRO_107 The Podcast**: A popular podcast wants you for an hour. The host is known for getting athletes to say too much.
- **PRO_108 The Autograph Session**: A mall signing goes three hours over, and the line still wraps around the food court. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_109 The Awards Show**: The league's awards show wants you on the red carpet the night before a practice you can't miss.
- **PRO_110 The National Deal**: A national brand wants you for a commercial that would play during every game this year.
- **PRO_111 The Leak**: Someone is leaking locker-room conversations to a reporter, and the coaches think it's a specialist.
- **PRO_112 The Specialists' Dinner**: The kicker, the punter and the snapper have a weekly dinner, and a new punter wants in.
- **PRO_113 The Playoff Push**: The city has noticed the team. Everyone wants a piece of the players in the last month. *(No results; the push is the atmosphere. Repeatable (cooldown 15-20 weeks).)*
- **PRO_114 A Season Going Nowhere**: The season's slipping away, and the locker room has started counting days until the offseason. *(Repeatable (cooldown 15-20 weeks).)*
- **PRO_115 The Trick Play**: The new coordinator wants a fake field goal with you throwing the pass, and you haven't thrown a ball since high school.

## Wrong path (pro) (27)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_116 | After the Game | any | once |  | pro_night_out |  |  |
| PRO_117 | The Supplement Sponsor | any | once |  | pro_unapproved_supplement |  |  |
| PRO_118 | The Video | any | once |  | pro_bar_fight |  |  |
| PRO_119 | The Friend Who Bets | any | once |  | pro_shared_inside_info |  |  |
| PRO_120 | The Party House | any | once |  | pro_party_house |  |  |
| PRO_121 | The New Car | any | once |  | pro_reckless_driving | street_race |  |
| PRO_122 | The Rant | any | once |  | pro_online_rant | online_incident, handled_old_post |  |
| PRO_123 | The Card Game | any | once |  | pro_gambling_debt |  | R3 money values |
| PRO_124 | The Team Fine | story | once | (every pro strike) | pro_warning, pro_owned_it | owned_mistake, rebuilt_reputation, character_concerns |  |
| PRO_125 | League Discipline | story | once | pro_warning; (every pro strike) | pro_second_chance, pro_character_concerns |  |  |
| PRO_126 | The Last Warning, Pro | story | once | pro_second_chance; (every pro strike) | pro_last_chance, pro_character_concerns | last_chance |  |
| PRO_127 | Released for Conduct | any | once | pro_last_chance; new pro strike | dismissed |  |  |
| PRO_128 | The Long Way Back, Pro | story | once | pro_character_concerns | pro_rebuilt_reputation |  |  |
| PRO_129 | The League's Counselor | any | once | pro_second_chance / pro_last_chance |  |  |  |
| PRO_130 | A Clean Year | any | once | pro_owned_it / pro_rebuilt_reputation |  |  |  |
| PRO_164 | The Package | any | once |  | pro_banned_substance, reported_package | took_unapproved_supplement, refused_improper_help |  |
| PRO_165 | The Search | any | once | pro_banned_substance | pro_caught_with_package |  |  |
| PRO_166 | The Night Before | any | once |  | pro_night_before |  |  |
| PRO_167 | Late for the Meeting | any | repeat |  | pro_late_meeting, late_fined |  |  |
| PRO_168 | Late Again | any | once | late_fined | pro_late_meeting, late_warned |  |  |
| PRO_169 | The Depth Chart Note | any | once | late_warned | pro_late_meeting |  |  |
| PRO_170 | The Office Pool | any | once |  | pro_casual_bet |  |  |
| PRO_171 | The Bookie | any | once |  | pro_betting_scandal, reported_bookie | refused_improper_help, reported_runner |  |
| PRO_172 | The Investigation | any | once | pro_betting_scandal | pro_character_concerns |  |  |
| PRO_173 | The Spa | any | once |  | pro_solicitation |  |  |
| PRO_174 | The Hearing | any | once | pro_solicitation; not made_long_distance_work / committed_to_relationship / new_partner / engaged / married | pro_hearing_done |  |  |
| PRO_175 | The Hearing, at Home | any | once | pro_solicitation; made_long_distance_work / committed_to_relationship / new_partner / engaged / married | pro_hearing_done, pro_cheated |  |  |

- **PRO_116 After the Game**: A teammate's night out after a home game starts at a club and ends somewhere you don't want to be. *(Strike. Clean no.)*
- **PRO_117 The Supplement Sponsor**: A supplement company offers you a deal for a product the league hasn't approved.
- **PRO_118 The Video**: Someone at a bar is filming you while a stranger tries to start a fight.
- **PRO_119 The Friend Who Bets**: An old friend who bets on games asks what you know about the starting quarterback's ankle. *(Integrity strike: the worst one.)*
- **PRO_120 The Party House**: A teammate rents a house for the bye week, and the guest list is long.
- **PRO_121 The New Car**: Your new car does zero to sixty in three seconds, and the highway is empty at midnight.
- **PRO_122 The Rant**: It's two in the morning and you've written four paragraphs about the general manager.
- **PRO_123 The Card Game**: The card game in the back of the team plane has a buy-in bigger than your first car.
- **PRO_124 The Team Fine**: The club fines you and calls you in. The special teams coach is there, and so is the general manager. *(Both choices set pro_warning (the fine is on record); owning it also sets pro_owned_it. College flags set severity through a locked choice. Every choice clears every pro strike.)*
- **PRO_125 League Discipline**: The league office wants a meeting. It's not a conversation; it's a hearing. *(Opens on the warning plus a new pro strike. suspend_weeks 2 (longer once R9 lands). Every choice clears every pro strike.)*
- **PRO_126 The Last Warning, Pro**: The general manager says it plainly: one more and you're done here. *(Every choice clears every pro strike. College last_chance adds a locked line.)*
- **PRO_127 Released for Conduct**: After a last chance, another strike: the club is done with you. *(Sets the dismissal flag; the release happens at season end once R7 lands.)*
- **PRO_128 The Long Way Back, Pro**: A new club, a short contract, and a list of conditions longer than the playbook.
- **PRO_129 The League's Counselor**: The league assigns you a counselor after the hearing, and the first session is Tuesday.
- **PRO_130 A Clean Year**: A full year without a fine, a headline or a hearing. The general manager notices.
- **PRO_164 The Package**: A trainer from a private gym you used last summer leaves a package in your locker: a banned substance, a note that says it can't be detected, and his number. *(The player is never shown taking anything: the wrong choice is keeping the package and saying nothing. Clean no: the team doctor or the league's confidential line. Tone-check scene.)*
- **PRO_165 The Search**: League testers arrive unannounced and ask to see your locker and your gym bag. The package is still in it. *(Follow-up to The Package: a possession case, not a positive test, so the player is never shown taking anything. Costs: suspend_weeks (3 now; longer once R9 lands), retention, followers, conduct scandal (sponsors drop the player).)*
- **PRO_166 The Night Before**: The night before a game, a teammate's dinner (or your agent's dinner for his clients) moves to a strip club, and the whole table is getting up. *(Non-explicit: the scene ends at the choice, and the bad choice cuts to the next morning. Costs: photos online (followers, conduct bad), tired / late_night into the game, {coach}; {love_interest} only through a locked or follow-up line if the player has a partner (partner flags). No game result.)*
- **PRO_167 Late for the Meeting**: The special teams meeting started at eight. It's 8:06, and you're in the parking lot. *(Escalation, step 1: the fine. Repeatable (cooldown 15 weeks); the escalating text lives in 168 and 169.)*
- **PRO_168 Late Again**: Late again. This time {coach} is waiting outside the meeting room, and the fine isn't the topic. *(Escalation, step 2: the talking-to.)*
- **PRO_169 The Depth Chart Note**: A third late arrival. There's a note on your locker: see {coach} before you dress. *(Escalation, step 3: inactive for a game (suspend_weeks 1, the club's discipline). Feeds the pro discipline chain through pro_late_meeting.)*
- **PRO_170 The Office Pool**: The locker room runs a pool on the college basketball tournament: twenty dollars a sheet and a lot of trash talk. *(Small strike: league rules forbid it, even on other sports. Conduct bad, a small fine, {coach}. Clean no with a payoff.)*
- **PRO_171 The Bookie**: An old friend from home introduces you to a man who takes bets, including on football, including on your own team's games. He'd also pay well for a heads-up on who's hurt. *(The most serious scandal: no how-to, no glamorous win. Clean no: walk away and call the league's integrity line. Tone-check scene.)*
- **PRO_172 The Investigation**: Two investigators from the league office are in the general manager's conference room, and they've asked for you by name. *(Follow-up: suspend_weeks 3 (the cap), retention, followers, scandal; character concerns for the pros (pro_character_concerns). Release follows through the discipline chain (R7).)*
- **PRO_173 The Spa**: On a road trip, an agent's client insists you come to a spa he swears by, and makes it clear the 'extras' are the point. *(Non-explicit: nothing is described, and the scene ends at the choice. Several clean no's, each with a payoff: book the team's therapist instead, tell him it isn't for you, or call the partner from the lobby (locked to partner flags). Paying cuts to later: a police investigation, a client list, a reporter's call. Strike: pro_solicitation (conduct scandal). Tone-check scene.)*
- **PRO_174 The Hearing**: A police report, a league hearing and a sponsor's lawyer, all in the same week. *(Follow-up for a player without a partner. League discipline: suspend_weeks (longer once R9 lands), sponsors pull out (conduct scandal), retention, followers.)*
- **PRO_175 The Hearing, at Home**: A police report, a league hearing and a sponsor's lawyer, all in the same week, and {love_interest} has read every word of it. *(Follow-up for a player with a partner: the same discipline, plus {love_interest} (-10 to -15). Every choice sets pro_cheated, so the Found Out chain picks it up.)*

## Veteran and the end (20)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_131 | Thirty | age 30 | once |  |  |  |  |
| PRO_132 | The Maintenance Bill | age 31+ | once |  |  |  |  |
| PRO_133 | The Younger Kicker in Camp | age 33+, weeks 1-3 | variant |  |  |  |  |
| PRO_134 | The One-Year Deal | age 34+ | once |  |  |  |  |
| PRO_135 | The Veteran Minimum | age 35+ | once |  |  |  | R3 money values |
| PRO_136 | The Body Says No | age 35+ | once |  |  |  |  |
| PRO_137 | The Retirement Talk | age 34+ | once | made_long_distance_work / committed_to_relationship / new_partner / engaged / married | planning_retirement |  |  |
| PRO_138 | The Farewell Season | age 34+ | once | planning_retirement |  |  |  |
| PRO_139 | The General Manager's Office | age 34+ | once | retention under 45 |  |  |  |
| PRO_140 | The Comeback Workout | age 33+ | once |  |  |  |  |
| PRO_141 | The Broadcast Booth | age 34+ | once |  | broadcast_offer |  |  |
| PRO_142 | The Coaching Offer | age 35+ | once |  | coaching_offer | mentored_rookie_kicker, mentored_backup |  |
| PRO_143 | Forty | age 40 | once |  |  |  | R1 no age cap |
| PRO_144 | The Oldest Player in the League | age 42+ | once |  |  |  | R1 no age cap |
| PRO_145 | The Last Contract | age 36+ | once |  |  |  |  |
| PRO_146 | Your Kid Wants to Kick | age 35+ | once | became_parent |  |  |  |
| PRO_147 | The Ring of Honor | age 33+, club season 7+ | once |  |  |  |  |
| PRO_148 | Cleaning Out the Locker | age 33+ | once |  |  |  |  |
| PRO_149 | What's Next | age 36+ | once |  |  | finished_degree_track, life_after_football |  |
| PRO_150 | The Note in the Locker | age 38+ | once |  |  |  |  |

- **PRO_131 Thirty**: You turn thirty in camp, and the trainer starts talking about 'maintenance'.
- **PRO_132 The Maintenance Bill**: Holding on to your leg costs more every year: more treatment, more rest, more skill points.
- **PRO_133 The Younger Kicker in Camp**: The club drafts a kicker in the fourth round, and he's sitting in your seat in the meeting room.
- **PRO_134 The One-Year Deal**: The offer is one year, the minimum, and a phone call that says take it or leave it.
- **PRO_135 The Veteran Minimum**: You're making a third of what you made five years ago, and the rookie next to you has your old car.
- **PRO_136 The Body Says No**: Your hip takes an hour to warm up now, and Monday mornings take two.
- **PRO_137 The Retirement Talk**: Your partner asks, gently, how many more seasons. *(Partner version; a single player gets the same question in PRO_149 What's Next.)*
- **PRO_138 The Farewell Season**: Do you tell the world this is your last season, or let it end quietly? *(The retirement itself is the player's choice on the contract screen.)*
- **PRO_139 The General Manager's Office**: The general manager says they're going in a different direction at kicker next season. *(Foreshadows the engine's release; retention lags a season.)*
- **PRO_140 The Comeback Workout**: Released last spring, signed this summer: everyone in camp thinks you're finished.
- **PRO_141 The Broadcast Booth**: A network offers you a job in the booth when you're done.
- **PRO_142 The Coaching Offer**: A college asks if you'd coach their kickers when you retire.
- **PRO_143 Forty**: You turn forty in camp. The rookies were in diapers when you kicked in high school.
- **PRO_144 The Oldest Player in the League**: A reporter writes that you're the oldest player in the league, and asks how long.
- **PRO_145 The Last Contract**: This contract is probably the last one, and your agent says so out loud.
- **PRO_146 Your Kid Wants to Kick**: Your kid wants to kick in middle school, and asks you to teach them.
- **PRO_147 The Ring of Honor**: The club wants to put your name in the stadium's ring of honor after you retire.
- **PRO_148 Cleaning Out the Locker**: You're cleaning out a locker after a release for the first time, and nobody walks by. *(At the new club, about the old one.)*
- **PRO_149 What's Next**: Your agent, your partner and your accountant all ask the same question in the same week.
- **PRO_150 The Note in the Locker**: A rookie leaves a note in your locker: he grew up watching you. *(Age 38 is reachable now (the cap retires a player after the age-38 season); ages above wait on R1.)*

## Relationships (13)

| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |
|---|---|---|---|---|---|---|---|
| PRO_151 | Someone New | any | repeat | ended_long_distance / dating_classmate / broke_up_pro / divorced; not new_partner / engaged / married | new_partner, enjoying_single_life | dating_classmate | R8 re-point {love_interest} |
| PRO_152 | The Setup | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_153 | The Profile | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_154 | The Famous Date | any | once | not made_long_distance_work / committed_to_relationship / new_partner / engaged / married / dating_classmate |  |  |  |
| PRO_155 | The Fan | any | once | new_partner; not engaged / married | pro_cheated |  |  |
| PRO_156 | The Hotel Bar | any | once | made_long_distance_work / committed_to_relationship; not engaged / married | pro_cheated |  |  |
| PRO_157 | The Sponsor's Rep | any | once | engaged; not married | pro_cheated, affair_public |  |  |
| PRO_158 | The Teammate's Friend | any | once | married; not became_parent | pro_cheated |  |  |
| PRO_159 | The Long Week on the Road | any | once | married + became_parent | pro_cheated |  |  |
| PRO_160 | Found Out | any | once | pro_cheated | confessed_affair, lied_about_affair |  |  |
| PRO_161 | The Lie Comes Out | any | once | lied_about_affair | affair_public, broke_up_pro |  |  |
| PRO_162 | Starting Over, Together | any | once | confessed_affair | repaired_relationship, broke_up_pro |  |  |
| PRO_163 | The Divorce | any | once | married; lied_about_affair / affair_public / confessed_affair / marriage_strained | divorced |  | R3 money values |

- **PRO_151 Someone New**: You're single in a new city, or the person you dated in college has followed you here, and it's starting to feel serious. *(One scene for both paths: a player who ended things with the high school love interest meets someone new; a player who dated the college classmate makes the classmate the pro partner (locked choice). Committing re-points {love_interest} to the new partner (R8). Repeats after a breakup or divorce (cooldown 15 weeks).)*
- **PRO_152 The Setup**: A teammate's wife has decided you need to meet her friend, and dinner is Saturday whether you like it or not. *(Single, dating around; no cheating framing.)*
- **PRO_153 The Profile**: Someone screenshots your dating profile and it ends up on a fan account with a caption you didn't write.
- **PRO_154 The Famous Date**: You're photographed at dinner with someone famous, and by morning the internet has decided you're engaged. *(Followers up; the date has opinions about your schedule.)*
- **PRO_155 The Fan**: A fan who's been at every signing this season slips you a hotel key card with your autograph. *(Dating stage. Strike: pro_cheated.)*
- **PRO_156 The Hotel Bar**: After a road game, the team hotel's bar. Someone who isn't {love_interest} has been talking to you for an hour and doesn't want the night to end. *(Committed stage (still with the high school love interest). Tone-check scene.)*
- **PRO_157 The Sponsor's Rep**: The rep from your biggest sponsor has handled your account for a year. Tonight the dinner is just the two of you, and she suggests a nightcap at her hotel. *(Engaged stage. Going public costs the sponsor (scandal).)*
- **PRO_158 The Teammate's Friend**: A teammate's friend keeps showing up at the team's Thursday dinners, and keeps sitting next to you. *(Married stage.)*
- **PRO_159 The Long Week on the Road**: Two road games back to back, ten days from home, and a woman at the team hotel who knows exactly who you are and doesn't care that you're married. *(Married with kids. The kids appear only in the text.)*
- **PRO_160 Found Out**: {love_interest} has your phone in one hand and a question in the other. *(Story event, soon after the strike. Confess: costs now, keeps the door open. Lie: worse when it surfaces.)*
- **PRO_161 The Lie Comes Out**: The story you told {love_interest} has just fallen apart, in a text from someone you've never met. *(Breaking up clears every partner flag (made_long_distance_work, committed_to_relationship, new_partner, engaged).)*
- **PRO_162 Starting Over, Together**: {love_interest} agrees to see a counselor with you. The first session is Thursday, and the counselor asks who wants to go first.
- **PRO_163 The Divorce**: The lawyers have the paperwork ready, and {love_interest} wants to talk before anyone signs anything. *(Divorce clears married and the other partner flags; the money cost lands with savings (R3). People: kids in the text only.)*


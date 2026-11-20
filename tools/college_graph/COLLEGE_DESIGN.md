# College story graph: skeleton (for review)

150 scenarios: 34 freshman, 35 sophomore, 34 junior, 30 senior, 16 year-neutral, 1 finale. Open unless **Opens on** says otherwise. **HS** = high school flags read by a locked choice inside an open scene. **Lock** = college flags read the same way. **Clears** = flags a choice sets to false.

Pivot flags (big choices kept for later college or pro callbacks): `accepted_sanction`, `asked_for_honesty`, `came_clean_tape`, `drove_teammates_home`, `held_teammate_accountable`, `hid_panic`, `hosted_recruit_well`, `leaned_on_support`, `left_party_early`, `promised_to_call_home`, `recommitted`, `refused_improper_help`, `reported_hazing`, `reported_runner`, `reported_tampering`, `shaded_questionnaire`, `told_trainer_col`, `took_mental_health_day`, `waited_for_agents`, `went_home_for_dad`.

Strike flags (any one opens the wrong-path chain; every wrong-path step clears them all so only a NEW strike opens the next step): `missed_curfew`, `hazing_participant`, `snuck_out_road`, `took_improper_benefit`, `online_incident`, `academic_shortcut`, `skipped_conditioning`, `shared_prescription`, `party_trouble`, `portal_tampering`, `took_unapproved_supplement`, `rivalry_prank`, `stayed_out_late`, `secret_agent_deal`, `hosted_recruit_badly`, `sabotaged_transfer`, `rode_along`, `ran_with_wrong_crowd`, `cash_camp`, `partied_before_pro_day`, `senior_trip_trouble`.

## Freshman (34)

### Academics
- **COL_006 Mandatory Study Hall** (Y1 wk 1-4; {teacher}): Your academic advisor, {teacher}, sets your schedule: six hours of study hall a week, signed in and out, or you lose eligibility. · Sets: `skipped_study_hall` · HS: `academic_recovery`
- **COL_016 The Scholarship Fine Print** (Y1 wk 2-8): Your aid paperwork comes with a line you skipped: a minimum GPA to keep it. Midterms are in three weeks. · Sets: `ignored_fine_print` · HS: `secured_academic_path`, `explored_combined_aid`
- **COL_026 The Class You're Failing** (Y1 wk 5-9; {teacher}): A D on your chemistry midterm. Your advisor will see it Friday whether you tell them or not. · Sets: `hid_the_grade`
- **COL_027 Group Project Ghost** (Y1): A teammate in your class wants his name on your group project. He hasn't come to a single meeting. · HS: `covered_teammate`, `reported_teammate`
- **COL_033 The Upperclassman's Notes** (Y1 wk 6-10): An upperclassman offers you a folder of last year's exams for your hardest class. 'Everybody uses them,' he says. · Sets: `academic_shortcut`

### Big moments
- **COL_019 Homecoming Weekend** (Y1 wk 5-8): Alumni pack the campus for homecoming. Boosters want photos, the band wants the specialists for a skit, and the team wants you rested.

### Body and mind
- **COL_018 The Sports Psychologist** (Y1 wk 4-10): The athletic department offers every player sessions with a sports psychologist. Most of the team jokes about it. · Sets: `saw_sports_psych`, `brushed_off_psych`
- **COL_025 Sleepless Before Saturday** (Y1 wk 3-9): You haven't slept more than four hours before a game all season. You lie awake replaying kicks you haven't attempted yet.
- **COL_034 Winter Conditioning** (Y1 offseason): Winter workouts start at 5:30 a.m. in the dark. Three teammates have already started skipping and signing each other in. · Sets: `skipped_conditioning` · HS: `built_training_plan`

### Coaching
- **COL_002 The First Team Meeting** (Y1 wk 1-2; {coach}): {coach} lays out the rules on day one: curfew, study hall, phones in the bin at meetings, and one strike before the coach calls home. · HS: `ready_for_college_football`
- **COL_028 The Captain's Talk** (Y1 wk 4-8): The senior captain pulls you aside: some of the guys think you act like you're too good for the team.

### Family crisis
- **COL_031 {parent}'s Phone Call** (Y1 wk 6-10; {parent}): {parent} sounds tired on the phone. His hours got cut, he says, but it's nothing for you to worry about. · Sets: `offered_to_help_home`, `stayed_focused_away` · HS: `helped_family_financially`

### Hazing
- **COL_011 Freshman Traditions** (Y1 wk 1-3, story): The seniors announce freshman duties: carry their bags, sing the fight song at dinner, fetch whatever they ask for. · Sets: `went_along_tradition`, `questioned_tradition`
- **COL_012 The Hazing Night** (Y1 wk 3-8): The freshman 'initiation' night arrives, and it's not singing anymore. Some of what the seniors have planned is humiliating, and some of it could hurt someone. · Opens on: any of went_along_tradition / questioned_tradition · Sets: `reported_hazing`, `hazing_participant`, `stayed_out_hazing`

### Home
- **COL_001 Move-In Day** (Y1 wk 1, story; {parent}): {parent} helps you carry boxes into a cinderblock dorm room and lingers at the door longer than either of you expected. · Sets: `promised_to_call_home` · HS: `family_college_compromise`
- **COL_003 Far From Home** (Y1 wk 2-5): Three weeks in, the dining hall, the dorm and the practice field all feel like someone else's life, and nobody here knew you before. · Sets: `homesick_spiral` · HS: `prioritized_own_college_choice`
- **COL_004 The Empty Group Chat** (Y1; {best_friend}): Your high school group chat goes quiet. {best_friend} posts photos from a new school with new friends, and you realize you haven't texted anyone in a week. · HS: `college_visit_with_friends`
- **COL_014 The Holiday You Miss** (Y1 wk 7-10; {sibling}, {parent}): The team practices straight through the holiday. {sibling} calls to ask why you're not coming home this year. · HS: `opened_family_conversation`
- **COL_032 The Sibling Visit** (Y1; {sibling}): {sibling} comes to campus for a weekend and wants to see everything: the locker room, the dorm, the parties he's heard about.

### Kicker's job
- **COL_007 The Veteran Kicker** (Y1 wk 1-4): The senior kicker you're replacing next year can make your life easy or miserable, and he hasn't decided which.
- **COL_008 Walk-On Reality** (Y1): You're paying your own way while scholarship players get meal cards and gear you don't. A teammate jokes that walk-ons are practice dummies. · Opens on: needs walk_on
- **COL_009 The Redshirt Teammate** (Y1): A freshman kicker who's redshirting this year sits out every game and watches you kick. He's lonely, bitter, and good.
- **COL_024 The New Holder** (Y1 wk 1-6; {holder}): Your new holder, {holder}, spins the laces a different way than you're used to, and neither of you wants to be the one to change. · HS: `holder_big_moment_success`
- **COL_035 Spring Kicking Competition** (Y1 offseason; {coach}): Spring practice opens with a kicking competition for next season. The veteran kicker is graduating, and the job is wide open.

### Love
- **COL_013 Long Distance** (Y1 wk 2-8; {love_interest}): {love_interest} is back home, the calls are getting shorter, and you keep missing each other between practice and class. · Sets: `made_long_distance_work`, `ended_long_distance`

### Media
- **COL_029 The Highlight Clip** (Y1): A trick-shot clip of you from practice goes around campus, and suddenly people you don't know want a picture.
- **COL_030 The Online Comment** (Y1): A fan account tears into you after a loss. Your thumb is already on the reply button. · Sets: `online_incident` · HS: `handled_old_post`

### Money
- **COL_020 The Booster's Handshake** (Y1 wk 4-9): A friendly booster shakes your hand after practice and leaves something in it: a prepaid card 'for a nice dinner.' · Sets: `took_improper_benefit`, `refused_improper_help`
- **COL_021 The First NIL Pitch** (Y1 wk 3-9): A local sandwich shop offers a small deal: free food all season and a few posts. It's legal, but it's your name on it. · Sets: `signed_first_nil` · HS: `earned_community_reference`
- **COL_022 Budget Week** (Y1): It's the middle of the semester and your account is nearly empty. Rent, books and a phone bill are due the same week. · HS: `saved_first_paycheck`

### Party
- **COL_010 The First Big Party** (Y1 wk 2-6): Upperclassmen throw the first big party of the year on a Thursday. The 6 a.m. lift is in seven hours, and everyone is watching what the freshmen do. · Sets: `missed_curfew`, `left_party_early`
- **COL_015 First Road Trip** (Y1 wk 2-6): Your first road game: a hotel, a curfew check at eleven, and two upperclassmen planning to sneak out to a party across town. · Sets: `snuck_out_road`

### Rival
- **COL_023 The Kicker You Know** (Y1 wk 3-10; {rival}): {tyler} is a college kicker now too, and your names keep showing up next to each other on the same lists. · Sets: `tyler_college_bond`, `tyler_college_feud` · HS: `befriended_tyler`, `hostile_tyler_rivalry`

### Roommates
- **COL_005 The Roommate Draw** (Y1 wk 1-3): Your assigned roommate games until four in the morning, and your first lift is at six. · Sets: `roommate_pact`, `roommate_cold_war`

## Sophomore (35)

### Academics
- **COL_037 The Tutor Who Offers More** (Y2; {teacher}): Your tutor offers to 'clean up' your history paper. You both know that means writing it. · Sets: `academic_shortcut`
- **COL_060 The Summer Plan** (Y2 offseason): Summer is three choices: summer classes to get ahead, a kicking camp circuit, or a job back home. · HS: `built_training_plan`, `summer_job`
- **COL_062 The Advisor's Warning** (Y2-3; {teacher}): {teacher} calls you in: one more bad grade and you're academically ineligible. · Opens on: any of hid_the_grade / skipped_study_hall / ignored_fine_print / academic_shortcut

### Big moments
- **COL_058 Rivalry Week** (Y2 wk 8-10): Rivalry week: someone painted your statue overnight, and teammates plan a midnight trip to the other campus to return the favor. · Sets: `rivalry_prank`

### Body and mind
- **COL_038 The Teammate's Prescription** (Y2 wk 3-9): Your hip is sore, and a teammate offers you some of his prescription. 'It's basically nothing,' he says. · Sets: `shared_prescription`, `told_trainer_col` · HS: `reported_kicking_pain`
- **COL_047 The Sophomore Slump** (Y2 wk 3-8): Your practice charts are the worst they've been since high school, and you can't stop thinking about it, even in class. · Sets: `spiraled_alone` · Lock: `saw_sports_psych`
- **COL_048 Panic in the Tunnel** (Y2-3): Before warmups your chest goes tight, your hands won't stop shaking and you can't get a full breath. · Opens on: any of spiraled_alone / brushed_off_psych / homesick_spiral · Sets: `got_help_panic`, `hid_panic`
- **COL_049 The Injury You Can't Hide** (Y2 wk 2-9): A groin strain flares on every kickoff. The trainer wants you out a week; the season says otherwise. · HS: `committed_to_recovery`
- **COL_050 The Training Table** (Y2): A guy at the gym swears by a powder that isn't on the team's approved list. Two teammates already use it. · Sets: `took_unapproved_supplement`

### Coaching
- **COL_065 The Leadership Council** (Y2; {coach}): {coach} invites you onto the team's leadership council, the players who set the rules and handle the problems. · Sets: `joined_council` · HS: `accepted_team_leadership`, `abused_leadership_role`
- **COL_066 The Head Coach Is Fired** (Y2 offseason, story; {coach}): The head coach is fired the morning after the last game. Staff jobs are up in the air, and half the roster is checking the portal. · Sets: `stayed_loyal`, `explored_options`

### Family crisis
- **COL_054 {parent} Loses His Job** (Y2; {parent}): {parent} finally tells you: the cut hours became a layoff. He says he'll figure it out. · Opens on: any of offered_to_help_home / stayed_focused_away · Sets: `sent_nil_money_home`, `kept_money_for_school`

### Hazing
- **COL_040 Hazing Fallout** (Y2 wk 1-6): The athletic department opens an investigation into last year's initiation night, and investigators want to talk to every sophomore. · Opens on: any of reported_hazing / hazing_participant / stayed_out_hazing
- **COL_041 Now You're the Upperclassman** (Y2 wk 1-3): The new freshmen arrive, and the seniors look at your class. Freshman duties are yours to run now, or to end. · Opens on: any of went_along_tradition / questioned_tradition · Sets: `ended_tradition`, `kept_tradition_alive`

### Home
- **COL_051 The Visit Home** (Y2 offseason; {parent}, {best_friend}): You go home for the first time in months. Your old room is a storage closet now, and everyone talks about people you don't know.
- **COL_053 The Best Friend's Crisis** (Y2; {best_friend}): {best_friend} calls at midnight: they're failing out of school and haven't told their family.

### Kicker's job
- **COL_042 The New Freshman Kicker** (Y2 wk 1-4; {backup}, {coach}): {coach} signs a scholarship freshman kicker, {backup}, and assigns them to share your reps and your locker row. · Sets: `mentored_backup`, `iced_out_backup`
- **COL_043 The Position Battle** (Y2 wk 1-4; {backup}, {coach}): Fall camp turns into a public competition with {backup}. Every kick is charted, and the depth chart comes out Friday. · Opens on: any of mentored_backup / iced_out_backup · Sets: `competed_clean`, `undermined_backup`
- **COL_061 The Holder Who Wants Out** (Y2; {holder}): {holder} wants to stop holding to focus on winning a starting job elsewhere on the roster.

### Love
- **COL_052 Someone New** (Y2): A classmate from your statistics class asks if you want to study together, and it doesn't feel like it's only about studying. · Opens on: any of ended_long_distance · Sets: `dating_classmate`

### Media
- **COL_057 Conference Media Day** (Y2 wk 1-2): The team picks you to speak at conference media day, live, with a dozen microphones in your face.
- **COL_067 The Charity Kick-a-thon** (Y2): A children's hospital asks the team to run a kick-a-thon fundraiser. Someone has to organize it. · HS: `community_volunteer`

### Money
- **COL_055 The Collective** (Y2): The school's NIL collective offers a monthly deal for appearances at booster events. It's real money, and it's a lot of evenings. · Sets: `joined_collective`
- **COL_056 The Loaner Car** (Y2): A car dealer who sits behind the bench offers you a 'loaner' for the semester. No paperwork, he says. · Sets: `took_improper_benefit`, `refused_improper_help`

### Party
- **COL_039 The Big House Party** (Y2 wk 2-8): An off-campus party gets out of hand fast. Campus security is on the way, and a teammate who's in bad shape can't find his ride. · Sets: `party_trouble`
- **COL_063 Hosting the Team Party** (Y2): Your apartment is the obvious place for the team party, and everyone's already planning it. · Sets: `party_trouble`
- **COL_068 Spring Break** (Y2 offseason): Teammates are going to the beach for spring break. Offseason lifts are optional that week, and so, it seems, are the rules. · Sets: `stayed_out_late`

### Pro dream
- **COL_044 The High School Tape** (Y2; {coach}): {coach} rewatches your old recruiting tape and stops on one clip. 'Tell me about this one,' the coach says. · Sets: `came_clean_tape` · HS: `doubled_down_recruiting_lie`, `corrected_recruiting_video`
- **COL_059 The Alum in the League** (Y2 offseason): A kicker from your school who made it to the pros offers to train you for a week this summer, at his own cost. · Sets: `trained_with_alum`
- **COL_069 The Kicking Camp Coach** (Y2 offseason; {coach}): A private kicking coach who's sent players to the pros offers you a spot in his elite group, if you drop your school's summer program. · HS: `vetted_trainer`, `trusted_unknown_trainer`

### Roommates
- **COL_064 The Roommate Problem Grows** (Y2): Your roommate's late nights have turned into parties in your room three nights a week. · Opens on: any of roommate_pact / roommate_cold_war

### Transfer
- **COL_045 Did I Pick Right?** (Y2 wk 2-8): Friends at other schools look happier, and a teammate keeps talking about the transfer portal like it's an escape hatch. · Sets: `eyed_portal`, `recommitted` · HS: `college_decision_pending`
- **COL_046 The Portal Call** (Y2-3): A coach from another school calls you directly, which isn't allowed. He says there's a spot for you if you ever 'get curious.' · Opens on: any of eyed_portal / explored_options · Sets: `portal_tampering`, `reported_tampering`

### Wrong path
- **COL_017 The Pattern** (Y2-4; {coach}): You owned your first mistake, and the staff believed you. Now there's another one, and {coach} wants to know whether the first apology meant anything. · Opens on: needs owned_mistake; any strike · Sets: `owned_it_again`, `character_concerns`, `second_chance_used` · Clears: (every strike flag) · Note: Opens only on a strike after owning the first one (The Coach's Office clears strikes). The good choice sets owned_it_again and second_chance_used; the bad one sets character_concerns.
- **COL_036 The Coach's Office** (Y1-3; {coach}): {coach} closes the door. Word of what you did got back to the staff, and the coach wants to hear it from you before deciding anything. · Opens on: any strike · Sets: `owned_mistake`, `college_warning` · Clears: (every strike flag) · HS: `repaired_coach_trust`

## Junior (34)

### Academics
- **COL_084 The Integrity Hearing** (Y3; {teacher}): Your professor reports a possible academic integrity violation. The hearing is next week. · Opens on: any of academic_shortcut · Sets: `accepted_sanction`
- **COL_085 Choosing a Major** (Y3; {teacher}): You have to declare a major. One keeps you eligible with the least effort; another is the one you actually care about. · HS: `secured_academic_path`, `ready_for_college_future`
- **COL_101 Academic Honors** (Y3; {teacher}): {teacher} says you're close to academic all-conference, if you take one more hard class instead of an easy elective. · HS: `academic_effort`

### Big moments
- **COL_094 The Watch List** (Y3 wk 1-3): You make a preseason watch list for the top kicker in the country. Your phone won't stop.
- **COL_095 The Conference Title Race** (Y3 wk 7-10): Your team is in the conference title race, and the campus is out of its mind. Everyone wants a piece of the players this week.

### Body and mind
- **COL_079 The Mental Health Day** (Y3): You're exhausted in a way sleep doesn't fix. The team counselor says taking a day isn't weakness. · Sets: `took_mental_health_day`
- **COL_080 The Old Injury Returns** (Y3): The groin strain is back, worse this time, right before the conference schedule. · HS: `hid_injury`, `ignored_recovery_advice`
- **COL_102 The Weight Room Push** (Y3 offseason): The new strength coach wants you to add power fast. Your legs are already sore, and his program doesn't do rest days. · HS: `built_training_plan`

### Coaching
- **COL_070 The New Head Coach** (Y3 wk 1-4, story): The new head coach, Marcus Reyes, starts with a team meeting and a new rulebook. He says he's heard about every player on the roster already. · Opens on: any of stayed_loyal / explored_options
- **COL_073 The Captain's Vote** (Y3 wk 1-3; {team}): The team votes for captains, and your name is on the ballot. · Sets: `ran_for_captain`, `deferred_captaincy` · HS: `earned_coach_confidence`
- **COL_074 The Captain's Burden** (Y3-4; {team}, {coach}): A teammate breaks team rules and asks you, as captain, to keep it in the locker room. · Opens on: any of ran_for_captain / joined_council · Sets: `held_teammate_accountable`
- **COL_103 The Leadership Retreat** (Y3 offseason): The team's leaders spend a weekend at a lake planning next season. It's also your only free weekend of the summer. · HS: `accepted_team_leadership`

### Family crisis
- **COL_082 Trouble at Home** (Y3; {sibling}, {parent}): {sibling} got suspended from school for a fight. {parent} is overwhelmed and asks you to talk to him.
- **COL_083 {parent}'s Health Scare** (Y3; {parent}): A late-night call: {parent} is in the hospital. They think it's his heart, and you're four hundred miles away with a game Saturday. · Opens on: any of sent_nil_money_home / kept_money_for_school · Sets: `went_home_for_dad` · HS: `opened_family_conversation`

### Home
- **COL_081 A High School Teammate Calls** (Y3): Someone from your old high school team calls: they're visiting campus next weekend and need a place to stay and a tour. · HS: `helped_freshman`, `new_qb_friendship`

### Kicker's job
- **COL_077 The Transfer Kicker** (Y3 wk 1-4; {coach}): A kicker with a big resume transfers in from another school, and the coaches love his leg. · Sets: `sabotaged_transfer` · HS: `sabotaged_teammate`, `helped_competing_teammate`
- **COL_096 The Holder's Senior Day** (Y3 wk 9-10; {holder}): It's {holder}'s last home game, and they ask you to walk out with their family on senior day.

### Love
- **COL_091 The Ultimatum** (Y3; {love_interest}): {love_interest} wants you to spend the summer at home instead of at training camp. 'For once,' they say. · Opens on: any of made_long_distance_work · Sets: `committed_to_relationship`
- **COL_092 Meeting the Family** (Y3-4; {love_interest}): The person you're dating wants you to meet their family over a holiday weekend, the same weekend as the team's leadership retreat. · Opens on: any of dating_classmate / committed_to_relationship · Sets: `met_the_family`

### Media
- **COL_088 The Viral Video** (Y3): A teammate posts a video of you at a party, edited to look worse than it was. It's everywhere by morning. · Sets: `online_incident`

### Money
- **COL_089 The Big Deal** (Y3): A regional company offers a real NIL deal, but you'd have to promote a product you'd never use. · Sets: `took_big_deal`
- **COL_090 The Tax Bill** (Y3; {parent}): Your NIL money came with a tax bill nobody warned you about, and it's due next month. · Opens on: any of signed_first_nil / joined_collective / took_big_deal · HS: `saved_first_paycheck`

### Party
- **COL_087 The Twenty-First Birthday** (Y3): A teammate turns twenty-one on a Thursday and everyone is going out. Practice is at seven the next morning. · Sets: `stayed_out_late`, `drove_teammates_home`
- **COL_100 The Late-Night Drive** (Y3): After curfew, a teammate who's in no shape to drive wants to take everyone for food. · Sets: `rode_along`

### Pro dream
- **COL_072 The Runner** (Y3): A man who says he works 'with' an agent finds you after practice with cash, a new phone and a promise of more. · Sets: `took_improper_benefit`, `reported_runner`
- **COL_075 The Scouting Questionnaire** (Y3): A pro team sends a questionnaire. Question 14: 'Describe any off-field incidents in your college career.' · Sets: `shaded_questionnaire` · HS: `recruiting_values_clear`
- **COL_076 The Agent's Dinner** (Y3 offseason): An agent invites you to a steakhouse to 'talk about your future.' It's a year too early, and you both know the rules. · Sets: `secret_agent_deal`, `waited_for_agents`
- **COL_097 When the Alum Gets Cut** (Y3): The pro kicker who trained you gets cut, and he calls you before he calls anyone else. · Opens on: any of trained_with_alum

### Rival
- **COL_093 The Award Race** (Y3; {rival}): You and {tyler} are both finalists for the same national kicking award, and the media wants a feud. · Opens on: any of tyler_college_bond / tyler_college_feud · Sets: `congratulated_tyler`, `trash_talked_tyler` · HS: `tyler_mutual_respect`

### Transfer
- **COL_099 A Teammate Enters the Portal** (Y3 offseason): Your closest friend on the team enters the transfer portal without telling you first.

### Wrong path
- **COL_071 The Second Strike** (Y2-4; {coach}, {team}): It happens again. This time it isn't only the coaches who know: a reporter is asking questions, and the team has to respond. · Opens on: needs college_warning; any strike · Sets: `caught_yourself`, `character_concerns`, `second_chance_used` · Clears: (every strike flag) · Note: Opens only on a strike AFTER the first warning: The Coach's Office clears every strike flag, so an old strike can't open it.
- **COL_078 The Long Way Back** (Y2-4; {coach}): You've got a reputation now, and the staff is watching. {coach} offers one path back: early workouts, community hours, and no more excuses. · Opens on: any of character_concerns · Sets: `rebuilt_reputation` · Clears: character_concerns
- **COL_086 The Final Warning** (Y2-4; {coach}): A third incident. {coach} and the head coach sit you down together: one more and you're off the team. This is the last conversation before that one. · Opens on: needs second_chance_used; any strike · Sets: `last_chance`, `character_concerns` · Clears: (every strike flag) · Note: Opens on second_chance_used (set by the good choice in The Second Strike or The Pattern) plus a new strike. The good choice sets last_chance (no label, heavy cost); the bad one sets character_concerns. Either way, The Long Way Back stays open to anyone with the label.
- **COL_098 Hosting a Recruit** (Y3; {coach}): {coach} asks you to host a high school kicker on an official visit. The recruit wants to see 'the real college experience.' · Sets: `hosted_recruit_badly`, `hosted_recruit_well` · HS: `communicated_recruiting_loyalty`

## Senior (30)

### Academics
- **COL_111 The Degree Question** (Y4 wk 6-10; {teacher}): You're two classes from a degree. Dropping them would free up hours for draft training. · Sets: `finished_degree_track` · HS: `ready_for_college_future`, `secured_academic_path`
- **COL_124 Final Exams, Final Season** (Y4 wk 7-10; {teacher}): Your last finals land in the same week as your last regular-season game.

### Big moments
- **COL_104 Senior Year Starts** (Y4 wk 1, story; {coach}): The first practice of your last college season. Everyone keeps saying it goes fast.
- **COL_112 Senior Night** (Y4 wk 8-10; {parent}, {sibling}): Senior night, and your family is driving in. Before kickoff, the seniors walk out one at a time. · HS: `family_college_compromise`
- **COL_113 The Last Rivalry Week** (Y4 wk 8-10; {team}): One last rivalry week. The younger players look to the seniors to set the tone.
- **COL_131 The Leadership Award** (Y4 wk 5-9; {holder}, {coach}): The conference names you its senior leadership honoree for your school. You have one minute at the podium at Monday's banquet.
- **COL_133 The Last Practice** (Y4 wk 9-10; {coach}, {holder}): The last practice of your college career. The field is the same one you walked onto four years ago.

### Body and mind
- **COL_122 The Mental Toll** (Y4): Draft season, final exams and your last season at once. You're short with everyone and you don't sleep. · Sets: `leaned_on_support` · Lock: `saw_sports_psych`, `got_help_panic`
- **COL_123 The Last Injury Scare** (Y4): Your knee buckles on a routine practice kick three weeks before scouts arrive. · HS: `reported_kicking_pain`

### Coaching
- **COL_114 The Captain's Last Speech** (Y4 wk 9-10; {coach}, {team}): {coach} asks you to speak to the team before the final game of your career. · Opens on: any of ran_for_captain / joined_council / deferred_captaincy
- **COL_132 The Coach's Letter** (Y4 wk 8-10; {coach}): {coach} is writing to pro scouts about you and asks what you want included, and what you'd rather leave out. · Sets: `asked_for_honesty` · HS: `repaired_coach_trust`

### Family crisis
- **COL_120 {parent} at Every Game** (Y4; {parent}): {parent} has driven to every game this season. You know he can't afford it. · HS: `helped_family_financially`
- **COL_121 The Little Brother's Recruiting** (Y4; {sibling}): {sibling} is a high school senior now, and college coaches are calling. He asks you how to handle them. · HS: `doubled_down_recruiting_lie`, `recruiting_values_clear`

### Hazing
- **COL_128 The Last Initiation** (Y4 wk 1-3; {team}): Your class is the senior class now. The freshman initiation is your call this year. · Opens on: any of ended_tradition / kept_tradition_alive

### Kicker's job
- **COL_115 The Freshman Who Reminds You** (Y4): A homesick freshman kicker reminds you of yourself four years ago. · HS: `mentored_younger_student`, `mentored_next_generation`
- **COL_116 The Holder's Future** (Y4; {holder}): {holder} asks you for a recommendation for a graduate assistant job. It means writing honestly about someone you love working with.
- **COL_117 The Backup's Moment** (Y4; {backup}, {coach}): You're sore, and {coach} wants to give {backup} the kickoffs this week. {backup} looks at you before saying yes. · Opens on: any of mentored_backup / iced_out_backup / competed_clean / undermined_backup

### Love
- **COL_119 What Comes After** (Y4; {love_interest}): {love_interest} asks the question you've both avoided: what happens to us after college? · Opens on: any of committed_to_relationship / met_the_family / dating_classmate

### Media
- **COL_130 The Old Posts** (Y4): Someone digs up your freshman-year posts during draft season and they're spreading. · HS: `handled_old_post`, `owned_old_group_chat`

### Money
- **COL_126 The Exclusive Deal** (Y4): A national brand wants an exclusive NIL deal for your senior year. It pays more than everything else combined, and it ends all your local deals.
- **COL_127 Giving Back** (Y4): Your hometown asks if you'd run a free kicking camp for kids this summer. It would cost you a week and some of your NIL money. · HS: `community_volunteer`, `earned_community_reference`

### Party
- **COL_125 The Senior Trip** (Y4 wk 4-9): The seniors book a trip for the bye weekend, in the middle of draft prep. It's the last time you'll all be together. · Sets: `senior_trip_trouble`

### Pro dream
- **COL_107 Choosing an Agent** (Y4 wk 6-10; {parent}): Three agents want to represent you: a big firm, a former player, and a smooth talker promising a first-round grade. · HS: `recruiting_values_clear`, `recruiting_said_what_they_wanted`
- **COL_108 Combine Prep** (Y4 wk 5-9): A training facility wants you for combine prep the day the season ends, and wants an answer now. Their 'recovery program' includes things you've never heard of. · Sets: `combine_ready`, `took_unapproved_supplement`
- **COL_109 The Scouts' Workout** (Y4 wk 6-9): Scouts from a dozen pro teams are coming Thursday morning to work out your school's seniors. The seniors are throwing a send-off party Wednesday night. · Sets: `pro_day_ready`, `partied_before_pro_day`
- **COL_110 Draft Weekend** (Y4 wk 8-10; {parent}, {sibling}): Draft weekend is months away, and everyone already wants to know where you'll watch it: with family, with teammates, or with your phone off. · HS: `family_college_compromise`, `prioritized_own_college_choice`
- **COL_129 The Scout's Dinner** (Y4): A scout takes you to dinner and spends more time watching how you treat the waiter than asking about kicking.

### Rival
- **COL_118 Old Rival, New Stage** (Y4 wk 5-9; {rival}): {tyler} is a draft prospect too, and his agent suggests you two spend your Sunday off-days training together until the season ends. · Opens on: any of tyler_college_bond / tyler_college_feud / congratulated_tyler / trash_talked_tyler · HS: `tyler_mutual_respect`

### Wrong path
- **COL_105 The Background Check** (Y4 wk 3-9, story): Pro scouts are interviewing everyone with a chance at the draft, and they've talked to people you haven't spoken to in years. · Sets: `scouts_red_flag` · HS: `corrected_recruiting_video`, `doubled_down_recruiting_lie` · Lock: `rebuilt_reputation` · Note: Open to every senior; a locked choice for rebuilt_reputation ('the long way back') joins the high school callbacks.
- **COL_106 The Red Flag Interview** (Y4): A scout sits across from you with a folder: everything that happened in college, in writing. 'Walk me through it,' he says. · Opens on: any of character_concerns / college_warning · Sets: `took_responsibility_scout` · Lock: `rebuilt_reputation`

## Year-neutral (16)

### Academics
- **COL_138 The Professor Who Doubts Athletes** (Y1-4): A professor says, in front of the class, that athletes don't belong in her seminar.
- **COL_146 The Extension** (Y1-4; {teacher}): Team travel lands on a paper deadline. A teammate says the trick is to claim a family emergency. · Sets: `academic_shortcut`

### Body and mind
- **COL_141 Pickup Basketball** (Y1-4): Teammates want you in a pickup basketball game. One rolled ankle could cost you a month.
- **COL_149 The Weekend Off** (Y1-4): Friends invite you away for a weekend off, your first in months.

### Home
- **COL_135 Sunday Night Blues** (Y1-4; {parent}): Every Sunday night the dorm goes quiet and you miss home most.
- **COL_147 The Coach From Home** (Y1-4): Your high school coach visits campus and wants to watch you practice. · HS: `earned_coach_confidence`, `repaired_coach_trust`, `coach_trust_damaged`

### Media
- **COL_136 The Group Chat Screenshot** (Y1-4): A screenshot from the team group chat leaks, and a joke you laughed at is in it. · HS: `owned_old_group_chat`, `joined_group_mockery`
- **COL_140 The Fan Who Goes Too Far** (Y1-4): A fan's messages have gone from friendly to strange. Now he says he knows where you live.
- **COL_148 The Hospital Visit** (Y1-4): The team visits a children's hospital. Some players are there for the cameras; one kid asks you to stay longer.

### Money
- **COL_137 The Parking Ticket Pile** (Y1-4): Seven unpaid parking tickets and a hold on your registration.
- **COL_144 The Camp You Run** (Y1-4 offseason): Parents offer you cash to run private kicking lessons for their kids this summer. Compliance has rules about that. · Sets: `cash_camp`
- **COL_145 The Aid Office Error** (Y1-4): The financial aid office deposits twice what you're owed.

### Party
- **COL_139 The Bus Argument** (Y1-4; {team}): An argument on the team bus is turning personal, and two teammates are about to swing.
- **COL_143 The Borrowed Car** (Y1-4): A teammate wants to borrow your car for the night and won't say where he's going.

### Roommates
- **COL_134 The Roommate's Secret** (Y1-4): Your roommate admits he hasn't left the room in days and asks you not to tell anyone.

### Wrong path
- **COL_142 The Wrong Crowd** (Y1-4): A group of non-team friends parties every night, and they've started inviting you along. · Sets: `ran_with_wrong_crowd`

## Finale (1)

### Finale
- **COL_150 The Next Level** (Y4 wk 10, finale beat; {parent}, {coach}): The last week of your college career. Whatever happens on draft day, this is where the kicker you became walks off the field. · Sets: `ready_for_pros`, `life_after_football`, `still_proving_it` · Lock: `combine_ready`, `pro_day_ready`, `finished_degree_track`, `rebuilt_reputation` · Note: Locked choices: ready_for_pros needs combine_ready or pro_day_ready; life_after_football needs finished_degree_track; a rebuilt_reputation lock adds 'the long way back'; still_proving_it is open.

**Season 4 has no offseason.** The college stage goes straight from the last game to the draft, so draft-season scenes (combine prep, the scouts' workout, draft weekend plans, the senior trip, the leadership award, Old Rival, New Stage) happen in weeks 4-10 of the senior season. `validate_scenario_graph.py` reports an offseason scene in a stage's last season as an error.

### Wrong path (added)
- **COL_151 Who's Driving?** (Y2-3; Team): A teammate who has had too much insists on driving everyone home from a party. You're one of his passengers. · Sets: `rode_along` (strike), `found_another_ride`
- **COL_152 The Balcony Dare** (Y1-3 offseason): On a spring trip, a friend dares you to jump from the hotel balcony into the pool three floors down. · Sets: `balcony_jump` (new strike)
- **COL_153 The Keys** (Y2-4; Team): After a party, a teammate who is in no shape to drive demands his keys back. You're sober, and you're holding them. · Sets: `gave_keys_back` (new strike), `drove_teammates_home`
- **COL_154 The Fast Lane** (Y2-4; {coach}): A teammate pulls up next to you on the highway at night and dares you to race him to the next exit. · Sets: `street_race` (new strike)

`balcony_jump`, `street_race` and `gave_keys_back` are new strike flags: The Coach's Office, The Second Strike, The Pattern and The Final Warning read them and clear them.

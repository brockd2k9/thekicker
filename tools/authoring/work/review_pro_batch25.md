# PRO batch 25: quality pass (rewrites and stat fixes) (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 25: quality pass (rewrites and stat fixes)

### PRO_688 The Big Market Rumor
- **Category:** career  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A big-market club is rumored to want you next season.

A big-market club is rumored to want you next season.

1. **Say nothing**: You say nothing and let the rumor be a rumor.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
2. **Reassure your club**: You tell your club you're happy here.  
   *(social +2; charisma +1; **retention +2**; {coach} +1; modifier loose)*
3. **Use it**: You use it as fuel. You kick like you're auditioning.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_689 The Weather Delay
- **Category:** training  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A long weather delay, and you have to stay warm for three hours.

A long weather delay, and you have to stay warm for three hours.

1. **Plan the warmup**: You plan a warmup schedule with the trainers and stick to it.  
   *(energy -1; accuracy +1; intelligence +2; {coach} +2; modifier focused)*
2. **Keep the unit loose**: You keep the specialists laughing. Time passes.  
   *(social +2; charisma +1; Team +3; modifier loose)*
3. **Rest and wait**: You rest in the locker room and wait.  
   *(energy +2; fun +1; modifier rested)*

### PRO_690 The Players' Council
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The players form a leadership council, and you're on it.

The players form a leadership council, and you're on it.

1. **Take it seriously**: You commit to it. The council fixes three real problems.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
2. **Bring data**: You bring data to every meeting. The coaches listen.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Stay quiet**: You stay quiet and let the others lead.  
   *(energy +2; fun +1; modifier rested)*

### PRO_022 The National List
- **Category:** media  
- **Window:** age 30-33, once, followers tier fan_favorite  
- **Cast:** (no cast)  
- **Premise:** Your name is on the national list for the league's best kicker, and the team's PR staff has eleven requests for you.

Your name is on the national list for the league's best kicker, and the team's PR staff has eleven requests for you.

1. **Do them all**: You do all eleven. Your face is everywhere.  
   *(social +2; charisma +1; followers +5; Team +1; modifier loose)*
2. **Pick three**: You pick three and do them well.  
   *(energy -1; resilience +1; intelligence +2; followers +3; modifier focused)*
3. **Do none**: You do none and keep kicking.  
   *(energy +2; fun +1; modifier rested)*

### PRO_023 The Skills Contest
- **Category:** media  
- **Window:** age 30-33, once, followers tier fan_favorite  
- **Cast:** (no cast)  
- **Premise:** The league invites you to the long-distance contest at the all-star week.  
- **Note:** kick_challenge (competition) per the gameplay handoff.

The league invites you to the long-distance contest at the all-star week.

1. **Go and compete**: You go and compete. You train for it like a playoff game.  
   *(energy -2; resilience +1; ambition +2; 2 SP; followers +3; modifier dialed_in)*
2. **Go for the fun**: You go for the fun and spend the week with kickers from every club.  
   *(social +2; charisma +1; followers +2; Team +3; modifier loose)*
3. **Decline**: You decline and rest your leg.  
   *(energy +2; fun +1; modifier rested)*

### PRO_053 A Coach Out of a Job
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** {coach}  
- **Premise:** The head coach is fired after a team meeting. {coach}'s office lights are on late.

The head coach is fired after a team meeting. {coach}'s office lights are on late.

1. **Check on {coach}**: You stop by {coach}'s office. You talk for an hour.  
   *(social +2; charisma +1; {coach} +4; modifier loose)*
2. **Steady the room**: You steady the specialists. The week goes on.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
3. **Keep your head down**: You keep your head down and wait.  
   *(energy +2; fun +1; modifier rested)*

### PRO_054 The General Manager's Nephew
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** The new general manager is the owner's nephew, and he has opinions about kickers.

The new general manager is the owner's nephew, and he has opinions about kickers.

1. **Educate him**: You ask for a meeting and educate him, politely.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
2. **Let the work speak**: You let the work speak. He stops having opinions.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Win him over**: You invite him to watch a special teams practice.  
   *(social +2; charisma +1; {coach} +1; modifier loose)*

### PRO_055 Loyalty or the Paycheck
- **Category:** career  
- **Window:** age 30-33, once, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** Another club would pay you double. This one gave you your first chance.

Another club would pay you double. This one gave you your first chance.

1. **Stay**: You stay. The club remembers, and so do you.  
   *(social +2; charisma +1; **retention +2**; {coach} +1; modifier loose; sets `stayed_loyal`)*
2. **Explore it**: You tell your agent to explore it. You kick like a free agent.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in; sets `explored_options`)*
3. **Ask your club to match**: You ask your club to come closer. They meet you partway.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused; sets `stayed_loyal`)*

### PRO_070 The Foundation
- **Category:** community  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** Your charity foundation's director is spending more on galas than on kids.

Your charity foundation's director is spending more on galas than on kids.

1. **Replace the director**: You replace the director and run the next year yourself.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired; sets `started_foundation`)*
2. **Audit the books**: You audit the books and set new rules.  
   *(energy -1; resilience +1; intelligence +2; modifier focused; sets `started_foundation`)*
3. **Let it run**: You let it run. The galas are nice.  
   *(energy +2; fun +1; modifier rested)*

### PRO_072 Broke at Thirty-Three
- **Category:** money  
- **Window:** age 30-33, once, opens on `advisor_stole` / `bad_venture` / `spent_big_check` / `lived_large` / `hid_the_loss`  
- **Cast:** (no cast)  
- **Premise:** The money's gone faster than the career, and you have a mortgage, a family and maybe three seasons.

The money's gone faster than the career. There's a mortgage, a family, and maybe three seasons left in your leg, if you're lucky.

1. **Make a hard plan**: You sit down with an honest advisor and make a hard plan: a smaller house, no new cars, a budget on the fridge. It hurts, and it works.  
   *(energy -1; resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Tell your family everything**: You tell your family everything at the kitchen table. It's the worst conversation of your life and the best one; nobody leaves.  
   *(social +2; charisma +1; {love_interest} +4; modifier loose)*
3. **Kick for one more contract**: You decide to kick for one more contract like your family depends on it. It does, and every practice feels heavier.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*

### PRO_073 The Pension Meeting
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** The players' union holds a meeting about pensions and retirement plans. Six players show up.

The players' union holds a meeting about pensions and retirement plans. Six players show up.

1. **Go and take notes**: You go and take notes. It's boring and important.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
2. **Bring teammates next time**: You bring twelve teammates to the next one.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
3. **Skip it**: You skip it. Retirement feels far away.  
   *(energy +2; fun +1; modifier rested)*

### PRO_084 The Coach Who Taught You
- **Category:** community  
- **Window:** age 30-33, offseason, once  
- **Cast:** (no cast)  
- **Premise:** Your high school coach is retiring, and the school wants you to speak at the dinner.

Your high school coach is retiring, and the school wants you to speak at the dinner.

1. **Speak from the heart**: You tell the room what that coach did for you. They stand.  
   *(social +2; charisma +1; {coach} +1; modifier loose)*
2. **Bring the team**: You bring the current high school team to the dinner.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
3. **Send a letter**: You send a letter that gets read aloud.  
   *(energy +2; fun +1; modifier rested)*
4. 🔒 *locked: needs `earned_coach_confidence` or `repaired_coach_trust`, shown as "having earned a coach's trust before"*  
   **Tell the story of the trust**: You tell the story of how that trust was earned, and what it taught you about earning it again.  
   *(social +2; leadership +1; charisma +1; modifier inspired)*

### PRO_088 The Rookie Kicker You Mentor
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** {backup}, {coach}  
- **Premise:** The club drafts a kicker and asks you to show the rookie how things work, knowing what that means.

The club drafts a kicker and asks you to show the rookie how things work, knowing what that means.

1. **Teach him everything**: You teach him everything. He'll take your job someday, and he'll do it right.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired; sets `mentored_rookie_kicker`)*
2. **Teach him the basics**: You teach him the basics and keep the rest.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Let the coaches do it**: You let the coaches do it.  
   *(energy +2; fun +1; **retention -1**; modifier rested)*
4. 🔒 *locked: needs `mentored_backup` or `mentored_younger_student`, shown as "having mentored before"*  
   **Do it the way you've done it**: You've done this before. You know what to teach and when.  
   *(social +1; leadership +2; modifier inspired; sets `mentored_rookie_kicker`)*

#### Flags this batch sets, and what they open

- `explored_options` (from PRO_055) → COL_046 The Portal Call; COL_070 The New Head Coach; PRO_055 Loyalty or the Paycheck (planned locked choice)
- `honest_advisor` (from PRO_072) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice); PRO_371 The Financial Mistake (locked choice)
- `mentored_rookie_kicker` (from PRO_088) → PRO_089 The Mentee Takes Your Job; PRO_142 The Coaching Offer (locked choice); PRO_142 The Coaching Offer (planned locked choice)
- `started_foundation` (from PRO_070) → PRO_236 Selling the Business; PRO_237 The Foundation at Ten; PRO_700 The Charity Foundation Gala (locked choice); PRO_700 The Charity Foundation Gala (planned locked choice); PRO_828 The Gala in Your Honor (planned locked choice)
- `stayed_loyal` (from PRO_055) → COL_070 The New Head Coach; PRO_055 Loyalty or the Paycheck (planned locked choice)

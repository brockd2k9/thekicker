# PRO batch 53: the cross-era pool, set B (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 53: the cross-era pool, set B

### PRO_165 The Search
- **Category:** career  
- **Window:** once, needs `pro_banned_substance`  
- **Cast:** {coach}, Team, {parent}  
- **Premise:** League testers arrive unannounced and ask to see your locker and your gym bag. The package is still in it.  
- **Note:** Follow-up to The Package: a possession case, not a positive test, so the player is never shown taking anything. Costs: suspend_weeks (3 now; longer once R9 lands), retention, followers, conduct scandal (sponsors drop the player).

League testers arrive unannounced on a Tuesday and ask to see your locker and your gym bag. The package from the private gym trainer is still in the side pocket, exactly where you left it.

1. **Tell them before they look**: Before they unzip anything, you speak up and hand it over yourself. The league suspends you anyway, and the testers note in their report that you came forward first.  
   *(fun -2; resilience +2; leadership +1; **retention -3**; **suspended 4 games**; followers -3; modifier drained; **conduct scandal**; sets `pro_caught_with_package`)*
2. **Ask for the union lawyer**: Not a word until the union lawyer arrives, you insist, and the testers wait in the hallway. The case is handled properly and slowly, and the suspension still comes in the spring.  
   *(energy +1; fun -1; intelligence +2; **retention -4**; **suspended 6 games**; followers -4; modifier stressed; **conduct scandal**; sets `pro_caught_with_package`)*
3. **Say it isn't yours**: You say it isn't yours, which nobody believes, least of all the trainer's text messages. The suspension is the longest the league can give, and every sponsor leaves by Friday.  
   *(ambition +2; charisma +1; leadership -3; **retention -6**; **suspended 8 games**; followers -6; {coach} -6; Team -3; modifier stressed; **conduct scandal**; sets `pro_caught_with_package`)*
4. **Call {parent} first**: From the trainers' room, before the testers finish, you phone {parent}. You tell the truth on the phone first, then to the league, and {parent} drives up that night to sit with you.  
   *(social +1; fun -2; resilience +1; **retention -3**; **suspended 4 games**; followers -4; {parent} +3; modifier drained; **conduct scandal**; sets `pro_caught_with_package`)*

### PRO_166 The Night Before
- **Category:** social  
- **Window:** once  
- **Cast:** {coach}, Team, {love_interest}  
- **Premise:** The night before a game, a teammate's dinner (or your agent's dinner for his clients) moves to a strip club, and the whole table is getting up.  
- **Note:** Non-explicit: the scene ends at the choice, and the bad choice cuts to the next morning. Costs: photos online (followers, conduct bad), tired / late_night into the game, {coach}; {love_interest} only through a locked or follow-up line if the player has a partner (partner flags). No game result.

The night before a road game, a teammate's dinner moves on to an adult club across the river, and the whole table is getting up and reaching for their jackets.

1. **Go back to the hotel**: Back to the hotel, alone, with a room-service sandwich and the film you meant to watch anyway. You're the sharpest player at breakfast, and nobody even teases you about it.  
   *(energy +2; intelligence +1; modifier rested)*
2. **Get the young players back**: You round up the two rookies and put them in a car with you. They grumble the whole ride, and in the morning one of them thanks you quietly at the bus.  
   *(resilience +1; leadership +2; {backup} +2; modifier inspired)*
3. **Go along**: You go along. The next morning there are photos online, your legs feel like sand in warmups, and {coach} doesn't say a word to you, which is worse than shouting.  
   *(fun +3; social +2; energy -4; leadership -2; followers -2; {coach} -3; modifier late_night; **conduct bad**; sets **strike** `pro_night_before`)*
4. 🔒 *locked: needs `made_long_distance_work` or `committed_to_relationship` or `new_partner` or `engaged` or `married`, shown as "with someone waiting at home"*  
   **Call {love_interest} and head back**: You call {love_interest} from the curb and walk back to the hotel talking. By the time you hang up you've forgotten the club existed, and you sleep well.  
   *(social +2; health +1; {love_interest} +2; modifier rested)*

### PRO_167 Late for the Meeting
- **Category:** team  
- **Window:** repeats (15-week cooldown)  
- **Cast:** {coach}  
- **Premise:** The special teams meeting started at eight. It's 8:06, and you're in the parking lot.  
- **Note:** Escalation, step 1: the fine. Repeatable (cooldown 15 weeks); the escalating text lives in 168 and 169.

The special teams meeting started at eight. It's 8:06, you're still in the parking lot, and your phone has three missed calls from the coordinator's office.

1. **Walk in and own it**: You walk in, apologize to the room, and sit in the back. The fine is posted on the board by lunch, and the coordinator nods at you once, which means it's over.  
   *(resilience +2; leadership +1; modifier drained; sets `late_fined`)*
2. **Pay it and laugh it off**: You pay the fine and make a joke about the traffic at the next meeting. The room laughs, the coordinator doesn't, and the fine gets slightly bigger next time.  
   *(fun +2; charisma +1; modifier loose; sets `late_fined`)*
3. **Make up a story**: A flat tire, you tell them, which isn't true. The coordinator checks the security cameras, and the fine doubles, and now there's a note in your file with the word 'honesty' in it.  
   *(social +1; ambition +1; leadership -2; {coach} -2; modifier stressed; **conduct bad**; sets `late_fined`, **strike** `pro_late_meeting`)*

### PRO_168 Late Again
- **Category:** team  
- **Window:** once, needs `late_fined`  
- **Cast:** {coach}  
- **Premise:** Late again. This time {coach} is waiting outside the meeting room, and the fine isn't the topic.  
- **Note:** Escalation, step 2: the talking-to.

Late again, by four minutes this time. {coach} is waiting outside the meeting room with the door closed behind them, and the fine isn't what the coach wants to talk about.

1. **Listen all the way through**: You listen all the way through without an excuse. It's a hard ten minutes about trust and standards, and at the end the coach puts a hand on your shoulder.  
   *(resilience +2; intelligence +1; {coach} +2; modifier drained; sets `late_warned`)*
2. **Fix the real problem**: The truth about why comes out: the long commute, the late film nights, the broken alarm. Together you fix it, and you start arriving forty minutes early with a coffee for the coordinator.  
   *(intelligence +2; leadership +1; modifier focused; sets `late_warned`)*
3. **Argue it was four minutes**: You point out it was four minutes. {coach} looks at you for a long moment, says nothing else, and walks into the meeting without you, which follows you around for weeks.  
   *(ambition +2; charisma +1; leadership -2; {coach} -4; modifier stressed; **conduct bad**; sets `late_warned`, **strike** `pro_late_meeting`)*

### PRO_169 The Depth Chart Note
- **Category:** team  
- **Window:** once, needs `late_warned`  
- **Cast:** {coach}, {backup}  
- **Premise:** A third late arrival. There's a note on your locker: see {coach} before you dress.  
- **Note:** Escalation, step 3: inactive for a game (suspend_weeks 1, the club's discipline). Feeds the pro discipline chain through pro_late_meeting.

A third late arrival this season. There's a handwritten note taped to your locker: see {coach} before you dress. {backup} is already in the trainers' room, getting their ankles taped.

1. **Take it like a professional**: Like a professional, you accept the week inactive, and you hold for {backup} in warmups. The coach notices who you were in the worst week, and says so in the next meeting.  
   *(fun -2; resilience +1; leadership +2; **suspended 1 games**; {backup} +3; modifier drained; **conduct bad**; sets **strike** `pro_late_meeting`)*
2. **Ask what it takes to earn back trust**: You ask {coach} exactly what it takes to earn back their trust. The list is short and specific, and you start on it that afternoon, a week of early mornings.  
   *(fun -2; intelligence +2; ambition +1; **suspended 1 games**; {coach} +2; modifier focused; **conduct bad**; sets **strike** `pro_late_meeting`)*
3. **Spend the week sulking**: Sulking at home all week, phone off, you stay away from everything. The team plays without you and the building moves on, faster than you expected it to.  
   *(energy +2; fun -1; leadership -2; **suspended 1 games**; Team -2; modifier stressed; **conduct bad**; sets **strike** `pro_late_meeting`)*

### PRO_172 The Investigation
- **Category:** career  
- **Window:** once, needs `pro_betting_scandal`  
- **Cast:** {coach}, Team, {parent}  
- **Premise:** Two investigators from the league office are in the general manager's conference room, and they've asked for you by name.  
- **Note:** Follow-up: suspend_weeks 3 (the cap), retention, followers, scandal; character concerns for the pros (pro_character_concerns). Release follows through the discipline chain (R7).

Two investigators from the league office are waiting in the general manager's conference room with a thick folder and a recorder, and they've asked for you by name.

1. **Tell them everything**: Everything, start to finish, and then your signature on the statement. The suspension is long, and the investigators write that you cooperated fully, which matters later more than you know.  
   *(fun -3; resilience +2; leadership +1; **retention -4**; **suspended 6 games**; followers -4; Team +1; modifier drained; **conduct scandal**; sets `pro_character_concerns`)*
2. **Bring a lawyer and say little**: A lawyer beside you, and as few words as possible. It drags out for weeks, every word is careful, and the suspension lands anyway, slightly longer.  
   *(energy +1; fun -2; intelligence +2; **retention -5**; **suspended 8 games**; followers -5; modifier stressed; **conduct scandal**; sets `pro_character_concerns`)*
3. **Deny it**: You deny it, even with the phone records on the table in front of you. The suspension is the longest the league gives, and the whole locker room reads about it on the same morning.  
   *(ambition +2; charisma +1; leadership -3; **retention -6**; **suspended 11 games**; followers -7; {coach} -6; Team -4; modifier stressed; **conduct scandal**; sets `pro_character_concerns`)*
4. **Call {parent} that night**: You cooperate, and then you call {parent} that night and tell the whole story. It's the hardest call you've made, and {parent} stays on the line until you're ready to sleep.  
   *(social +2; fun -3; **retention -4**; **suspended 6 games**; followers -5; {parent} +3; modifier drained; **conduct scandal**; sets `pro_character_concerns`)*

### PRO_174 The Hearing
- **Category:** career  
- **Window:** once, needs `pro_solicitation`, not `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** {coach}, Team, {parent}  
- **Premise:** A police report, a league hearing and a sponsor's lawyer, all in the same week.  
- **Note:** Follow-up for a player without a partner. League discipline: suspend_weeks (longer once R9 lands), sponsors pull out (conduct scandal), retention, followers.

A police report, a league hearing and a sponsor's lawyer, all in the same week. Your agent has cleared the calendar and keeps saying the word 'contain' on the phone.

1. **Own it publicly**: A short statement, in your own words, with no excuses in it. The league suspends you, the sponsors leave anyway, and a few teammates text to say they respect how you handled it.  
   *(fun -3; resilience +2; leadership +1; **retention -3**; **suspended 4 games**; followers -4; Team +1; modifier drained; **conduct scandal**; sets `pro_hearing_done`)*
2. **Let the lawyers handle it**: You let the lawyers handle everything and say nothing at all. It's quieter and slower, the suspension is longer, and the silence reads to the public like hiding.  
   *(energy +1; fun -2; intelligence +2; **retention -4**; **suspended 6 games**; followers -5; modifier stressed; **conduct scandal**; sets `pro_hearing_done`)*
3. **Fight the league**: You fight the league's ruling through every appeal. It costs months, a lot of money and most of the goodwill you had left, and the suspension still stands at the end.  
   *(toughness +1; ambition +2; leadership -2; **retention -6**; **suspended 8 games**; followers -6; {coach} -5; modifier stressed; **conduct scandal**; sets `pro_hearing_done`)*
4. **Tell {parent} before the news does**: You tell {parent} before the news does, in person, at the kitchen table. It's a terrible conversation, and {parent} is still there on the morning of the hearing.  
   *(social +2; fun -3; **retention -3**; **suspended 4 games**; followers -5; {parent} +2; modifier drained; **conduct scandal**; sets `pro_hearing_done`)*

### PRO_175 The Hearing, at Home
- **Category:** family  
- **Window:** once, needs `pro_solicitation`, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** {coach}, Team, {love_interest}  
- **Premise:** A police report, a league hearing and a sponsor's lawyer, all in the same week, and {love_interest} has read every word of it.  
- **Note:** Follow-up for a player with a partner: the same discipline, plus {love_interest} (-10 to -15). Every choice sets pro_cheated, so the Found Out chain picks it up.

A police report, a league hearing and a sponsor's lawyer, all in the same week, and {love_interest} has read every word of it, sitting on the stairs with the paper in their lap.

1. **Tell them all of it**: You tell {love_interest} all of it, without softening anything. They listen, go upstairs, and close the door, and the hearing two days later feels small next to that.  
   *(fun -3; resilience +2; leadership +1; **retention -3**; **suspended 4 games**; followers -4; {love_interest} -10; modifier drained; **conduct scandal**; sets `pro_hearing_done`, **strike** `pro_cheated`)*
2. **Ask for counseling**: You ask {love_interest} to see a counselor with you, and mean it. They agree to one appointment, only one for now, and the suspension letter arrives the same morning.  
   *(social +1; fun -3; intelligence +2; **retention -3**; **suspended 4 games**; followers -5; {love_interest} -10; modifier drained; **conduct scandal**; sets `pro_hearing_done`, **strike** `pro_cheated`)*
3. **Minimize it**: You tell {love_interest} it isn't what it looks like. They've read the police report, and they look at you for a long time before packing a bag for a friend's.  
   *(ambition +2; charisma +1; leadership -2; **retention -4**; **suspended 6 games**; followers -5; {love_interest} -15; modifier stressed; **conduct scandal**; sets `pro_hearing_done`, **strike** `pro_cheated`)*

### PRO_200 The Yearly Media Session
- **Category:** media  
- **Window:** weeks 1-1, repeats (15-week cooldown)  
- **Cast:** Team  
- **Premise:** Media day, and the questions are the same every year. Your answers don't have to be.  
- **Note:** Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.

Media day, and the questions are the same as they always are: the leg, the pressure, the miss everybody still remembers. The reporters have their phones out before you sit down.

1. **Give them something new**: A new answer to an old question, rehearsed in the car on the way in. It runs on every channel that night, and the reporters actually look up from their phones.  
   *(fun +1; charisma +2; followers +2; modifier spotlight)*
2. **Keep it brief**: Short, polite and finished in eight minutes, with nothing anybody can use. You're back on the practice field before the linemen have even sat down at their tables.  
   *(energy +1; resilience +2; modifier focused)*
3. **Talk about the specialists**: You spend every answer on the snapper and {holder}, and they get their first real profile in the local paper. {holder} cuts it out and puts it on the fridge.  
   *(social +1; leadership +2; {holder} +2; modifier inspired)*
4. 🔒 *locked: needs `pro_seasons >= 6`, shown as "after six seasons in the league"*  
   **Answer the question before they ask it**: You've heard every question so many times you answer them before they're asked, with a grin. The room laughs, the young reporters write it all down, and the session is a joy.  
   *(charisma +2; leadership +1; followers +3; modifier loose)*

### PRO_201 Camp Opens
- **Category:** team  
- **Window:** weeks 1-1, repeats (15-week cooldown)  
- **Cast:** Team  
- **Premise:** The first day of camp. The rookies are terrified, the veterans are bored, and you're somewhere in between.  
- **Note:** Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.

The first day of camp. The rookies are terrified and too loud, the veterans are bored and too quiet, and you're somewhere in between with a new pair of cleats that pinch.

1. **Learn the rookies' names**: Every rookie's name, learned by the end of the first day, and used. They stop looking terrified by Wednesday, and one of them asks you about plant-foot drills.  
   *(social +2; leadership +1; Team +2; modifier inspired)*
2. **Get your legs under you**: A quiet first week of building your legs back up, slowly, with the trainers. You're the healthiest specialist in camp when the hitting starts, and you plan to stay that way.  
   *(health +2; power +1; modifier rested)*
3. **Set the tone early**: Every rep at full effort from the first whistle. The coaches notice, the other specialists pick it up, and your legs hate you by Friday.  
   *(energy -2; accuracy +1; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `pro_seasons >= 3`, shown as "after three seasons in the league"*  
   **Take {backup} under your wing**: You take {backup} aside on the first day and show them the things nobody showed you. It costs you an hour a day, and it's the best hour of camp.  
   *(leadership +2; charisma +1; {backup} +3; modifier inspired)*

### PRO_203 The Charity Kick
- **Category:** media  
- **Window:** repeats (15-week cooldown)  
- **Cast:** Team  
- **Premise:** The club's charity day: kids, cameras and a field goal for every dollar raised.  
- **Note:** Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.

The club's charity day: kids in oversized jerseys, a dozen cameras, and a field goal for every dollar raised. The organizers have put a microphone on you without asking.

1. **Kick until your leg gives out**: Kick after kick, until your leg is jelly and the board says the total twice what anyone hoped. The kids chant your name, and you can't lift your leg the next morning.  
   *(social +2; energy -3; power +1; followers +2; modifier drained)*
2. **Teach the kids instead**: The afternoon goes to teaching the kids to kick instead. One small girl puts it through from ten yards, and the cameras catch your face when it does.  
   *(fun +2; leadership +1; followers +3; modifier inspired)*
3. **Bring your own family**: You bring your own family and make it their day too, with {parent} working the face-painting tent. Nobody watches you kick, and that's perfect.  
   *(social +1; resilience +1; charisma +1; {parent} +2; modifier loose)*
4. 🔒 *locked: needs `pro_seasons >= 6`, shown as "after six seasons in the league"*  
   **Bring back an old charity**: You bring back the charity you've supported for years, and the total goes to them. Their director cries on the microphone, and the club makes it a yearly thing.  
   *(leadership +2; charisma +1; followers +2; modifier inspired)*

### PRO_204 Bye Week at Home
- **Category:** family  
- **Window:** repeats (15-week cooldown)  
- **Cast:** Team  
- **Premise:** The bye week. Home for six days, and everyone wants a piece of them.  
- **Note:** Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.

The bye week. You're home for six days, and everyone wants a piece of them: family, friends, the plumber who has been rescheduling since August, and a dog who has forgotten your face.

1. **Rest, properly**: You rest properly for the first three days: long sleeps, a slow walk, no phone. By Thursday your legs feel new and your family has stopped tiptoeing around you.  
   *(energy +3; health +1; modifier rested)*
2. **See everyone**: You see everyone, every day, from breakfast to the last late phone call. It's wonderful and exhausting, and {best_friend} says it's the most like yourself you've been in months.  
   *(social +3; energy -2; {best_friend} +2; modifier loose)*
3. **Fix the house**: You fix the house, finally: the gutter, the gate, the leak under the sink. It's satisfying in a way kicking never quite is, and {sibling} comes over to help.  
   *(fun +1; toughness +1; intelligence +1; {sibling} +2; modifier focused)*
4. 🔒 *locked: needs `pro_seasons >= 6`, shown as "after six seasons in the league"*  
   **Keep the bye-week ritual**: The same bye week you've had for years: the same diner, the same hike, the same movie with the kids. The ritual itself is the rest, and everyone knows their parts.  
   *(energy +2; social +1; resilience +1; modifier rested)*

### PRO_205 The Offseason Plan
- **Category:** career  
- **Window:** offseason, repeats (15-week cooldown)  
- **Cast:** Team  
- **Premise:** The offseason starts. You can rest, rebuild or chase something new.  
- **Note:** Repeatable (15-week cooldown). Locked choices open with experience: min pro_seasons 3 / 6 / 10, age, earlier flags.

The offseason starts on a gray Monday. Your locker is empty, your calendar isn't yet, and you can rest, rebuild or chase something new before camp opens in July.

1. **Rest first**: The first month is off completely: no kicking, no film, no plans. Your body is grateful by week three, and your mind follows soon after.  
   *(health +2; energy +2; modifier rested)*
2. **Rebuild your leg**: A strength program with a specialist, four days a week, from the first week on. It's hard and boring, and you come back to camp with more leg than you've had in years.  
   *(energy -2; power +2; toughness +1; 2 SP; modifier heavy_legs)*
3. **Learn something new**: A course, a language, a skill that has nothing to do with football. It fills the empty days, and it reminds you there's a person under the helmet.  
   *(fun +1; intelligence +2; modifier focused)*
4. 🔒 *locked: needs `pro_seasons >= 10`, shown as "after ten seasons in the league"*  
   **Start planning the next life**: You start sketching out the life after football, quietly, with a notebook and a few phone calls. It isn't sad at all, it turns out, and some of it is exciting.  
   *(intelligence +2; ambition +1; modifier focused)*

#### Flags this batch sets, and what they open

- `late_fined` (from PRO_167) → PRO_168 Late Again
- `late_warned` (from PRO_168) → PRO_169 The Depth Chart Note
- `pro_caught_with_package` (from PRO_165) → nothing reads it yet
- `pro_character_concerns` (from PRO_172) → PRO_128 Earning It Back
- `pro_cheated` (from PRO_175) → PRO_160 Found Out
- `pro_hearing_done` (from PRO_174, PRO_175) → nothing reads it yet
- `pro_late_meeting` (from PRO_167, PRO_168, PRO_169) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `pro_night_before` (from PRO_166) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing

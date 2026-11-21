# Patch round: number fixes (34 scenes)

Dry run and import: 0 errors, 0 warnings, 0 lint notes. Windows narrowed in pro_design.json: PRO_766 age 35 only, PRO_630 3+ pro seasons, PRO_632 needs re_signed or signed_new_club, PRO_265 needs released, PRO_319 exactly 10 pro seasons.


## Number fixes

### PRO_038 Contract Year: One More
- **Category:** career  
- **Window:** age 35-37, age-banded variant, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** At your age, the next contract is one year at a time, and everyone in the building knows it.

This late in a career, the next contract is one year at a time, and everyone in the building knows it, including the twenty-two-year-old kicker on the practice squad.

1. **Earn the next year every day**: Every practice treated as the interview it is. The coaches notice the veteran who never takes a rep off, and so does the rookie.  
   *(energy -2; toughness +1; ambition +2; 3 SP; modifier dialed_in)*
2. **Talk numbers honestly**: Your agent and you, talking numbers honestly: one year, fair money, and an out if your body says so. It's a calm conversation.  
   *(resilience +1; intelligence +2; modifier focused)*
3. **Talk it over at home**: One more, you both say at the kitchen table, and you both mean it completely. {love_interest} squeezes your hand and doesn't let go.  
   *(social +2; fun +1; {love_interest} +3; modifier loose)*

### PRO_072 Broke in Your Thirties
- **Category:** money  
- **Window:** age 30-33, once, opens on `advisor_stole` / `bad_venture` / `spent_big_check` / `lived_large` / `hid_the_loss`  
- **Cast:** (no cast)  
- **Premise:** The money's gone faster than the career, and you have a mortgage, a family and maybe three seasons.

The money's gone faster than the career. There's a mortgage, a family, a car payment, and maybe three seasons left in your leg, if you're very lucky.

1. **Make a hard plan**: An honest advisor and a hard plan: a smaller house, no new cars, a budget taped to the fridge. It hurts, and it works.  
   *(resilience +2; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Tell your family everything**: You tell your family everything at the kitchen table. It's the worst conversation of your life and the best one; nobody leaves.  
   *(social +2; leadership +1; {parent} +3; modifier loose)*
3. **Kick for one more contract**: You decide to kick for one more contract like your family depends on it. It does, and every practice feels heavier.  
   *(energy -2; toughness +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_133 The Younger Kicker in Camp
- **Category:** career  
- **Window:** age 35-37, weeks 1-3, age-banded variant  
- **Cast:** {backup}, {coach}  
- **Premise:** The club drafts a kicker in the fourth round, and he's sitting in your seat in the meeting room.

Deep into your thirties, you walk into the meeting room and a fourth-round rookie is sitting in your seat. He doesn't know it's your seat. Everyone else does.

1. **Take your seat back every day**: First into the meeting room, every day after that. The seat is yours until it isn't, and you're not going to give it away for free.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in)*
2. **Teach him**: Your routine, your wind charts, your nerves: you teach him all of it. It's the right thing, and it makes the room trust you even more.  
   *(energy -1; leadership +3; {backup} +4; modifier inspired)*
3. **Ask where you stand**: {coach}, asked plainly in the hallway. It's an open competition, the coach says, and you appreciate the honesty more than the answer.  
   *(accuracy +1; intelligence +2; {coach} +2; modifier focused)*

### PRO_140 The Comeback Workout
- **Category:** career  
- **Window:** age 34-37, once, needs `signed_new_club` + `released`  
- **Cast:** (no cast)  
- **Premise:** Released last spring, signed this summer: everyone in camp thinks you're finished.

Released last spring, signed this summer by a club that needed a kicker fast, at an age when most kickers are coaching. Everyone in camp, including some of the coaches, thinks you're finished.

1. **Show them on day one**: On the first day of camp, and every day after, you show them. By August, nobody calls you finished, and the youngest kicker asks for your routine.  
   *(energy -3; power +1; ambition +2; 3 SP; modifier dialed_in)*
2. **Help the young players**: From the first day, the young players get your help: film, rides, nerves. You're the veteran they didn't know they needed, and they say so.  
   *(energy -1; leadership +3; {backup} +3; modifier inspired)*
3. **Let the numbers argue**: Every kick charted, and the numbers left on {coach}'s desk every Friday. They're good numbers, and they do the arguing for you.  
   *(accuracy +1; intelligence +2; {coach} +2; modifier focused)*

### PRO_180 The Veteran Slump
- **Category:** training  
- **Window:** age 35-37, age-banded variant, slump_now 1+  
- **Cast:** {coach}, {holder}  
- **Premise:** At your age a slump doesn't look like a slump. It looks like the end, and talk radio says so.

A slump at your age doesn't look like a slump to anyone outside the building. It looks like the end, and talk radio has started saying so every morning, by name, with a countdown.

1. **Find the cause in the film**: Three nights of film, alone, and there it is: your plant foot has drifted half an inch, the way it did when you were young. It isn't age. You fix it by Thursday and tell nobody.  
   *(accuracy +2; intelligence +2; modifier focused)*
2. **Kick until it breaks**: Two hundred balls a day, until your leg is heavy and the slump finally cracks on day twelve. Your hip pays for every one of them, and you'd do it again.  
   *(energy -3; power +1; ambition +2; 3 SP; modifier heavy_legs)*
3. **Turn the radio off**: The radio, off, in the car and the kitchen and the locker room. Without the countdown in your ears, the misses get quieter, and so do you.  
   *(energy +1; resilience +2; {love_interest} +1; modifier rested)*
4. 🔒 *locked: needs `saw_sports_psych` or `leaned_on_support`, shown as "having gotten help before"*  
   **Use what you learned the first time**: The tools from the first slump come back like an old song: the breath, the word, the one thought. This one is shorter than any before it, and you're almost grateful for it.  
   *(energy +1; resilience +2; 1 SP; modifier focused)*

### PRO_185 Still Got It
- **Category:** media  
- **Window:** age 35-37, age-banded variant, fg_streak 8+  
- **Cast:** Team  
- **Premise:** A run of makes at your age, and every story calls it a 'renaissance'. You'd call it work.

A month without a miss, this late in a career, and every story calls it a 'renaissance'. A television crew wants to film your morning routine. You'd call the whole thing work.

1. **Let them film the routine**: The crew films the routine at six in the morning: bands, heat, the long walk. The piece is honest about the work, and young kickers start copying it.  
   *(social +1; fun +1; charisma +2; followers +3; modifier spotlight)*
2. **Say nothing about it**: No crew, no interviews, no word about the run. The streak is a fragile thing, and you treat it like a full glass you're carrying across a room.  
   *(resilience +2; intelligence +1; modifier focused)*
3. **Credit the people around you**: Every interview turns to the snapper, {holder} and the trainers who keep your hip alive. The specialists' group chat is very pleased with itself.  
   *(social +1; leadership +2; {holder} +3; Team +1; modifier inspired)*

### PRO_197 The Veteran Signing
- **Category:** team  
- **Window:** age 35-37, age-banded variant, needs `signed_new_club`  
- **Cast:** Team, {love_interest}  
- **Premise:** They signed you for your experience. The young players want to know what that means.

A new club signed you this late in your career 'for your experience'. On the first day, three young players wait by your locker to find out what that actually means.

1. **Show them on day one**: Early on the field, last off it, every kick charted. By Friday the young players have stopped asking what experience means; they've watched it.  
   *(energy -2; ambition +1; leadership +2; 1 SP; {backup} +2; Team +1; modifier inspired)*
2. **Take them to lunch**: Lunch with the three of them, and then with everyone else. The stories you tell are mostly about mistakes, which is what they actually wanted.  
   *(social +2; fun +1; charisma +1; Team +3; modifier loose)*
3. **Keep your head down**: Your own work, quietly, no speeches. They learn from watching, which is slower, and the coaches notice you never ask for anything.  
   *(resilience +2; intelligence +1; {coach} +1; modifier focused)*

### PRO_259 The Recovery Clinic
- **Category:** health  
- **Window:** age 34-37, once  
- **Cast:** {coach}, Team  
- **Premise:** A clinic promises to make your thirty-eight-year-old leg feel twenty-eight. Its menu includes a banned substance.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.

A recovery clinic promises to make your veteran leg feel ten years younger. The brochure is beautiful, two veterans swear by it, and the treatment menu includes a substance the league bans.

1. **Walk out of the consultation**: Out of the consultation, politely, before the second page. You tell the team doctor about the clinic, and she thanks you and adds it to a list.  
   *(health +1; intelligence +2; {coach} +2; modifier focused)*
2. **Ask the team doctor for a real plan**: A real plan from the team doctor: legal, slow and specific. Your leg doesn't feel ten years younger, and by October it feels strong, honest and your own.  
   *(energy -1; health +3; resilience +1; {coach} +1; modifier focused)*
3. **Book the full program**: The forms for the full program, signed in the clinic's leather chair. Three weeks later the league's testers are waiting at the facility on a Tuesday morning, and your name is first on their list.  
   *(health +2; fun +1; intelligence -2; leadership -2; **retention -4**; {coach} -6; Team -3; modifier stressed; **conduct scandal**; sets **strike** `pro_banned_substance`)*

### PRO_416 The Retirement Rumors
- **Category:** media  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** The media have started asking how much longer you'll play.

The media have started asking how much longer you'll play: at your locker, on the radio, in a column titled 'The Last Good Years'. You're in your thirties, you feel fine, and you'd rather be asked about kicking.

1. **Give the same answer every time**: 'As long as I'm good,' every time, to every reporter, word for word. They stop asking by October, bored, which was the point.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Joke about the question**: A joke about needing a walker for the post-game interview. The clip goes around the league, and the columnist writes a nicer column.  
   *(social +2; fun +2; followers +2; modifier loose)*
3. **Stop answering questions**: Practice instead of interviews, every single day. Your silence says more than any answer could, and your kicks say all the rest.  
   *(energy -2; power +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_444 The Training Load
- **Category:** training  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You have to choose between training hard and recovering.

This deep into a career you have to choose, every single week: train hard and risk the body, or recover and risk the edge. The trainers have different opinions on every day of the week.

1. **Train hard on Mondays only**: One hard day, Mondays, and recovery the rest of the week. It's a system, and it works better than either extreme.  
   *(health +1; accuracy +1; intelligence +2; modifier focused)*
2. **Keep training hard**: Hard, every day, the way you always have. You're strong and sore, and the trainers watch you nervously from the sideline.  
   *(energy -3; power +2; ambition +1; 3 SP; modifier heavy_legs)*
3. **Recover first**: Recovery first, training second, every week of the season. Your body feels years younger, and your leg feels a little rusty by Saturday morning.  
   *(energy +3; health +2; modifier rested)*

### PRO_692 Doubts in Your Thirties
- **Category:** training  
- **Window:** age 30-33, once, slump_now 1+  
- **Cast:** (no cast)  
- **Premise:** A slump at thirty, and the questions are about your age, not your form.

A slump in your thirties, and the questions are all about your age, not your form. The analysts have started using the word 'decline', and a reporter asks about retirement.

1. **Find the real cause in the film**: The real cause, found in the film after three nights: your plant foot, not your age. You fix it in a week and say nothing to the reporters.  
   *(accuracy +2; intelligence +1; modifier focused)*
2. **Kick two hundred a day**: Two hundred balls a day, every day, until the slump breaks. It does, on day eleven, and your leg feels every one of them.  
   *(energy -3; power +1; ambition +2; 3 SP; modifier heavy_legs)*
3. **Lean on {holder}**: {holder}, who has seen you through everything, says simply that this is just another one. It helps more than any drill.  
   *(social +2; resilience +2; {holder} +3; modifier loose)*
4. 🔒 *locked: needs `saw_sports_psych` or `leaned_on_support`, shown as "having gotten help before"*  
   **Use the tools you learned**: The tools you learned the first time come right back: the breath, the word, the one thought. The slump is shorter, and the reporters move on.  
   *(energy +1; intelligence +1; 1 SP; modifier focused)*

### PRO_693 The Thirty-Something Streak
- **Category:** media  
- **Window:** age 30-33, once, fg_streak 8+  
- **Cast:** (no cast)  
- **Premise:** A month without a miss, and the stories say you're better than ever.

A month without a miss, and the stories say you're better than ever in your thirties. The highlight shows have a graphic, and the specialists have stopped saying the word.

1. **Stay in your routine**: Nothing changes: same breakfast, same warmup, same parking spot. You don't read a word of the stories, and the streak goes on.  
   *(resilience +2; intelligence +1; modifier focused)*
2. **Share it with the unit**: The streak belongs to the snapper and {holder} too, and you say so in every interview. The specialists' chat is very happy.  
   *(social +2; leadership +1; {holder} +3; Team +1; modifier inspired)*
3. **Enjoy it quietly at home**: A good dinner at home, the television off. You enjoy it the way you'd want to remember it, and {parent} calls to say he's proud.  
   *(energy +2; fun +2; {parent} +1; modifier rested)*

### PRO_695 The Slow Recovery
- **Category:** health  
- **Window:** age 30-33, once, injured_now 1+  
- **Cast:** (no cast)  
- **Premise:** An injury at thirty, and the recovery takes longer than it used to.

An injury in your thirties, a groin strain on a routine kick, and the recovery takes longer than it used to. The trainers keep saying 'at your age', gently.

1. **Follow the plan exactly**: The plan, exactly, for six weeks. It takes longer than it would have a few years ago, and you come back whole.  
   *(health +3; energy -1; intelligence +1; {coach} +1; modifier focused)*
2. **Push to come back**: Back two weeks early, and sore. You kick carefully for a month, and the trainers watch every rep like hawks.  
   *(health -2; toughness +1; ambition +2; 2 SP; modifier sore)*
3. **Take extra time**: Extra time, on purpose. You come back fresh and a little behind, and your body thanks you for it all season.  
   *(energy +3; health +2; fun +1; modifier rested)*
4. 🔒 *locked: needs `committed_to_recovery` or `hid_injury`, shown as "having been through a hard recovery before"*  
   **Use what you learned**: What you learned last time comes straight back: the order of the exercises, the warning signs, the patience. You're back on schedule and smarter.  
   *(energy -1; health +3; intelligence +1; modifier rested)*

### PRO_696 The New Club in Your Thirties
- **Category:** team  
- **Window:** age 30-33, club season 1, once, needs `signed_new_club`  
- **Cast:** (no cast)  
- **Premise:** A new club, and the young players already know your name.

A new club, in your thirties, and the young players already know your name. Some of them had your poster. One of them asks you to sign his old jersey.

1. **Earn it anyway**: Earned anyway, one practice at a time, as if nobody knew you. The young players respect that more than the poster.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in)*
2. **Take the young specialists to lunch**: Lunch, the first week, with every young specialist. By Friday they're asking you everything, and you're the heart of the room.  
   *(social +2; leadership +1; {backup} +3; {holder} +2; modifier loose)*
3. **Focus on the job**: Just the job, quietly, and the rest follows on its own. You sign the old jersey, say very little else, and the young players respect it.  
   *(accuracy +1; resilience +1; intelligence +1; modifier focused)*

### PRO_754 The Halfway Point
- **Category:** media  
- **Window:** age 30-33, once, pro_seasons 8+  
- **Cast:** (no cast)  
- **Premise:** A reporter asks if you think you're halfway through your career.

A reporter asks if you think you're halfway through your career. You're in your thirties, it's a fair question, and you have no idea how to answer it.

1. **Give a careful answer**: Focused on this season, you say, which is true. Later, in the car, you think about the question for a long time.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Joke about it**: You hope it's a third, you say, and the room laughs. The clip goes around, and {parent} sends it to everyone he knows.  
   *(social +2; fun +1; followers +2; {parent} +1; modifier loose)*
3. **Say you're just starting**: Just getting started, you say, and you mean it. The column the next day calls you 'defiant', which you like.  
   *(energy -1; ambition +2; 1 SP; modifier dialed_in)*

### PRO_766 The Thirty-Fifth Birthday
- **Category:** team  
- **Window:** age 35, once  
- **Cast:** (no cast)  
- **Premise:** You turn thirty-five in camp, and the young players bake you a cake shaped like a walker.

Another birthday in camp, and the young players bake you a cake shaped like a walker, with candles on the wheels and a card signed by the entire roster.

1. **Laugh harder than anyone**: The loudest laugh in the cafeteria is yours, and you blow out every candle on the walker. The photo ends up in the team's yearbook.  
   *(fun +3; social +2; Team +2; modifier loose)*
2. **Give a speech about getting old**: Standing on a cafeteria chair, you give a short speech about what getting old in this league actually teaches you. It starts as a joke and ends with the room silent.  
   *(leadership +2; charisma +1; {backup} +2; modifier inspired)*
3. **Get revenge in practice**: Revenge, served in practice: every rookie who signed the card has to shag your kicks for an hour. They do it laughing, and you kick beautifully.  
   *(energy -1; power +1; ambition +2; 1 SP; {backup} +1; modifier dialed_in)*

### PRO_221 The Anniversary
- **Category:** family  
- **Window:** age 30-33, once, needs `married`  
- **Cast:** {love_interest}  
- **Premise:** Ten years married, and you're in a hotel in a city you can't remember the name of.

Another wedding anniversary, and you're in a hotel room in a city you can't remember the name of, with a road game tomorrow. {love_interest} is home with the dog and a cake.

1. **Fly {love_interest} in**: A ticket for the last flight in, booked from the team bus. One night together in a strange city, and it's the best anniversary yet.  
   *(social +2; fun +3; {love_interest} +6; modifier inspired)*
2. **Plan the real celebration**: The real celebration, planned for the bye week, down to the restaurant and the song. You talk about it all night on the phone.  
   *(intelligence +2; leadership +1; {love_interest} +3; modifier focused)*
3. **Call for an hour**: An hour on the phone from the hotel, talking about the first year: the tiny apartment, the bad car. It's enough, almost.  
   *(energy +1; resilience +1; {love_interest} +2; modifier rested)*

### PRO_097 The Reunion
- **Category:** social  
- **Window:** age 34-37, offseason, once  
- **Cast:** {best_friend}  
- **Premise:** Your high school reunion is the weekend after the season, and everyone wants to know what the league is like.

Your high school reunion is the weekend after the season ends. A gym with streamers, name tags, and everyone wants to know what the league is really like.

1. **Tell stories all night**: Stories, all night, to a growing circle by the bleachers. Your old friends laugh in the same places they always did, and {best_friend} finishes your sentences.  
   *(social +3; fun +2; {best_friend} +4; modifier loose)*
2. **Ask about their lives instead**: Their lives, asked about, one by one. They're more interesting than the league: a nurse, a farmer, a pilot, a teacher who still remembers your essay.  
   *(intelligence +1; charisma +2; modifier inspired)*
3. **Skip the reunion**: Skipped, and you see the pictures later online. Everyone looks older, and so do you, and you feel the miss more than you expected.  
   *(energy +2; resilience +1; {best_friend} -1; modifier rested)*

### PRO_302 The Owner's Funeral
- **Category:** community  
- **Window:** once, pro_seasons 10+  
- **Cast:** Team  
- **Premise:** The owner who signed you dies, and the family asks you to speak.

The owner of the club that first signed you has died at eighty-one. His family asks if you'll speak at the memorial, because he used to talk about you at dinner.

1. **Speak about the man**: Not the owner, the man: the way he knew the equipment staff's kids' names. His widow holds your hand afterward for a long time.  
   *(social +1; charisma +2; Team +1; modifier inspired)*
2. **Tell one story about him**: One story, the one about your rookie contract and the handwritten note he slipped into it. The room laughs and then goes very quiet.  
   *(fun +1; resilience +1; charisma +1; modifier focused)*
3. **Write to the family instead**: A letter to the family, long and personal, because you're no good at podiums. They read it at the reception, and his grandson keeps it.  
   *(resilience +2; intelligence +1; modifier rested)*

### PRO_800 The Fan Who Has Seen Every Game
- **Category:** community  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** A fan has been to every one of your home games, and wants a picture for the last one.

A fan has been to every one of your home games since you arrived, always in the same seat, and asks through the team for a photo at what might be the last one.

1. **Meet her on the field**: On the field, before warmups, with a photographer and a signed ball. She brings a scrapbook of every ticket stub.  
   *(social +2; fun +1; charisma +1; followers +2; modifier inspired)*
2. **Invite her to practice**: A practice pass, a lunch with the specialists, a tour of the locker room. She cries at the locker, and so does {holder}.  
   *(social +2; leadership +1; {holder} +2; modifier inspired)*
3. **Send a letter and a jersey**: A long letter and a signed jersey, delivered to her seat before kickoff. She frames both, and she writes back on lined paper.  
   *(fun +1; resilience +1; intelligence +1; modifier rested)*

### PRO_807 The Trainer's Retirement
- **Category:** health  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** The trainer who has taped your ankle for years is retiring.

The trainer who has taped your ankle every game day since you arrived is retiring. He says your ankle is the one he'll miss, which you choose to take as a compliment.

1. **Give him a send-off**: A send-off in the training room, with every player he ever taped. You tape his ankle, badly, and he laughs until he cries.  
   *(social +2; fun +2; Team +3; modifier inspired)*
2. **Learn to tape it yourself**: His last lesson: how to tape your own ankle properly. You practice for a week, and his successor is impressed.  
   *(health +1; intelligence +1; leadership +1; modifier focused)*
3. **Write him a note**: A note, left in his kit bag, about every game day morning. He reads it at his retirement party and has to stop.  
   *(resilience +2; charisma +1; modifier rested)*

### PRO_630 No Longer a Rookie
- **Category:** career  
- **Window:** age 26-29, once, pro_seasons 3+  
- **Cast:** (no cast)  
- **Premise:** Your fourth pro season, and nobody calls you a rookie anymore.

Another pro season. Nobody calls you a rookie anymore, the equipment manager knows your cleat size by heart, and two of this year's rookies ask for your autograph.

1. **Look out for the rookies**: The rookies get looked after, the way someone once looked after you: rides, meals, the names of the people who matter.  
   *(energy -2; leadership +2; charisma +1; 1 SP; {backup} +2; modifier inspired)*
2. **Raise your own bar**: Nobody else will raise your bar now, so you do it yourself: new goals, written down and taped to the bathroom mirror.  
   *(energy -2; accuracy +1; ambition +2; 2 SP; modifier dialed_in)*
3. **Enjoy the ease**: Some ease, finally earned. You enjoy this season more than any before it, and the snapper says you look five years younger.  
   *(energy +2; fun +2; modifier rested)*

### PRO_634 The Specialist Who Retires
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The punter you've worked beside for years retires suddenly.

The punter you've worked beside since your first day at the club retires suddenly, with a two-line statement on a Tuesday afternoon. He hasn't returned anyone's calls since, including yours.

1. **Throw him a send-off**: A send-off with the specialists at his favorite diner, whether he likes it or not. He comes, finally, and it's loud and long.  
   *(social +2; fun +2; energy -1; Team +2; {holder} +1; modifier loose)*
2. **Help the new punter settle**: The new punter gets your time and the old punter's tricks, passed along. The unit stays steady through the change.  
   *(energy -2; leadership +2; 1 SP; {backup} +2; modifier inspired)*
3. **Give him his quiet**: His quiet, respected. You send one short message and wait, and a month later he calls you first, from a lake.  
   *(energy +1; resilience +2; modifier rested)*

### PRO_632 The Raise
- **Category:** money  
- **Window:** age 26-29, once, opens on `re_signed` / `signed_new_club`  
- **Cast:** (no cast)  
- **Premise:** Your second contract is real money, and everyone you know has noticed.

Your new contract is real money, and everyone you know has noticed: old friends with ideas, cousins with emergencies, a teacher from middle school with a fundraiser.

1. **Set one rule for everyone**: One rule, for everyone, written down. It's fair, it's a little lonely, and the calls slow down within a month.  
   *(intelligence +2; leadership +1; modifier focused)*
2. **Help the ones who need it**: The people who really need it get help, quietly, and nobody else hears about it. {parent} finds out anyway and is proud.  
   *(social +1; fun +1; charisma +1; {parent} +3; modifier inspired)*
3. **Change your number**: A new phone number, given to twelve people. Things get quieter immediately, and two old friends feel shut out and say so.  
   *(energy +2; resilience +1; {best_friend} -1; modifier rested)*

### PRO_265 The Grudge
- **Category:** social  
- **Window:** age 34-37, once, needs `released`  
- **Cast:** {coach}, Team  
- **Premise:** The general manager who released you two years ago is at the same restaurant, and he's laughing.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.

The general manager who released you is at the same restaurant, three tables away, and he's laughing loudly. You're sure, for a moment, that he's laughing about you.

1. **Finish your dinner**: Your dinner, finished, and the check, paid. He never sees you, and on the drive home you realize you don't care as much as you thought.  
   *(resilience +2; intelligence +1; {love_interest} +1; modifier rested)*
2. **Say a polite hello**: A polite hello at his table, on your way out. He's surprised, then gracious, and says he made a mistake back then. You both pretend that settles it.  
   *(charisma +2; leadership +1; modifier confident)*
3. **Go over and say something**: You go over and say something you've rehearsed in the car for years. Words turn into a shove, a phone camera catches it, and the video is everywhere by midnight.  
   *(fun +1; ambition +1; leadership -3; intelligence -2; **retention -4**; followers -5; {coach} -4; modifier stressed; **conduct scandal**; sets **strike** `pro_bar_fight`)*

### PRO_404 The Mentor's Retirement
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A coach who shaped your career is stepping away.

The special teams coach who rebuilt your swing years ago is retiring at the end of the year, and he calls to tell you before he tells anyone else, even his own players.

1. **Thank him**: You drive to his house on a Tuesday and thank him in his kitchen. He waves it off, then walks you to the car and doesn't let go of the handshake.  
   *(social +2; resilience +1; {coach} +2; modifier loose)*
2. **Organize a send-off**: You call every kicker and punter he ever coached. Eleven of them show up for his last practice, and he has to turn around to the fence for a minute.  
   *(energy -2; leadership +3; 1 SP; Team +2; modifier inspired)*
3. **Leave a note**: You write him a note and leave it in his playbook. He never mentions it, but on his last day it's the only thing he takes from the desk.  
   *(energy +2; intelligence +1; modifier rested)*

### PRO_435 The Backup Role
- **Category:** career  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** A club offers you a job behind a younger kicker.

A club offers you a job: backup kicker, behind a twenty-four-year-old with a huge leg. The money is fine. It's the job young kickers hold while they wait their turn, and you are not young.

1. **Take it and teach**: The job, taken, and the young kicker gets everything you know. He's better by midseason, and the room calls you 'coach' half seriously.  
   *(social +1; leadership +2; {backup} +4; modifier inspired)*
2. **Take it and compete**: The job, taken, and you compete for the real one every day. The young kicker gets better because of you, whether he likes it or not.  
   *(energy -2; accuracy +1; ambition +2; 2 SP; modifier dialed_in)*
3. **Turn it down**: No, politely. You'd rather start somewhere small than sit somewhere big, and your agent sighs and makes three more calls.  
   *(resilience +2; ambition +1; modifier stressed)*

### PRO_319 Ten Years
- **Category:** career  
- **Window:** once, pro_seasons 10+, pro_seasons under 10  
- **Cast:** Team  
- **Premise:** Ten years in the league. The pension kicks in, and so does the question of how many more.

A decade in the league. The pension kicks in, the club gives you a watch, and the question arrives with it, uninvited: how many more?

1. **Go for more**: Not done, not close. You tell {coach} and your agent the same thing, and you start the eleventh year angrier than the first.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in)*
2. **Plan the next five years**: The next five years, planned with your agent and your family at the kitchen table. Everyone breathes easier, including you.  
   *(intelligence +2; leadership +1; {parent} +1; modifier focused)*
3. **Celebrate with the people who got you here**: A party for everyone who got you here: coaches, holders, {parent}, {best_friend}. The watch goes around the room twice, and {parent} cries.  
   *(social +2; fun +2; {parent} +3; {best_friend} +2; modifier inspired)*

### PRO_008 Homesick in {town}
- **Category:** family  
- **Window:** age 21-25, club season 1, once  
- **Cast:** {parent}, {best_friend}  
- **Premise:** Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.

Nobody in {town} knows your name yet. Practice ends at four, the apartment is very quiet on Tuesday nights, and the only voice you hear after dinner is the television.

1. **Call home every night**: You call home every night for a week. {parent} starts saving up stories for you like he used to before school, and {sibling} grabs the phone at the end to complain about homework.  
   *(social +1; fun +1; {parent} +4; {sibling} +2; modifier rested)*
2. **Make the city yours**: You pick one new neighborhood every Tuesday and walk it until dinner. By October, {town} has a coffee shop that knows your order.  
   *(energy -1; fun +2; intelligence +1; modifier inspired)*
3. **Bury it in work**: Every quiet night ends in the film room. You become the best-prepared rookie on the roster and the loneliest one, and the cleaning crew starts saying goodnight to you.  
   *(social -2; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `promised_to_call_home`, shown as "having promised to call home every week"*  
   **Keep the Sunday call**: You kept the Sunday call all through college, and you keep it now. The first Sunday in {town}, {sibling} answers and talks for an hour.  
   *(social +1; fun +2; {parent} +3; {sibling} +3; modifier rested)*

### PRO_135 The Veteran Minimum
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You're making a third of what you made five years ago, and the rookie next to you has your old car.

You're on the veteran minimum, a third of what you made in your prime. The rookie at the next locker drives your old car; he bought it from the dealer you sold it to.

1. **Laugh about it with him**: Laughing about it together, at the lockers. He offers to sell it back to you at a discount, and you decline, and it becomes your running joke.  
   *(social +2; fun +2; {backup} +3; modifier loose)*
2. **Adjust the budget**: A smaller budget, built at the kitchen table, and nobody in the house misses the things you cut. You're surprised how little you needed.  
   *(resilience +1; intelligence +2; {love_interest} +1; modifier focused)*
3. **Kick for the next deal**: Every practice, like the next deal depends on it, because it does. It's motivating, and on bad days it's heavy.  
   *(energy -2; power +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_305 The Old Lineman's Memory
- **Category:** social  
- **Window:** age 34-37, once  
- **Cast:** Team  
- **Premise:** A lineman you played with for years doesn't remember your name at a reunion.

At a team reunion, a lineman you played beside for years looks at you kindly and doesn't remember your name. His wife squeezes his arm and says it quietly for him.

1. **Sit with him all evening**: The whole evening, beside him, telling him stories he used to tell. Some of them he remembers, and he laughs in the right places.  
   *(social +2; resilience +1; Team +3; modifier drained)*
2. **Talk to his wife**: His wife, in the hallway, tells you everything: the hits, the doctors, the bad days. You leave with her number and a promise to visit.  
   *(intelligence +1; charisma +1; leadership +1; modifier focused)*
3. **Call the union about it**: The union, called the next morning about the retired players' care program. It's a small thing to do, and you do it twice more that month.  
   *(leadership +2; intelligence +1; modifier inspired)*

### PRO_446 The Charity Legacy
- **Category:** community  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You consider making your community work permanent.

You've done community work for years: the camps, the hospital visits, the coat drives. You're starting to think about making it permanent, with a building and a staff.

1. **Start a real foundation**: A foundation, legally and properly, with a board and a director. It's a year of paperwork, and it will outlast your career.  
   *(energy -2; leadership +3; intelligence +1; ambition +1; modifier inspired; sets `started_foundation`)*
2. **Partner with a charity you trust**: A charity you've worked with for years becomes your partner. They do what they do best; you bring your name and your Saturdays.  
   *(intelligence +2; charisma +1; modifier focused)*
3. **Keep it personal**: No building, no staff, no board. You keep showing up yourself on Saturdays, which is what the kids remember anyway.  
   *(social +2; fun +2; modifier loose)*

### PRO_752 Running the Music
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** You've been the locker room DJ for years, and a rookie wants the job.

You've been the locker room DJ for years, and a rookie wants the job. He has a speaker the size of a refrigerator and opinions about your playlists.

1. **Hand it over with a speech**: The aux cord, handed over with a ceremony and a speech about responsibility. The room cheers, and he plays your favorite song first.  
   *(fun +1; leadership +2; {backup} +2; modifier inspired)*
2. **Share the job**: Fridays are his, the rest are yours. It works, and his Fridays are better than you would ever admit out loud.  
   *(social +2; fun +2; Team +2; modifier loose)*
3. **Make him earn it**: A month of proving himself, playlist by playlist. His is better, and you admit it in front of the whole team meeting.  
   *(resilience +1; ambition +2; 1 SP; modifier dialed_in)*

### PRO_795 The Last Charity Game
- **Category:** community  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You play in the charity game you've hosted for ten years, maybe for the last time.

You play in the charity game you've hosted for years, maybe for the last time: same field, same kids, a sold-out crowd that knows the anniversary.

1. **Kick with every kid**: Every kid in the clinic gets one kick with you, all hundred and twenty of them. It takes three hours, and nobody leaves early.  
   *(energy -3; social +1; leadership +2; charisma +1; followers +2; modifier inspired)*
2. **Hand it to someone else**: The event, handed to a younger player at halftime, with a speech and a handshake. It will outlast you now, which is what you wanted for it.  
   *(leadership +2; intelligence +1; modifier inspired)*
3. **Enjoy it like a fan**: For once, enjoyed from the sideline like a fan. You watch your kids run the concession stand and laugh all afternoon.  
   *(fun +3; social +1; resilience +1; {love_interest} +1; modifier loose)*

#### Flags this batch sets, and what they open

- `honest_advisor` (from PRO_072) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice); PRO_123 The Card Game (locked choice); PRO_234 The Partner Who Cheats You (locked choice); PRO_371 The Financial Mistake (locked choice)
- `pro_banned_substance` (from PRO_259) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_165 The Search; PRO_268 The Veteran Hearing
- `pro_bar_fight` (from PRO_265) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `started_foundation` (from PRO_446) → PRO_236 Selling the Business; PRO_237 The Foundation at Ten; PRO_700 The Charity Foundation Gala (locked choice); PRO_700 The Charity Foundation Gala (planned locked choice); PRO_828 The Gala in Your Honor (planned locked choice)

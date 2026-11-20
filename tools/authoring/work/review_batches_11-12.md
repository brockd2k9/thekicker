# College batches 11 and 12 (written, not imported)

Dry run: batch 11 8 written, batch 12 16 written, each 0 errors, 0 warnings, 0 lint notes. With batches 8-10 (all 63 remaining drafts together): 63 written, 0 / 0 / 0. Not imported. Note: "what they open" lists readers already in the game data; came_clean_tape and went_home_for_dad are read by the COL_121 locked choices in this batch.


## Batch 11: COL_103 and the seven senior scenes

### COL_103 The Leadership Retreat
- **Category:** team  
- **Window:** year 3, offseason after that season  
- **Cast:** Team, {coach}  
- **Premise:** The team's leaders spend a weekend at a lake planning next season. It's also your only free weekend of the summer.

The team's leaders spend a summer weekend at a lake house planning next season: team rules, goals, who sits where on the bus. It's also your only free weekend of the summer.

1. **Go and speak up**: You go and argue for one thing you care about: no freshman duties that aren't about football. It's in the rulebook by Sunday.  
   *(energy -2; social +2; leadership +2; Team +3; {coach} +2; modifier inspired)*
2. **Go and mostly listen**: You go, fish with the linemen and listen more than you talk. You come back knowing the team better than you did.  
   *(fun +2; social +2; intelligence +1; Team +2; modifier loose)*
3. **Keep the weekend for yourself**: You skip it and spend the weekend doing nothing at all. You're rested, and you hear about the new rules secondhand.  
   *(energy +4; fun +3; leadership -1; 1 SP; {coach} -1; modifier rested)*
4. 🔒 *locked: needs `accepted_team_leadership`, shown as "having led a team before"*  
   **Run the meeting**: You've led a team before, so when the room stalls on Saturday, you take the whiteboard. The plan that comes out of it has your handwriting all over it.  
   *(energy -3; social +1; leadership +3; Team +3; {coach} +3; modifier confident)*

### COL_113 The Last Rivalry Week
- **Category:** team  
- **Window:** year 4, weeks 8-10  
- **Cast:** Team, {coach}  
- **Premise:** One last rivalry week. The younger players look to the seniors to set the tone.

One last rivalry week. The younger players are watching the seniors to see what this week is supposed to look like, and somebody has already floated a midnight trip to the rival's campus.

1. **Set the tone in the film room**: You call a seniors-only film session and tell the younger players the rivalry gets settled on Saturday, not at midnight. The trip never happens.  
   *(energy -2; leadership +3; Team +3; {coach} +2; modifier focused)*
2. **Plan something legal and loud**: You organize a pep rally banner and a team video instead. It's loud, it's fun, and nobody has to explain anything to anyone.  
   *(fun +3; social +3; energy -1; charisma +1; followers +3; Team +2; modifier pumped_up)*
3. **Go on the midnight trip**: You pile into the car with the younger players. Campus security at the rival school takes down every name, and the first call the next morning goes to {coach}.  
   *(fun +5; social +4; energy -6; leadership -3; **draft -3**; {coach} -6; Team -2; modifier late_night; **conduct bad**; sets **strike** `rivalry_prank`)*
4. 🔒 *locked: needs `rebuilt_reputation`, shown as "having taken the long way back"*  
   **Tell them what the long way back costs**: You tell the younger players about the six a.m. workouts and the community hours, and what one midnight trip cost you. Nobody gets in the car.  
   *(energy -2; social +1; leadership +3; Team +4; modifier inspired)*

### COL_121 The Little Brother's Recruiting
- **Category:** family  
- **Window:** year 4, any week  
- **Cast:** {parent}, {sibling}  
- **Premise:** {sibling} is a high school senior now, and college coaches are calling. He asks you how to handle them.

{sibling} is a high school senior now, and college coaches are calling. He wants to know how to handle them, and he wants to know what you'd do differently.

1. **Tell him to be honest with every coach**: You tell him to be honest early, with every coach, even when it costs him an offer. He writes it down, which you've never seen him do.  
   *(energy -1; leadership +1; intelligence +1; {sibling} +5; modifier focused)*
2. **Make a list of his questions**: You build him a list of questions to ask every coach: who'll be his position coach, what happens if he's hurt, what the players really say. It takes a whole Sunday.  
   *(energy -3; social +1; intelligence +2; {sibling} +6; {parent} +1; modifier focused)*
3. 🔒 *locked: needs `came_clean_tape` or `corrected_recruiting_video`, shown as "having owned up to your own recruiting tape"*  
   **Tell him the truth about your tape**: You tell {sibling} about the clip on your recruiting tape and what owning it taught you. He goes back and checks his own highlight video that night.  
   *(energy -1; social -1; leadership +2; {sibling} +7; modifier inspired)*
4. 🔒 *locked: needs `went_home_for_dad`, shown as "having gone home when {parent} was in the hospital"*  
   **Tell him what to ask about family**: You remind {sibling} of the night you flew home to the hospital, and tell him to ask every coach what happens when family needs you. Two coaches give answers he likes.  
   *(energy -1; charisma +1; intelligence +1; {sibling} +6; {parent} +3; modifier inspired)*

### COL_123 The Last Injury Scare
- **Category:** health  
- **Window:** year 4, any week  
- **Cast:** {coach}  
- **Premise:** Your knee buckles on a routine practice kick three weeks before scouts arrive.

Your knee buckles on a routine practice kick three weeks before the scouts' workout. It holds, mostly. The trainer wants an MRI.

1. **Get the MRI today**: You get the scan the same afternoon. It's a sprain, not a tear, and you have a three-week plan before you leave the building.  
   *(health +5; fun -1; intelligence +1; {coach} +2; modifier rested)*
2. **Wait until after the workout**: You ask to put off the scan until after the scouts come. You kick with a brace and a careful plant, and you don't sleep well.  
   *(health -2; ambition +2; 2 SP; modifier stressed)*
3. **Say nothing and keep kicking**: You tell the trainer it was nothing and keep your full load. It holds for two weeks, and then it doesn't.  
   *(health -5; energy +1; ambition +2; intelligence -1; 3 SP; {coach} -3; modifier sore)*
4. 🔒 *locked: needs `reported_kicking_pain`, shown as "having reported kicking pain early before"*  
   **Do what worked in high school**: You reported pain early once and it saved your season. You walk into the training room before practice ends and ask for the scan yourself.  
   *(health +6; fun -2; intelligence +1; leadership +1; {coach} +3; modifier rested)*

### COL_124 Final Exams, Final Season
- **Category:** school  
- **Window:** year 4, weeks 7-10  
- **Cast:** {teacher}  
- **Premise:** Your last finals land in the same week as your last regular-season game.

Your last finals land in the same week as your last regular-season game. {teacher} has the exam schedule on the screen, and two of them are the morning after team travel.

1. **Study on the bus and the plane**: You turn every trip into a study session and get four hours of sleep a night. You pass everything, and you're exhausted on Saturday.  
   *(energy -5; intelligence +2; **grades +0.15**; {teacher} +3; modifier drained)*
2. **Ask {teacher} to move two exams**: You ask {teacher} to arrange makeup times with your professors. It takes three emails each, and you get a normal week.  
   *(energy -1; intelligence +1; charisma +1; **grades +0.1**; {teacher} +2; modifier focused)*
3. **Let the grades slide this once**: You do the minimum on two exams and focus on the last game. It's your senior year, and you don't regret it until the transcript arrives.  
   *(energy +2; fun +1; ambition +2; 2 SP; **grades -0.1**; modifier dialed_in)*
4. 🔒 *locked: needs `accepted_sanction`, shown as "having sat through an integrity hearing"*  
   **Take every exam by the book**: You've been in front of an integrity panel once. You take every exam early, in the testing center, with nothing on the desk, and {teacher} notices without saying anything.  
   *(energy -3; fun -1; intelligence +2; leadership +1; **grades +0.1**; {teacher} +5; modifier focused)*

### COL_126 The Exclusive Deal
- **Category:** money  
- **Window:** year 4, any week  
- **Cast:** (no cast)  
- **Premise:** A national brand wants an exclusive NIL deal for your senior year. It pays more than everything else combined, and it ends all your local deals.

A national brand wants an exclusive NIL deal for your senior year. It pays more than everything else combined, it ends all your local deals, and the contract has a morality clause on page nine.

1. **Sign the exclusive deal**: You sign. The money is life-changing, and the local sandwich shop that sponsored you first takes your photo off the wall.  
   *(fun +2; ambition +2; followers +6; modifier spotlight; brand deal "the national brand" (sp 2, 1 season))*
2. **Keep the local deals**: You turn it down and keep the deals with the people who backed you first. The sandwich shop names a sandwich after you.  
   *(social +2; fun +1; charisma +1; leadership +1; followers +2; modifier inspired)*
3. **Ask your agent to negotiate**: You ask to keep one local deal as a condition. The brand says yes, for a little less money, and everyone gets something.  
   *(energy -1; social +1; intelligence +2; ambition +1; followers +4; modifier focused; brand deal "the national brand" (sp 1.5, 1 season))*
4. 🔒 *locked: needs `character_concerns` or `last_chance`, shown as "having a record the brand will find"*  
   **Tell them about your record first**: You tell the brand about your college record before they find it themselves. They rewrite the morality clause and sign you anyway, for less, because you told them.  
   *(energy -1; social -1; leadership +2; followers +4; modifier confident; brand deal "the national brand" (sp 1, 1 season))*

### COL_127 Giving Back
- **Category:** community  
- **Window:** year 4, any week  
- **Cast:** {parent}  
- **Premise:** Your hometown asks if you'd run a free kicking camp for kids this summer. It would cost you a week and some of your NIL money.

Your hometown asks if you'd run a free kicking camp for kids this summer. It would cost you a week of draft training and some of your NIL money for the equipment.

1. **Run it, and pay for it**: You run the camp and buy every kid a ball with your name on it. Eighty kids show up, and {parent} works the check-in table.  
   *(energy -3; social +3; fun +2; leadership +2; followers +3; {parent} +3; modifier inspired)*
2. **Run it, and find a sponsor**: You call the local businesses that backed you in high school. Two of them pay for everything, and you run the camp for free.  
   *(energy -2; social +2; charisma +1; intelligence +1; followers +2; {parent} +1; modifier focused)*
3. **Not this summer**: You say it'll have to wait until after the draft. They understand, and the camp happens without you.  
   *(energy +2; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `community_volunteer` or `rebuilt_reputation`, shown as "having put in community hours before"*  
   **Bring in the people you volunteered with**: You call the people you did community work with, and they turn the camp into a weekend: a clinic, a cookout and a reading tent. It's the best week of your summer.  
   *(energy -4; social +3; fun +1; leadership +3; followers +4; {parent} +2; modifier inspired)*

### COL_130 The Old Posts
- **Category:** media  
- **Window:** year 4, any week  
- **Cast:** {coach}  
- **Premise:** Someone digs up your freshman-year posts during draft season and they're spreading.

Someone digs up posts from your first year of college, right in the middle of draft season. They're mean, they're stupid, and they're spreading.

1. **Post a short, real apology**: You write three sentences yourself: what you said, why it was wrong and who you are now. It's quoted everywhere, and the scouts mostly move on.  
   *(energy -1; leadership +2; **draft +1**; followers -2; modifier stressed)*
2. **Let the media staff handle it**: You hand it to the school's media staff, who write a careful statement for you. It's polished, and nobody believes you wrote it.  
   *(energy +1; intelligence +1; followers -3; modifier focused)*
3. **Say they're taken out of context**: You post that the screenshots are fake and out of context. Someone posts the originals an hour later, with the dates.  
   *(fun +1; ambition +2; leadership -2; **draft -3**; followers -5; {coach} -4; modifier stressed; **conduct bad**; sets **strike** `online_incident`)*
4. 🔒 *locked: needs `handled_old_post` or `last_chance` or `online_incident`, shown as "having been through an online mess before"*  
   **Go to {coach} before anyone asks**: You've been here before, so you walk into {coach}'s office with the screenshots before the coach sees them. You write the apology together.  
   *(energy -2; leadership +2; intelligence +1; **draft +1**; followers -1; {coach} +3; modifier focused)*

#### Flags this batch sets, and what they open

- `online_incident` (from COL_130) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning
- `rivalry_prank` (from COL_113) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning

## Batch 12: the sixteen year-neutral scenes

### COL_134 The Roommate's Secret
- **Category:** health  
- **Window:** years 1-4, any week  
- **Cast:** (no cast)  
- **Premise:** Your roommate admits he hasn't left the room in days and asks you not to tell anyone.

Your roommate admits he hasn't left the room in four days except for the bathroom. He's skipped every class and asks you, please, not to tell anyone.

1. **Walk him to the counseling center**: You tell him you won't make a scene, and you won't leave him alone with it either. You walk over together the next morning, and you wait outside.  
   *(energy -2; social +1; leadership +2; charisma +1; modifier drained)*
2. **Keep his secret, and keep checking**: You promise not to tell and start bringing him dinner every night. He eats some of it. You worry about him through every practice, and you're the one person he still talks to.  
   *(energy -3; fun -2; social +2; charisma +2; modifier distracted)*
3. **Tell your resident advisor**: You tell the RA that night. Your roommate is furious for a week, then shows up to a class, then another.  
   *(social -2; leadership +1; intelligence +1; modifier stressed)*

### COL_135 Sunday Night Blues
- **Category:** family  
- **Window:** years 1-4, any week  
- **Cast:** {parent}, {sibling}  
- **Premise:** Every Sunday night the dorm goes quiet and you miss home most.

Every Sunday night the building goes quiet, and that's when you miss home the most: the noise of the kitchen, {parent} watching the late game with the volume too loud.

1. **Call {parent}**: You call just to hear the kitchen noise in the background. You talk for twenty minutes about nothing, and it's exactly enough.  
   *(social +1; fun +1; {parent} +4; modifier rested)*
2. **Start a Sunday dinner on your floor**: You cook a big pot of pasta and knock on doors. Five people show up the first week; twelve by the end of the month.  
   *(energy -2; social +3; fun +2; leadership +1; modifier loose)*
3. **Fill it with work**: You make Sunday night your film and homework night. The quiet stops bothering you, mostly because you stop noticing it.  
   *(fun -1; intelligence +1; ambition +1; 1 SP; **grades +0.05**; modifier focused)*
4. 🔒 *locked: needs `promised_to_call_home`, shown as "having promised to call home every week"*  
   **Keep the promise you made**: You promised {parent} you'd call every week, and you have. Tonight he puts {sibling} on too, and the three of you talk until the phone dies.  
   *(social +1; fun +2; energy -1; {parent} +5; {sibling} +2; modifier inspired)*

### COL_136 The Group Chat Screenshot
- **Category:** media  
- **Window:** years 1-4, any week  
- **Cast:** Team, {coach}  
- **Premise:** A screenshot from the team group chat leaks, and a joke you laughed at is in it.

A screenshot from the team group chat leaks: a cruel joke about a classmate, and right under it, your laughing emoji. It's all over campus by lunch.

1. **Apologize to the classmate yourself**: You find the classmate and apologize in person, without excuses. It's the most uncomfortable five minutes of your year, and they accept it.  
   *(energy -1; social -1; leadership +2; charisma +1; {coach} +1; modifier drained)*
2. **Call it out in the chat**: You tell the group chat the joke was out of line, including your own reaction to it. A few teammates agree, and a few go quiet.  
   *(social -2; leadership +2; intelligence +1; Team -1; {coach} +1; modifier stressed)*
3. **Wait for it to blow over**: You say nothing and wait. It does blow over, in about two weeks, and the classmate never looks at you the same way.  
   *(energy +1; fun +1; intelligence -1; Team +1; modifier distracted)*
4. 🔒 *locked: needs `owned_old_group_chat`, shown as "having owned a group chat mistake before"*  
   **Do what you learned last time**: You've been here before. You apologize to the classmate, then ask {coach} to talk to the team about the chat. The coach does, and it changes.  
   *(energy -2; social -1; leadership +3; {coach} +3; modifier confident)*

### COL_137 The Parking Ticket Pile
- **Category:** money  
- **Window:** years 1-4, any week  
- **Cast:** {parent}  
- **Premise:** Seven unpaid parking tickets and a hold on your registration.

Seven unpaid parking tickets, and now there's a hold on your registration. Class sign-ups close on Friday.

1. **Pay them all**: You pay every one. It's most of your spending money for the month, the hold is gone in an hour, and you're back to training by seven.  
   *(fun -2; energy +2; ambition +1; modifier focused)*
2. **Appeal the ones that were wrong**: You spend an evening on appeals and win three. You pay the rest and learn where the hidden signs are.  
   *(energy -2; intelligence +2; modifier focused)*
3. **Ask {parent} to cover it**: You call {parent}. He pays and then asks, in a very calm voice, how there were seven of them. You get your evening back.  
   *(energy +3; fun +1; {parent} -2; modifier stressed)*

### COL_138 The Professor Who Doubts Athletes
- **Category:** school  
- **Window:** years 1-4, any week  
- **Cast:** {teacher}  
- **Premise:** A professor says, in front of the class, that athletes don't belong in her seminar.

A professor says in front of the whole class that athletes don't belong in her seminar, then looks straight at you.

1. **Prove her wrong on paper**: You say nothing and turn in the best paper of your life. She writes 'I stand corrected' in the margin.  
   *(energy -3; intelligence +2; ambition +1; **grades +0.1**; modifier focused)*
2. **Talk to her after class**: You go to office hours and ask what she's seen that made her say it. It's a real conversation, and by the end of it, she asks about your schedule.  
   *(energy -1; charisma +1; intelligence +1; **grades +0.05**; {teacher} +1; modifier focused)*
3. **Tell {teacher} and switch sections**: You tell {teacher} what happened and move to another section. It's a fresh start, and she never learns she was wrong.  
   *(energy +1; leadership +1; {teacher} +3; modifier rested)*

### COL_139 The Bus Argument
- **Category:** team  
- **Window:** years 1-4, any week  
- **Cast:** Team, {coach}  
- **Premise:** An argument on the team bus is turning personal, and two teammates are about to swing.

An argument on the team bus is turning personal, and two teammates are about to swing at each other in the aisle.

1. **Get between them**: You stand up and get between them before the first punch. You take an elbow to the ribs, and it stops there.  
   *(health -2; energy -1; leadership +3; Team +3; {coach} +2; modifier sore)*
2. **Get the coaches**: You walk to the front and get the coaches. It's handled in a minute, and both players sit apart for the rest of the trip.  
   *(intelligence +1; {coach} +2; modifier focused)*
3. **Stay out of it**: You put your headphones on. The coaches break it up, and someone asks later why nobody back there did anything.  
   *(energy +1; leadership -1; 1 SP; Team -1; modifier rested)*

### COL_140 The Fan Who Goes Too Far
- **Category:** media  
- **Window:** years 1-4, any week  
- **Cast:** {coach}  
- **Premise:** A fan's messages have gone from friendly to strange. Now he says he knows where you live.

A fan's messages have gone from friendly to strange. Now he says he knows which building you live in, and he sends a photo of the front door.

1. **Report it today**: You take screenshots and go straight to campus police and the team's security staff. They handle it, and your building gets a new key card system.  
   *(energy -1; intelligence +2; {coach} +2; modifier stressed)*
2. **Block him and move on**: You block the account and try to forget it. You check the street outside your window more than you'd like to admit.  
   *(fun -1; resilience +1; ambition +1; modifier distracted)*
3. **Message him back to back off**: You tell him to stay away. He takes it as an invitation and sends more, and now you report it anyway, a week later.  
   *(fun +1; ambition +1; followers -1; modifier stressed)*

### COL_141 Pickup Basketball
- **Category:** social  
- **Window:** years 1-4, any week  
- **Cast:** Team  
- **Premise:** Teammates want you in a pickup basketball game. One rolled ankle could cost you a month.

Teammates want you in a pickup basketball game on your day off. You haven't played in a year, and one rolled ankle could cost you a month.

1. **Play, carefully**: You play half-speed, take the open jumpers and stay out of the paint. Nobody gets hurt, and you're on the group chat's highlight reel.  
   *(fun +4; social +3; health -1; Team +2; modifier loose)*
2. **Keep score instead**: You run the scoreboard and the trash talk. It's almost as fun, and your ankles thank you.  
   *(fun +2; social +2; charisma +1; Team +1; modifier rested)*
3. **Pass and stretch instead**: You say no and spend the afternoon on mobility work. Your hips feel great, and the stories from the game are very loud at dinner.  
   *(health +2; social -1; ambition +1; 1 SP; modifier fresh_legs)*

### COL_142 The Wrong Crowd
- **Category:** social  
- **Window:** years 1-4, any week  
- **Cast:** {coach}  
- **Premise:** A group of non-team friends parties every night, and they've started inviting you along.

A group of friends from outside the team goes out every night, and they've started inviting you along: never pushy, always fun, every single night.

1. **Go out with them every time**: You become a regular. Your grades slide, you're late twice, and {coach} starts hearing your name from people who aren't on the team.  
   *(fun +5; social +4; energy -6; leadership -2; **grades -0.1**; **draft -2**; {coach} -5; modifier late_night; **conduct bad**; sets **strike** `ran_with_wrong_crowd`)*
2. **See them on weekends only**: You tell them weekdays are off-limits and stick to it. They tease you about it, and they still invite you on Saturdays.  
   *(fun +2; social +2; intelligence +1; modifier rested)*
3. **Say no and mean it**: You say thanks, but it's not your life right now. They stop asking after a week, and your evenings get quiet again.  
   *(social -2; energy +2; ambition +2; 1 SP; modifier focused)*

### COL_143 The Borrowed Car
- **Category:** social  
- **Window:** years 1-4, any week  
- **Cast:** Team  
- **Premise:** A teammate wants to borrow your car for the night and won't say where he's going.

A teammate wants to borrow your car for the night. He won't say where he's going, and he's already holding out his hand for the keys.

1. **Say no**: You say no, nicely, and offer to drive him wherever it is tomorrow. He's annoyed and finds another ride.  
   *(social -1; intelligence +1; leadership +1; modifier focused)*
2. **Drive him yourself**: You say you'll drive. It's a ride to his girlfriend's place across town, and you're back in an hour.  
   *(energy -2; social +2; charisma +1; Team +2; modifier tired)*
3. **Hand him the keys**: You toss him the keys. The car comes back at 4 a.m. with a parking ticket and a dent, and you never find out where it was.  
   *(social +1; fun +1; intelligence -1; Team +1; modifier stressed)*

### COL_144 The Camp You Run
- **Category:** money  
- **Window:** years 1-4, offseason after that season  
- **Cast:** {coach}  
- **Premise:** Parents offer you cash to run private kicking lessons for their kids this summer. Compliance has rules about that.

Parents back home offer you cash to run private kicking lessons for their kids this summer. Compliance has rules about that, and the money is good.

1. **Take the cash and skip the paperwork**: You run the lessons and take cash. In the fall, one parent posts a thank-you online, and compliance asks to see your paperwork.  
   *(fun +3; ambition +2; leadership -1; **draft -2**; {coach} -5; modifier stressed; **conduct bad**; sets **strike** `cash_camp`)*
2. **Run it through compliance**: You fill out the forms and run the lessons the legal way. It takes a week to get approved and pays a little less.  
   *(energy -2; intelligence +1; leadership +1; {coach} +2; modifier focused; **conduct good**)*
3. **Teach for free**: You run a few free lessons at the local field instead. No forms, no money, a lot of happy kids.  
   *(energy -1; social +2; charisma +1; followers +2; modifier inspired)*

### COL_145 The Aid Office Error
- **Category:** money  
- **Window:** years 1-4, any week  
- **Cast:** (no cast)  
- **Premise:** The financial aid office deposits twice what you're owed.

The financial aid office deposits twice what you're owed this semester. Nobody has noticed yet.

1. **Report it right away**: You call the aid office the same day. They thank you, fix it, and you go back to being exactly as broke as before.  
   *(leadership +1; intelligence +1; modifier focused; **conduct good**)*
2. **Leave it until they notice**: You don't touch it and don't report it. Two months later they notice, take it back, and charge a late fee for your trouble.  
   *(energy +1; fun +1; intelligence -1; modifier distracted)*
3. **Spend some of it**: You spend part of it on new cleats and a nice dinner. When the aid office asks for it back, you don't have it, and the repayment plan runs all semester.  
   *(fun +3; ambition +1; intelligence -2; **grades -0.05**; modifier stressed)*

### COL_146 The Extension
- **Category:** school  
- **Window:** years 1-4, any week  
- **Cast:** {coach}, {teacher}  
- **Premise:** Team travel lands on a paper deadline. A teammate says the trick is to claim a family emergency.

Team travel lands right on a paper deadline. A teammate says the trick is to email the professor about a family emergency; nobody ever checks.

1. **Claim the family emergency**: You send the email. The professor gives you a week and sends a kind note about your family. Then {teacher} gets a call about it, and the story doesn't hold.  
   *(energy +2; fun +1; intelligence -1; leadership -1; **grades -0.05**; **draft -1**; {teacher} -4; {coach} -2; modifier stressed; **conduct bad**; sets **strike** `academic_shortcut`)*
2. **Ask for an extension honestly**: You email the professor about the travel and ask for two days. You get them, and the paper is better for it.  
   *(energy -1; charisma +1; intelligence +1; **grades +0.05**; {teacher} +2; modifier focused)*
3. **Finish it early**: You write it in three late nights before the trip. It's not your best work, and it's on time, with the whole trip free for film.  
   *(energy -4; ambition +1; intelligence +1; 1 SP; **grades +0.05**; modifier tired)*

### COL_147 The Coach From Home
- **Category:** family  
- **Window:** years 1-4, any week  
- **Cast:** {coach}  
- **Premise:** Your high school coach visits campus and wants to watch you practice.

Your old high school coach is in town and stops by to watch you practice. It's the first time in years you've kicked in front of the person who taught you most of it.

1. **Ask for notes**: After practice you ask your old coach to be honest about your form. The notes are short and sharp, and two of them stick.  
   *(energy -1; intelligence +1; 2 SP; modifier focused)*
2. **Introduce them to {coach}**: You introduce your old coach to {coach}, and the two of them talk kicking for an hour while you stand there grinning.  
   *(social +2; charisma +1; {coach} +3; modifier inspired)*
3. **Take them to dinner**: You skip the film session to take your old coach to dinner. You talk about everything except kicking, and it's the best night of your month.  
   *(fun +3; social +2; energy +1; {coach} -1; modifier loose)*
4. 🔒 *locked: needs `earned_coach_confidence`, shown as "having earned your high school coach's confidence"*  
   **Say thank you properly**: You tell your old coach, out loud, what that trust meant to you. They don't say much back. They don't have to.  
   *(social +1; energy -1; charisma +1; leadership +1; modifier inspired)*

### COL_148 The Hospital Visit
- **Category:** community  
- **Window:** years 1-4, any week  
- **Cast:** Team  
- **Premise:** The team visits a children's hospital. Some players are there for the cameras; one kid asks you to stay longer.

The team visits a children's hospital. Some players are there for the cameras, and when the cameras leave, a kid in a wheelchair asks you to stay and play a video game.

1. **Stay and play**: You stay two extra hours and lose every game. The kid's mother writes the team a letter, and you keep a copy.  
   *(energy -2; social +2; fun +2; charisma +1; Team +1; modifier inspired)*
2. **Promise to come back**: You have to leave with the team, so you promise to come back next week, and you do. Then the week after that, and two teammates start coming with you.  
   *(energy -3; social +1; leadership +2; Team +2; modifier inspired)*
3. **Leave with the bus**: You say a warm goodbye and get on the bus with everyone else. You think about that kid for the whole ride home.  
   *(energy +1; ambition +1; 1 SP; modifier distracted)*

### COL_149 The Weekend Off
- **Category:** social  
- **Window:** years 1-4, any week  
- **Cast:** (no cast)  
- **Premise:** Friends invite you away for a weekend off, your first in months.

Friends from home invite you to a lake cabin for a weekend off, the first one you've had in months. It's quiet, with no plan except fishing and sleep.

1. **Go and actually rest**: You go, sleep ten hours a night and leave your phone in the car. You come back feeling like a person again.  
   *(energy +5; fun +3; health +2; ambition -1; modifier rested)*
2. **Go, and bring the kicking net**: You go and set up a net behind the cabin. It's half a vacation, and your friends think it's hilarious.  
   *(energy +1; fun +2; social +1; ambition +1; 1 SP; modifier loose)*
3. **Stay and train**: You skip it and spend the weekend at the facility. It's productive, and the photos from the lake look perfect.  
   *(fun -2; social -2; ambition +2; 3 SP; modifier dialed_in)*

#### Flags this batch sets, and what they open

- `academic_shortcut` (from COL_146) → COL_017 The Pattern; COL_036 The Coach's Office; COL_062 The Advisor's Warning; COL_071 The Second Strike; COL_084 The Integrity Hearing; COL_086 The Final Warning
- `cash_camp` (from COL_144) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning
- `ran_with_wrong_crowd` (from COL_142) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning; pro_old_crowd The Old Crowd

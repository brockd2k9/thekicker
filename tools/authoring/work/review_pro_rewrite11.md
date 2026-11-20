# PRO rewrite pass 11: era-3 scenes 79-117

The next 39 era-3 scenes: maintenance and old injuries, the room's veterans, community and family, the awards and fan scenes, loyalty against the paycheck, broke at thirty-three, the comeback year. PRO_219 and PRO_220 (written in batch 38) were already at the standard and are unchanged.

Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 37 of 39.** Unchanged: PRO_219, PRO_220.

**Standing costs removed** (routine choices): PRO_763 "Do the favor" (-2).

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_728 The Massage Therapist
*health; premise 28 words*

> The team's massage therapist has worked on your legs for years and can tell how your week went by touching your hamstring. They want you to change something.

1. **Listen to them** (21 words)
   You listen to them about everything: sleep, stretching, the way you sit on the plane. Your legs feel younger by midseason.
   <sub>health +2; intelligence +2; rel coach +2; mods focused</sub>

2. **Thank them** (25 words)
   You thank them publicly at the end of the season, in front of the whole team. They pretend to be annoyed and keep the clip.
   <sub>social +2; charisma +1; rel team +2; followers +1; mods loose</sub>

3. **Book extra sessions** (22 words)
   You book extra sessions and sleep better than you have in years. Your bank account notices, and your legs are worth it.
   <sub>energy +3; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The team's massage therapist has worked on your legs for years and can tell how your week went by touching your hamstring. They want you to change something.

1. **Listen to them**: You listen to them about everything: sleep, stretching, the way you sit on the plane. Your legs feel younger by midseason.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Thank them**: You thank them publicly at the end of the season, in front of the whole team. They pretend to be annoyed and keep the clip.
   <sub>social +2; charisma +1; rel team +3; followers +1; mods loose</sub>

3. **Book extra sessions**: You book extra sessions and sleep better than you have in years. Your bank account notices, and your legs are worth it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 2. PRO_729 The Old Injury Flares
*health; premise 33 words*

> An old hip injury flares up on a road trip, in a hotel bed at two in the morning, two days before a game. You can feel it every time you roll over.

1. **Tell the trainers right away** (24 words)
   The trainers, told at breakfast, before it gets worse. They catch it early, and you're fine by Sunday, with a new stretch for life.
   <sub>health +3; intelligence +1; rel coach +1; mods focused</sub>

2. **Work through it quietly** (23 words)
   Through it, quietly, and the trainers find out later. The hip holds, and it reminds you of itself every morning for a month.
   <sub>health -2; toughness +1; ambition +2; skill_points +2; mods sore</sub>

3. **Rest it all week** (22 words)
   No extra kicking all week, ice and rest. It calms down by Saturday, and you miss the work more than you expected.
   <sub>energy +3; health +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> An old injury flares up during a road trip.

1. **Tell the trainers**: You tell the trainers right away. They catch it before it gets worse.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Work through it**: You work through it and tell them later.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Rest it**: You rest it all week and miss the extra work. It calms down.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 3. PRO_730 The Long Practice Week
*training; premise 30 words*

> A long week of practice in the August heat, three sessions a day, and your legs feel every one of your years. The rookies are bouncing; you're icing between meetings.

1. **Pace yourself** (22 words)
   Your legs, saved for the kicks that matter. You skip the extra sprints, and you're fresh on Sunday while the rookies limp.
   <sub>energy +2; health +1; intelligence +1; mods rested</sub>

2. **Push through every rep** (22 words)
   Every rep, every sprint, every session, in the heat. Your legs feel it all weekend, and the rookies stop calling you old.
   <sub>energy -3; toughness +1; ambition +2; skill_points +2; mods heavy_legs</sub>

3. **Keep the unit laughing** (21 words)
   Jokes, bad songs and a running bit about the heat. The specialists laugh through the whole week, and it feels shorter.
   <sub>social +2; fun +2; rel holder +2; rel team +1; mods loose</sub>

<details><summary>Before</summary>

> A long week of practice in the heat, and your legs feel every year.

1. **Pace yourself**: You pace yourself and save your legs for Sunday.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Push through**: You push through every rep. Your legs feel it all weekend.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Keep the unit laughing**: You keep the unit laughing through the heat.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 4. PRO_731 The Teammate's Retirement Speech
*team; premise 25 words*

> A teammate's retirement speech, delivered in the locker room with a cracking voice, mentions you by name: 'the kicker who never once let me down'.

1. **Hug him afterward** (22 words)
   A long hug afterward, by his empty locker. Neither of you says much, and you both have to look at the ceiling.
   <sub>social +2; resilience +1; rel team +4; mods inspired</sub>

2. **Say something back at dinner** (24 words)
   A few words back, at the team dinner that night, about what he meant to the room. He can't look up from his plate.
   <sub>leadership +2; charisma +1; rel team +2; mods inspired</sub>

3. **Keep it with you** (22 words)
   The words, kept just for yourself. Some nights before big games you think about them, and they steady your hands every time.
   <sub>energy +1; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> A teammate's retirement speech mentions you by name.

1. **Hug him afterward**: You hug him afterward. Neither of you says much.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Say something back**: You say something back at the team dinner.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep it with you**: You keep it with you. Some nights you think about it before you sleep.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 5. PRO_732 The Team Historian
*media; premise 28 words*

> The club's historian wants an hour with you for the team archive. She has a recorder, a list of questions and a photo of you as a rookie.

1. **Tell every story** (21 words)
   You tell every story you can remember, including some you probably shouldn't. She laughs until she has to stop the recorder.
   <sub>social +2; fun +1; rel team +2; mods loose</sub>

2. **Tell the true ones** (20 words)
   You tell the true ones, carefully, including the hard years. She says it's the most honest interview in the archive.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Keep it short** (23 words)
   A short interview, and the archive gets a few good lines. Later you realize you didn't mention the people who got you there.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The club's historian wants an hour with you for the team archive. She has a recorder, a list of questions and a photo of you as a rookie.

1. **Tell every story**: You tell every story you can remember, including some you probably shouldn't. She laughs until she has to stop the recorder.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Tell the true ones**: You tell the true ones, carefully, including the hard years. She says it's the most honest interview in the archive.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Keep it short**: You keep it short. The archive gets a few good lines, and you realize later you didn't mention the people who got you there.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 6. PRO_734 The Team's Anniversary
*community; premise 28 words*

> The club celebrates its fiftieth anniversary with a gala, a banner of club legends across the stadium, and your face is on it, between two Hall of Famers.

1. **Meet the old players** (27 words)
   Players from every era of the club, met one by one at the gala. One of them held for your childhood hero, and he tells you everything.
   <sub>social +2; fun +1; intelligence +1; rel team +1; mods loose</sub>

2. **Speak at the event** (24 words)
   A short speech, on stage, about what the club has meant to you. The old players clap the loudest, and one of them cries.
   <sub>energy -1; leadership +2; charisma +1; followers +2; mods inspired</sub>

3. **Enjoy it with your family** (22 words)
   Your family, in the stands, under the banner, quietly. {parent} takes forty photos of your face on the banner, all slightly blurry.
   <sub>energy +1; fun +2; rel parent +3; mods rested</sub>

<details><summary>Before</summary>

> The club celebrates an anniversary, and you're one of the faces on the banner.

1. **Meet the old players**: You meet players from every era. One of them held for your hero.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Speak at the event**: You speak at the event. It's short, and the old players clap the loudest.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Enjoy it**: You enjoy it quietly with your family in the stands.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 7. PRO_735 The Veteran's Union Meeting
*team; premise 28 words*

> The veterans meet about the next labor agreement in a hotel conference room, and it's tense: pensions, health care, the length of the season. Somebody throws a chair.

1. **Speak for the specialists** (20 words)
   The specialists, spoken for, because nobody else was going to. The union adds two lines about kickers to the proposal.
   <sub>energy -1; leadership +3; rel team +2; mods inspired</sub>

2. **Read every clause** (21 words)
   Every clause of the proposal, read overnight. You find the one about injury guarantees that matters most, and you flag it.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Vote with the room** (21 words)
   Your vote goes with the room, and your opinions stay for the bus. The meeting ends, and nobody throws anything else.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Veterans meet about the next labor agreement, and it's tense.

1. **Speak for the specialists**: You speak for the specialists. Nobody else was going to.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Read every clause**: You read every clause and find the one that matters for kickers.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Vote with the room**: You vote with the room and keep your opinions for the bus.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 8. PRO_736 The Teammate in Rehab
*team; premise 31 words*

> A teammate goes into a long rehab for a knee injury that may end his career. He's thirty-four and has three kids, and he stops answering texts after the second surgery.

1. **Visit him every week** (23 words)
   Every week, at his house, whether he wants it or not. Some weeks you just watch television together, and some weeks he talks.
   <sub>social +2; energy -1; rel team +4; mods drained</sub>

2. **Keep his locker as it was** (21 words)
   His locker, kept exactly as it was, with his name on it, at your insistence. The room remembers him every day.
   <sub>resilience +1; leadership +2; rel team +2; mods inspired</sub>

3. **Send a message** (21 words)
   A warm, short message every few weeks. He replies with a thumbs-up months later, and you're glad you kept sending them.
   <sub>energy +2; fun +1; resilience +1; rel team +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate goes into rehab for an injury that may end his career.

1. **Visit him**: You visit him every week. Some weeks you just watch television together.
   <sub>social +2; charisma +1; rel team +5; mods loose</sub>

2. **Keep him in the room**: You keep his locker as it was and make sure the room remembers him.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Send a message**: You send a message. He replies with a thumbs up, weeks later.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 9. PRO_737 The Kicking Camp Partner
*training; premise 28 words*

> A college coach asks you to co-host a kicking camp in July: two hundred high school kickers, three days, a university field and your name on the poster.

1. **Co-host it** (21 words)
   Three days, co-hosted, from dawn to dusk. It's a great week, and five of the kids end up with college scholarships.
   <sub>energy -3; leadership +3; charisma +1; followers +1; mods inspired</sub>

2. **Bring {holder} along** (23 words)
   {holder}, recruited to run the holding station. The campers love the two of you together, and {holder} is better with teenagers than you.
   <sub>social +2; fun +2; rel holder +3; mods loose</sub>

3. **Pass this year** (22 words)
   Not this year, you tell the coach. He says the offer stands, and you spend July at the lake with your family.
   <sub>energy +3; fun +1; health +1; mods rested</sub>

<details><summary>Before</summary>

> A college coach asks you to co-host a kicking camp.

1. **Co-host it**: You co-host it. It's a great week.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring your holder**: You bring your holder along. The campers love the two of you together.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

3. **Pass**: You pass this year. The coach says the offer stands.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 10. PRO_743 The Weekend Away
*social; premise 29 words*

> A rare weekend away from the city, at a cabin with no neighbors and one bar of signal. Your phone won't stop buzzing anyway: agents, reporters, a teammate's crisis.

1. **Turn the phone off** (20 words)
   Off, in a drawer, for two days. Nothing burns down, and you come back calmer than you've been since August.
   <sub>energy +3; health +1; mods rested</sub>

2. **Check it once a day** (20 words)
   Once a day, after dinner, for twenty minutes. You answer what matters and let the rest wait, and it works.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Answer the teammate** (21 words)
   The teammate's crisis gets an hour on the porch, on the phone. You lose an afternoon, and he's grateful for years.
   <sub>social +2; energy -1; leadership +1; rel team +3; mods drained</sub>

<details><summary>Before</summary>

> A rare weekend away from the city, and your phone won't stop.

1. **Turn it off**: You turn it off. Nothing burns down.
   <sub>energy +2; fun +1; mods rested</sub>

2. **Check once a day**: You check once a day after dinner and answer what matters.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Answer the important ones**: You answer the important ones and lose an afternoon to them.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 11. PRO_744 The Veteran Leadership Award
*team; premise 27 words*

> The club names you its veteran leadership honoree. The award comes with a dinner, a speech, and a young team that will be listening to every word.

1. **Accept and speak** (26 words)
   You accept and talk to the young players about the year you nearly lost your job. The room is silent, and three rookies find you afterward.
   <sub>energy -1; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Share it** (21 words)
   You bring the specialists up with you and make them stand there while you thank them. {holder} is mortified and delighted.
   <sub>social +2; fun +1; rel holder +3; mods loose</sub>

3. **Accept quietly** (22 words)
   You accept quietly and thank the equipment staff in a handwritten note. They pin it to the wall of the equipment room.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The club names you its veteran leadership honoree. The award comes with a dinner, a speech, and a young team that will be listening to every word.

1. **Accept and speak**: You accept and talk to the young players about the year you nearly lost your job. The room is silent, and three rookies find you afterward.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Share it**: You bring the specialists up with you and make them stand there while you thank them. {holder} is mortified and delighted.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Accept quietly**: You accept quietly and thank the equipment staff in a handwritten note. They pin it to the wall of the equipment room.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_745 The Media Feud
*media; premise 31 words*

> A columnist has a feud with you, nobody knows why, and every column is about you: your age, your contract, your 'declining leg'. {parent} has started writing letters to the editor.

1. **Ignore every column** (23 words)
   Not one column read, not one word said. He runs out of things to say by December and starts writing about the punter.
   <sub>resilience +2; intelligence +1; mods focused</sub>

2. **Invite him to practice** (23 words)
   An invitation to watch practice, from the sideline, for a whole day. The next column is kinder, and he admits you're still good.
   <sub>social +2; charisma +1; followers +1; mods loose</sub>

3. **Put the columns on your garage wall** (23 words)
   Every column, printed and pinned to the garage wall where you kick. It's very motivating, a little strange, and {parent} adds his letters.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> A columnist has a feud with you, and every column is about you.

1. **Ignore it**: You ignore it. He runs out of things to say.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Invite him to practice**: You invite him to practice. The next column is kinder.
   <sub>social +2; charisma +1; rel team +3; followers +1; mods loose</sub>

3. **Use it**: You use it. Every column goes on the wall in your garage.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 13. PRO_746 The Social Media Break
*social; premise 32 words*

> You take a month off social media after a rough stretch, the apps deleted and the password changed. On day three you keep reaching for a phone that has nothing on it.

1. **Stay off the whole month** (24 words)
   The whole month, off. By week three you stop reaching for your phone, and you read two books and sleep better than in years.
   <sub>energy +2; resilience +2; followers -2; mods rested</sub>

2. **Have someone post for you** (21 words)
   Someone else posts the basics for you: game days, charity events. You don't read the replies, and it's the perfect middle.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Spend the time with people** (21 words)
   The time, spent with real people instead: long dinners, a walk with {best_friend}, an afternoon with {parent}. It's so much better.
   <sub>social +2; fun +2; rel best_friend +2; rel parent +1; mods loose</sub>

<details><summary>Before</summary>

> You take a month off social media, and it feels strange.

1. **Stay off the whole month**: You stay off the whole month. By week three, you stop reaching for your phone.
   <sub>energy +2; fun +1; followers -2; mods rested</sub>

2. **Have someone post for you**: You have someone post the basics. You don't read the replies.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Spend the time with people**: You spend the time with real people. Dinners get longer.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 14. PRO_747 The Charity Ride
*community; premise 27 words*

> You ride in a charity bike ride across the state with four teammates: three hundred miles, five days, and a support van driven by the equipment manager.

1. **Ride with the slowest group** (21 words)
   The slowest group, the whole way, telling stories. You finish last, laughing, and the charity raises the most it ever has.
   <sub>social +2; fun +2; rel team +3; mods loose</sub>

2. **Ride it hard** (26 words)
   Hard, every day, at the front. Your legs hate you by day three, and the charity gets a huge photo of you at the finish line.
   <sub>energy -3; toughness +2; ambition +1; skill_points +2; mods heavy_legs</sub>

3. **Organize the team's riders** (22 words)
   The team's riders and the support van, organized by you. Everyone finishes, nobody gets lost, and the equipment manager calls you 'boss'.
   <sub>energy -2; leadership +3; intelligence +1; rel team +1; mods inspired</sub>

<details><summary>Before</summary>

> You ride in a charity bike ride across the state with teammates.

1. **Ride with the slowest group**: You ride with the slowest group and finish last, laughing.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Ride it hard**: You ride it hard. Your legs hate you, and the charity raises a lot.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Organize the team**: You organize the team's riders and the support van.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 15. PRO_748 The Coach Who Believed in You
*family; premise 29 words*

> The coach who gave you your first chance is in the hospital after a heart attack. He's seventy-three, and his wife says he keeps asking about your last game.

1. **Visit on your day off** (23 words)
   A day off, spent at his bedside. He's thin and pale and still giving you notes about your follow-through, which makes you laugh.
   <sub>social +2; energy -2; rel coach +1; mods inspired</sub>

2. **Call his family** (23 words)
   His family, called, to ask what would actually help. You do all of it, including fixing his porch steps yourself on a Sunday.
   <sub>intelligence +1; leadership +2; mods focused</sub>

3. **Send a long letter** (24 words)
   A long letter, handwritten over two nights, about everything he did for you. His wife reads it to him, twice, and he keeps it.
   <sub>energy +1; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> The coach who gave you your first chance is in the hospital.

1. **Visit**: You visit on your day off. He's thin and still giving you notes.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Call his family**: You call his family and ask what would help. You do it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Send a letter**: You send a long letter. His wife reads it to him.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_749 The Teammate's Kid
*community; premise 26 words*

> A teammate's ten-year-old wants to kick and asks you for lessons, very formally, in a handwritten letter he delivers to your locker himself, wearing a tie.

1. **Teach him every Saturday** (24 words)
   Saturday mornings, all fall, on the practice field. He's good, and so is his smile, and his father watches from the fence every week.
   <sub>energy -2; leadership +3; charisma +1; rel team +2; mods inspired</sub>

2. **Make it a family thing** (20 words)
   Your family and his, together every Saturday: kicking first, then pancakes. The two families become very close over the season.
   <sub>social +2; fun +2; rel team +3; mods loose</sub>

3. **Give one lesson and cleats** (23 words)
   One proper lesson and a pair of cleats, signed. He wears the cleats to bed for a month and to school for another.
   <sub>energy +2; fun +2; charisma +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate's kid wants to kick, and asks you for lessons.

1. **Teach him**: You teach him every Saturday. He's good, and so is his smile.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Make it a family thing**: You bring your own family. The two families become close.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

3. **Give one lesson**: You give one lesson and a pair of cleats.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 17. PRO_751 The Neighbor's Kid
*community; premise 25 words*

> The neighbor's kid practices kicking in the street every day after school, against a recycling bin, with a ball that's lost most of its air.

1. **Show him one thing** (21 words)
   One thing, shown from the curb: the plant foot. He does it right the next day, and waves at your window.
   <sub>leadership +2; charisma +1; mods inspired</sub>

2. **Set up a net in your driveway** (21 words)
   A net in your driveway, with a new ball, and a sign that says it's his. His mother brings you cookies.
   <sub>social +2; fun +1; followers +1; mods loose</sub>

3. **Watch from the window** (24 words)
   From your kitchen window, every afternoon, you watch him kick against the recycling bin and remember, exactly, what it was like being that kid.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The neighbor's kid practices kicking in the street every day.

1. **Show him one thing**: You walk over and show him one thing. He does it right the next day.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Set up a net**: You set up a net in your driveway and tell him it's his.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

3. **Watch from the window**: You watch from the window and remember.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 18. PRO_752 Running the Music
*team; premise 29 words*

> You've been the locker room DJ for six years, and a rookie wants the job. He has a speaker the size of a refrigerator and opinions about your playlists.

1. **Hand it over with a speech** (23 words)
   The aux cord, handed over with a ceremony and a speech about responsibility. The room cheers, and he plays your favorite song first.
   <sub>fun +1; leadership +2; rel backup +2; mods inspired</sub>

2. **Share the job** (21 words)
   Fridays are his, the rest are yours. It works, and his Fridays are better than you would ever admit out loud.
   <sub>social +2; fun +2; rel team +2; mods loose</sub>

3. **Make him earn it** (22 words)
   A month of proving himself, playlist by playlist. His is better, and you admit it in front of the whole team meeting.
   <sub>resilience +1; ambition +2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> You've been the locker room DJ for years, and a rookie wants the job.

1. **Hand it over**: You hand it over with a speech. The room cheers.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Share the job**: You share it. Fridays are his.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Make him earn it**: You make him earn it. His playlist is better.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 19. PRO_756 The Middle-Aged Rookie
*team; premise 25 words*

> A thirty-year-old rookie kicker joins the club after years of tryouts, day jobs and empty stadiums at midnight. Everyone keeps saying you two should talk.

1. **Talk to him** (24 words)
   You talk to him over lunch. He spent six years kicking at midnight in a high school stadium, and you leave the table humbled.
   <sub>social +2; fun +1; rel backup +4; mods loose</sub>

2. **Help him** (20 words)
   You help him learn the league: travel, routines, which coaches mean what. He's grateful and fast, which makes you nervous.
   <sub>energy -2; leadership +3; rel backup +2; skill_points +1; mods inspired</sub>

3. **Stay focused** (22 words)
   Polite, and focused on your job. He's still competition, whatever his story is, and his story won't keep your job for you.
   <sub>energy -1; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> A thirty-year-old rookie kicker joins the club after years of tryouts and day jobs. Everyone keeps saying you two should talk.

1. **Talk to him**: You talk to him over lunch. He spent six years kicking at midnight in a high school stadium, and you leave the table humbled.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Help him**: You help him learn the league: travel, routines, which coaches mean what. He's grateful and fast, which makes you nervous.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Stay focused**: You stay polite and focused. He's still competition, and his story won't keep your job for you.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 20. PRO_757 The Retirement Seminar
*career; premise 25 words*

> The union holds a retirement seminar on a Tuesday night. You sit in the back row, near the door, in case you want to leave.

1. **Take notes** (23 words)
   Notes, pages of them, in the back row. Some of it scares you, usefully, and you call your advisor on the drive home.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Bring a teammate** (26 words)
   You bring a teammate who needs it more than you do. He doesn't say a word all night and asks for your notes the next day.
   <sub>social +2; leadership +1; rel team +2; mods loose</sub>

3. **Leave early** (22 words)
   You leave at the break. Not yet. In the parking lot, you sit in the car a while before you start it.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The union holds a retirement seminar on a Tuesday night. You sit in the back row, near the door, in case you want to leave.

1. **Take notes**: You take notes. Some of it scares you, usefully, and you call your advisor on the drive home.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Bring a teammate**: You bring a teammate who needs it more than you do. He doesn't say a word all night and asks for your notes the next day.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Leave early**: You leave at the break. Not yet. In the parking lot, you sit in the car a while before you start it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 21. PRO_759 The Lost Season
*career; premise 26 words*

> A season where nothing goes right: the team loses nine straight, the coach is on the hot seat, and your own kicks feel like someone else's.

1. **Keep working** (22 words)
   You keep working, because it's all you can do. By December your kicks feel like yours again, even if the team doesn't.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Hold the room together** (20 words)
   The room, held together while the losses pile up. The young players remember who stayed calm, long after the season.
   <sub>energy -1; leadership +3; rel team +3; mods inspired</sub>

3. **Lean on home** (21 words)
   Home, every night: dinner with people who don't care about the score. It saves your season, and maybe more than that.
   <sub>social +2; fun +2; rel parent +2; mods loose</sub>

<details><summary>Before</summary>

> A season where nothing goes right, for the team or for you.

1. **Keep working**: You keep working. It's all you can do, and by December it's enough to feel like yourself again.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Hold the room together**: You hold the room together when the losses pile up. The young players remember who stayed calm.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Lean on home**: You lean on home. Dinner with the people who don't care about the score saves your season.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 22. PRO_760 The Comeback Practice
*training; premise 25 words*

> After a rough week, you have the best practice of your career: every kick perfect, every hold perfect, and the coaches stop talking to watch.

1. **Write down what changed** (23 words)
   Everything that changed, written down that night: the sleep, the warmup, the one thought. You keep the page in your bag for years.
   <sub>accuracy +1; intelligence +2; mods focused</sub>

2. **Thank the unit** (21 words)
   The unit, thanked before you leave the field, one by one. {holder} grins all the way back to the locker room.
   <sub>social +2; charisma +1; rel holder +3; mods inspired</sub>

3. **Go home happy** (20 words)
   Home, happy, and ten hours of sleep for the first time in a month. You don't analyze any of it.
   <sub>energy +3; fun +1; mods rested</sub>

<details><summary>Before</summary>

> After a rough week, you have the best practice of your career.

1. **Write down what changed**: You write down everything that changed: the sleep, the warmup, the one thought. You keep the page in your bag.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Thank the unit**: You thank the unit before you leave the field. {holder} grins all the way to the locker room.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

3. **Go home happy**: You go home happy and sleep ten hours for the first time in a month.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 23. PRO_761 The Kicker Who Took Your Spot in College
*social; premise 33 words*

> The kicker who beat you for a scholarship in college, the one whose name you used to say like a curse, is out of football now and asks for your help finding work.

1. **Help him find work** (22 words)
   Calls to people you know, for him, over a week. A job comes through, and he's grateful, and so, strangely, are you.
   <sub>energy -1; leadership +2; charisma +1; rel rival +2; mods inspired</sub>

2. **Make one call** (23 words)
   One call, for him, to a friend in sales. It turns into a job interview, and he sends you a long message afterward.
   <sub>resilience +1; intelligence +1; mods focused</sub>

3. **Wish him well** (21 words)
   Good luck, said sincerely, and meant. It's strange how small the old wounds look now, and you sleep well that night.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The kicker who beat you for a job in college is out of football and asks for help.

1. **Help him**: You help him find work. He's grateful, and so are you.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Make one call**: You make one call for him. It turns into a job interview.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Wish him well**: You wish him well and mean it. It's strange how small the old wounds look now.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 24. PRO_762 The Captain's Dinner
*team; premise 26 words*

> You host the captains for dinner at your house, and it turns into a three-hour argument about the season: the coaches, the quarterback, the losing streak.

1. **Steer it to a plan** (22 words)
   By dessert, a plan: three things to fix, written on a napkin. The captains leave with a purpose, and the season turns.
   <sub>energy -1; leadership +3; intelligence +1; rel team +2; mods inspired</sub>

2. **Let it run** (21 words)
   Three hours of everyone saying everything that needed saying. The room is closer for it, and the dishes take an hour.
   <sub>social +2; fun +1; rel team +3; mods loose</sub>

3. **Take notes for the coaches** (21 words)
   Notes, taken quietly all night, and the best ideas brought to the coaches the next morning, without anyone's name on them.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> You host the captains for dinner, and it turns into a three-hour argument about the season.

1. **Steer it**: You steer it to a plan by dessert. The captains leave with three things to fix.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Let it run**: You let it run. Some things need saying.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Take notes**: You take notes and bring the best ideas to the coaches without names on them.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 25. PRO_763 The Booster's Favor
*social; premise 26 words*

> A wealthy booster asks you to make a few appearances at his business, on his schedule, for a private thank-you. It isn't quite against the rules.

1. **Say no politely** (20 words)
   You say no politely. He doesn't call again, and you never have to wonder what the thank-you would have cost.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Ask {coach} first** (20 words)
   You ask {coach} before answering. The coach says no for you, and you're relieved to have someone else to blame.
   <sub>social +2; charisma +1; leadership +1; rel coach +1; mods loose</sub>

3. **Do the favor** (26 words)
   You do the favor. It's fine, technically, and the parties are fun. Then he calls again, and again, and it's harder to say no each time.
   <sub>fun +2; social +3; charisma +1; ambition +1; rel coach -2; followers +1; mods loose</sub>

<details><summary>Before</summary>

> A wealthy booster asks you to make a few appearances at his business, on his schedule, for a private thank-you. It isn't quite against the rules.

1. **Say no politely**: You say no politely. He doesn't call again, and you never have to wonder what the thank-you would have cost.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Ask {coach} first**: You ask {coach} before answering. The coach says no for you, and you're relieved to have someone else to blame.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

3. **Do the favor**: You do the favor. It's fine, technically, and the parties are fun. Then he calls again, and again, and it's harder to say no each time.
   <sub>fun +2; social +3; charisma +1; retention -2; followers +1; mods loose</sub>

</details>

## 26. PRO_764 The Team Doctor's Advice
*health; premise 29 words*

> The team doctor suggests, over coffee, that you start planning your body's next twenty years, not just this season. She has a folder, and it's labeled with your name.

1. **Make the plan with her** (20 words)
   The plan, made with the doctor: stretching, scans, and a word you've never used before, 'longevity'. It's sobering and comforting.
   <sub>health +2; intelligence +2; mods focused</sub>

2. **Focus on this season** (21 words)
   This season first, you tell her. The folder goes in your locker, and you think about it more than you admit.
   <sub>energy -1; toughness +1; ambition +2; skill_points +1; mods dialed_in</sub>

3. **Bring family to the appointment** (23 words)
   {parent} comes to the next appointment and asks the questions you were afraid to. You leave with a plan and a calmer heart.
   <sub>social +2; resilience +1; rel parent +3; mods loose</sub>

<details><summary>Before</summary>

> The team doctor suggests you start planning your body's next twenty years, not just this season.

1. **Make the plan**: You make the plan with the doctor: stretching, scans and a word you've never used before, 'longevity'.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Focus on this season**: You focus on this season for now. The doctor's card stays in your wallet.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Bring {love_interest}**: You bring {love_interest} to the next appointment. They ask the questions you were afraid to.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 27. PRO_765 The Kicker in the Stands
*social; premise 29 words*

> A retired kicker you admired as a kid is in the stands, watching you warm up. You recognize the walk before you see the face, and your stomach flips.

1. **Go say hello** (26 words)
   Over to the railing to say hello. He knows your name, your stats and the one kick you'd rather forget, and he laughs about it kindly.
   <sub>social +2; fun +1; followers +1; mods loose</sub>

2. **Give him a show in warmups** (21 words)
   The best warmup of your year, for an audience of one. He nods once from the stands, and you feel twelve.
   <sub>energy -1; accuracy +1; ambition +2; skill_points +1; mods dialed_in</sub>

3. **Stay in your routine** (21 words)
   Your routine, unchanged. Afterward he leaves you a short note at the equipment window: 'Good habits.' You keep it for years.
   <sub>resilience +2; intelligence +1; mods focused</sub>

<details><summary>Before</summary>

> A retired kicker you admired is in the stands, watching you warm up.

1. **Go say hello**: You go say hello. He knows your name, and your stats, and the one kick you'd rather forget.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Give him a show**: You give him a show in warmups. He nods once from the stands.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Stay in your routine**: You stay in your routine. Afterward he leaves you a note: 'Good habits.'
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 28. PRO_022 The National List
*media; premise 27 words*

> Your name is on the national list for the league's best kicker, and the team's PR staff has eleven interview requests on a whiteboard, color-coded by urgency.

1. **Do all eleven** (21 words)
   All eleven, in a week. Your face is everywhere, you say the same three things forty times, and you sleep badly.
   <sub>social +2; energy -2; charisma +2; followers +5; mods spotlight</sub>

2. **Pick three and do them well** (21 words)
   Three interviews, chosen carefully and done well. One of them becomes the definitive piece about you, the one people still quote.
   <sub>intelligence +2; charisma +1; followers +3; mods focused</sub>

3. **Do none and keep kicking** (24 words)
   None at all. You keep kicking, the PR staff sighs and erases the whiteboard, and the list says what it says without your help.
   <sub>energy +2; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> Your name is on the national list for the league's best kicker, and the team's PR staff has eleven requests for you.

1. **Do them all**: You do all eleven. Your face is everywhere.
   <sub>social +2; charisma +1; rel team +1; followers +5; mods loose</sub>

2. **Pick three**: You pick three and do them well.
   <sub>energy -1; resilience +1; intelligence +2; followers +3; mods focused</sub>

3. **Do none**: You do none and keep kicking.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_023 The Skills Contest
*media; premise 26 words*

> The league invites you to the long-distance contest at the all-star week: a stadium, a television audience, and nine of the strongest legs in the league.

1. **Train for it like a playoff** (21 words)
   Two weeks of training for one contest. You go, compete hard, and come home with a trophy shaped like a goalpost.
   <sub>energy -2; power +2; ambition +1; followers +3; skill_points +2; mods dialed_in</sub>

2. **Go for the fun** (22 words)
   The week, spent with kickers from every club: dinners, card games, stories. You finish fourth and have the best time of anyone.
   <sub>social +2; fun +3; rel rival +1; followers +2; mods loose</sub>

3. **Decline and rest your leg** (24 words)
   A polite decline, and your leg gets a week of rest. The contest happens without you, and you watch it from your couch, cheering.
   <sub>energy +3; health +1; mods rested</sub>

<details><summary>Before</summary>

> The league invites you to the long-distance contest at the all-star week.

1. **Go and compete**: You go and compete. You train for it like a playoff game.
   <sub>energy -2; resilience +1; ambition +2; followers +3; skill_points +2; mods dialed_in</sub>

2. **Go for the fun**: You go for the fun and spend the week with kickers from every club.
   <sub>social +2; charisma +1; rel team +3; followers +2; mods loose</sub>

3. **Decline**: You decline and rest your leg.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 30. PRO_055 Loyalty or the Paycheck
*career; premise 33 words*

> Another club would pay you double, your agent says, with the offer in writing. This one gave you your first chance when nobody else would. The general manager is waiting for your call.

1. **Stay** (23 words)
   You stay. The club remembers it, the locker room remembers it, and so do you, every time you drive past the old stadium.
   <sub>social +2; charisma +1; rel coach +1; retention +2; mods loose; flags stayed_loyal</sub>

2. **Explore it** (23 words)
   Your agent explores the offer, fully and openly. You kick the season like a free agent, and the club starts calling more often.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in; flags explored_options</sub>

3. **Ask your club to match** (24 words)
   Your club, asked to come closer to the other offer. They meet you partway, and you sign, a little richer and still at home.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused; flags stayed_loyal</sub>

<details><summary>Before</summary>

> Another club would pay you double. This one gave you your first chance.

1. **Stay**: You stay. The club remembers, and so do you.
   <sub>social +2; charisma +1; rel coach +1; retention +2; mods loose; flags stayed_loyal</sub>

2. **Explore it**: You tell your agent to explore it. You kick like a free agent.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in; flags explored_options</sub>

3. **Ask your club to match**: You ask your club to come closer. They meet you partway.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused; flags stayed_loyal</sub>

</details>

## 31. PRO_072 Broke at Thirty-Three
*money; premise 27 words*

> The money's gone faster than the career. There's a mortgage, a family, a car payment, and maybe three seasons left in your leg, if you're very lucky.

1. **Make a hard plan** (24 words)
   An honest advisor and a hard plan: a smaller house, no new cars, a budget taped to the fridge. It hurts, and it works.
   <sub>resilience +2; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Tell your family everything** (22 words)
   You tell your family everything at the kitchen table. It's the worst conversation of your life and the best one; nobody leaves.
   <sub>social +2; leadership +1; rel parent +3; mods loose</sub>

3. **Kick for one more contract** (21 words)
   You decide to kick for one more contract like your family depends on it. It does, and every practice feels heavier.
   <sub>energy -2; toughness +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> The money's gone faster than the career. There's a mortgage, a family, and maybe three seasons left in your leg, if you're lucky.

1. **Make a hard plan**: You sit down with an honest advisor and make a hard plan: a smaller house, no new cars, a budget on the fridge. It hurts, and it works.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Tell your family everything**: You tell your family everything at the kitchen table. It's the worst conversation of your life and the best one; nobody leaves.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

3. **Kick for one more contract**: You decide to kick for one more contract like your family depends on it. It does, and every practice feels heavier.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 32. PRO_109 The Awards Show
*media; premise 30 words*

> The league's awards show wants you on the red carpet the night before a practice you can't miss. There's a tuxedo waiting at your hotel and a car at seven.

1. **Walk the carpet and leave early** (20 words)
   The carpet, two interviews and gone before dessert. You make practice on time the next morning, tired and secretly pleased.
   <sub>social +2; energy -1; charisma +1; followers +4; mods spotlight</sub>

2. **Ask {coach}** (20 words)
   {coach} says go, and be on time. You are, at six in the morning, with makeup still behind your ear.
   <sub>resilience +1; intelligence +1; rel coach +2; mods focused</sub>

3. **Watch from home** (20 words)
   The awards, watched from home in sweatpants. You cheer loudly for the punter who wins, and you're asleep by ten.
   <sub>energy +3; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The league's awards show wants you on the red carpet the night before a practice you can't miss.

1. **Go and leave early**: You walk the carpet, do two interviews and leave before dessert.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Ask {coach}**: You ask {coach}. The coach says go, and be on time. You are.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Skip it**: You skip it and watch at home.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 33. PRO_219 Someone New, Later (unchanged)
*romance; premise 34 words*

> Years after it ended, a friend's dinner party seats you next to someone who doesn't care about football at all, has never heard of you and wants to talk about birds, of all things.

1. **Ask for their number** (25 words)
   Their number arrives before dessert, written on a napkin with a drawing of a heron. By spring you know more about birds than kicking, almost.
   <sub>fun +3; social +2; charisma +1; recast love_interest; mods inspired; flags new_partner, -enjoying_single_life, -made_long_distance_work, -committed_to_relationship</sub>

2. **Call {best_friend} first** (26 words)
   {best_friend} listens to the whole story on the drive home and says only, 'Call them.' You don't, yet, but you keep the napkin on your fridge.
   <sub>social +1; resilience +1; intelligence +1; rel best_friend +4; mods focused</sub>

3. **Not ready yet** (27 words)
   A lovely evening, and a polite goodbye at the door. You're not ready yet, and you're honest enough with yourself to know it, which feels like progress.
   <sub>energy +2; fun +1; leadership +1; mods rested; flags enjoying_single_life</sub>

## 34. PRO_220 The Second Wedding (unchanged)
*family; premise 32 words*

> Married before, both of you. Somewhere between the dishes and the dog, you start talking about doing it again with {love_interest}: smaller, quieter, and somehow harder to plan than the first time.

1. **The courthouse and a long dinner** (29 words)
   A Tuesday at the courthouse, two witnesses, and a long dinner after. Nobody posts anything. It's the happiest day you've had in years, and it belongs only to you.
   <sub>fun +3; energy +1; social +1; rel love_interest +6; mods inspired; flags married, -engaged</sub>

2. **Invite the people who stayed** (24 words)
   Only the people who stayed through everything: {parent}, {sibling}, {best_friend}. Forty chairs in a backyard, and {sibling} gives a toast that makes everyone cry.
   <sub>social +3; fun +2; energy -2; charisma +1; rel love_interest +4; rel sibling +3; rel parent +2; mods inspired; flags married, -engaged</sub>

3. **Wait one more season** (25 words)
   One more season, you agree, until you're both sure. {love_interest} understands, mostly, and the conversation comes back every few weeks, a little shorter each time.
   <sub>energy +1; resilience +1; ambition +1; rel love_interest -2; mods focused</sub>

## 35. PRO_221 The Anniversary
*family; premise 32 words*

> Ten years married, and you're in a hotel room in a city you can't remember the name of, with a road game tomorrow. {love_interest} is home with the dog and a cake.

1. **Fly {love_interest} in** (25 words)
   A ticket for the last flight in, booked from the team bus. One night together in a strange city, and it's the best anniversary yet.
   <sub>social +2; fun +3; rel love_interest +6; mods inspired</sub>

2. **Plan the real celebration** (24 words)
   The real celebration, planned for the bye week, down to the restaurant and the song. You talk about it all night on the phone.
   <sub>intelligence +2; leadership +1; rel love_interest +3; mods focused</sub>

3. **Call for an hour** (22 words)
   An hour on the phone from the hotel, talking about the first year: the tiny apartment, the bad car. It's enough, almost.
   <sub>energy +1; resilience +1; rel love_interest +2; mods rested</sub>

<details><summary>Before</summary>

> Ten years married, and you're in a hotel in a city you can't remember the name of.

1. **Fly {love_interest} in**: You fly {love_interest} in for one night. It's the best anniversary yet.
   <sub>social +2; charisma +1; rel love_interest +6; mods loose</sub>

2. **Plan the real one**: You plan a real celebration for the bye week, down to the restaurant.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Call for an hour**: You call for an hour from the hotel room and talk about the first year.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 36. PRO_238 The Comeback Year
*career; premise 26 words*

> Last year everyone wrote your obituary: released, or benched, and called finished in print. This year you're the first one on the field every single morning.

1. **Be first every day** (25 words)
   First on the field and last off it, every day. By September nobody is writing obituaries, and the columnist who wrote the worst one apologizes.
   <sub>energy -3; resilience +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Bring the young players** (21 words)
   The young players, invited to your early sessions. It becomes a club, and the club becomes the core of the team.
   <sub>energy -2; leadership +3; rel backup +2; rel team +1; mods inspired</sub>

3. **Prove it with numbers** (21 words)
   Every kick, charted, and the curve left on {coach}'s desk every Friday. The numbers do all the arguing for you, quietly.
   <sub>accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> Last year everyone wrote your obituary. This year you're the first one on the field.

1. **Be first every day**: You're first on the field every day, and last off it.
   <sub>energy -2; resilience +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Bring the young players**: You bring the young players with you. The early sessions become a club.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Prove it with numbers**: You track every kick and show the coaches the curve.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 37. PRO_256 Who Am I Without It
*health; premise 26 words*

> A sleepless night at three in the morning, the question you've been avoiding finally sitting on your chest: if you're not the kicker, who are you?

1. **Wake {love_interest}** (20 words)
   {love_interest}, woken gently, and you talk until dawn. By morning you have half an answer and a much fuller heart.
   <sub>social +2; resilience +1; rel love_interest +4; mods inspired</sub>

2. **Write it all down** (24 words)
   Everything you are besides a kicker, written on a legal pad. The list is longer than you thought, and some of it surprises you.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Walk until it's light** (21 words)
   A walk at three in the morning, through an empty neighborhood. The question comes with you, and so does the sunrise.
   <sub>energy -1; health +1; fun +1; resilience +2; mods drained</sub>

<details><summary>Before</summary>

> A sleepless night: if you're not the kicker, who are you?

1. **Wake {love_interest}**: You wake {love_interest} and talk until dawn.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Write it down**: You write down everything you are besides a kicker. The list is longer than you thought.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Go for a walk**: You go for a walk at three in the morning. The question comes with you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 38. PRO_271 The Family Vacation
*family; premise 30 words*

> A real family vacation, a whole week, no phones, and a family that's not used to having you around for seven straight days. The kids keep asking when you're leaving.

1. **Be completely there** (23 words)
   The phone, in a drawer, all week. You build sandcastles, lose at board games and fall asleep on the beach, and everyone notices.
   <sub>social +2; fun +3; rel love_interest +6; mods loose</sub>

2. **Plan every day** (21 words)
   Every day planned: the boat, the museum, the hike. It's fun and a little exhausting, and the kids love the boat.
   <sub>intelligence +2; leadership +1; rel love_interest +2; mods focused</sub>

3. **Train every morning** (23 words)
   Every morning, a run and a kicking session before anyone wakes up. You're there for the rest, mostly, and {love_interest} notices the mornings.
   <sub>energy -2; power +1; ambition +2; rel love_interest -1; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> A real vacation, no phones, and a family that's not used to having you around for a whole week.

1. **Be fully there**: You leave your phone in the drawer all week. Everyone notices.
   <sub>social +2; charisma +1; rel love_interest +6; mods loose</sub>

2. **Plan every day**: You plan every day. It's fun and a little exhausting.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Train in the mornings**: You train every morning before anyone wakes up.
   <sub>energy -2; ambition +2; rel love_interest -1; skill_points +2; mods dialed_in</sub>

</details>

## 39. PRO_279 The Fan Convention
*media; premise 27 words*

> A fan convention wants you for a signing weekend. The line includes people who've followed you since high school, and one woman has your peewee league photo.

1. **Talk to every person** (20 words)
   Every person in line gets a real conversation. It takes nine hours, and the woman with the peewee photo cries.
   <sub>social +2; energy -2; charisma +2; followers +4; mods inspired</sub>

2. **Keep the line moving kindly** (20 words)
   The line, kept moving, with every name said back to them. It's efficient and warm, and you finish on time.
   <sub>resilience +1; intelligence +1; charisma +1; followers +2; mods focused</sub>

3. **Do one day** (20 words)
   One day of signing, and the other at the hotel pool. The organizers are gracious, and you come home rested.
   <sub>energy +3; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A fan convention wants you for a signing weekend. The line includes people who've followed you since high school.

1. **Talk to everyone**: You talk to every person in line. It takes nine hours.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Keep it moving**: You keep the line moving and still say each name.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Do one day**: You do one day and keep the other.
   <sub>energy +2; fun +1; mods rested</sub>

</details>


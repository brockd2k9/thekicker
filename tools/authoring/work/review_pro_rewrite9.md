# PRO rewrite pass 9: era-3 scenes 1-39

The first 39 era-3 scenes (ages 30-33): coaching changes, business offers, maintenance and aging, the mentoring of a rookie kicker, the veteran's place in the room.

Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 39 of 39.**

**Standing costs removed** (routine choices): PRO_088 "Leave it to the coaches" (-1); PRO_280 "Go and climb" (-2).

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_053 A Coach Out of a Job
*team; premise 31 words*

> The head coach is fired after a Monday team meeting, in front of everyone, with a two-sentence statement from the owner. That night, {coach}'s office lights are still on at eleven.

1. **Check on {coach}** (32 words)
   A knock on the lit office door at eleven. You talk for an hour about the head coach, the business and the next three weeks, and {coach} thanks you at the door.
   <sub>social +2; resilience +1; rel coach +4; mods drained</sub>

2. **Steady the specialists** (27 words)
   The specialists, gathered the next morning: same routine, same standards, whoever the coach is. The week goes on, and the young players watch how you do it.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

3. **Wait and see** (24 words)
   Head down, waiting to see who comes next. It's the business, and you've seen enough of it to know that worrying changes nothing, mostly.
   <sub>energy +2; resilience +1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> The head coach is fired after a team meeting. {coach}'s office lights are on late.

1. **Check on {coach}**: You stop by {coach}'s office. You talk for an hour.
   <sub>social +2; charisma +1; rel coach +4; mods loose</sub>

2. **Steady the room**: You steady the specialists. The week goes on.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep your head down**: You keep your head down and wait.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 2. PRO_054 The General Manager's Nephew
*team; premise 28 words*

> The new general manager is the owner's nephew, thirty-one years old, with a spreadsheet about kickers that he's very proud of. He wants to meet you on Friday.

1. **Teach him about kicking** (26 words)
   A polite meeting, and a gentle education: what the spreadsheet misses, what the film shows, what a kicker actually does. He takes notes, which surprises you.
   <sub>intelligence +2; charisma +1; rel coach +1; mods focused</sub>

2. **Let the work speak** (21 words)
   No meeting needed. You let your practices speak for you, and by midseason he quietly stops sending you spreadsheets about kickers.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Invite him to practice** (27 words)
   An invitation to watch a special teams practice from the field. He holds a ball for you, badly, and leaves with a new respect for the job.
   <sub>social +2; fun +1; leadership +1; rel coach +1; mods loose</sub>

<details><summary>Before</summary>

> The new general manager is the owner's nephew, and he has opinions about kickers.

1. **Educate him**: You ask for a meeting and educate him, politely.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Let the work speak**: You let the work speak. He stops having opinions.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Win him over**: You invite him to watch a special teams practice.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 3. PRO_063 The Car Dealership
*money; premise 28 words*

> A car dealership wants you as a partner: your face on the billboards, your money in the lot, and a guaranteed parking space with your name on it.

1. **Become a partner** (27 words)
   You sign. Your face goes up on the highway, and every teammate calls you about a deal. The dealership's books are the dealer's business, until they aren't.
   <sub>fun +2; ambition +2; charisma +1; followers +3; mods spotlight; flags dealership_partner</sub>

2. **Do the ads, skip the ownership** (24 words)
   You agree to the billboards for a flat fee and keep your money out of the lot. It's less exciting and a lot safer.
   <sub>intelligence +2; leadership +1; followers +2; mods focused</sub>

3. **Keep your name off the lot** (25 words)
   No dealership, no billboard, no parking space. Your money stays where it is, and the dealership signs a weatherman, whose face you see every day.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A car dealership wants you as a partner: your face on the billboards, your money in the lot, and a guaranteed parking space with your name on it.

1. **Become a partner**: You sign. Your face goes up on the highway, and every teammate calls you about a deal. The dealership's books are the dealer's business, until they aren't.
   <sub>fun +2; social +1; ambition +1; intelligence -1; followers +3; mods spotlight; flags dealership_partner</sub>

2. **Do the ads, skip the ownership**: You agree to the billboards for a flat fee and keep your money out of the lot. It's less exciting and a lot safer.
   <sub>energy -1; intelligence +1; charisma +1; followers +2; mods focused</sub>

3. **Pass**: You pass. Your face stays off the highway, and somebody else's goes up three months later.
   <sub>energy +1; intelligence +1; mods rested</sub>

</details>

## 4. PRO_070 The Foundation
*community; premise 29 words*

> Your charity foundation's director is spending more on galas than on kids: the books show a ballroom, a band and a photographer, and only two new programs all year.

1. **Replace the director** (24 words)
   A new director, hired by you after a hard conversation with the old one. You run the next year closely, and the programs double.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired; flags started_foundation</sub>

2. **Audit the books** (21 words)
   An outside audit, every line, with new rules on spending afterward. The director stays, chastened, and the money starts reaching kids.
   <sub>resilience +1; intelligence +2; mods focused; flags started_foundation</sub>

3. **Trust the director** (21 words)
   The galas raise money too, you tell yourself, and you let it run. The next annual report is glossy and thin.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Your charity foundation's director is spending more on galas than on kids.

1. **Replace the director**: You replace the director and run the next year yourself.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags started_foundation</sub>

2. **Audit the books**: You audit the books and set new rules.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags started_foundation</sub>

3. **Let it run**: You let it run. The galas are nice.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 5. PRO_073 The Pension Meeting
*team; premise 27 words*

> The players' union holds a meeting about pensions and retirement plans in a hotel conference room. Six players show up, and you're the youngest by four years.

1. **Go and take notes** (22 words)
   Notes on everything, for two hours. It's boring and important, and you understand your pension for the first time in your career.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Bring twelve teammates next time** (24 words)
   Twelve teammates at the next meeting, recruited by you one at a time. The union rep looks at you like you've performed a miracle.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

3. **Skip it** (21 words)
   Retirement feels far away, so you skip it. The six who went start a group chat, and you're not in it.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The players' union holds a meeting about pensions and retirement plans. Six players show up.

1. **Go and take notes**: You go and take notes. It's boring and important.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Bring teammates next time**: You bring twelve teammates to the next one.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Skip it**: You skip it. Retirement feels far away.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 6. PRO_084 The Coach Who Taught You
*community; premise 31 words*

> Your high school coach is retiring after thirty-one years, and the school wants you to speak at the dinner. The gym will be full of people who knew you at fifteen.

1. **Speak from the heart** (27 words)
   What that coach did for you, said plainly to a full gym. They stand at the end, and your old coach can't look up from the table.
   <sub>social +2; charisma +2; rel parent +1; mods inspired</sub>

2. **Bring the current team** (28 words)
   The current high school team, invited to the dinner by you, in their jerseys. Your old coach sees the whole program in one room and laughs through tears.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

3. **Send a letter to be read** (21 words)
   A letter, read aloud by the principal. It's lovely, and you wish, reading the reports, that you'd been there in person.
   <sub>energy +2; intelligence +1; mods rested</sub>

4. **Tell the story of the trust** *(locked: having earned a coach's trust before)* (29 words)
   How that trust was earned, and how you had to earn it again later: you tell the whole story. Your old coach nods along to every part of it.
   <sub>social +2; leadership +1; charisma +1; mods inspired</sub>

<details><summary>Before</summary>

> Your high school coach is retiring, and the school wants you to speak at the dinner.

1. **Speak from the heart**: You tell the room what that coach did for you. They stand.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Bring the team**: You bring the current high school team to the dinner.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Send a letter**: You send a letter that gets read aloud.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Tell the story of the trust**: You tell the story of how that trust was earned, and what it taught you about earning it again.
   <sub>social +2; leadership +1; charisma +1; mods inspired</sub>

</details>

## 7. PRO_088 The Rookie Kicker You Mentor
*team; premise 30 words*

> The club drafts a kicker in the fourth round and asks you to show the rookie how things work. Everybody in the building knows what that means, including the rookie.

1. **Teach him everything** (25 words)
   Everything, generously: the routines, the wind, the coaches' moods. He'll take your job someday, and he'll do it right, and he'll know who taught him.
   <sub>energy -2; leadership +3; rel backup +4; skill_points +1; mods inspired; flags mentored_rookie_kicker</sub>

2. **Teach him the basics** (25 words)
   The basics, taught well, and the rest kept for yourself. He learns fast anyway, and you notice him watching your routine from across the field.
   <sub>energy -1; ambition +2; intelligence +1; skill_points +2; mods dialed_in</sub>

3. **Leave it to the coaches** (22 words)
   The coaches can teach him, you decide, and you keep your distance all camp. The room notices, and so, unfortunately, does {coach}.
   <sub>energy +2; resilience +1; mods rested</sub>

4. **Do it the way you've done it** *(locked: having mentored before)* (28 words)
   You've done this before, so you know what to teach and when: the routine in week one, the wind in week three, the nerves before his first game.
   <sub>social +1; leadership +2; mods inspired; flags mentored_rookie_kicker</sub>

<details><summary>Before</summary>

> The club drafts a kicker and asks you to show the rookie how things work, knowing what that means.

1. **Teach him everything**: You teach him everything. He'll take your job someday, and he'll do it right.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags mentored_rookie_kicker</sub>

2. **Teach him the basics**: You teach him the basics and keep the rest.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Let the coaches do it**: You let the coaches do it.
   <sub>energy +2; fun +1; retention -1; mods rested</sub>

4. **Do it the way you've done it**: You've done this before. You know what to teach and when.
   <sub>social +1; leadership +2; mods inspired; flags mentored_rookie_kicker</sub>

</details>

## 8. PRO_094 The Letter From a Kid
*community; premise 33 words*

> A letter arrives at the facility from a kid you met in a hospital years ago. He's twelve now, and walking, and he's enclosed a photo of himself standing next to a football.

1. **Write back** (27 words)
   A handwritten reply, two pages, with a signed photo of your own. He frames it, and his mother sends you a picture of it on his wall.
   <sub>social +2; resilience +1; charisma +1; rel parent +1; mods loose</sub>

2. **Invite him to a practice** (23 words)
   An invitation to practice, for him and his family. He walks onto the field himself, slowly, and the whole team stops to clap.
   <sub>energy -1; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep the letter** (23 words)
   The letter goes in your locker, next to your cleats. On bad days you read it again, and it fixes something every time.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

4. **Go back to the hospital** *(locked: having volunteered for years)* (20 words)
   You go back to the hospital where you met him, and you bring his letter to show the kids there.
   <sub>social +2; energy -1; leadership +1; charisma +1; followers +2; mods inspired</sub>

<details><summary>Before</summary>

> A letter from a kid in a hospital you visited years ago: he's walking now.

1. **Write back**: You write back by hand. He frames it, and his mother sends a picture.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Invite him to a practice**: You invite him and his family to practice. He walks onto the field.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep the letter**: You keep the letter in your locker and read it on bad days.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Go back to the hospital**: You go back to the hospital where you met him, and you bring his letter to show the kids there.
   <sub>social +2; energy -1; leadership +1; charisma +1; followers +2; mods inspired</sub>

</details>

## 9. PRO_131 Thirty
*health; premise 27 words*

> You turn thirty in camp, and the trainer starts using the word 'maintenance' in every conversation. Your birthday cake has a candle shaped like an ice pack.

1. **Listen to the trainer** (28 words)
   The new maintenance routine, added without complaint: bands, heat, an extra stretching block. It's dull and it works, and your hip stops talking to you in the mornings.
   <sub>energy -1; health +3; intelligence +1; mods focused</sub>

2. **Prove you don't need it** (23 words)
   No maintenance, thanks; you'll prove you don't need it. Your body disagrees by October, loudly, and the trainer says nothing, which is worse.
   <sub>health -2; power +1; ambition +2; skill_points +3; mods sore</sub>

3. **Celebrate with the unit** (24 words)
   A birthday in the cafeteria, thrown by the specialists, with the ice-pack candle and a terrible song. {holder} gives a speech about your age.
   <sub>social +2; fun +2; rel holder +3; mods loose</sub>

<details><summary>Before</summary>

> You turn thirty in camp, and the trainer starts talking about 'maintenance'.

1. **Listen to the trainer**: You listen and add the new routine. It's dull and it works.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Prove you don't need it**: You decide to prove you don't need it. Your body disagrees by October.
   <sub>energy -2; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Celebrate with the unit**: You let the specialists throw you a birthday in the cafeteria.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 10. PRO_132 The Maintenance Bill
*health; premise 28 words*

> Holding on to your leg costs more every year: more treatment, more rest days, more hours in the cold tub, and more of the life outside the facility.

1. **Plan the year around recovery** (23 words)
   The whole year, planned around recovery like a second job. It's tedious, and your leg is the best it's been in three seasons.
   <sub>health +2; intelligence +2; mods focused</sub>

2. **Work harder instead** (23 words)
   Harder, not smarter: more reps, more lifting, more hours. It holds, for now, and you can feel the bill coming for next year.
   <sub>energy -3; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Rest more, train less** (24 words)
   More rest, less training. Your leg feels fresh on game days and a little slower in practice, and you can't decide if that's wisdom.
   <sub>energy +3; health +1; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Holding on to your leg costs more every year: more treatment, more rest, more of your time.

1. **Budget your body**: You plan the whole year around recovery. It's a second job.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Work harder instead**: You work harder instead of smarter. It holds, for now.
   <sub>energy -2; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Rest more**: You rest more and train less. Your leg feels fresh, and a little slower.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 11. PRO_225 {sibling}'s Family
*family; premise 32 words*

> {sibling} has kids of his own now, two of them, and they think you're the most famous person alive. They have your jersey, your card and a poster above the bunk bed.

1. **Be the fun uncle for a day** (28 words)
   A whole day with them: the zoo, the park, ice cream twice. They tell their entire school about it for a year, and {sibling} looks at you differently.
   <sub>social +2; fun +3; rel sibling +5; mods loose</sub>

2. **Teach them to kick** (23 words)
   Kicking lessons in {sibling}'s backyard, with a net and a lot of patience. The younger one is actually good, which {sibling} finds hilarious.
   <sub>energy -2; leadership +2; charisma +1; rel sibling +3; skill_points +1; mods inspired</sub>

3. **Send signed gear** (20 words)
   Signed gear and a video message, mailed with a long note. They wear the jerseys to bed for a month.
   <sub>energy +2; resilience +1; rel sibling +1; mods rested</sub>

<details><summary>Before</summary>

> {sibling} has kids of his own now, and they think you're the most famous person alive.

1. **Be the fun uncle**: You spend a whole day with them. They tell their school about it for a year.
   <sub>social +2; charisma +1; rel sibling +5; mods loose</sub>

2. **Teach them to kick**: You teach them to kick in the backyard. One of them is actually good.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Send signed gear**: You send signed gear and a video.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_229 The Radio Show
*media; premise 32 words*

> A local radio station offers you a weekly show during the season: an hour on Wednesday nights, your name in the title, and callers who want to talk about everything but kicking.

1. **Say yes** (26 words)
   Yes, every Wednesday. The callers love you, a few teammates call in under fake names, and you become the voice of the club for a season.
   <sub>social +2; energy -1; charisma +2; rel team +1; followers +3; mods loose; flags radio_show</sub>

2. **Do it in the offseason** (25 words)
   An offseason show only, you counter, and they agree. It's relaxed and fun, and you never have to talk about a loss the night after.
   <sub>intelligence +2; leadership +1; mods focused; flags radio_show</sub>

3. **Keep your Wednesdays** (22 words)
   No show this year. Your Wednesday nights stay quiet and yours, and the station hires a retired linebacker who shouts a lot.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A local station offers you a weekly radio show during the season.

1. **Say yes**: You say yes. The callers love you, and so do some teammates.
   <sub>social +2; charisma +1; rel team +1; followers +3; mods loose; flags radio_show</sub>

2. **Do it in the offseason**: You agree to an offseason show only. It works.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags radio_show</sub>

3. **Decline**: You decline. Your Mondays stay quiet.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 13. PRO_235 A Franchise Offer
*money; premise 27 words*

> A restaurant chain offers you a franchise with your name on it: real professionals running it this time, a real contract, and your face on the menu.

1. **Do it with professionals** (24 words)
   Signed, with professionals running it and two lawyers reading everything first. It opens in March, and the burger named after you is surprisingly good.
   <sub>resilience +1; intelligence +2; leadership +1; mods focused; flags franchise_owner</sub>

2. **Bring family in** (25 words)
   {sibling}, brought in to keep an eye on things for you. It's a family project now, and {sibling} turns out to be good at it.
   <sub>social +2; fun +1; leadership +1; rel sibling +3; mods loose; flags franchise_owner</sub>

3. **Stay out of restaurants** (22 words)
   No franchise for you. You have enough to think about already, and you've watched what restaurants did to two teammates' savings accounts.
   <sub>energy +2; fun +1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A restaurant chain offers you a franchise with your name on it, this time with professionals running it.

1. **Do it with professionals**: You sign with professionals running it and lawyers reading everything.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags franchise_owner</sub>

2. **Bring family in**: You bring {sibling} in to keep an eye on it.
   <sub>social +2; charisma +1; rel sibling +3; mods loose; flags franchise_owner</sub>

3. **Pass**: You pass. You have enough to think about.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 14. PRO_270 The Camp You Teach
*community; premise 28 words*

> A youth camp asks you to coach for a week in July. The kids kick terribly, fall over constantly, and have more fun than you've had in years.

1. **Coach every station** (27 words)
   Every station, coached by you, all week. By Friday three of them can actually kick, and one of them cries when his first one clears the bar.
   <sub>energy -3; leadership +3; skill_points +1; mods inspired</sub>

2. **Play with them as much as coach** (24 words)
   Half coaching, half playing: tag, relay races, a kicking contest you lose on purpose. You laugh all week and go home sunburned and happy.
   <sub>social +2; fun +3; mods loose</sub>

3. **Coach the mornings only** (23 words)
   The mornings, coached properly, and the afternoons for rest. It's a good balance, and the head counselor is grateful for any of it.
   <sub>energy +1; health +1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A youth camp asks you to coach for a week. The kids kick terribly and have more fun than you've had in years.

1. **Coach every station**: You coach every station. By Friday, three of them can kick.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Play with them**: You play with them as much as you coach. You laugh all week.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Do the mornings**: You do the mornings and rest in the afternoons.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 15. PRO_276 Back to Your College
*training; premise 32 words*

> Your college invites you back for spring practice. The kicking net is in the same place, the equipment manager is the same man, and the cafeteria still serves the same terrible pasta.

1. **Coach their kickers for a day** (23 words)
   Their kickers, coached by you for a whole day. They follow you everywhere, ask a hundred questions and kick better by the end.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

2. **Find the old staff** (25 words)
   The equipment manager, the trainers, the woman who ran the cafeteria. They tell stories about you that you'd rather forget, and you love every one.
   <sub>social +2; fun +2; rel best_friend +2; mods loose</sub>

3. **Stand by the net for a while** (26 words)
   The facility, walked alone, and a long time standing by the old net. You think about the kid who kicked there, and how far he came.
   <sub>energy +1; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> Your college invites you back for spring practice. The kicking net is in the same place.

1. **Coach the kickers**: You coach their kickers for a day. They follow you everywhere.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Find the old staff**: You find the old equipment manager and the trainers. They tell stories.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

3. **Walk around**: You walk the facility alone and stand by the net for a while.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_280 The Mountain Trip
*social; premise 29 words*

> Friends from college plan a climbing trip for the offseason: a real mountain, ropes, a guide. Your contract has a clause about 'dangerous activities', and you've just reread it.

1. **Read the clause and pass** (24 words)
   The clause wins: you stay home and see the pictures from the summit. It's the right call, and you feel old for a week.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Go and hike instead** (24 words)
   You go along, and hike the trails while they climb. You're there for the campfire and the stories, and nobody's contract is in danger.
   <sub>social +2; charisma +1; rel best_friend +3; mods loose</sub>

3. **Go and climb** (25 words)
   You go and climb, and it's amazing. You don't tell your agent, and every time your ankle twinges in camp you wonder if anyone knows.
   <sub>fun +4; energy -2; social +1; ambition -1; rel best_friend +5; mods loose</sub>

<details><summary>Before</summary>

> Friends plan a climbing trip. Your contract has a clause about 'dangerous activities'.

1. **Read the clause and pass**: You read the clause and stay home. You see the pictures.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Go and hike instead**: You go with them and hike while they climb. You're there for the campfire.
   <sub>social +2; charisma +1; rel best_friend +3; mods loose</sub>

3. **Go and climb**: You go and climb. It's amazing, and you don't tell your agent.
   <sub>fun +4; energy -2; social +1; ambition -1; rel best_friend +5; retention -2; mods loose</sub>

</details>

## 17. PRO_286 The Off-Season Job Offer
*career; premise 30 words*

> A company offers you an offseason job in sales: real work, a real desk, a real quota. It would be good to know you can do something other than kick.

1. **Take the job** (27 words)
   The job, taken, with a desk and a badge. You learn you're good at it, and the quota board has your name at the top by June.
   <sub>energy -2; intelligence +1; charisma +2; leadership +1; mods focused</sub>

2. **Shadow for a week** (23 words)
   Seven days of shadowing a top salesperson. It's useful and humbling, and you leave with a much better idea of life after football.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Keep the offseason for your leg** (20 words)
   Your leg needs the offseason, you decide, and you pass. It's sensible, and you wonder about the desk all summer.
   <sub>energy +2; health +1; mods rested</sub>

<details><summary>Before</summary>

> A company offers you an offseason job in sales. It's real work, and it would be good to know you can do it.

1. **Take the job**: You accept the job and learn you're good at it.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Shadow for a week**: You shadow someone for a week. It's useful and humbling.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Pass**: You pass. Your offseason is for your leg.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 18. PRO_287 Family Reunion, Pro Edition
*family; premise 30 words*

> The family reunion, at a lake. Everyone wants a photo with you, an aunt wants your autograph for her mail carrier, and one uncle wants a loan for a boat.

1. **Take every photo** (24 words)
   Every photo, every autograph, and a promise to the uncle that you'll think about it. It's exhausting and warm, and {parent} beams all day.
   <sub>social +3; energy -1; rel parent +3; mods loose</sub>

2. **Say no to the loan kindly** (21 words)
   No to the boat, kindly and clearly. The uncle sulks through dessert, and three cousins thank you privately for saying it.
   <sub>intelligence +2; leadership +1; rel parent +1; mods focused</sub>

3. **Leave early** (21 words)
   An early exit, before the speeches. You'll see everyone next time, and {sibling} texts you a photo of the uncle's face.
   <sub>energy +2; fun +1; rel sibling +1; mods rested</sub>

<details><summary>Before</summary>

> The family reunion. Everyone wants a photo, and one uncle wants a loan.

1. **Take every photo**: You take every photo and tell the uncle you'll think about it.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

2. **Say no kindly**: You say no to the loan, kindly and clearly. He sulks through dessert.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Leave early**: You leave early. You'll see everyone next time.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 19. PRO_391 The Room Starts Looking at You
*team; premise 25 words*

> Teammates have started bringing their problems to your locker: contracts, girlfriends, coaches, homesick kids, a lineman's divorce. You're not sure when you became that person.

1. **Make time** (25 words)
   You make time for every one of them, even when it costs you film work. You're more tired, and the room is steadier for it.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Listen** (23 words)
   Mostly, you listen. It turns out that's what they need, and the young ones start bringing you coffee as a kind of payment.
   <sub>social +2; resilience +1; rel backup +2; mods loose</sub>

3. **Set limits** (23 words)
   You set limits: after practice, never before. A few people take it personally, and you keep enough of yourself to do the job.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> Teammates have started bringing their problems to your locker: contracts, girlfriends, coaches, homesick kids. You're not sure when that happened.

1. **Make time**: You make time for every one of them, even when it costs you film work. You're more tired, and the room is steadier for it.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Listen**: You mostly listen. It turns out that's what they need, and the young ones start bringing coffee as payment.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Set limits**: You set limits: after practice, never before. A few people take it personally, and you keep enough of yourself to do the job.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 20. PRO_392 The Coaching Staff Meeting
*training; premise 30 words*

> A new coach wants to change the preparation routine that got you here: a new warmup, a new film schedule, and a new word for 'hold' that nobody can pronounce.

1. **Explain the routine** (23 words)
   Every piece of your routine, explained with reasons. He keeps most of it, changes the film schedule, and drops the new word entirely.
   <sub>intelligence +2; leadership +1; rel coach +2; mods focused</sub>

2. **Try it his way** (20 words)
   His way, for a month, honestly. Some of it sticks, and the coaches notice that the veteran didn't fight them.
   <sub>energy -2; accuracy +1; ambition +1; rel coach +1; skill_points +2; mods dialed_in</sub>

3. **Find the middle over lunch** (22 words)
   The middle ground, found over lunch at a diner. It's mostly your routine, with his film schedule, and you both claim victory.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

<details><summary>Before</summary>

> A new coach wants to change the preparation routine that got you here.

1. **Explain the routine**: You explain why each piece is there. He keeps most of it.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Try his way**: You try his way for a month. Some of it sticks.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Find middle ground**: You find middle ground over lunch.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 21. PRO_394 The Retirement Plan
*money; premise 32 words*

> You sit down at the kitchen table with a calculator and a yellow pad and try to work out how much you'll need after football. The number is bigger than you expected.

1. **Do the math** (23 words)
   The math, done properly with an honest advisor over three meetings. It's sobering and useful, and you finally know what 'enough' looks like.
   <sub>resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Do it with {love_interest}** (22 words)
   {parent} sits beside you with a second calculator and decades of experience. You make the plan together, and it's better for it.
   <sub>social +2; leadership +1; rel parent +2; mods loose</sub>

3. **Leave it for next year** (20 words)
   Next year, you decide, and the yellow pad goes in a drawer. The number keeps growing in your head anyway.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> You sit down and work out how much you'll need after football.

1. **Do the math**: You do the math with an honest advisor. It's sobering and useful.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Do it with {love_interest}**: You do it with {love_interest}. You make a plan together.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Put it off**: You put it off another year.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 22. PRO_395 The Former Teammate's Retirement
*team; premise 28 words*

> A teammate you've lined up beside for years retires on a Wednesday. By Thursday morning his locker is empty, his nameplate is gone, and the room sounds different.

1. **Keep in touch** (23 words)
   You keep in touch. He calls on game days with notes from his couch, and the calls get funnier the longer he's away.
   <sub>social +2; fun +1; rel team +4; mods loose</sub>

2. **Fill the space** (24 words)
   You start doing the things he used to do: the jokes before meetings, the check-ins on rookies. It's harder than he made it look.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

3. **Let it be different** (24 words)
   You let it be different. Rooms change; this one will too. You notice his empty chair less each week, and feel guilty about that.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate you've lined up beside for years retires on a Wednesday. Thursday morning his locker is empty, and the room sounds different.

1. **Keep in touch**: You keep in touch. He calls on game days with notes from his couch, and the calls get funnier the longer he's away.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Fill the space**: You start doing the things he used to do: the jokes before meetings, the check-ins on rookies. It's harder than he made it look.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Let it be different**: You let it be different. Rooms change; this one will too. You notice his empty chair less each week, and feel guilty about that.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 23. PRO_396 The Younger Generation
*team; premise 25 words*

> A rookie asks how you handle the pressure, standing by the kicking net after practice, and you realize you've never once said it out loud.

1. **Say it out loud** (24 words)
   For the first time, you find the words: the breath, the one thought, the forgetting. He writes them down, and so, later, do you.
   <sub>energy -1; leadership +2; intelligence +1; rel backup +2; mods inspired</sub>

2. **Show him instead** (25 words)
   Not words: you take him to the field and show him your routine, breath by breath, kick by kick. He gets it faster that way.
   <sub>social +1; accuracy +1; charisma +1; rel backup +3; mods focused</sub>

3. **Tell him it comes with time** (23 words)
   It comes with time, you tell him. It's true, and it isn't much help, and you think about it on the drive home.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A rookie asks how you handle the pressure, and you realize you've never said it out loud.

1. **Say it out loud**: You find the words for the first time. He writes them down, and so, later, do you.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Show him instead**: You take him to the field and show him your routine, breath by breath.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Tell him it comes with time**: You tell him it comes with time. It's true, and it isn't much help.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 24. PRO_397 The New Contract Negotiation
*career; premise 27 words*

> Your agent wants a longer deal, four years with guarantees, and the club wants a shorter one, two years and incentives. They've been stuck for three weeks.

1. **Take the shorter deal** (23 words)
   Two years, and you bet on yourself. Your agent grumbles, the club is relieved, and you feel lighter than you have in weeks.
   <sub>resilience +1; ambition +2; skill_points +1; mods confident</sub>

2. **Fight for the longer deal** (22 words)
   Four years, and you fight for them: a month of calls, a lot of silence. You get three, and some sleepless nights.
   <sub>energy -2; leadership +1; intelligence +1; mods stressed</sub>

3. **Talk to the club yourself** (22 words)
   The general manager, called directly, to meet in the middle. Three years, fair guarantees, and an agent who sulks for a week.
   <sub>social +1; charisma +2; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> Your agent wants a longer deal, and the club wants a shorter one.

1. **Take the shorter deal**: You take the shorter deal and bet on yourself.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Fight for the longer one**: You fight for the longer one. It takes a month.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Talk to the club yourself**: You talk to the club yourself. You meet in the middle.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 25. PRO_398 The Media Debate
*media; premise 26 words*

> On a sports show, two analysts spend ten minutes arguing about whether you're still among the best kickers in the league. Your phone fills with clips.

1. **Use it** (25 words)
   You watch it once and put the losing argument on a card in your locker. Every practice that week, you kick like you're answering it.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ignore it** (25 words)
   You turn off the television and leave your phone in the car during practice. By Thursday the debate has moved on, and so have you.
   <sub>resilience +2; intelligence +1; mods focused</sub>

3. **Do impressions with the unit** (24 words)
   You laugh about it with the specialists, who do impressions of both analysts all week. It's the loosest the unit has been all year.
   <sub>social +2; fun +2; rel holder +2; rel team +1; mods loose</sub>

<details><summary>Before</summary>

> On a sports show, two analysts spend ten minutes arguing about whether you're still among the best kickers in the league. Your phone fills with clips.

1. **Use it**: You watch it once and put the losing argument on a card in your locker. Every practice that week, you kick like you're answering it.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ignore it**: You turn off the television and leave your phone in the car during practice. By Thursday the debate has moved on, and so have you.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Laugh about it**: You laugh about it with the specialists, who do impressions of both analysts all week. It's the loosest the unit has been all year.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 26. PRO_399 The Community Commitment
*community; premise 32 words*

> A local charity wants you as its face, year-round: the posters, the hospital visits, the winter coat drive, a fun run in your name. It's a real commitment, and a real honor.

1. **Commit** (24 words)
   The full year, committed. It's a lot of evenings, and the coat drive breaks the city's record, and you shake hands with every volunteer.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; followers +2; skill_points +1; mods inspired</sub>

2. **Bring teammates** (23 words)
   You bring teammates so the work is shared. It becomes a team tradition, and the young players start signing up on their own.
   <sub>social +2; fun +1; rel team +2; mods loose</sub>

3. **Do the big events** (25 words)
   The big events only: the gala and the coat drive. It helps, and you can tell from the director's face that she hoped for more.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A local charity wants you as its face, year-round: the posters, the hospital visits, the winter coat drive. It's a real commitment.

1. **Commit**: You commit to the full year. It's a lot of evenings, and the coat drive breaks the city's record.
   <sub>energy -2; social +1; leadership +2; rel team +2; followers +2; skill_points +1; mods inspired</sub>

2. **Bring teammates**: You bring teammates so the work is shared. It becomes a team tradition, and the young players start signing up on their own.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Do the big events**: You do the big events only. It helps, and you can tell the charity hoped for more.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 27. PRO_400 The Expensive Lifestyle
*money; premise 30 words*

> Your household's expenses have quietly doubled in two years: a second car, a bigger house, three subscriptions to things nobody watches, and a gardener for a garden you never visit.

1. **Cut back together** (20 words)
   An evening with the statements and a highlighter. Some things go, and nobody misses them, and the household feels lighter.
   <sub>intelligence +2; leadership +1; mods focused</sub>

2. **Make a plan at home** (26 words)
   The plan, made at home, out loud, with everyone in the house. It's an awkward talk and a relief, and the budget goes on the fridge.
   <sub>social +2; resilience +1; rel parent +1; mods loose</sub>

3. **Let it ride for now** (22 words)
   Later, you'll deal with it later. The statements keep coming, a little bigger each month, and you stop opening them on Mondays.
   <sub>energy +2; fun +1; mods distracted</sub>

<details><summary>Before</summary>

> Your household's expenses have quietly doubled.

1. **Cut back**: You sit down and cut back. Some things go, and nobody misses them.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Talk to {love_interest}**: You talk to {love_interest}. You make a plan together.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Let it ride**: You let it ride. You'll deal with it later.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 28. PRO_401 The Advisor's Concern
*money; premise 31 words*

> Your financial advisor slides one line of your statement across the table and asks, carefully, whether you still want to be in it. It's the investment a teammate talked you into.

1. **Listen and adjust** (26 words)
   You listen, ask the questions you skipped the first time, and move most of the money out. It costs you a little, and you sleep better.
   <sub>resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Get a second opinion** (25 words)
   You show it to someone you trust before deciding. They read it twice, sigh, and explain the part you didn't understand. You get out together.
   <sub>social +1; intelligence +1; charisma +1; rel parent +3; mods loose</sub>

3. **Keep it** (25 words)
   It stays in your portfolio. You like the idea and the teammate, and you tell yourself the advisor is being careful. The statements keep arriving.
   <sub>energy +1; fun +2; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> Your financial advisor slides one line of your statement across the table and asks, carefully, whether you still want to be in it. It's the investment a teammate talked you into.

1. **Listen and adjust**: You listen, ask the questions you skipped the first time, and move most of the money out. It costs you a little, and you sleep better.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Get a second opinion**: You show it to someone you trust before deciding. They read it twice, sigh, and explain the part you didn't understand. You get out together.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Keep it**: You keep it. You like the idea and the teammate, and you tell yourself the advisor is just being careful. The statement keeps arriving.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_402 The Team Rebuild
*career; premise 27 words*

> The club has started replacing veterans with younger, cheaper players. Every week another familiar locker is cleared out, and you've started counting the ones that are left.

1. **Stay ahead** (22 words)
   You get ahead of the clock: earlier mornings, cleaner numbers. If they want to replace you, they'll have to find someone better.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help the young players** (24 words)
   You help the young players learn the job. It's the right thing, and it makes you the veteran the club can't afford to lose.
   <sub>energy -2; leadership +3; rel backup +2; rel team +1; skill_points +1; mods inspired</sub>

3. **Talk to your agent** (25 words)
   An honest talk with your agent about the next two years, at a diner. It's a hard conversation, and a relief to finally have it.
   <sub>social +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> The club has started replacing veterans with younger, cheaper players. Every week another familiar locker is cleared out, and you've started counting.

1. **Stay ahead**: You get ahead of the clock: earlier mornings, cleaner numbers. If they want to replace you, they'll have to find someone better.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help the young players**: You help the young players learn the job. It's the right thing, and it makes you the veteran the club can't afford to lose.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Talk to your agent**: You sit down with your agent and talk through the next two years honestly. It's a hard conversation, and a relief to have it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 30. PRO_403 The New Special Teams Coach
*training; premise 36 words*

> The new special teams coach stops a drill in front of the whole unit to ask why you still warm up the way you did as a rookie. Everyone is watching to see what you do.

1. **Answer with data** (26 words)
   You bring him three seasons of charts after practice, in his office, with the door closed. He reads every page and changes one drill, not yours.
   <sub>intelligence +2; leadership +1; rel coach +2; mods focused</sub>

2. **Answer with work** (23 words)
   You say nothing and out-work everyone for a week. He stops asking in public, though you can tell the question is still there.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Talk to him alone** (28 words)
   You ask for ten minutes alone and tell him what the routine is for. He listens, and the next morning he warms up the young kicker your way.
   <sub>social +2; charisma +1; rel coach +2; mods loose</sub>

<details><summary>Before</summary>

> The new special teams coach stops a drill in front of the whole unit to ask why you still warm up the way you did as a rookie. Everyone is watching to see what you do.

1. **Answer with data**: You bring him three seasons of charts after practice, in his office, with the door closed. He reads every page and changes one drill, not yours.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Answer with work**: You say nothing and out-work everyone for a week. He stops asking in public, though you can tell the question is still there.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Talk to him alone**: You ask for ten minutes alone and tell him what the routine is for. He listens, and the next morning he warms up the young kicker your way.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 31. PRO_404 The Mentor's Retirement
*team; premise 31 words*

> The special teams coach who rebuilt your swing in your second season is stepping away at the end of the year. He hasn't told the room yet; he told you first.

1. **Thank him** (31 words)
   You drive to his house on a Tuesday and thank him in his kitchen. He waves it off, then walks you to the car and doesn't let go of the handshake.
   <sub>social +2; resilience +1; rel coach +2; mods loose</sub>

2. **Organize a send-off** (30 words)
   You call every kicker and punter he ever coached. Eleven of them show up for his last practice, and he has to turn around to the fence for a minute.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

3. **Leave a note** (29 words)
   You write him a note and leave it in his playbook. He never mentions it, but on his last day it's the only thing he takes from the desk.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> The special teams coach who rebuilt your swing in your second season is stepping away at the end of the year. He hasn't told the room yet; he told you first.

1. **Thank him**: You drive to his house on a Tuesday and thank him in his kitchen. He waves it off, then walks you to the car and doesn't let go of the handshake.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Organize a send-off**: You call every kicker and punter he ever coached. Eleven of them show up for his last practice, and he has to turn around to the fence for a minute.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Leave a note**: You write him a note and leave it in his playbook. He never mentions it, but on his last day it's the only thing he takes from the desk.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 32. PRO_405 The Old Rival
*social; premise 32 words*

> A kicker you competed against for years, the one who beat you for a job early on, reaches out of nowhere. He's out of football now, and he wants to have coffee.

1. **Meet for coffee** (23 words)
   Coffee, then lunch, then three hours. It's warmer than you expected, and you both admit you used to watch each other's every kick.
   <sub>social +2; fun +1; rel rival +2; mods loose</sub>

2. **Ask what he needs** (20 words)
   What does he need? It's advice, about life after football, and you give it honestly, and he writes everything down.
   <sub>intelligence +1; leadership +2; mods focused</sub>

3. **Reply politely** (20 words)
   A polite reply, warm and short. You leave it there, and you think about the old job battle all week.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A competitor from years ago reaches out out of nowhere.

1. **Meet for lunch**: You meet for lunch. It's warmer than you expected.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Ask what he needs**: You ask what he needs. It's advice, and you give it.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Reply politely**: You reply politely and leave it there.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 33. PRO_407 The College Invitation
*community; premise 29 words*

> A university you never played for invites you to speak to its football program. The head coach says the kickers have been asking for you by name all spring.

1. **Speak to the team** (27 words)
   You give the team a short talk about failing in front of people. The kickers stay after and ask questions until the groundskeeper turns off the lights.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired</sub>

2. **Spend the day** (24 words)
   You spend the whole day: meetings, lunch, practice. By the end, a freshman kicker who barely spoke at breakfast is showing you his notebook.
   <sub>social +2; fun +1; rel backup +1; mods loose</sub>

3. **Send a video** (25 words)
   A video message, recorded in your kitchen and sent with a signed ball. It's thoughtful and it plays well, and the kickers watch it twice.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A university you never played for invites you to speak to its football program. The head coach says the kickers have been asking for you by name all spring.

1. **Speak to the team**: You give the team a short talk about failing in front of people. The kickers stay after and ask questions until the groundskeeper turns off the lights.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Spend the day**: You spend the whole day: meetings, lunch, practice. By the end, a freshman kicker who barely spoke at breakfast is showing you his notebook.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Send a video**: You send a video instead. It's thoughtful and it plays well, and you see later that the kickers watched it twice.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 34. PRO_408 The Team's Direction
*media; premise 28 words*

> You're not sure the franchise is going in the right direction, and a respected columnist asks you about it on the record, with a recorder on the table.

1. **Say something careful** (25 words)
   Something careful and true, with no names. Fans respect it; the front office notices, and the general manager calls you in for a long talk.
   <sub>energy -1; intelligence +2; rel coach -1; followers +2; skill_points +1; mods focused</sub>

2. **Back the club** (21 words)
   The club, backed publicly and fully. The front office is grateful, and you're not entirely sure you believe what you said.
   <sub>social +2; charisma +1; rel coach +1; retention +1; mods loose</sub>

3. **Say it to the club** (23 words)
   To the club, not to the columnist: your concerns, in the general manager's office the next morning. They listen, and one thing changes.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> You're not sure the franchise is going in the right direction, and someone asks you on the record.

1. **Say something careful**: You say something careful and true. Fans respect it; the front office notices.
   <sub>energy -1; intelligence +2; rel coach -1; followers +2; skill_points +1; mods focused</sub>

2. **Back the club**: You back the club publicly.
   <sub>social +2; charisma +1; rel coach +1; retention +1; mods loose</sub>

3. **Say it to the club**: You say it to the club, not the reporter.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 35. PRO_410 The Injury Prevention Debate
*health; premise 30 words*

> You and a trainer disagree about your recovery routine: they want more rest days; you want more work. It's turned into an argument in front of the whole training room.

1. **Compare the numbers** (23 words)
   Both of you bring numbers to a meeting. The routine you end up with is better than either plan, and you shake hands.
   <sub>health +1; intelligence +2; leadership +1; rel coach +1; mods focused</sub>

2. **Do it your way** (20 words)
   Your way, with more work. Your leg holds, and the trainer stays unconvinced and writes it down in your file.
   <sub>energy -2; toughness +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Trust the trainer this time** (22 words)
   The trainer's way, this time, without arguing at all. They notice the trust, and your body thanks you for it by November.
   <sub>energy +2; health +2; rel coach +1; mods rested</sub>

<details><summary>Before</summary>

> You and a trainer disagree about your recovery routine.

1. **Compare the numbers**: You both bring numbers. The routine you end up with is better than either.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Do it your way**: You do it your way. Your leg holds, and the trainer stays unconvinced.
   <sub>energy -2; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Trust the trainer**: You trust the trainer this time. They notice.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 36. PRO_411 The Veteran's Committee
*team; premise 27 words*

> Teammates ask you to represent them in a hard conversation with the coaches: practices are too long, the young players are exhausted, and two have been hurt.

1. **Speak for them** (26 words)
   Their case, made calmly and clearly by you in the coaches' office. The coaches change one thing, the practice length, and the room notices who asked.
   <sub>energy -2; leadership +3; rel team +3; skill_points +1; mods inspired</sub>

2. **Bring a proposal** (22 words)
   A proposal, not a complaint: a new practice schedule with the same work in less time. The coaches adopt half of it.
   <sub>intelligence +2; leadership +1; rel coach +2; mods focused</sub>

3. **Suggest a captain** (20 words)
   A captain should do it, you suggest. One does, less well, and the young players stop asking you for things.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Teammates ask you to represent them in a hard conversation with the coaches.

1. **Speak for them**: You speak for them, calmly and clearly. The coaches change one thing.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring a proposal**: You bring a proposal, not a complaint. It works better.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Suggest a captain**: You suggest a captain do it instead.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 37. PRO_412 The Charity Board
*community; premise 26 words*

> A children's nonprofit you've supported for years invites you to join its board. The meetings are monthly, the budget is tight, and the work is real.

1. **Join and work** (22 words)
   You join and actually work: budgets, hiring, a summer program. The meetings run long, and you've never been prouder of a spreadsheet.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Join as an adviser** (26 words)
   You join as an adviser, with a seat at four meetings a year. You help where a famous name helps and stay out of the rest.
   <sub>intelligence +2; charisma +1; mods focused</sub>

3. **Stay a donor** (23 words)
   A polite no to the board, and a generous donation with a long letter. They read the letter aloud at their next meeting.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A children's nonprofit you've supported for years invites you to join its board. The meetings are monthly, and the work is real.

1. **Join and work**: You join and actually work: budgets, hiring, a summer program. The meetings run long, and you've never been prouder of a spreadsheet.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Join as an adviser**: You join as an adviser, with a seat at four meetings a year. You help where a famous name helps and stay out of the rest.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Decline**: You decline politely and send a donation with a long letter. They read the letter at their next meeting.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 38. PRO_414 Everyone Wants You There
*family; premise 28 words*

> Your family wants you at more events than you can make: a cousin's wedding, a niece's recital, {parent}'s retirement party, a reunion. All of them are in October.

1. **Pick the ones that matter most** (22 words)
   The ones that matter most, chosen carefully: {parent}'s party and the recital. You make every one, and nobody asks about the rest.
   <sub>social +2; intelligence +1; rel parent +4; mods inspired</sub>

2. **Share your calendar** (20 words)
   Your whole calendar, shared with the family. The arguments get shorter, and the cousin moves the wedding by a week.
   <sub>intelligence +2; leadership +1; rel sibling +1; mods focused</sub>

3. **Promise the offseason** (20 words)
   The offseason, promised to everyone, and kept. It's a long wait, and the family photos from October are missing you.
   <sub>energy +1; ambition +2; rel parent -1; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Your family wants you at more events than you can make.

1. **Pick the important ones**: You pick the ones that matter most and make every one.
   <sub>social +2; charisma +1; rel parent +4; mods loose</sub>

2. **Share the calendar**: You share your calendar with everyone. The arguments get shorter.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Promise the offseason**: You promise the offseason and keep it.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 39. PRO_415 The New Contract Structure
*career; premise 26 words*

> The club offers a shorter deal with incentives you're not sure you'll hit: percentages, long kicks, playoff games. Your agent calls it 'a bet on you'.

1. **Sign and chase them** (22 words)
   Signed, and every incentive goes on the inside of your locker. You chase them all season, and you hit two of three.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Negotiate the incentives down** (21 words)
   The incentives, renegotiated to numbers you can actually hit. It takes a week, and the club agrees because you asked nicely.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Ask {holder} what they think** (24 words)
   {holder}, who has watched every one of your kicks, says 'Sign it' without hesitation. You do, and you feel calm about it all season.
   <sub>social +2; resilience +1; rel holder +3; mods loose</sub>

<details><summary>Before</summary>

> The club offers a shorter deal with incentives you're not sure you'll hit.

1. **Sign and chase them**: You sign and chase every incentive.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Negotiate the incentives**: You negotiate the incentives down to numbers you'll hit.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Ask {holder}**: You ask {holder}, who has seen your whole season. 'Sign it,' they say.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

</details>


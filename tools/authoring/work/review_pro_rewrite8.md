# PRO rewrite pass 8: era-2 scenes 118-150

The last 33 era-2 scenes in play order: the contract-year scenes, partner and family scenes, the captaincy and the veteran-adjacent scenes. Era 2 is now fully rewritten.

Dry run and import: 33 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 33 of 33.**

**Standing costs removed** (routine choices): PRO_041 "Hold out" (-3); PRO_317 "Back him publicly" (-2).

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_368 The Offseason Vacation
*family; premise 33 words*

> {love_interest} wants a real vacation this offseason: two weeks, an island, no phones. You want to train. The brochure has been on the kitchen counter for a month, open to the same page.

1. **Go, and leave the ball home** (29 words)
   Two weeks on the island, no ball, no film, no phone. It's the best fortnight of the year, and you come back rested and in love all over again.
   <sub>fun +3; social +1; energy +2; rel love_interest +5; mods rested</sub>

2. **Stay and train** (23 words)
   Training, alone, while {love_interest} goes with friends and sends pictures of the water every day. You're stronger by July and a little lonelier.
   <sub>energy -2; power +1; ambition +2; rel love_interest -2; skill_points +2; mods dialed_in</sub>

3. **Find an island with a field** (25 words)
   A beach town with a high school field, found after two hours of searching. Mornings for kicking, afternoons for the beach. Everyone wins, sort of.
   <sub>fun +1; energy -1; intelligence +2; leadership +1; rel love_interest +2; mods focused</sub>

<details><summary>Before</summary>

> {love_interest} wants a real vacation; you want to train.

1. **Go on the vacation**: You go, and you don't bring a ball. It's the best week of the year.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Train instead**: You train. {love_interest} goes with friends and sends pictures.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Find a place with a field**: You find a beach town with a high school field. Everyone wins, sort of.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 2. PRO_037 Contract Year: The Payday
*career; premise 34 words*

> This is the contract that could set up your family for life, if you earn it this season. Your agent has a number in mind, and so does the club, and they're far apart.

1. **Make the season undeniable** (23 words)
   Every practice counts, every rep, every film session. Nothing about this season will be an accident, and you're exhausted and proud by December.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Let your agent do the talking** (25 words)
   Every contract conversation goes to your agent, and you keep your head on kicking. It works, mostly, though you check your phone after every practice.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Talk it through at home** (23 words)
   A long evening at home, talking it through. Their calm becomes your calm, and you sleep better for the rest of the season.
   <sub>social +2; fun +1; rel parent +3; mods loose</sub>

<details><summary>Before</summary>

> This is the contract that sets up your family for life, if you earn it this season.

1. **Make the season undeniable**: You make every practice count. Nothing about this season will be an accident.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Let your agent work**: You let your agent handle every conversation and keep your head on kicking.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Talk it through at home**: You talk it through with your family. Their calm becomes your calm.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

</details>

## 3. PRO_040 The Hometown Discount
*money; premise 33 words*

> The club offers less than the market and asks you to take it because 'you're family here'. The general manager says it twice, and puts his hand on your shoulder the second time.

1. **Take the discount** (24 words)
   The discount, accepted. The club remembers it, and so does the locker room, and you never quite know if it was generous or foolish.
   <sub>social +2; charisma +1; leadership +1; rel team +2; retention +2; mods loose</sub>

2. **Meet in the middle** (29 words)
   The middle ground, found by your agent over two weeks of calls. Everyone is a little unhappy and fine, which your agent says is how you know it's fair.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Test the market next spring** (23 words)
   Next spring's open market, it is. You kick like it all year, and every practice feels like an audition for twenty-nine other clubs.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> The club offers less than the market and asks you to take it because you're family here.

1. **Take the discount**: You accept the discount. The club remembers, and so does the locker room.
   <sub>social +2; charisma +1; rel team +3; retention +2; mods loose</sub>

2. **Meet in the middle**: You ask your agent to find the middle. It takes two weeks, and everyone is a little unhappy and fine.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Test the market**: You decide to test the market next spring and kick like it all year.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 4. PRO_041 The Holdout Talk
*career; premise 45 words*

> Your agent slides the club's offer across a restaurant table: less than a kicker in your division got last spring, with a pay cut in year two. 'We hold out,' your agent says. 'You stay home from camp until they pay you what you're worth.'

1. **Sign it and say why** (40 words)
   You sign, then tell your agent you'd rather kick for a fair number than sit at home waiting for a better one. Your agent calls it leaving money on the table. {coach} calls it the best news of the week.
   <sub>ambition -1; leadership +1; rel coach +3; retention +2; mods confident</sub>

2. **Hold out** (38 words)
   You stay home when camp opens. The club fines you every day, talk radio calls you greedy, and two weeks later you sign for a little more and walk into a locker room that moved on without you.
   <sub>fun +1; ambition +2; rel coach -5; rel team -3; followers -2; mods stressed</sub>

3. **Call the general manager yourself** (25 words)
   You call the general manager directly, which agents hate. You get a better guarantee in year two and an agent who sulks for a month.
   <sub>energy -1; intelligence +1; charisma +1; rel coach +1; retention +1; mods focused</sub>

4. **Ask for the honest read** *(locked: having hired an agent who tells you the truth)* (30 words)
   The agent you hired for honesty admits the offer is fair for a kicker and a holdout would cost more than it gains. You sign, and you don't regret it.
   <sub>energy -1; intelligence +1; ambition -1; rel coach +2; retention +2; mods confident</sub>

<details><summary>Before</summary>

> Your agent slides the club's offer across a restaurant table: less than a kicker in your division got last spring, with a pay cut in year two. 'We hold out,' your agent says. 'You stay home from camp until they pay you what you're worth.'

1. **Sign it and say why**: You sign, then tell your agent you'd rather kick for a fair number than sit at home waiting for a better one. Your agent calls it leaving money on the table. {coach} calls it the best news of the week.
   <sub>ambition -1; leadership +1; rel coach +3; retention +2; mods confident</sub>

2. **Hold out**: You stay home when camp opens. The club fines you every day, talk radio calls you greedy, and two weeks later you sign for a little more and walk into a locker room that moved on without you.
   <sub>fun +1; ambition +2; rel coach -5; rel team -3; retention -3; followers -2; mods stressed</sub>

3. **Call the general manager yourself**: You call the general manager directly, which agents hate. You get a better guarantee in year two and an agent who sulks for a month.
   <sub>energy -1; intelligence +1; charisma +1; rel coach +1; retention +1; mods focused</sub>

4. **Ask for the honest read**: The agent you hired for honesty admits the offer is fair for a kicker and a holdout would cost more than it gains. You sign, and you don't regret it.
   <sub>energy -1; intelligence +1; ambition -1; rel coach +2; retention +2; mods confident</sub>

</details>

## 5. PRO_077 First Day of School
*family; premise 30 words*

> Your kid's first day of school falls on a Thursday practice day. The backpack has been packed since Sunday, and there's a photo planned by the front door at seven-thirty.

1. **Ask to come in late** (23 words)
   An hour's grace from {coach}, granted without a pause. You're there for the photo, the backpack, and the wave at the classroom door.
   <sub>social +2; fun +2; rel love_interest +4; mods inspired</sub>

2. **Go to practice and watch the video** (23 words)
   Practice, and a video from home at lunch. You watch it four times in the locker room, and {holder} watches it with you.
   <sub>energy -1; ambition +2; rel holder +1; skill_points +1; mods dialed_in</sub>

3. **Plan the whole morning** (21 words)
   The morning, planned to the minute with {coach} and the family: drop-off at seven-forty, meeting at eight-fifteen. You make both, barely.
   <sub>energy -1; intelligence +2; leadership +1; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> Your kid's first day of school is a Thursday practice.

1. **Ask to come in late**: You ask {coach} to come in an hour late. You're there for the first wave goodbye.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Go to practice**: You go to practice and get a video. You watch it four times at lunch.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Plan around it**: You plan the morning with the coach and your partner. You make the drop-off and the meeting.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 6. PRO_091 The Snapper Retires
*team; premise 28 words*

> The long snapper you've trusted for years is done: his back, his age, his wife's patience. He asks you, of all people, to speak at his farewell dinner.

1. **Speak from the heart** (22 words)
   What it's like to trust someone without ever looking back: you tell the room. He cries first, and then everyone else does.
   <sub>social +2; charisma +2; rel team +3; mods inspired</sub>

2. **Keep it light and true** (24 words)
   Three funny stories and one true one. The room loves it, and he asks for a copy of the speech to show his kids.
   <sub>fun +2; intelligence +1; charisma +1; rel team +1; mods loose</sub>

3. **Say a few words** (27 words)
   A few short words and a raised glass of water. He hugs you anyway, hard, and says it was perfect, and his wife writes you a note.
   <sub>energy +1; resilience +1; rel team +1; mods rested</sub>

<details><summary>Before</summary>

> The long snapper you've trusted for years is done, and he asks you to speak at his farewell.

1. **Speak from the heart**: You tell the room what it's like to trust someone without ever looking. He cries first.
   <sub>social +2; charisma +1; rel team +2; mods loose</sub>

2. **Keep it light**: You tell three funny stories and one true one. The room loves it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Say a few words**: You say a few words and raise a glass of water. He hugs you anyway.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 7. PRO_107 The Podcast
*media; premise 30 words*

> A popular podcast wants you for a full hour. The host is famous for getting athletes to say too much, and three of your teammates have already regretted going on.

1. **Prepare and stay disciplined** (21 words)
   Prepared, disciplined, and still funny. It's a good episode with no headlines, and the host admits you were a hard interview.
   <sub>resilience +1; intelligence +2; followers +2; mods focused</sub>

2. **Be yourself on air** (23 words)
   Funny and honest for an hour, until one joke about a teammate gets clipped everywhere. You apologize to him before he hears it.
   <sub>social +2; fun +1; charisma +2; rel team -1; followers +5; mods spotlight</sub>

3. **Turn the podcast down** (21 words)
   No, politely. The host says something snide about kickers on the next episode, and your teammates send it to you, delighted.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A popular podcast wants you for an hour. The host is known for getting athletes to say too much.

1. **Prepare and stay disciplined**: You prepare and stay disciplined. It's a good episode with no headlines.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

2. **Be yourself**: You're funny and honest. One joke about a teammate gets clipped everywhere.
   <sub>social +2; charisma +1; rel team -1; followers +5; mods loose</sub>

3. **Decline**: You decline. The host says something snide about kickers on the next episode.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 8. PRO_110 The National Deal
*media; premise 30 words*

> A national brand wants you for a commercial that would air during every game this year: you, a ball, and a talking dog. The shoot is during your bye week.

1. **Sign on for the commercial** (25 words)
   Signed. You're on every broadcast all season, the talking dog becomes famous, and the shoot eats your entire bye week, which you never get back.
   <sub>energy -2; fun +1; charisma +2; followers +6; mods spotlight</sub>

2. **Shoot it in the offseason** (23 words)
   The offseason, or nothing, you tell them politely. They agree, the dog waits, and your bye week stays your own, with your family.
   <sub>intelligence +2; leadership +1; followers +4; mods focused</sub>

3. **Pass on it** (24 words)
   No commercial this year. You'd rather be known for kicking than for the dog, and a punter gets the part instead and loves it.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A national brand wants you for a commercial that would play during every game this year.

1. **Take it**: You sign on. You're everywhere, and the shoot eats your bye week.
   <sub>energy -2; resilience +1; ambition +2; followers +6; skill_points +2; mods dialed_in</sub>

2. **Negotiate the schedule**: You agree if they shoot in the offseason. They do.
   <sub>energy -1; resilience +1; intelligence +2; followers +4; mods focused</sub>

3. **Pass**: You pass. You'd rather be known for kicking.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 9. PRO_196 A New City, Mid-Career
*team; premise 31 words*

> A new club, a new town, and a locker room that has already decided whether you're a mercenary. The last kicker was popular, and his photo is still on the wall.

1. **Win the room** (22 words)
   Every name learned, every team meal attended, every question asked. By midseason the room is yours, and the old photo comes down.
   <sub>social +3; charisma +1; rel team +3; mods loose</sub>

2. **Let the work talk** (23 words)
   Few words and a great many kicks. The room comes around by October, slowly and completely, and nobody mentions the old photo again.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Help the young specialists** (23 words)
   The young specialists get your help from day one: rides, film, advice. They become your biggest supporters, and the room follows their lead.
   <sub>energy -2; leadership +3; rel backup +2; rel holder +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> A new club, a new town, and a locker room that has already decided whether you're a mercenary.

1. **Win the room**: You learn every name, show up to every team meal and win the room by midseason.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Let the work talk**: You say little and kick a lot. The room comes around.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Help the young players**: You help the young specialists from day one. They become your biggest supporters.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 10. PRO_364 The Public Relationship
*family; premise 30 words*

> Your relationship becomes a topic of public interest after a photo goes around, and {love_interest} didn't sign up for that. There are strangers in the comments of their private account.

1. **Protect {love_interest}** (26 words)
   Nothing about home, posted ever again, not even a photo of the dog. {love_interest} notices, and is quietly grateful, and the strangers lose interest by spring.
   <sub>social +1; resilience +1; rel love_interest +5; followers -2; mods focused</sub>

2. **Set boundaries together** (23 words)
   What stays private and what doesn't: decided together, at the kitchen table, with a list. It feels like a team, which it is.
   <sub>intelligence +2; leadership +1; rel love_interest +3; mods focused</sub>

3. **Let it blow over** (20 words)
   It'll blow over, you decide. It takes much longer than you thought, and {love_interest} deletes the account without telling you.
   <sub>energy +1; fun +1; rel love_interest -2; mods distracted</sub>

<details><summary>Before</summary>

> Your relationship becomes a topic of public interest, and {love_interest} didn't sign up for that.

1. **Protect {love_interest}**: You stop posting about home entirely. {love_interest} notices and is grateful.
   <sub>social +2; charisma +1; rel love_interest +5; followers -2; mods loose</sub>

2. **Set boundaries together**: You agree together on what stays private and what doesn't.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Let it blow over**: You let it blow over. It takes longer than you thought.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 11. PRO_372 The Family Conversation
*family; premise 30 words*

> You and {love_interest} start talking about starting a family, late at night, and neither of you knows the right time. The schedule, the contract, the next city: everything feels uncertain.

1. **Decide on now** (20 words)
   Now, you both say, at almost the same moment. It's terrifying and right, and you laugh for ten minutes afterward.
   <sub>social +2; fun +2; rel love_interest +5; mods inspired</sub>

2. **Plan around the seasons** (22 words)
   A plan, built around the contract and the seasons: when, where, who helps. It's sensible, and it makes the dream feel real.
   <sub>intelligence +2; leadership +1; rel love_interest +2; mods focused</sub>

3. **Agree to wait** (23 words)
   Waiting, for now, you both agree. The conversation comes back every few months, a little more urgent each time, and a little warmer.
   <sub>energy +1; resilience +1; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> You and {love_interest} talk about starting a family, and neither of you knows the right time.

1. **Say now**: You both say now. It's terrifying and right.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Make a plan**: You make a plan around the contract and the seasons.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Wait**: You agree to wait. The conversation comes back every few months.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_380 The Sponsored Posts
*media; premise 26 words*

> A supplement-free sports drink company offers to pay you for sponsored posts. The product is fine, mostly, and the contract has a clause about 'authentic enthusiasm'.

1. **Take the deal** (21 words)
   The deal, signed. The posts do well, the money is real, and the 'authentic enthusiasm' feels a little hollow every time.
   <sub>fun +1; ambition +2; followers +3; mods spotlight</sub>

2. **Test it for a month** (20 words)
   A month of actually drinking it before you post a word. It's genuinely good, and your posts say so honestly.
   <sub>health +1; intelligence +2; followers +2; mods focused</sub>

3. **Keep your page yours** (20 words)
   No sponsored posts, ever. Your page stays yours, full of your dog, your family and very bad photos of sunsets.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A company offers to pay for sponsored posts, and the product is fine, mostly.

1. **Take the deal**: You take the deal. The posts do well and feel a little hollow.
   <sub>energy -2; resilience +1; ambition +2; followers +3; skill_points +2; mods dialed_in</sub>

2. **Test it first**: You use the product for a month before you post. It's actually good.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Decline**: You decline. Your page stays yours.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 13. PRO_381 The Long-Term Commitment
*family; premise 27 words*

> {love_interest} wants to talk about where you'll live after football. It's a quiet Sunday, and they've made a list of places on the back of an envelope.

1. **Let {love_interest} choose** (22 words)
   Their choice, from the envelope: a town near the coast, near their family. It's the right call, and you both know it.
   <sub>social +2; fun +1; rel love_interest +5; mods loose</sub>

2. **Make the list together** (26 words)
   A list together, with pros and cons in two colors. Your hometown wins by a point, and {parent} cries on the phone when you tell him.
   <sub>intelligence +2; leadership +1; rel love_interest +2; rel parent +2; mods focused</sub>

3. **Say there's still time** (24 words)
   There's still time, you say. {love_interest} says there isn't always, and puts the envelope away in a drawer you both pretend not to see.
   <sub>energy +1; ambition +1; rel love_interest -2; mods distracted</sub>

<details><summary>Before</summary>

> {love_interest} wants to talk about where you'll live after football.

1. **Let {love_interest} choose**: You let {love_interest} choose. It's the right call.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Make a list together**: You make a list together. Your hometown wins.
   <sub>energy -1; resilience +1; intelligence +2; rel parent +1; mods focused</sub>

3. **Not yet**: You say there's time. {love_interest} says there isn't always.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 14. PRO_636 The Pregnancy
*family; premise 26 words*

> {love_interest} is pregnant, and the due date falls right in the middle of the season. You're thrilled, terrified, and already counting weeks on the team schedule.

1. **Plan to be there** (26 words)
   You tell {coach} now that you'll miss a game if the baby comes on a Sunday. The coach says it's the right call and means it.
   <sub>social +2; fun +1; rel love_interest +6; rel coach +1; mods loose</sub>

2. **Make a plan with everyone** (26 words)
   You make a plan with {love_interest}, the coach and both families: who's on call, which flights, which bags. It feels like a playbook, and it helps.
   <sub>intelligence +2; leadership +1; rel love_interest +2; rel parent +1; mods focused</sub>

3. **Hope for the bye week** (25 words)
   You hope the baby comes in the bye week. You also keep a bag packed in the car and check your phone at every break.
   <sub>energy -1; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> {love_interest} is pregnant, and the due date falls right in the middle of the season. You're thrilled, and already counting weeks on the schedule.

1. **Plan to be there**: You tell {coach} now that you'll miss a game if the baby comes on a Sunday. The coach says it's the right call and means it.
   <sub>social +2; charisma +1; rel love_interest +6; mods loose</sub>

2. **Make a plan with everyone**: You make a plan with {love_interest}, the coach and both families: who's on call, which flights, which bags. It feels like a playbook, and it helps.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Hope for the bye week**: You hope the baby comes in the bye week. You also keep a bag packed in the car and check your phone at every break.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 15. PRO_637 The Baby's First Year
*family; premise 30 words*

> Sleepless nights with a newborn, in the middle of the season. The baby wakes at two and four, practice starts at eight, and you've started falling asleep in film sessions.

1. **Take the night shifts** (24 words)
   The night shifts on your off days, every one. You're tired and closer to {love_interest} and the baby than you've ever been to anyone.
   <sub>social +2; energy -3; rel love_interest +5; mods drained</sub>

2. **Sleep in shifts by schedule** (22 words)
   A sleep schedule, written on the fridge like a practice plan. It works, roughly, and nobody falls asleep in a meeting again.
   <sub>health +1; intelligence +2; rel love_interest +2; mods focused</sub>

3. **Ask the grandparents for help** (20 words)
   The grandparents, invited for a month. Everyone sleeps, the house is loud and full, and {parent} becomes a diaper expert.
   <sub>energy +3; fun +1; rel parent +3; mods rested</sub>

<details><summary>Before</summary>

> Sleepless nights with a newborn during the season.

1. **Take the night shifts**: You take the night shifts on off days. You're tired and close.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Sleep in shifts**: You and {love_interest} sleep in shifts by the schedule. It works, roughly.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Ask for help**: You ask the grandparents to come for a month. Everyone sleeps.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_638 The Daycare
*family; premise 30 words*

> Finding daycare in a city where you might not live next year. Every good place has a waiting list, and every waiting list asks how long you'll be in town.

1. **Visit every place** (25 words)
   Six daycares, visited in one week, with a notebook. You pick the best one and get on the list by being honest about the contract.
   <sub>energy -1; intelligence +2; leadership +1; mods focused</sub>

2. **Ask the team families** (23 words)
   The other team families, asked at the next game. They have a list, a group chat and a spot opening up in March.
   <sub>social +2; charisma +1; rel team +2; mods loose</sub>

3. **Hire a nanny for the season** (21 words)
   A nanny for the season, and a decision later. It's expensive and easy, and the baby adores her within a week.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Finding daycare in a city where you might not live next year.

1. **Do the research**: You visit six places and pick the best one.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Ask the team families**: You ask the other team families. They have a list and a group chat.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Hire a nanny for now**: You hire a nanny for the season and decide later.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 17. PRO_639 The In-Laws
*family; premise 30 words*

> {love_interest}'s family visits for two weeks during the season: parents, a grandmother, and a brother-in-law who is certain that kicking is easy and has a lot of advice about it.

1. **Be the perfect host** (20 words)
   Every evening at home with them: dinners, card games, the grandmother's long stories. {love_interest} notices, and so does the grandmother.
   <sub>social +2; energy -1; charisma +1; rel love_interest +5; mods loose</sub>

2. **Keep your routine** (22 words)
   Your routine, unchanged, and you see them at dinner every night. It's polite and a little distant, and {love_interest} doesn't say anything.
   <sub>energy +1; ambition +2; rel love_interest -1; skill_points +1; mods dialed_in</sub>

3. **Plan their days** (24 words)
   Their days, planned by you: the museum, the stadium tour, a lake. Everyone has something to do, and the brother-in-law gets a practice pass.
   <sub>intelligence +2; leadership +1; rel love_interest +2; mods focused</sub>

<details><summary>Before</summary>

> {love_interest}'s family visits for two weeks during the season.

1. **Be the host**: You make them feel welcome every evening. {love_interest} notices.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Keep your routine**: You keep your routine and see them at dinner.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Plan their days**: You plan their days so everyone has something to do.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 18. PRO_640 The Kicking Video Series
*media; premise 28 words*

> You start a video series teaching kids how to kick, filmed in your backyard on a phone. The first episode has more views than your team's highlight reel.

1. **Make it really good** (20 words)
   Real drills, real mistakes, real fixes, and a lot of editing late at night. Coaches start using it in practice.
   <sub>energy -2; leadership +2; intelligence +1; followers +4; mods inspired</sub>

2. **Bring {holder} in** (23 words)
   {holder}, invited for an episode on holding. It's the most popular one by far, because {holder} is much funnier on camera than you.
   <sub>social +2; fun +2; rel holder +3; followers +3; mods loose</sub>

3. **Keep it simple** (20 words)
   One video a month on your phone, unedited. It's honest and charming, and it never takes more than an hour.
   <sub>energy +2; fun +1; resilience +1; followers +1; mods rested</sub>

<details><summary>Before</summary>

> You start a video series teaching kids how to kick.

1. **Make it good**: You make it good: real drills, real mistakes, real fixes.
   <sub>energy -2; social +1; leadership +2; rel team +2; followers +4; skill_points +1; mods inspired</sub>

2. **Bring in {holder}**: You bring {holder} in for an episode. It's the most popular one.
   <sub>social +2; charisma +1; rel holder +3; followers +3; mods loose</sub>

3. **Keep it simple**: You film one video a month on your phone.
   <sub>energy +2; fun +1; followers +1; mods rested</sub>

</details>

## 19. PRO_666 The Wedding Planning
*family; premise 28 words*

> Wedding planning in the middle of the season, and every decision is a phone call: flowers between meetings, the menu on the team bus, seating charts at midnight.

1. **Take every call** (20 words)
   Every call, even in the minutes between meetings. {love_interest} feels it, and the seating chart is perfect, and you're exhausted.
   <sub>social +2; energy -2; rel love_interest +5; mods drained</sub>

2. **Hire a planner** (24 words)
   A planner, hired, and the big decisions saved for Mondays. It works beautifully, and it costs more than the cake and the flowers combined.
   <sub>resilience +1; intelligence +2; rel love_interest +2; mods focused</sub>

3. **Leave it to {love_interest}** (20 words)
   Most of it, left to {love_interest} until the offseason. They manage it all, and they remember exactly who didn't help.
   <sub>energy +2; ambition +1; rel love_interest -2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Wedding planning during the season, and every decision is a phone call.

1. **Take every call**: You take every call, even between meetings. {love_interest} feels it.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Hire a planner**: You hire a planner and make the big decisions on Mondays.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Leave it to {love_interest}**: You leave most of it to {love_interest} until the offseason.
   <sub>energy -2; ambition +2; rel love_interest -2; skill_points +2; mods dialed_in</sub>

</details>

## 20. PRO_684 The Kicking Net in the Living Room
*family; premise 29 words*

> You set up a kicking net in the living room for winter practice, right in front of the television. {love_interest} has opinions, mostly about the lamp that's already broken.

1. **Move it to the garage** (26 words)
   The net, moved to the garage, with a space heater. Peace returns to the house, the lamp is replaced, and the garage becomes your favorite room.
   <sub>social +1; resilience +1; rel love_interest +4; mods rested</sub>

2. **Negotiate a deal** (22 words)
   A deal: weekdays only, and you hang the paintings that have been leaning on the wall since you moved in. Everyone wins.
   <sub>intelligence +2; charisma +1; rel love_interest +2; mods focused</sub>

3. **Keep the net** (24 words)
   The net stays where it is. Some arguments are worth having, you decide, and you kick very carefully around the brand-new lamp all winter.
   <sub>energy -1; accuracy +1; ambition +2; rel love_interest -2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> You set up a net in the living room, and {love_interest} has opinions.

1. **Move it to the garage**: You move it to the garage. Peace returns.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Make a deal**: You make a deal: weekdays only, and you hang the art.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Keep it**: You keep it. Some arguments are worth having.
   <sub>energy -2; ambition +2; rel love_interest -2; skill_points +2; mods dialed_in</sub>

</details>

## 21. PRO_283 The Hometown Parade
*community; premise 30 words*

> Your hometown throws you a parade after your best season: a fire truck, the high school band, and {parent} in the front car, waving like he's the one who kicked.

1. **Ride with {parent}** (25 words)
   The front car, beside {parent}, waving until your arm hurts. He doesn't stop smiling for the entire route, and neither, in the end, do you.
   <sub>social +2; fun +2; rel parent +5; mods inspired</sub>

2. **Give a speech at the end** (23 words)
   A short speech on the courthouse steps, thanking the town. The high school team cheers loudest, and the kicker asks for your gloves.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

3. **Ride the route and slip away** (22 words)
   The route, a few waves, and then a quiet exit to {parent}'s porch. The town understands; the band plays on without you.
   <sub>energy +2; resilience +1; rel parent +1; mods rested</sub>

<details><summary>Before</summary>

> Your hometown throws you a parade after your best season. {parent} rides in the front car.

1. **Ride with {parent}**: You ride with {parent} and wave until your arm hurts.
   <sub>social +2; charisma +1; rel parent +5; mods loose</sub>

2. **Give a speech**: You give a short speech thanking the town. The high school team cheers loudest.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep it short**: You ride the route and leave early.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 22. PRO_317 A Teammate Holds Out
*team; premise 26 words*

> Your closest teammate is holding out for a new contract and wants you to say something publicly. The front office is watching who stands with him.

1. **Back him publicly** (24 words)
   You back him publicly in front of the cameras. He's grateful for good, and the front office remembers your name in a different way.
   <sub>social +2; charisma +1; leadership +1; rel team +4; rel coach -2; mods loose</sub>

2. **Back him privately** (25 words)
   Privately, at his kitchen table, you say you're with him all the way. He understands why it stays private, and wishes you'd said it louder.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Speak for the room** (25 words)
   You tell reporters the whole team wants him back and leave the money to the people who handle it. Both sides nod, neither is thrilled.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> Your closest teammate is holding out for a new contract and wants you to say something publicly. The front office is watching who stands with him.

1. **Back him publicly**: You back him publicly in front of the cameras. He's grateful for good, and the front office remembers your name in a different way.
   <sub>social +2; charisma +1; rel team +4; retention -2; mods loose</sub>

2. **Back him privately**: You tell him privately you're with him and keep it out of the papers. He understands, and wishes you'd said it louder.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Speak for the room**: You tell reporters the whole team wants him back and leave the money to the people who handle it. Both sides nod, neither is thrilled.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 23. PRO_320 The Prime-Time Game
*media; premise 26 words*

> Your first prime-time game in years, and the national broadcast crew wants an interview at the team hotel the night before. They want a 'human' story.

1. **Tell them a real story** (20 words)
   One good story, about kicking into a fence with {parent}. It runs before kickoff, and {parent} watches it on repeat.
   <sub>social +2; charisma +2; rel parent +2; followers +3; mods loose</sub>

2. **Give them ten minutes** (21 words)
   Ten polite minutes, then bed. The story they run is fine and forgettable, and you sleep well and wake up ready.
   <sub>energy +2; resilience +1; mods focused</sub>

3. **Decline and watch film** (21 words)
   A polite no, and film in your room instead until midnight. The crew talks to the punter, who is absolutely delighted.
   <sub>energy -1; accuracy +1; intelligence +1; mods focused</sub>

<details><summary>Before</summary>

> Your first prime-time game in years, and the broadcast crew wants an interview at the hotel.

1. **Do the interview**: You do the interview and tell one good story. It runs before kickoff.
   <sub>social +2; charisma +1; rel team +1; followers +3; mods loose</sub>

2. **Keep it short**: You give them ten minutes and go to bed early.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Decline politely**: You decline politely and watch film in your room.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 24. PRO_390 The Career Milestone
*career; premise 31 words*

> You reach a career milestone the club makes a big deal about: a graphic on the scoreboard, a ball in a case, and a question about how you want to celebrate.

1. **Celebrate with the specialists** (21 words)
   Dinner with the specialists, on you, at the steakhouse. {holder} gives a speech that is mostly about {holder}, and it's perfect.
   <sub>social +2; fun +2; rel holder +3; mods loose</sub>

2. **Celebrate at home** (21 words)
   The people who knew you before, at home: {parent}, {sibling}, old friends. The ball in the case goes on {parent}'s mantel.
   <sub>energy +1; fun +2; rel parent +2; rel sibling +1; mods rested</sub>

3. **Thank the room one by one** (24 words)
   Every person in the building, thanked one by one: trainers, equipment staff, the snapper, the cafeteria. It takes all day and it's worth it.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> You reach a milestone and have to decide how to celebrate it.

1. **Celebrate with the specialists**: You take the specialists to dinner. {holder} gives a speech.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

2. **Celebrate at home**: You celebrate at home with the people who knew you before.
   <sub>energy +2; fun +1; mods rested</sub>

3. **Thank the room**: You thank the whole room, one by one. It takes a while.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 25. PRO_310 The Big Second Contract
*money; premise 28 words*

> Your agent says this is the contract that matters, the one that sets the rest of your life, and the club agrees, eventually, after a month of silence.

1. **Hold firm for your number** (27 words)
   Three tense weeks of holding firm. You get your number, and lose some sleep getting it, and the general manager doesn't smile at you for a while.
   <sub>energy -2; resilience +1; toughness +1; ambition +2; rel coach -1; mods stressed</sub>

2. **Take the fair deal early** (26 words)
   A fair deal, taken early, and you stop thinking about it entirely. Your agent calls it smart, and means it, and you sleep well all spring.
   <sub>energy +1; intelligence +2; rel coach +1; mods rested</sub>

3. **Decide it at home** (20 words)
   The decision, made at home, at the kitchen table. The number matters less than you thought, and you sign happily.
   <sub>social +2; resilience +1; rel parent +2; mods loose</sub>

<details><summary>Before</summary>

> Your agent says this is the contract that matters, and the club agrees, eventually.

1. **Hold firm**: You hold firm for three tense weeks. You get your number and lose some sleep getting it.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Take the fair deal**: You take a fair deal early and stop thinking about it. Your agent calls it smart, and means it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Ask the family first**: You talk it over at home before you sign. The number matters less than you thought.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 26. PRO_313 The Hometown Charity Game
*community; premise 30 words*

> You organize a charity game in your hometown with players from five clubs: a high school field, a sold-out crowd of four thousand, and a lot of favors called in.

1. **Run every detail yourself** (21 words)
   Every detail, run by you: buses, jerseys, the national anthem singer. It's exhausting, and it raises far more than anyone expected.
   <sub>energy -3; leadership +3; charisma +1; followers +2; mods inspired</sub>

2. **Put {best_friend} in charge** (22 words)
   {best_friend} runs the whole day, with a clipboard and a whistle. It's the most fun either of you has had in years.
   <sub>social +2; fun +2; rel best_friend +4; mods loose</sub>

3. **Hire an organizer** (23 words)
   An event organizer who actually knows what they're doing. It runs perfectly, and it feels a little less like yours on the day.
   <sub>resilience +1; intelligence +2; mods focused</sub>

<details><summary>Before</summary>

> You organize a charity game in your hometown with players from five clubs.

1. **Run it yourself**: You run every detail yourself. It's exhausting and it raises more than anyone expected.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring in {best_friend}**: You put {best_friend} in charge of the day. It's the most fun either of you has had in years.
   <sub>social +2; charisma +1; rel best_friend +4; mods loose</sub>

3. **Hire an organizer**: You hire someone who knows events. It runs perfectly, and it feels a little less like yours.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 27. PRO_309 The Captaincy
*team; premise 32 words*

> The team votes for captains, and for the first time in the club's history a kicker is on the ballot. Your name is written on the whiteboard in the locker room, misspelled.

1. **Ask for the vote** (27 words)
   Why a kicker can lead too: you tell the room in two minutes, plainly. You win by four votes, and they fix the spelling on the whiteboard.
   <sub>energy -1; leadership +3; charisma +1; rel team +2; skill_points +1; mods inspired; flags pro_captain</sub>

2. **Let the room decide** (21 words)
   No campaign at all. The room votes you in anyway, by more, and that means more than any speech would have.
   <sub>social +2; resilience +1; leadership +1; rel team +3; mods loose; flags pro_captain</sub>

3. **Take your name off the ballot** (21 words)
   Your name, erased from the whiteboard by you. A linebacker who wanted it more gets the patch, and thanks you privately.
   <sub>energy +2; intelligence +1; ambition -1; mods rested</sub>

<details><summary>Before</summary>

> The team votes for captains, and for the first time a kicker is on the ballot.

1. **Ask for the vote**: You tell the room why a kicker can lead too. You win by four votes.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags pro_captain</sub>

2. **Let the room decide**: You don't campaign. The room votes you in anyway, and that means more.
   <sub>social +2; charisma +1; rel team +3; mods loose; flags pro_captain</sub>

3. **Take your name off**: You take your name off the ballot. A linebacker who wanted it more gets it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 28. PRO_316 The Kid Who Copies Your Routine
*media; premise 26 words*

> A high school kicker's video goes around the internet: he copies your whole routine, down to the last step and the way you tug your sleeve.

1. **Send him a message and cleats** (20 words)
   A message and a pair of cleats. His video of opening the box gets more views than yours ever did.
   <sub>social +2; fun +1; followers +3; mods loose</sub>

2. **Show him one fix** (22 words)
   A short reply video showing him one thing to fix. Kickers everywhere try it, and his school's coach writes to thank you.
   <sub>energy -1; leadership +2; intelligence +1; mods inspired</sub>

3. **Smile and show {love_interest}** (21 words)
   A smile, and the video shown to {love_interest} over dinner, twice. You don't reply, and you think about it all week.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A high school kicker's video goes around: he copies your routine down to the last step.

1. **Send him a message**: You send him a message and a pair of cleats. His video of opening the box gets more views than yours.
   <sub>social +2; charisma +1; rel team +1; followers +3; mods loose</sub>

2. **Fix one thing**: You post a short reply showing him one thing to fix. Kickers everywhere try it.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Smile and move on**: You smile, show {love_interest} the video and move on.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_318 The Coordinator's Son
*team; premise 28 words*

> The new special teams coordinator's son is a kicker on the practice squad. He's polite, talented, and his father watches every one of his kicks with great interest.

1. **Out-kick him every day** (22 words)
   Better than him every single day of camp. It's awkward and undeniable, and the coordinator starts watching your kicks just as closely.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help the kid** (20 words)
   His plant foot, fixed with your help. The coordinator watches and says nothing, and something between you changes for good.
   <sub>social +1; leadership +2; charisma +1; rel coach +1; rel backup +2; mods inspired</sub>

3. **Ask the coordinator directly** (24 words)
   How exactly is the job decided? You ask him straight, in his office. He respects the question and gives you a fair, specific answer.
   <sub>resilience +1; intelligence +2; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> The new special teams coordinator's son is a kicker on the practice squad.

1. **Out-kick him daily**: You out-kick him every day. It's awkward and undeniable.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help the kid**: You help the kid with his plant foot. The coordinator watches and says nothing, and something changes.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

3. **Ask the coordinator directly**: You ask the coordinator directly how the job is decided. He respects the question.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 30. PRO_312 The Endorsement Renewal
*media; premise 26 words*

> Your biggest sponsor wants to renew, with new conditions: more appearances, more posts, more of you. The contract is twice as long as the first one.

1. **Accept the conditions** (22 words)
   Accepted. The money is good, and your weeks get much shorter, and you start to recognize the sponsor's photographer at your house.
   <sub>energy -2; ambition +2; charisma +1; followers +4; mods tired</sub>

2. **Halve the appearances** (20 words)
   The appearances, negotiated down by half, line by line. They agree, grudgingly, and you keep your Tuesdays and your sanity.
   <sub>intelligence +2; leadership +1; followers +2; mods focused</sub>

3. **Walk away from the renewal** (20 words)
   The renewal, politely declined. You get your Tuesdays back, and your agent finds a smaller, kinder deal within a month.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Your biggest sponsor wants to renew, with new conditions: more appearances, more posts, more of you.

1. **Accept the conditions**: You accept. The money is good, and your weeks get a lot shorter.
   <sub>energy -2; resilience +1; ambition +2; followers +4; skill_points +2; mods dialed_in</sub>

2. **Negotiate fewer appearances**: You negotiate the appearances down by half. They agree, grudgingly.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Walk away**: You walk away. You get your Tuesdays back.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 31. PRO_314 The Rival Club Calls
*career; premise 32 words*

> A rival club's general manager catches you at an awards dinner and makes it very clear, without saying it outright, that they'd pay you a lot more the next time you're free.

1. **Keep it between you and your agent** (24 words)
   Your agent hears every word, and nobody else does. You kick the rest of the season like a player with options, calmly and well.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Tell your own club** (27 words)
   Your own general manager hears about the conversation from you, the next morning. They appreciate it more than they say, and they remember it at contract time.
   <sub>social +1; charisma +1; leadership +1; rel coach +1; retention +2; mods loose</sub>

3. **Forget the conversation** (23 words)
   Forgotten, on purpose, by the time you're home. You kick the season out without thinking about it, and whatever comes in spring, comes.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> A rival club's general manager makes it clear they'd pay more, next time you're free.

1. **Tell your agent, nobody else**: You tell your agent and nobody else. You kick like a player who has options.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Tell your club**: You tell your own club about the call. They appreciate it and remember it.
   <sub>social +2; charisma +1; rel coach +1; retention +2; mods loose</sub>

3. **Ignore it**: You ignore it and kick the season out. Whatever comes, comes.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 32. PRO_311 The Teammate Who Becomes a Coach
*team; premise 25 words*

> {holder} retires and joins the coaching staff, with a whistle and a new office. Now {holder} is your boss, and the first meeting is tomorrow.

1. **Keep the friendship** (22 words)
   The friendship stays, and you let {holder} coach you anyway. It works, mostly, and only gets strange at parties and team dinners.
   <sub>social +2; fun +1; rel holder +4; mods loose</sub>

2. **Set new rules together** (21 words)
   New rules, agreed over coffee: coach at the facility, friends on the weekend. It works better than either of you expected.
   <sub>intelligence +2; leadership +1; rel holder +2; mods focused</sub>

3. **Earn their trust fresh** (22 words)
   {holder}, treated like any new coach, and you earn their trust again from scratch. It's strange, and it makes you both better.
   <sub>energy -2; resilience +1; ambition +2; rel holder +1; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> {holder} retires and joins the coaching staff. Now they're your boss.

1. **Keep the friendship**: You keep the friendship and let {holder} coach you anyway. It works, mostly.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

2. **Set new rules**: You agree on new rules: coach at the facility, friends on the weekend.
   <sub>energy -1; intelligence +2; rel coach +2; rel holder +2; mods focused</sub>

3. **Earn it fresh**: You treat {holder} like any new coach and earn their trust again.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 33. PRO_315 The Motivation Slump
*health; premise 26 words*

> Nothing's wrong. That's the problem: practice feels like a job, the job feels like nothing, and you haven't been nervous before a game in a month.

1. **Take a real break** (29 words)
   Days off, taken seriously for once: no film, no phone, a long hike in the hills. Some of the spark comes back, slowly, by the end of the month.
   <sub>energy +3; fun +1; mods rested</sub>

2. **Talk to someone** (22 words)
   Out loud, for the first time, to the team psychologist. It's uncomfortable and it helps, and you go back the next week.
   <sub>social +1; resilience +2; rel parent +1; mods focused</sub>

3. **Set a secret goal** (25 words)
   A goal nobody else knows about, written on a card in your wallet. Practice has a point again, and you catch yourself smiling during warmups.
   <sub>energy -1; accuracy +1; ambition +2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Nothing's wrong. That's the problem: practice feels like a job, and the job feels like nothing.

1. **Take a real break**: You take your days off seriously: no film, no phone. Some of the spark comes back.
   <sub>energy +2; fun +1; mods rested</sub>

2. **Talk to someone**: You talk to someone about it, out loud, for the first time.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Set a new goal**: You set a goal nobody else knows about. Practice has a point again.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>


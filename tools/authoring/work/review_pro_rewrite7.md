# PRO rewrite pass 7: era-2 scenes 79-117

The next 39 era-2 scenes in play order: the mid-career injury, money and sponsors, the locker room, family, the city becoming home.

Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 39 of 39.**

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_648 The Second Car
*money; premise 33 words*

> You buy a second car on a whim after a good week, a convertible in a color the salesman called 'victory'. Then you realize you haven't driven the first one in a month.

1. **Sell one of them** (28 words)
   One of them goes back on the market by Friday, at a loss. You feel smarter for it, and a little silly every time you see a convertible.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Give the old one to {sibling}** (23 words)
   The old car, keys and all, goes to {sibling}, who cries in the driveway and then honks the horn for ten straight seconds.
   <sub>social +2; fun +2; rel sibling +5; mods loose</sub>

3. **Keep both cars** (24 words)
   Both stay. They sit side by side in the driveway, shining, and the insurance bill makes you laugh out loud in a bad way.
   <sub>fun +2; energy +1; charisma +1; mods rested</sub>

<details><summary>Before</summary>

> You buy a second car, and then realize you never drive the first one.

1. **Sell one**: You sell one and feel smarter for it.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Give one to {sibling}**: You give the old one to {sibling}. He cries a little.
   <sub>social +2; charisma +1; rel sibling +5; mods loose</sub>

3. **Keep both**: You keep both. They sit in the driveway, shining.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 2. PRO_649 The Contract Rumors
*career; premise 31 words*

> Rumors say the club might not re-sign you next spring. A radio host says it, then a blog, then the guy who makes your sandwich at the deli near the facility.

1. **Answer with your leg** (23 words)
   No interviews, no reading, just kicking every day. The rumors get quieter by November, and the deli guy apologizes with a free sandwich.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ask the club directly** (24 words)
   A direct question to the general manager, in his office. The answer is honest and incomplete: they love you, and they're keeping options open.
   <sub>intelligence +2; leadership +1; rel coach +1; mods focused</sub>

3. **Talk it over at home** (25 words)
   A long evening at home, talking it through, agreeing not to look at houses in other cities yet. It helps more than any answer would.
   <sub>social +2; resilience +1; rel parent +2; mods loose</sub>

<details><summary>Before</summary>

> Rumors say the club might not re-sign you next spring.

1. **Kick through it**: You kick through it. The rumors get quieter.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ask the club directly**: You ask the club directly. The answer is honest and incomplete.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Talk it over at home**: You talk it over at home and agree not to look at houses yet.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 3. PRO_650 The Locker Room Elections
*team; premise 26 words*

> The players' union asks you to run for team representative. The last rep was traded the week after a tense meeting with management, and everybody remembers.

1. **Run for the job** (25 words)
   Elected, by a lot. Now the young players call you about everything, from pensions to parking, and management knows your name in a new way.
   <sub>energy -2; leadership +3; rel team +2; mods inspired; flags player_rep</sub>

2. **Nominate someone better** (25 words)
   A teammate better suited to the job gets your nomination and your vote. He wins, does it well, and thanks you at the end-of-season dinner.
   <sub>intelligence +2; charisma +1; rel team +1; mods focused</sub>

3. **Stay off the ballot** (20 words)
   Off the ballot. You have enough meetings already, and you'd rather spend the time on the field and with family.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The players' union asks you to run for team representative.

1. **Run**: You run and win. Now the young players call you about everything.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags player_rep</sub>

2. **Nominate someone else**: You nominate someone better suited. They win.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Decline**: You decline. You have enough meetings.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 4. PRO_651 The Mid-Career Injury
*health; premise 30 words*

> A torn muscle in practice, on a routine kick, with a sound you've only heard other people make. It's the first serious injury of your career, right in your prime.

1. **Follow the rehab exactly** (25 words)
   Every step of the rehab, exactly as written, for ten weeks. It's slow and dull, and you come back whole, which the trainers call rare.
   <sub>health +4; energy -1; intelligence +1; rel coach +1; mods focused; flags committed_to_recovery</sub>

2. **Push the timeline** (22 words)
   Early, by three weeks. You're back on the field and not quite right, and you kick carefully all season, favoring the leg.
   <sub>health -2; toughness +1; ambition +2; skill_points +2; mods sore</sub>

3. **Lean on the people at home** (22 words)
   The worst weeks, spent leaning on home: {parent} on the phone every night, {sibling} visiting with bad movies. It gets you through.
   <sub>social +2; resilience +2; rel parent +2; rel sibling +2; mods loose</sub>

<details><summary>Before</summary>

> A torn muscle in practice: the first serious injury of your career, in your prime.

1. **Follow the rehab exactly**: You follow every step of the rehab. It's slow and it works.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused; flags committed_to_recovery</sub>

2. **Push the timeline**: You push the timeline. You're back early and not quite right.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Lean on home**: You lean on {love_interest} through the worst weeks.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 5. PRO_652 The Rehab Partner
*health; premise 31 words*

> You're rehabbing beside a teammate with the same injury, on the same table, at the same hours, with the same trainer. Whoever's back first will notice, and so will the coaches.

1. **Make it a team** (22 words)
   You push each other every day and swap the bad days. You both come back, and you've got a friend for life.
   <sub>social +2; health +1; resilience +1; rel team +3; mods loose</sub>

2. **Race him back** (20 words)
   You race him back and win by a week. He shakes your hand, and something between you cools a little.
   <sub>energy -2; toughness +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Compare notes** (21 words)
   Notes compared every afternoon: what hurts, what helps, what the trainers said. You both come back smarter, and a little closer.
   <sub>health +2; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> You're rehabbing beside a teammate with the same injury, on the same table, at the same hours. Whoever's back first will notice.

1. **Make it a team**: You push each other every day and swap the bad days. You both come back, and you've got a friend for life.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Race him back**: You race him back and win by a week. He shakes your hand, and something between you cools a little.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Compare notes**: You compare notes every afternoon: what hurts, what helps, what the trainers said. You both come back smarter.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 6. PRO_655 The Mortgage
*money; premise 30 words*

> Your first mortgage, and the papers are thicker than your playbook: forty pages of terms, a stack of signature tabs, and a loan officer who keeps calling you 'the athlete'.

1. **Read every page** (22 words)
   Every page, read, with questions about the three that matter. The loan officer is surprised and fixes one clause in your favor.
   <sub>energy -1; intelligence +2; leadership +1; mods focused</sub>

2. **Bring {parent} to the signing** (22 words)
   {parent} at the signing, with reading glasses and opinions. He's done this before and asks the questions you didn't know to ask.
   <sub>social +1; fun +1; resilience +1; rel parent +3; mods loose</sub>

3. **Sign where they point** (26 words)
   Signed where they point, every tab, in twenty minutes. You hope for the best, and for a year you're never quite sure what you agreed to.
   <sub>energy +2; fun +1; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> Your first mortgage, and the papers are thicker than your playbook.

1. **Read every page**: You read every page and ask about the parts that matter.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Bring {parent}**: You bring {parent} to the signing. They've done this before.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Sign where they point**: You sign where they point and hope for the best.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 7. PRO_656 The Family Health Scare
*family; premise 29 words*

> A family member gets scary news from a doctor while you're on a road trip two thousand miles away. {parent} calls at midnight, trying very hard to sound calm.

1. **Fly home overnight** (26 words)
   A red-eye home, a day at the hospital, a red-eye back for the game. You're exhausted and glad, and the news turns out better than feared.
   <sub>energy -3; social +2; rel parent +6; mods drained</sub>

2. **Stay on the phone all night** (23 words)
   All night, on the phone with {parent} and the doctors, asking every question. By morning there's a plan, and you're part of it.
   <sub>energy -2; resilience +1; intelligence +2; rel parent +3; mods focused</sub>

3. **Stay with the team and call** (24 words)
   With the team, calling every hour between meetings. It's the hardest week of your season, and {parent} says it helped to hear your voice.
   <sub>resilience +2; ambition +1; rel parent +1; mods stressed</sub>

<details><summary>Before</summary>

> A family member gets scary news while you're on a road trip.

1. **Fly home**: You fly home overnight and fly back for the game.
   <sub>social +2; charisma +1; rel parent +6; mods loose</sub>

2. **Stay on the phone**: You stay on the phone with the doctors all night.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Stay with the team**: You stay with the team and call every hour.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 8. PRO_657 The Teammate's Divorce
*team; premise 28 words*

> A teammate's divorce is playing out in the locker room: phone calls in the hallway, a lawyer at the facility, and jokes from people who should know better.

1. **Be there quietly** (22 words)
   Quietly there for him: rides, lunches, no questions. He says later you were the only one who never made it a thing.
   <sub>social +2; resilience +1; rel team +3; mods loose</sub>

2. **Keep the room kind** (23 words)
   The jokes stop when you're around, because you calmly make them stop. The room follows your lead, and he notices who did it.
   <sub>energy -1; leadership +2; charisma +1; rel team +2; mods inspired</sub>

3. **Keep out of his business** (23 words)
   His business, not yours. You keep out of it entirely, and he's fine with that, and you wonder sometimes if he needed more.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate's divorce plays out in the locker room.

1. **Be there for him**: You're there for him without making it a thing.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Keep the room kind**: You keep the room from turning it into jokes.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Stay out of it**: You stay out of it. It's his business.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 9. PRO_658 The Charity Auction
*community; premise 33 words*

> You donate an experience to a charity auction, a day at practice with you, and it sells for a fortune to a retired schoolteacher who has been saving for it for a year.

1. **Make it a full day** (20 words)
   A whole day: practice, lunch with the specialists, kicks on the stadium field. She cries twice, and so does {holder}.
   <sub>social +2; fun +2; energy -1; rel holder +2; followers +2; mods inspired</sub>

2. **Do exactly what was promised** (22 words)
   Exactly what was promised, done well and warmly. She's thrilled, and writes the club a thank-you letter they print in the program.
   <sub>resilience +1; intelligence +1; leadership +1; mods focused</sub>

3. **Bring the whole unit** (22 words)
   The whole specialist unit, recruited by you. She gets four for the price of one, and the punter teaches her to hold.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> You donate an experience to a charity auction, and the winner is very excited.

1. **Make it special**: You make it a full day: practice, lunch, the field. They cry.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

2. **Keep it to the plan**: You do exactly what was promised, and do it well.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Bring the specialists**: You bring the whole specialist unit. The winner gets four for one.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 10. PRO_659 The Brand Ambassador
*media; premise 27 words*

> A sporting-goods brand wants you as its regional ambassador for three years: commercials, store openings, a signature cleat. The contract arrives with a pen taped to it.

1. **Sign for three years** (25 words)
   Three years, signed. It's steady money and a lot of store openings, and your signature cleat is ugly in a way you grow to love.
   <sub>energy -2; ambition +2; charisma +1; followers +3; mods spotlight</sub>

2. **Sign for one year** (25 words)
   One year, with an option for more. They agree, a little surprised, and you keep your freedom for the next negotiation and the one after.
   <sub>resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Pass on the cleat** (27 words)
   No contract. Three years is a long time, and the cleat really is ugly. A rival kicker signs instead, and you see his face at the mall.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A brand wants you as its regional ambassador for three years.

1. **Sign for three**: You sign for three years. It's steady, and it's a lot.
   <sub>energy -2; resilience +1; ambition +2; followers +3; skill_points +2; mods dialed_in</sub>

2. **Sign for one**: You sign for one year and see.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Pass**: You pass. Three years is a long time.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 11. PRO_660 The Kicker Clinic Tour
*training; premise 27 words*

> A kicking company wants you on a weekend clinic tour: eight cities, eight Saturdays, a thousand young kickers who all want to know what your secret is.

1. **Do the whole tour** (22 words)
   All eight cities. You see a thousand young kickers and remember being one, and you lose your voice in the sixth city.
   <sub>energy -3; leadership +2; charisma +1; followers +2; mods inspired</sub>

2. **Do the dates near home** (26 words)
   The three dates near home, and your own training the rest of the time. It's a good balance, and the kids in your hometown are thrilled.
   <sub>energy -1; accuracy +1; ambition +1; rel parent +1; skill_points +1; mods focused</sub>

3. **Keep your weekends** (23 words)
   No tour. Your weekends stay yours, and you spend them doing nothing much with the people you love most, which is the point.
   <sub>energy +2; fun +2; mods rested</sub>

<details><summary>Before</summary>

> A kicking company wants you on a weekend clinic tour.

1. **Do the tour**: You do the tour. You see a hundred young kickers and remember being one.
   <sub>energy -2; social +1; leadership +2; rel team +2; followers +2; skill_points +1; mods inspired</sub>

2. **Do some dates**: You do the dates near home and train the rest.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Pass**: You pass and keep your weekends.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_661 A New Boss on the Sideline
*team; premise 29 words*

> A new head coach arrives and doesn't seem to think kickers matter. In his first team meeting he forgets the special teams entirely, and the punter writes it down.

1. **Make him notice** (26 words)
   One practice at a time, you make him notice: the extra kicks, the clean operation, the timing. By October he knows your name and uses it.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ask for ten minutes** (23 words)
   Ten minutes in his office to explain what you actually do. He listens, genuinely surprised, and asks a good question at the end.
   <sub>intelligence +2; charisma +1; rel coach +2; mods focused</sub>

3. **Win the assistants first** (20 words)
   The assistants first, then the head coach follows. It takes a month, and it's the quieter way, and it works.
   <sub>social +2; leadership +1; rel coach +1; rel team +1; mods loose</sub>

<details><summary>Before</summary>

> A new head coach arrives and doesn't seem to think kickers matter.

1. **Make him notice**: You make him notice, one practice at a time.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ask for a meeting**: You ask for ten minutes and explain what you do. He listens, surprised.
   <sub>energy -1; intelligence +2; rel coach +1; mods focused</sub>

3. **Win the staff**: You win over the assistants first. The head coach follows.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 13. PRO_662 The Team Leader Talk
*team; premise 28 words*

> {coach} catches you after a meeting and asks you to speak up more in team meetings. 'They listen to you,' the coach says. 'You just don't say anything.'

1. **Speak at the next meeting** (25 words)
   At the next meeting, you speak: short, clear, about the special teams' mistakes and how to fix them. The room listens, and two veterans nod.
   <sub>energy -2; leadership +3; rel coach +2; rel team +1; skill_points +1; mods inspired</sub>

2. **Speak when it counts** (22 words)
   Only when you have something only a kicker can see, you agree. It happens twice that season, and both times it matters.
   <sub>resilience +1; intelligence +2; rel coach +1; mods focused</sub>

3. **Lead one on one instead** (23 words)
   Your way: one teammate at a time, after practice, in the parking lot. It's quieter and it works, and {coach} lets it go.
   <sub>social +2; charisma +1; rel team +2; mods loose</sub>

<details><summary>Before</summary>

> {coach} asks you to speak up more in team meetings.

1. **Speak up**: You speak up the next meeting, short and clear. People listen.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Speak when it counts**: You agree to speak when you have something only a kicker can see.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Talk one on one**: You do it your way: one teammate at a time, after practice.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 14. PRO_663 The Team Trip Abroad
*team; premise 30 words*

> The club plays a game overseas, and the trip is a week long: a different city, a different language, a different time zone, and a stadium that smells like rain.

1. **See the city with the unit** (21 words)
   The city, explored with the specialists: museums, a market, a terrible bus tour. It's the best road trip of your career.
   <sub>social +2; fun +3; rel holder +2; rel team +1; mods loose</sub>

2. **Keep your routine exactly** (25 words)
   Your routine, kept to the minute, even at four in the morning local time. It's lonely and very steady, and your leg feels like home.
   <sub>energy +1; resilience +2; ambition +1; mods focused</sub>

3. **Shift your sleep a week early** (25 words)
   A week early, at home, you start shifting your sleep an hour a night. You land ready while half the roster stumbles off the plane.
   <sub>health +1; intelligence +2; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> The club plays a game overseas, and the trip is a week long.

1. **See the city with teammates**: You see the city with the specialists. It's the best road trip of your career.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Keep your routine**: You keep your routine to the minute. It's a little lonely and very steady.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Plan for the time change**: You shift your sleep a week early. You land ready.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 15. PRO_664 The Jet Lag Game
*training; premise 28 words*

> You're kicking in a different time zone, three hours off, and your body hasn't noticed. Your leg feels like it belongs to someone who's still asleep at home.

1. **Follow the sleep plan** (20 words)
   The trainers' sleep plan, exactly: light, dark, water, no phone. By game day you feel almost normal, which is enough.
   <sub>energy -1; health +2; intelligence +1; rel coach +1; mods focused</sub>

2. **Kick your legs awake** (20 words)
   Extra kicks the first morning, until your leg finally wakes up. It works, mostly, and you're tired by Saturday night.
   <sub>energy -2; power +1; ambition +1; skill_points +1; mods dialed_in</sub>

3. **Sleep whenever you can** (23 words)
   Naps, whenever and wherever: the bus, the hotel lobby, a training table. You stop worrying about the clock, and the clock stops mattering.
   <sub>energy +3; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You're kicking in a different time zone, and your body hasn't noticed yet.

1. **Follow the sleep plan**: You follow the trainers' sleep plan exactly. By game day, you feel almost normal.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Kick it awake**: You kick extra the first morning to wake your legs up.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Sleep when you can**: You sleep whenever you can and stop worrying about the clock.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_665 The Contract Bonus
*money; premise 26 words*

> You hit a contract bonus on the last day of the season. Your agent calls to congratulate you and asks you, very seriously, to celebrate quietly.

1. **Put it all in savings** (22 words)
   The whole bonus, straight into savings, and you tell almost nobody about it. Your advisor sends a single word by text: 'Proud.'
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Treat the specialists** (23 words)
   A nice dinner for the specialists, on you, and nobody posts about it. {holder} gives a toast to 'the bonus we all earned'.
   <sub>social +2; fun +2; rel holder +3; mods loose</sub>

3. **Celebrate at home** (21 words)
   Takeout, a movie and a very long sleep at home. It's the quietest celebration in league history, and it's exactly right.
   <sub>energy +2; fun +2; health +1; mods rested</sub>

<details><summary>Before</summary>

> You hit a contract bonus, and your agent wants you to celebrate quietly.

1. **Put it away**: You put it straight into savings and tell almost nobody.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Treat the specialists**: You treat the specialists to a nice dinner. Nobody posts about it.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

3. **Celebrate at home**: You celebrate at home with takeout and a movie.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 17. PRO_667 The House Party You Host
*social; premise 28 words*

> You host a team party at your new house, and by ten o'clock it's twice as big as planned. There are people in your backyard you've never met.

1. **Set the rules early** (22 words)
   You set the rules at the door: rides home, nothing stupid, done by midnight. Everyone respects them, and the night stays fun.
   <sub>energy -1; leadership +2; intelligence +1; rel team +2; skill_points +1; mods inspired</sub>

2. **Enjoy it** (25 words)
   Running with it, you enjoy the whole night. Half the team is in your backyard, laughing, and you've never felt more like one of them.
   <sub>social +3; fun +3; rel team +4; mods loose</sub>

3. **Shut it down early** (23 words)
   You shut it down early when it gets too big. A few teammates grumble on the way out, and nobody calls the police.
   <sub>energy +1; resilience +1; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> You host a team party at your new house, and by ten o'clock it's twice as big as planned. There are people in your backyard you've never met.

1. **Set the rules early**: You set the rules at the door: rides home, nothing stupid, done by midnight. Everyone respects them, and the night stays fun.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Enjoy it**: You let it run and enjoy it. Half the team is in your backyard, laughing, and you've never felt more like one of them.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

3. **Shut it down early**: You shut it down early when it gets too big. A few teammates grumble on the way out, and nobody calls the police.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 18. PRO_668 Your Old Coach Visits
*training; premise 28 words*

> Your college special teams coach visits practice and watches every kick from the sideline, arms crossed, the way he did when you were nineteen and terrified of him.

1. **Spend the day with him** (24 words)
   The whole day with him: practice, lunch, the drive to the airport. He tells stories about you that you'd forgotten, some of them true.
   <sub>social +2; fun +1; rel best_friend +1; mods loose</sub>

2. **Ask for his notes** (27 words)
   His notes, please. He has one page, and one line on it is gold: your left arm drops on long kicks. You fix it in a week.
   <sub>accuracy +2; intelligence +1; mods focused</sub>

3. **Give him your best practice** (25 words)
   The best practice of your year, for an audience of one. He nods once at the end, which is the most he ever gave you.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> Your college special teams coach visits practice and watches every kick.

1. **Spend the day with him**: You spend the day with him. He tells stories about you that you'd forgotten.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Ask for his notes**: You ask for his notes. He has a page, and one line is gold.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Show him your best**: You show him your best practice of the year.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 19. PRO_669 The Ball Boy
*team; premise 32 words*

> A ball boy who's been at the facility as long as you have, since he was twelve, is going to college in the fall. He's the first in his family to go.

1. **Throw him a send-off** (22 words)
   A send-off in the equipment room, organized by the specialists, with a cake shaped like a football and a card everybody signed.
   <sub>social +2; fun +2; rel team +2; mods loose</sub>

2. **Write him a letter** (20 words)
   A recommendation letter, written carefully over a weekend. He gets the scholarship, and sends you a photo from his dorm.
   <sub>intelligence +1; leadership +2; mods inspired</sub>

3. **Shake his hand** (23 words)
   A handshake on his last day and a wish of good luck. He'll remember it, and you'll wish you'd done a little more.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A ball boy who's been here as long as you have is going to college.

1. **Throw him a send-off**: You and the specialists throw him a send-off in the equipment room.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Write him a letter**: You write him a recommendation letter. He gets the scholarship.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Shake his hand**: You shake his hand and wish him luck.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 20. PRO_670 The Scrapbook
*family; premise 30 words*

> {parent} keeps a scrapbook of every article ever written about you, back to the peewee league newsletter. He shows it to you on a visit, a little embarrassed, very proud.

1. **Go through every page** (24 words)
   Every page, together, at the kitchen table, all evening. He tells you what he was doing the day of every article, and you listen.
   <sub>social +2; resilience +1; rel parent +5; mods loose</sub>

2. **Help him digitize it** (25 words)
   A weekend of scanning, so nothing gets lost in a flood or a fire. He insists on keeping the paper one too, and you agree.
   <sub>energy -1; intelligence +2; leadership +1; rel parent +2; mods focused</sub>

3. **Laugh at the old haircuts** (27 words)
   A few favorites, and a lot of laughing at your old haircuts. It's a warm half hour, and he puts the book back on its shelf carefully.
   <sub>fun +2; energy +1; rel parent +1; mods rested</sub>

<details><summary>Before</summary>

> {parent} keeps a scrapbook of every article about you, and shows you.

1. **Go through it together**: You go through every page together. It takes the whole evening.
   <sub>social +2; charisma +1; rel parent +5; mods loose</sub>

2. **Help them digitize it**: You help scan it so nothing gets lost.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Look at your favorites**: You look at a few favorites and laugh at your old haircut.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 21. PRO_671 The Fan Who Grew Up
*community; premise 31 words*

> A kid who held a cardboard sign with your name at your first pro practice is now in high school, a kicker, and pretty good. His coach emails to tell you.

1. **Invite him to practice** (24 words)
   An invitation to watch practice, and a session with you after. He kicks better than you did at sixteen, and you tell him so.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

2. **Send a message about the sign** (20 words)
   A message: the sign is still on your fridge. He posts it, and his whole school sees it by lunch.
   <sub>social +2; fun +1; followers +2; mods loose</sub>

3. **Watch his videos** (21 words)
   His game film, watched from your couch, with a smile. You don't reach out, and you check his scores every Friday.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A kid who held a sign at your first practice is now in high school and kicking.

1. **Invite him to practice**: You invite him to watch practice and hold a session after.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Send him a message**: You send a message: the sign is still on your fridge.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

3. **Watch from afar**: You watch his videos and smile.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 22. PRO_673 The Pet
*family; premise 26 words*

> You get a dog from the shelter, a big nervous mutt with one ear up, and it changes your schedule more than any coach ever has.

1. **Love the morning walks** (25 words)
   The morning walks become the calmest part of your day. The dog learns to wait at the door at six, and so, somehow, do you.
   <sub>energy +1; health +2; fun +1; mods rested</sub>

2. **Bring the dog on Fridays** (25 words)
   Fridays at the facility, with the dog. It becomes the team's dog within a month, and the linemen fight over who gets to walk it.
   <sub>social +2; fun +2; rel team +2; mods loose</sub>

3. **Build it into the routine** (24 words)
   The dog, built into your routine like a stretching session, with walks before film. Everyone's happier, especially the dog, who now knows the playbook.
   <sub>energy -1; resilience +1; intelligence +1; mods focused</sub>

<details><summary>Before</summary>

> You get a dog, and it changes your schedule more than you expected.

1. **Enjoy the walks**: You enjoy the morning walks. They're the calmest part of your day.
   <sub>energy +2; fun +1; mods rested</sub>

2. **Bring the dog to the facility**: You bring the dog to the facility on Fridays. It becomes the team's dog.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Set a routine**: You build the dog into your routine. Everyone's happier.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 23. PRO_674 The Retirement Account
*money; premise 26 words*

> Your advisor finally gets you to open a retirement account, after three years of reminders. The paperwork is waiting on the table, with little yellow arrows.

1. **Do it right** (27 words)
   Done right: every arrow signed, every question asked, contributions set to grow on their own. Your advisor sends a photo of the paperwork, framed, as a joke.
   <sub>resilience +1; intelligence +2; leadership +1; mods focused; flags honest_advisor</sub>

2. **Ask {parent} what he wishes he'd done** (23 words)
   What does {parent} wish he'd done at your age? It's a long, honest talk on the phone, and it changes what you sign.
   <sub>social +1; resilience +1; intelligence +1; rel parent +3; mods loose</sub>

3. **Sign the minimum** (23 words)
   The minimum, signed and then forgotten about. Your advisor sighs on the phone and sets a reminder for the same day next year.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Your advisor finally gets you to open a retirement account.

1. **Do it right**: You do it right and set it to grow on its own.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Ask {parent} what they wish they'd done**: You ask {parent} what they wish they'd done. It's a long, honest talk.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Do the minimum**: You do the minimum and forget about it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 24. PRO_675 The Charity Basketball Game
*community; premise 28 words*

> A charity basketball game with teammates in a high school gym, and you are, by a wide margin, the worst player on the court. The crowd has noticed.

1. **Play it for laughs** (23 words)
   Every miss, celebrated like a championship. The crowd loves it, the clips go around, and the charity raises more than it ever has.
   <sub>social +2; fun +3; rel team +2; followers +2; mods loose</sub>

2. **Practice for a week** (20 words)
   A week of secret practice in your driveway. You score twice in the game, and your teammates are genuinely amazed.
   <sub>energy -2; toughness +1; ambition +2; skill_points +1; mods dialed_in</sub>

3. **Coach from the bench** (21 words)
   A clipboard, a whistle and the bench. You coach your team to a win, and the losing team demands a rematch.
   <sub>leadership +2; intelligence +1; rel team +1; mods inspired</sub>

<details><summary>Before</summary>

> A charity basketball game with teammates, and you're the worst player on the court.

1. **Play it for laughs**: You play it for laughs. The crowd loves it.
   <sub>social +2; charisma +1; rel team +3; followers +2; mods loose</sub>

2. **Practice for a week**: You practice for a week and score twice. Your teammates are amazed.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Coach from the bench**: You coach from the bench instead. Your team wins.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 25. PRO_676 Supporting a Teammate's Cause
*community; premise 27 words*

> A teammate is launching a foundation for kids in his old neighborhood and asks you to stand beside him. It's his cause, and he's nervous about it.

1. **Show up** (26 words)
   Every event this season, and you show up early to each one. He stops looking nervous by the third, and you help him with the speeches.
   <sub>social +2; energy -1; charisma +1; rel team +3; mods loose</sub>

2. **Help with the plan** (22 words)
   You help him build the plan, not just the photos: a budget, a board, a calendar. A year later, it's still running.
   <sub>intelligence +2; leadership +1; rel team +2; mods focused</sub>

3. **Donate quietly** (23 words)
   A quiet donation and your best wishes. He's grateful, and you can tell from his face that he hoped you'd stand beside him.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate is launching a foundation for kids in his old neighborhood and asks you to stand beside him. It's his cause, and he's nervous about it.

1. **Show up**: You show up at every event this season, early. He stops looking nervous by the third one.
   <sub>social +2; charisma +1; rel team +4; mods loose</sub>

2. **Help with the plan**: You help him build the plan, not just the photos: a budget, a board, a calendar. A year later, it's still running.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Donate quietly**: You donate quietly and send your best. He's grateful, and you can tell he hoped for more.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 26. PRO_677 The Old Rival on Your Team
*team; premise 30 words*

> A kicker you competed with all through college signs with your club as a backup. He beat you for a scholarship once. Now he's the one on the practice squad.

1. **Bury the old rivalry** (25 words)
   Lunch on his first day, and the old rivalry turns into a joke you both share. By midseason, he's your best friend on the team.
   <sub>social +2; fun +1; rel backup +4; mods loose</sub>

2. **Stay ahead every day** (22 words)
   Ahead of him every day, by a little. He notices, you notice, and neither of you says a word about the scholarship.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Help him fit in** (25 words)
   His introduction to the room, made by you, generously. The room notices how you handle it, and so does {coach}, who says nothing and remembers.
   <sub>energy -1; leadership +2; charisma +1; rel backup +2; rel coach +1; mods inspired</sub>

<details><summary>Before</summary>

> A kicker you competed with in college signs with your club as a backup.

1. **Bury the old rivalry**: You take him to lunch the first day. The old rivalry turns into a joke you share.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Stay ahead**: You stay ahead of him every single day.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Help him fit in**: You help him fit in. The room notices how you handle it.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 27. PRO_678 The Brother's Wedding
*family; premise 27 words*

> {sibling} is getting married on a game weekend. The date was set before the schedule came out, and {sibling} has already asked you to give the toast.

1. **Fly in for the wedding** (21 words)
   The Friday, granted by {coach}, a flight back Saturday night. You give the toast, and {sibling} doesn't stop crying through it.
   <sub>social +2; energy -2; charisma +1; rel sibling +6; mods inspired</sub>

2. **Help move the date** (24 words)
   A different date, found together with {sibling}, who moves it a week. You're there all weekend, and so is the rest of the family.
   <sub>social +1; intelligence +1; leadership +1; rel sibling +3; rel parent +1; mods focused</sub>

3. **Send a video toast** (23 words)
   A video toast, recorded in the locker room. {sibling} plays it twice, and you watch the reception on a phone in a hotel.
   <sub>resilience +1; ambition +1; rel sibling +1; mods stressed</sub>

<details><summary>Before</summary>

> {sibling} is getting married on a game weekend.

1. **Ask to be there**: You ask {coach} for the Friday and fly back Saturday night. You give the toast.
   <sub>social +2; charisma +1; rel sibling +6; mods loose</sub>

2. **Help plan around it**: You help {sibling} find a date that works. He moves it, and you're there all weekend.
   <sub>energy -1; resilience +1; intelligence +2; rel sibling +2; mods focused</sub>

3. **Send a video toast**: You send a video toast. He plays it twice.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 28. PRO_679 The City Starts to Feel Like Home
*community; premise 30 words*

> One morning you realize you know your neighbors' names, your barista knows your order, and the dry cleaner asks about your knee. The city has started to feel like home.

1. **Put down roots** (23 words)
   A neighborhood group, a library card, a farmers' market on Saturdays. You start saying yes to things, and the city says yes back.
   <sub>social +2; fun +2; rel best_friend +1; mods loose</sub>

2. **Enjoy it quietly** (23 words)
   Quietly, you enjoy it. Home is a nice word, and you don't need to say it out loud to anyone to feel it.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

3. **Think about staying for good** (21 words)
   A question you've never asked: what if you stayed here after football? You start reading about schools and neighborhoods at night.
   <sub>intelligence +2; leadership +1; mods focused</sub>

<details><summary>Before</summary>

> You realize you know your neighbors and your coffee order.

1. **Put down roots**: You join a neighborhood group and start saying yes to things.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

2. **Enjoy it quietly**: You enjoy it quietly. Home is a nice word.
   <sub>energy +2; fun +1; mods rested</sub>

3. **Think about staying**: You start thinking about staying here after football.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 29. PRO_680 The Sponsor's Event
*media; premise 32 words*

> Your sponsor wants you at a store opening on your only day off this month. It's three hours away, there's a ribbon to cut, and the regional manager has already announced you.

1. **Go and do it well** (24 words)
   You go, cut the ribbon, sign for two hours and smile until your face hurts. The sponsor is thrilled, and your day off disappears.
   <sub>energy -2; social +1; charisma +2; followers +2; mods tired</sub>

2. **Offer another day** (21 words)
   A different day, offered politely. They take it, and reschedule the ribbon, and the regional manager pretends it was his idea.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Keep your day off** (21 words)
   No, politely, and you keep your day off. The sponsor is a little cooler next time, and you sleep until ten.
   <sub>energy +3; health +1; mods rested</sub>

<details><summary>Before</summary>

> Your sponsor wants you at an event on your only day off.

1. **Go**: You go and do it well. Your day off disappears.
   <sub>energy -2; resilience +1; ambition +2; followers +2; skill_points +2; mods dialed_in</sub>

2. **Offer another day**: You offer another day. They take it.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Say no**: You say no politely. The sponsor is cooler next time.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 30. PRO_681 The Mid-Career Check-In
*career; premise 28 words*

> Your agent takes you to lunch and asks a question nobody's asked you before: where do you want to be in five years? Not the contract. The life.

1. **Write it down** (24 words)
   The club, the house, the people, the life after, written on a napkin. Your agent keeps the napkin and brings it to every meeting.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Aim for the top** (23 words)
   The top, you say: the best in the league, the biggest contract, the Hall of Fame. Your agent smiles and gets to work.
   <sub>energy -1; ambition +3; skill_points +1; mods dialed_in</sub>

3. **Ask your family first** (21 words)
   Your family first, you say, and you ask them that night. Their answer surprises you, and it changes the next contract.
   <sub>social +2; charisma +1; rel parent +2; rel sibling +1; mods loose</sub>

<details><summary>Before</summary>

> Your agent asks where you want to be in five years.

1. **Write it down**: You write it down: the club, the house, the life.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Say the top**: You say the top. Your agent smiles and gets to work.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Ask {love_interest}**: You ask {love_interest} first. The answer surprises you.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 31. PRO_682 The Teammate Who Gets Rich
*team; premise 28 words*

> A teammate signs a huge contract and starts acting like it: the new watch, the entourage, the late arrivals, a new way of talking to the equipment staff.

1. **Talk to him as a friend** (23 words)
   A quiet word, as a friend, in the parking lot. He hears it, eventually, and apologizes to the equipment staff on his own.
   <sub>social +2; leadership +1; rel team +2; mods loose</sub>

2. **Keep the room together** (23 words)
   The room, kept from turning on him. You defend him in public and push him in private, and by December he's himself again.
   <sub>energy -2; resilience +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Let him be** (21 words)
   Money changes people for a while, you decide, and you let him be. He comes back to earth by spring, mostly.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A teammate signs a huge contract and starts acting like it.

1. **Talk to him**: You talk to him as a friend. He hears it, eventually.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Keep the room together**: You keep the room from turning on him.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Let him be**: You let him be. Money changes people for a while.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 32. PRO_683 The Practice Squad Kicker
*career; premise 26 words*

> The practice squad kicker is good, really good, and the coaches know it. They've started watching his kicks as closely as yours, and he's started noticing.

1. **Raise your level** (21 words)
   Your level, raised, and kept there. Every practice is better than the last, and the coaches start watching your kicks again.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help him anyway** (21 words)
   Help, freely given: his plant foot, his routine, his nerves. He'll get a job somewhere, and he'll remember who helped him.
   <sub>social +1; leadership +2; charisma +1; rel backup +4; mods inspired</sub>

3. **Ask where you stand** (21 words)
   {coach}, asked plainly where you stand. The answer is fair and a little uncomfortable, and you leave with a clear target.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> The practice squad kicker is good, and the coaches know it.

1. **Raise your level**: You raise your level and keep it there.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Help him anyway**: You help him anyway. He'll get a job somewhere, and he'll remember you.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Ask where you stand**: You ask {coach} where you stand. The answer is fair.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 33. PRO_685 The Season-Ticket Holder
*community; premise 30 words*

> A season-ticket holder has sat in the same seat behind the bench for thirty years, and talks to you every single week: weather, wind, his late wife's opinions on kickers.

1. **Learn his story** (25 words)
   His story, over a dozen conversations: he was here for every era of this club, good and terrible. You start looking for him before warmups.
   <sub>social +2; resilience +1; followers +1; mods loose</sub>

2. **Bring him onto the field** (23 words)
   A practice pass, arranged by you. He walks onto the field for the first time in thirty years and has to sit down.
   <sub>energy -1; leadership +2; charisma +1; mods inspired</sub>

3. **Wave every week** (24 words)
   A wave every week, and he waves back from his seat. It's small and steady, and you'd miss it terribly if it ever stopped.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A season-ticket holder has sat behind the bench for thirty years and talks to you every week.

1. **Learn his story**: You learn his story. He was here for every era of this club.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Get him on the field**: You get him onto the field for a practice. He cries.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Wave every week**: You wave every week. He waves back.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 34. PRO_686 The Charity Visit You Remember
*community; premise 32 words*

> A charity visit to the children's hospital leaves a mark. One kid, eight years old, asked you to kick a paper ball across his room, and you can't stop thinking about him.

1. **Go back on your own** (26 words)
   Back, on your own, without cameras, twice a month. The kid's family remembers you forever, and you remember them every time you see a paper ball.
   <sub>social +2; energy -1; resilience +1; rel parent +1; mods inspired</sub>

2. **Start something** (27 words)
   A small fund for the hospital, started by you and run by a nurse. It buys games, tablets and paper balls, and it's still running years later.
   <sub>energy -2; leadership +2; charisma +1; rel team +2; skill_points +1; mods inspired; flags community_volunteer</sub>

3. **Keep his drawing in your locker** (27 words)
   His drawing of you, kicking a paper ball, goes in your locker. You look at it before every game, and it calms you more than any routine.
   <sub>energy +1; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> A charity visit leaves a mark, and you can't stop thinking about one kid.

1. **Visit again**: You go back on your own. The kid's family remembers you forever.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Start something**: You start a small fund for the hospital.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags community_volunteer</sub>

3. **Hold the memory**: You keep the kid's drawing in your locker.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 35. PRO_687 The Coaching Staff Dinner
*team; premise 26 words*

> The coaches invite you to dinner at the head coach's house, which they've never done before. You're the only player there, and there are place cards.

1. **Go and enjoy it** (26 words)
   Dinner, stories and a long evening on the patio. They're people too, it turns out, and the head coach does a very bad impression of you.
   <sub>social +2; fun +2; rel coach +2; mods loose</sub>

2. **Go and listen closely** (23 words)
   Mostly listening, all evening. You learn what they think of the special teams, and what they think of you, and both are useful.
   <sub>resilience +1; intelligence +2; rel coach +1; mods focused</sub>

3. **Decline politely** (23 words)
   A polite no. It feels strange to eat with the people who decide your job, and you're not sure that's a good reason.
   <sub>energy +2; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> The coaches invite you to dinner, which they've never done before.

1. **Go and enjoy it**: You go and enjoy it. They're people too, it turns out.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Go and listen**: You go and listen. You learn what they think of the unit.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Decline politely**: You decline politely. It's strange to eat with the people who decide your job.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 36. PRO_688 The Big Market Rumor
*career; premise 27 words*

> A big-market club is rumored to want you next season. Your agent mentions it 'just so you know', and every reporter at your locker mentions it too.

1. **Let the rumor be a rumor** (24 words)
   Silence, and no comment to anyone. The rumor stays a rumor, and you stay focused on this season, mostly, and the reporters move on.
   <sub>resilience +2; intelligence +1; mods focused</sub>

2. **Reassure your club** (21 words)
   Your own club hears it from you directly: you're happy here. The general manager thanks you, and the front office remembers.
   <sub>social +1; charisma +1; leadership +1; rel coach +1; retention +2; mods loose</sub>

3. **Kick like it's an audition** (25 words)
   Fuel, every single week: you kick like the big-market club is watching every practice, because it probably is, and your leg has never felt better.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> A big-market club is rumored to want you next season.

1. **Say nothing**: You say nothing and let the rumor be a rumor.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Reassure your club**: You tell your club you're happy here.
   <sub>social +2; charisma +1; rel coach +1; retention +2; mods loose</sub>

3. **Use it**: You use it as fuel. You kick like you're auditioning.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 37. PRO_689 The Weather Delay
*training; premise 31 words*

> A lightning delay in the second quarter, and the teams go to the locker rooms for three hours. Your leg is cold by the first hour and stiff by the second.

1. **Plan the warmup with the trainers** (27 words)
   A warmup plan, built with the trainers: bike, bands, a heat pack every thirty minutes. You walk out loose and ready when the lights come back on.
   <sub>health +1; intelligence +2; rel coach +1; mods focused</sub>

2. **Keep the unit laughing** (22 words)
   Card tricks, bad jokes and an impression of {coach}. The specialists laugh through the whole delay, and three hours pass like one.
   <sub>social +2; fun +2; rel holder +2; mods loose</sub>

3. **Rest in the locker room** (26 words)
   A towel over your eyes, a bench, and rest. You nap for an hour, and you're fresh, if a little stiff, when they call you back.
   <sub>energy +3; toughness +1; mods rested</sub>

<details><summary>Before</summary>

> A long weather delay, and you have to stay warm for three hours.

1. **Plan the warmup**: You plan a warmup schedule with the trainers and stick to it.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Keep the unit loose**: You keep the specialists laughing. Time passes.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Rest and wait**: You rest in the locker room and wait.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 38. PRO_690 The Players' Council
*team; premise 29 words*

> The players form a leadership council after a rough season, eight players, and they vote you on. The first meeting is Monday, and there's already a list of problems.

1. **Commit to the council** (24 words)
   Every meeting, every follow-up, every hard conversation with management. The council fixes three real problems, and you lose a lot of sleep doing it.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring data to every meeting** (22 words)
   Numbers, charts and dates to every single meeting. The coaches start listening to the council because of the data, and say so.
   <sub>intelligence +2; leadership +1; rel coach +1; mods focused</sub>

3. **Stay quiet on the council** (23 words)
   On the council, quietly, letting the others lead. You vote, you listen, and you're glad when the season ends and the meetings stop.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The players form a leadership council, and you're on it.

1. **Take it seriously**: You commit to it. The council fixes three real problems.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring data**: You bring data to every meeting. The coaches listen.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Stay quiet**: You stay quiet and let the others lead.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 39. PRO_277 Moving House
*family; premise 30 words*

> You and {love_interest} are buying a house, and every room becomes an argument about how long you'll stay in this city: a nursery, an office, a guest room for {parent}.

1. **Buy the house they love** (24 words)
   The house {love_interest} loves, with the big kitchen and the bad plumbing. It's the right call, and you know it by the first dinner.
   <sub>social +2; fun +1; rel love_interest +5; mods loose</sub>

2. **Buy something easy to sell** (20 words)
   Something practical, easy to sell if you're traded. It's sensible and a little sad, and {love_interest} agrees without much enthusiasm.
   <sub>resilience +1; intelligence +2; leadership +1; rel love_interest -1; mods focused</sub>

3. **Keep renting a year** (27 words)
   Another year of renting, and the argument waits in the corner. It's easier for now, and it will come back every time you pass an open house.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You're buying a house, and every room is an argument about how long you'll stay in this city.

1. **Buy what your partner wants**: You buy the house {love_interest} loves. It's the right call.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Buy something you can sell**: You buy something easy to sell. It's practical and a little sad.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Keep renting**: You keep renting another year. The argument waits.
   <sub>energy +2; fun +1; mods rested</sub>

</details>


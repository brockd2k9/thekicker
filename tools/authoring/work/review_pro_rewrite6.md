# PRO rewrite pass 6: era-2 scenes 40-78

The next 39 era-2 scenes in play order: the second contract, money and business, the locker room in your late twenties, family.

Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 39 of 39.**

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_357 The Contract Extension
*career; premise 32 words*

> The club wants to talk about extending your contract a year early. The general manager calls it a sign of respect; your agent calls it a discount with a bow on it.

1. **Sign early for security** (27 words)
   Signed, a year early. Your agent says you left money on the table; you sleep fine, and the front office starts calling you 'part of the core'.
   <sub>energy +1; resilience +1; intelligence +1; retention +2; mods rested</sub>

2. **Bet on yourself** (27 words)
   Declined, politely, and you play out the deal. Every kick this season is an audition for the open market, and you can feel it in your stomach.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Talk it over at home** (26 words)
   The offer goes on the kitchen table for a week. You sign a shorter version that leaves room to breathe, and everyone in the house exhales.
   <sub>social +1; intelligence +2; rel parent +2; mods focused</sub>

<details><summary>Before</summary>

> The club wants to talk about extending your contract, a year early.

1. **Take the security**: You sign early. Your agent says you left money on the table; you sleep fine.
   <sub>energy -1; intelligence +2; rel coach +2; retention +2; mods focused</sub>

2. **Bet on yourself**: You decline and play out the deal. Every kick is an audition now.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Ask {love_interest}**: You talk it over at home. You sign a shorter version.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 2. PRO_358 The First Big Purchase
*money; premise 31 words*

> You can finally afford the car you've wanted since you were fifteen, the one on the poster above your childhood bed. The dealer already knows your name when you walk in.

1. **Buy it and drive it home** (21 words)
   Bought, and driven straight home to {parent}'s driveway. He walks around it three times without speaking, then asks for the keys.
   <sub>fun +3; social +1; rel parent +3; mods loose</sub>

2. **Buy something sensible** (28 words)
   Something sensible, with good mileage, and the rest goes in the bank. It's a good car. It isn't the car, and you notice every time you see one.
   <sub>fun -1; resilience +1; intelligence +2; mods focused</sub>

3. **Wait one more year** (27 words)
   A year's wait, on purpose. The wanting fades a little, and so does the fun of it, and you're not sure whether that's wisdom or a loss.
   <sub>energy +1; ambition +1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> You can finally afford the car you've wanted since high school.

1. **Buy it and show {parent}**: You buy it and drive it home first. {parent} won't stop smiling.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

2. **Buy something sensible**: You buy something sensible and put the rest away. It's a good car. It isn't the car.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Wait a year**: You wait a year. The want fades a little, and so does the fun.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 3. PRO_359 The Regional Endorsement
*money; premise 26 words*

> A regional grocery chain offers you a sponsorship worth more than your whole rookie salary: commercials, store openings, your face on cereal boxes in three states.

1. **Sign the deal** (22 words)
   Signed. The shoots take some weekends, the money is real, and {sibling} buys forty boxes of cereal with your face on them.
   <sub>fun +2; energy -1; ambition +1; rel sibling +2; followers +3; mods spotlight</sub>

2. **Strike two clauses first** (22 words)
   The fine print, read twice, and two clauses struck: no appearances in season, no exclusivity. They agree, and you keep your Tuesdays.
   <sub>intelligence +2; leadership +1; followers +2; mods focused</sub>

3. **Keep your weekends** (24 words)
   A pass, and your weekends stay yours. A rival kicker takes the deal, and you see his face in every aisle for a year.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A regional company offers you a sponsorship worth more than your rookie salary.

1. **Sign it**: You sign it. The shoots take some weekends, and the money is real.
   <sub>energy -2; ambition +2; followers +3; skill_points +2; mods dialed_in</sub>

2. **Read the fine print**: You read the fine print and strike two clauses. They agree.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Pass on it**: You pass. Your weekends stay yours.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 4. PRO_360 The Investment Pitch
*money; premise 27 words*

> A man at a charity dinner pitches you an investment: guaranteed returns, a famous partner, no risk. He's done this before, and he knows you can tell.

1. **Walk away** (24 words)
   You thank him and walk away. Six months later you read his name in the paper, and you pass the article to your teammates.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Ask someone you trust** (27 words)
   You show it to someone you trust. They laugh, then explain exactly how it works. You learn more in an hour than in a year of statements.
   <sub>social +1; intelligence +1; charisma +1; rel parent +3; mods loose</sub>

3. **Put money in** (26 words)
   You put money in. The statements look great for a while, then they stop coming, and so does he. The shame lasts longer than the loss.
   <sub>fun -2; energy -1; ambition +1; skill_points +1; mods stressed; flags bad_venture</sub>

<details><summary>Before</summary>

> A man at a charity dinner pitches you an investment: guaranteed returns, a famous partner, no risk. He's done this before, and he knows you can tell.

1. **Walk away**: You thank him and walk away. Six months later you read his name in the paper, and you pass the article to your teammates.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Ask someone you trust**: You show it to someone you trust. They laugh, then explain exactly how it works. You learn more in an hour than in a year of statements.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Put money in**: You put money in. The statements look great for a while, then they stop coming, and so does he. The shame lasts longer than the loss.
   <sub>fun -2; energy -1; ambition +1; skill_points +1; mods stressed; flags bad_venture</sub>

</details>

## 5. PRO_361 The Rookie Mentor
*team; premise 30 words*

> The club asks you to help a younger player adjust: a nervous second-year punter who eats lunch alone and calls home after every practice. Someone once did this for you.

1. **Take the punter on** (27 words)
   Meals, film, the long drives home: all of it, on your shoulders for a season. He's steadier by midseason and starts eating lunch at the specialists' table.
   <sub>energy -2; leadership +3; rel team +1; skill_points +1; mods inspired</sub>

2. **Be a friend, not a mentor** (21 words)
   Friendly instead of formal: video games, bad movies, no lectures. He calls you when it really matters, and it does, twice.
   <sub>social +2; fun +2; rel backup +2; mods loose</sub>

3. **Point him to a veteran** (28 words)
   A veteran with more time and more patience gets the job, at your suggestion. It works out fine, and you feel a small pang at the specialists' table.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> The club asks you to help a younger player adjust, the way someone helped you.

1. **Take it on**: You agree to it: meals, film, the long drives. He's steadier by midseason.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Be a friend**: You keep it friendly instead of formal. He calls you when it matters.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Point him elsewhere**: You point him to a veteran with more time.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 6. PRO_362 The Locker Room Reputation
*team; premise 33 words*

> Younger teammates have started looking at you when something goes wrong: a bad practice, a fight in the weight room, a rumor about a trade. You're not sure when you became that person.

1. **Step into it** (24 words)
   You step into it. When the room gets loud, you're the calm voice, and by December the coaches start running things past you first.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Pick your moments** (21 words)
   Rare words, carefully chosen. You speak up twice all season, in two bad weeks, and both times the room listens completely.
   <sub>resilience +1; intelligence +2; leadership +1; mods focused</sub>

3. **Stay a kicker** (25 words)
   There are captains for that, you decide, and you stay a kicker. The young players find someone else, and you're relieved and a little sorry.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Younger teammates have started looking at you when something goes wrong.

1. **Step into it**: You step into it. When the room gets loud, you're the calm voice.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Pick your moments**: You speak rarely and choose the moments. They listen more for it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Stay a kicker**: You stay a kicker. There are captains for that.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 7. PRO_363 The Coaching Change
*training; premise 29 words*

> A new special teams coach arrives with a new way of doing everything: new drills, new warmups, a new word for every old thing. He's thirty-four and very confident.

1. **Try every new drill** (20 words)
   Every new drill, without complaint, for a month. Some of it actually helps, and he notices who didn't fight him.
   <sub>energy -2; accuracy +1; ambition +1; rel coach +2; skill_points +2; mods dialed_in</sub>

2. **Keep what works** (20 words)
   What works, kept; what doesn't, explained calmly. He respects the reasoning, argues once, and then adopts one of your drills.
   <sub>resilience +1; intelligence +2; leadership +1; rel coach +1; mods focused</sub>

3. **Get to know him first** (25 words)
   Lunch, his story, his family, before you judge a single drill. He turns out to be nervous, and the drills make more sense after that.
   <sub>social +2; charisma +1; rel coach +2; mods loose</sub>

<details><summary>Before</summary>

> A new special teams coach arrives with a new way of doing everything.

1. **Try it all**: You try every new drill without complaint. Some of it helps.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Pick what works**: You keep what works and explain why the rest doesn't. He respects the reasoning.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Get to know him**: You get to know him before you judge the drills.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 8. PRO_365 The First Home Repair
*money; premise 33 words*

> The roof leaks the week of a road trip, all over the living room, and the repair estimate is the size of a used car. You're in a hotel two thousand miles away.

1. **Handle it from the hotel** (22 words)
   Contractors, insurance and photos, all handled by phone from the hotel. It gets done, expensively, and you miss a meeting doing it.
   <sub>energy -2; intelligence +2; leadership +1; mods stressed</sub>

2. **Ask {parent} to oversee it** (23 words)
   {parent} drives over with a ladder and an opinion, and oversees the whole repair. He loves being useful, and the roof is perfect.
   <sub>social +1; fun +1; resilience +1; rel parent +3; mods rested</sub>

3. **Patch it for now** (25 words)
   A tarp and a bucket for now, the real fix in the offseason. It's cheap, and you sleep under the sound of dripping all winter.
   <sub>energy +1; health -1; ambition +1; mods distracted</sub>

<details><summary>Before</summary>

> The roof leaks the week of a road trip, and the bill is enormous.

1. **Handle it by phone**: You handle it by phone from the hotel. It gets done, expensively.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Ask {parent} to oversee it**: You ask {parent} to oversee the repair. They love being useful.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Patch it for now**: You patch it for now and deal with it in the offseason.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 9. PRO_366 The Charity Commitment
*community; premise 30 words*

> A children's literacy nonprofit asks you to become a regular supporter: not a photo at the gala, but monthly visits, a reading program, and your name on a library wing.

1. **Commit to monthly visits** (25 words)
   Monthly visits, all year. The kids know your name by spring, and one of them reads you a whole book about a dragon who kicks.
   <sub>energy -2; leadership +2; charisma +1; followers +2; mods inspired</sub>

2. **Bring teammates along** (24 words)
   Teammates, signed up one by one. It becomes a team tradition, and {holder} turns out to be the best reader of all of you.
   <sub>social +2; fun +1; rel holder +2; rel team +1; mods loose</sub>

3. **Write a check** (22 words)
   A generous check and a warm letter. It helps, and the director thanks you sincerely, and you never see the library wing.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A nonprofit asks you to become a regular supporter, not just a photo.

1. **Commit for real**: You commit to monthly visits. The kids know your name by spring.
   <sub>energy -2; social +1; leadership +2; rel team +2; followers +2; skill_points +1; mods inspired</sub>

2. **Bring teammates**: You bring teammates along. It becomes a team tradition.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Stay a donor**: You write a check and stay a donor.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 10. PRO_367 The Radio Segment
*media; premise 25 words*

> A sports radio station offers you a recurring weekly segment: Monday mornings, fifteen minutes, live, with a host who likes to ask about locker-room drama.

1. **Take the segment** (25 words)
   Yes, every Monday at seven. You're good at it, the callers love you, and your Mondays disappear for the whole season into a radio booth.
   <sub>social +2; energy -1; charisma +2; followers +4; mods spotlight</sub>

2. **Try it for a month** (22 words)
   A one-month trial, then a decision. You keep it, shorter, with a promise from the host to leave the locker room alone.
   <sub>intelligence +2; charisma +1; followers +2; mods focused</sub>

3. **Keep your Mondays** (20 words)
   No segment. You'd rather talk about kicking with other kickers, and your Monday mornings stay quiet, slow and entirely yours.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You're offered a recurring weekly segment on sports radio.

1. **Take it**: You say yes. You're good at it, and your Tuesdays disappear.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Try it for a month**: You sign up for a month and then decide. You keep it, shorter.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Decline**: You decline. You'd rather talk about kicking with kickers.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 11. PRO_369 The Former Teammate
*social; premise 28 words*

> A former teammate can't find another job in the league and keeps calling: late at night, after he's watched your games, asking if you've heard anything from anyone.

1. **Keep picking up** (22 words)
   Every call, picked up. Mostly he needs someone to listen, and some nights you stay on the phone until he's laughing again.
   <sub>social +2; energy -1; resilience +1; rel team +2; mods drained</sub>

2. **Help him find other work** (27 words)
   Calls to people you know about jobs outside football: coaching, sales, broadcasting. One of them works out, and he sends you a photo from his new desk.
   <sub>energy -1; intelligence +1; leadership +2; mods focused</sub>

3. **Let some calls go** (22 words)
   Some calls go to voicemail. You feel bad about it every time, and you call back on Sundays, which helps a little.
   <sub>energy +2; fun +1; mods distracted</sub>

<details><summary>Before</summary>

> A former teammate can't find another job in the league and keeps calling.

1. **Keep picking up**: You keep picking up. Mostly he needs someone to listen.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Help him find work**: You call people you know about jobs outside football. One works out.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Let it go to voicemail**: You let it go to voicemail sometimes. You feel bad about it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_370 The New Neighborhood
*community; premise 34 words*

> You've lived on this street for two years and know nobody's name. There's a block party flyer on your door and a kid next door who kicks a ball against your garage every afternoon.

1. **Go to the block party** (29 words)
   The block party, with a casserole you bought. By the end of the night you know every name on the street, and the neighbors start bringing food after losses.
   <sub>social +3; fun +1; rel best_friend +1; mods loose</sub>

2. **Help with the youth league** (26 words)
   The neighborhood youth league gets a volunteer coach once a week. The kid next door is on your team, and he's terrible, and you love it.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

3. **Keep to yourself** (21 words)
   You keep to yourself. It's quiet and private, and a little lonely when the street fills with music on Saturday nights.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> You can get involved in your neighborhood or stay a stranger on your own street.

1. **Knock on doors**: You introduce yourself up and down the street. The neighbors bring food after a loss.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

2. **Help with the youth league**: You help coach the neighborhood youth league once a week.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep to yourself**: You keep to yourself. It's quiet, and a little lonely.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 13. PRO_371 The Financial Mistake
*money; premise 32 words*

> An investment you were sure about turns out not to be smart: a restaurant that closed, a fund that froze, a statement you read three times in the car outside the facility.

1. **Cut the loss** (22 words)
   The loss, cut cleanly, and a lesson learned. It stings for a month, and then it becomes a story you tell rookies.
   <sub>fun -1; resilience +2; intelligence +2; mods focused</sub>

2. **Tell {love_interest} everything** (27 words)
   Everything, at the kitchen table, including the part you were embarrassed about. It's a hard talk and a good one, and you make the next decision together.
   <sub>social +1; energy -1; leadership +1; rel parent +2; mods drained</sub>

3. **Bury it in work** (23 words)
   Work, to forget it: early mornings, long sessions, no thinking. It doesn't quite work, and the statement is still in the glove box.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

4. **Call the advisor you trust** *(locked: having learned about money the hard way)* (30 words)
   The one advisor who has always told you the truth gets a call that afternoon. You make a plan together, you stick to it, and the hole closes by spring.
   <sub>energy +1; intelligence +2; mods focused</sub>

<details><summary>Before</summary>

> An investment or a purchase wasn't as smart as it looked.

1. **Cut the loss**: You cut the loss and learn from it. It stings for a month.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Tell {love_interest}**: You tell {love_interest} the whole thing. It's a hard talk and a good one.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Make it back**: You throw yourself into work to forget it. It doesn't quite work.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

4. **Call the advisor you trust**: You call the one advisor who has always told you the truth. You make a plan, and you stick to it.
   <sub>energy +1; intelligence +2; mods focused</sub>

</details>

## 14. PRO_373 The Family Business
*money; premise 30 words*

> A cousin wants your money and your name to expand the family store into three towns. The whole family is waiting for your answer, and Thanksgiving is in two weeks.

1. **Invest** (27 words)
   You invest and put your name on the sign. The opening is a family party, and for the first time in years, everyone is in one room.
   <sub>social +2; fun +2; leadership +1; rel parent +4; mods loose; flags family_business</sub>

2. **Invest, quietly** (23 words)
   You put in money but keep your name off the sign. It's safer, and your cousin is a little hurt by the distance.
   <sub>resilience +1; intelligence +2; mods focused; flags family_business</sub>

3. **Turn the cousin down** (23 words)
   No, as kindly and clearly as you can manage. Thanksgiving is quieter this year, and you're sure it was the right answer, mostly.
   <sub>energy +1; fun -1; ambition +1; rel parent -1; mods rested</sub>

<details><summary>Before</summary>

> A cousin wants your money and your name to expand the family store into three towns. The whole family is waiting for your answer.

1. **Invest**: You invest and put your name on the sign. The opening is a family party, and for the first time in years, everyone is in one room.
   <sub>social +2; charisma +1; rel parent +4; mods loose; flags family_business</sub>

2. **Invest, quietly**: You put in money but keep your name off the sign. It's safer, and your cousin is a little hurt by the distance.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags family_business</sub>

3. **Say no**: You say no, kindly and clearly. Thanksgiving is quieter this year, and you're sure it was the right answer, mostly.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 15. PRO_374 The Memorabilia Deal
*money; premise 32 words*

> A memorabilia collector wants to pay you to sign five hundred footballs in one afternoon, in a hotel ballroom, with a man counting and a camera to prove each one is real.

1. **Sign all five hundred** (23 words)
   Five hundred signatures in one long afternoon. Your hand hurts for days, the check is large, and the man counting never smiles once.
   <sub>energy -2; toughness +1; ambition +2; mods tired</sub>

2. **Add a hundred for charity** (27 words)
   All five hundred, plus a hundred extra for the children's hospital auction. The auction raises more than your check, and the collector pays for the extra hundred.
   <sub>social +1; leadership +2; charisma +1; followers +2; mods inspired</sub>

3. **Sign for kids at the fence** (21 words)
   No ballroom, no counting man. You'd rather sign for kids at the practice fence, for free, and you do, every Thursday.
   <sub>energy +1; fun +2; social +1; mods loose</sub>

<details><summary>Before</summary>

> A collector wants to pay you to sign five hundred footballs.

1. **Sign them all**: You sign all five hundred in one long afternoon. Your hand hurts for days.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Sign some for charity**: You sign them and ask for a hundred extra for the children's hospital.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

3. **Pass**: You pass. You'd rather sign them for kids at the fence.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_375 The Young Kicker's Question
*social; premise 35 words*

> A college kicker emails you for career advice. It's a long email, carefully written, and the question at the end is a good one: how do you know when to change and when to wait?

1. **Write a real answer** (27 words)
   A long, honest answer, written over two evenings. He prints it out, and two years later he sends you a photo of it taped inside his locker.
   <sub>energy -1; leadership +2; intelligence +1; mods inspired</sub>

2. **Call him instead** (28 words)
   A phone call instead of an email. You talk for an hour, and he sounds exactly like you did at twenty, which is strange and a little moving.
   <sub>social +2; fun +1; charisma +1; rel backup +1; mods loose</sub>

3. **Send a short reply** (21 words)
   A short, kind reply and a 'good luck'. He's grateful, and you wonder later what the longer answer would have been.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A college kicker emails you for career advice, and it's a good question.

1. **Write a real answer**: You write a long, honest answer. He prints it out.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Call him**: You call him instead. You talk for an hour.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Send a short reply**: You send a short reply and a good luck.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 17. PRO_376 The Retirement Savings
*money; premise 26 words*

> A financial advisor reviews your long-term plan and asks a question you can't answer: what does your life cost after football, per year, in today's money?

1. **Learn the answer** (26 words)
   The answer, learned over two weeks of spreadsheets, and the next ten questions too. You understand your own money for the first time, and it's calming.
   <sub>intelligence +2; leadership +1; mods focused; flags honest_advisor</sub>

2. **Bring {parent} to the next meeting** (27 words)
   {parent} comes to the next meeting with a legal pad and better questions than yours. You make the plan together, and he insists on paying for lunch.
   <sub>social +2; intelligence +1; rel parent +3; mods loose</sub>

3. **Trust the advisor** (20 words)
   The advisor knows best, you decide, and stop asking questions. It's easy and restful, and you never learn the number.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A financial advisor reviews your long-term plan and asks a question you can't answer.

1. **Learn the answer**: You learn the answer, and the next ten questions too.
   <sub>energy -1; resilience +1; intelligence +2; mods focused; flags honest_advisor</sub>

2. **Bring {love_interest}**: You bring {love_interest} to the next meeting. You make the plan together.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Trust the advisor**: You trust the advisor and stop asking questions.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 18. PRO_377 The Public Appearance
*media; premise 27 words*

> You're invited to a high-profile charity gala in black tie: actors, owners, a senator, a string quartet. You don't own a tuxedo, and the event is Saturday.

1. **Go and enjoy it** (29 words)
   A rented tuxedo, a long night and people you didn't know existed. You enjoy it more than you expected, and someone from a children's charity asks for your number.
   <sub>social +2; fun +2; charisma +1; followers +2; mods loose</sub>

2. **Go with a purpose** (21 words)
   A plan, three introductions, and home by eleven. You leave with three useful numbers and a sponsor for your youth camp.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Stay home** (24 words)
   Home, in sweatpants, with takeout and a movie. Nobody at the gala notices except your agent, who sends a single sad emoji at midnight.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You're asked to attend a high-profile event in a suit you don't own yet.

1. **Go and enjoy it**: You buy the suit and enjoy the night. You meet people you didn't know existed.
   <sub>social +2; charisma +1; rel love_interest +3; followers +2; mods loose</sub>

2. **Go and network**: You go with a plan and leave with three useful numbers.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Skip it**: You skip it and stay home. Nobody notices but your agent.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 19. PRO_378 The Family Holiday
*family; premise 28 words*

> The schedule lands on a family holiday again, the third year in a row. {parent} has already set a place for you at the table, just in case.

1. **Bring the holiday to you** (24 words)
   The whole family, flown in for the weekend. Dinner is in a hotel ballroom, and it's still home, and {sibling} carves the turkey badly.
   <sub>social +2; fun +2; energy -2; rel parent +3; rel sibling +2; mods inspired</sub>

2. **Keep your routine and call** (21 words)
   Your routine, and a long call between meetings. They put you on speaker at the table, and you hear everyone laughing.
   <sub>energy +1; resilience +1; ambition +1; rel parent +1; mods focused</sub>

3. **Plan a second celebration** (23 words)
   A second holiday, planned for the bye week, with everything: the dishes, the games, the arguments. Everyone says it's fine. It mostly is.
   <sub>social +1; intelligence +1; leadership +1; rel parent +2; mods rested</sub>

<details><summary>Before</summary>

> The schedule lands on a family holiday again.

1. **Bring the holiday to you**: You fly the family in for the weekend. Dinner is in a hotel, and it's still home.
   <sub>social +2; charisma +1; rel parent +4; mods loose</sub>

2. **Keep your routine**: You keep your routine and call between meetings.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Celebrate a day late**: You plan a celebration for the day after. Everyone says it's fine. It mostly is.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 20. PRO_379 The Teammates' Dispute
*team; premise 33 words*

> Two teammates ask you to settle an argument about who gets the corner locker by the heater. It's been going on for a week, and they both say you're the only fair one.

1. **Make them talk it out** (26 words)
   Both of them, in a room, talking it out in front of you. It takes forty minutes, ends with a handshake, and they decide to share.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

2. **Pick the right side** (21 words)
   The right side, after listening to both. One of them sulks for a week, and then admits you were right, grudgingly.
   <sub>resilience +1; intelligence +2; rel team -1; mods focused</sub>

3. **Let them settle it** (21 words)
   Settle it yourselves, you tell them, and walk away. They do, eventually, with a coin flip, some shouting and a handshake.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Two teammates ask you to settle an argument, which means picking a side.

1. **Make them talk it out**: You make them talk it out in front of you. It works.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Pick the right side**: You listen and pick the side that's right. One of them sulks for a week.
   <sub>energy -1; intelligence +2; rel coach +2; rel team -1; mods focused</sub>

3. **Stay out of it**: You tell them to settle it themselves.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 21. PRO_382 The Injury Prevention Program
*health; premise 32 words*

> The club wants you on a new training and recovery program: sleep tracking, cold tubs, a mobility routine at six in the morning. The sports science staff is very excited about it.

1. **Follow it to the letter** (22 words)
   Every piece of it, exactly. Your legs feel younger by October, and the sports science staff starts using your numbers in presentations.
   <sub>energy -1; health +3; toughness +1; rel coach +1; mods focused</sub>

2. **Add your own work** (22 words)
   The program, plus your own work on top. You're stronger and more tired, and the staff worries quietly about the extra load.
   <sub>energy -3; power +2; ambition +1; skill_points +2; mods dialed_in</sub>

3. **Do the minimum** (22 words)
   The minimum: the cold tubs, never the six o'clock mobility. The trainers notice right away, and so, by December, does your hip.
   <sub>energy +2; fun +1; health -1; mods rested</sub>

<details><summary>Before</summary>

> The club wants you on a new training and recovery routine.

1. **Follow it exactly**: You follow it exactly. Your legs feel younger by October.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Add your own work**: You do it and add your own work on top. You're stronger, and tired.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Do the minimum**: You do the minimum. The trainers notice.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 22. PRO_383 The Younger Teammate's Mistake
*team; premise 29 words*

> A rookie makes a mistake: he missed a meeting, then lied about why. He comes to you, not the coaches, white-faced, asking what to do before anyone finds out.

1. **Walk him to the coaches** (27 words)
   Down the hall, together, and you stand beside him while he tells them. It goes better than he feared, and he never lies to a coach again.
   <sub>energy -2; leadership +3; rel coach +1; rel team +1; skill_points +1; mods inspired</sub>

2. **Listen first** (20 words)
   Listening first, all of it, and then helping him find the words. He goes in alone, which matters to him.
   <sub>social +2; resilience +1; charisma +1; rel backup +2; mods loose</sub>

3. **Tell him what you'd do** (21 words)
   Exactly what you'd do, step by step. He does it, it works, and he thanks you without quite looking at you.
   <sub>intelligence +2; leadership +1; mods focused</sub>

<details><summary>Before</summary>

> A rookie makes a mistake and comes to you, not the coaches.

1. **Walk him to the coaches**: You walk him to the coaches and stand beside him while he tells them.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Listen first**: You listen first and help him find the words.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Tell him what you'd do**: You tell him exactly what you'd do. He does it.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 23. PRO_384 The Personal Trainer
*training; premise 26 words*

> A private trainer who works with three Olympic athletes could change your whole offseason, for a price that makes your advisor wince. They have one opening.

1. **Hire the trainer** (22 words)
   Hired, for the summer. It's brutal and scientific, and you come back to camp faster, leaner and slightly afraid of the trainer.
   <sub>energy -3; power +1; toughness +1; ambition +1; skill_points +3; mods dialed_in</sub>

2. **Ask for a trial week** (23 words)
   A trial week first. It's good, so you hire them for half the summer, and keep the other half for your own work.
   <sub>energy -1; accuracy +1; intelligence +2; skill_points +1; mods focused</sub>

3. **Train the way you always have** (21 words)
   Your own routine, the one that got you here. It's familiar and cheaper, and you wonder all summer what you're missing.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A private trainer could change your offseason, for a price.

1. **Hire the trainer**: You hire the trainer. The summer is brutal, and you come back faster.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Ask for a trial week**: You ask for a trial week first. It's good, and you hire them for half the summer.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Train on your own**: You train on your own, the way you always have.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 24. PRO_385 Dinner With Influential People
*career; premise 26 words*

> Your agent invites you to a private dinner with influential people in the league: two owners, a network executive and a former commissioner. Dress code: 'nice'.

1. **Be yourself** (21 words)
   Good stories, honestly told, and you laugh at your own mistakes. Two of the owners remember your name the next season.
   <sub>social +2; charisma +2; followers +1; mods loose</sub>

2. **Mostly listen** (23 words)
   Mostly listening. You learn how the league actually works, who decides what and why, and you write it all down in the car.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Skip the dinner** (20 words)
   No dinner. Your agent sighs and goes alone, and comes back with a story about you that isn't quite true.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> Your agent invites you to dinner with influential people in the league.

1. **Go and be yourself**: You go and tell good stories. Two of them remember your name.
   <sub>social +2; charisma +1; rel team +1; followers +1; mods loose</sub>

2. **Go and listen**: You go and mostly listen. You learn how the league actually works.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Stay home**: You stay home. Your agent sighs and goes alone.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 25. PRO_387 The Team's Future
*career; premise 29 words*

> The franchise is talking about a full rebuild: younger, cheaper, faster. A reporter says there's a list of veterans who might be traded, and your name is on it.

1. **Make yourself essential** (20 words)
   The one veteran they can't rebuild without: that's the plan, and you work like it. The list changes by spring.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Have your agent find out** (24 words)
   Your agent finds out which list it is. It's the good one, for now, and you breathe for the first time in a week.
   <sub>energy +1; intelligence +2; mods focused</sub>

3. **Invest in the young players** (20 words)
   The young players get your time, because they're the future and so, maybe, are you. The coaches notice who's helping.
   <sub>energy -2; leadership +2; charisma +1; rel backup +2; rel team +1; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> The franchise is talking about a full rebuild, and your name is on a list.

1. **Make yourself essential**: You make yourself the one veteran they can't rebuild without.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Ask your agent to find out**: You ask your agent to find out which list it is. It's the good one, for now.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Help the young players**: You help the young players, because they're the future and so, maybe, are you.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 26. PRO_388 The New Family Responsibility
*family; premise 27 words*

> A family member needs more of your time than the season has: {sibling} is going through a divorce, and calls every night after the kids are asleep.

1. **Make the time** (24 words)
   Flights on off days, calls every night. You're exhausted and present, and {sibling} says later that you were the reason they got through it.
   <sub>social +2; energy -3; rel sibling +6; mods drained</sub>

2. **Build a plan with the family** (23 words)
   A family plan, so nobody carries it alone: {parent} takes Mondays, you take Thursdays, everyone takes Sunday. It works better than anyone hoped.
   <sub>intelligence +2; leadership +1; rel sibling +3; rel parent +2; mods focused</sub>

3. **Promise the offseason** (20 words)
   The offseason, promised, and kept. It's a long wait for both of you, and the calls in between are short.
   <sub>energy +1; ambition +1; rel sibling -1; mods rested</sub>

<details><summary>Before</summary>

> A family member needs more of your time than the season has.

1. **Make the time**: You make the time: flights on off days, calls every night. You're exhausted and present.
   <sub>social +2; charisma +1; rel parent +5; mods loose</sub>

2. **Build a plan with family**: You build a plan with the rest of the family so nobody carries it alone.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Wait for the offseason**: You promise the offseason and keep the promise. It's a long wait for both of you.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 27. PRO_630 The Fourth Season
*career; premise 29 words*

> Your fourth pro season. Nobody calls you a rookie anymore, the equipment manager knows your cleat size by heart, and two of this year's rookies ask for your autograph.

1. **Look out for the rookies** (21 words)
   The rookies get looked after, the way someone once looked after you: rides, meals, the names of the people who matter.
   <sub>energy -2; leadership +2; charisma +1; rel backup +2; skill_points +1; mods inspired</sub>

2. **Raise your own bar** (22 words)
   Nobody else will raise your bar now, so you do it yourself: new goals, written down and taped to the bathroom mirror.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Enjoy the ease** (22 words)
   Some ease, finally earned. You enjoy this season more than any before it, and the snapper says you look five years younger.
   <sub>energy +2; fun +2; mods rested</sub>

<details><summary>Before</summary>

> Your fourth pro season, and nobody calls you a rookie anymore.

1. **Look out for the rookies**: You look out for the rookies the way someone once looked out for you.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Raise your own bar**: You raise your own bar. Nobody else will now.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Enjoy it**: You enjoy it. You've earned some ease.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 28. PRO_631 The Comfortable Routine
*training; premise 33 words*

> Your routine works so well it's starting to feel like a rut. Same breakfast, same warmup, same thoughts at the same moments. You haven't felt nervous in a month, and you miss it.

1. **Change one small thing** (23 words)
   One small change: a different song in your warmup. It's enough to wake you up, and your first kick that day feels new.
   <sub>fun +2; accuracy +1; intelligence +1; mods focused</sub>

2. **Push harder inside it** (22 words)
   Harder, inside the exact same routine. It's tiring, and it works, and slowly the rut starts to feel like a groove again.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Trust the rut** (20 words)
   A rut that works is a groove, you decide, and you trust it. The season goes on quietly and well.
   <sub>energy +2; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> Your routine works so well it's starting to feel like a rut.

1. **Change one small thing**: You change one small thing. It's enough to wake you up.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Push harder**: You push harder inside the routine. It's tiring and it works.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Trust the rut**: You trust the rut. A rut that works is a groove.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_632 The Raise
*money; premise 27 words*

> Your second contract is real money, and everyone you know has noticed: old friends with ideas, cousins with emergencies, a teacher from middle school with a fundraiser.

1. **Set one rule for everyone** (20 words)
   One rule, for everyone, written down. It's fair, it's a little lonely, and the calls slow down within a month.
   <sub>intelligence +2; leadership +1; mods focused</sub>

2. **Help the ones who need it** (22 words)
   The people who really need it get help, quietly, and nobody else hears about it. {parent} finds out anyway and is proud.
   <sub>social +1; fun +1; charisma +1; rel parent +3; mods inspired</sub>

3. **Change your number** (22 words)
   A new phone number, given to twelve people. Things get quieter immediately, and two old friends feel shut out and say so.
   <sub>energy +2; resilience +1; rel best_friend -1; mods rested</sub>

<details><summary>Before</summary>

> Your second contract is real money, and everyone you know has noticed.

1. **Set a rule for everyone**: You set one rule for everyone and stick to it. It's fair and a little lonely.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Help a few people**: You help a few people who really need it.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Change your number**: You change your phone number. Things get quieter.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 30. PRO_633 The House With a Yard
*family; premise 29 words*

> You buy a house with a backyard big enough for a kicking net. The previous owners left a swing set, a lemon tree and a note wishing you luck.

1. **Put up the net** (23 words)
   The net goes up the first weekend. The neighbors watch from their windows, and by Sunday their kids are shagging balls for you.
   <sub>energy -1; accuracy +1; ambition +1; skill_points +1; mods dialed_in</sub>

2. **Throw a housewarming** (20 words)
   Everyone, over, the first Saturday: family, teammates, neighbors. {parent} gives the tour twice, and {sibling} falls off the swing set.
   <sub>social +3; fun +2; rel parent +2; rel sibling +2; mods loose</sub>

3. **Sit under the lemon tree** (23 words)
   Nothing, in the backyard, under the lemon tree, for a whole afternoon. It's the first time in years you've done nothing on purpose.
   <sub>energy +3; health +1; mods rested</sub>

<details><summary>Before</summary>

> You buy a house with a yard big enough for a kicking net.

1. **Put up the net**: You put up the net the first weekend. The neighbors watch.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Have everyone over**: You have everyone over for a housewarming. {parent} gives the tour.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Enjoy the quiet**: You sit in the yard and do nothing for the first time in years.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 31. PRO_634 The Specialist Who Retires
*team; premise 26 words*

> The punter you've worked beside for six years retires suddenly, with a two-line statement on a Tuesday afternoon. He hasn't returned anyone's calls since, including yours.

1. **Throw him a send-off** (23 words)
   A send-off with the specialists at his favorite diner, whether he likes it or not. He comes, finally, and it's loud and long.
   <sub>social +2; fun +2; energy -1; rel team +2; rel holder +1; mods loose</sub>

2. **Help the new punter settle** (20 words)
   The new punter gets your time and the old punter's tricks, passed along. The unit stays steady through the change.
   <sub>energy -2; leadership +2; rel backup +2; skill_points +1; mods inspired</sub>

3. **Give him his quiet** (21 words)
   His quiet, respected. You send one short message and wait, and a month later he calls you first, from a lake.
   <sub>energy +1; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> The punter you've worked beside for years retires suddenly.

1. **Throw him a send-off**: You throw him a send-off with the specialists. It's loud and long.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Help the new punter**: You help the new punter settle in. The unit stays steady.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Say goodbye quietly**: You say goodbye quietly and keep in touch.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 32. PRO_635 A Different Snap
*training; premise 37 words*

> A new long snapper arrives, and for the first time in years your timing is off. The ball comes faster, flatter, with a spin you don't recognize, and the misses are in practice for everyone to see.

1. **Rep it out after practice** (23 words)
   After every practice, an extra fifty snaps until the timing is back. Your leg is heavy and your rhythm returns by week three.
   <sub>energy -3; accuracy +1; ambition +1; skill_points +3; mods heavy_legs</sub>

2. **Get to know him first** (23 words)
   Off the field first: dinners, his family, his terrible music. The timing follows the trust, the way it always does, within two weeks.
   <sub>social +2; charisma +1; rel team +2; mods loose</sub>

3. **Film every snap** (22 words)
   Every snap, filmed and studied. You find the tenth of a second in the film room, and fix it in one afternoon.
   <sub>energy -1; accuracy +1; intelligence +2; mods focused</sub>

<details><summary>Before</summary>

> A new long snapper, and your timing is off for the first time in years.

1. **Rep it out**: You rep it out after every practice until the timing is back.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Get to know him**: You get to know him off the field first. The timing follows.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Film every snap**: You film every snap and find the tenth of a second.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 33. PRO_641 The Podcast Guest Spot
*media; premise 26 words*

> A popular podcast wants you as a weekly guest. The host likes controversy and has a reputation for getting athletes to say things about their teammates.

1. **Set your terms first** (21 words)
   Terms, agreed up front: no teammates, no coaches, no locker room. It's good radio anyway, and the host respects the line.
   <sub>intelligence +2; leadership +1; followers +2; mods focused</sub>

2. **Say yes and wing it** (24 words)
   Yes, and you're great at it, until the fourth episode, when you say too much about a teammate. You apologize to him in person.
   <sub>social +2; fun +1; charisma +2; rel team -1; followers +5; mods spotlight</sub>

3. **Pass on the podcast** (20 words)
   No podcast this year. The host finds another kicker, who says something he regrets by October, and you're quietly relieved.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A podcast wants you every week, and the host likes controversy.

1. **Set your terms**: You agree on terms: no teammates, no coaches. It's good radio.
   <sub>energy -1; intelligence +2; rel coach +2; followers +2; mods focused</sub>

2. **Say yes**: You say yes and say too much once. You apologize to a teammate.
   <sub>social +2; charisma +1; rel team -1; followers +5; mods loose</sub>

3. **Decline**: You decline. The host finds another kicker.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 34. PRO_642 The Teammate Who Becomes a Friend
*social; premise 34 words*

> A teammate has become your closest friend in the league: same humor, same bad taste in movies, families who get along. You realize it on a road trip, laughing at three in the morning.

1. **Make time for it** (20 words)
   Time, made on purpose: dinners, families, the off days together. The friendship becomes the best part of the whole job.
   <sub>social +3; fun +1; rel team +3; mods loose</sub>

2. **Train together all summer** (21 words)
   A whole summer of training together, every morning. You both get better, and the friendship gets a rhythm of its own.
   <sub>energy -2; power +1; ambition +1; rel team +1; skill_points +2; mods dialed_in</sub>

3. **Keep it easy** (22 words)
   No effort required, and none spent. Some friendships don't need any work at all, and this one never does, even years later.
   <sub>energy +2; fun +2; mods rested</sub>

<details><summary>Before</summary>

> A teammate becomes your closest friend in the league.

1. **Make time for it**: You make time: dinners, families, the off days.
   <sub>social +2; charisma +1; rel team +5; mods loose</sub>

2. **Train together**: You train together in the offseason. You both get better.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Keep it easy**: You keep it easy. Some friendships don't need work.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 35. PRO_643 The Holder's Wedding
*social; premise 26 words*

> {holder} asks you to be in the wedding party. It's in June, in {holder}'s hometown, and there's a rehearsal dinner where you're expected to say something.

1. **Say yes and give a toast** (23 words)
   Yes, and a toast at the rehearsal dinner that nobody forgets: the first hold, the bad haircut, the night they saved your season.
   <sub>social +2; charisma +2; rel holder +5; mods inspired</sub>

2. **Organize the weekend** (23 words)
   The whole weekend, organized by you: the hotel block, the shuttle, the backup suits. {holder} doesn't lift a finger and cries about it.
   <sub>energy -2; leadership +2; intelligence +1; rel holder +3; mods focused</sub>

3. **Show up and enjoy it** (22 words)
   Showing up, standing where they tell you, dancing badly at the reception. You enjoy every minute, and {holder} says it was perfect.
   <sub>energy +1; fun +3; rel holder +2; mods rested</sub>

<details><summary>Before</summary>

> {holder} asks you to be in the wedding party.

1. **Say yes with joy**: You say yes and give a toast nobody forgets.
   <sub>social +2; charisma +1; rel holder +5; mods loose</sub>

2. **Organize the weekend**: You organize the whole weekend so {holder} doesn't have to.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Show up, enjoy it**: You show up, stand where they tell you and enjoy the day.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 36. PRO_644 The Fan Club
*media; premise 32 words*

> Fans start an official fan club in your name, with T-shirts and a newsletter. They want you at the first meeting, in the back room of a pizza place on a Tuesday.

1. **Go to the meeting** (23 words)
   Two hours in the back room of the pizza place. They make you an honorary member, and the T-shirt becomes your favorite shirt.
   <sub>social +2; fun +2; charisma +1; followers +4; mods loose</sub>

2. **Send a message and a ball** (20 words)
   A recorded message and a signed ball for the raffle. They play the message three times and frame the ball.
   <sub>resilience +1; intelligence +1; charisma +1; followers +2; mods focused</sub>

3. **Thank them online** (24 words)
   A thank-you post, and your Tuesday stays your own. The club grows anyway, without you, which feels a little strange and kind of nice.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Fans start an official fan club, and they want you at the first meeting.

1. **Go to the meeting**: You go and stay two hours. They make you an honorary member.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Send a message**: You send a recorded message and a signed ball.
   <sub>energy -1; intelligence +2; rel coach +2; followers +2; mods focused</sub>

3. **Thank them online**: You thank them online and keep your evening.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 37. PRO_645 The Rival's Big Contract
*media; premise 25 words*

> {tyler} signs a bigger contract than yours, by a lot, and the media want a comment. A reporter reads you the number, slowly, and waits.

1. **Congratulate him** (23 words)
   Congratulations, publicly, and you mean it. He texts you thanks within the hour and a photo of the two of you at seventeen.
   <sub>social +2; resilience +1; charisma +1; rel rival +4; mods loose</sub>

2. **Decline to comment** (22 words)
   No comment, politely, and you walk away from the cameras. It makes a headline anyway: 'Kicker silent on rival's huge new deal.'
   <sub>energy +1; intelligence +1; mods focused</sub>

3. **Keep the number private** (26 words)
   The number, written on a card, goes inside your locker where only you can see it. Every practice that month has a little more in it.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> {tyler} signs a bigger contract than yours, and the media want a comment.

1. **Congratulate him**: You congratulate him, and mean it. He texts you thanks.
   <sub>social +2; charisma +1; rel rival +4; mods loose</sub>

2. **Say nothing**: You decline to comment. It makes a headline anyway.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Use it**: You put the number on your locker where only you can see it.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 38. PRO_646 The Charity Golf Tournament
*community; premise 25 words*

> You host your own charity golf tournament for the first time: thirty-six foursomes, a silent auction, and a sponsor who keeps asking for 'more visibility'.

1. **Run it yourself** (22 words)
   Every detail, run by you, from the sign-up sheet to the last trophy. You're exhausted, and the tournament raises twice the goal.
   <sub>energy -3; leadership +2; intelligence +1; charisma +1; followers +2; mods inspired</sub>

2. **Invite the old college crew** (20 words)
   Your college teammates, invited, and {best_friend} runs the auction. It turns into a reunion, and the bidding gets very competitive.
   <sub>social +3; fun +2; rel best_friend +4; mods loose</sub>

3. **Find a sponsor to run it** (21 words)
   A sponsor who covers everything and handles the details. It raises more than you'd have alone, and feels less like yours.
   <sub>resilience +1; intelligence +2; mods focused</sub>

<details><summary>Before</summary>

> You host a charity golf tournament for the first time.

1. **Run it yourself**: You run it yourself, from the sign-up sheet to the last trophy.
   <sub>energy -2; social +1; leadership +2; rel team +2; followers +2; skill_points +1; mods inspired</sub>

2. **Invite the old crew**: You invite your college teammates. It turns into a reunion.
   <sub>social +2; charisma +1; rel best_friend +4; mods loose</sub>

3. **Find a sponsor**: You find a sponsor to cover the costs. It raises twice as much.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 39. PRO_647 The Investment Club
*money; premise 33 words*

> A group of teammates forms an investment club: monthly meetings, a shared account, a lot of opinions about technology stocks. They want you in, and the first meeting is at the quarterback's house.

1. **Join the club** (20 words)
   Joined. The meetings are mostly jokes and some good ideas, and the account does fine, and the friendships do better.
   <sub>social +2; fun +1; rel team +3; mods loose</sub>

2. **Join with limits** (26 words)
   In, with a small amount and one rule: nothing you don't understand. You end up explaining index funds to a linebacker, who becomes your biggest convert.
   <sub>resilience +1; intelligence +2; rel coach +2; mods focused; flags honest_advisor</sub>

3. **Keep money and friends apart** (20 words)
   Money and friends don't mix, for you. You stay out, politely, and still go to the meetings for the food.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A group of teammates forms an investment club and wants you in.

1. **Join the club**: You join. The meetings are mostly jokes and some good ideas.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Join with limits**: You join with a small amount and one rule: nothing you don't understand.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused; flags honest_advisor</sub>

3. **Stay out**: You stay out. Money and friends don't mix for you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>


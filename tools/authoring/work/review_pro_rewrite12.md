# PRO rewrite pass 12: era-3 scenes 118-150

The last 33 era-3 scenes: family with kids, partner scenes, business disputes, contract and new-club scenes of the thirties, and the long-career milestones (ten years, the records board, the ring of honor). Era 3 is now fully rewritten.

Dry run and import: 33 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 33 of 33.**

**Standing costs removed** (routine choices): PRO_703 "Ask to miss a day" (-1).

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_393 The Family Schedule
*family; premise 29 words*

> Your kids' games and your schedule are in a war you keep losing: soccer on Saturdays, recitals on Thursdays, and a road trip every other weekend of the fall.

1. **Make every game you can** (32 words)
   Every game you can make, even if it means a red-eye and a nap in the car. The kids look for you in the stands, and find you more often than not.
   <sub>social +2; energy -3; rel love_interest +3; rel parent +1; mods inspired</sub>

2. **Plan the season on one calendar** (24 words)
   One big calendar on the kitchen wall, with every game, recital and road trip in different colors. It's chaos made visible, and it helps.
   <sub>intelligence +2; leadership +1; rel parent +1; mods focused</sub>

3. **Watch the videos after practice** (25 words)
   The videos, watched in the locker room after practice, every one. It's not the same, and the kids know it, and they send them anyway.
   <sub>resilience +1; ambition +2; rel love_interest -1; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Your kids' games and your schedule are in a war you keep losing.

1. **Make every game you can**: You make every game you can, even if it means a red-eye.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Plan the season together**: You plan the season together on a big calendar.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Watch the videos**: You watch the videos after practice. It's not the same.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 2. PRO_406 The Family Business Dispute
*money; premise 29 words*

> A business with relatives in it is turning into a family fight: a cousin wants to expand, an uncle wants out, and everyone wants you to decide at Thanksgiving.

1. **Bring in a mediator** (20 words)
   A professional mediator, hired before the holiday. It's expensive and it works, and Thanksgiving is merely awkward instead of explosive.
   <sub>intelligence +2; leadership +1; rel parent +1; mods focused</sub>

2. **Step back from the business** (24 words)
   Out of the business, and into the family. You sell your share to the cousin, and dinner that year is the warmest in years.
   <sub>social +2; resilience +1; rel parent +4; mods loose</sub>

3. **Take charge of it** (24 words)
   In charge, for a season, making the hard calls yourself. It's a lot of work, the business steadies, and a few people stay mad.
   <sub>energy -3; toughness +1; ambition +2; leadership +1; rel parent -1; mods stressed</sub>

<details><summary>Before</summary>

> A business with relatives in it is turning into a family fight.

1. **Bring in a mediator**: You bring in a mediator. It's expensive and it works.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Step back**: You step back from the business and keep the family.
   <sub>social +2; charisma +1; rel parent +4; mods loose</sub>

3. **Take charge**: You take charge. It's a lot of work, and a few people are mad.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 3. PRO_409 The New Home
*family; premise 26 words*

> Your family has outgrown the house: three kids, two dogs, one bathroom that everybody fights over every morning, and a garage completely full of kicking nets.

1. **Let the kids choose their rooms** (23 words)
   A bigger house, and the kids pick their rooms first, loudly. The move is chaotic and happy, and the dogs love the yard.
   <sub>social +2; fun +2; rel love_interest +3; rel parent +2; mods loose</sub>

2. **Add a room instead** (23 words)
   An addition instead of a move, built over the offseason. The kids keep their school and their friends, and you keep your street.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Make it work another year** (21 words)
   One more year in the small house, creatively. It's crowded and warm, you build bunk beds yourself, badly, and {sibling} helps.
   <sub>energy -1; fun +2; leadership +1; rel sibling +2; mods rested</sub>

<details><summary>Before</summary>

> Your family has outgrown the house.

1. **Let the kids choose**: You let the kids pick their rooms first. The move is loud and happy.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Add on instead**: You add a room instead of moving. The kids keep their school.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Make it work**: You make the house work another year. It's crowded and warm.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 4. PRO_413 The Business Partner's Exit
*money; premise 29 words*

> A partner wants out of a business you built together: the restaurant, the dealership, the start-up, whichever it is. He's tired, and he wants his money back by spring.

1. **Buy him out fairly** (25 words)
   A fair buyout, with lawyers and a handshake at the end. He leaves happy, and the business is all yours now, for better and worse.
   <sub>intelligence +2; leadership +1; mods focused</sub>

2. **Sell it together** (22 words)
   You both sell, and split it evenly down the middle. The business goes to new owners, and the friendship stays completely intact.
   <sub>social +2; resilience +1; rel best_friend +3; mods loose</sub>

3. **Run it alone** (23 words)
   Alone, with his share bought on a payment plan. It's more work than you thought, and you learn a great deal about payroll.
   <sub>energy -3; toughness +1; ambition +2; skill_points +1; mods stressed</sub>

<details><summary>Before</summary>

> A partner wants out of a business you built together.

1. **Buy him out fairly**: You buy him out fairly, with lawyers and a handshake.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Sell together**: You both sell and stay friends.
   <sub>social +2; charisma +1; rel best_friend +3; mods loose</sub>

3. **Run it alone**: You run it alone. It's more work than you thought.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 5. PRO_421 The Family Financial Decision
*family; premise 26 words*

> You and {love_interest} disagree about a major purchase: a lake house, two hours away, that one of you loves and the other thinks you'll never use.

1. **Let {love_interest} decide** (20 words)
   Their decision, fully. It's the right call, and you know it the first weekend you sit on the dock together.
   <sub>social +2; fun +1; rel love_interest +4; mods loose</sub>

2. **Sleep on it for a month** (24 words)
   A month, before anyone decides anything at all. The decision makes itself in the end, and neither of you has to win the argument.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Make your case** (26 words)
   Your case, made carefully at the kitchen table with a spreadsheet and a chart. You win, and the house is very quiet for a whole day.
   <sub>leadership +1; ambition +2; rel love_interest -2; mods confident</sub>

<details><summary>Before</summary>

> You and {love_interest} disagree about a major purchase.

1. **Let {love_interest} decide**: You let {love_interest} decide. It's the right call.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Sleep on it**: You agree to wait a month. The decision makes itself.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Make your case**: You make your case. You win, and the house is quiet for a day.
   <sub>energy -2; ambition +2; rel love_interest -2; skill_points +2; mods dialed_in</sub>

</details>

## 6. PRO_426 The Business Reputation
*money; premise 30 words*

> A customer's angry post about your business has been shared all over town, with your face in the picture. Your name is on the sign, so it's your problem now.

1. **Fix the problem** (29 words)
   You find out what actually went wrong, fix it, and say so publicly in plain words. A few people unfollow, more come back, and the manager stops dreading Mondays.
   <sub>intelligence +2; leadership +1; followers +2; mods focused</sub>

2. **Call the customer** (25 words)
   You call the customer yourself. They don't believe it's you at first, then talk for twenty minutes. Their next post is about the phone call.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

3. **Let the managers handle it** (23 words)
   You leave it to the managers. They handle it fine, slowly, and for a month people bring it up whenever they recognize you.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A customer's angry post about your business has been shared all over town, with your face in the picture. Your name is on the sign, so it's your problem now.

1. **Fix the problem**: You find out what actually went wrong, fix it, and say so publicly in plain words. A few people unfollow, more come back, and the manager stops dreading Mondays.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

2. **Call the customer**: You call the customer yourself. They don't believe it's you at first, then talk for twenty minutes. Their next post is about the phone call.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Let the managers handle it**: You leave it to the managers. They handle it fine, slowly, and for a month people bring it up whenever they recognize you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 7. PRO_430 The Next Chapter Conversation
*family; premise 28 words*

> {love_interest} wants to know, over a late dinner, what you picture for life after football. It's a simple question, and you realize you've never answered it out loud.

1. **Picture it together** (25 words)
   The picture, painted together, piece by piece: a town, a porch, a coaching job. It sounds good, and you both go quiet for a while.
   <sub>social +2; resilience +1; rel love_interest +5; mods inspired</sub>

2. **Each make a list** (21 words)
   Two lists, written separately and compared over coffee. They overlap more than you thought, and the differences are interesting, not scary.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Not yet** (21 words)
   Not there yet, you say honestly. {love_interest} waits, patiently, and the question comes back every spring, a little warmer each time.
   <sub>energy +1; ambition +2; rel love_interest -1; mods rested</sub>

<details><summary>Before</summary>

> {love_interest} wants to know what you picture for life after football.

1. **Picture it together**: You picture it together. It sounds good.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Make a list**: You each make a list. They overlap more than you thought.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Not yet**: You say you're not there yet. {love_interest} waits.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 8. PRO_691 Contract Year: The Middle Years
*career; premise 28 words*

> A contract year in your thirties means proving you're not slowing down. The club has a younger kicker on the practice squad, and the general manager mentions it.

1. **Train like a rookie** (23 words)
   All summer, like a rookie: early, hard, hungry. You come back faster than you've been in three years, and the general manager notices.
   <sub>energy -3; power +2; ambition +1; skill_points +3; mods dialed_in</sub>

2. **Show them the numbers** (21 words)
   Your numbers, shown to the club: as good as ever, better in the cold. They agree, grudgingly, and the conversation changes.
   <sub>accuracy +1; intelligence +2; rel coach +1; mods focused</sub>

3. **Keep it calm at home** (20 words)
   Calm at home, on purpose: the contract will come or it won't. You sleep well, and your kicks feel easy.
   <sub>social +1; resilience +2; rel parent +2; mods rested</sub>

<details><summary>Before</summary>

> A contract year in your thirties means proving you're not slowing down.

1. **Train like a rookie**: You train like a rookie all summer.
   <sub>energy -2; resilience +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Show the numbers**: You show the club your numbers. They're as good as ever.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Stay calm at home**: You keep it calm at home. The contract will come or it won't.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 9. PRO_696 The New Club at Thirty
*team; premise 29 words*

> A new club, at thirty-one, and the young players already know your name. Some of them had your poster. One of them asks you to sign his old jersey.

1. **Earn it anyway** (21 words)
   Earned anyway, one practice at a time, as if nobody knew you. The young players respect that more than the poster.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Take the young specialists to lunch** (21 words)
   Lunch, the first week, with every young specialist. By Friday they're asking you everything, and you're the heart of the room.
   <sub>social +2; leadership +1; rel backup +3; rel holder +2; mods loose</sub>

3. **Focus on the job** (26 words)
   Just the job, quietly, and the rest follows on its own. You sign the old jersey, say very little else, and the young players respect it.
   <sub>accuracy +1; resilience +1; intelligence +1; mods focused</sub>

<details><summary>Before</summary>

> A new club, and the young players already know your name.

1. **Earn it anyway**: You earn it anyway, one practice at a time.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Take them to lunch**: You take the young specialists to lunch the first week.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Focus on the job**: You focus on the job. The rest follows.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 10. PRO_701 Kindergarten Morning
*family; premise 31 words*

> Your youngest's first day of kindergarten is a practice day, and the drop-off is at the exact time of the special teams meeting. There's a photo planned by the front door.

1. **Ask to come in late** (22 words)
   An hour, asked of {coach} and granted instantly. You're there for the photo, the backpack and the wave at the classroom door.
   <sub>social +2; fun +1; rel coach +1; rel parent +1; rel sibling +1; mods inspired</sub>

2. **Drop off and race to the meeting** (21 words)
   Drop-off at seven-forty and the special teams meeting at eight-fifteen, barely. You're out of breath, sweaty and very happy all morning.
   <sub>energy -2; intelligence +1; leadership +1; mods focused</sub>

3. **Go to practice** (26 words)
   Practice, and the whole story at dinner, told twice by a very proud five-year-old. You hang on every word and ask for it a third time.
   <sub>resilience +1; ambition +2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Your youngest's first day of kindergarten is a practice day.

1. **Ask to come in late**: You ask {coach} for an hour. You're there for the wave.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Do drop-off and run**: You do drop-off and make it to the meeting with a minute to spare.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Go to practice**: You go to practice and hear about it at dinner.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 11. PRO_702 The Kid's Team
*family; premise 26 words*

> Your kid's youth team needs a coach, and every parent at the meeting slowly turns to look at you. You've never coached nine-year-olds in your life.

1. **Coach the team** (21 words)
   Head coach, with a whistle and a clipboard. It's the most stressful thing you do all year, and the most fun.
   <sub>energy -3; leadership +3; skill_points +1; mods inspired</sub>

2. **Be an assistant** (22 words)
   Assistant coach, which means snacks, cones and a lot of encouragement. It's perfect, and your kid is delighted you're there every week.
   <sub>social +2; fun +2; rel sibling +1; mods loose</sub>

3. **Cheer from the stands** (21 words)
   The stands, loud and proud, every Saturday morning. Another parent coaches, and you bring the orange slices and the folding chairs.
   <sub>energy +2; fun +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Your kid's youth team needs a coach, and everyone looks at you.

1. **Coach the team**: You coach the team. It's the most stressful thing you do all year.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Be an assistant**: You help as an assistant.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

3. **Cheer from the stands**: You cheer from the stands.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_703 The Anniversary Trip
*family; premise 26 words*

> You and {love_interest} have planned an anniversary trip for months, flights and all, and then the club schedules a mandatory minicamp on the same four days.

1. **Ask to miss a day** (23 words)
   A day off minicamp, asked for and granted, grudgingly. You catch the last flight, and the trip is three days instead of four.
   <sub>social +2; fun +2; rel love_interest +5; rel coach -1; mods inspired</sub>

2. **Move the trip** (23 words)
   The trip, moved a week later, with a lot of rebooking and one angry airline. It's a little less magical, and still wonderful.
   <sub>resilience +1; intelligence +2; rel love_interest +2; mods focused</sub>

3. **Go to minicamp** (20 words)
   Minicamp, and a promise of next year instead. {love_interest} understands, and you can tell they're tired of having to understand.
   <sub>energy -1; ambition +2; rel love_interest -2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> You and {love_interest} plan a trip for your anniversary, and the club schedules a minicamp.

1. **Ask to miss a day**: You ask to miss a day. The club agrees, grudgingly.
   <sub>social +2; charisma +1; rel love_interest +5; retention -1; mods loose</sub>

2. **Move the trip**: You move the trip by a week.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Go to minicamp**: You go to minicamp and promise next year.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 13. PRO_704 The Marriage Counselor
*family; premise 25 words*

> You and {love_interest} decide to see a counselor together, before anything's wrong. It was their idea, and you agreed faster than either of you expected.

1. **Commit to it** (25 words)
   You commit to it, every other Tuesday, even in season. It's the best thing you do for the marriage, and you say so out loud.
   <sub>social +2; resilience +1; rel love_interest +5; mods loose</sub>

2. **Go every other week** (22 words)
   You go every other week when the schedule allows. It helps, and you learn how differently you two remember the same arguments.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Try it once** (22 words)
   You go to one session to see what it's like. It's harder than practice, and you leave unsure whether you'll go back.
   <sub>energy +1; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You and {love_interest} decide to see a counselor, before anything's wrong. It was their idea, and you agreed faster than you expected.

1. **Commit to it**: You commit to it, every other Tuesday, even in season. It's the best thing you do for the marriage, and you say so out loud.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Go every other week**: You go every other week when the schedule allows. It helps, and you learn how differently you two remember the same arguments.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Try it once**: You go to one session to see what it's like. It's harder than practice, and you leave unsure whether you'll go back.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 14. PRO_711 The Second Business
*money; premise 30 words*

> You're considering a second business while the first is still finding its feet: a gym this time, with your name on the door and a partner who talks very fast.

1. **Wait a year** (20 words)
   A year's wait, until the first business is steady. The fast-talking partner finds someone else, and you're relieved by spring.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Do both** (21 words)
   Both, at once. You don't sleep much for months, and the gym opens in June to a line around the block.
   <sub>energy -3; ambition +2; leadership +1; mods stressed; flags business_owner</sub>

3. **Ask your first partner** (21 words)
   Your partner in the first business, asked honestly over lunch. The answer is 'please not yet', and you listen to them.
   <sub>social +2; charisma +1; rel best_friend +2; mods loose</sub>

<details><summary>Before</summary>

> You consider a second business, while the first is still finding its feet.

1. **Wait a year**: You wait a year until the first one is steady.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Do both**: You do both. You don't sleep much.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in; flags business_owner</sub>

3. **Ask your partner in the first one**: You ask your partner. The answer is 'please not yet'.
   <sub>social +2; charisma +1; rel best_friend +3; mods loose</sub>

</details>

## 15. PRO_719 The Commercial Shoot
*media; premise 29 words*

> A national commercial shoot, two days in a studio with a famous director who wants you to act: a scene where you kick a ball into a moving truck.

1. **Go for it** (24 words)
   All in on the acting, with real feeling. The commercial is silly and everywhere, and your teammates quote it at you for a year.
   <sub>social +2; fun +2; charisma +1; followers +4; mods spotlight</sub>

2. **Ask for fewer lines** (22 words)
   Fewer lines, you suggest politely, and more kicking. The director agrees after a long pause, and it works much better on screen.
   <sub>resilience +1; intelligence +2; charisma +1; followers +2; mods focused</sub>

3. **Do one take and leave** (20 words)
   One stiff take, and you leave for the airport. The director uses it anyway, and it shows in every frame.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A national commercial shoot, and the director wants you to act.

1. **Go for it**: You go for it. The commercial is silly and everywhere.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Keep it simple**: You ask for fewer lines. It works better.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Do one take**: You do one take and leave. The director uses it, and it's stiff.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_720 The Late-Night Show
*media; premise 27 words*

> A late-night show wants you as a guest during the bye week. The producers want a funny kicker story and maybe a kick on the studio set.

1. **Be funny** (27 words)
   You're funny, mostly at your own expense. The clip goes around the league, and the whole locker room does the bit back at you for a month.
   <sub>social +2; fun +1; charisma +2; rel team +1; followers +4; mods loose</sub>

2. **Bring one story** (27 words)
   You bring one good story about your first pro camp and tell it well. The host stops laughing long enough to say it was a good story.
   <sub>resilience +1; intelligence +2; charisma +1; followers +2; mods focused</sub>

3. **Decline** (24 words)
   You decline and spend the bye week at home. The producers book a punter instead, and he's better on television than you'd have been.
   <sub>energy +3; fun +1; health +1; mods rested</sub>

<details><summary>Before</summary>

> A late-night show wants you as a guest during the bye week. The producers want a funny kicker story and maybe a kick on the studio set.

1. **Be funny**: You're funny, mostly at your own expense. The clip goes around the league, and the whole locker room does the bit back at you for a month.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Bring one story**: You bring one good story about your first pro camp and tell it well. The host stops laughing long enough to say it was a good story.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Decline**: You decline and spend the bye week at home. The producers book a punter instead, and he's better on television than you'd have been.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 17. PRO_738 Baby Number Two
*family; premise 27 words*

> A second child, and the house feels half its size. Everyone is tired, nobody is sleeping, the dog is confused, and the season starts in three weeks.

1. **Take the night shift** (22 words)
   You take the night shifts on your off days. You're exhausted at practice and closer to {love_interest} than you've been in years.
   <sub>social +2; energy -3; rel love_interest +5; mods loose</sub>

2. **Make a plan** (23 words)
   You make a plan for the season, down to who sleeps when. It works about half the time, which is better than nothing.
   <sub>intelligence +2; leadership +1; rel parent +1; mods focused</sub>

3. **Ask the grandparents** (22 words)
   You ask the grandparents to come for a month. Everyone sleeps, and the house is loud and full in the best way.
   <sub>energy +3; fun +1; rel parent +3; mods rested</sub>

<details><summary>Before</summary>

> A second child, and the house feels half its size. Everyone is tired, nobody is sleeping, and the season starts in three weeks.

1. **Take the night shift**: You take the night shifts on your off days. You're exhausted at practice and closer to {love_interest} than you've been in years.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Make a plan**: You make a plan for the season, down to who sleeps when. It works about half the time, which is better than nothing.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Ask the grandparents**: You ask the grandparents to come for a month. Everyone sleeps, and the house is loud and full in the best way.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 18. PRO_739 The School Play
*family; premise 29 words*

> Your kid's school play is the night before a road game. They're playing a tree, with two lines, and they've practiced them on you every night for a month.

1. **Go to the play** (23 words)
   The play, front row, and a late flight to join the team. You know both lines by heart, and you mouth them along.
   <sub>social +2; energy -2; rel love_interest +5; mods inspired</sub>

2. **Watch the dress rehearsal** (20 words)
   The dress rehearsal, the afternoon before, front row of an empty gym. Your kid performs the tree just for you.
   <sub>fun +2; intelligence +1; mods focused</sub>

3. **Watch the video on the plane** (22 words)
   The video, on the plane, twice. Your kid forgives you faster than you forgive yourself, and you never miss the next play.
   <sub>resilience +1; ambition +2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Your kid's school play is the night before a road game.

1. **Go to the play**: You go to the play and catch a late flight.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Watch the dress rehearsal**: You watch the dress rehearsal instead.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Watch the video**: You watch the video on the plane, twice. Your kid forgives you faster than you forgive yourself.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 19. PRO_740 The Parent-Teacher Conference
*family; premise 25 words*

> You go to your first parent-teacher conference, in a tiny chair, and the teacher recognizes you immediately and asks for an autograph for her nephew.

1. **Laugh and focus on your kid** (22 words)
   An autograph, a laugh, and then forty minutes about your kid's reading. You learn things about your own kid you never knew.
   <sub>social +2; fun +1; intelligence +1; charisma +1; mods loose</sub>

2. **Ask good questions** (23 words)
   Good questions, carefully asked, all of them about your kid and none about you. The teacher forgets you kick by the third question.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Keep it short** (22 words)
   A short meeting, and you leave with a list of spelling words to practice. Your kid is thrilled you came at all.
   <sub>energy +2; fun +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> You go to your first parent-teacher conference and get recognized by the teacher.

1. **Laugh about it**: You laugh about it and focus on your kid.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

2. **Ask good questions**: You ask good questions. The teacher forgets you kick.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Keep it short**: You keep it short and leave with a list of spelling words.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 20. PRO_741 The Family Dog
*family; premise 29 words*

> The family dog is getting old: slow on walks, gray in the face, sleeping by the door. The kids have started asking questions you don't know how to answer.

1. **Answer honestly** (20 words)
   Honest answers, at the kitchen table, about getting old and saying goodbye. It's a hard talk and a good one.
   <sub>social +2; resilience +1; rel sibling +1; mods inspired</sub>

2. **Find a good book** (20 words)
   A good book about it, found by you and read together at bedtime, twice. The kids ask better questions after.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Spend time with the dog** (20 words)
   More time with the old dog: slow walks, long naps, the good treats. The kids join you on every walk.
   <sub>energy +1; fun +2; mods rested</sub>

<details><summary>Before</summary>

> The family dog is getting old, and the kids are asking questions.

1. **Answer honestly**: You answer honestly. It's a hard and good talk.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Find a good book**: You find a good book about it and read it together.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Spend the time**: You spend more time with the dog. The kids join you on the slow walks.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 21. PRO_742 The Partner's New Job
*family; premise 27 words*

> {love_interest} gets a big job offer of their own, in a city you'd never live in during the season. They're excited, and trying not to show it.

1. **Back them all the way** (25 words)
   You back them all the way and work out the travel later. Your life gets busier and lonelier, and {love_interest} glows every time you call.
   <sub>social +2; resilience +1; rel love_interest +6; mods loose</sub>

2. **Make it work together** (22 words)
   You sit down with a calendar and make a plan that works for both careers. It's complicated and fair, and it holds.
   <sub>intelligence +2; leadership +1; rel love_interest +2; mods focused</sub>

3. **Ask them to wait** (20 words)
   You ask them to wait a year, until your contract is settled. They agree, and something goes quiet between you.
   <sub>energy -1; ambition +2; rel love_interest -3; skill_points +2; mods dialed_in</sub>

<details><summary>Before</summary>

> {love_interest} gets a big job offer of their own, in a city you'd never live in during the season. They're excited, and trying not to show it.

1. **Back them all the way**: You back them all the way and work out the travel later. Your life gets busier and lonelier, and {love_interest} glows every time you call.
   <sub>social +2; charisma +1; rel love_interest +6; mods loose</sub>

2. **Make it work together**: You sit down with a calendar and make a plan that works for both careers. It's complicated and fair, and it holds.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Ask them to wait**: You ask them to wait a year, until your contract is settled. They agree, and something goes quiet between you.
   <sub>energy -2; ambition +2; rel love_interest -3; skill_points +2; mods dialed_in</sub>

</details>

## 22. PRO_750 The Prime-Time Interview
*media; premise 28 words*

> A national network wants an in-depth interview about your whole career: two days of filming, your hometown, your family, the hard years. It will air before the playoffs.

1. **Open up about the hard years** (21 words)
   The hard years, told honestly on camera. People write to you for weeks, and some of the letters make you cry.
   <sub>social +2; resilience +1; charisma +1; followers +4; mods inspired</sub>

2. **Prepare carefully** (22 words)
   Every answer, prepared and true, rehearsed twice with {best_friend}. It's a strong piece, and you say exactly what you mean on camera.
   <sub>intelligence +2; leadership +1; rel best_friend +1; followers +2; mods focused</sub>

3. **Keep it light** (21 words)
   Light and funny, nothing heavy at all. It's a nice piece about nothing much, and {parent} likes it best of everything.
   <sub>energy +2; fun +1; rel parent +1; mods rested</sub>

<details><summary>Before</summary>

> A national network wants an in-depth interview about your career.

1. **Open up**: You open up about the hard years. People write to you for weeks.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Prepare carefully**: You prepare carefully and say exactly what you mean.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Keep it light**: You keep it light. It's a nice piece about nothing much.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 23. PRO_753 The Contract Year Pressure at Home
*family; premise 25 words*

> Contract year again, and the conversations at home are getting shorter. {love_interest} has stopped asking how practice went, and you've stopped offering anything at all.

1. **Talk about all of it** (27 words)
   All of it, one night after the kids are asleep: the fear, the money, the next city. It's long and hard and the best talk in months.
   <sub>social +2; resilience +1; rel love_interest +5; mods inspired</sub>

2. **Plan for every outcome** (20 words)
   A plan for every outcome, written down together: stay, move, retire. It helps, because nothing will be a surprise anymore.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Focus on kicking** (20 words)
   Kicking, only kicking, and home gets quieter. The contract comes in March, and the quiet takes much longer to fix.
   <sub>energy -1; ambition +2; rel love_interest -2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> Contract year again, and the conversations at home are getting shorter.

1. **Talk about it**: You talk about it, all of it, one night after the kids are asleep.
   <sub>social +2; charisma +1; rel love_interest +5; mods loose</sub>

2. **Make a plan for every outcome**: You make a plan for every outcome. It helps.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Focus on kicking**: You focus on kicking. Home gets quieter.
   <sub>energy -2; ambition +2; rel love_interest -2; skill_points +2; mods dialed_in</sub>

</details>

## 24. PRO_758 The Family Photo
*family; premise 31 words*

> The family photo for the team's holiday card, in matching sweaters, and nobody is smiling: the baby is crying, the dog is escaping, and your eldest is furious about the sweater.

1. **Make them laugh** (22 words)
   A ridiculous face, and everyone laughs at once. The photo is chaos and perfect, and the club uses it on the cover.
   <sub>social +2; fun +2; rel sibling +2; mods loose</sub>

2. **Bribe with dessert** (21 words)
   Dessert, promised loudly to everyone. They all smile on cue, the photographer thanks you, and the dog stays put for once.
   <sub>fun +1; intelligence +2; leadership +1; mods focused</sub>

3. **Go with the grumpy one** (20 words)
   The grumpy photo, kept on purpose. It becomes the family's favorite picture of all time, framed in the hallway forever.
   <sub>energy +2; resilience +1; rel love_interest +1; mods rested</sub>

<details><summary>Before</summary>

> The family photo for the team's holiday card, and nobody is smiling.

1. **Make them laugh**: You make them laugh. The photo is chaos, and perfect.
   <sub>social +2; charisma +1; rel love_interest +4; mods loose</sub>

2. **Bribe with dessert**: You promise dessert. Everyone smiles.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Go with it**: You go with it. The grumpy photo becomes the family favorite.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 25. PRO_292 The Kicker You Grew Up Watching
*social; premise 30 words*

> The kicker whose poster hung above your bed when you were ten is at your game, in a suite, and he sends word that he'd like to meet you after.

1. **Meet him** (25 words)
   A meeting in the tunnel after the game. You tell him about the poster, he laughs, and he signs your shoe like you're the fan.
   <sub>social +2; fun +2; followers +1; mods inspired</sub>

2. **Ask him everything** (26 words)
   How did he last so long, through all of it? You ask him everything, for an hour in the tunnel, and he answers every question honestly.
   <sub>resilience +1; intelligence +2; mods focused</sub>

3. **Shake his hand** (24 words)
   A handshake and a simple thank-you, nothing more. It's brief, and it's enough, and you call {parent} from the car on the way home.
   <sub>energy +1; charisma +1; rel parent +1; mods rested</sub>

<details><summary>Before</summary>

> The kicker whose poster hung in your bedroom is at your game, and asks to meet you.

1. **Meet him**: You meet him and tell him about the poster. He laughs and signs your shoe.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Ask him everything**: You ask him everything about how he lasted.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Shake his hand**: You shake his hand and say thank you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 26. PRO_293 The Rule Change
*training; premise 29 words*

> The league moves the extra-point line back again, the second time in your career. The young kickers in camp are thrilled about it; you've lived through this once already.

1. **Adjust your training** (22 words)
   New distances, added to every practice the next morning. By camp the new line feels normal, and the young kickers are surprised.
   <sub>energy -2; power +1; ambition +1; rel holder +1; skill_points +2; mods dialed_in</sub>

2. **Study the change** (26 words)
   The change, studied properly: the angles, the wind off each end zone, the hash marks. You find the edge before anyone else in the league does.
   <sub>accuracy +1; intelligence +2; mods focused</sub>

3. **Wait and see** (25 words)
   Wait until camp, you decide, and see how it feels with real snaps. It feels fine, and you're glad you didn't spend the summer worrying.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The league moves the extra-point line again, and the young kickers are thrilled.

1. **Adjust your training**: You adjust your training the next morning.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Study the change**: You study the change and find the edge.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Wait and see**: You wait to see how it feels in camp.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 27. PRO_297 The Rookie Who Wears Your Number
*media; premise 29 words*

> A rookie at another club wears your number and tells a reporter you're the reason he started kicking. The clip is everywhere by morning, and your phone won't stop.

1. **Call him** (25 words)
   Your call reaches him on his cell, and he's speechless for ten full seconds. You wish him luck, and he calls you every season after.
   <sub>social +2; charisma +1; rel rival +1; followers +2; mods loose</sub>

2. **Send him a note** (22 words)
   The best advice you ever got, written on a card and mailed to his locker. He tapes it inside, he says, forever.
   <sub>leadership +2; intelligence +1; mods inspired</sub>

3. **Smile and keep it** (21 words)
   A smile, kept to yourself, and the clip watched twice. You don't reach out, and it stays with you all week.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> A rookie at another club wears your number and says you're the reason.

1. **Call him**: You call him and wish him luck. He's speechless.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

2. **Send him a note**: You send him a note with the best advice you ever got.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Smile**: You smile and keep it to yourself.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 28. PRO_299 The Coach You Outlasted
*team; premise 30 words*

> The head coach who drafted you is fired after a bad season, in a short statement on a Monday. You've outlasted him. It doesn't feel like a win at all.

1. **Call him** (26 words)
   You call him that night. He thanks you for calling, talks about your rookie camp for twenty minutes, and you hear his family in the background.
   <sub>social +2; resilience +1; rel coach +1; mods loose</sub>

2. **Steady the room** (21 words)
   You steady the room the next morning, before the rumors start. The new coach hears about it before you meet him.
   <sub>energy -1; leadership +3; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep going** (23 words)
   You keep going, because that's the business, and you've seen it before. You keep his old playbook on a shelf at home, though.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> The head coach who drafted you is fired after a bad season. You've outlasted him. It doesn't feel like a win.

1. **Call him**: You call him that night. He thanks you for calling, talks about your rookie camp for twenty minutes, and you hear his family in the background.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

2. **Steady the room**: You steady the room the next morning, before the rumors start. The new coach hears about it before you meet him.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep going**: You keep going, because that's the business. You keep his old playbook on a shelf at home.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_424 The Hall of Fame Conversation
*media; premise 25 words*

> A broadcaster asks, on air, whether you ever think about your legacy. It's a soft question, and it lands harder than he meant it to.

1. **Give an honest answer** (24 words)
   You say you think about the next kick, which is true. Later, in the car, you think about the question for a long time.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Talk about the people** (23 words)
   You talk about the people who got you here: {parent}, your first coach, the holders. The clip is the one your family keeps.
   <sub>social +2; charisma +1; rel parent +2; followers +2; mods loose</sub>

3. **Laugh it off** (23 words)
   You laugh and say you'll worry about it when you're old. Your teammates tease you about it, and the question stays with you.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A broadcaster asks, on air, whether you ever think about your legacy. It's a soft question, and it lands harder than he meant it to.

1. **Give an honest answer**: You say you think about the next kick, which is true. Later, in the car, you think about the question for a long time.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Talk about the people**: You talk about the people who got you here: {parent}, your first coach, the holders. The clip is the one your family keeps.
   <sub>social +2; charisma +1; rel parent +2; followers +2; mods loose</sub>

3. **Laugh it off**: You laugh and say you'll worry about it when you're old. Your teammates tease you about it, and the question stays with you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 30. PRO_733 The Kicking Records Board
*career; premise 26 words*

> Your name goes up on the club's kicking records board in the hallway, above two legends. The equipment manager screws in the plaque while you watch.

1. **Bring {holder} to see it** (21 words)
   {holder}, brought to see it, because their name should be there too. {holder} pretends not to care and takes a photo.
   <sub>social +2; fun +1; rel holder +4; mods inspired</sub>

2. **Aim for the next name** (20 words)
   The next name on the list, noted carefully. It's three good kicks away, and you start counting them in practice.
   <sub>energy -1; accuracy +1; ambition +2; rel coach +1; skill_points +1; mods dialed_in</sub>

3. **Take a picture for {parent}** (23 words)
   A photo of the plaque, sent to {parent}, who prints it out and puts it next to your peewee trophy on the mantel.
   <sub>energy +1; fun +1; rel parent +3; mods rested</sub>

<details><summary>Before</summary>

> Your name goes up on the club's kicking records board.

1. **Bring {holder}**: You bring {holder} to see it. Their name should be there too.
   <sub>social +2; charisma +1; rel holder +4; mods loose</sub>

2. **Aim for more**: You look at the next name on the list.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Take a picture**: You take a picture for {parent}.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 31. PRO_754 The Halfway Point
*media; premise 26 words*

> A reporter asks if you think you're halfway through your career. You're thirty-two, it's a fair question, and you have no idea how to answer it.

1. **Give a careful answer** (22 words)
   Focused on this season, you say, which is true. Later, in the car, you think about the question for a long time.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Joke about it** (23 words)
   You hope it's a third, you say, and the room laughs. The clip goes around, and {parent} sends it to everyone he knows.
   <sub>social +2; fun +1; rel parent +1; followers +2; mods loose</sub>

3. **Say you're just starting** (20 words)
   Just getting started, you say, and you mean it. The column the next day calls you 'defiant', which you like.
   <sub>energy -1; ambition +2; skill_points +1; mods dialed_in</sub>

<details><summary>Before</summary>

> A reporter asks if you think you're halfway through your career.

1. **Give a careful answer**: You say you're focused on this season. It's true.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Joke about it**: You say you hope it's a third. The room laughs.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

3. **Say you're just starting**: You say you're just getting started.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

</details>

## 32. PRO_755 The Club's Ring of Honor Nominee
*community; premise 28 words*

> Fans start a petition to nominate you for the club's ring of honor while you're still playing. It has forty thousand signatures, and the owner has seen it.

1. **Thank the fans** (22 words)
   Thanks, online and in person at the next home game. The fans cheer loudly, and the petition hits sixty thousand by Monday.
   <sub>social +2; charisma +1; followers +3; mods inspired</sub>

2. **Ask them to wait** (20 words)
   Wait until you're done, you ask the fans kindly. They agree, and it gives everyone something to look forward to.
   <sub>intelligence +2; leadership +1; mods focused</sub>

3. **Keep it to yourself** (21 words)
   A smile, kept to yourself, and back to practice. It means more than you'd ever say out loud, even to {parent}.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Fans nominate you for the club's ring of honor, while you're still playing.

1. **Thank the fans**: You thank them online and in person.
   <sub>social +2; charisma +1; rel team +1; followers +3; mods loose</sub>

2. **Ask them to wait**: You ask them to wait. You're not done.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Smile**: You smile and keep it to yourself.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 33. PRO_319 Ten Years
*career; premise 25 words*

> Ten years in the league. The pension kicks in, the club gives you a watch, and the question arrives with it, uninvited: how many more?

1. **Go for more** (23 words)
   Not done, not close. You tell {coach} and your agent the same thing, and you start the eleventh year angrier than the first.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Plan the next five years** (20 words)
   The next five years, planned with your agent and your family at the kitchen table. Everyone breathes easier, including you.
   <sub>intelligence +2; leadership +1; rel parent +1; mods focused</sub>

3. **Celebrate with the people who got you here** (22 words)
   A party for everyone who got you here: coaches, holders, {parent}, {best_friend}. The watch goes around the room twice, and {parent} cries.
   <sub>social +2; fun +2; rel parent +3; rel best_friend +2; mods inspired</sub>

<details><summary>Before</summary>

> Ten years in the league. The pension kicks in, and so does the question of how many more.

1. **Go for more**: You decide you're not done. Not even close.
   <sub>energy -2; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Plan the next five**: You plan the next five years with your agent and your family.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Celebrate with the people who got you here**: You celebrate with everyone who got you here.
   <sub>social +2; charisma +1; rel parent +4; mods loose</sub>

</details>


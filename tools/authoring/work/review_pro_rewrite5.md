# PRO rewrite pass 5: era-2 scenes 1-39

The first 39 era-2 scenes in play order (ages 26-29): the offseason scenes, the money decisions of the first big contract, family and locker-room scenes.

Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 39 of 39.**

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_026 The Coach for Hire
*training; premise 30 words*

> A private kicking coach who rebuilt three pro careers offers you his whole offseason: his field, his methods, his famous temper. The price is a number your agent repeats twice.

1. **Hire him for the summer** (30 words)
   The summer belongs to him: brutal drills at dawn, video at night, a temper that softens by July. Your leg feels new by August, and you've never been so tired.
   <sub>energy -3; power +2; ambition +1; skill_points +3; mods dialed_in; flags hired_private_coach</sub>

2. **Stay with the club's staff** (23 words)
   The club's staff knows your body, so you stay. It's less glamorous and steady, and the trainers quietly appreciate the vote of confidence.
   <sub>energy -1; accuracy +1; resilience +1; intelligence +1; rel coach +2; mods focused</sub>

3. **Take most of the summer off** (24 words)
   Most of the summer, off: lake, family, sleep. You come back rested, a little rusty, and happier than you've been in a long time.
   <sub>energy +3; fun +2; rel parent +1; mods rested</sub>

4. **Check his record first** *(locked: having checked out trainers before)* (30 words)
   Two of his former clients, called before you decide. Both rave about the results and warn you about the temper. You hire him with your eyes open, and it shows.
   <sub>energy -2; intelligence +1; ambition +1; skill_points +2; mods dialed_in; flags hired_private_coach</sub>

<details><summary>Before</summary>

> A private coach who rebuilt three pro kickers offers you his offseason, for a price.

1. **Hire him**: You hire him for the summer. His drills are brutal and brilliant, and your leg feels new by August.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in; flags hired_private_coach</sub>

2. **Train with the club's staff**: You stay with the club's staff, who know your body. It's less glamorous and steady.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Take the summer off**: You take the summer mostly off. You come back rested and a little rusty.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Check his record first**: You call two of his former clients before deciding. Both rave. You hire him with your eyes open.
   <sub>energy -2; intelligence +1; ambition +1; skill_points +2; mods dialed_in; flags hired_private_coach</sub>

</details>

## 2. PRO_098 A College Teammate's Wedding
*social; premise 33 words*

> Your old college roommate is getting married in June and wants you to give the toast. He's sent a list of stories you're not allowed to tell, and it's longer than the speech.

1. **Write a great toast** (27 words)
   A great toast, written over three weeks and delivered from memory. The bride's grandmother hugs you twice, and the groom mouths 'thank you' from the head table.
   <sub>social +2; charisma +2; rel best_friend +3; mods loose</sub>

2. **Tell one true story** (23 words)
   One true story from freshman year, carefully chosen. It's the one people repeat at breakfast the next morning, and the groom tears up.
   <sub>energy -1; intelligence +1; leadership +1; mods focused</sub>

3. **Remember the pact** *(locked: having made a pact with your college roommate)* (20 words)
   You raise a glass to the pact you made freshman year. He laughs so hard he can't finish his drink.
   <sub>social +2; fun +2; charisma +1; mods inspired</sub>

4. **Make peace in the toast** *(locked: having fallen out with your college roommate)* (23 words)
   You haven't really talked since college. You say so in the toast, and you say sorry. He finds you on the patio afterward.
   <sub>social +2; energy -1; charisma +1; leadership +1; rel best_friend +3; mods inspired</sub>

<details><summary>Before</summary>

> Your old college roommate is getting married, and he wants you to give a toast.

1. **Write a great toast**: You write a great toast and deliver it from memory. The bride's grandmother hugs you.
   <sub>social +2; charisma +1; rel best_friend +2; mods loose</sub>

2. **Tell one true story**: You tell one true story from freshman year. It's the one people repeat at breakfast.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Remember the pact**: You raise a glass to the pact you made freshman year. He laughs so hard he can't finish his drink.
   <sub>social +2; fun +2; charisma +1; mods inspired</sub>

4. **Make peace in the toast**: You haven't really talked since college. You say so in the toast, and you say sorry. He finds you on the patio afterward.
   <sub>social +2; energy -1; charisma +1; leadership +1; rel best_friend +3; mods inspired</sub>

</details>

## 3. PRO_272 Wedding Season
*social; premise 31 words*

> Four friends are getting married this summer, every one of them wants you to give a toast, and three of the weddings are on the same coast in the same month.

1. **Give all four toasts** (23 words)
   Four toasts in five weeks, four suits, four rehearsal dinners. You're exhausted by July and deeply loved, and {best_friend} keeps all four printouts.
   <sub>social +3; energy -2; charisma +1; rel best_friend +4; mods loose</sub>

2. **Write one toast to adapt** (22 words)
   One great toast structure, adapted four times. It works every time, and only {sibling}, who goes to two of the weddings, notices.
   <sub>fun +1; intelligence +2; rel sibling +1; mods focused</sub>

3. **Toast once, attend the rest** (20 words)
   One toast, for the oldest friend, and quiet attendance at the rest. You actually enjoy the other three, dancing badly.
   <sub>energy +2; fun +2; mods rested</sub>

<details><summary>Before</summary>

> Four friends are getting married this summer, and every one of them wants you to give a toast.

1. **Say yes to all four**: You give four toasts in five weeks. You're tired, and loved.
   <sub>social +2; charisma +1; rel best_friend +4; mods loose</sub>

2. **Write one great toast**: You write one great toast structure and adapt it. It works every time.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Pick one**: You give one toast and attend the rest quietly.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 4. PRO_273 The Offseason Surgery
*health; premise 33 words*

> The doctors say a small surgery on your hip now will save your next three seasons. The recovery takes the whole summer: no kicking, a lot of walking, and a lot of waiting.

1. **Have the surgery** (30 words)
   Surgery in May, and a long, boring summer of walking and bands. By camp your hip is better than it's been in years, and you kick without thinking about it.
   <sub>health +4; energy -1; toughness +1; rel coach +1; mods focused</sub>

2. **Train through it** (24 words)
   No surgery: you train through it. It holds, for now, and the doctor writes something in your file that you can't read upside down.
   <sub>health -2; energy -1; ambition +2; skill_points +2; mods sore</sub>

3. **Get a second opinion** (24 words)
   A second opinion, and a month to decide. The second doctor agrees with the first, and the month helps you make peace with it.
   <sub>energy +2; resilience +1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> The doctors say a small surgery now saves your next three seasons. The recovery takes the whole summer.

1. **Have the surgery**: You have it. The summer is long and boring, and your hip is better than it's been in years.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Train through it**: You skip the surgery and train through it. It holds, for now.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Get a second opinion**: You get a second opinion and take a month to decide.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 5. PRO_274 The Training Partner
*training; premise 32 words*

> A young kicker from a rival club asks to train with you this summer. He's talented, nervous, and says he's watched every one of your kicks since he was in high school.

1. **Train together** (22 words)
   All summer, together. You both get better, you make a friend, and you think twice about it every time your clubs play.
   <sub>social +2; fun +1; charisma +1; rel rival +1; mods loose</sub>

2. **Keep your secrets** (20 words)
   No, politely. You don't help the competition, and you train alone all summer, a little harder and a little lonelier.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Make it a summer camp** (24 words)
   A group of four kickers instead, from four clubs. It becomes an unofficial summer camp that runs for years, and you're its first coach.
   <sub>energy -2; social +1; leadership +3; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> A young kicker from a rival club asks to train with you this summer.

1. **Say yes**: You train together all summer. You both get better, and you make a friend.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Say no**: You say no. You don't help the competition.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Make it a group**: You make it a group of four kickers. It becomes a summer camp.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 6. PRO_275 The Class
*school; premise 32 words*

> You sign up for an evening class at the community college, something that has nothing to do with football: astronomy, it turns out, with a professor who has never heard of you.

1. **Earn the A** (23 words)
   Every reading, every lab, every telescope night. You get an A, and the class is the best part of your week all spring.
   <sub>energy -1; resilience +1; intelligence +3; mods focused</sub>

2. **Bring {backup} along** (20 words)
   {backup} comes too, grumbling. You study together in the facility cafeteria, and by finals {backup} knows more constellations than you.
   <sub>social +2; fun +1; intelligence +1; rel backup +3; mods loose</sub>

3. **Audit it for fun** (24 words)
   Audited, no grades and no pressure. You just look at the stars on Thursday nights, and it's the most peaceful part of your week.
   <sub>energy +2; fun +2; mods rested</sub>

4. **Take the next step** *(locked: having finished your degree)* (23 words)
   With your degree finished, you take a graduate-level class instead. It's hard, the reading is endless, and you love every page of it.
   <sub>energy -2; intelligence +2; leadership +1; mods focused</sub>

<details><summary>Before</summary>

> You sign up for a class at the community college, something that has nothing to do with football.

1. **Take it seriously**: You treat it seriously and get an A. It's the best part of your week.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Bring a teammate**: You talk a teammate into taking it with you. You study together.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Audit it**: You audit it, no grades, no pressure.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Take the next step**: You've finished your degree, so you take a graduate-level class. It's hard and you love it.
   <sub>energy -2; intelligence +2; leadership +1; mods focused</sub>

</details>

## 7. PRO_278 The Summer Without Football
*health; premise 29 words*

> For one offseason, you put the kicking bag in the closet and decide not to touch a ball for six weeks. On day three, your leg starts to itch.

1. **Keep the bag in the closet** (24 words)
   Six weeks, untouched. You read, travel and sleep, and when you finally open the closet, you come back hungry in a way you'd forgotten.
   <sub>energy +3; fun +2; health +1; mods rested</sub>

2. **Spend it with family** (21 words)
   All six weeks with family: the lake house, {parent}'s birthday, {sibling}'s new apartment. It's the best summer you've had in years.
   <sub>social +2; fun +2; rel parent +3; rel sibling +2; mods loose</sub>

3. **Study the greats** (24 words)
   Film of the best kickers in history instead of kicking. You fill a notebook and come back with three ideas, one of them good.
   <sub>energy -1; accuracy +1; intelligence +2; mods focused</sub>

<details><summary>Before</summary>

> For one offseason, you put the bag in the closet and don't touch a ball for six weeks.

1. **Enjoy it**: You enjoy every day of it. You come back hungry.
   <sub>energy +2; fun +1; mods rested</sub>

2. **Spend it with family**: You spend it all with family. It's the best summer in years.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Use the time to learn**: You use the time to study film of the best kickers in history.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 8. PRO_284 The Kicking Coach Calls
*training; premise 31 words*

> Your old private kicking coach calls out of nowhere with an idea about your plant foot. He's been watching your games, he says, and something has been bothering him since October.

1. **Work on his idea** (24 words)
   A week of working on his idea, charting everything. It helps, a half-step and a little more lift, and you send him the numbers.
   <sub>energy -1; accuracy +2; intelligence +1; mods focused</sub>

2. **Visit him for a day** (22 words)
   A day at his field, just like old times: his whistle, your kicks, his coffee. You both leave happier than you expected.
   <sub>social +2; fun +1; rel best_friend +1; mods loose</sub>

3. **Thank him and keep your form** (22 words)
   A warm thank-you, and you keep your form as it is. He understands, mostly, and keeps watching your games from his couch.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Your old private kicking coach calls with an idea about your plant foot.

1. **Try the idea**: You work on it for a week and chart everything. It helps.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Visit him**: You visit him and spend a day working together like old times.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

3. **Thank him, not now**: You thank him and say you're happy with your form.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 9. PRO_285 The Charity Golf Event
*community; premise 31 words*

> The club's charity golf event: donors in expensive shoes, owners in carts, and one teammate who's had far too much sun and keeps trying to drive the cart into the pond.

1. **Charm the donors** (27 words)
   Eighteen holes with the donors, your worst golf and your best stories. The charity raises more than last year, and one donor sends you a handwritten note.
   <sub>social +2; charisma +2; followers +1; mods loose</sub>

2. **Look after the teammate** (24 words)
   The sunburned teammate gets water, shade and a ride home from you. He doesn't remember most of it and thanks you anyway on Monday.
   <sub>energy -2; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Play your round and go** (20 words)
   Your round, a sandwich, and home by three. Your golf is terrible, nobody asks you for anything, and you nap.
   <sub>energy +2; fun +1; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The club's charity golf event, with donors, owners and one teammate who's had too much sun.

1. **Play with donors**: You play with the donors and charm them. The charity raises more.
   <sub>social +2; charisma +1; rel team +1; mods loose</sub>

2. **Look after the teammate**: You look after the sunburned teammate and get him home safely.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Play and leave**: You play your round and leave.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 10. PRO_288 The Off-Season Weight
*training; premise 31 words*

> You come back from the offseason six pounds heavier than the club likes. The strength coach is waiting by the scale with a clipboard and a face like a disappointed uncle.

1. **Step on the scale** (26 words)
   On the scale, number read out loud, and six weeks of earning the old one back. It's miserable, and your legs feel lighter by the opener.
   <sub>energy -2; health +2; ambition +1; skill_points +2; mods dialed_in</sub>

2. **Bring your own numbers** (21 words)
   Your summer leg-speed numbers, printed and highlighted. They're better than last year, and the strength coach backs off a little, grudgingly.
   <sub>energy -1; power +1; intelligence +2; rel coach +1; mods focused</sub>

3. **Joke with the strength coach** (25 words)
   Jokes, a confession about the ice cream, and an agreement on a plan. The strength coach likes you more for it and doubles your sprints.
   <sub>social +2; fun +1; charisma +1; rel team +1; mods loose</sub>

<details><summary>Before</summary>

> You come back from the offseason heavier than the club likes, and the strength coach has a scale ready.

1. **Get on the scale**: You step on the scale, hear the number and spend six weeks earning back the old one.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Bring your own numbers**: You bring your leg-speed numbers from the summer. They're better than last year, and the strength coach backs off a little.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Laugh with the strength coach**: You joke your way through it and agree to a plan. The strength coach likes you more for it.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

</details>

## 11. PRO_386 The Homecoming Event
*community; premise 32 words*

> Your high school invites you back for its homecoming game. They want you at the pep rally, on the field at halftime, and in the trophy case photo with your old coach.

1. **Walk the halls with {parent}** (24 words)
   The halls, with {parent}, in the afternoon. A teacher still has your old essay about wanting to be a kicker, and reads it aloud.
   <sub>social +2; fun +1; rel parent +4; mods loose</sub>

2. **Talk to the team** (22 words)
   The football team before the game, in the old locker room. The kicker can't stop grinning, and you leave him your cleats.
   <sub>energy -2; leadership +2; charisma +1; skill_points +1; mods inspired</sub>

3. **Send a halftime video** (23 words)
   A video, played at halftime on the old scoreboard. They cheer anyway, and someone films the crowd cheering for you and sends it.
   <sub>energy +2; fun +1; resilience +1; followers +1; mods rested</sub>

<details><summary>Before</summary>

> Your high school invites you back for its homecoming.

1. **Go back**: You go back and walk the halls with {parent}. A teacher still has your old essay.
   <sub>social +2; charisma +1; rel parent +4; mods loose</sub>

2. **Talk to the team**: You talk to the football team before the game. The kicker can't stop grinning.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Send a video**: You send a video. It plays at halftime, and they cheer anyway.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 12. PRO_389 The Offseason Media Tour
*media; premise 25 words*

> Your growing reputation comes with an offseason full of interview requests: podcasts, morning shows, and a magazine that wants to photograph you on a beach.

1. **Say yes to most** (21 words)
   Most of them, yes. Your name is everywhere by June, your phone never stops, and you're more tired than in season.
   <sub>social +2; energy -2; charisma +2; followers +4; mods spotlight</sub>

2. **Do three, and do them well** (20 words)
   Three interviews, carefully chosen and well prepared. One of them becomes the clip people share whenever your name comes up.
   <sub>intelligence +2; charisma +1; followers +2; mods focused</sub>

3. **Keep the summer quiet** (22 words)
   A quiet summer and your training, no interviews. Nobody photographs you on a beach, which suits you fine, and your agent sighs.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Your growing reputation comes with an offseason full of interviews.

1. **Say yes to most**: You say yes to most of them. Your name is everywhere by June.
   <sub>social +2; charisma +1; rel team +1; followers +4; mods loose</sub>

2. **Pick the good ones**: You pick the three best and do them well.
   <sub>energy -1; resilience +1; intelligence +2; followers +2; mods focused</sub>

3. **Keep the summer quiet**: You keep the summer quiet and train.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 13. PRO_653 The Long Offseason
*health; premise 25 words*

> The longest offseason of your career: fourteen weeks with no games, no meetings and nowhere to be. By week two you've reorganized the garage twice.

1. **Rest for real** (20 words)
   Real rest, for once: no plans, long walks and long naps. Your body thanks you, and the garage stays organized.
   <sub>energy +3; health +2; mods rested</sub>

2. **Take a course** (20 words)
   A course in something you've always wondered about: woodworking, it turns out. You make a crooked table and love it.
   <sub>energy -1; fun +1; resilience +1; intelligence +2; mods focused</sub>

3. **Travel with family** (22 words)
   Three weeks of travel with the people you love most. It's the longest you've been away from a ball since high school.
   <sub>social +2; fun +2; rel parent +2; rel sibling +2; mods loose</sub>

<details><summary>Before</summary>

> The longest offseason of your career, and you don't know what to do with it.

1. **Rest for real**: You rest for real. Your body thanks you.
   <sub>energy +2; fun +1; mods rested</sub>

2. **Learn something**: You take a course in something you've always wondered about.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Travel with family**: You travel with family for three weeks.
   <sub>social +2; charisma +1; rel love_interest +3; mods loose</sub>

</details>

## 14. PRO_654 The Hometown Kids' Camp
*community; premise 28 words*

> You run a free camp for kids in your hometown: two days, two hundred kids, one field, a donated pallet of footballs and the old high school band.

1. **Run every station** (26 words)
   Every station, run by you. You lose your voice by noon on day one and keep going in a whisper, and the kids love the whisper.
   <sub>energy -3; leadership +3; skill_points +1; mods inspired</sub>

2. **Bring three teammates** (21 words)
   Three teammates, including {holder}. The kids lose their minds, and {holder} runs a holding clinic that's the hit of the weekend.
   <sub>social +2; fun +2; rel holder +3; mods loose</sub>

3. **Make it a yearly camp** (24 words)
   The high school becomes a partner, so the camp happens every year whether you're there or not. It's the most lasting thing you've built.
   <sub>energy -1; intelligence +2; leadership +1; rel parent +1; mods focused</sub>

<details><summary>Before</summary>

> You run a free camp for kids in your hometown.

1. **Run every station**: You run every station yourself. You lose your voice.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Bring teammates**: You bring three teammates. The kids lose their minds.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Partner with the school**: You partner with the high school so it happens every year.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

</details>

## 15. PRO_672 The Fitness Test
*training; premise 30 words*

> The club's offseason fitness test: shuttle runs, a mile, a jump. You're not where you were, the strength coach writes your times down without comment, and the linemen are watching.

1. **Train for the retest** (23 words)
   Three weeks of training for the retest, and you pass it clean, faster than last year. The linemen cheer, sarcastically and then sincerely.
   <sub>energy -3; toughness +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Explain kicking fitness** (22 words)
   Your leg numbers, shown to the trainers: kicking fitness isn't running fitness. They agree, mostly, and adjust your test for next year.
   <sub>energy -1; intelligence +2; leadership +1; rel coach +1; mods focused</sub>

3. **Accept the number** (21 words)
   The number is the number. You accept it calmly and plan a better summer, and the strength coach nods, clearly surprised.
   <sub>energy +2; resilience +2; mods rested</sub>

<details><summary>Before</summary>

> The club's offseason fitness test, and you're not where you were.

1. **Train for the retest**: You train hard for the retest and pass it clean.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

2. **Explain the numbers**: You show the trainers your leg numbers. Kicking fitness isn't running fitness.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

3. **Accept it**: You accept the number and plan a better summer.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 16. PRO_032 The Kicker Brought In
*team; premise 32 words*

> The club signs a kicker with a bigger leg and a lower salary and puts him at the locker next to yours. He's polite, twenty-three, and kicks sixty-yarders in warmups for fun.

1. **Out-prepare him** (23 words)
   Every day, better prepared than him. He has the leg; you have the habits. By October the coaches have noticed which one matters.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Get to know him** (21 words)
   Lunch, then dinner, then a friendship. He's nervous and decent, and you both kick better without the tension in the room.
   <sub>social +2; charisma +1; rel backup +3; mods loose</sub>

3. **Ask {coach} the plan** (24 words)
   The plan, asked for straight out in the hallway. {coach}'s answer is honest: it's an open competition. It stings, and it helps to know.
   <sub>energy -1; resilience +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> The club signs a kicker with a bigger leg and a lower salary, and puts him at the locker next to yours.

1. **Out-prepare him**: You out-prepare him every single day. He has the leg; you have the habits.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Get to know him**: You get to know him. He's nervous and decent, and you both kick better without the tension.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Ask {coach} the plan**: You ask {coach} straight out what the plan is. The answer is honest: it's open.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 17. PRO_021 Don't Talk About It
*team; premise 32 words*

> The specialists have a superstition: nobody says the streak out loud. A rookie just said it at lunch, loudly, with the whole table listening, and the snapper has put down his fork.

1. **Laugh and reassure him** (21 words)
   Laughing, you tell the rookie it's fine. The room relaxes, the snapper picks up his fork, and the streak goes on.
   <sub>social +2; fun +1; rel team +2; mods loose</sub>

2. **Change absolutely nothing** (24 words)
   Your routine stays exactly the same, down to the socks, the parking spot and the brand of gum. The specialists approve in total silence.
   <sub>energy -1; resilience +2; intelligence +1; mods focused</sub>

3. **Make the rookie buy lunch** (21 words)
   Lunch for the specialists, every day for a week, on the rookie. It becomes a tradition, and he takes it well.
   <sub>energy -1; leadership +2; charisma +1; rel holder +2; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> The specialists have a superstition: nobody says the streak out loud. A rookie just said it, at lunch, loudly.

1. **Laugh it off**: You laugh and tell the rookie it's fine. The room relaxes, and the streak goes on.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Change nothing**: You keep every part of your routine exactly the same, including the socks.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Make the rookie buy lunch**: You make the rookie buy the specialists lunch as penance. It becomes a tradition.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 18. PRO_031 The Incentive Clause
*money; premise 30 words*

> Your contract pays a bonus if you hit ninety percent this season, and your agent keeps texting you the math: where you are, what's left, what one miss would mean.

1. **Ask your agent to stop** (23 words)
   No more math, please, you text back. You'll find out at the end of the season, and the next three months are quieter.
   <sub>energy -1; resilience +2; intelligence +1; mods focused</sub>

2. **Chase the number** (23 words)
   The number goes on your locker, and you chase it every practice. It's motivating, and some nights it's all you can think about.
   <sub>energy -2; accuracy +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Forget the bonus** (24 words)
   Forgotten, on purpose, and the agent's texts go unread. If it comes, it comes, and you kick more freely than you have in years.
   <sub>energy +2; fun +2; mods rested</sub>

<details><summary>Before</summary>

> Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.

1. **Ask your agent to stop**: You ask your agent to stop sending the math. You'll know at the end of the season.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Chase it**: You put the number on your locker and chase it every practice.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Forget about it**: You forget about it entirely. If it comes, it comes.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 19. PRO_035 The Bad Week
*team; premise 26 words*

> You snapped at {holder} in practice, walked past {coach} without a word and skipped the team meal. It's Wednesday, and it's been that kind of week.

1. **Apologize to {holder}** (21 words)
   A real apology to {holder} before practice, no excuses. The holds are better that afternoon, and {holder} buys you a coffee.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

2. **Tell {coach} what's going on** (22 words)
   What's actually going on comes out in {coach}'s office: sleep, family, the pressure. The coach listens and gives you a lighter week.
   <sub>energy -1; resilience +1; intelligence +1; rel coach +2; mods focused</sub>

3. **Take one night completely off** (27 words)
   One night, completely off: no film, no phone, no football, just a long walk and a bad movie. It resets you, and Thursday is a better day.
   <sub>energy +3; fun +1; mods rested</sub>

<details><summary>Before</summary>

> You snapped at {holder}, ignored {coach} and skipped the team meal. It's been that kind of week.

1. **Apologize to {holder}**: You apologize to {holder} before practice. The holds are better that afternoon.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

2. **Tell {coach} what's going on**: You tell {coach} what's actually going on. The coach listens and gives you a lighter week.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Take a night off**: You take a night completely off: no film, no phone. It resets you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 20. PRO_048 The Agent's Bigger Client
*career; premise 29 words*

> Your agent just signed a star quarterback. Your last three calls went to voicemail, and the fourth went to an assistant who asked how to spell your last name.

1. **Say something now** (31 words)
   A short email to your agent: what you need this year, and by when. The reply comes from the agent personally, a day late and genuinely apologetic, with a meeting date.
   <sub>energy -1; leadership +1; intelligence +1; mods focused</sub>

2. **Let it slide** (25 words)
   The agent's busy, you tell yourself, and it'll even out. It doesn't. You stop expecting calls back, and you start finding out things from reporters.
   <sub>energy +1; fun +1; ambition -1; mods distracted; flags agent_neglect</sub>

3. **Vent to the locker room** (24 words)
   Complaints about your agent, to anyone who'll listen. Two teammates say theirs is worse, and a reporter hears about all of it by Friday.
   <sub>social +2; fun +1; charisma -1; followers -1; mods stressed; flags agent_neglect</sub>

<details><summary>Before</summary>

> Your agent just signed a star quarterback. Your last three calls went to voicemail, and the fourth went to an assistant who asked how to spell your name.

1. **Say something now**: You email your agent a short list: what you need this year and by when. The reply comes from your agent personally, a day late and apologetic.
   <sub>energy -1; leadership +1; intelligence +1; mods focused</sub>

2. **Let it slide**: You tell yourself the agent's busy and it'll even out. It doesn't. You stop expecting calls back.
   <sub>energy +1; fun +1; ambition -1; mods distracted; flags agent_neglect</sub>

3. **Vent to the locker room**: You complain about your agent to anyone who'll listen. Two teammates say theirs is worse. A reporter hears about it by Friday.
   <sub>social +2; fun +1; charisma -1; followers -1; mods stressed; flags agent_neglect</sub>

</details>

## 21. PRO_052 The Teammate Traded Away
*team; premise 28 words*

> The club traded your holder's best friend at midnight. {holder} found out from a phone notification, sitting in the parking lot after practice, and hasn't said much since.

1. **Check on {holder}** (20 words)
   First thing in the morning, you find {holder}, and you stay through lunch. Nothing much is said, and it helps.
   <sub>social +2; charisma +1; rel holder +4; mods drained</sub>

2. **Talk to the specialists** (25 words)
   A few words to the specialists about how the business works, and how to look after each other in it. The young ones need it.
   <sub>energy -2; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep your head low** (20 words)
   It's the business, and you know it could be you. You keep your head low and your phone face down.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The club traded your holder's best friend at midnight. He found out from his phone.

1. **Check on {holder}**: You check on {holder} first thing in the morning and stay through lunch.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

2. **Talk to the team**: You say something to the specialists about how the business works. It helps the young ones.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep your head down**: You keep your head down. It's the business, and you know it could be you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 22. PRO_056 The Big Check
*money; premise 31 words*

> Your signing bonus clears on a Tuesday. Within an hour your phone lights up with cousins, a car dealer, two realtors and someone from high school who wants to 'catch up'.

1. **Put it somewhere boring** (23 words)
   You put almost all of it somewhere boring and tell everyone it's tied up. Nobody believes you, and nobody can get to it.
   <sub>fun -1; energy +2; intelligence +2; mods focused; flags saved_big_check</sub>

2. **Celebrate properly** (30 words)
   The whole family, on a trip, and then the house with the pool. It's the best summer anyone in your family has had, and the pool bill arrives in September.
   <sub>fun +4; social +2; intelligence -1; rel parent +4; mods loose; flags spent_big_check</sub>

3. **Set aside a family share** (20 words)
   You set aside one share for family and tell them it's the only one. The cousins grumble. {parent} quietly approves.
   <sub>social -1; leadership +1; intelligence +1; rel parent +2; mods focused; flags saved_big_check</sub>

<details><summary>Before</summary>

> The signing bonus clears. Within an hour your phone lights up with cousins, a car dealer and someone from high school who wants to 'catch up'.

1. **Put it somewhere boring**: You put almost all of it somewhere boring and tell everyone it's tied up. Nobody believes you, and nobody can get to it.
   <sub>fun -1; energy +2; intelligence +2; mods focused; flags saved_big_check</sub>

2. **Celebrate properly**: You take the whole family on a trip and buy the house with the pool. It's the best summer anyone in your family has had.
   <sub>fun +4; social +2; intelligence -1; rel parent +4; mods loose; flags spent_big_check</sub>

3. **Set aside a family share**: You set aside one share for family and tell them it's the only one. The cousins grumble. {parent} quietly approves.
   <sub>social -1; leadership +1; intelligence +1; rel parent +2; mods focused; flags saved_big_check</sub>

</details>

## 23. PRO_061 The Restaurant
*money; premise 34 words*

> An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night, and he keeps saying 'can't miss.'

1. **Put your money in** (26 words)
   You sign the papers at his kitchen table. Your name goes up in lights in March, and you eat there twice a week because it's yours.
   <sub>fun +3; social +2; intelligence -1; followers +2; mods inspired; flags opened_restaurant</sub>

2. **Ask to see real numbers** (29 words)
   A real plan, the lease and an accountant's review, please. He's offended, sends half of it, then stops answering. You keep your money and lose some of a friendship.
   <sub>social -2; fun -1; intelligence +2; leadership +1; mods focused</sub>

3. **Lend your name, not your money** (23 words)
   The opening night, a photo line and nothing more: your name, not your money. He's disappointed and says so, then takes the deal.
   <sub>energy -1; social +1; charisma +1; followers +1; mods loose</sub>

4. **Send it to your advisor** *(locked: having an advisor you trust)* (36 words)
   Your advisor reads the plan in an afternoon and circles four things that would sink it. You send the list to your old teammate as a favor. He fixes two of them and opens without you.
   <sub>energy -1; social +1; intelligence +2; leadership +1; mods focused</sub>

<details><summary>Before</summary>

> An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night, and he keeps saying 'can't miss.'

1. **Put your money in**: You sign the papers at his kitchen table. Your name goes up in lights in March, and you eat there twice a week because it's yours.
   <sub>fun +3; social +2; intelligence -1; followers +2; mods inspired; flags opened_restaurant</sub>

2. **Ask to see real numbers**: You ask for a real plan, the lease and an accountant's review. He's offended, sends half of it, then stops answering. You keep your money and lose some of a friendship.
   <sub>social -2; fun -1; intelligence +2; leadership +1; mods focused</sub>

3. **Lend your name, not your money**: You agree to show up for the opening and sign photos, nothing more. He's disappointed and says so, then takes it.
   <sub>energy -1; social +1; charisma +1; followers +1; mods loose</sub>

4. **Send it to your advisor**: Your advisor reads the plan in an afternoon and circles four things that would sink it. You send the list to your old teammate as a favor. He fixes two of them and opens without you.
   <sub>energy -1; social +1; intelligence +2; leadership +1; mods focused</sub>

</details>

## 24. PRO_064 The Friend's Start-Up
*money; premise 31 words*

> {best_friend} is starting a company, a real one with a plan, a lawyer and two hires, and asks you over dinner to be the very first investor. They've practiced the pitch.

1. **Invest** (29 words)
   You write the check because it's {best_friend}, and because the plan is actually good. You get a seat at their first board meeting and don't understand half of it.
   <sub>fun +1; social +1; ambition +1; rel best_friend +6; mods inspired; flags invested_in_friend</sub>

2. **Invest a little, and say why** (22 words)
   You invest a small piece and tell {best_friend} why it's small. It stings for a day, and they respect it after that.
   <sub>intelligence +1; leadership +1; rel best_friend +3; mods focused; flags invested_in_friend</sub>

3. **Say no as a friend** (23 words)
   You say you don't mix friendship and money, and you mean it kindly. {best_friend} says they understand, and calls a little less often.
   <sub>energy +1; fun +1; intelligence +1; rel best_friend -3; mods rested</sub>

<details><summary>Before</summary>

> {best_friend} is starting a company, a real one with a plan and two hires, and asks you to be the first investor.

1. **Invest**: You write the check because it's {best_friend}, and because the plan is actually good. You get a seat at their first board meeting and don't understand half of it.
   <sub>fun +1; social +1; ambition +1; rel best_friend +6; mods inspired; flags invested_in_friend</sub>

2. **Invest a little, and say why**: You invest a small piece and tell {best_friend} why it's small. It stings for a day, and they respect it after that.
   <sub>intelligence +1; leadership +1; rel best_friend +3; mods focused; flags invested_in_friend</sub>

3. **Say no as a friend**: You say you don't mix friendship and money, and you mean it kindly. {best_friend} says they understand, and calls a little less often.
   <sub>energy +1; fun +1; intelligence +1; rel best_friend -3; mods rested</sub>

</details>

## 25. PRO_069 {parent}'s House
*money; premise 26 words*

> You could pay off {parent}'s mortgage this week with one transfer. He's told you not to, twice, in the voice he used when you were twelve.

1. **Do it anyway** (32 words)
   You pay it off and tell him after. He's furious for an hour and doesn't speak at dinner. A month later, he still has the letter from the bank on his fridge.
   <sub>social +2; fun +1; leadership +1; rel parent +6; mods loose</sub>

2. **Ask what he'd accept** (26 words)
   You ask {parent} what he would actually accept. He agrees to a loan with no interest, insists on paying it back, and pays it back early.
   <sub>energy -1; resilience +1; intelligence +2; rel parent +3; mods focused</sub>

3. **Respect his wish** (24 words)
   You respect his wish and let it go. He's proud of that, in his quiet way, and you send money to his church instead.
   <sub>energy +2; fun +1; charisma +1; mods rested</sub>

4. **Do it the way that worked before** *(locked: having helped your family with money before)* (23 words)
   You set it up the way you did last time: quietly, through the bank, with his name on everything. He grumbles and signs.
   <sub>energy -1; intelligence +1; rel parent +5; mods inspired</sub>

<details><summary>Before</summary>

> You could pay off {parent}'s mortgage this week with one transfer. He's told you not to, twice, in the voice he used when you were twelve.

1. **Do it anyway**: You pay it off and tell him after. He's furious for an hour and doesn't speak at dinner. A month later, he still has the letter from the bank on his fridge.
   <sub>social +2; charisma +1; rel parent +6; mods loose</sub>

2. **Ask what he'd accept**: You ask {parent} what he would actually accept. He agrees to a loan with no interest, insists on paying it back, and pays it back early.
   <sub>energy -1; resilience +1; intelligence +2; rel parent +3; mods focused</sub>

3. **Respect his wish**: You respect his wish and let it go. He's proud of that, in his quiet way, and you send money to his church instead.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Do it the way that worked before**: You set it up the way you did last time: quietly, through the bank, with his name on everything. He grumbles and signs.
   <sub>energy -1; intelligence +1; rel parent +5; mods inspired</sub>

</details>

## 26. PRO_080 {parent} Is Getting Older
*family; premise 27 words*

> {parent} forgets the name of a neighbor he's known for twenty years, in the middle of a story on the phone. He laughs it off. You don't.

1. **Go home for the bye** (25 words)
   Home for the bye weekend, every minute with him: the hardware store, the porch, the old stories. He tells the neighbor story right this time.
   <sub>social +2; energy -1; rel parent +5; mods loose</sub>

2. **Find him a specialist** (25 words)
   A specialist, found and booked, and you join the first appointment by video. It's probably nothing, the doctor says, and you hold on to 'probably'.
   <sub>energy -1; intelligence +2; leadership +1; rel parent +2; mods focused</sub>

3. **Call every other day** (23 words)
   Every other day, a phone call, ten minutes or an hour. It's not much, it's something, and he starts saving stories for you.
   <sub>energy +1; social +1; resilience +1; rel parent +2; mods rested</sub>

<details><summary>Before</summary>

> {parent} forgets the name of a neighbor he's known for twenty years.

1. **Go home for a weekend**: You go home for the bye weekend and spend every minute with him.
   <sub>social +2; charisma +1; rel parent +5; mods loose</sub>

2. **Find him a doctor**: You find him a specialist and go to the first appointment by video.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Call more often**: You start calling every other day. It's not much, and it's something.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 27. PRO_082 {sibling}'s Own Shot
*family; premise 27 words*

> {sibling} has a tryout of his own, with a semi-pro team three hours from home, and he wants you there. He's never asked you for anything before.

1. **Be at the fence** (23 words)
   A flight in, and you stand behind the fence all morning. He looks for you before every kick, and finds you every time.
   <sub>social +2; energy -1; rel sibling +6; mods inspired</sub>

2. **Coach him by phone** (28 words)
   The night before, by phone: one thought, one routine, nothing else. He calls after the tryout to tell you it worked, and he sounds like a different person.
   <sub>energy -1; intelligence +2; leadership +1; rel sibling +3; mods focused</sub>

3. **Send a message and watch later** (21 words)
   A message in the morning, the video at night. He understands, mostly, and doesn't mention it again, which tells you something.
   <sub>energy +2; fun +1; rel sibling -1; mods rested</sub>

4. **Tell him what you learned** *(locked: having learned what showing up means)* (24 words)
   You tell {sibling} the hardest thing you ever learned: show up, tell the truth, let the rest go. Then you're there at the fence.
   <sub>energy -2; social +1; leadership +1; rel sibling +7; mods inspired</sub>

<details><summary>Before</summary>

> {sibling} has a tryout of his own, and he wants you there.

1. **Be there**: You fly in for the tryout and stand behind the fence. He looks for you before every kick.
   <sub>social +2; charisma +1; rel sibling +6; mods loose</sub>

2. **Coach him by phone**: You coach him by phone the night before: one thought, one routine.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Send a message**: You send a message and watch the video later. He understands, mostly.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Tell him what you learned**: You tell {sibling} the hardest thing you ever learned: show up, tell the truth, let the rest go. Then you're there at the fence.
   <sub>energy -2; social +1; leadership +1; rel sibling +7; mods inspired</sub>

</details>

## 28. PRO_086 {tyler} Gets Cut
*social; premise 25 words*

> {tyler} is released on a Monday morning. He calls you before he calls his agent, and for a long time neither of you says anything.

1. **Listen for an hour** (21 words)
   An hour on the phone, mostly listening. He doesn't want advice, and you don't give any, and he thanks you twice.
   <sub>social +2; resilience +1; rel rival +4; mods drained</sub>

2. **Make a call for him** (23 words)
   A special teams coach you know gets a call from you, and you say {tyler}'s name twice. He has a workout by Friday.
   <sub>energy -1; leadership +1; intelligence +1; rel rival +4; mods focused</sub>

3. **Promise to talk soon** (24 words)
   A message, warm and short, and a promise to talk soon. You mean it, and it still takes three weeks before you actually call.
   <sub>energy +2; fun +1; rel rival +1; mods rested</sub>

<details><summary>Before</summary>

> {tyler} is released on a Monday. He calls you before his agent.

1. **Listen**: You listen for an hour. He doesn't want advice, and you don't give any.
   <sub>social +2; charisma +1; rel rival +3; mods loose</sub>

2. **Make a call for him**: You call a special teams coach you know and say his name.
   <sub>energy -1; intelligence +2; rel coach +2; rel rival +3; mods focused</sub>

3. **Send a message**: You send a message and a promise to talk soon.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_090 The Holder's Last Season
*team; premise 29 words*

> {holder} is retiring after this season and wants every hold to count. They've started bringing a notebook to practice, writing down each one, with the date and the weather.

1. **Celebrate every practice** (20 words)
   Every practice becomes a small celebration: a joke, a photo, a cake on the fortieth birthday. {holder} cries twice, happily.
   <sub>social +2; fun +2; rel holder +5; mods loose</sub>

2. **Make every kick count** (25 words)
   Every kick in practice, for {holder}, like it's the playoffs. The notebook fills up with good ones, and {holder} reads them to you on Fridays.
   <sub>energy -2; accuracy +1; ambition +1; rel holder +2; skill_points +2; mods dialed_in</sub>

3. **Train the next holder** (29 words)
   The next holder gets trained by both of you, all season, so the job is in good hands. {holder} calls it the best thing you ever did for them.
   <sub>energy -2; leadership +2; rel holder +3; rel team +1; skill_points +1; mods inspired</sub>

<details><summary>Before</summary>

> {holder} is retiring after this season and wants every hold to count.

1. **Make it a season to remember**: You make every practice a little celebration with {holder}.
   <sub>social +2; charisma +1; rel holder +5; mods loose</sub>

2. **Make it count on the field**: You make every kick count for {holder}, practicing like it's the playoffs.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Help pick the next holder**: You help {holder} train the next holder, so the job is in good hands.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

</details>

## 30. PRO_093 The Concussion
*team; premise 26 words*

> A teammate who has had too many concussions takes another hit in practice and hides it. You saw it happen, and he saw you see it.

1. **Tell the trainers** (27 words)
   The trainers hear it from you before the next drill. He's angry for a week and won't look at you, then thanks you in the parking lot.
   <sub>energy -1; resilience +1; leadership +2; rel team +1; skill_points +1; mods inspired</sub>

2. **Talk to him first** (25 words)
   Away from everyone, by the water cooler, you convince him to tell the trainers himself. It costs you an hour and some of his pride.
   <sub>social +2; energy -1; charisma +1; rel team +3; mods loose</sub>

3. **Look the other way** (25 words)
   Looking the other way, you let it go. He plays the next game, and you watch him every single snap, wondering if you were wrong.
   <sub>energy +1; fun +1; mods distracted</sub>

<details><summary>Before</summary>

> A teammate who has had too many concussions takes another hit in practice and hides it. You saw it happen, and he saw you see it.

1. **Tell the trainers**: You tell the trainers before the next drill. He's angry for a week and won't look at you, then thanks you in the parking lot.
   <sub>energy -2; social +1; leadership +2; rel team +1; skill_points +1; mods inspired</sub>

2. **Talk to him first**: You talk to him first, away from everyone, and convince him to tell the trainers himself. It costs you an hour and some of his pride.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Stay out of it**: You stay out of it. He plays the next game, and you watch him every snap, wondering.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 31. PRO_101 The Veteran Who Can't Let Go
*team; premise 25 words*

> A thirty-six-year-old linebacker is getting cut on Friday, and he hasn't figured it out yet. He's still planning next year's offseason out loud at lunch.

1. **Sit with him on his last day** (25 words)
   Lunch with him on his last day, just the two of you. He talks about his first season the whole time, and you let him.
   <sub>social +2; resilience +1; rel team +2; mods drained</sub>

2. **Get the young players to say goodbye** (23 words)
   The young players, quietly told to say goodbye before he's gone. Twenty of them line up at his locker, and he can't speak.
   <sub>energy -2; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Let it happen** (22 words)
   It's not your place, so you let it happen. It stays with you, the empty chair at lunch, longer than you expect.
   <sub>energy +1; intelligence +1; mods distracted</sub>

<details><summary>Before</summary>

> A thirty-six-year-old linebacker is getting cut, and he hasn't figured it out yet.

1. **Sit with him**: You sit with him at lunch on his last day. He talks about his first season.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Tell the young players**: You tell the young players to say goodbye before he's gone.
   <sub>energy -2; social +1; leadership +2; rel team +1; skill_points +1; mods inspired</sub>

3. **Let it happen**: You let it happen. It's not your place, and it stays with you.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 32. PRO_102 The Players-Only Meeting
*team; premise 27 words*

> The team captains call a players-only meeting about {coach}'s boss, the head coach, and they want every player's vote. For the first time, they're asking the kicker.

1. **Speak honestly** (26 words)
   Tough and fair, you say about the head coach, and you give two examples. Some agree, some don't, and the vote is closer because of you.
   <sub>energy -2; leadership +2; charisma +1; rel team +1; skill_points +1; mods inspired</sub>

2. **Ask for the facts first** (21 words)
   What exactly is the problem? The meeting gets calmer as people answer, and the vote becomes a list of fixes instead.
   <sub>energy -1; resilience +1; intelligence +2; rel team +1; mods focused</sub>

3. **Abstain** (24 words)
   An abstention. Kickers rarely get asked anyway, and you'd rather not start now. The captains notice, and they stop asking you for a while.
   <sub>energy +2; fun +1; mods rested</sub>

<details><summary>Before</summary>

> The team captains call a players-only meeting about the coach, and they want your vote.

1. **Speak honestly**: You speak honestly: the coach is tough and fair. Some agree, some don't.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Ask for facts**: You ask what exactly the problem is before voting. The meeting gets calmer.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Abstain**: You abstain. Kickers rarely get asked anyway.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 33. PRO_103 The Player Rep
*team; premise 27 words*

> The team needs a players' union representative, the job of standing up in front of management twice a year. Nobody wants to be the one management remembers.

1. **Volunteer** (22 words)
   Volunteered. It's meetings and conference calls, and the young players start coming to you with questions about everything from contracts to pensions.
   <sub>energy -2; leadership +3; rel team +2; skill_points +1; mods inspired; flags player_rep</sub>

2. **Nominate the right person** (20 words)
   The veteran who should do it gets nominated by you. He accepts, grumbling, and does it brilliantly for three years.
   <sub>energy -1; intelligence +2; charisma +1; rel team +1; mods focused</sub>

3. **Leave it to someone else** (22 words)
   Someone else does it. You vote for them and go back to kicking, relieved, a little guiltily, every time there's a meeting.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> The team needs a union representative, and nobody wants to be the one management remembers.

1. **Volunteer**: You volunteer. It's meetings and calls, and the young players start coming to you.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired; flags player_rep</sub>

2. **Nominate the right person**: You nominate the veteran who should do it. He accepts, grumbling.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

3. **Stay out of it**: You stay out of it. Someone else does it.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 34. PRO_105 The Injured Teammate
*team; premise 30 words*

> A teammate who tore his knee for the team last season is cut the day he's cleared to practice. He found out in the training room, still wearing the brace.

1. **Help him clean out his locker** (22 words)
   His locker, cleaned out with your help, into two cardboard boxes. He doesn't say much, and he hugs you at the car.
   <sub>social +2; energy -1; rel team +2; mods drained</sub>

2. **Say something to the room** (24 words)
   A few words to the room about how this business works and what we owe each other inside it. The young players listen closely.
   <sub>energy -2; resilience +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep quiet** (21 words)
   Quiet. You're one bad season from the same thing, and you know it, and you kick a little angrier that week.
   <sub>energy +1; ambition +1; mods distracted</sub>

<details><summary>Before</summary>

> A teammate who tore his knee for the team is cut the day he's cleared to practice.

1. **Help him clean out**: You help him clean out his locker. He doesn't say much.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Say something to the room**: You say something to the room about how this business works. The young players listen.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

3. **Keep quiet**: You keep quiet. You're one bad season from the same thing.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 35. PRO_111 The Leak
*team; premise 26 words*

> Someone is leaking locker-room conversations to a beat reporter, word for word, and the coaches think it's a specialist. The punter is furious. So is {holder}.

1. **Find the pattern** (22 words)
   Which details leak, and when? You notice the pattern and tell {coach}: it's a rookie lineman with a cousin at the paper.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Rally the specialists** (21 words)
   The specialists, gathered: everyone knows what's at stake, and nobody says anything outside the room. {holder} calls it a team meeting.
   <sub>energy -2; leadership +2; rel holder +2; skill_points +1; mods inspired</sub>

3. **Let the coaches sort it** (22 words)
   The coaches will sort it out, you decide. They do, slowly, and the specialists' room stays tense and quiet for a month.
   <sub>energy +2; resilience +1; mods rested</sub>

<details><summary>Before</summary>

> Someone is leaking locker-room conversations to a reporter, and the coaches think it's a specialist.

1. **Help find the leak**: You notice which details leak and tell {coach} what they have in common. It's a rookie lineman.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Talk to the specialists**: You talk to the specialists and make sure everyone knows what's at stake.
   <sub>energy -2; social +1; leadership +2; rel team +2; rel coach +1; skill_points +1; mods inspired</sub>

3. **Stay out of it**: You stay out of it and let the coaches sort it out.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 36. PRO_179 The Prime Slump
*training; premise 27 words*

> You're supposed to be at your best, and the misses in practice have started making headlines. The coaches haven't said anything about it yet, which is worse.

1. **Go back to the film** (30 words)
   You go back to the film of your best season and find the one thing that changed: your plant foot drifted half an inch. It takes a week to fix.
   <sub>energy -1; accuracy +2; intelligence +1; rel coach +2; mods focused</sub>

2. **Kick two hundred a day** (24 words)
   You kick through it, two hundred extra balls a day. Your leg aches, your rhythm comes back, and nobody can say you didn't work.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Lean on the holder** (20 words)
   You and {holder} go back to basics together, laughing at how far you've come. It helps more than you expected.
   <sub>social +2; resilience +1; rel holder +3; mods loose</sub>

4. **Use the tools you learned** *(locked: having gotten help before)* (28 words)
   The tools you learned the last time this happened come right back: the breath, the word, the one thought. The slump is shorter this time, by a lot.
   <sub>energy +1; intelligence +1; skill_points +1; mods focused</sub>

<details><summary>Before</summary>

> You're supposed to be at your best, and the misses in practice have started making headlines. The coaches haven't said anything, which is worse.

1. **Go back to the film**: You go back to the film of your best season and find the one thing that changed: your plant foot drifted half an inch. It takes a week to fix.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Kick through it**: You kick through it, two hundred extra balls a day. Your leg aches, your rhythm comes back, and nobody can say you didn't work.
   <sub>energy -2; power +1; ambition +2; skill_points +3; mods dialed_in</sub>

3. **Lean on the holder**: You and {holder} go back to basics together, laughing at how far you've come. It helps more than you expected.
   <sub>social +2; charisma +1; rel holder +3; mods loose</sub>

4. **Use the tools you learned**: You use the tools you learned the last time this happened. It's shorter this time.
   <sub>energy +1; intelligence +1; skill_points +1; mods focused</sub>

</details>

## 37. PRO_184 Untouchable
*media; premise 31 words*

> Your streak is the longest in the league, the highlight shows run it every Sunday, and the other team's kicker catches you on the field after warmups to ask for tips.

1. **Share a tip** (23 words)
   One real tip, about his follow-through. He thanks you publicly the next week, and the league notices what kind of veteran you are.
   <sub>social +2; charisma +1; rel rival +1; followers +2; mods loose</sub>

2. **Don't talk about the streak** (22 words)
   Not a word about the streak, to anyone, including him. He laughs, says he understands completely, and walks away shaking his head.
   <sub>energy -1; resilience +2; intelligence +1; mods focused</sub>

3. **Enjoy it quietly at home** (21 words)
   A good dinner at home, the highlights off, the streak unmentioned. You enjoy it the way you'd want to remember it.
   <sub>energy +2; fun +2; rel parent +1; mods rested</sub>

<details><summary>Before</summary>

> The streak is the longest in the league, and the other team's kicker is asking you for tips.

1. **Share a tip**: You share a tip. He thanks you publicly, and the league notices.
   <sub>social +2; charisma +1; rel team +1; followers +2; mods loose</sub>

2. **Say nothing about it**: You don't talk about the streak, at all, to anyone.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

3. **Enjoy it**: You enjoy it quietly at home with a good dinner.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 38. PRO_192 Hurt in Your Prime
*health; premise 33 words*

> A hip flexor strain, in the best season of your career. The club wants to know how long, the reporters want to know how bad, and the trainers want you to stop asking.

1. **Follow the plan exactly** (22 words)
   The trainers' plan, exactly, every day. You're back right on schedule, and the hip feels stronger than it did before the strain.
   <sub>health +3; energy -1; intelligence +1; rel coach +1; mods focused</sub>

2. **Push to come back early** (22 words)
   Early, by a week, and sore. You kick through it, and the trainers keep a very close eye on you all month.
   <sub>health -2; toughness +1; ambition +2; skill_points +2; mods sore</sub>

3. **Take the full time and more** (21 words)
   The full recovery time and then a few days more. You come back fresh and fully healed, and a little behind.
   <sub>energy +3; health +2; fun +1; mods rested</sub>

4. **Build the plan with the trainers** *(locked: having been through a hard recovery before)* (27 words)
   This time you build the plan with the trainers, using everything you learned last time. You're back early and healthy, and the trainers start asking your advice.
   <sub>energy -1; health +3; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A hip flexor in the best season of your career, and the club wants to know how long.

1. **Follow the plan exactly**: You follow the trainers' plan exactly. You're back on schedule.
   <sub>energy -1; toughness +1; intelligence +2; rel coach +2; mods focused</sub>

2. **Push to come back**: You push to come back early. You do, sore.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Take the full time**: You take the full recovery time and then a little more.
   <sub>energy +2; fun +1; mods rested</sub>

4. **Build the plan with the trainers**: You build the plan with the trainers, using what you learned last time. You're back early and healthy.
   <sub>energy -1; health +3; intelligence +1; mods rested</sub>

</details>

## 39. PRO_202 The Rookie Asks
*team; premise 30 words*

> A rookie specialist catches you after practice with a question you used to ask yourself: how do you stop thinking about the last kick? He looks like he hasn't slept.

1. **Answer it fully** (24 words)
   You answer it fully and stay an hour, showing him the breathing and the one thought. He asks you something new every week after.
   <sub>energy -2; resilience +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Take him to dinner** (23 words)
   Dinner, your treat, and every question answered. He's homesick, too, which you can hear between the questions, and you invite him to Thanksgiving.
   <sub>social +2; charisma +1; rel backup +3; mods loose</sub>

3. **Give him one line** (25 words)
   You give him a short answer and go home. On the drive you think of a better one, and you tell him in the morning.
   <sub>energy +2; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> A rookie specialist catches you after practice with a question you used to ask: how do you stop thinking about the last kick?

1. **Answer it fully**: You answer it fully and stay an hour, showing him the breathing and the one thought. He asks you something new every week after.
   <sub>energy -2; social +1; leadership +2; rel team +2; skill_points +1; mods inspired</sub>

2. **Take him to dinner**: You take him to dinner and answer everything he asks. He's homesick, too, which you can hear between the questions.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

3. **Keep it short**: You give him a short answer and go home. On the drive you think of a better one, and you tell him in the morning.
   <sub>energy +2; fun +1; mods rested</sub>

</details>


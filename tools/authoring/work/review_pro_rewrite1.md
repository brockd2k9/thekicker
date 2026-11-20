# PRO rewrite pass 1: the first 39 era-1 scenes

The first 39 era-1 scenes, in the order players meet them: rookie camp and the first season, then season two and the first offseason, then the scenes that can turn up any time in the rookie years.
Dry run and import: 39 written, 0 errors, 0 warnings, 0 lint notes, including the new writing-standard and repetition checks. Graph check 0/0, 32 tool tests, Godot `TESTS: 165 run, 0 failed`.

**Rewritten: 35 scenes.** PRO_009 only lost two Team changes. **Unchanged: 3** (PRO_001, PRO_002, PRO_004), which already met the standard.
Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. PRO_013 Rookie Year Ends
*team; premise 35 words*

> The season's over, and the locker room empties in one afternoon: duffel bags, handshakes, a line at the equipment window. By dinner you're alone in {town} with no idea what pros do in the offseason.

1. **Copy three veterans' summers** (32 words)
   Three veterans give you three different summers, and you steal the best piece of each. It's the most organized offseason you've ever had, and {holder} texts you a lifting plan every Monday.
   <sub>energy -2; social +1; intelligence +1; rel holder +2; skill_points +2; mods focused</sub>

2. **Go home for a month** (34 words)
   A month at home doing nothing: {parent}'s cooking, your old bedroom, {best_friend} on the porch every night. You come back rested, a little out of shape and happier than you've been since the draft.
   <sub>energy +4; fun +3; rel parent +3; rel best_friend +2; mods rested</sub>

3. **Train like you're still in camp** (24 words)
   You never stop. Six days a week, all summer. By August your leg is the strongest it's been, and you're tired before camp starts.
   <sub>energy -4; ambition +2; skill_points +3; mods heavy_legs</sub>

<details><summary>Before</summary>

> The season's over. The locker room empties in an afternoon, and you realize you have no idea what pros do in the offseason.

1. **Ask the veterans**: You ask three veterans how they spend the offseason and steal the best of each plan. It's the best summer of training you've had.
   <sub>energy -2; social +1; intelligence +1; rel team +1; skill_points +2; mods focused</sub>

2. **Go home for a month**: You go home and do nothing for a month: {parent}'s cooking, old friends, your old bedroom. You come back rested and a little out of shape.
   <sub>energy +4; fun +3; rel parent +3; mods rested</sub>

3. **Train like you're still in camp**: You never stop. Six days a week, all summer. By August your leg is the strongest it's been, and you're tired before camp starts.
   <sub>energy -4; ambition +2; skill_points +3; mods heavy_legs</sub>

</details>

## 2. PRO_001 Rookie Camp (unchanged)
*team; premise 31 words*

> Camp opens with four kickers on the roster and one job. The special teams coordinator has called you by the wrong name twice, and {coach} hasn't called you anything at all.

1. **Be the first one on the field** (26 words)
   You're stretching on the field at six every morning before the trainers unlock the door. By the second week, {coach} knows your name and uses it.
   <sub>energy -3; ambition +2; rel coach +3; skill_points +2; mods dialed_in</sub>

2. **Learn the room before the field** (33 words)
   You spend the first week listening: who the veterans trust, which snapper the coaches like, where the rookies sit at lunch. It's slow, and nothing in that locker room surprises you after it.
   <sub>social +2; intelligence +1; charisma +1; rel team +3; mods focused</sub>

3. **Kick like it's already yours** (27 words)
   You walk in like the job is yours and kick like it too. Two veterans love it. One of the other kickers stops talking to you entirely.
   <sub>fun +2; ambition +2; charisma +1; rel team -2; skill_points +1; mods confident</sub>

4. **Do what got you here** *(locked: having trained with a pro or rebuilt a reputation before)* (30 words)
   You've been in rooms where nobody expected anything from you. You kick, you say little, and you keep a notebook of every correction. {coach} borrows the notebook in week two.
   <sub>energy -2; intelligence +1; leadership +1; rel coach +4; skill_points +1; mods focused</sub>

## 3. PRO_002 The Kicker You're Replacing (unchanged)
*team; premise 27 words*

> The kicker whose job you're taking has been here eleven years. His locker is next to yours, and he can make your first month easy or impossible.

1. **Ask him to teach you** (26 words)
   You ask him straight out how he lasted eleven years. He stares at you for a while, then starts talking and doesn't stop for an hour.
   <sub>energy -1; social +1; intelligence +1; rel team +2; skill_points +1; mods inspired; flags learned_from_veteran</sub>

2. **Compete and keep your distance** (21 words)
   You stay polite and give him nothing. Every kick in camp becomes a quiet contest, and both of you get better.
   <sub>social -1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Freeze him out** (32 words)
   You sit with the younger players, laugh at the right jokes about his age and let the room decide who's in charge. You win the room. You also notice who stopped laughing.
   <sub>fun +1; social +1; ambition +1; leadership -2; rel team -3; mods confident; flags froze_out_veteran</sub>

## 4. PRO_003 Your First Real Payday
*money; premise 26 words*

> Your first real paycheck lands, and it has more zeros than {parent} made in a year. Your phone starts buzzing before you've finished reading the number.

1. **Save most of it** (31 words)
   You put most of it into an account you promise not to touch and buy one thing: a mattress that isn't from a dorm. It's dull, and you sleep very well.
   <sub>energy +2; fun -1; intelligence +2; mods rested; flags saved_rookie_check</sub>

2. **Spend it like you earned it** (20 words)
   You buy the car, the watch and dinner for the whole rookie class. It feels incredible for about a month.
   <sub>fun +4; social +2; intelligence -1; charisma +1; followers +2; mods loose; flags spent_rookie_check</sub>

3. **Pay off {parent}'s debts** (30 words)
   {parent} refuses twice when you ask for the number on every bill, then gives in the third time. The calls home sound different after that: lighter, and a lot longer.
   <sub>fun -1; leadership +1; rel parent +7; mods inspired; flags paid_family_debt</sub>

4. **Split it the way you always have** *(locked: having handled your first paychecks wisely)* (31 words)
   You do what you did with your first paycheck at sixteen, just with more zeros: a third saved, a third home, a third yours. It's an old habit, and it holds.
   <sub>fun +1; intelligence +1; rel parent +3; mods focused; flags saved_rookie_check</sub>

<details><summary>Before</summary>

> Your first real paycheck lands, and it has more zeros than {parent} made in a year. Your phone starts buzzing before you've finished reading the number.

1. **Save most of it**: You put most of it into an account you promise not to touch and buy one thing: a mattress that isn't from a dorm. It's dull, and you sleep very well.
   <sub>energy +2; fun -1; intelligence +2; mods rested; flags saved_rookie_check</sub>

2. **Spend it like you earned it**: You buy the car, the watch and dinner for the whole rookie class. It feels incredible for about a month.
   <sub>fun +4; social +2; intelligence -1; charisma +1; followers +2; mods loose; flags spent_rookie_check</sub>

3. **Pay off {parent}'s debts**: You call {parent} and ask for the number on every bill. He refuses twice and gives in the third time. The calls home sound different after that.
   <sub>fun -1; leadership +1; rel parent +7; mods inspired; flags paid_family_debt</sub>

4. **Split it the way you always have**: You do what you did with your first paycheck at sixteen, just with more zeros: a third saved, a third home, a third yours. It's an old habit, and it holds.
   <sub>fun +1; intelligence +1; rel parent +3; mods focused; flags saved_rookie_check</sub>

</details>

## 5. PRO_004 Rookie Duties (unchanged)
*team; premise 36 words*

> The veterans hand the rookies a list: breakfast for the unit every Friday, carrying the pads, a song on the team plane. Most of it is fun. One item, a stunt in a hotel hallway, isn't.

1. **Do the list, skip the stunt** (24 words)
   You do every chore with a grin and tell the captain, privately, you're not doing the hallway stunt. He shrugs and crosses it off.
   <sub>social +1; leadership +1; rel team +2; mods loose</sub>

2. **Do all of it** (28 words)
   You do everything on the list, the stunt included. The veterans cheer, a rookie gets hurt doing the same one, and the coaches hold a meeting about it.
   <sub>fun +4; social +2; energy -2; leadership -1; rel team +1; rel coach -2; mods late_night</sub>

3. **Turn the song into a show** (25 words)
   You go all in on the plane song, with costumes. It's the best one in years, and the veterans stop giving you the worst chores.
   <sub>fun +3; energy -1; charisma +2; rel team +3; followers +1; mods loose</sub>

4. **Fix the list with the captain** *(locked: having run freshman traditions in college)* (29 words)
   You ran this kind of tradition in college, so you sit down with the captain and rewrite the stunt into something nobody gets hurt doing. It's a quiet win.
   <sub>energy -1; leadership +2; intelligence +1; rel team +3; rel coach +1; mods confident</sub>

## 6. PRO_005 The Long Snapper
*team; premise 26 words*

> The long snapper has been in the league fourteen years and has opinions about everything, including your warmup, your shoes and the way you say 'hold'.

1. **Listen to every opinion** (21 words)
   You let him talk. Half of it is nonsense. The other half fixes a timing problem you didn't know you had.
   <sub>energy -1; social +1; intelligence +1; skill_points +1; mods focused; flags trusted_snapper</sub>

2. **Push back on the warmup** (32 words)
   Your warmup isn't changing, you tell him, and you don't blink. He respects it more than you expected and starts timing his snaps to your count by the end of the week.
   <sub>ambition +1; charisma +1; leadership +1; mods confident; flags trusted_snapper</sub>

3. **Keep it professional** (20 words)
   You say thanks, keep it short and do your own thing. The snaps are fine. The friendship never quite starts.
   <sub>energy +1; ambition +1; skill_points +1; mods rested</sub>

<details><summary>Before</summary>

> The long snapper has been in the league fourteen years and has opinions about everything, including your warmup, your shoes and the way you say 'hold'.

1. **Listen to every opinion**: You let him talk. Half of it is nonsense. The other half fixes a timing problem you didn't know you had.
   <sub>energy -1; social +1; intelligence +1; skill_points +1; mods focused; flags trusted_snapper</sub>

2. **Push back on the warmup**: You tell him your warmup isn't changing. He respects it more than you expected and starts timing his snaps to it.
   <sub>ambition +1; charisma +1; leadership +1; mods confident; flags trusted_snapper</sub>

3. **Keep it professional**: You say thanks, keep it short and do your own thing. The snaps are fine. The friendship never quite starts.
   <sub>energy +1; ambition +1; skill_points +1; mods rested</sub>

</details>

## 7. PRO_006 Curfew on the Road
*social; premise 27 words*

> First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies. Three of them are already in the lobby.

1. **Stay in** (21 words)
   You order room service, watch film and are asleep by ten-thirty. At breakfast you're the only rookie who isn't wearing sunglasses.
   <sub>energy +3; social -1; ambition +1; rel coach +1; mods rested</sub>

2. **Go to dinner, back by eleven** (31 words)
   Dinner with the veterans is loud and fun, and you laugh at every story. You leave before dessert. A couple of them call you a rookie; a couple of them nod.
   <sub>fun +2; social +2; intelligence +1; rel team +1; mods loose</sub>

3. **Go out with them** (25 words)
   You go out and come back at three. Bed check was at eleven, and your name is on the list {coach} reads out at breakfast.
   <sub>fun +4; social +3; energy -5; leadership -2; rel coach -5; retention -2; conduct bad; mods late_night; flags stayed_out_pro</sub>

<details><summary>Before</summary>

> First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies. Three of them are already in the lobby.

1. **Stay in**: You order room service, watch film and are asleep by ten-thirty. At breakfast you're the only rookie who isn't wearing sunglasses.
   <sub>energy +3; social -1; ambition +1; rel coach +1; mods rested</sub>

2. **Go to dinner, back by eleven**: You go to dinner with the veterans, laugh at their stories and leave before dessert. A couple of them call you a rookie. A couple of them nod.
   <sub>fun +2; social +2; intelligence +1; rel team +1; mods loose</sub>

3. **Go out with them**: You go out and come back at three. Bed check was at eleven, and your name is on the list {coach} reads out at breakfast.
   <sub>fun +4; social +3; energy -5; leadership -2; rel coach -5; retention -2; conduct bad; mods late_night; flags stayed_out_pro</sub>

</details>

## 8. PRO_007 Where You Live
*money; premise 29 words*

> Half the roster lives in the same glass tower downtown, with a rooftop pool and a doorman who knows everyone's name. The rent is a quarter of your salary.

1. **Rent something modest** (37 words)
   You rent a two-bedroom twenty minutes from the facility, above a bakery. The teammates call it 'the bakery'. You save more in a month than some of them save in a year, and the commute is short.
   <sub>fun -1; social -1; energy +2; intelligence +2; mods rested; flags lived_modestly</sub>

2. **Move into the tower** (33 words)
   The lease in the tower gets signed on a Tuesday. The pool parties are legendary and the elevators are full of teammates, and the rent comes out of every check like a tax.
   <sub>fun +3; social +3; intelligence -1; rel team +2; mods loose; flags lived_large</sub>

3. **Room with a teammate** (29 words)
   Splitting a place with another rookie is cheaper and louder than you planned. You never eat dinner alone, and you learn more about him than you ever wanted to.
   <sub>social +2; energy -1; charisma +1; rel team +1; mods loose</sub>

<details><summary>Before</summary>

> Half the roster lives in the same glass tower downtown, with a rooftop pool and a doorman who knows everyone's name. The rent is a quarter of your salary.

1. **Rent something modest**: You rent a two-bedroom twenty minutes from the facility, above a bakery. The teammates call it 'the bakery'. You save more in a month than some of them save in a year, and the commute is short.
   <sub>fun -1; social -1; energy +2; intelligence +2; mods rested; flags lived_modestly</sub>

2. **Move into the tower**: You sign the lease in the tower. The pool parties are legendary, the elevator rides are full of teammates, and the rent comes out of every check like a tax.
   <sub>fun +3; social +3; intelligence -1; rel team +2; mods loose; flags lived_large</sub>

3. **Room with a teammate**: You split a place with another rookie. It's cheaper, louder, and you never eat dinner alone.
   <sub>social +2; energy -1; charisma +1; rel team +1; mods loose</sub>

</details>

## 9. PRO_008 Homesick in {town}
*family; premise 30 words*

> Nobody in {town} knows your name yet. Practice ends at four, the apartment is very quiet on Tuesday nights, and the only voice you hear after dinner is the television.

1. **Call home every night** (33 words)
   You call home every night for a week. {parent} starts saving up stories for you like he used to before school, and {sibling} grabs the phone at the end to complain about homework.
   <sub>social +1; fun +1; rel parent +4; rel sibling +2; mods rested</sub>

2. **Make the city yours** (23 words)
   You pick one new neighborhood every Tuesday and walk it until dinner. By October, {town} has a coffee shop that knows your order.
   <sub>energy -1; fun +2; intelligence +1; mods inspired</sub>

3. **Bury it in work** (29 words)
   Every quiet night ends in the film room. You become the best-prepared rookie on the roster and the loneliest one, and the cleaning crew starts saying goodnight to you.
   <sub>social -2; ambition +2; skill_points +2; mods dialed_in</sub>

4. **Keep the Sunday call** *(locked: having promised to call home every week)* (27 words)
   You kept the Sunday call through four years of college, and you keep it now. The first Sunday in {town}, {sibling} answers and talks for an hour.
   <sub>social +1; fun +2; rel parent +3; rel sibling +3; mods rested</sub>

<details><summary>Before</summary>

> Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.

1. **Call home every night**: You call home every night for a week. {parent} starts saving up stories for you, like he used to before school.
   <sub>social +1; fun +1; rel parent +4; mods rested</sub>

2. **Make the city yours**: You pick one new neighborhood every Tuesday and walk it until dinner. By October, {town} has a coffee shop that knows your order.
   <sub>energy -1; fun +2; intelligence +1; mods inspired</sub>

3. **Bury it in work**: You spend every quiet night in the film room. You're the best-prepared rookie on the roster and the loneliest.
   <sub>social -2; ambition +2; skill_points +2; mods dialed_in</sub>

4. **Keep the Sunday call**: You kept the Sunday call through four years of college, and you keep it now. The first Sunday in {town}, {sibling} answers and talks for an hour.
   <sub>social +1; fun +2; rel parent +3; rel sibling +3; mods rested</sub>

</details>

## 10. PRO_009 The Practice Squad Friend
*team; premise 26 words*

> The receiver you've eaten lunch with since camp gets cut on a Tuesday morning. At noon he's still sitting in his car in the players' lot.

1. **Sit in the car with him** (24 words)
   You knock on the window and sit in the passenger seat for an hour. You don't say much. He drives away a little steadier.
   <sub>energy -1; social +1; charisma +1; mods drained</sub>

2. **Make a call for him** (22 words)
   You call a coach you know at another club and say the receiver's name twice. He gets a workout the next week.
   <sub>energy -1; leadership +2; intelligence +1; mods inspired</sub>

3. **Leave him alone** (26 words)
   You walk past to your own car. It's not your business, and it could be you next year. You think about it the whole drive home.
   <sub>energy +1; ambition +1; skill_points +1; mods distracted</sub>

<details><summary>Before</summary>

> The receiver you've eaten lunch with since camp gets cut on a Tuesday morning. At noon he's still sitting in his car in the players' lot.

1. **Sit in the car with him**: You knock on the window and sit in the passenger seat for an hour. You don't say much. He drives away a little steadier.
   <sub>energy -1; social +1; charisma +1; rel team +2; mods drained</sub>

2. **Make a call for him**: You call a coach you know at another club and say the receiver's name twice. He gets a workout the next week.
   <sub>energy -1; leadership +2; intelligence +1; rel team +1; mods inspired</sub>

3. **Leave him alone**: You walk past to your own car. It's not your business, and it could be you next year. You think about it the whole drive home.
   <sub>energy +1; ambition +1; skill_points +1; mods distracted</sub>

</details>

## 11. PRO_010 Meeting the Owner
*team; premise 26 words*

> The owner throws a party for the rookies at his house and spends twenty minutes telling you exactly what kickers are worth, which is not much.

1. **Smile and agree** (23 words)
   You smile, agree and get a second drink of lemonade. He likes you. You feel slightly worse about yourself on the drive home.
   <sub>social +1; energy +1; charisma +1; ambition -1; retention +1; mods distracted</sub>

2. **Make him laugh** (28 words)
   Kickers are the only players who show up every week without hurting anyone, you tell him. He laughs harder than you expected and remembers your name all season.
   <sub>fun +2; social +2; charisma +2; mods confident</sub>

3. **Tell him he's wrong** (28 words)
   Politely, and with numbers, you explain why he's wrong. The room goes quiet, his wife changes the subject, and {coach} has heard all about it by Monday morning.
   <sub>social -1; ambition +2; leadership +1; rel coach -2; mods stressed</sub>

<details><summary>Before</summary>

> The owner throws a party for the rookies at his house and spends twenty minutes telling you exactly what kickers are worth, which is not much.

1. **Smile and agree**: You smile, agree and get a second drink of lemonade. He likes you. You feel slightly worse about yourself on the drive home.
   <sub>social +1; energy +1; charisma +1; ambition -1; retention +1; mods distracted</sub>

2. **Make him laugh**: You tell him kickers are the only players who show up to work every week without hurting anyone. He laughs harder than you expected and remembers your name.
   <sub>fun +2; social +2; charisma +2; mods confident</sub>

3. **Tell him he's wrong**: You tell him, politely, that he's wrong, and why. The room goes quiet. {coach} hears about it by Monday.
   <sub>social -1; ambition +2; leadership +1; rel coach -2; mods stressed</sub>

</details>

## 12. PRO_011 The Quote
*media; premise 33 words*

> You said something careless to a beat reporter about the kicker you replaced, half a joke, and by morning it's the headline on the team's biggest fan site, with his photo beside yours.

1. **Apologize to his face** (29 words)
   You find him in the weight room and apologize, no excuses. He accepts it more gracefully than you would have, and the room watches you both walk out together.
   <sub>energy -1; social -1; leadership +2; rel team +3; mods drained</sub>

2. **Say it was taken out of context** (27 words)
   Out of context, you tell another reporter. The original reporter posts the full recording an hour later, and now the story is that you said it twice.
   <sub>fun +1; ambition +1; intelligence -1; rel team -2; rel coach -2; followers -2; mods stressed</sub>

3. **Wait for it to pass** (25 words)
   A week of silence lets it blow over online. The veterans remember it longer, and for a month nobody saves you a seat at lunch.
   <sub>energy +1; rel team -1; mods distracted</sub>

4. **Handle it the way you learned to** *(locked: having been through a public mistake before)* (23 words)
   You've done this before. You call the reporter back, own the quote, and apologize to the veteran before lunch. It's over by dinner.
   <sub>energy -2; leadership +2; intelligence +1; rel team +2; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> You said something careless to a beat reporter about the kicker you replaced, and it's the headline on the team's biggest fan site.

1. **Apologize to his face**: You find him and apologize in person, no excuses. He accepts it more gracefully than you would have.
   <sub>energy -1; social -1; leadership +2; rel team +3; mods drained</sub>

2. **Say it was taken out of context**: You tell another reporter it was out of context. The original reporter posts the full recording.
   <sub>fun +1; ambition +1; intelligence -1; rel team -2; rel coach -2; followers -2; mods stressed</sub>

3. **Say nothing**: You let it blow over. It does, in about a week, and the veterans remember it a while longer.
   <sub>energy +1; rel team -1; mods distracted</sub>

4. **Handle it the way you learned to**: You've done this before. You call the reporter back, own the quote, and apologize to the veteran before lunch. It's over by dinner.
   <sub>energy -2; leadership +2; intelligence +1; rel team +2; rel coach +1; mods focused</sub>

</details>

## 13. PRO_012 Your First Autograph Line
*community; premise 25 words*

> A kid in a jersey with your number on it is first in line at the autograph table. You didn't know they made your number.

1. **Take your time with him** (29 words)
   The jersey, the ball and his little brother's hat all get signed, and you ask about his own team. The line behind him grows, and nobody seems to mind.
   <sub>energy -1; social +2; fun +2; charisma +1; leadership +1; followers +2; mods inspired</sub>

2. **Ask his parents for a photo** (31 words)
   His parents say yes to a photo, and you post it with his first name only. It's the best-liked thing you've ever posted, and his coach prints it for the team.
   <sub>fun +2; charisma +2; followers +4; mods spotlight</sub>

3. **Keep the line moving** (26 words)
   You sign, smile and keep the line moving like the team's staff asked. Two hundred people get an autograph, and none of them get a moment.
   <sub>energy -2; leadership +1; intelligence +1; rel team +1; followers +1; mods focused</sub>

<details><summary>Before</summary>

> A kid in a jersey with your number on it is first in line at the autograph table. You didn't know they made your number.

1. **Take your time with him**: You sign the jersey, the ball and his little brother's hat, and ask him about his own team. The line behind him gets longer and nobody minds.
   <sub>energy -1; social +2; fun +2; charisma +1; leadership +1; followers +2; mods inspired</sub>

2. **Ask his parents for a photo**: You ask for a photo and post it with his first name and no last name. It's the best-liked thing you've ever posted.
   <sub>fun +2; charisma +2; followers +4; mods spotlight</sub>

3. **Keep the line moving**: You sign, smile and keep the line moving like the team's staff asked. Two hundred people get an autograph, and none of them get a moment.
   <sub>energy -2; leadership +1; intelligence +1; rel team +1; followers +1; mods focused</sub>

</details>

## 14. PRO_625 The New Club as a Rookie
*team; premise 37 words*

> Released after your first camp and signed somewhere new three days later, you walk into a building where nobody knows your name, your locker still has the last kicker's tape on it, and the season starts Sunday.

1. **Learn the building by Friday** (30 words)
   Every name in the building is yours by Friday: trainers, equipment staff, the snapper's kids. Nobody owes you anything here, and by the first game that has started to change.
   <sub>social +2; energy -1; charisma +2; rel team +2; rel holder +2; mods loose</sub>

2. **Kick like it's still a tryout** (29 words)
   Every rep in practice is a tryout, because it still is. Your leg is tired by Thursday, and the coaches stop watching you like a stranger who might leave.
   <sub>energy -3; power +1; resilience +1; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Find out what they saw** (29 words)
   {coach} pulls up your college film and shows you the three kicks that got you signed. It's a short list, and you build your whole first month around it.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +2; mods focused</sub>

<details><summary>Before</summary>

> Released after your first camp and signed somewhere new, you're starting your rookie year over.

1. **Learn every name fast**: You learn every name in the new building by Friday. Nobody owes you anything, and that starts to change.
   <sub>social +2; charisma +1; rel team +3; mods loose</sub>

2. **Kick like it's a tryout**: You kick every practice like it's a tryout, because it still is.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Ask what they saw in you**: You ask {coach} what the club saw in your film. It's a list to build on.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

</details>

## 15. PRO_015 Your Story, Secondhand
*social; premise 29 words*

> A college teammate calls from his rookie symposium: they told a story about a player who owned his mistakes and came back, and it sounded a lot like you.

1. **Tell him the real version** (28 words)
   The parts that didn't make the speech come out: the bad nights, the early workouts, the people who wouldn't look at you. He goes quiet, then thanks you.
   <sub>energy -1; social +1; leadership +1; charisma +1; mods inspired</sub>

2. **Say they meant someone else** (26 words)
   They must have meant someone else, you say, and change the subject. It's easier than talking about it, and the story sits with you all week.
   <sub>fun +1; mods distracted</sub>

3. **Call the people who helped** (21 words)
   You hang up and call the coach who gave you the chance. The coach doesn't say much, and doesn't need to.
   <sub>energy -1; intelligence +1; rel coach +1; mods focused</sub>

<details><summary>Before</summary>

> A college teammate calls from his rookie symposium: they told a story about a player who owned his mistakes and came back, and it sounded a lot like you.

1. **Tell him the real version**: You tell him the parts that didn't make the speech: the bad nights, the early workouts, the people who wouldn't look at you for a while. He goes quiet and then thanks you.
   <sub>energy -1; social +1; leadership +1; charisma +1; mods inspired</sub>

2. **Laugh it off**: You laugh and say they must have meant someone else. It's easier than talking about it, and you feel it all week.
   <sub>fun +1; mods distracted</sub>

3. **Call the people who helped**: You hang up and call the coach who gave you the chance. The coach doesn't say much, and doesn't need to.
   <sub>energy -1; intelligence +1; rel coach +1; mods focused</sub>

</details>

## 16. PRO_014 The Second-Year Wall
*team; premise 34 words*

> Year two. The novelty is gone, the scouting reports on you are thicker, the rookie snapper calls you 'sir', and your legs remember every kick of last season when you get out of bed.

1. **Change something small** (24 words)
   You change one thing, a half-step in your approach, and chart it for a month. It takes, and it surprises the coaches watching you.
   <sub>energy -1; intelligence +2; rel coach +2; skill_points +1; mods focused</sub>

2. **Change nothing** (27 words)
   You decide last year's routine earned you this year, and you keep every piece of it. Some weeks it works perfectly. Some weeks it's just a routine.
   <sub>energy +1; ambition +1; skill_points +1; mods confident</sub>

3. **Take on a rookie** (32 words)
   {backup}, the new rookie specialist, gets your lunch table, your notes and your Tuesday nights, the way someone once gave you theirs. It costs you time, and it makes the room yours.
   <sub>energy -2; social +2; leadership +2; rel backup +3; mods inspired</sub>

<details><summary>Before</summary>

> Year two. The novelty is gone, the scouting reports on you are thicker, and your legs remember every kick of last season.

1. **Change something small**: You change one thing, a half-step in your approach, and chart it for a month. It takes, and it surprises the coaches watching you.
   <sub>energy -1; intelligence +2; rel coach +2; skill_points +1; mods focused</sub>

2. **Change nothing**: You decide last year's routine earned you this year, and you keep every piece of it. Some weeks it works perfectly. Some weeks it's just a routine.
   <sub>energy +1; ambition +1; skill_points +1; mods confident</sub>

3. **Take on a rookie**: You take the new rookie specialist under your wing, like someone did for you. It costs you time, and it makes the room yours.
   <sub>energy -2; social +2; leadership +2; rel team +3; mods inspired</sub>

</details>

## 17. PRO_269 Summer at Home
*family; premise 35 words*

> Your first offseason back home. Everyone at the grocery store wants to talk about one kick, the high school has your picture in the trophy case, and {parent} has told the whole street you're coming.

1. **Enjoy being home** (32 words)
   Your old bedroom, {parent}'s cooking and {sibling} in the next room, just like before. The town makes a fuss, you let it, and it's the best month you've had in a year.
   <sub>fun +4; energy +3; rel parent +4; rel sibling +2; mods rested</sub>

2. **Train at your old high school** (20 words)
   You train on your old high school field every morning. The kids on the team start showing up to watch.
   <sub>energy -2; social +1; leadership +1; skill_points +2; mods focused</sub>

3. **Hide from the attention** (29 words)
   You stay in, see {best_friend} and a few old friends at night, and avoid the grocery store entirely. It's quiet and restful, and by July it's a little lonely.
   <sub>energy +2; social -1; intelligence +1; rel best_friend +2; mods rested</sub>

<details><summary>Before</summary>

> Your first offseason back home, and everyone at the grocery store wants to talk about one kick.

1. **Enjoy being home**: You sleep in your old bedroom, eat {parent}'s cooking and let the town make a fuss. It's the best month you've had in a year.
   <sub>fun +4; energy +3; rel parent +4; mods rested</sub>

2. **Train at your old high school**: You train on your old high school field every morning. The kids on the team start showing up to watch.
   <sub>energy -2; social +1; leadership +1; skill_points +2; mods focused</sub>

3. **Hide from the attention**: You stay in, see a few friends, and avoid the grocery store. It's quiet, and a little lonely.
   <sub>energy +2; social -1; intelligence +1; rel best_friend +2; mods rested</sub>

</details>

## 18. PRO_618 The Rookie Year Review
*team; premise 34 words*

> {coach} closes the office door and sits you down for an honest review of your first season: a folder of charts, a laptop of clips, and a list that starts with the word 'concerns'.

1. **Take notes on all of it** (31 words)
   Every point goes in your notebook, and you ask about the ones that sting. You leave with a summer plan and the feeling that the coach is actually on your side.
   <sub>energy -1; accuracy +1; intelligence +2; rel coach +3; mods focused</sub>

2. **Ask for the three hardest truths** (28 words)
   {coach} gives you three without softening them: your plant foot drifts, you look rattled after misses, and you don't lift enough. You work on all three until August.
   <sub>energy -2; resilience +2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Bring your own review** (29 words)
   Your own review is four handwritten pages, and half of it matches theirs. The coach is impressed you thought about it, and {holder} laughs that you graded yourself harder.
   <sub>social +1; charisma +1; leadership +1; intelligence +1; rel coach +1; rel holder +2; mods confident</sub>

<details><summary>Before</summary>

> {coach} sits you down for an honest review of your first season.

1. **Take notes**: You take notes on everything and ask follow-up questions. You leave with a plan.
   <sub>energy -1; intelligence +2; rel coach +2; mods focused</sub>

2. **Ask for the hard truths**: You ask for the three hardest truths. You get them, and you work on them all summer.
   <sub>energy -2; ambition +2; skill_points +2; mods dialed_in</sub>

3. **Share your own review**: You bring your own review and compare. The coach is impressed you thought about it.
   <sub>social +2; charisma +1; rel coach +1; mods loose</sub>

</details>

## 19. PRO_619 The Offseason Without Structure
*training; premise 34 words*

> For the first time in your life, nobody tells you what to do all summer. No coach, no schedule, no bell. The facility is closed for six weeks, and your phone is very quiet.

1. **Write your own program** (29 words)
   Twelve weeks, written by hand and taped to the fridge, and you follow it to the day. It's lonely work, and you report to camp stronger than anyone expected.
   <sub>energy -3; power +2; ambition +1; skill_points +2; mods dialed_in</sub>

2. **Disappear for three weeks** (28 words)
   Three weeks with no ball, no film and no phone. It feels wrong for five days and wonderful after, and you come back to the field genuinely hungry.
   <sub>energy +3; fun +2; health +1; mods rested</sub>

3. **Train with {best_friend}** (32 words)
   {best_friend} drives up for a month and holds for you every morning in a city park. It's real work and a lot of laughing, and neither of you wants it to end.
   <sub>social +2; fun +1; energy -1; accuracy +1; rel best_friend +4; mods loose</sub>

<details><summary>Before</summary>

> For the first time in your life, nobody tells you what to do all summer.

1. **Build your own plan**: You build a strict plan and follow it. You come back stronger.
   <sub>energy -2; power +1; ambition +2; skill_points +2; mods dialed_in</sub>

2. **Take a real break**: You take three weeks off completely. You come back hungry.
   <sub>energy +2; fun +1; mods rested</sub>

3. **Train with friends**: You train with old college teammates. It's fun and it's real work.
   <sub>social +2; charisma +1; rel best_friend +3; mods loose</sub>

</details>

## 20. PRO_188 The Veteran They Signed to Push You
*team; premise 33 words*

> The club signs a thirty-four-year-old kicker 'for depth'. He has a locker two down from yours, a ring from another club, and everybody in the building knows what 'depth' means for a rookie.

1. **Learn from the veteran** (29 words)
   The veteran watches your warmup once and fixes your hip turn in five minutes. He doesn't make a speech about it, and you wonder why he'd help his competition.
   <sub>social +1; accuracy +1; intelligence +2; skill_points +1; mods focused</sub>

2. **Compete every day** (27 words)
   Every practice becomes a contest you refuse to lose. The veteran is tired by October and you aren't, and {coach} starts calling your name first in meetings.
   <sub>energy -3; ambition +2; rel coach +1; skill_points +2; mods dialed_in</sub>

3. **Go out and forget about it** (27 words)
   You go out with the other rookies every night that week to stop thinking about the veteran. It works until Monday, when {coach} notices you look tired.
   <sub>fun +2; social +1; energy -1; charisma +1; rel coach -1; mods late_night</sub>

<details><summary>Before</summary>

> The club signs a thirty-four-year-old kicker 'for depth'. Everybody knows what that means for a rookie.

1. **Learn from the veteran**: You ask the veteran to watch your warmup. He does, and fixes something in five minutes.
   <sub>social +1; intelligence +2; skill_points +1; mods focused</sub>

2. **Compete every day**: You turn every practice into a contest. The veteran is tired by October, and you aren't.
   <sub>energy -3; ambition +2; rel coach +1; skill_points +2; mods dialed_in</sub>

3. **Go out and forget about it**: You go out with the other rookies every night that week to stop thinking about the veteran. It works until Monday, when {coach} notices you look tired.
   <sub>fun +2; social +1; energy -1; charisma +1; rel coach -1; mods late_night</sub>

</details>

## 21. PRO_029 The Backup Wants Your Job
*team; premise 32 words*

> {backup} is on the practice squad and has been kicking very well where the coaches can see: long ones after practice, clean ones in team drills, and a few reporters have noticed.

1. **Kick with {backup}** (22 words)
   You ask {backup} to share your warmups. It makes you both better, and it makes the coaches' decision harder, which is fine.
   <sub>energy -1; social +1; leadership +1; rel backup +5; skill_points +1; mods focused</sub>

2. **Out-work {backup}** (28 words)
   Every day for a month, you stay later than {backup}. The coaches notice the hours more than the kicks, and {backup} starts leaving earlier, which tells you something.
   <sub>energy -3; ambition +2; rel coach +2; skill_points +2; mods dialed_in</sub>

3. **Let the coaches decide** (24 words)
   The practice squad isn't your problem, you decide. Your kicking stays the same, and so does the whispering, and {backup} stops saying good morning.
   <sub>energy +1; fun +1; rel backup -2; mods rested</sub>

<details><summary>Before</summary>

> {backup} is on the practice squad and has been kicking very well where the coaches can see.

1. **Kick with {backup}**: You ask {backup} to share your warmups. It makes you both better, and it makes the coaches' decision harder, which is fine.
   <sub>energy -1; social +1; leadership +1; rel backup +5; skill_points +1; mods focused</sub>

2. **Out-work {backup}**: You stay later than {backup} every day for a month. The coaches notice the hours more than the kicks.
   <sub>energy -3; ambition +2; rel coach +2; skill_points +2; mods dialed_in</sub>

3. **Ignore it**: You decide the practice squad isn't your problem. Your kicking stays the same, and so does the whispering.
   <sub>energy +1; fun +1; rel backup -2; mods rested</sub>

</details>

## 22. PRO_030 The New Holder Midseason
*team; premise 31 words*

> {holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick. The quarterback has soft hands, a nervous laugh and four days before Sunday.

1. **Teach the new holder** (21 words)
   You stay after practice every day with the backup quarterback until the laces spin right. By Friday the holds are clean.
   <sub>energy -3; social +1; leadership +2; rel team +2; mods focused</sub>

2. **Ask for the punter instead** (26 words)
   The punter has held before, you point out to {coach}. The coach agrees, the punter shrugs, and the relieved quarterback buys you lunch the next day.
   <sub>intelligence +1; ambition +1; rel coach +1; mods confident</sub>

3. **Visit {holder}** (26 words)
   You visit {holder} in the training room and bring the new holder along for a lesson. Two holders and a kicker in one cramped room, laughing.
   <sub>social +2; fun +1; charisma +1; rel holder +4; mods loose</sub>

<details><summary>Before</summary>

> {holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick.

1. **Teach the new holder**: You stay after practice every day with the backup quarterback until the laces spin right. By Friday the holds are clean.
   <sub>energy -3; social +1; leadership +2; rel team +2; mods focused</sub>

2. **Ask for a different holder**: You ask {coach} for the punter instead. The coach agrees, and the quarterback looks relieved.
   <sub>intelligence +1; ambition +1; rel coach +1; mods confident</sub>

3. **Visit {holder}**: You visit {holder} in the training room and bring the new holder along for a lesson. Two holders and a kicker in one cramped room, laughing.
   <sub>social +2; fun +1; charisma +1; rel holder +4; mods loose</sub>

</details>

## 23. PRO_034 The Kick Everyone Saw
*media; premise 32 words*

> A clip of your practice-field trick shot, the ball off the crossbar and into a trash can forty yards away, goes around the league overnight. Your phone has two hundred new messages.

1. **Make a few more** (20 words)
   You film a series with the specialists. It's fun, the club's social media team loves it, and the coaches don't.
   <sub>fun +3; charisma +2; rel coach -1; followers +5; mods spotlight</sub>

2. **Let it be one clip** (27 words)
   A thank-you post, and that's all. The clip fades in a week, the coaches never mention it, and you're a little sorry you didn't enjoy it more.
   <sub>energy +1; intelligence +1; followers +1; mods focused</sub>

3. **Use it for charity** (20 words)
   You turn the clip into a charity challenge: a donation for every kid who sends in their own trick shot.
   <sub>energy -2; social +2; leadership +1; charisma +1; followers +3; mods inspired</sub>

<details><summary>Before</summary>

> A clip of you in a practice-field trick shot, the ball off the crossbar and into a trash can, goes around the league.

1. **Make a few more**: You film a series with the specialists. It's fun, the club's social media team loves it, and the coaches don't.
   <sub>fun +3; charisma +2; rel coach -1; followers +5; mods spotlight</sub>

2. **Let it be one clip**: You thank people and leave it there. It fades in a week.
   <sub>energy +1; intelligence +1; followers +1; mods focused</sub>

3. **Use it for charity**: You turn the clip into a charity challenge: a donation for every kid who sends in their own trick shot.
   <sub>energy -2; social +2; leadership +1; charisma +1; followers +3; mods inspired</sub>

</details>

## 24. PRO_050 The Good Agent
*career; premise 26 words*

> An agent with six clients asks for an hour. The pitch has no private jets and no promises, just a plan so plain it's almost funny.

1. **Sign with the plain plan** (29 words)
   Signing with them is quiet. The calls get answered, the deadlines get met, and nothing about it will ever make a highlight reel, which is exactly what you hired.
   <sub>energy +1; intelligence +2; mods focused; flags good_agent</sub>

2. **Stay with the big agency** (28 words)
   The big agency's name opens doors, so you stay. Some doors do open. Some just have a receptionist behind them who never remembers how to spell your name.
   <sub>fun +1; ambition +2; followers +1; mods confident</sub>

3. **Ask what they'd fix first** (26 words)
   What would they fix first? The answer is specific and a little uncomfortable: your social media, your trainer, your spending. You hire them on the spot.
   <sub>energy -1; intelligence +1; leadership +1; charisma +1; mods inspired; flags good_agent</sub>

<details><summary>Before</summary>

> An agent with six clients asks for an hour. The pitch has no private jets and no promises, just a plan so plain it's almost funny.

1. **Sign with the plain plan**: You sign. The calls get answered, the deadlines get met, and nothing about it will ever make a highlight reel.
   <sub>energy +1; intelligence +2; mods focused; flags good_agent</sub>

2. **Stay with the big agency**: You stay with the big agency because the name opens doors. Some do. Some just have a receptionist behind them.
   <sub>fun +1; ambition +2; followers +1; mods confident</sub>

3. **Ask what they'd fix first**: You ask what they'd change about your career tomorrow. The answer is specific and a little uncomfortable, and you hire them on the spot.
   <sub>energy -1; intelligence +1; leadership +1; charisma +1; mods inspired; flags good_agent</sub>

</details>

## 25. PRO_057 The Honest Advisor
*money; premise 26 words*

> A financial advisor recommended by your long snapper walks you through a plan so boring it's almost funny: index funds, a budget, a rule about cars.

1. **Hire the boring advisor** (21 words)
   You hire the advisor and follow the rule about cars, mostly. Nothing exciting happens to your money, which is the point.
   <sub>fun -1; intelligence +2; leadership +1; mods focused; flags honest_advisor</sub>

2. **Ask for more upside** (25 words)
   More upside, you say. The advisor says no, explains why in plain words and doesn't budge. You hire them anyway, partly because they wouldn't budge.
   <sub>ambition +1; intelligence +1; mods focused; flags honest_advisor</sub>

3. **Pass for now** (21 words)
   You say you'll think about it and never call back. The money sits in a checking account doing nothing at all.
   <sub>energy +1; fun +1; mods rested</sub>

<details><summary>Before</summary>

> A financial advisor recommended by your long snapper walks you through a plan so boring it's almost funny: index funds, a budget, a rule about cars.

1. **Hire the boring advisor**: You hire the advisor and follow the rule about cars, mostly. Nothing exciting happens to your money, which is the point.
   <sub>fun -1; intelligence +2; leadership +1; mods focused; flags honest_advisor</sub>

2. **Ask for something with more upside**: You ask for something with more upside. The advisor says no, explains why, and you hire them anyway.
   <sub>ambition +1; intelligence +1; mods focused; flags honest_advisor</sub>

3. **Pass for now**: You say you'll think about it and never call back. The money sits in a checking account doing nothing at all.
   <sub>energy +1; fun +1; mods rested</sub>

</details>

## 26. PRO_058 The Advisor With the Yacht
*money; premise 27 words*

> A financial advisor who manages three of your teammates invites you onto his boat and talks about 'real returns', the kind 'the boring guys' can't get you.

1. **Hand over your money** (26 words)
   Papers get signed on the boat, between lunch and the sunset. The first statements look incredible, and he always answers when you call, even on weekends.
   <sub>fun +3; social +1; ambition +2; intelligence -2; mods confident; flags trusted_flashy_advisor</sub>

2. **Ask for audited statements** (22 words)
   Audited statements and one reference outside football, please. He laughs, changes the subject and refills your lemonade, and you never sign anything.
   <sub>social -1; intelligence +2; leadership +1; mods focused</sub>

3. **Enjoy the boat, sign nothing** (29 words)
   You enjoy the afternoon, eat his food and sign nothing. Your teammates call you paranoid on the drive home, and two of them sign with him the next week.
   <sub>fun +2; charisma +1; rel team -1; mods loose</sub>

4. **Send it to the people you trust** *(locked: having an agent or advisor you trust)* (25 words)
   You send his paperwork to the people who already handle your money. Their reply is one word: 'No.' Then a second message: 'Warn your teammates.'
   <sub>energy -1; intelligence +2; leadership +1; rel team +2; mods focused</sub>

<details><summary>Before</summary>

> A financial advisor who manages three of your teammates invites you onto his boat and talks about 'real returns', the kind 'the boring guys' can't get you.

1. **Hand over your money**: You sign the papers on the boat. The first statements look incredible, and he's always available when you call.
   <sub>fun +3; social +1; ambition +2; intelligence -2; mods confident; flags trusted_flashy_advisor</sub>

2. **Ask for audited statements**: You ask for audited statements and a reference outside football. He laughs and changes the subject, and you never sign.
   <sub>social -1; intelligence +2; leadership +1; mods focused</sub>

3. **Enjoy the boat, sign nothing**: You enjoy the afternoon, eat his food and sign nothing. Your teammates think you're paranoid.
   <sub>fun +2; charisma +1; rel team -1; mods loose</sub>

4. **Send it to the people you trust**: You send his paperwork to the people who already handle your money. Their reply is one word: 'No.' Then a second message: 'Warn your teammates.'
   <sub>energy -1; intelligence +2; leadership +1; rel team +2; mods focused</sub>

</details>

## 27. PRO_066 The Tax Letter, Pro
*money; premise 27 words*

> You owe taxes in every state where you played a road game, and your old accountant didn't file most of them. The letters have started to arrive.

1. **Hire a sports accountant** (22 words)
   You hire an accountant who does nothing but athletes. It takes a month of paperwork and a painful check, and it's done.
   <sub>energy -2; fun -1; intelligence +2; leadership +1; mods stressed</sub>

2. **Ignore the letters** (28 words)
   The letters go in a drawer. They come back with penalties, then with a lawyer's name on the envelope, and every one of them makes your stomach drop.
   <sub>energy +1; fun +1; intelligence -2; retention -1; mods distracted</sub>

3. **Ask the veterans at lunch** (29 words)
   Every veteran at the lunch table has a horror story and a phone number. You call the one who sounds least scary, and she fixes it in a month.
   <sub>energy -1; social +1; intelligence +1; mods focused</sub>

4. **Pay it from the account you never touch** *(locked: having handled money carefully since your first paycheck)* (25 words)
   You pay it from the account you've never touched since your first paycheck. It's a big number, and it doesn't keep you up at night.
   <sub>fun -1; intelligence +1; mods rested</sub>

<details><summary>Before</summary>

> You owe taxes in every state where you played a road game, and your old accountant didn't file most of them. The letters have started to arrive.

1. **Hire a sports accountant**: You hire an accountant who does nothing but athletes. It takes a month of paperwork and a painful check, and it's done.
   <sub>energy -2; fun -1; intelligence +2; leadership +1; mods stressed</sub>

2. **Ignore the letters**: You put the letters in a drawer. They come back with penalties, and then with a lawyer's name on them.
   <sub>energy +1; fun +1; intelligence -2; retention -1; mods distracted</sub>

3. **Ask the veterans what they did**: You ask the veterans at lunch. Every one of them has a horror story and a phone number. You call the one who sounds least scary.
   <sub>energy -1; social +1; intelligence +1; rel team +1; mods focused</sub>

4. **Pay it from the account you never touch**: You pay it from the account you've never touched since your first paycheck. It's a big number, and it doesn't keep you up at night.
   <sub>fun -1; intelligence +1; mods rested</sub>

</details>

## 28. PRO_068 The Cousin Nobody Remembers
*money; premise 34 words*

> Someone from your hometown with your last name, a folder of drawings and a business idea is waiting by your car after practice. He says you met at a wedding when you were nine.

1. **Hear the pitch, then check it** (24 words)
   You listen, take the paperwork and have your agent look at it. The idea is real; the numbers aren't. You say no with reasons.
   <sub>energy -1; intelligence +2; leadership +1; mods focused</sub>

2. **Buy him lunch, not the idea** (21 words)
   You buy him lunch and talk about family for an hour. You don't invest, and he leaves happier than he came.
   <sub>social +2; fun +1; charisma +1; rel parent +3; rel sibling +1; mods loose</sub>

3. **Say no before he finishes** (29 words)
   No, before he's finished his first sentence, and you get in your car. It's quick and a little cold, and {parent} hears about it from three relatives by Sunday.
   <sub>energy +2; ambition +1; rel parent -1; mods rested</sub>

<details><summary>Before</summary>

> Someone from your hometown with your last name and a business idea is waiting by your car after practice.

1. **Hear the pitch, then check it**: You listen, take the paperwork and have your agent look at it. The idea is real; the numbers aren't. You say no with reasons.
   <sub>energy -1; resilience +1; intelligence +2; mods focused</sub>

2. **Buy him lunch, not the idea**: You buy him lunch and talk about family for an hour. You don't invest, and he leaves happier than he came.
   <sub>social +2; charisma +1; rel parent +3; mods loose</sub>

3. **Say no on the spot**: You say no before he finishes and get in your car. It's quick, and a little cold.
   <sub>energy +2; fun +1; mods rested</sub>

</details>

## 29. PRO_071 The Watch, the Car, the Chain
*money; premise 25 words*

> The locker room has a dress code nobody wrote down: the watch, the car, the chain. It costs about what you made as a rookie.

1. **Keep up** (20 words)
   You buy the watch and the car. You look the part, and every month the statement looks a little worse.
   <sub>fun +3; social +2; intelligence -1; followers +2; mods spotlight</sub>

2. **Opt out with a joke** (30 words)
   The same old truck shows up every day, and you call it 'retro'. It becomes a running joke in the locker room, and nobody actually minds; one rookie copies you.
   <sub>social +1; charisma +1; intelligence +1; mods loose</sub>

3. **Ask a veteran who went broke** (30 words)
   The oldest player on the roster takes his watch off when you ask about it, sets it on the table and tells you what it cost him in the end.
   <sub>energy -1; intelligence +2; rel team +1; mods focused</sub>

<details><summary>Before</summary>

> The locker room has a dress code nobody wrote down: the watch, the car, the chain. It costs about what you made as a rookie.

1. **Keep up**: You buy the watch and the car. You look the part, and every month the statement looks a little worse.
   <sub>fun +3; social +2; intelligence -1; followers +2; mods spotlight</sub>

2. **Opt out with a joke**: You show up in the same old truck and call it 'retro'. It becomes a running joke, and nobody actually minds.
   <sub>social +1; charisma +1; intelligence +1; mods loose</sub>

3. **Ask a veteran who went broke**: You ask the oldest player on the roster about the watch. He takes his off and tells you what it cost him in the end.
   <sub>energy -1; intelligence +2; rel team +1; mods focused</sub>

</details>

## 30. PRO_085 {tyler} in the Same Division
*social; premise 27 words*

> {tyler} signs with a team in your division, and the sports channel has already made the graphic: the two of you, face to face, twice a year.

1. **Call {tyler} and laugh about it** (22 words)
   You call {tyler} and laugh about the graphic. You agree to give the reporters nothing, and you both mostly keep that promise.
   <sub>fun +2; social +1; charisma +1; rel rival +5; mods loose; flags tyler_division_rival</sub>

2. **Put the graphic on your locker** (27 words)
   The graphic goes on your locker. Every practice before those two games has a little more in it, and {tyler} hears about the locker from a reporter.
   <sub>energy -1; ambition +2; rel rival -2; skill_points +2; mods pumped_up; flags tyler_division_rival</sub>

3. **Plan a dinner after the first game** *(locked: having earned {tyler}'s respect before)* (31 words)
   You text {tyler} a restaurant name and a time: after the first game, win or lose. He sends back a thumbs-up and a picture of the two of you at sixteen.
   <sub>fun +3; social +1; energy -2; charisma +1; leadership +1; rel rival +8; mods inspired; flags tyler_division_rival</sub>

4. **Make peace first** *(locked: having trash-talked {tyler} in college)* (30 words)
   You remember what you said about {tyler} in college, and you call to say it was out of line. It's an awkward call, and the rivalry gets cleaner after it.
   <sub>energy -1; leadership +2; rel rival +6; mods drained; flags tyler_division_rival</sub>

<details><summary>Before</summary>

> {tyler} signs with a team in your division, and the sports channel has already made the graphic: the two of you, face to face, twice a year.

1. **Call {tyler} and laugh about it**: You call {tyler} and laugh about the graphic. You agree to give the reporters nothing, and you both mostly keep that promise.
   <sub>fun +2; social +1; charisma +1; rel rival +5; mods loose; flags tyler_division_rival</sub>

2. **Use it**: You put the graphic on your locker. Every practice before those two games has a little more in it.
   <sub>energy -1; ambition +2; rel rival -2; skill_points +2; mods pumped_up; flags tyler_division_rival</sub>

3. **Plan a dinner after the first game**: You text {tyler} a restaurant name and a time: after the first game, win or lose. He sends back a thumbs-up and a picture of the two of you at sixteen.
   <sub>fun +3; social +1; energy -2; charisma +1; leadership +1; rel rival +8; mods inspired; flags tyler_division_rival</sub>

4. **Make peace first**: You remember what you said about {tyler} in college, and you call to say it was out of line. It's an awkward call, and the rivalry gets cleaner after it.
   <sub>energy -1; leadership +2; rel rival +6; mods drained; flags tyler_division_rival</sub>

</details>

## 31. PRO_100 The Quarterback's Ego
*team; premise 30 words*

> The franchise quarterback blames the special teams in a press conference, by name, on camera. Twenty minutes later the reporters are standing at your locker with their phones already recording.

1. **Talk only about your job** (28 words)
   Your job is the only thing you'll talk about, and you say it calmly three times. The quarterback notices, and so does the locker room, in different ways.
   <sub>intelligence +1; leadership +1; rel team +2; mods focused</sub>

2. **Fire back** (27 words)
   Special teams aren't the problem, you say, looking straight into the camera. It's the clip of the week, and the quarterback stops talking to you until December.
   <sub>fun +2; ambition +2; rel team -3; rel coach -2; followers +3; mods pumped_up</sub>

3. **Talk to him privately** (30 words)
   You find him at his locker after practice and ask what he actually meant. It turns out he was angry at himself. He says so at the next press conference.
   <sub>energy -1; social +1; charisma +1; leadership +1; rel team +3; mods confident</sub>

<details><summary>Before</summary>

> The franchise quarterback blames the special teams in a press conference, and the reporters come to your locker next.

1. **Say nothing**: You say you're focused on your job and leave it there. The quarterback notices, and so does the locker room.
   <sub>intelligence +1; leadership +1; rel team +2; mods focused</sub>

2. **Fire back**: You say the special teams aren't the problem. It's the clip of the week, and the quarterback stops talking to you.
   <sub>fun +2; ambition +2; rel team -3; rel coach -2; followers +3; mods pumped_up</sub>

3. **Talk to him privately**: You find him at his locker after practice and ask what he actually meant. It turns out he was angry at himself. He says so at the next press conference.
   <sub>energy -1; social +1; charisma +1; leadership +1; rel team +3; mods confident</sub>

</details>

## 32. PRO_106 The Owner's Gala
*social; premise 25 words*

> Black tie, the owner's charity gala, and a donor who wants a photo and then a favor: a visit to his company's party next week.

1. **Take the photo, skip the favor** (27 words)
   The photo is easy; the favor isn't. You smile, say your schedule is full, and he's disappointed for about a minute and forgets about it by dessert.
   <sub>social +1; intelligence +1; mods focused</sub>

2. **Do the favor** (26 words)
   His company party is two hours of handshakes and lukewarm food, and at the end a check for the gala's charity with your name on it.
   <sub>energy -2; social +2; charisma +2; followers +2; mods tired</sub>

3. **Slip out before the auction** (26 words)
   An hour in, you slip out before the auction starts. Nobody asks you for anything, you're asleep by ten, and practice the next morning feels easy.
   <sub>energy +2; skill_points +1; mods rested</sub>

<details><summary>Before</summary>

> Black tie, the owner's charity gala, and a donor who wants a photo and then a favor: a visit to his company's party next week.

1. **Take the photo, skip the favor**: You smile for the photo and say your schedule is full. He's disappointed and forgets about it by dessert.
   <sub>social +1; intelligence +1; mods focused</sub>

2. **Do the favor**: You show up at his company party. It's two hours of handshakes and a check for the gala's charity with your name on it.
   <sub>energy -2; social +2; charisma +2; followers +2; mods tired</sub>

3. **Leave early**: You stay an hour and slip out before the auction. Nobody asks for anything, and you're asleep by ten.
   <sub>energy +2; skill_points +1; mods rested</sub>

</details>

## 33. PRO_112 The Specialists' Dinner
*team; premise 32 words*

> The kicker, the punter and the snapper have had a dinner every Thursday since camp. A new punter wants in, he's nervous about asking, and the other two are looking at you.

1. **Invite the new punter** (30 words)
   The new punter gets the invitation from you, and four turns out to be louder than three. The dinner gets better, and he stops eating lunch alone in his car.
   <sub>social +2; fun +1; leadership +1; rel team +1; rel holder +2; mods loose</sub>

2. **Keep it to three** (26 words)
   Three is the number, you decide. It stays easy and familiar, and the new punter eats alone on Thursdays for a month. You notice every time.
   <sub>fun +1; energy +1; ambition +1; rel team -1; mods rested</sub>

3. **Make it a unit dinner** (26 words)
   The whole special teams unit comes. It's chaos, two tables pushed together and a waiter who quits halfway, and it's the best night of the season.
   <sub>social +3; fun +2; energy -2; charisma +1; rel team +2; rel holder +1; mods loose</sub>

<details><summary>Before</summary>

> The kicker, the punter and the snapper have a weekly dinner. A new punter wants in, and the other two are looking at you.

1. **Invite the new punter**: You invite the new punter. Four is louder than three, and the dinner gets better.
   <sub>social +2; fun +1; leadership +1; rel team +2; mods loose</sub>

2. **Keep it to three**: You say the dinner is for three and leave it there. It stays easy, and the new punter eats alone that month.
   <sub>fun +1; energy +1; ambition +1; rel team -1; mods rested</sub>

3. **Make it a unit dinner**: You invite the whole special teams unit. It's chaos, and it's the best night of the season.
   <sub>social +3; fun +2; energy -2; charisma +1; rel team +3; rel coach +1; mods loose</sub>

</details>

## 34. PRO_115 The Trick Play
*team; premise 31 words*

> The new coordinator wants a fake field goal with you throwing the pass. You haven't thrown a football in a game since high school, and the backup quarterback is already laughing.

1. **Practice the throw** (21 words)
   You throw fifty passes a day for a week until the ball stops wobbling. The coordinator puts it in the playbook.
   <sub>energy -2; ambition +1; rel coach +2; skill_points +1; mods focused</sub>

2. **Pitch a different fake** (26 words)
   A fake where the holder runs and you just block, you suggest. The coordinator likes it better, and {holder} is thrilled to finally get a carry.
   <sub>intelligence +2; rel coach +1; rel holder +2; mods focused</sub>

3. **Say you're just a kicker** (28 words)
   Kickers kick, you say with a grin. The coordinator doesn't grin back, the fake goes to the punter, and you spend the season watching him get the credit.
   <sub>fun +1; energy +1; rel coach -2; mods loose</sub>

<details><summary>Before</summary>

> The new coordinator wants a fake field goal with you throwing the pass, and you haven't thrown a ball since high school.

1. **Practice the throw**: You throw fifty passes a day for a week until the ball stops wobbling. The coordinator puts it in the playbook.
   <sub>energy -2; ambition +1; rel coach +2; skill_points +1; mods focused</sub>

2. **Ask for a different fake**: You suggest a fake where the holder runs and you just block. The coordinator likes it better.
   <sub>intelligence +2; rel coach +1; mods focused</sub>

3. **Laugh it off**: You laugh and say you're a kicker. The coordinator doesn't laugh, and the fake goes to the punter.
   <sub>fun +1; energy +1; rel coach -2; mods loose</sub>

</details>

## 35. PRO_178 The Rookie Slump
*training; premise 33 words*

> Your first real slump. The misses come in practice, then in your sleep, and every veteran in the room has a theory about your plant foot that he wants to share at lunch.

1. **Listen to one person** (20 words)
   You pick the one voice you trust, {coach}, and tune out the rest. The fix is small and it takes.
   <sub>energy -1; intelligence +1; rel coach +3; skill_points +1; mods focused</sub>

2. **Try every theory** (27 words)
   Every veteran's advice gets tried in one week. Your form is a mess by Friday, your confidence is worse, and at least they all feel listened to.
   <sub>energy -2; social +1; rel team +2; mods stressed</sub>

3. **Kick until it comes back** (28 words)
   Two hundred balls a day, until something clicks. Your leg is sore and heavy, the snapper starts bringing you ice, and on the ninth day the slump breaks.
   <sub>energy -4; ambition +2; skill_points +2; mods heavy_legs</sub>

4. **Call someone who helped before** *(locked: having gotten help before)* (26 words)
   The people who helped the last time you struggled pick up on the first ring, and the plan you made with them then still works now.
   <sub>energy -1; fun +1; intelligence +1; skill_points +1; mods rested</sub>

<details><summary>Before</summary>

> Your first real slump, and every veteran in the room has a theory about your plant foot.

1. **Listen to one person**: You pick the one voice you trust, {coach}, and tune out the rest. The fix is small and it takes.
   <sub>energy -1; intelligence +1; rel coach +3; skill_points +1; mods focused</sub>

2. **Try every theory**: You try every veteran's advice in one week. Your form is a mess, and your confidence is worse.
   <sub>energy -2; social +1; rel team +2; mods stressed</sub>

3. **Kick until it comes back**: You kick two hundred balls a day until something clicks. Your leg is sore, and the slump breaks.
   <sub>energy -4; ambition +2; skill_points +2; mods heavy_legs</sub>

4. **Call someone who helped before**: You call the people who helped the last time you struggled, and the plan you made then still works.
   <sub>energy -1; fun +1; intelligence +1; skill_points +1; mods rested</sub>

</details>

## 36. PRO_183 The Rookie on a Run
*media; premise 30 words*

> The streak is a month old. Rookie card companies are calling your agent, a talk show wants you, and the specialists have stopped saying the word 'streak' anywhere near you.

1. **Never say the word** (25 words)
   Not one word about the streak, from you or anyone in the specialists' room. The snapper even unplugs the television when the highlights come on.
   <sub>intelligence +1; rel holder +1; skill_points +1; mods focused</sub>

2. **Enjoy the attention** (29 words)
   Interviews, a card shoot and a podcast, all in one week. It's fun and a little dizzying, and by Friday practice you're more tired than you've been all year.
   <sub>fun +3; energy -2; charisma +2; followers +4; mods spotlight</sub>

3. **Credit {holder} and the snapper** (26 words)
   Every interview turns into a speech about the snapper and {holder}. The specialists' group chat is very happy, and {holder} prints one quote and frames it.
   <sub>social +2; leadership +2; rel holder +3; followers +1; mods inspired</sub>

<details><summary>Before</summary>

> The streak is a month old, and the rookie card companies are calling your agent.

1. **Don't talk about it**: You don't say a word about the streak, and neither does anyone in the specialists' room.
   <sub>intelligence +1; skill_points +1; mods focused</sub>

2. **Enjoy the attention**: You do the interviews, the card shoot and a podcast. It's fun, and you're tired by Friday.
   <sub>fun +3; energy -2; charisma +2; followers +4; mods spotlight</sub>

3. **Credit the unit**: Every interview is about the snapper and {holder}. The specialists' group chat is very happy.
   <sub>social +2; leadership +2; rel holder +3; followers +1; mods inspired</sub>

</details>

## 37. PRO_191 The Rookie Injury
*health; premise 31 words*

> Your first pro injury, a strained hip flexor, and the trainers are talking about you like a part that might not fit back in. You can hear them through the curtain.

1. **Do the rehab exactly** (28 words)
   Every exercise the trainers give you gets done on time, and nothing extra. You're back a week early, and the head trainer starts using you as an example.
   <sub>health +5; fun -1; intelligence +1; rel coach +2; mods rested</sub>

2. **Push to come back early** (27 words)
   Kicking before the trainers clear you gets you back on time, and sore for a month. You never quite trust your hip on cold mornings after that.
   <sub>health -2; ambition +2; skill_points +2; mods sore</sub>

3. **Ask how the veterans came back** (29 words)
   Each veteran has a comeback story, and one has a stretch that works. By the end of the week you're doing it in the hallway with three of them.
   <sub>health +3; social +1; charisma +1; rel team +2; mods focused</sub>

4. **Use what you learned before** *(locked: having been through a hard recovery before)* (25 words)
   You've done a long rehab before, so you build the plan with the trainers instead of waiting for one. They're impressed, and you're back early.
   <sub>health +5; energy -1; intelligence +1; leadership +1; rel coach +3; mods rested</sub>

<details><summary>Before</summary>

> Your first pro injury, a strained hip flexor, and the trainers are talking about you like a part that might not fit back in.

1. **Do the rehab exactly**: You do every exercise the trainers give you, on time, and nothing extra. You're back a week early.
   <sub>health +5; fun -1; intelligence +1; rel coach +2; mods rested</sub>

2. **Push to come back early**: You push to kick before the trainers clear you. You're back on time, and sore for a month.
   <sub>health -2; ambition +2; skill_points +2; mods sore</sub>

3. **Ask the veterans**: You ask the veterans how they came back from their first injury. Each has a story, and one has a stretch that works.
   <sub>health +3; social +1; charisma +1; rel team +2; mods focused</sub>

4. **Use what you learned before**: You've done a long rehab before, so you build the plan with the trainers instead of waiting for one. They're impressed, and you're back early.
   <sub>health +5; energy -1; intelligence +1; leadership +1; rel coach +3; mods rested</sub>

</details>

## 38. PRO_321 The Veteran's Advice
*team; premise 34 words*

> An eleven-year veteran pulls you aside after practice, sits you on a bench by the field and says he has a few rules for surviving the league, if you're smart enough to want them.

1. **Write them down tonight** (27 words)
   Every rule goes in a notebook that night. Some are about kicking; most are about money, agents and who to trust. You reread them every season after.
   <sub>resilience +1; intelligence +2; mods focused</sub>

2. **Ask about his worst season** (27 words)
   His worst season comes out over an hour on that bench: the cut, the divorce, the comeback. You learn more from the story than from any rule.
   <sub>energy -1; social +1; charisma +1; intelligence +1; rel team +3; mods inspired</sub>

3. **Nod and forget them** (26 words)
   Nodding politely gets you to dinner on time, and you forget the rules by dessert. Three of them come back to you later, the hard way.
   <sub>energy +1; fun +1; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> An eleven-year veteran pulls you aside after practice with a few rules for surviving the league.

1. **Write them down**: You write every rule down that night. Some are about kicking. Most are about money and people.
   <sub>intelligence +2; rel team +2; mods focused</sub>

2. **Ask about the hard years**: You ask about his worst season. He talks for an hour, and you learn more than the rules.
   <sub>energy -1; social +1; charisma +1; intelligence +1; rel team +3; mods inspired</sub>

3. **Nod and forget them**: You nod politely and forget them by dinner. Three of them come back to you later, the hard way.
   <sub>energy +1; fun +1; ambition +1; mods rested</sub>

</details>

## 39. PRO_322 The First Media Interview
*media; premise 34 words*

> Local reporters catch you at your locker on your second day, before anyone has taught you what not to say. There are four microphones, and one of them is very close to your face.

1. **Keep it boring** (25 words)
   Short, polite answers and nothing quotable. The story that runs is boring, which {coach} likes, and your agent sends you a thumbs-up you didn't expect.
   <sub>energy +1; intelligence +1; rel coach +1; followers +1; mods focused</sub>

2. **Be yourself** (22 words)
   You joke, tell a story about your college holder and admit you're nervous. The reporters like you, and so do the fans.
   <sub>fun +2; social +1; charisma +2; followers +3; mods spotlight</sub>

3. **Say something bold** (24 words)
   You say you'll be the best kicker in the league in three years. It's the headline, and the veterans tape it to your locker.
   <sub>fun +1; ambition +2; rel team -2; followers +4; skill_points +1; mods pumped_up</sub>

<details><summary>Before</summary>

> Local reporters catch you at your locker before you've learned what not to say.

1. **Keep it simple**: You give short, polite answers and nothing quotable. The story is boring, which {coach} likes.
   <sub>energy +1; intelligence +1; rel coach +1; followers +1; mods focused</sub>

2. **Be yourself**: You joke, tell a story about your college holder and admit you're nervous. The reporters like you, and so do the fans.
   <sub>fun +2; social +1; charisma +2; followers +3; mods spotlight</sub>

3. **Say something bold**: You say you'll be the best kicker in the league in three years. It's the headline, and the veterans tape it to your locker.
   <sub>fun +1; ambition +2; rel team -2; followers +4; skill_points +1; mods pumped_up</sub>

</details>


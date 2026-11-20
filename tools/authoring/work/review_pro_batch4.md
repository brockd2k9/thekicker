# PRO batch 4: era 1, Rookie (written, not imported)

Dry run against a temporary copy of the game data with the PRO drafts generated: 13 written, 0 errors, 0 warnings, 0 lint notes. Money scenes use flags and stress costs; money values come with the savings stat.


## PRO batch 4: era 1, Rookie

### PRO_007 Where You Live
- **Category:** money  
- **Window:** age 21-25, club season 1, once  
- **Cast:** (no cast)  
- **Premise:** Half the roster lives in the same glass tower downtown. The rent is a quarter of your salary.

Half the roster lives in the same glass tower downtown, with a rooftop pool and a doorman who knows everyone's name. The rent is a quarter of your salary.

1. **Rent something modest**: You rent a two-bedroom twenty minutes from the facility, above a bakery. The teammates call it 'the bakery'. You save more in a month than some of them save in a year, and the commute is short.  
   *(fun -1; social -1; energy +2; intelligence +2; modifier rested; sets `lived_modestly`)*
2. **Move into the tower**: You sign the lease in the tower. The pool parties are legendary, the elevator rides are full of teammates, and the rent comes out of every check like a tax.  
   *(fun +3; social +3; intelligence -1; Team +2; modifier loose; sets `lived_large`)*
3. **Room with a teammate**: You split a place with another rookie. It's cheaper, louder, and you never eat dinner alone.  
   *(social +2; energy -1; charisma +1; Team +1; modifier loose)*

### PRO_008 Homesick in {town}
- **Category:** family  
- **Window:** age 21-25, club season 1, once  
- **Cast:** {parent}, {best_friend}  
- **Premise:** Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.

Nobody in {town} knows your name yet, and the apartment is very quiet on Tuesday nights.

1. **Call home every night**: You call home every night for a week. {parent} starts saving up stories for you, like he used to before school.  
   *(social +1; fun +1; {parent} +4; modifier rested)*
2. **Make the city yours**: You pick one new neighborhood every Tuesday and walk it until dinner. By October, {town} has a coffee shop that knows your order.  
   *(energy -1; fun +2; intelligence +1; modifier inspired)*
3. **Bury it in work**: You spend every quiet night in the film room. You're the best-prepared rookie on the roster and the loneliest.  
   *(social -2; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `promised_to_call_home`, shown as "having promised to call home every week"*  
   **Keep the Sunday call**: You kept the Sunday call through four years of college, and you keep it now. The first Sunday in {town}, {sibling} answers and talks for an hour.  
   *(social +1; fun +2; {parent} +3; {sibling} +3; modifier rested)*

### PRO_029 The Backup Wants Your Job
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** {backup}, {coach}  
- **Premise:** {backup} is on the practice squad and has been kicking very well where the coaches can see.

{backup} is on the practice squad and has been kicking very well where the coaches can see.

1. **Kick with {backup}**: You ask {backup} to share your warmups. It makes you both better, and it makes the coaches' decision harder, which is fine.  
   *(energy -1; social +1; leadership +1; 1 SP; {backup} +5; modifier focused)*
2. **Out-work {backup}**: You stay later than {backup} every day for a month. The coaches notice the hours more than the kicks.  
   *(energy -3; ambition +2; 2 SP; {coach} +2; modifier dialed_in)*
3. **Ignore it**: You decide the practice squad isn't your problem. Your kicking stays the same, and so does the whispering.  
   *(energy +1; fun +1; {backup} -2; modifier rested)*

### PRO_030 The New Holder Midseason
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** {holder}, Team  
- **Premise:** {holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick.

{holder} is hurt, and the replacement holder is a backup quarterback who has never held for a kick.

1. **Teach the new holder**: You stay after practice every day with the backup quarterback until the laces spin right. By Friday the holds are clean.  
   *(energy -3; social +1; leadership +2; Team +2; modifier focused)*
2. **Ask for a different holder**: You ask {coach} for the punter instead. The coach agrees, and the quarterback looks relieved.  
   *(intelligence +1; ambition +1; {coach} +1; modifier confident)*
3. **Visit {holder}**: You visit {holder} in the training room and bring the new holder along for a lesson. Two holders and a kicker in one cramped room, laughing.  
   *(social +2; fun +1; charisma +1; {holder} +4; modifier loose)*

### PRO_034 The Kick Everyone Saw
- **Category:** media  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A clip of you in a practice-field trick shot goes around the league.  
- **Note:** Practice clip only; no game result.

A clip of you in a practice-field trick shot, the ball off the crossbar and into a trash can, goes around the league.

1. **Make a few more**: You film a series with the specialists. It's fun, the club's social media team loves it, and the coaches don't.  
   *(fun +3; charisma +2; followers +5; {coach} -1; modifier spotlight)*
2. **Let it be one clip**: You thank people and leave it there. It fades in a week.  
   *(energy +1; intelligence +1; followers +1; modifier focused)*
3. **Use it for charity**: You turn the clip into a charity challenge: a donation for every kid who sends in their own trick shot.  
   *(energy -2; social +2; leadership +1; charisma +1; followers +3; modifier inspired)*

### PRO_036 Contract Year: Prove It
- **Category:** career  
- **Window:** age 21-25, age-banded variant, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** It's the last year of your rookie deal, and the front office wants to see one more season before they talk.

It's the last year of your rookie deal, and the front office wants to see one more season before it talks.

1. **Put your head down**: You stop reading anything about contracts and kick. Your agent handles the rest, and the season feels lighter for it.  
   *(energy +1; ambition +1; 1 SP; modifier focused)*
2. **Ask {coach} what they want**: You ask {coach} exactly what the club needs from you this year. The answer is two things, and both are fixable.  
   *(energy -1; intelligence +2; {coach} +3; modifier focused)*
3. **Push for a deal now**: You have your agent push for an extension before the season. The club says no, politely, and remembers that you asked.  
   *(fun +1; ambition +2; **retention -1**; modifier stressed)*

### PRO_100 The Quarterback's Ego
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** Team, {coach}  
- **Premise:** The franchise quarterback blames the special teams in a press conference.

The franchise quarterback blames the special teams in a press conference, and the reporters come to your locker next.

1. **Say nothing**: You say you're focused on your job and leave it there. The quarterback notices, and so does the locker room.  
   *(intelligence +1; leadership +1; Team +2; modifier focused)*
2. **Fire back**: You say the special teams aren't the problem. It's the clip of the week, and the quarterback stops talking to you.  
   *(fun +2; ambition +2; followers +3; Team -3; {coach} -2; modifier pumped_up)*
3. **Talk to him privately**: You find him at his locker after practice and ask what he actually meant. It turns out he was angry at himself. He says so at the next press conference.  
   *(energy -1; social +1; charisma +1; leadership +1; Team +3; modifier confident)*

### PRO_106 The Owner's Gala
- **Category:** social  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Black tie, the owner's charity, and a donor who wants a photo and a favor.

Black tie, the owner's charity gala, and a donor who wants a photo and then a favor: a visit to his company's party next week.

1. **Take the photo, skip the favor**: You smile for the photo and say your schedule is full. He's disappointed and forgets about it by dessert.  
   *(social +1; intelligence +1; modifier focused)*
2. **Do the favor**: You show up at his company party. It's two hours of handshakes and a check for the gala's charity with your name on it.  
   *(energy -2; social +2; charisma +2; followers +2; modifier tired)*
3. **Leave early**: You stay an hour and slip out before the auction. Nobody asks for anything, and you're asleep by ten.  
   *(energy +2; 1 SP; modifier rested)*

### PRO_112 The Specialists' Dinner
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** Team, {holder}  
- **Premise:** The kicker, the punter and the snapper have a weekly dinner, and a new punter wants in.

The kicker, the punter and the snapper have a weekly dinner. A new punter wants in, and the other two are looking at you.

1. **Invite the new punter**: You invite the new punter. Four is louder than three, and the dinner gets better.  
   *(social +2; fun +1; leadership +1; Team +2; modifier loose)*
2. **Keep it to three**: You say the dinner is for three and leave it there. It stays easy, and the new punter eats alone that month.  
   *(fun +1; energy +1; ambition +1; Team -1; modifier rested)*
3. **Make it a unit dinner**: You invite the whole special teams unit. It's chaos, and it's the best night of the season.  
   *(social +3; fun +2; energy -2; charisma +1; Team +3; {coach} +1; modifier loose)*

### PRO_115 The Trick Play
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** {coach}  
- **Premise:** The new coordinator wants a fake field goal with you throwing the pass, and you haven't thrown a ball since high school.

The new coordinator wants a fake field goal with you throwing the pass, and you haven't thrown a ball since high school.

1. **Practice the throw**: You throw fifty passes a day for a week until the ball stops wobbling. The coordinator puts it in the playbook.  
   *(energy -2; ambition +1; 1 SP; {coach} +2; modifier focused)*
2. **Ask for a different fake**: You suggest a fake where the holder runs and you just block. The coordinator likes it better.  
   *(intelligence +2; {coach} +1; modifier focused)*
3. **Laugh it off**: You laugh and say you're a kicker. The coordinator doesn't laugh, and the fake goes to the punter.  
   *(fun +1; energy +1; {coach} -2; modifier loose)*

### PRO_178 The Rookie Slump
- **Category:** training  
- **Window:** age 21-25, age-banded variant, slump_now 1+  
- **Cast:** {coach}, {holder}  
- **Premise:** Your first real slump, and every veteran in the room has a theory about your plant foot.

Your first real slump, and every veteran in the room has a theory about your plant foot.

1. **Listen to one person**: You pick the one voice you trust, {coach}, and tune out the rest. The fix is small and it takes.  
   *(energy -1; intelligence +1; 1 SP; {coach} +3; modifier focused)*
2. **Try every theory**: You try every veteran's advice in one week. Your form is a mess, and your confidence is worse.  
   *(energy -2; social +1; Team +2; modifier stressed)*
3. **Kick until it comes back**: You kick two hundred balls a day until something clicks. Your leg is sore, and the slump breaks.  
   *(energy -4; ambition +2; 2 SP; modifier heavy_legs)*
4. 🔒 *locked: needs `saw_sports_psych` or `leaned_on_support`, shown as "having gotten help before"*  
   **Call someone who helped before**: You call the people who helped the last time you struggled, and the plan you made then still works.  
   *(energy -1; fun +1; intelligence +1; 1 SP; modifier rested)*

### PRO_183 The Rookie on a Run
- **Category:** media  
- **Window:** age 21-25, age-banded variant, fg_streak 8+  
- **Cast:** Team  
- **Premise:** A month without a miss, and the rookie card companies are calling your agent.

The streak is a month old, and the rookie card companies are calling your agent.

1. **Don't talk about it**: You don't say a word about the streak, and neither does anyone in the specialists' room.  
   *(intelligence +1; 1 SP; modifier focused)*
2. **Enjoy the attention**: You do the interviews, the card shoot and a podcast. It's fun, and you're tired by Friday.  
   *(fun +3; energy -2; charisma +2; followers +4; modifier spotlight)*
3. **Credit the unit**: Every interview is about the snapper and {holder}. The specialists' group chat is very happy.  
   *(social +2; leadership +2; followers +1; {holder} +3; modifier inspired)*

### PRO_188 The Veteran They Signed to Push You
- **Category:** team  
- **Window:** age 21-25, weeks 1-3, age-banded variant  
- **Cast:** {coach}, {backup}  
- **Premise:** The club signs a thirty-four-year-old kicker 'for depth'. Everybody knows what that means for a rookie.

The club signs a thirty-four-year-old kicker 'for depth'. Everybody knows what that means for a rookie.

1. **Learn from the veteran**: You ask the veteran to watch your warmup. He does, and fixes something in five minutes.  
   *(social +1; intelligence +2; 1 SP; modifier focused)*
2. **Compete every day**: You turn every practice into a contest. The veteran is tired by October, and you aren't.  
   *(energy -3; ambition +2; 2 SP; {coach} +1; modifier dialed_in)*
3. **Go out and forget about it**: You go out with the other rookies every night that week to stop thinking about the veteran. It works until Monday, when {coach} notices you look tired.  
   *(fun +2; social +1; energy -1; charisma +1; {coach} -1; modifier late_night)*

#### Flags this batch sets, and what they open

- `lived_large` (from PRO_007) → PRO_072 Broke at Thirty-Three
- `lived_modestly` (from PRO_007) → nothing reads it yet

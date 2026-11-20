# PRO batches 1-3 (written, not imported)

Dry run (against a temporary copy of the game data with the PRO drafts generated): batch 1, 2 and 3 each 13 written, 0 errors, 0 warnings, 0 lint notes; together with the two approved tone-check files, 47 written, 0 / 0 / 0. Money scenes use flags and stress costs; `money` values are added when the savings stat lands.


## PRO batch 1: arrival and rookie years

### PRO_001 Rookie Camp
- **Category:** team  
- **Window:** age 21-25, club season 1, weeks 1-2, story event, once  
- **Cast:** {coach}, Team  
- **Premise:** Camp opens with four kickers on the roster and one job. The veteran special teams coordinator calls you by the wrong name twice.

Camp opens with four kickers on the roster and one job. The special teams coordinator has called you by the wrong name twice, and {coach} hasn't called you anything at all.

1. **Be the first one on the field**: You're stretching on the field at six every morning before the trainers unlock the door. By the second week, {coach} knows your name and uses it.  
   *(energy -3; ambition +2; 2 SP; {coach} +3; modifier dialed_in)*
2. **Learn the room before the field**: You spend the first week listening: who the veterans trust, which snapper the coaches like, where the rookies sit at lunch. It's slow, and nothing in that locker room surprises you after it.  
   *(social +2; intelligence +1; charisma +1; Team +3; modifier focused)*
3. **Kick like it's already yours**: You walk in like the job is yours and kick like it too. Two veterans love it. One of the other kickers stops talking to you entirely.  
   *(fun +2; ambition +2; charisma +1; 1 SP; Team -2; modifier confident)*
4. 🔒 *locked: needs `rebuilt_reputation` or `trained_with_alum`, shown as "having trained with a pro or rebuilt a reputation before"*  
   **Do what got you here**: You've been in rooms where nobody expected anything from you. You kick, you say little, and you keep a notebook of every correction. {coach} borrows the notebook in week two.  
   *(energy -2; intelligence +1; leadership +1; 1 SP; {coach} +4; modifier focused)*

### PRO_002 The Veteran Kicker
- **Category:** team  
- **Window:** age 21-26, club season 1, weeks 1-4, once  
- **Cast:** Team  
- **Premise:** The kicker whose job you're taking has been here eleven years. He can make your first month easy or impossible.

The kicker whose job you're taking has been here eleven years. His locker is next to yours, and he can make your first month easy or impossible.

1. **Ask him to teach you**: You ask him straight out how he lasted eleven years. He stares at you for a while, then starts talking and doesn't stop for an hour.  
   *(energy -1; social +1; intelligence +1; 1 SP; Team +2; modifier inspired; sets `learned_from_veteran`)*
2. **Compete and keep your distance**: You stay polite and give him nothing. Every kick in camp becomes a quiet contest, and both of you get better.  
   *(social -1; ambition +2; 2 SP; modifier dialed_in)*
3. **Freeze him out**: You sit with the younger players, laugh at the right jokes about his age and let the room decide who's in charge. You win the room. You also notice who stopped laughing.  
   *(fun +1; social +1; ambition +1; leadership -2; Team -3; modifier confident; sets `froze_out_veteran`)*

### PRO_003 The First Check
- **Category:** money  
- **Window:** age 21-26, club season 1, once  
- **Cast:** {parent}  
- **Premise:** Your first real paycheck lands, and it has more zeros than {parent} made in a year.

Your first real paycheck lands, and it has more zeros than {parent} made in a year. Your phone starts buzzing before you've finished reading the number.

1. **Save most of it**: You put most of it into an account you promise not to touch and buy one thing: a mattress that isn't from a dorm. It's dull, and you sleep very well.  
   *(energy +2; fun -1; intelligence +2; modifier rested; sets `saved_rookie_check`)*
2. **Spend it like you earned it**: You buy the car, the watch and dinner for the whole rookie class. It feels incredible for about a month.  
   *(fun +4; social +2; intelligence -1; charisma +1; followers +2; modifier loose; sets `spent_rookie_check`)*
3. **Pay off {parent}'s debts**: You call {parent} and ask for the number on every bill. He refuses twice and gives in the third time. The calls home sound different after that.  
   *(fun -1; leadership +1; {parent} +7; modifier inspired; sets `paid_family_debt`)*
4. 🔒 *locked: needs `saved_first_paycheck` or `helped_family_financially`, shown as "having handled your first paychecks wisely"*  
   **Split it the way you always have**: You do what you did with your first paycheck at sixteen, just with more zeros: a third saved, a third home, a third yours. It's an old habit, and it holds.  
   *(fun +1; intelligence +1; {parent} +3; modifier focused; sets `saved_rookie_check`)*

### PRO_004 Rookie Duties
- **Category:** team  
- **Window:** age 21-25, club season 1, once  
- **Cast:** Team  
- **Premise:** The veterans hand the rookies a list: breakfast for the unit every Friday, the luggage, the karaoke on the team plane. Some of it is fun. One item isn't.

The veterans hand the rookies a list: breakfast for the unit every Friday, carrying the pads, a song on the team plane. Most of it is fun. One item, a stunt in a hotel hallway, isn't.

1. **Do the list, skip the stunt**: You do every chore with a grin and tell the captain, privately, you're not doing the hallway stunt. He shrugs and crosses it off.  
   *(social +1; leadership +1; Team +2; modifier loose)*
2. **Do all of it**: You do everything on the list, the stunt included. The veterans cheer, a rookie gets hurt doing the same one, and the coaches hold a meeting about it.  
   *(fun +4; social +2; energy -2; leadership -1; Team +1; {coach} -2; modifier late_night)*
3. **Turn the song into a show**: You go all in on the plane song, with costumes. It's the best one in years, and the veterans stop giving you the worst chores.  
   *(fun +3; energy -1; charisma +2; followers +1; Team +3; modifier loose)*
4. 🔒 *locked: needs `ended_tradition` or `kept_tradition_alive`, shown as "having run freshman traditions in college"*  
   **Fix the list with the captain**: You ran this kind of tradition in college, so you sit down with the captain and rewrite the stunt into something nobody gets hurt doing. It's a quiet win.  
   *(energy -1; leadership +2; intelligence +1; Team +3; {coach} +1; modifier confident)*

### PRO_005 The Long Snapper
- **Category:** team  
- **Window:** age 21-27, club seasons 1-2, once  
- **Cast:** Team  
- **Premise:** The long snapper has been in the league fourteen years and has opinions about everything, including your warmup.

The long snapper has been in the league fourteen years and has opinions about everything, including your warmup, your shoes and the way you say 'hold'.

1. **Listen to every opinion**: You let him talk. Half of it is nonsense. The other half fixes a timing problem you didn't know you had.  
   *(energy -1; social +1; intelligence +1; 1 SP; modifier focused; sets `trusted_snapper`)*
2. **Push back on the warmup**: You tell him your warmup isn't changing. He respects it more than you expected and starts timing his snaps to it.  
   *(ambition +1; charisma +1; leadership +1; modifier confident; sets `trusted_snapper`)*
3. **Keep it professional**: You say thanks, keep it short and do your own thing. The snaps are fine. The friendship never quite starts.  
   *(energy +1; ambition +1; 1 SP; modifier rested)*

### PRO_006 The First Road Trip
- **Category:** social  
- **Window:** age 21-25, club season 1, once  
- **Cast:** Team, {coach}  
- **Premise:** First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies.  
- **Note:** Pressure scene: clean no. The wrong choice sets pro strike stayed_out_pro.

First road trip. Curfew is eleven, and the veterans say curfew is for rookies who want to stay rookies. Three of them are already in the lobby.

1. **Stay in**: You order room service, watch film and are asleep by ten-thirty. At breakfast you're the only rookie who isn't wearing sunglasses.  
   *(energy +3; social -1; ambition +1; {coach} +1; modifier rested)*
2. **Go to dinner, back by eleven**: You go to dinner with the veterans, laugh at their stories and leave before dessert. A couple of them call you a rookie. A couple of them nod.  
   *(fun +2; social +2; intelligence +1; Team +1; modifier loose)*
3. **Go out with them**: You go out and come back at three. Bed check was at eleven, and your name is on the list {coach} reads out at breakfast.  
   *(fun +4; social +3; energy -5; leadership -2; **retention -2**; {coach} -5; modifier late_night; **conduct bad**; sets **strike** `stayed_out_pro`)*

### PRO_009 The Practice Squad Friend
- **Category:** team  
- **Window:** age 21-27, club seasons 1-2, once  
- **Cast:** Team  
- **Premise:** The receiver you've been eating lunch with since camp gets cut on a Tuesday morning. He's still in the parking lot at noon.

The receiver you've eaten lunch with since camp gets cut on a Tuesday morning. At noon he's still sitting in his car in the players' lot.

1. **Sit in the car with him**: You knock on the window and sit in the passenger seat for an hour. You don't say much. He drives away a little steadier.  
   *(energy -1; social +1; charisma +1; Team +2; modifier drained)*
2. **Make a call for him**: You call a coach you know at another club and say the receiver's name twice. He gets a workout the next week.  
   *(energy -1; leadership +2; intelligence +1; Team +1; modifier inspired)*
3. **Leave him alone**: You walk past to your own car. It's not your business, and it could be you next year. You think about it the whole drive home.  
   *(energy +1; ambition +1; 1 SP; modifier distracted)*

### PRO_010 Meeting the Owner
- **Category:** team  
- **Window:** age 21-26, club season 1, once  
- **Cast:** (no cast)  
- **Premise:** The owner throws a party for the rookies at his house and spends twenty minutes telling you what kickers are worth.

The owner throws a party for the rookies at his house and spends twenty minutes telling you exactly what kickers are worth, which is not much.

1. **Smile and agree**: You smile, agree and get a second drink of lemonade. He likes you. You feel slightly worse about yourself on the drive home.  
   *(social +1; energy +1; charisma +1; ambition -1; **retention +1**; modifier distracted)*
2. **Make him laugh**: You tell him kickers are the only players who show up to work every week without hurting anyone. He laughs harder than you expected and remembers your name.  
   *(fun +2; social +2; charisma +2; modifier confident)*
3. **Tell him he's wrong**: You tell him, politely, that he's wrong, and why. The room goes quiet. {coach} hears about it by Monday.  
   *(social -1; ambition +2; leadership +1; {coach} -2; modifier stressed)*

### PRO_011 The Quote
- **Category:** media  
- **Window:** age 21-26, club seasons 1-2, once  
- **Cast:** Team, {coach}  
- **Premise:** You said something careless to a beat reporter about the veteran you replaced, and it's the headline.

You said something careless to a beat reporter about the kicker you replaced, and it's the headline on the team's biggest fan site.

1. **Apologize to his face**: You find him and apologize in person, no excuses. He accepts it more gracefully than you would have.  
   *(energy -1; social -1; leadership +2; Team +3; modifier drained)*
2. **Say it was taken out of context**: You tell another reporter it was out of context. The original reporter posts the full recording.  
   *(fun +1; ambition +1; intelligence -1; followers -2; Team -2; {coach} -2; modifier stressed)*
3. **Say nothing**: You let it blow over. It does, in about a week, and the veterans remember it a while longer.  
   *(energy +1; Team -1; modifier distracted)*
4. 🔒 *locked: needs `handled_old_post` or `online_incident`, shown as "having been through a public mistake before"*  
   **Handle it the way you learned to**: You've done this before. You call the reporter back, own the quote, and apologize to the veteran before lunch. It's over by dinner.  
   *(energy -2; leadership +2; intelligence +1; Team +2; {coach} +1; modifier focused)*

### PRO_012 Your First Autograph Line
- **Category:** community  
- **Window:** age 21-26, club seasons 1-2, once  
- **Cast:** (no cast)  
- **Premise:** A kid in a jersey with your number on it is first in line. You didn't know they made your number.

A kid in a jersey with your number on it is first in line at the autograph table. You didn't know they made your number.

1. **Take your time with him**: You sign the jersey, the ball and his little brother's hat, and ask him about his own team. The line behind him gets longer and nobody minds.  
   *(energy -1; social +2; fun +2; charisma +1; leadership +1; followers +2; modifier inspired)*
2. **Ask his parents for a photo**: You ask for a photo and post it with his first name and no last name. It's the best-liked thing you've ever posted.  
   *(fun +2; charisma +2; followers +4; modifier spotlight)*
3. **Keep the line moving**: You sign, smile and keep the line moving like the team's staff asked. Two hundred people get an autograph, and none of them get a moment.  
   *(energy -2; leadership +1; intelligence +1; followers +1; Team +1; modifier focused)*

### PRO_013 Rookie Year Ends
- **Category:** team  
- **Window:** age 21-26, club season 1, offseason, once  
- **Cast:** (no cast)  
- **Premise:** The season's over. The locker room empties in an afternoon, and you realize you have no idea what pros do in the offseason.

The season's over. The locker room empties in an afternoon, and you realize you have no idea what pros do in the offseason.

1. **Ask the veterans**: You ask three veterans how they spend the offseason and steal the best of each plan. It's the best summer of training you've had.  
   *(energy -2; social +1; intelligence +1; 2 SP; Team +1; modifier focused)*
2. **Go home for a month**: You go home and do nothing for a month: {parent}'s cooking, old friends, your old bedroom. You come back rested and a little out of shape.  
   *(energy +4; fun +3; {parent} +3; modifier rested)*
3. **Train like you're still in camp**: You never stop. Six days a week, all summer. By August your leg is the strongest it's been, and you're tired before camp starts.  
   *(energy -4; ambition +2; 3 SP; modifier heavy_legs)*

### PRO_014 The Second-Year Wall
- **Category:** team  
- **Window:** age 22-27, club season 2, weeks 1-4, once  
- **Cast:** (no cast)  
- **Premise:** Year two. The novelty is gone, the scouting reports on you are thicker, and your legs feel every one of last season's kicks.

Year two. The novelty is gone, the scouting reports on you are thicker, and your legs remember every kick of last season.

1. **Change something small**: You change one thing, a half-step in your approach, and chart it for a month. It takes, and it surprises the coaches watching you.  
   *(energy -1; intelligence +2; 1 SP; {coach} +2; modifier focused)*
2. **Change nothing**: You decide last year's routine earned you this year, and you keep every piece of it. Some weeks it works perfectly. Some weeks it's just a routine.  
   *(energy +1; ambition +1; 1 SP; modifier confident)*
3. **Take on a rookie**: You take the new rookie specialist under your wing, like someone did for you. It costs you time, and it makes the room yours.  
   *(energy -2; social +2; leadership +2; Team +3; modifier inspired)*

### PRO_015 The Rookie Symposium Call
- **Category:** social  
- **Window:** age 21-26, club seasons 1-2, once, opens on `owned_mistake` / `rebuilt_reputation` / `took_responsibility_scout`  
- **Cast:** (no cast)  
- **Premise:** A former teammate from college calls from his rookie symposium: they told a story about someone who sounds a lot like you.  
- **Note:** College callback scene: opens only for players with a college comeback; pairs with pro_rookie_symposium.

A college teammate calls from his rookie symposium: they told a story about a player who owned his mistakes and came back, and it sounded a lot like you.

1. **Tell him the real version**: You tell him the parts that didn't make the speech: the bad nights, the early workouts, the people who wouldn't look at you for a while. He goes quiet and then thanks you.  
   *(energy -1; social +1; leadership +1; charisma +1; modifier inspired)*
2. **Laugh it off**: You laugh and say they must have meant someone else. It's easier than talking about it, and you feel it all week.  
   *(fun +1; modifier distracted)*
3. **Call the people who helped**: You hang up and call the coach who gave you the chance. The coach doesn't say much, and doesn't need to.  
   *(energy -1; intelligence +1; {coach} +1; modifier focused)*

#### Flags this batch sets, and what they open

- `froze_out_veteran` (from PRO_002) → nothing reads it yet
- `learned_from_veteran` (from PRO_002) → nothing reads it yet
- `paid_family_debt` (from PRO_003) → nothing reads it yet
- `saved_rookie_check` (from PRO_003) → nothing reads it yet
- `spent_rookie_check` (from PRO_003) → nothing reads it yet
- `stayed_out_pro` (from PRO_006) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro
- `trusted_snapper` (from PRO_005) → PRO_091 The Snapper Retires

## PRO batch 2: the first money and contract scenes

### PRO_048 The Agent's Bigger Client
- **Category:** career  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** Your agent just signed a star quarterback, and your calls go to voicemail.

Your agent just signed a star quarterback. Your last three calls went to voicemail, and the fourth went to an assistant who asked how to spell your name.

1. **Say something now**: You email your agent a short list: what you need this year and by when. The reply comes from your agent personally, a day late and apologetic.  
   *(energy -1; leadership +1; intelligence +1; modifier focused)*
2. **Let it slide**: You tell yourself the agent's busy and it'll even out. It doesn't. You stop expecting calls back.  
   *(energy +1; fun +1; ambition -1; modifier distracted; sets `agent_neglect`)*
3. **Vent to the locker room**: You complain about your agent to anyone who'll listen. Two teammates say theirs is worse. A reporter hears about it by Friday.  
   *(social +2; fun +1; charisma -1; followers -1; modifier stressed; sets `agent_neglect`)*

### PRO_049 Firing Your Agent
- **Category:** career  
- **Window:** once, needs `agent_neglect`  
- **Cast:** (no cast)  
- **Premise:** Your agent has missed two deadlines this year. Firing him means starting over with someone new.

Your agent has missed two deadlines this year, including one for a bonus you never saw. Firing an agent means starting over with someone new in the middle of a career.

1. **Fire your agent**: You send a short letter and make three calls to find someone new. It's awkward for a month and a relief after that.  
   *(energy -2; leadership +2; ambition +1; modifier stressed; sets `fired_agent`)*
2. **Give one last chance**: You sit down with your agent and lay out exactly what has to change. Things get better for a season, mostly.  
   *(energy -1; charisma +1; intelligence +1; modifier focused)*
3. **Stay and say nothing**: You decide a bad agent you know beats a new one you don't. The next deadline gets missed too.  
   *(energy +1; fun +1; ambition -1; **retention -1**; modifier distracted)*

### PRO_050 The Good Agent
- **Category:** career  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** An agent with six clients asks for an hour to show you a plan with no flash in it at all.

An agent with six clients asks for an hour. The pitch has no private jets and no promises, just a plan so plain it's almost funny.

1. **Sign with the plain plan**: You sign. The calls get answered, the deadlines get met, and nothing about it will ever make a highlight reel.  
   *(energy +1; intelligence +2; modifier focused; sets `good_agent`)*
2. **Stay with the big agency**: You stay with the big agency because the name opens doors. Some do. Some just have a receptionist behind them.  
   *(fun +1; ambition +2; followers +1; modifier confident)*
3. **Ask what they'd fix first**: You ask what they'd change about your career tomorrow. The answer is specific and a little uncomfortable, and you hire them on the spot.  
   *(energy -1; intelligence +1; leadership +1; charisma +1; modifier inspired; sets `good_agent`)*

### PRO_056 The Big Check
- **Category:** money  
- **Window:** age 24-34, once  
- **Cast:** (no cast)  
- **Premise:** The signing bonus clears. Your phone lights up with cousins.

The signing bonus clears. Within an hour your phone lights up with cousins, a car dealer and someone from high school who wants to 'catch up'.

1. **Put it somewhere boring**: You put almost all of it somewhere boring and tell everyone it's tied up. Nobody believes you, and nobody can get to it.  
   *(fun -1; energy +2; intelligence +2; modifier focused; sets `saved_big_check`)*
2. **Celebrate properly**: You take the whole family on a trip and buy the house with the pool. It's the best summer anyone in your family has had.  
   *(fun +4; social +2; intelligence -1; {parent} +4; modifier loose; sets `spent_big_check`)*
3. **Set aside a family share**: You set aside one share for family and tell them it's the only one. The cousins grumble. {parent} quietly approves.  
   *(social -1; leadership +1; intelligence +1; {parent} +2; modifier focused; sets `saved_big_check`)*

### PRO_057 The Honest Advisor
- **Category:** money  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** A financial advisor recommended by your snapper walks you through a plan so boring it's almost funny.

A financial advisor recommended by your long snapper walks you through a plan so boring it's almost funny: index funds, a budget, a rule about cars.

1. **Hire the boring advisor**: You hire the advisor and follow the rule about cars, mostly. Nothing exciting happens to your money, which is the point.  
   *(fun -1; intelligence +2; leadership +1; modifier focused; sets `honest_advisor`)*
2. **Ask for something with more upside**: You ask for something with more upside. The advisor says no, explains why, and you hire them anyway.  
   *(ambition +1; intelligence +1; modifier focused; sets `honest_advisor`)*
3. **Pass for now**: You say you'll think about it and never call back. The money sits in a checking account doing nothing at all.  
   *(energy +1; fun +1; modifier rested)*

### PRO_058 The Advisor With the Yacht
- **Category:** money  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** A financial advisor who manages three teammates invites you onto his boat and talks about 'real returns'.

A financial advisor who manages three of your teammates invites you onto his boat and talks about 'real returns', the kind 'the boring guys' can't get you.

1. **Hand over your money**: You sign the papers on the boat. The first statements look incredible, and he's always available when you call.  
   *(fun +3; social +1; ambition +2; intelligence -2; modifier confident; sets `trusted_flashy_advisor`)*
2. **Ask for audited statements**: You ask for audited statements and a reference outside football. He laughs and changes the subject, and you never sign.  
   *(social -1; intelligence +2; leadership +1; modifier focused)*
3. **Enjoy the boat, sign nothing**: You enjoy the afternoon, eat his food and sign nothing. Your teammates think you're paranoid.  
   *(fun +2; charisma +1; Team -1; modifier loose)*
4. 🔒 *locked: needs `good_agent` or `honest_advisor`, shown as "having an agent or advisor you trust"*  
   **Send it to the people you trust**: You send his paperwork to the people who already handle your money. Their reply is one word: 'No.' Then a second message: 'Warn your teammates.'  
   *(energy -1; intelligence +2; leadership +1; Team +2; modifier focused)*

### PRO_060 The Lawsuit
- **Category:** money  
- **Window:** once, needs `advisor_stole`  
- **Cast:** (no cast)  
- **Premise:** Your lawyer says you can sue the advisor. It'll take three years and your name will be in every story.

Your lawyer says you can sue the advisor who took your money. It'll take three years, and your name will be in every story.

1. **Sue him**: You file. The case drags on for years, you testify twice, and some of the money comes back long after you've stopped counting on it.  
   *(energy -3; fun -2; leadership +1; ambition +1; intelligence +1; followers -1; modifier stressed; sets `sued_advisor`)*
2. **Report him and move on**: You file the report with the regulators and let them handle it. He's barred from the business a year later. You never see a dime.  
   *(energy -1; intelligence +1; modifier focused)*
3. **Join with the other players**: You call the three teammates he also handled. Together you hire one lawyer and split the bill. It's slower, and nobody faces it alone.  
   *(energy -2; social +2; leadership +2; Team +3; modifier inspired; sets `sued_advisor`)*

### PRO_062 The Restaurant Is Failing
- **Category:** money  
- **Window:** once, needs `opened_restaurant`  
- **Cast:** (no cast)  
- **Premise:** The steakhouse is losing money every week, and your name is on the sign.

The steakhouse is losing money every week. The chef quit, your old teammate isn't answering, and your name is still lit up over the door.

1. **Close it now**: You close it, pay the staff two weeks' wages from your own pocket and take your name down yourself. It hurts, and it's over.  
   *(fun -2; energy -1; leadership +2; charisma +1; modifier drained; sets `bad_venture`)*
2. **Put more money in**: You write another check to keep it open one more season. The food gets better. The losses don't.  
   *(fun +1; ambition +1; intelligence -1; modifier stressed; sets `bad_venture`)*
3. **Sell your share to your partner**: You sell your share to your old teammate for whatever he can pay. You lose most of it and keep the friendship, barely.  
   *(social +1; intelligence +1; modifier focused; sets `bad_venture`)*
4. 🔒 *locked: needs `honest_advisor`, shown as "having an advisor you trust"*  
   **Let your advisor run the exit**: Your advisor finds a buyer for the lease and the equipment within a month. You lose money, but a lot less than you would have.  
   *(energy -1; intelligence +2; modifier focused; sets `bad_venture`)*

### PRO_063 The Car Dealership
- **Category:** money  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** A dealership wants you as a partner: your face on the billboards, your money in the lot.

A car dealership wants you as a partner: your face on the billboards, your money in the lot, and a guaranteed parking space with your name on it.

1. **Become a partner**: You sign. Your face goes up on the highway, and every teammate calls you about a deal. The dealership's books are the dealer's business, until they aren't.  
   *(fun +2; social +1; ambition +1; intelligence -1; followers +3; modifier spotlight; sets `dealership_partner`)*
2. **Do the ads, skip the ownership**: You agree to the billboards for a flat fee and keep your money out of the lot. It's less exciting and a lot safer.  
   *(energy -1; intelligence +1; charisma +1; followers +2; modifier focused)*
3. **Pass**: You pass. Your face stays off the highway, and somebody else's goes up three months later.  
   *(energy +1; intelligence +1; modifier rested)*

### PRO_064 The Friend's Start-Up
- **Category:** money  
- **Window:** once  
- **Cast:** {best_friend}  
- **Premise:** {best_friend} is starting a company and asks you to be the first investor.

{best_friend} is starting a company, a real one with a plan and two hires, and asks you to be the first investor.

1. **Invest**: You write the check because it's {best_friend}, and because the plan is actually good. You get a seat at their first board meeting and don't understand half of it.  
   *(fun +1; social +1; ambition +1; {best_friend} +6; modifier inspired; sets `invested_in_friend`)*
2. **Invest a little, and say why**: You invest a small piece and tell {best_friend} why it's small. It stings for a day, and they respect it after that.  
   *(intelligence +1; leadership +1; {best_friend} +3; modifier focused; sets `invested_in_friend`)*
3. **Say no as a friend**: You say you don't mix friendship and money, and you mean it kindly. {best_friend} says they understand, and calls a little less often.  
   *(energy +1; fun +1; intelligence +1; {best_friend} -3; modifier rested)*

### PRO_065 The Start-Up Calls
- **Category:** money  
- **Window:** once, needs `invested_in_friend`  
- **Cast:** {best_friend}  
- **Premise:** {best_friend}'s company is either about to make it or about to fold, and they need one more check.  
- **Note:** The one good venture: it can pay off.

{best_friend}'s company is close: one more check and they make it to the next stage, or they fold this month.

1. **Write the last check**: You write it. Six months later the company is bought, and your share turns into the best investment of your life. {best_friend} cries on the phone.  
   *(fun +3; ambition +1; {best_friend} +8; modifier inspired)*
2. **Hold the line**: You don't put in more. The company makes it anyway with someone else's money, and your share is smaller than it could have been. You're still glad for them.  
   *(energy +1; intelligence +1; {best_friend} +2; modifier focused)*
3. **Help them find another investor**: You introduce {best_friend} to two people from the owner's gala. One of them writes the check.  
   *(energy -2; social +2; charisma +1; leadership +1; {best_friend} +6; modifier focused)*
4. 🔒 *locked: needs `honest_advisor`, shown as "having an advisor you trust"*  
   **Ask your advisor to look first**: Your advisor reads the numbers and says this one is real. You write the check with your eyes open, and it pays.  
   *(energy -1; fun +2; intelligence +1; {best_friend} +6; modifier confident)*

### PRO_066 The Tax Letter, Pro
- **Category:** money  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** You owe taxes in every state you played a road game in, and your old accountant didn't file most of them.

You owe taxes in every state where you played a road game, and your old accountant didn't file most of them. The letters have started to arrive.

1. **Hire a sports accountant**: You hire an accountant who does nothing but athletes. It takes a month of paperwork and a painful check, and it's done.  
   *(energy -2; fun -1; intelligence +2; leadership +1; modifier stressed)*
2. **Ignore the letters**: You put the letters in a drawer. They come back with penalties, and then with a lawyer's name on them.  
   *(energy +1; fun +1; intelligence -2; **retention -1**; modifier distracted)*
3. **Ask the veterans what they did**: You ask the veterans at lunch. Every one of them has a horror story and a phone number. You call the one who sounds least scary.  
   *(energy -1; social +1; intelligence +1; Team +1; modifier focused)*
4. 🔒 *locked: needs `saved_first_paycheck`, shown as "having handled money carefully since your first paycheck"*  
   **Pay it from the account you never touch**: You pay it from the account you've never touched since your first paycheck. It's a big number, and it doesn't keep you up at night.  
   *(fun -1; intelligence +1; modifier rested)*

### PRO_071 The Watch, the Car, the Chain
- **Category:** money  
- **Window:** once  
- **Cast:** Team  
- **Premise:** The locker room has a dress code nobody wrote down, and it costs about your rookie salary.

The locker room has a dress code nobody wrote down: the watch, the car, the chain. It costs about what you made as a rookie.

1. **Keep up**: You buy the watch and the car. You look the part, and every month the statement looks a little worse.  
   *(fun +3; social +2; intelligence -1; followers +2; modifier spotlight)*
2. **Opt out with a joke**: You show up in the same old truck and call it 'retro'. It becomes a running joke, and nobody actually minds.  
   *(social +1; charisma +1; intelligence +1; modifier loose)*
3. **Ask a veteran who went broke**: You ask the oldest player on the roster about the watch. He takes his off and tells you what it cost him in the end.  
   *(energy -1; intelligence +2; Team +1; modifier focused)*

#### Flags this batch sets, and what they open

- `agent_neglect` (from PRO_048) → PRO_049 Firing Your Agent
- `bad_venture` (from PRO_062) → PRO_072 Broke at Thirty-Three
- `dealership_partner` (from PRO_063) → nothing reads it yet
- `fired_agent` (from PRO_049) → nothing reads it yet
- `good_agent` (from PRO_050) → PRO_041 The Holdout Talk (locked choice); PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_059 The Missing Money (locked choice)
- `honest_advisor` (from PRO_057) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice)
- `invested_in_friend` (from PRO_064) → PRO_065 The Start-Up Calls
- `saved_big_check` (from PRO_056) → nothing reads it yet
- `spent_big_check` (from PRO_056) → PRO_072 Broke at Thirty-Three
- `sued_advisor` (from PRO_060) → nothing reads it yet
- `trusted_flashy_advisor` (from PRO_058) → PRO_059 The Missing Money

## PRO batch 3: partner and family, Found Out, and the pro wrong-path chain steps

### PRO_074 The Proposal
- **Category:** romance  
- **Window:** once, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner`, not `engaged` / `married`, rel_love_interest 55+  
- **Cast:** {love_interest}  
- **Premise:** You've been carrying a ring around for three weeks, waiting for the right moment that won't come during a season.

You've carried a ring around in your gym bag for three weeks, waiting for a right moment that never seems to come during a season.

1. **Ask tonight**: You stop waiting for the perfect moment and ask in the kitchen, still in your practice clothes. {love_interest} laughs, cries and says yes, in that order.  
   *(fun +4; social +1; charisma +1; {love_interest} +8; modifier inspired; sets `engaged`)*
2. **Ask {parent} first**: You call {parent} first, which nobody does anymore. He's quiet, then tells you how he asked your mother. You propose that weekend with his story in your head.  
   *(fun +2; energy -1; leadership +1; {love_interest} +6; {parent} +4; modifier inspired; sets `engaged`)*
3. **Wait until you're sure**: You put the ring back in the bag. You're not ready, and you think {love_interest} can tell something's different.  
   *(energy +1; ambition +1; 1 SP; {love_interest} -3; modifier distracted)*

### PRO_075 The Wedding
- **Category:** family  
- **Window:** offseason, once, needs `engaged`  
- **Cast:** {love_interest}, {parent}, {sibling}  
- **Premise:** The wedding is in the offseason. The guest list is a fight.

The wedding is this offseason. The guest list is a fight: {parent} wants half your hometown, {love_interest} wants forty people, and your agent wants a magazine there.

1. **Forty people, no cameras**: You keep it to forty people and no cameras. {parent} grumbles for a week and then dances until midnight.  
   *(fun +3; social +1; leadership +1; {love_interest} +8; {parent} -1; modifier inspired; sets `married`)*
2. **Invite the whole town**: You invite everyone. It's loud, enormous and a little out of control, and your hometown talks about it for years.  
   *(fun +4; social +3; energy -3; charisma +1; {parent} +5; {love_interest} +2; modifier loose; sets `married`)*
3. **Let the magazine in**: You let the magazine shoot it. The photos are beautiful and everywhere, and some of the day belongs to strangers.  
   *(fun +2; social +1; charisma +2; followers +6; {love_interest} -2; modifier spotlight; sets `married`)*

### PRO_076 The Due Date
- **Category:** family  
- **Window:** once, opens on `married` / `engaged`  
- **Cast:** {love_interest}, {coach}  
- **Premise:** The baby is due the same week as a road game across the country.

The baby is due the same week as a road game across the country, and {coach} has already asked what your plan is.

1. **Stay home for the birth**: You tell {coach} you're staying home, whatever it costs. You're there when the baby arrives, and you'd make the same call a hundred times.  
   *(fun +4; energy -3; leadership +1; **retention -1**; {love_interest} +8; {coach} -2; modifier inspired; sets `became_parent`)*
2. **Fly out and fly back**: You fly out for the game and take the first flight home. You miss the birth by four hours and meet your kid in a hospital hallway at dawn.  
   *(energy -5; fun +1; ambition +2; 2 SP; {love_interest} -4; {coach} +2; modifier drained; sets `became_parent`)*
3. **Ask {coach} for a plan**: You sit down with {coach} and work out a plan: a phone in the trainer's pocket and a jet on standby. It's complicated, and it works.  
   *(energy -3; fun +2; intelligence +1; charisma +1; {love_interest} +4; {coach} +3; modifier focused; sets `became_parent`)*

### PRO_085 {tyler} in the Same Division
- **Category:** social  
- **Window:** once  
- **Cast:** {tyler}  
- **Premise:** {tyler} signs with a division rival, and the media has already made the graphic.

{tyler} signs with a team in your division, and the sports channel has already made the graphic: the two of you, face to face, twice a year.

1. **Call {tyler} and laugh about it**: You call {tyler} and laugh about the graphic. You agree to give the reporters nothing, and you both mostly keep that promise.  
   *(fun +2; social +1; charisma +1; {tyler} +5; modifier loose; sets `tyler_division_rival`)*
2. **Use it**: You put the graphic on your locker. Every practice before those two games has a little more in it.  
   *(energy -1; ambition +2; 2 SP; {tyler} -2; modifier pumped_up; sets `tyler_division_rival`)*
3. 🔒 *locked: needs `tyler_mutual_respect` or `congratulated_tyler`, shown as "having earned {tyler}'s respect before"*  
   **Plan a dinner after the first game**: You text {tyler} a restaurant name and a time: after the first game, win or lose. He sends back a thumbs-up and a picture of the two of you at sixteen.  
   *(fun +3; social +1; energy -2; charisma +1; leadership +1; {tyler} +8; modifier inspired; sets `tyler_division_rival`)*
4. 🔒 *locked: needs `trash_talked_tyler`, shown as "having trash-talked {tyler} in college"*  
   **Make peace first**: You remember what you said about {tyler} in college, and you call to say it was out of line. It's an awkward call, and the rivalry gets cleaner after it.  
   *(energy -1; leadership +2; {tyler} +6; modifier drained; sets `tyler_division_rival`)*

### PRO_160 Found Out
- **Category:** romance  
- **Window:** once, needs `pro_cheated`  
- **Cast:** {love_interest}  
- **Premise:** {love_interest} has your phone in one hand and a question in the other.  
- **Note:** Story event, soon after the strike. Confess: costs now, keeps the door open. Lie: worse when it surfaces.

{love_interest} has your phone in one hand and a question in the other, and it isn't really a question.

1. **Tell the whole truth**: You tell the truth: the night, the hotel, all of it. {love_interest} goes very quiet and leaves for a friend's place. Two days later, a text: 'I'm not done talking.'  
   *(energy -3; fun -3; leadership +2; charisma +1; {love_interest} -8; modifier drained; sets `confessed_affair`)*
2. **Lie**: You say it isn't what it looks like and keep saying it until {love_interest} stops asking. It works, for now. It always works for now.  
   *(energy +1; ambition +1; leadership -2; {love_interest} -2; modifier stressed; sets `lied_about_affair`)*

### PRO_161 The Lie Comes Out
- **Category:** romance  
- **Window:** once, needs `lied_about_affair`  
- **Cast:** {love_interest}  
- **Premise:** The story you told {love_interest} has just fallen apart, in a text from someone you've never met.  
- **Note:** Breaking up clears every partner flag (made_long_distance_work, committed_to_relationship, new_partner, engaged).

The story you told {love_interest} has just fallen apart, in a text from someone you've never met, with screenshots.

1. **Ask for one more chance**: You ask for one more chance and promise everything you can think of. {love_interest} doesn't say yes, and doesn't leave. Not yet.  
   *(energy -3; fun -3; charisma +1; {love_interest} -6; modifier drained; sets **strike** `affair_public`)*
2. **Let them go**: You don't argue. You help pack the car and stand in the driveway after it leaves. It's the worst week of your life, and you know you earned it.  
   *(fun -4; social -2; leadership +1; intelligence +1; {love_interest} -10; modifier drained; sets **strike** `affair_public`, `broke_up_pro`; clears `made_long_distance_work`, `committed_to_relationship`, `new_partner`, `engaged`)*
3. **Blame them**: You say it happened because they were never around. It's cruel, it isn't true, and you know it while you're saying it.  
   *(fun -2; ambition +1; leadership -2; charisma -1; {love_interest} -15; modifier stressed; **conduct bad**; sets **strike** `affair_public`, `broke_up_pro`; clears `made_long_distance_work`, `committed_to_relationship`, `new_partner`, `engaged`)*

### PRO_162 Starting Over, Together
- **Category:** romance  
- **Window:** once, needs `confessed_affair`  
- **Cast:** {love_interest}  
- **Premise:** {love_interest} agrees to see a counselor with you. The first session is Thursday, and the counselor asks who wants to go first.

{love_interest} agrees to see a counselor with you. The first session is Thursday, and the counselor asks who wants to go first.

1. **Go first, every week**: You go first, every week, for six months. Some sessions are worse than the night itself. Slowly, you start to recognize each other again.  
   *(energy -3; fun -2; leadership +1; intelligence +1; {love_interest} +8; modifier drained; sets `repaired_relationship`)*
2. **Go a few times, then stop**: You go three times and then say practice is too busy. It's true, and you both know it isn't the reason.  
   *(energy +1; ambition +1; 1 SP; {love_interest} -4; modifier distracted)*
3. **Agree it's over**: After the second session you both say what neither wanted to: it's over. You end it as kindly as two hurt people can.  
   *(fun -3; social -1; intelligence +1; charisma +1; {love_interest} -2; modifier drained; sets `broke_up_pro`; clears `made_long_distance_work`, `committed_to_relationship`, `new_partner`, `engaged`)*

### PRO_124 The Team Fine
- **Category:** team  
- **Window:** story event, once, opens on any pro strike  
- **Cast:** (no cast)  
- **Premise:** The club fines you and calls you in. The special teams coach is there, and so is the general manager.  
- **Note:** Both choices set pro_warning (the fine is on record); owning it also sets pro_owned_it. College flags set severity through a locked choice. Every choice clears every pro strike.

The club fines you and calls you in. {coach} is in the room, and so is the general manager, who has a folder with your name on it.

1. **Own it**: You don't explain it away. You say what happened, what you'll change and who can hold you to it. The general manager closes the folder early.  
   *(energy -2; social -1; leadership +2; **retention -1**; {coach} +2; modifier drained; sets `pro_warning`, `pro_owned_it`; clears every pro strike)*
2. **Explain it away**: You explain why it wasn't really your fault. The general manager listens to all of it and writes one word at the top of the page.  
   *(energy +1; ambition +1; leadership -2; **retention -3**; {coach} -4; modifier stressed; sets `pro_warning`; clears every pro strike)*
3. 🔒 *locked: needs `owned_mistake` or `rebuilt_reputation`, shown as "having owned a mistake before"*  
   **Say you've been here before**: You tell them you've sat in a room like this in college and what you did after. {coach} nods slowly. The fine stands. The tone changes.  
   *(energy -2; fun -2; leadership +2; charisma +1; **retention -1**; {coach} +4; modifier confident; sets `pro_warning`, `pro_owned_it`; clears every pro strike)*

### PRO_125 League Discipline
- **Category:** team  
- **Window:** story event, once, needs `pro_warning`, opens on any pro strike  
- **Cast:** (no cast)  
- **Premise:** The league office wants a meeting. It's not a conversation; it's a hearing.  
- **Note:** Opens on the warning plus a new pro strike. suspend_weeks 2 (longer once R9 lands). Every choice clears every pro strike.

The league office wants a meeting. It isn't a conversation; it's a hearing, with a lawyer from the players' union at your side.

1. **Accept the suspension**: You accept two games and don't appeal. You practice with the scout team, and the veterans notice that you show up every day anyway.  
   *(energy -2; fun -3; leadership +2; **retention -2**; **suspended 2 games**; Team +2; modifier drained; **conduct bad**; sets `pro_second_chance`; clears every pro strike)*
2. **Fight it**: You appeal and say the league is making an example of you. The appeal fails, the suspension stands, and now the whole league knows your name for the wrong reason.  
   *(fun -2; ambition +2; leadership -2; **retention -4**; **suspended 2 games**; followers -3; {coach} -6; modifier stressed; **conduct scandal**; sets `pro_second_chance`, `pro_character_concerns`; clears every pro strike)*

### PRO_126 The Last Warning, Pro
- **Category:** team  
- **Window:** story event, once, needs `pro_second_chance`, opens on any pro strike  
- **Cast:** (no cast)  
- **Premise:** The general manager says it plainly: one more and you're done here.  
- **Note:** Every choice clears every pro strike. College last_chance adds a locked line.

With {coach} beside the desk, the general manager says it plainly: one more, and you're done here. Then a list of conditions slides across the table.

1. **Accept every condition**: Early workouts, no nights out on the road, weekly check-ins. You sign the list. It costs you a lot of the season, and nobody has to wonder about you again.  
   *(energy -5; fun -4; leadership +2; **retention -2**; {coach} +4; modifier drained; sets `pro_last_chance`; clears every pro strike)*
2. **Push back**: You say the conditions are too much for what happened. The general manager ends the meeting. By Friday, every reporter covering the team has heard the word 'problem'.  
   *(energy +1; fun +1; ambition +2; leadership -3; **retention -5**; {coach} -10; Team -3; modifier stressed; **conduct scandal**; sets `pro_character_concerns`; clears every pro strike)*
3. 🔒 *locked: needs `last_chance`, shown as "having had a last chance in college"*  
   **Say you've heard this speech before**: You tell them you got this exact speech in college, and that you kept the promise for two years. You sign the list. {coach} believes you more than the general manager does.  
   *(energy -5; fun -4; social -2; leadership +2; charisma +1; **retention -2**; {coach} +6; modifier drained; sets `pro_last_chance`; clears every pro strike)*

### PRO_128 The Long Way Back, Pro
- **Category:** team  
- **Window:** story event, once, opens on `pro_character_concerns`  
- **Cast:** (no cast)  
- **Premise:** A new club, a short contract, and a list of conditions longer than the playbook.

You have a reputation in the league now. {coach} offers a way back: six a.m. workouts, a mentor from the players' union and no excuses for a full season.

1. **Take every hour of it**: You're there at six every day for a season, and your name stays out of every story. In the spring, {coach} tells a reporter you're not the same player, and means it.  
   *(energy -6; fun -3; leadership +3; **retention +4**; {coach} +8; Team +4; modifier tired; **conduct good**; sets `pro_rebuilt_reputation`; clears `pro_character_concerns`)*
2. **Do the minimum**: You do the workouts you can't skip. Nothing new goes wrong, nothing changes, and the reputation stays.  
   *(energy -2; ambition +1; {coach} -2; modifier focused)*
3. **Say you've paid enough**: You say you served your suspension and don't need a program. {coach} closes the folder. It's the last offer you get here.  
   *(energy +2; fun +2; ambition +2; leadership -2; **retention -3**; {coach} -8; modifier stressed)*

### PRO_129 The League's Counselor
- **Category:** health  
- **Window:** once, opens on `pro_second_chance` / `pro_last_chance`  
- **Cast:** (no cast)  
- **Premise:** The league assigns you a counselor after the hearing, and the first session is Tuesday.

The league assigns you a counselor after the hearing. The first session is Tuesday, in a beige office near the airport.

1. **Go and actually talk**: You go every week and actually talk. Some of it is about the incidents. Most of it isn't, and that turns out to be the point.  
   *(energy -1; health +2; intelligence +1; leadership +1; **retention +1**; modifier focused)*
2. **Go and say nothing**: You go every week and say as little as possible. You check the box, and the counselor writes that you checked the box.  
   *(energy +1; ambition +1; modifier distracted)*
3. **Bring the hard question**: In the first session you ask the question you've been avoiding: why it keeps happening. You don't get an answer that day. You get a better question.  
   *(energy -2; fun -1; resilience +1; intelligence +2; **retention +1**; modifier drained)*

### PRO_130 A Clean Year
- **Category:** team  
- **Window:** once, opens on `pro_owned_it` / `pro_rebuilt_reputation`  
- **Cast:** (no cast)  
- **Premise:** A full year without a fine, a headline or a hearing. The general manager notices.

A full year without a fine, a headline or a hearing. The general manager stops by your locker and says nothing, just nods.

1. **Thank the people who held you to it**: You thank {coach}, the union mentor and the teammate who drove you to the early workouts. Saying it out loud makes it real.  
   *(social +2; charisma +1; leadership +1; {coach} +4; Team +2; modifier inspired)*
2. **Keep it to yourself**: You keep it quiet and keep going. The best part of a clean year is that nobody talks about it.  
   *(energy +2; ambition +1; 1 SP; modifier rested)*
3. **Help a rookie who's slipping**: There's a rookie making your old mistakes. You take him to breakfast and tell him the whole story.  
   *(energy -2; social +1; leadership +3; Team +3; modifier inspired)*

#### Flags this batch sets, and what they open

- `affair_public` (from PRO_161) → PRO_163 The Divorce
- `became_parent` (from PRO_076) → PRO_077 First Day of School; PRO_078 The Recital; PRO_146 Your Kid Wants to Kick; PRO_159 The Long Week on the Road
- `broke_up_pro` (from PRO_161, PRO_162) → PRO_151 Someone New
- `confessed_affair` (from PRO_160) → PRO_162 Starting Over, Together; PRO_163 The Divorce
- `engaged` (from PRO_074) → PRO_075 The Wedding; PRO_076 The Due Date; PRO_079 Your Partner's Career; PRO_137 The Retirement Talk; PRO_157 The Sponsor's Rep
- `lied_about_affair` (from PRO_160) → PRO_161 The Lie Comes Out; PRO_163 The Divorce
- `married` (from PRO_075) → PRO_076 The Due Date; PRO_079 Your Partner's Career; PRO_095 The Tabloid; PRO_096 The Marriage on the Road; PRO_137 The Retirement Talk; PRO_158 The Teammate's Friend; PRO_159 The Long Week on the Road; PRO_163 The Divorce
- `pro_character_concerns` (from PRO_125, PRO_126) → PRO_128 The Long Way Back, Pro
- `pro_last_chance` (from PRO_126) → PRO_127 Released for Conduct; PRO_129 The League's Counselor
- `pro_owned_it` (from PRO_124) → PRO_130 A Clean Year
- `pro_rebuilt_reputation` (from PRO_128) → PRO_130 A Clean Year
- `pro_second_chance` (from PRO_125) → PRO_126 The Last Warning, Pro; PRO_129 The League's Counselor
- `pro_warning` (from PRO_124) → PRO_125 League Discipline
- `repaired_relationship` (from PRO_162) → nothing reads it yet
- `tyler_division_rival` (from PRO_085) → nothing reads it yet

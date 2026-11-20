# PRO batch 17: era 2 (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 17: era 2

### PRO_288 The Off-Season Weight
- **Category:** training  
- **Window:** age 26-29, offseason, once  
- **Cast:** Team  
- **Premise:** You come back from the off-season heavier than the club likes, and the strength coach has a scale ready.

You come back from the offseason heavier than the club likes, and the strength coach has a scale ready.

1. **Get on the scale**: You step on the scale, hear the number and spend six weeks earning back the old one.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
2. **Bring your own numbers**: You bring your leg-speed numbers from the summer. They're better than last year, and the strength coach backs off a little.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Laugh with the strength coach**: You joke your way through it and agree to a plan. The strength coach likes you more for it.  
   *(social +2; charisma +1; Team +3; modifier loose)*

### PRO_309 The Captaincy
- **Category:** team  
- **Window:** once, pro_seasons 5+  
- **Cast:** Team  
- **Premise:** The team votes for captains, and for the first time a kicker is on the ballot.

The team votes for captains, and for the first time a kicker is on the ballot.

1. **Ask for the vote**: You tell the room why a kicker can lead too. You win by four votes.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired; sets `pro_captain`)*
2. **Let the room decide**: You don't campaign. The room votes you in anyway, and that means more.  
   *(social +2; charisma +1; Team +3; modifier loose; sets `pro_captain`)*
3. **Take your name off**: You take your name off the ballot. A linebacker who wanted it more gets it.  
   *(energy +2; fun +1; modifier rested)*

### PRO_310 The Big Second Contract
- **Category:** money  
- **Window:** once, needs `re_signed`, pro_seasons 4+  
- **Cast:** Team  
- **Premise:** Your agent says this is the contract that matters, and the club agrees, eventually.

Your agent says this is the contract that matters, and the club agrees, eventually.

1. **Hold firm**: You hold firm for three tense weeks. You get your number and lose some sleep getting it.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
2. **Take the fair deal**: You take a fair deal early and stop thinking about it. Your agent calls it smart, and means it.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Ask the family first**: You talk it over at home before you sign. The number matters less than you thought.  
   *(social +2; charisma +1; {love_interest} +3; modifier loose)*

### PRO_311 The Teammate Who Becomes a Coach
- **Category:** team  
- **Window:** once, pro_seasons 6+  
- **Cast:** {holder}, {coach}  
- **Premise:** Your holder retires and joins the coaching staff. Now they're your boss.

{holder} retires and joins the coaching staff. Now they're your boss.

1. **Keep the friendship**: You keep the friendship and let {holder} coach you anyway. It works, mostly.  
   *(social +2; charisma +1; {holder} +3; modifier loose)*
2. **Set new rules**: You agree on new rules: coach at the facility, friends on the weekend.  
   *(energy -1; intelligence +2; {coach} +2; {holder} +2; modifier focused)*
3. **Earn it fresh**: You treat {holder} like any new coach and earn their trust again.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*

### PRO_312 The Endorsement Renewal
- **Category:** media  
- **Window:** once, pro_seasons 5+, followers tier verified  
- **Cast:** Team  
- **Premise:** Your biggest sponsor wants to renew, with new conditions.

Your biggest sponsor wants to renew, with new conditions: more appearances, more posts, more of you.

1. **Accept the conditions**: You accept. The money is good, and your weeks get a lot shorter.  
   *(energy -2; ambition +2; 2 SP; followers +4; modifier dialed_in)*
2. **Negotiate fewer appearances**: You negotiate the appearances down by half. They agree, grudgingly.  
   *(energy -1; intelligence +2; followers +2; {coach} +2; modifier focused)*
3. **Walk away**: You walk away. You get your Tuesdays back.  
   *(energy +2; fun +1; modifier rested)*

### PRO_313 The Hometown Charity Game
- **Category:** community  
- **Window:** offseason, once, pro_seasons 5+  
- **Cast:** {parent}, {best_friend}  
- **Premise:** You organize a charity game in your hometown with players from five clubs.

You organize a charity game in your hometown with players from five clubs.

1. **Run it yourself**: You run every detail yourself. It's exhausting and it raises more than anyone expected.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
2. **Bring in {best_friend}**: You put {best_friend} in charge of the day. It's the most fun either of you has had in years.  
   *(social +2; charisma +1; {best_friend} +4; modifier loose)*
3. **Hire an organizer**: You hire someone who knows events. It runs perfectly, and it feels a little less like yours.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*

### PRO_314 The Rival Club Calls
- **Category:** career  
- **Window:** once, needs `contract_year`, pro_seasons 5+  
- **Cast:** Team  
- **Premise:** A rival club's general manager makes it clear they'd pay more, next time you're free.

A rival club's general manager makes it clear they'd pay more, next time you're free.

1. **Tell your agent, nobody else**: You tell your agent and nobody else. You kick like a player who has options.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
2. **Tell your club**: You tell your own club about the call. They appreciate it and remember it.  
   *(social +2; charisma +1; **retention +2**; {coach} +1; modifier loose)*
3. **Ignore it**: You ignore it and kick the season out. Whatever comes, comes.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*

### PRO_315 The Motivation Slump
- **Category:** health  
- **Window:** once, pro_seasons 6+  
- **Cast:** Team  
- **Premise:** Nothing's wrong. That's the problem: practice feels like a job, and the job feels like nothing.

Nothing's wrong. That's the problem: practice feels like a job, and the job feels like nothing.

1. **Take a real break**: You take your days off seriously: no film, no phone. Some of the spark comes back.  
   *(energy +2; fun +1; modifier rested)*
2. **Talk to someone**: You talk to someone about it, out loud, for the first time.  
   *(social +2; charisma +1; {love_interest} +3; modifier loose)*
3. **Set a new goal**: You set a goal nobody else knows about. Practice has a point again.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*

### PRO_316 The Kid Who Copies Your Routine
- **Category:** media  
- **Window:** once, pro_seasons 5+  
- **Cast:** Team  
- **Premise:** A high school kicker's video goes around: he copies your routine down to the last step.

A high school kicker's video goes around: he copies your routine down to the last step.

1. **Send him a message**: You send him a message and a pair of cleats. His video of opening the box gets more views than yours.  
   *(social +2; charisma +1; followers +3; Team +1; modifier loose)*
2. **Fix one thing**: You post a short reply showing him one thing to fix. Kickers everywhere try it.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
3. **Smile and move on**: You smile, show {love_interest} the video and move on.  
   *(energy +2; fun +1; modifier rested)*

### PRO_317 A Teammate Holds Out
- **Category:** team  
- **Window:** once, pro_seasons 4+  
- **Cast:** Team  
- **Premise:** Your closest teammate is holding out for a new contract, and wants you to say something publicly.

Your closest teammate is holding out for a new contract, and wants you to say something publicly.

1. **Back him publicly**: You back him publicly. He's grateful, and the front office notices.  
   *(social +2; charisma +1; **retention -2**; Team +4; modifier loose)*
2. **Back him privately**: You tell him you're with him and keep it out of the papers.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Speak for the room**: You say the whole team wants him back and leave the money to the people who handle it.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*

### PRO_318 The Coordinator's Son
- **Category:** team  
- **Window:** once, pro_seasons 5+  
- **Cast:** {coach}, {backup}  
- **Premise:** The new special teams coordinator's son is a kicker on the practice squad.

The new special teams coordinator's son is a kicker on the practice squad.

1. **Out-kick him daily**: You out-kick him every day. It's awkward and undeniable.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
2. **Help the kid**: You help the kid with his plant foot. The coordinator watches and says nothing, and something changes.  
   *(social +2; charisma +1; {coach} +1; modifier loose)*
3. **Ask the coordinator directly**: You ask the coordinator directly how the job is decided. He respects the question.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*

### PRO_320 The Prime-Time Game
- **Category:** media  
- **Window:** once, pro_seasons 4+  
- **Cast:** Team  
- **Premise:** Your first prime-time game in years, and the broadcast crew wants an interview at the hotel.

Your first prime-time game in years, and the broadcast crew wants an interview at the hotel.

1. **Do the interview**: You do the interview and tell one good story. It runs before kickoff.  
   *(social +2; charisma +1; followers +3; Team +1; modifier loose)*
2. **Keep it short**: You give them ten minutes and go to bed early.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Decline politely**: You decline politely and watch film in your room.  
   *(energy +2; fun +1; modifier rested)*

### PRO_357 The Contract Extension
- **Category:** career  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The club wants to talk about extending your contract, a year early.

The club wants to talk about extending your contract, a year early.

1. **Take the security**: You sign early. Your agent says you left money on the table; you sleep fine.  
   *(energy -1; intelligence +2; **retention +2**; {coach} +2; modifier focused)*
2. **Bet on yourself**: You decline and play out the deal. Every kick is an audition now.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Ask {love_interest}**: You talk it over at home. You sign a shorter version.  
   *(social +2; charisma +1; {love_interest} +3; modifier loose)*

#### Flags this batch sets, and what they open

- `pro_captain` (from PRO_309) → nothing reads it yet

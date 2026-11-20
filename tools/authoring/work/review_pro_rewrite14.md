# PRO rewrite pass 14: the cross-era pool and the hand-written pro scenes

The 24 written cross-era (state-driven) PRO scenes, the 13 hand-written pro_* scenes and PRO_066 (era 1, for its standing cost). The wrong-path steps keep their standing costs; routine standing costs are removed. The hand-written scenes now have a source file: tools/authoring/work/pro_handwritten.json.

Dry run and import: 38 written, 0 errors, 0 warnings, 0 lint notes (writing-standard and repetition checks included). Graph check 0/0, tool tests and Godot tests pass (see the commit).

**Changed: 28 of 38.** Unchanged: pro_old_crowd, PRO_042, PRO_124, PRO_126, PRO_151, PRO_156, PRO_163, PRO_164, PRO_171, PRO_173.

**Standing costs removed** (routine choices): pro_rookie_dinner "Politely pass" (-2); pro_contract_talks "Push for top dollar" (-3); pro_media_interview "Blame the conditions" (-6); pro_media_interview "Decline to talk" (-1); pro_hospital_visit "Skip it for treatment" (-1); pro_folder_follows "Say college is over" (-1); pro_reporters_question "Say no comment" (-1); pro_reporters_question "Push back" (-3); PRO_049 "Stay and say nothing" (-1); PRO_059 "Call a lawyer before practice" (-1); PRO_059 "Call {parent}" (-2); PRO_059 "Keep it quiet and fix it yourself" (-1); PRO_059 "Call your agent first" (-1); PRO_076 "Stay home for the birth" (-1); PRO_066 "Ignore the letters" (-1).

Each scene shows the new version, then the old one in a fold. Effects are under each choice.

## 1. pro_rookie_dinner Rookie Dinner
*team; premise 29 words*

> The veterans 'invite' the rookies to cover the team dinner at a fancy steakhouse: forty players, a private room, and a menu with no prices on it at all.

1. **Pay for the whole thing** (26 words)
   The whole bill, on your card, with a straight face. It's painfully expensive, and the veterans love you for it for the rest of the season.
   <sub>social +6; fun +3; charisma +2; ambition -1; leadership +2; intelligence -1; mods confident</sub>

2. **Split it with the other rookies** (26 words)
   Split evenly with the other rookies, after a quick huddle by the coat check. It's fair and friendly, and the rookie class gets closer for it.
   <sub>social +2; charisma -1; intelligence +2; mods rested</sub>

3. **Politely pass** (29 words)
   A polite pass, with an excuse about your budget. A couple of veterans give you the cold shoulder for a month, and one of them respects you for it.
   <sub>social -6; ambition +2; leadership -1; mods stressed</sub>

<details><summary>Before</summary>

> The veterans 'invite' the rookies to cover the team dinner at a fancy steakhouse.

1. **Pay for the whole thing**: Expensive, but the vets love you.
   <sub>social +6; fun +3; charisma +2; ambition -1; leadership +2; intelligence -1; mods confident</sub>

2. **Split it with the other rookies**: Fair and friendly.
   <sub>social +2; charisma -1; intelligence +2; mods rested</sub>

3. **Politely pass**: A couple of veterans give you the cold shoulder.
   <sub>social -6; ambition +2; leadership -1; retention -2; mods stressed</sub>

</details>

## 2. pro_agent_meeting Agent Meeting
*career; premise 30 words*

> Three agencies want to represent you, and each one has a pitch: a famous name with forty clients, a careful agent with six, and your own reflection in the mirror.

1. **Sign with the big agency** (25 words)
   The big agency, with the famous name and the glossy folder. Big plans, big promises, and you're one of forty clients from the first meeting.
   <sub>charisma -1; ambition +3; leadership -1; intelligence +1; mods confident</sub>

2. **Hire a small, careful agent** (23 words)
   The small, careful agent, who returns every call within an hour. Fewer promises, much more attention, and a plan written on one page.
   <sub>charisma -2; leadership +1; intelligence +4; mods focused</sub>

3. **Represent yourself** (25 words)
   Yourself, at the kitchen table, reading contracts at midnight. It saves money, costs a lot of sleep, and teaches you more than any agent would.
   <sub>energy -4; resilience +1; charisma -1; ambition +2; leadership -1; intelligence +3; mods stressed</sub>

<details><summary>Before</summary>

> Three agencies want to represent you. Each one has a pitch.

1. **Sign with the big agency**: Big name, big plans.
   <sub>charisma -1; ambition +3; leadership -1; intelligence +1; mods confident</sub>

2. **Hire a small, careful agent**: Fewer promises, more attention.
   <sub>charisma -2; leadership +1; intelligence +4; mods focused</sub>

3. **Represent yourself**: Saves money. Costs sleep.
   <sub>energy -4; resilience +1; charisma -1; ambition +2; leadership -1; intelligence +3; mods stressed</sub>

</details>

## 3. pro_contract_talks Contract Talks
*money; premise 30 words*

> Your agent says the team wants to talk about an extension before the season. The general manager has a number in mind, and so do you, and they're far apart.

1. **Push for top dollar** (28 words)
   Top dollar, and nothing less. The talks get tense, the general manager stops smiling, and it takes a month to reach a number you can both live with.
   <sub>charisma +1; ambition +4; leadership -2; mods stressed</sub>

2. **Take a team-friendly deal** (21 words)
   A team-friendly deal, signed in a week. Teammates notice, management notices, and the locker room thinks a little more of you.
   <sub>social +2; ambition -2; leadership +4; retention +6; mods confident</sub>

3. **Wait until the season ends** (21 words)
   Wait until the season ends, and bet on yourself. Your agent sighs, the club shrugs, and every practice becomes a negotiation.
   <sub>resilience +1; charisma -1; intelligence +3; skill_points +1; mods focused</sub>

4. **Let the fans make your case** *(locked: None)* (24 words)
   Your public profile does the negotiating for you. Fans ask the club about you on every broadcast, and the offer gets better by Friday.
   <sub>fun +3; charisma +2; ambition +2; leadership -1; intelligence -1; retention +2; mods confident</sub>

<details><summary>Before</summary>

> Your agent says the team wants to talk about an extension.

1. **Push for top dollar**: Talks get tense.
   <sub>charisma +1; ambition +4; leadership -2; retention -3; mods stressed</sub>

2. **Take a team-friendly deal**: Teammates notice. Management does too.
   <sub>social +2; ambition -2; leadership +4; retention +6; mods confident</sub>

3. **Wait until the season ends**: Bet on yourself.
   <sub>resilience +1; charisma -1; intelligence +3; skill_points +1; mods focused</sub>

4. **Let the fans make your case**: Your public profile does the negotiating.
   <sub>fun +3; charisma +2; ambition +2; leadership -1; intelligence -1; retention +2; mods confident</sub>

</details>

## 4. pro_media_interview Postgame Questions
*media; premise 27 words*

> After a missed kick last week, the reporters are waiting at your locker, five of them, with their phones out and the same question ready to go.

1. **Own the miss** (25 words)
   Straight answers about the miss, no excuses, looking at each reporter in turn. It earns respect in the room, and the story dies by Wednesday.
   <sub>resilience +1; charisma +2; ambition -2; leadership +4; intelligence -1; retention +4; skill_points +1; mods confident</sub>

2. **Blame the conditions** (24 words)
   The wind, the hold, the field: you blame the conditions. The quote doesn't land well at all, and {holder} hears about it before practice.
   <sub>social -3; fun +2; resilience +1; charisma -1; leadership -3; rel holder -3; mods distracted</sub>

3. **Decline to talk** (23 words)
   No comment, today. You skip the circus, and the reporters write that you 'declined to talk', which follows you for a few days.
   <sub>social -2; charisma -1; intelligence +1; mods focused</sub>

4. **Turn it into a rallying cry** *(locked: None)* (23 words)
   Your answer turns into a rallying cry, about the whole unit having each other's backs. The locker room plays your quote all week.
   <sub>social +3; resilience +2; ambition -1; leadership +3; retention +5; skill_points +2; mods inspired</sub>

<details><summary>Before</summary>

> After a missed kick last week, reporters are waiting at your locker.

1. **Own the miss**: Straight answers earn respect.
   <sub>resilience +1; charisma +2; ambition -2; leadership +4; intelligence -1; retention +4; skill_points +1; mods confident</sub>

2. **Blame the conditions**: The quote doesn't land well.
   <sub>social -3; fun +2; resilience +1; charisma -1; leadership -3; retention -6; mods distracted</sub>

3. **Decline to talk**: You skip the circus.
   <sub>social -2; charisma -1; intelligence +1; retention -1; mods focused</sub>

4. **Turn it into a rallying cry**: The locker room plays your quote all week.
   <sub>social +3; resilience +2; ambition -1; leadership +3; retention +5; skill_points +2; mods inspired</sub>

</details>

## 5. pro_family_finances Family and Finances
*family; premise 29 words*

> Relatives keep asking for loans now that you're a pro: a cousin's car, an uncle's business, a great-aunt you've never met who has a very specific number in mind.

1. **Set a budget with an advisor** (22 words)
   A budget, built with an advisor, with one yearly amount for family help. Clear rules mean fewer awkward calls, and {parent} approves.
   <sub>charisma -2; intelligence +5; ambition +1; mods focused</sub>

2. **Help everyone out** (22 words)
   Help for everyone who asks. It's generous and stressful, and by spring you realize you've stopped saying no to anything at all.
   <sub>social +5; fun +2; charisma +2; ambition -1; leadership +1; intelligence -1; mods stressed</sub>

3. **Say no to everyone** (22 words)
   No, to everyone, every time. It's peace for your wallet and tension at every holiday, and {sibling} stops calling for a while.
   <sub>social -5; charisma -1; ambition +2; leadership -1; intelligence +1; mods drained</sub>

<details><summary>Before</summary>

> Relatives keep asking for loans now that you're a pro.

1. **Set a budget with an advisor**: Clear rules, fewer awkward calls.
   <sub>charisma -2; intelligence +5; ambition +1; mods focused</sub>

2. **Help everyone out**: Generous, and stressful.
   <sub>social +5; fun +2; charisma +2; ambition -1; leadership +1; intelligence -1; mods stressed</sub>

3. **Say no to everyone**: Peace for your wallet, tension at home.
   <sub>social -5; charisma -1; ambition +2; leadership -1; intelligence +1; mods drained</sub>

</details>

## 6. pro_hospital_visit Team Hospital Visit
*community; premise 31 words*

> The team is visiting the children's hospital this week: an afternoon of games, signed footballs and a ward full of kids who have been looking forward to it for a month.

1. **Stay all afternoon** (24 words)
   The whole afternoon, ward by ward, until the nurses chase you out. You'll remember one boy's face forever, and so will he remember yours.
   <sub>social +4; fun +4; energy -4; charisma +3; leadership +2; retention +2; mods inspired</sub>

2. **Join for the group photo** (25 words)
   A quick, kind visit and the group photo. You sign a few balls and leave on time, and a mother thanks you in the elevator.
   <sub>social +2; resilience +1; charisma +1; mods confident</sub>

3. **Skip it for treatment** (23 words)
   Skipped, for extra treatment on your hip. You get the recovery time, and you see the photos of everyone else the next day.
   <sub>health +4; social -3; energy +2; mods rested</sub>

<details><summary>Before</summary>

> The team is visiting the children's hospital this week.

1. **Stay all afternoon**: You'll remember this one forever.
   <sub>social +4; fun +4; energy -4; charisma +3; ambition -1; leadership +2; intelligence -1; retention +2; mods inspired</sub>

2. **Join for the group photo**: A quick, kind visit.
   <sub>social +2; charisma +1; intelligence -1; mods confident</sub>

3. **Skip it for treatment**: You get extra recovery time.
   <sub>health +4; social -3; retention -1; mods rested</sub>

</details>

## 7. pro_holder_chemistry Holder Chemistry
*training; premise 28 words*

> {holder} wants extra time to work on timing this week: an hour after every practice, just the two of you and a bag of balls, in the cold.

1. **Extra reps every day** (26 words)
   Extra reps every day, snap, hold, kick, until the timing is perfect. By Friday you could do it with your eyes closed, and {holder} is grinning.
   <sub>energy -4; accuracy +3; ambition -1; leadership +2; rel holder +3; retention +2; skill_points +3; mods dialed_in</sub>

2. **Take a recovery day instead** (20 words)
   A recovery day instead, and an apology to {holder}. Your leg feels brand new by Sunday, and {holder} understands, mostly.
   <sub>health +5; energy +6; charisma -1; intelligence +1; mods fresh_legs</sub>

3. **Study the opponent's stadium** (22 words)
   The opponent's stadium, studied together on film for two nights. You both know every gust in that building before the bus leaves.
   <sub>toughness +1; charisma -1; intelligence +3; skill_points +1; mods scouted</sub>

<details><summary>Before</summary>

> Your holder wants extra time to work on timing this week.

1. **Extra reps every day**: Snap, hold, kick. Perfect timing.
   <sub>energy -4; accuracy +3; ambition -1; leadership +2; retention +2; skill_points +3; mods dialed_in</sub>

2. **Take a recovery day instead**: Your leg feels brand new.
   <sub>health +5; energy +6; charisma -1; intelligence +1; mods fresh_legs</sub>

3. **Study the opponent's stadium**: You know every gust in that building.
   <sub>toughness +1; charisma -1; intelligence +3; skill_points +1; mods scouted</sub>

</details>

## 8. pro_cold_snap Cold Snap
*health; premise 27 words*

> The forecast says single digits and wind for Sunday. The equipment staff is already unpacking heated benches, and the veterans are wearing shorts to make a point.

1. **Practice outside all week** (21 words)
   Outside, every day, in the freezing wind. Your leg learns the cold, slowly, and so do your fingers, painfully, by Thursday.
   <sub>health -3; toughness +3; ambition +2; leadership -1; skill_points +2; mods scouted</sub>

2. **Practice indoors** (21 words)
   Indoors, warm and accurate all week. You feel great on Thursday, and not at all ready for the wind on Sunday.
   <sub>health +2; accuracy +1; charisma -1; intelligence +1; skill_points +1; mods rested</sub>

3. **Ask the equipment staff for help** (22 words)
   The equipment staff, asked for help. Heated capes, the right cleats and a trick with hand warmers that you'll use for years.
   <sub>toughness +1; charisma -1; intelligence +2; mods confident</sub>

<details><summary>Before</summary>

> Forecast says single digits and wind for Sunday.

1. **Practice outside all week**: Your leg learns the cold.
   <sub>health -3; toughness +3; ambition +2; leadership -1; skill_points +2; mods scouted</sub>

2. **Practice indoors**: Warm and accurate. Not ready for the wind.
   <sub>health +2; accuracy +1; charisma -1; intelligence +1; skill_points +1; mods rested</sub>

3. **Ask the equipment staff for help**: Heated capes and the right cleats.
   <sub>toughness +1; charisma -1; intelligence +2; mods confident</sub>

</details>

## 9. pro_trade_rumors Trade Rumors
*career; premise 26 words*

> Sports radio says the team might trade for another kicker before the deadline. The host has a 'source', and your phone has fourteen messages about it.

1. **Tune out the noise** (21 words)
   Kick, sleep, repeat, and no radio in the car. The noise fades by the deadline, and nobody gets traded for anybody.
   <sub>resilience +1; ambition +2; leadership -1; skill_points +1; mods focused</sub>

2. **Ask the coach directly** (22 words)
   {coach}, asked directly in the hallway. You're the guy, the coach says, for now. 'For now' stays in your head all week.
   <sub>charisma +1; ambition -1; leadership +3; intelligence -1; rel coach +2; retention +2; mods confident</sub>

3. **Read every rumor online** (22 words)
   Every rumor, read online, every single night until two. It's all you think about, and your practices show it clearly by Thursday.
   <sub>fun -4; charisma -1; intelligence +1; mods distracted</sub>

<details><summary>Before</summary>

> Sports radio says the team might trade for another kicker.

1. **Tune out the noise**: Kick, sleep, repeat.
   <sub>resilience +1; ambition +2; leadership -1; skill_points +1; mods focused</sub>

2. **Ask the coach directly**: He says you're his guy. For now.
   <sub>charisma +1; ambition -1; leadership +3; intelligence -1; retention +2; mods confident</sub>

3. **Read every rumor online**: It's all you think about.
   <sub>fun -4; charisma -1; intelligence +1; mods distracted</sub>

</details>

## 10. pro_folder_follows The Folder Follows You
*team; premise 31 words*

> Your first month as a pro, the team's player-development director calls you in. Your college record followed you here, and the club wants to know what kind of player it signed.

1. **Ask for a weekly check-in** (24 words)
   You suggest a weekly check-in yourself and hand over your college coach's number. The director writes it in the file: rookie asked for structure.
   <sub>energy -2; leadership +1; rel coach +3; retention +3; mods focused</sub>

2. **Say college is over** (28 words)
   You say the folder belongs to a different person and you'd rather be judged on what you do here. The director says that's fair. The file stays open.
   <sub>energy +1; fun +1; ambition +2; mods confident</sub>

3. **Bring your own copy** *(locked: having already faced your record honestly)* (30 words)
   You bring a copy of your college record with your own notes in the margins: what happened and what changed. The director keeps it and tells {coach} to stop worrying.
   <sub>energy -3; fun -1; leadership +2; rel coach +4; retention +4; mods confident</sub>

<details><summary>Before</summary>

> Your first month as a pro, the team's player-development director calls you in. Your college record followed you here, and the club wants to know what kind of player it signed.

1. **Ask for a weekly check-in**: You suggest a weekly check-in yourself and hand over your college coach's number. The director writes it in the file: rookie asked for structure.
   <sub>energy -2; leadership +1; rel coach +3; retention +3; mods focused</sub>

2. **Say college is over**: You say the folder belongs to a different person and you'd rather be judged on what you do here. The director says that's fair. The file stays open.
   <sub>energy +1; fun +1; ambition +2; retention -1; mods confident</sub>

3. **Bring your own copy**: You bring a copy of your college record with your own notes in the margins: what happened and what changed. The director keeps it and tells {coach} to stop worrying.
   <sub>energy -3; fun -1; leadership +2; rel coach +4; retention +4; mods confident</sub>

</details>

## 11. pro_old_crowd The Old Crowd (unchanged)
*social; premise 37 words*

> Three guys you used to run with in college show up in your new city on a Friday with a hotel suite booked and a plan for your first paycheck. Your phone has been buzzing since noon.

1. **Dinner, then home** (24 words)
   You buy them dinner, laugh about the old days and are home by ten. They call you boring. You're at the facility at seven.
   <sub>energy -1; fun +1; social +1; retention +2; mods rested</sub>

2. **Don't answer** (22 words)
   You let the phone buzz and stay in. It's lonely, and it's the first weekend in a while you don't regret anything.
   <sub>energy +3; social -2; fun -2; resilience +1; retention +1; mods rested</sub>

3. **Go out with them** (24 words)
   You go out. Saturday's photos end up online, a team official calls on Monday, and {coach} hears about it before you're in the building.
   <sub>fun +5; social +4; energy -6; leadership -1; rel coach -4; retention -4; conduct bad; mods late_night</sub>

## 12. pro_rookie_symposium The Rookie Symposium
*community; premise 33 words*

> The league's rookie symposium wants a player to speak about a mistake from college and what came after. The team's player-development director thinks your story is the one the rookies need to hear.

1. **Tell the whole story** (31 words)
   You stand in front of two hundred rookies and tell them about your worst college year without making yourself the hero. Afterward, a line of players waits to talk to you.
   <sub>energy -3; leadership +3; charisma +2; retention +2; followers +3; mods inspired</sub>

2. **Tell the safe version** (22 words)
   The version with the details smoothed over. It goes fine, the room claps politely, and nobody waits to talk to you afterward.
   <sub>energy -1; fun +2; charisma +1; retention +1; mods focused</sub>

3. **Say no thanks** (25 words)
   No thanks, you'd rather not relive it in front of a room. The director understands and asks someone else, and you wonder about it later.
   <sub>energy +2; fun +1; ambition +1; mods rested</sub>

<details><summary>Before</summary>

> The league's rookie symposium wants a player to speak about a mistake from college and what came after. The team's player-development director thinks your story is the one the rookies need to hear.

1. **Tell the whole story**: You stand in front of two hundred rookies and tell them about your worst college year without making yourself the hero. Afterward, a line of players waits to talk to you.
   <sub>energy -3; leadership +3; charisma +2; retention +2; followers +3; mods inspired</sub>

2. **Tell the safe version**: You give the version with the details smoothed over. It goes fine, and nobody waits afterward.
   <sub>energy -1; fun +2; charisma +1; retention +1; mods focused</sub>

3. **Say no thanks**: You say you'd rather not relive it in front of a room. The director understands and asks someone else.
   <sub>energy +2; fun +1; ambition +1; mods rested</sub>

</details>

## 13. pro_reporters_question The Reporter's Question
*media; premise 28 words*

> At your first open locker room, a beat reporter skips the kicking questions and asks about your college record: 'Do you think the stories about you are fair?'

1. **Answer it straight** (34 words)
   You say the stories are true, you're not proud of them and you'd rather be judged on what comes next. The quote runs in full, and it's the least dramatic thing in the paper.
   <sub>energy -1; charisma +1; leadership +1; retention +2; followers +2; mods confident</sub>

2. **Say no comment** (26 words)
   You say you're only taking football questions. The reporter writes that you 'declined to address' your past, which reads worse than anything you could have said.
   <sub>energy +1; fun +1; mods stressed</sub>

3. **Push back** (29 words)
   You say the stories were overblown and the reporter should do some homework. It's the most-shared clip of the week, and {coach} asks you to stop by the office.
   <sub>fun +2; ambition +2; leadership -1; rel coach -4; followers +6; mods spotlight</sub>

<details><summary>Before</summary>

> At your first open locker room, a beat reporter skips the kicking questions and asks about your college record: 'Do you think the stories about you are fair?'

1. **Answer it straight**: You say the stories are true, you're not proud of them and you'd rather be judged on what comes next. The quote runs in full, and it's the least dramatic thing in the paper.
   <sub>energy -1; charisma +1; leadership +1; retention +2; followers +2; mods confident</sub>

2. **Say no comment**: You say you're only taking football questions. The reporter writes that you 'declined to address' your past, which reads worse than anything you could have said.
   <sub>energy +1; fun +1; retention -1; mods stressed</sub>

3. **Push back**: You say the stories were overblown and the reporter should do some homework. It's the most-shared clip of the week, and {coach} asks you to stop by the office.
   <sub>fun +2; ambition +2; leadership -1; rel coach -4; retention -3; followers +6; mods spotlight</sub>

</details>

## 14. PRO_042 Starting Over (unchanged)
*career; premise 52 words*

> The last club let you go at the end of camp: a ten-minute meeting, a plastic bag for your cleats and a security guard who walked you to the parking lot. Ten days later you're in a stranger's locker room, and the kicker you're replacing still has his name above the stall.

1. **Learn every name by Friday** (32 words)
   You learn every name in the specialists' room by Friday and buy the long snapper lunch. Nobody here owes you anything, and by Sunday a few of them act like they might.
   <sub>energy -2; social +2; rel team +3; mods inspired</sub>

2. **Say nothing and kick** (31 words)
   You keep your head down, kick until the trainers send you in and let the work introduce you. It's lonely. It's also the cleanest practice week you've had in a year.
   <sub>social -2; ambition +1; rel coach +2; skill_points +2; mods dialed_in</sub>

3. **Call {parent} before the first practice** (31 words)
   You call {parent} from the hotel parking lot. He doesn't ask what went wrong; he asks what the new place smells like. You laugh for the first time in ten days.
   <sub>energy +1; fun +2; rel parent +4; mods rested</sub>

4. **Ask {coach} what they heard** *(locked: having taken the long way back)* (31 words)
   You've rebuilt a reputation before. On day one you walk into {coach}'s office and ask what they heard about you at the last club, and you answer every part of it.
   <sub>energy -2; leadership +2; rel coach +4; mods confident</sub>

## 15. PRO_049 Firing Your Agent
*career; premise 37 words*

> Your agent has missed two deadlines this year, including one for a bonus you never saw. Firing an agent means starting over with someone new in the middle of a career, and everyone will hear about it.

1. **Fire your agent** (23 words)
   You send a short letter and make three calls to find someone new. It's awkward for a month and a relief after that.
   <sub>energy -2; leadership +2; ambition +1; mods stressed; flags fired_agent</sub>

2. **Give one last chance** (21 words)
   You sit down with your agent and lay out exactly what has to change. Things get better for a season, mostly.
   <sub>energy -1; charisma +1; intelligence +1; mods focused</sub>

3. **Stay and say nothing** (26 words)
   A bad agent you know beats a new one you don't, you decide. The next deadline gets missed too, and you find out from a teammate.
   <sub>energy +1; fun +1; ambition -1; mods distracted</sub>

<details><summary>Before</summary>

> Your agent has missed two deadlines this year, including one for a bonus you never saw. Firing an agent means starting over with someone new in the middle of a career.

1. **Fire your agent**: You send a short letter and make three calls to find someone new. It's awkward for a month and a relief after that.
   <sub>energy -2; leadership +2; ambition +1; mods stressed; flags fired_agent</sub>

2. **Give one last chance**: You sit down with your agent and lay out exactly what has to change. Things get better for a season, mostly.
   <sub>energy -1; charisma +1; intelligence +1; mods focused</sub>

3. **Stay and say nothing**: You decide a bad agent you know beats a new one you don't. The next deadline gets missed too.
   <sub>energy +1; fun +1; ambition -1; retention -1; mods distracted</sub>

</details>

## 16. PRO_059 The Missing Money
*money; premise 32 words*

> Your bank calls on a Tuesday morning: a transfer you didn't authorize, the third one this year. The advisor with the boat isn't answering, and his office number goes to a recording.

1. **Call a lawyer before practice** (32 words)
   You make the calls in the parking lot. By Friday the accounts are frozen, a forensic accountant is on it, and you know the number: four of every ten dollars you've earned.
   <sub>energy -3; fun -3; resilience +1; intelligence +2; leadership +1; mods stressed; flags advisor_stole</sub>

2. **Call {parent}** (37 words)
   You call {parent} and say the number out loud. He's quiet for a long time, then tells you about the year he lost his job and what he did the next morning. You write it all down.
   <sub>energy -1; fun -2; charisma +1; rel parent +5; mods stressed; flags advisor_stole</sub>

3. **Keep it quiet and fix it yourself** (29 words)
   You tell nobody, including the three teammates he also manages. You tell them everything's fine, which is a lie, and spend the season doing math in the training room.
   <sub>energy -4; fun -1; ambition +2; rel team -3; mods distracted; flags advisor_stole, hid_the_loss</sub>

4. **Call your agent first** *(locked: having hired an agent who tells you the truth)* (33 words)
   Your agent has seen this before. Within an hour you have a lawyer, an accountant and a plan, and a warning to call the other three players he manages before the news does.
   <sub>energy -2; fun -2; intelligence +1; leadership +1; rel team +2; mods stressed; flags advisor_stole</sub>

<details><summary>Before</summary>

> Your bank calls on a Tuesday morning: a transfer you didn't authorize, the third one this year. The advisor with the boat isn't answering, and his office number goes to a recording.

1. **Call a lawyer before practice**: You make the calls in the parking lot. By Friday the accounts are frozen, a forensic accountant is on it, and you know the number: four of every ten dollars you've earned.
   <sub>energy -3; fun -3; intelligence +2; retention -1; mods stressed; flags advisor_stole</sub>

2. **Call {parent}**: You call {parent} and say the number out loud. He's quiet for a long time, then tells you about the year he lost his job and what he did the next morning. You write it all down.
   <sub>energy -1; fun -2; charisma +1; rel parent +5; retention -2; mods stressed; flags advisor_stole</sub>

3. **Keep it quiet and fix it yourself**: You tell nobody, including the three teammates he also manages. You tell them everything's fine, which is a lie, and spend the season doing math in the training room.
   <sub>energy -4; fun -1; ambition +2; rel team -3; retention -1; mods distracted; flags advisor_stole, hid_the_loss</sub>

4. **Call your agent first**: Your agent has seen this before. Within an hour you have a lawyer, an accountant and a plan, and a warning to call the other three players he manages before the news does.
   <sub>energy -2; fun -2; intelligence +1; leadership +1; rel team +2; retention -1; mods stressed; flags advisor_stole</sub>

</details>

## 17. PRO_060 The Lawsuit
*money; premise 31 words*

> Your lawyer says you can sue the advisor who took your money. It'll take three years, cost a fortune in fees, and your name will be in every story about it.

1. **Sue him** (25 words)
   You file. The case drags on for years, you testify twice, and some of the money comes back long after you've stopped counting on it.
   <sub>energy -3; fun -2; leadership +1; ambition +1; intelligence +1; followers -1; mods stressed; flags sued_advisor</sub>

2. **Report him and move on** (25 words)
   You file the report with the regulators and let them handle it. He's barred from the business a year later. You never see a dime.
   <sub>energy -1; intelligence +1; mods focused</sub>

3. **Join with the other players** (24 words)
   You call the three teammates he also handled. Together you hire one lawyer and split the bill. It's slower, and nobody faces it alone.
   <sub>energy -2; social +2; leadership +2; rel team +3; mods inspired; flags sued_advisor</sub>

<details><summary>Before</summary>

> Your lawyer says you can sue the advisor who took your money. It'll take three years, and your name will be in every story.

1. **Sue him**: You file. The case drags on for years, you testify twice, and some of the money comes back long after you've stopped counting on it.
   <sub>energy -3; fun -2; leadership +1; ambition +1; intelligence +1; followers -1; mods stressed; flags sued_advisor</sub>

2. **Report him and move on**: You file the report with the regulators and let them handle it. He's barred from the business a year later. You never see a dime.
   <sub>energy -1; intelligence +1; mods focused</sub>

3. **Join with the other players**: You call the three teammates he also handled. Together you hire one lawyer and split the bill. It's slower, and nobody faces it alone.
   <sub>energy -2; social +2; leadership +2; rel team +3; mods inspired; flags sued_advisor</sub>

</details>

## 18. PRO_062 The Restaurant Is Failing
*money; premise 25 words*

> The steakhouse is losing money every week. The chef quit, your old teammate isn't answering, and your name is still lit up over the door.

1. **Close it now** (24 words)
   You close it, pay the staff two weeks' wages from your own pocket and take your name down yourself. It hurts, and it's over.
   <sub>fun -2; energy -1; leadership +2; charisma +1; mods drained; flags bad_venture</sub>

2. **Put more money in** (24 words)
   Another check, to keep it open one more season. The food gets better, the reviews get kinder, and the losses don't change at all.
   <sub>fun +1; ambition +1; intelligence -1; mods stressed; flags bad_venture</sub>

3. **Sell your share to your partner** (23 words)
   You sell your share to your old teammate for whatever he can pay. You lose most of it and keep the friendship, barely.
   <sub>social +1; intelligence +1; mods focused; flags bad_venture</sub>

4. **Let your advisor run the exit** *(locked: having an advisor you trust)* (25 words)
   Your advisor finds a buyer for the lease and the equipment within a month. You lose money, but a lot less than you would have.
   <sub>energy -1; intelligence +2; mods focused; flags bad_venture</sub>

<details><summary>Before</summary>

> The steakhouse is losing money every week. The chef quit, your old teammate isn't answering, and your name is still lit up over the door.

1. **Close it now**: You close it, pay the staff two weeks' wages from your own pocket and take your name down yourself. It hurts, and it's over.
   <sub>fun -2; energy -1; leadership +2; charisma +1; mods drained; flags bad_venture</sub>

2. **Put more money in**: You write another check to keep it open one more season. The food gets better. The losses don't.
   <sub>fun +1; ambition +1; intelligence -1; mods stressed; flags bad_venture</sub>

3. **Sell your share to your partner**: You sell your share to your old teammate for whatever he can pay. You lose most of it and keep the friendship, barely.
   <sub>social +1; intelligence +1; mods focused; flags bad_venture</sub>

4. **Let your advisor run the exit**: Your advisor finds a buyer for the lease and the equipment within a month. You lose money, but a lot less than you would have.
   <sub>energy -1; intelligence +2; mods focused; flags bad_venture</sub>

</details>

## 19. PRO_065 The Start-Up Calls
*money; premise 31 words*

> {best_friend}'s company is close: one more check and they make it to the next stage, or they fold this month. They call you late at night, trying hard not to ask.

1. **Write the last check** (26 words)
   You write it. Six months later the company is bought, and your share turns into the best investment of your life. {best_friend} cries on the phone.
   <sub>fun +3; ambition +1; rel best_friend +8; mods inspired</sub>

2. **Hold the line** (29 words)
   You don't put in more. The company makes it anyway with someone else's money, and your share is smaller than it could have been. You're still glad for them.
   <sub>energy +1; intelligence +1; rel best_friend +2; mods focused</sub>

3. **Help them find another investor** (22 words)
   Two people from the owner's gala, introduced to {best_friend} by you over coffee. One of them writes the check within a week.
   <sub>energy -2; social +2; charisma +1; leadership +1; rel best_friend +6; mods focused</sub>

4. **Ask your advisor to look first** *(locked: having an advisor you trust)* (22 words)
   Your advisor reads the numbers and says this one is real. You write the check with your eyes open, and it pays.
   <sub>energy -1; fun +2; intelligence +1; rel best_friend +6; mods confident</sub>

<details><summary>Before</summary>

> {best_friend}'s company is close: one more check and they make it to the next stage, or they fold this month.

1. **Write the last check**: You write it. Six months later the company is bought, and your share turns into the best investment of your life. {best_friend} cries on the phone.
   <sub>fun +3; ambition +1; rel best_friend +8; mods inspired</sub>

2. **Hold the line**: You don't put in more. The company makes it anyway with someone else's money, and your share is smaller than it could have been. You're still glad for them.
   <sub>energy +1; intelligence +1; rel best_friend +2; mods focused</sub>

3. **Help them find another investor**: You introduce {best_friend} to two people from the owner's gala. One of them writes the check.
   <sub>energy -2; social +2; charisma +1; leadership +1; rel best_friend +6; mods focused</sub>

4. **Ask your advisor to look first**: Your advisor reads the numbers and says this one is real. You write the check with your eyes open, and it pays.
   <sub>energy -1; fun +2; intelligence +1; rel best_friend +6; mods confident</sub>

</details>

## 20. PRO_074 The Proposal
*romance; premise 25 words*

> You've carried a ring around in your gym bag for three weeks, waiting for a right moment that never seems to come during a season.

1. **Ask tonight** (26 words)
   You stop waiting for the perfect moment and ask in the kitchen, still in your practice clothes. {love_interest} laughs, cries and says yes, in that order.
   <sub>fun +4; social +1; charisma +1; rel love_interest +8; mods inspired; flags engaged</sub>

2. **Ask {parent} first** (28 words)
   You call {parent} first, which nobody does anymore. He's quiet, then tells you how he asked your mother. You propose that weekend with his story in your head.
   <sub>fun +2; energy -1; leadership +1; rel love_interest +6; rel parent +4; mods inspired; flags engaged</sub>

3. **Wait until you're sure** (22 words)
   The ring goes back in the bag for another month. You're not ready, and you think {love_interest} can tell that something's different.
   <sub>energy +1; ambition +1; rel love_interest -3; skill_points +1; mods distracted</sub>

<details><summary>Before</summary>

> You've carried a ring around in your gym bag for three weeks, waiting for a right moment that never seems to come during a season.

1. **Ask tonight**: You stop waiting for the perfect moment and ask in the kitchen, still in your practice clothes. {love_interest} laughs, cries and says yes, in that order.
   <sub>fun +4; social +1; charisma +1; rel love_interest +8; mods inspired; flags engaged</sub>

2. **Ask {parent} first**: You call {parent} first, which nobody does anymore. He's quiet, then tells you how he asked your mother. You propose that weekend with his story in your head.
   <sub>fun +2; energy -1; leadership +1; rel love_interest +6; rel parent +4; mods inspired; flags engaged</sub>

3. **Wait until you're sure**: You put the ring back in the bag. You're not ready, and you think {love_interest} can tell something's different.
   <sub>energy +1; ambition +1; rel love_interest -3; skill_points +1; mods distracted</sub>

</details>

## 21. PRO_075 The Wedding
*family; premise 27 words*

> The wedding is this offseason. The guest list is a fight: {parent} wants half your hometown, {love_interest} wants forty people, and your agent wants a magazine there.

1. **Forty people, no cameras** (21 words)
   Forty people and no cameras, in a garden. {parent} grumbles for a week beforehand and then dances until midnight with everyone.
   <sub>fun +3; social +1; leadership +1; rel love_interest +8; rel parent -1; mods inspired; flags married</sub>

2. **Invite the whole town** (20 words)
   You invite everyone. It's loud, enormous and a little out of control, and your hometown talks about it for years.
   <sub>fun +4; social +3; energy -3; charisma +1; rel parent +5; rel love_interest +2; mods loose; flags married</sub>

3. **Let the magazine in** (20 words)
   You let the magazine shoot it. The photos are beautiful and everywhere, and some of the day belongs to strangers.
   <sub>fun +2; social +1; charisma +2; rel love_interest -2; followers +6; mods spotlight; flags married</sub>

<details><summary>Before</summary>

> The wedding is this offseason. The guest list is a fight: {parent} wants half your hometown, {love_interest} wants forty people, and your agent wants a magazine there.

1. **Forty people, no cameras**: You keep it to forty people and no cameras. {parent} grumbles for a week and then dances until midnight.
   <sub>fun +3; social +1; leadership +1; rel love_interest +8; rel parent -1; mods inspired; flags married</sub>

2. **Invite the whole town**: You invite everyone. It's loud, enormous and a little out of control, and your hometown talks about it for years.
   <sub>fun +4; social +3; energy -3; charisma +1; rel parent +5; rel love_interest +2; mods loose; flags married</sub>

3. **Let the magazine in**: You let the magazine shoot it. The photos are beautiful and everywhere, and some of the day belongs to strangers.
   <sub>fun +2; social +1; charisma +2; rel love_interest -2; followers +6; mods spotlight; flags married</sub>

</details>

## 22. PRO_076 The Due Date
*family; premise 29 words*

> The baby is due the same week as a road game across the country, and {coach} has already asked, gently, what your plan is. {love_interest} hasn't asked at all.

1. **Stay home for the birth** (24 words)
   You tell {coach} you're staying home, whatever it costs. You're there when the baby arrives, and you'd make the same call a hundred times.
   <sub>fun +4; energy -3; leadership +1; rel love_interest +8; rel coach -2; mods inspired; flags became_parent</sub>

2. **Fly out and fly back** (29 words)
   You fly out for the game and take the first flight home. You miss the birth by four hours and meet your kid in a hospital hallway at dawn.
   <sub>energy -5; fun +1; ambition +2; rel love_interest -4; rel coach +2; skill_points +2; mods drained; flags became_parent</sub>

3. **Ask {coach} for a plan** (26 words)
   You sit down with {coach} and work out a plan: a phone in the trainer's pocket and a jet on standby. It's complicated, and it works.
   <sub>energy -3; fun +2; intelligence +1; charisma +1; rel love_interest +4; rel coach +3; mods focused; flags became_parent</sub>

<details><summary>Before</summary>

> The baby is due the same week as a road game across the country, and {coach} has already asked what your plan is.

1. **Stay home for the birth**: You tell {coach} you're staying home, whatever it costs. You're there when the baby arrives, and you'd make the same call a hundred times.
   <sub>fun +4; energy -3; leadership +1; rel love_interest +8; rel coach -2; retention -1; mods inspired; flags became_parent</sub>

2. **Fly out and fly back**: You fly out for the game and take the first flight home. You miss the birth by four hours and meet your kid in a hospital hallway at dawn.
   <sub>energy -5; fun +1; ambition +2; rel love_interest -4; rel coach +2; skill_points +2; mods drained; flags became_parent</sub>

3. **Ask {coach} for a plan**: You sit down with {coach} and work out a plan: a phone in the trainer's pocket and a jet on standby. It's complicated, and it works.
   <sub>energy -3; fun +2; intelligence +1; charisma +1; rel love_interest +4; rel coach +3; mods focused; flags became_parent</sub>

</details>

## 23. PRO_124 The Team Fine (unchanged)
*team; premise 28 words*

> The club fines you and calls you in. {coach} is in the room, and so is the general manager, who has a folder with your name on it.

1. **Own it** (26 words)
   You don't explain it away. You say what happened, what you'll change and who can hold you to it. The general manager closes the folder early.
   <sub>energy -2; social -1; leadership +2; rel coach +2; retention -1; mods drained; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (21 flags)</sub>

2. **Explain it away** (26 words)
   You explain why it wasn't really your fault. The general manager listens to all of it and writes one word at the top of the page.
   <sub>energy +1; ambition +1; leadership -2; rel coach -4; retention -3; mods stressed; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

3. **Say you've been here before** *(locked: having owned a mistake before)* (26 words)
   You tell them you've sat in a room like this in college and what you did after. {coach} nods slowly. The fine stands. The tone changes.
   <sub>energy -2; fun -2; leadership +2; charisma +1; rel coach +4; retention -1; mods confident; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (21 flags)</sub>

## 24. PRO_125 League Discipline
*team; premise 33 words*

> The league office wants a meeting about the strike on your record. It isn't a conversation; it's a hearing, in a gray room, with a lawyer from the players' union at your side.

1. **Accept the suspension** (24 words)
   You accept two games and don't appeal. You practice with the scout team, and the veterans notice that you show up every day anyway.
   <sub>energy -2; fun -3; leadership +2; rel team +2; retention -2; suspend_weeks +2; conduct bad; mods drained; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

2. **Fight it** (30 words)
   You appeal and say the league is making an example of you. The appeal fails, the suspension stands, and now the whole league knows your name for the wrong reason.
   <sub>fun -2; ambition +2; leadership -2; rel coach -6; retention -4; followers -3; suspend_weeks +2; conduct scandal; mods stressed; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (21 flags)</sub>

<details><summary>Before</summary>

> The league office wants a meeting. It isn't a conversation; it's a hearing, with a lawyer from the players' union at your side.

1. **Accept the suspension**: You accept two games and don't appeal. You practice with the scout team, and the veterans notice that you show up every day anyway.
   <sub>energy -2; fun -3; leadership +2; rel team +2; retention -2; suspend_weeks +2; conduct bad; mods drained; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

2. **Fight it**: You appeal and say the league is making an example of you. The appeal fails, the suspension stands, and now the whole league knows your name for the wrong reason.
   <sub>fun -2; ambition +2; leadership -2; rel coach -6; retention -4; followers -3; suspend_weeks +2; conduct scandal; mods stressed; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (21 flags)</sub>

</details>

## 25. PRO_126 The Last Warning, Pro (unchanged)
*team; premise 26 words*

> With {coach} beside the desk, the general manager says it plainly: one more, and you're done here. Then a list of conditions slides across the table.

1. **Accept every condition** (30 words)
   Early workouts, no nights out on the road, weekly check-ins. You sign the list. It costs you a lot of the season, and nobody has to wonder about you again.
   <sub>energy -5; fun -4; leadership +2; rel coach +4; retention -2; mods drained; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

2. **Push back** (28 words)
   You say the conditions are too much for what happened. The general manager ends the meeting. By Friday, every reporter covering the team has heard the word 'problem'.
   <sub>energy +1; fun +1; ambition +2; leadership -3; rel coach -10; rel team -3; retention -5; conduct scandal; mods stressed; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

3. **Say you've heard this speech before** *(locked: having had a last chance in college)* (32 words)
   You tell them you got this exact speech in college, and that you kept the promise for two years. You sign the list. {coach} believes you more than the general manager does.
   <sub>energy -5; fun -4; social -2; leadership +2; charisma +1; rel coach +6; retention -2; mods drained; flags -stayed_out_pro, -pro_night_out, -pro_unapproved_supplement, -pro_bar_fight ... (20 flags)</sub>

## 26. PRO_128 Earning It Back
*team; premise 29 words*

> You have a reputation in the league now. {coach} offers a way back: six a.m. workouts, a mentor from the players' union and no excuses for a full season.

1. **Take every hour of it** (32 words)
   You're there at six every day for a season, and your name stays out of every story. In the spring, {coach} tells a reporter you're not the same player, and means it.
   <sub>energy -6; fun -3; leadership +3; rel coach +8; rel team +4; retention +4; conduct good; mods tired; flags pro_rebuilt_reputation, -pro_character_concerns</sub>

2. **Do the minimum** (23 words)
   The workouts you can't skip, and nothing more. Nothing new goes wrong, nothing much changes, and the reputation stays exactly where it was.
   <sub>energy -2; ambition +1; rel coach -2; mods focused</sub>

3. **Say you've paid enough** (22 words)
   You say you served your suspension and don't need a program. {coach} closes the folder. It's the last offer you get here.
   <sub>energy +2; fun +2; ambition +2; leadership -2; rel coach -8; retention -3; mods stressed</sub>

<details><summary>Before</summary>

> You have a reputation in the league now. {coach} offers a way back: six a.m. workouts, a mentor from the players' union and no excuses for a full season.

1. **Take every hour of it**: You're there at six every day for a season, and your name stays out of every story. In the spring, {coach} tells a reporter you're not the same player, and means it.
   <sub>energy -6; fun -3; leadership +3; rel coach +8; rel team +4; retention +4; conduct good; mods tired; flags pro_rebuilt_reputation, -pro_character_concerns</sub>

2. **Do the minimum**: You do the workouts you can't skip. Nothing new goes wrong, nothing changes, and the reputation stays.
   <sub>energy -2; ambition +1; rel coach -2; mods focused</sub>

3. **Say you've paid enough**: You say you served your suspension and don't need a program. {coach} closes the folder. It's the last offer you get here.
   <sub>energy +2; fun +2; ambition +2; leadership -2; rel coach -8; retention -3; mods stressed</sub>

</details>

## 27. PRO_129 The League's Counselor
*health; premise 31 words*

> The league assigns you a counselor after the hearing. The first session is Tuesday at four, in a beige office near the airport, with a box of tissues on the table.

1. **Go and actually talk** (26 words)
   You go every week and actually talk. Some of it is about the incidents. Most of it isn't, and that turns out to be the point.
   <sub>energy -1; health +2; intelligence +1; leadership +1; retention +1; mods focused</sub>

2. **Go and say nothing** (23 words)
   You go every week and say as little as possible. You check the box, and the counselor writes that you checked the box.
   <sub>energy +1; ambition +1; mods distracted</sub>

3. **Bring the hard question** (27 words)
   In the first session you ask the question you've been avoiding: why it keeps happening. You don't get an answer that day. You get a better question.
   <sub>energy -2; fun -1; resilience +1; intelligence +2; retention +1; mods drained</sub>

<details><summary>Before</summary>

> The league assigns you a counselor after the hearing. The first session is Tuesday, in a beige office near the airport.

1. **Go and actually talk**: You go every week and actually talk. Some of it is about the incidents. Most of it isn't, and that turns out to be the point.
   <sub>energy -1; health +2; intelligence +1; leadership +1; retention +1; mods focused</sub>

2. **Go and say nothing**: You go every week and say as little as possible. You check the box, and the counselor writes that you checked the box.
   <sub>energy +1; ambition +1; mods distracted</sub>

3. **Bring the hard question**: In the first session you ask the question you've been avoiding: why it keeps happening. You don't get an answer that day. You get a better question.
   <sub>energy -2; fun -1; resilience +1; intelligence +2; retention +1; mods drained</sub>

</details>

## 28. PRO_130 A Clean Year
*team; premise 31 words*

> A full year without a fine, a headline or a hearing. The general manager stops by your locker on the last day of the season and says nothing, just nods, twice.

1. **Thank the people who held you to it** (23 words)
   You thank {coach}, the union mentor and the teammate who drove you to the early workouts. Saying it out loud makes it real.
   <sub>social +2; charisma +1; leadership +1; rel coach +4; rel team +2; mods inspired</sub>

2. **Keep it to yourself** (20 words)
   You keep it quiet and keep going. The best part of a clean year is that nobody talks about it.
   <sub>energy +2; ambition +1; skill_points +1; mods rested</sub>

3. **Help a rookie who's slipping** (24 words)
   A rookie making your old mistakes gets a breakfast invitation from you, and the whole story, start to finish. He listens to every word.
   <sub>energy -2; social +1; leadership +3; rel team +3; mods inspired</sub>

<details><summary>Before</summary>

> A full year without a fine, a headline or a hearing. The general manager stops by your locker and says nothing, just nods.

1. **Thank the people who held you to it**: You thank {coach}, the union mentor and the teammate who drove you to the early workouts. Saying it out loud makes it real.
   <sub>social +2; charisma +1; leadership +1; rel coach +4; rel team +2; mods inspired</sub>

2. **Keep it to yourself**: You keep it quiet and keep going. The best part of a clean year is that nobody talks about it.
   <sub>energy +2; ambition +1; skill_points +1; mods rested</sub>

3. **Help a rookie who's slipping**: There's a rookie making your old mistakes. You take him to breakfast and tell him the whole story.
   <sub>energy -2; social +1; leadership +3; rel team +3; mods inspired</sub>

</details>

## 29. PRO_151 Love Again (unchanged)
*romance; premise 36 words*

> You're single in a new city. Then, at a teammate's birthday dinner, the person across the table asks a question about you instead of the league, and you're still talking when the restaurant starts stacking chairs.

1. **Ask to see them again** (27 words)
   A second dinner turns into a Sunday walk, then into a toothbrush at your place. It's new and easy, and you catch yourself smiling in film sessions.
   <sub>fun +2; social +2; charisma +1; recast love_interest; mods inspired; flags new_partner, -enjoying_single_life, -made_long_distance_work, -committed_to_relationship</sub>

2. **Enjoy being single** (27 words)
   Single, for now, on purpose. You cook badly for friends, sleep in on off days and answer to nobody, and it's the lightest you've felt since college.
   <sub>fun +3; energy +2; rel best_friend +2; mods rested; flags enjoying_single_life</sub>

3. **Keep the season first** (25 words)
   A friendly goodbye at the door, and nothing more. The season gets all of you, and some nights the apartment is very quiet after film.
   <sub>energy +1; resilience +1; ambition +2; skill_points +1; mods dialed_in</sub>

4. **Ask the classmate to come** *(locked: having dated your college classmate)* (32 words)
   The classmate from statistics, the standing Thursday nights: you call and ask them to move here. They say yes before you finish the question, and the apartment finally sounds like a home.
   <sub>social +2; fun +2; leadership +1; recast love_interest; mods inspired; flags new_partner, -enjoying_single_life, -made_long_distance_work, -committed_to_relationship</sub>

## 30. PRO_156 The Hotel Bar (unchanged)
*romance; premise 40 words*

> After a road game, the team hotel's bar. She has been talking to you for an hour, laughs at the right moments and doesn't want the night to end. Your phone buzzes on the bar: a goodnight text from {love_interest}.

1. **Walk away and call home** (30 words)
   You say goodnight, pay the tab and take the elevator up alone. You call {love_interest} back from the hallway, and the two of you talk until you're both half asleep.
   <sub>energy +1; fun -1; social -1; rel love_interest +4; mods rested</sub>

2. **Tell {love_interest} what happened** (33 words)
   You go upstairs and tell {love_interest} about the hour at the bar and what was offered. It's an uncomfortable call. At the end of it, {love_interest} says thank you for telling the truth.
   <sub>energy -1; fun -2; charisma +1; leadership +1; rel love_interest +6; mods drained</sub>

3. **Leave the bar together** (39 words)
   You leave the bar together. The next morning you're on the team bus with your phone face down in your lap, three unanswered texts from home, and a teammate who saw everything looking at you a second too long.
   <sub>fun +4; social +2; energy -3; leadership -1; rel love_interest -12; rel team -2; retention -2; conduct bad; mods distracted; flags pro_cheated</sub>

## 31. PRO_160 Found Out
*romance; premise 29 words*

> {love_interest} has your phone in one hand and a question in the other, and it isn't really a question. The screen is still lit, and neither of you moves.

1. **Tell the whole truth** (30 words)
   You tell the truth: the night, the hotel, all of it. {love_interest} goes very quiet and leaves for a friend's place. Two days later, a text: 'I'm not done talking.'
   <sub>energy -3; fun -3; leadership +2; charisma +1; rel love_interest -8; mods drained; flags confessed_affair</sub>

2. **Lie** (25 words)
   You say it isn't what it looks like and keep saying it until {love_interest} stops asking. It works, for now. It always works for now.
   <sub>energy +1; ambition +1; leadership -2; rel love_interest -2; mods stressed; flags lied_about_affair</sub>

<details><summary>Before</summary>

> {love_interest} has your phone in one hand and a question in the other, and it isn't really a question.

1. **Tell the whole truth**: You tell the truth: the night, the hotel, all of it. {love_interest} goes very quiet and leaves for a friend's place. Two days later, a text: 'I'm not done talking.'
   <sub>energy -3; fun -3; leadership +2; charisma +1; rel love_interest -8; mods drained; flags confessed_affair</sub>

2. **Lie**: You say it isn't what it looks like and keep saying it until {love_interest} stops asking. It works, for now. It always works for now.
   <sub>energy +1; ambition +1; leadership -2; rel love_interest -2; mods stressed; flags lied_about_affair</sub>

</details>

## 32. PRO_161 The Lie Comes Out
*romance; premise 26 words*

> The story you told {love_interest} has just fallen apart, in a text from someone you've never met, with screenshots, at eleven o'clock on a Tuesday night.

1. **Ask for one more chance** (22 words)
   You ask for one more chance and promise everything you can think of. {love_interest} doesn't say yes, and doesn't leave. Not yet.
   <sub>energy -3; fun -3; charisma +1; rel love_interest -6; mods drained; flags affair_public</sub>

2. **Let them go** (29 words)
   You don't argue. You help pack the car and stand in the driveway after it leaves. It's the worst week of your life, and you know you earned it.
   <sub>fun -4; social -2; leadership +1; intelligence +1; rel love_interest -10; mods drained; flags affair_public, broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

3. **Blame them** (22 words)
   You say it happened because they were never around. It's cruel, it isn't true, and you know it while you're saying it.
   <sub>fun -2; ambition +1; leadership -2; charisma -1; rel love_interest -15; conduct bad; mods stressed; flags affair_public, broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

<details><summary>Before</summary>

> The story you told {love_interest} has just fallen apart, in a text from someone you've never met, with screenshots.

1. **Ask for one more chance**: You ask for one more chance and promise everything you can think of. {love_interest} doesn't say yes, and doesn't leave. Not yet.
   <sub>energy -3; fun -3; charisma +1; rel love_interest -6; mods drained; flags affair_public</sub>

2. **Let them go**: You don't argue. You help pack the car and stand in the driveway after it leaves. It's the worst week of your life, and you know you earned it.
   <sub>fun -4; social -2; leadership +1; intelligence +1; rel love_interest -10; mods drained; flags affair_public, broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

3. **Blame them**: You say it happened because they were never around. It's cruel, it isn't true, and you know it while you're saying it.
   <sub>fun -2; ambition +1; leadership -2; charisma -1; rel love_interest -15; conduct bad; mods stressed; flags affair_public, broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

</details>

## 33. PRO_162 Starting Over, Together
*romance; premise 29 words*

> {love_interest} agrees to see a counselor with you. The first session is Thursday, in a quiet room with two chairs, and the counselor asks who wants to go first.

1. **Go first, every week** (24 words)
   You go first, every week, for six months. Some sessions are worse than the night itself. Slowly, you start to recognize each other again.
   <sub>energy -3; fun -2; leadership +1; intelligence +1; rel love_interest +8; mods drained; flags repaired_relationship</sub>

2. **Go a few times, then stop** (21 words)
   You go three times and then say practice is too busy. It's true, and you both know it isn't the reason.
   <sub>energy +1; ambition +1; rel love_interest -4; skill_points +1; mods distracted</sub>

3. **Agree it's over** (23 words)
   After the second session you both say what neither wanted to: it's over. You end it as kindly as two hurt people can.
   <sub>fun -3; social -1; intelligence +1; charisma +1; rel love_interest -2; mods drained; flags broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

<details><summary>Before</summary>

> {love_interest} agrees to see a counselor with you. The first session is Thursday, and the counselor asks who wants to go first.

1. **Go first, every week**: You go first, every week, for six months. Some sessions are worse than the night itself. Slowly, you start to recognize each other again.
   <sub>energy -3; fun -2; leadership +1; intelligence +1; rel love_interest +8; mods drained; flags repaired_relationship</sub>

2. **Go a few times, then stop**: You go three times and then say practice is too busy. It's true, and you both know it isn't the reason.
   <sub>energy +1; ambition +1; rel love_interest -4; skill_points +1; mods distracted</sub>

3. **Agree it's over**: After the second session you both say what neither wanted to: it's over. You end it as kindly as two hurt people can.
   <sub>fun -3; social -1; intelligence +1; charisma +1; rel love_interest -2; mods drained; flags broke_up_pro, -made_long_distance_work, -committed_to_relationship, -new_partner, -engaged</sub>

</details>

## 34. PRO_163 The Divorce (unchanged)
*family; premise 30 words*

> The lawyers have the paperwork ready on the kitchen table. {love_interest} wants to talk before anyone signs anything, and for the first time in months, neither of you is angry.

1. **Sign it, and be kind** (36 words)
   You sign it together and make the hard parts fair: the house, the holidays, the friends. It hurts for a long time, {parent} calls every night that month, and you're proud of how you did it.
   <sub>fun -3; social -1; resilience +1; leadership +2; rel love_interest +3; rel parent +2; mods drained; flags divorced, -married, -engaged, -new_partner, -made_long_distance_work, -committed_to_relationship</sub>

2. **Fight over everything** (28 words)
   Every chair, every account, every weekend becomes a fight through lawyers. It takes a year, costs a fortune and leaves you both strangers who used to be married.
   <sub>fun -4; energy -3; toughness +1; ambition +1; rel love_interest -6; rel parent -2; mods stressed; flags divorced, -married, -engaged, -new_partner, -made_long_distance_work, -committed_to_relationship</sub>

3. **Ask for one more try** (28 words)
   One more try, you ask, with a counselor and no secrets. {love_interest} takes a long breath and agrees to six months. The papers go back in the drawer.
   <sub>energy -2; social +1; charisma +1; intelligence +1; rel love_interest +4; mods focused</sub>

## 35. PRO_164 The Package (unchanged)
*health; premise 36 words*

> A trainer from the private gym you used last summer leaves a package in your locker: a banned substance, a note promising it can't be detected, and his phone number. Two veterans saw him walk out.

1. **Take it to the team doctor** (51 words)
   You carry the package, unopened, to the team doctor's office and set it on the desk. The doctor makes two calls, the league's testing office makes one more, and by Friday the trainer's name is on a list. Two veterans stop you in the hallway to say they'd wondered who would.
   <sub>energy -1; leadership +2; intelligence +1; rel coach +3; rel team +2; retention +1; conduct good; mods focused; flags reported_package</sub>

2. **Call the league's confidential line** (31 words)
   You call the confidential line from your car and drop the package at the testing office the next morning. Nobody on the team knows it was you, and nobody needs to.
   <sub>fun +1; intelligence +1; retention +1; conduct good; mods rested; flags reported_package</sub>

3. **Throw it away and block his number** (31 words)
   You drop it in the dumpster behind the facility and block his number. It's gone, and so is any chance of stopping him before he tries the rookie two lockers down.
   <sub>energy +1; fun +1; ambition +1; rel team -1; mods rested</sub>

4. **Keep it and say nothing** (31 words)
   You put the package in your gym bag and tell no one. A week later the league's testers show up unannounced on a Tuesday morning, and they ask for you first.
   <sub>fun +1; energy +2; ambition +2; intelligence -1; retention -2; conduct bad; mods stressed; flags pro_banned_substance</sub>

## 36. PRO_171 The Bookie (unchanged)
*money; premise 43 words*

> An old friend from home introduces you to a man who takes bets on everything, including football and including your own team's games. He mentions, casually, that he'd pay well for a heads-up on who's really hurt before the injury report comes out.

1. **Walk away and call the integrity line** (38 words)
   You leave before the food comes and call the league's integrity line from the parking lot. Your friend doesn't speak to you for a month. Three weeks later the man is in the news, for someone else's mistake.
   <sub>social -2; leadership +2; intelligence +1; rel coach +2; retention +1; conduct good; mods focused; flags reported_bookie</sub>

2. **Say no and leave it there** (26 words)
   You say you're not interested, keep it polite and never go back. You don't report it, and you think about that more than you expected to.
   <sub>energy +1; social +1; charisma +1; mods distracted</sub>

3. **Bet on your own team, once** (36 words)
   You put money on your own team to win, just once, because what could be cleaner than betting on yourself? Two months later a league investigator slides a printout of your account across a conference table.
   <sub>fun +3; ambition +2; intelligence -2; rel coach -6; rel team -3; retention -4; followers -4; conduct scandal; mods stressed; flags pro_betting_scandal</sub>

## 37. PRO_173 The Spa (unchanged)
*social; premise 44 words*

> On a road trip, a client of your agent's insists you come with him to a spa he swears by. In the waiting room he makes it clear that the 'extras' are the point, and two other players are already at the front desk.

1. **Leave and book the team's therapist** (33 words)
   You say you're good, walk out and text the team's massage therapist for a real session in the morning. Your hamstring feels better by Thursday, and there's nothing to remember about the night.
   <sub>health +3; fun -1; intelligence +1; mods rested</sub>

2. **Tell him it isn't for you** (38 words)
   You tell him plainly it isn't for you, and that he might want to think twice too. He laughs it off. On the bus home he sits somewhere else, and one of the other players nods at you.
   <sub>social -1; leadership +2; rel team +1; mods confident</sub>

3. **Pay at the front desk** (39 words)
   You pay at the front desk. Two weeks later a detective calls your agent: the spa was part of a police investigation, your name is on a client list, and a reporter has already asked the club for comment.
   <sub>fun +1; energy +1; leadership -2; intelligence -2; rel coach -5; rel team -2; retention -3; followers -3; conduct scandal; mods stressed; flags pro_solicitation</sub>

4. **Call {love_interest} from the lobby** *(locked: having a partner at home)* (29 words)
   You step out into the lobby and call {love_interest}, and tell them exactly where you were invited. There's a long pause, then a laugh, then a quiet thank you.
   <sub>social +1; energy -1; charisma +1; rel love_interest +5; mods inspired</sub>

## 38. PRO_066 The Tax Letter, Pro
*money; premise 27 words*

> You owe taxes in every state where you played a road game, and your old accountant didn't file most of them. The letters have started to arrive.

1. **Hire a sports accountant** (22 words)
   You hire an accountant who does nothing but athletes. It takes a month of paperwork and a painful check, and it's done.
   <sub>energy -2; fun -1; intelligence +2; leadership +1; mods stressed</sub>

2. **Ignore the letters** (28 words)
   The letters go in a drawer. They come back with penalties, then with a lawyer's name on the envelope, and every one of them makes your stomach drop.
   <sub>energy +1; fun +1; intelligence -2; mods distracted</sub>

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

2. **Ignore the letters**: The letters go in a drawer. They come back with penalties, then with a lawyer's name on the envelope, and every one of them makes your stomach drop.
   <sub>energy +1; fun +1; intelligence -2; retention -1; mods distracted</sub>

3. **Ask the veterans at lunch**: Every veteran at the lunch table has a horror story and a phone number. You call the one who sounds least scary, and she fixes it in a month.
   <sub>energy -1; social +1; intelligence +1; mods focused</sub>

4. **Pay it from the account you never touch**: You pay it from the account you've never touched since your first paycheck. It's a big number, and it doesn't keep you up at night.
   <sub>fun -1; intelligence +1; mods rested</sub>

</details>


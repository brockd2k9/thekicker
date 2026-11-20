# College batch 13 (written, not imported)


## Batch 13: four added wrong-path scenes, plus the four steps that now clear the new strikes

### COL_151 The Ride Home
- **Category:** social  
- **Window:** years 2-3, any week  
- **Cast:** Team, {coach}  
- **Premise:** A teammate who has had too much insists on driving everyone home from a party. You're one of his passengers.

The party is breaking up, and the teammate who drove you here has had too much. He's jingling his keys at the door and telling everyone to pile in.

1. **Find another way home**: You say you'll find your own ride, then call a car for yourself and two freshmen who were about to get in. It costs you twenty dollars and some teasing. On Monday, one freshman's mother emails {coach} to say thank you.  
   *(energy -2; social -1; leadership +2; {coach} +3; modifier tired; **conduct good**; sets `found_another_ride`)*
2. **Ride along**: You get in the back seat because everyone else does. Four blocks later, police lights fill the car. Nobody's hurt, and every name in that car is in the paper by Tuesday, yours included.  
   *(fun +2; social +2; energy -3; leadership -3; **draft -5**; {coach} -8; Team -2; modifier stressed; **conduct scandal**; sets **strike** `rode_along`)*
3. **Take the keys and drive**: You haven't had anything all night, so you take his keys and drive everyone home yourself. He calls you a narc in front of the whole party and doesn't speak to you for a week.  
   *(energy -3; social -2; leadership +3; intelligence +1; Team -3; modifier tired)*

### COL_152 The Balcony Dare
- **Category:** social  
- **Window:** years 1-3, offseason after that season  
- **Cast:** {coach}  
- **Premise:** On a spring trip, a friend dares you to jump from the hotel balcony into the pool three floors down.

Spring trip, a hotel by the beach. A friend leans over the third-floor balcony rail, points at the pool below and offers you a hundred dollars to jump. Somebody already has a phone out.

1. **Say no and take the stairs**: You laugh, say you like your legs where they are and take the stairs down to the pool. You swim, you sleep, and you fly home with nothing to explain.  
   *(energy +2; fun +1; intelligence +1; modifier rested)*
2. **Stop him from trying it**: When you say no, he starts climbing the rail himself. You pull him back by the shirt and walk him inside. He's angry for ten minutes and grateful for the rest of the trip.  
   *(energy -1; social +2; leadership +2; modifier confident)*
3. **Jump**: You climb the rail and jump. You're a foot short of where you thought you'd land, clip the pool's edge and spend the night in an emergency room. The video is online before your X-ray comes back, and {coach} sees both.  
   *(health -8; fun +2; social +1; intelligence -2; **draft -3**; followers +3; {coach} -6; modifier sore; **conduct scandal**; sets **strike** `balcony_jump`)*

### COL_153 The Keys
- **Category:** social  
- **Window:** years 2-4, any week  
- **Cast:** Team, {coach}  
- **Premise:** After a party, a teammate who is in no shape to drive demands his keys back. You're sober, and you're holding them.

You're the one who stayed sober tonight, so the host gave you a teammate's car keys at midnight for safekeeping. Now he's in no shape to drive, he's standing in front of you, and he wants them back.

1. **Keep the keys and call a ride**: You put the keys in your pocket and call him a car. He argues in the driveway for ten minutes, then falls asleep in the back seat. You hand the keys back at breakfast.  
   *(energy -1; social -1; leadership +2; Team +1; modifier focused; **conduct good**)*
2. **Hand them over and get in**: You give him the keys and get in the passenger seat because it's easier than the fight. He runs a red light two blocks later, right in front of a patrol car, and {coach} gets the call before sunrise.  
   *(fun +1; social +2; leadership -3; **draft -5**; {coach} -8; Team -2; modifier stressed; **conduct scandal**; sets **strike** `rode_along`)*
3. **Drive him home yourself**: You drive him home in his own car, walk him to his door and walk two miles back at 2 a.m. You get four hours of sleep, and some teammates think you overstepped. He gets home safe.  
   *(energy -5; leadership +3; charisma +1; Team -2; modifier tired; **conduct good**; sets `drove_teammates_home`)*

### COL_154 The Fast Lane
- **Category:** social  
- **Window:** years 2-4, any week  
- **Cast:** Team, {coach}  
- **Premise:** A teammate pulls up next to you on the highway at night and dares you to race him to the next exit.

Driving back to campus late on a Sunday, a teammate pulls up next to you on the empty highway, revs his engine and points at the next exit sign. He wants a race.

1. **Let him go**: You ease off the gas and watch his taillights disappear. He texts you a chicken emoji. You get home in one piece, with a clean record.  
   *(energy +1; fun -1; intelligence +1; modifier rested)*
2. **Call him when you're both home**: You let him go, then call him once you're both home and tell him he scared you. He laughs it off, but he drives the speed limit to practice all week.  
   *(energy -1; social +1; leadership +2; modifier focused)*
3. **Race him**: You floor it. A state trooper clocks you both at 102, the tickets come with a court date, and the local news runs the story with your team photo. {coach} reads it before you're out of bed.  
   *(fun +4; energy -1; ambition +1; leadership -2; **draft -5**; {coach} -8; Team -2; modifier distracted; **conduct scandal**; sets **strike** `street_race`)*

### COL_036 The Coach's Office
- **Category:** team  
- **Window:** years 1-3, any week; opens on any of `missed_curfew`, `hazing_participant`, `snuck_out_road`, `took_improper_benefit`, `online_incident`, `academic_shortcut`, `skipped_conditioning`, `shared_prescription`, `party_trouble`, `portal_tampering`, `took_unapproved_supplement`, `rivalry_prank`, `stayed_out_late`, `hosted_recruit_badly`, `sabotaged_transfer`, `rode_along`, `ran_with_wrong_crowd`, `cash_camp`, `balcony_jump`, `street_race`  
- **Cast:** {coach}  
- **Premise:** {coach} closes the door. Word of what you did got back to the staff, and the coach wants to hear it from you before deciding anything.

{coach} closes the office door and slides a printed report across the desk. Word of what happened got back to the staff. 'I want to hear it from you,' the coach says, 'before I decide what happens next.'

1. **Tell the whole truth**: You don't trim anything. {coach} listens without interrupting, then hands you a list: three 6 a.m. workouts with the strength staff and a talk with the team. 'That's the end of it, if it stays the end of it.'  
   *(energy -4; social -2; leadership +2; intelligence +1; **draft -1**; {coach} +6; modifier drained; sets `owned_mistake`; clears 23 strike flags)*
2. **Shrink your part in it**: You say you were barely involved and that other people pushed it. {coach} nods slowly and writes something down. You walk out without a punishment and with the feeling you just made things worse.  
   *(energy +1; fun +1; ambition +1; leadership -2; **draft -3**; {coach} -8; modifier stressed; **conduct bad**; sets `college_warning`; clears 23 strike flags)*

### COL_071 The Second Strike
- **Category:** media  
- **Window:** years 2-4, any week; opens on any of `missed_curfew`, `hazing_participant`, `snuck_out_road`, `took_improper_benefit`, `online_incident`, `academic_shortcut`, `skipped_conditioning`, `shared_prescription`, `party_trouble`, `portal_tampering`, `took_unapproved_supplement`, `rivalry_prank`, `stayed_out_late`, `secret_agent_deal`, `hosted_recruit_badly`, `sabotaged_transfer`, `rode_along`, `ran_with_wrong_crowd`, `cash_camp`, `partied_before_pro_day`, `senior_trip_trouble`, `balcony_jump`, `street_race`; needs all of `college_warning`  
- **Cast:** Team, {coach}  
- **Premise:** It happens again. This time it isn't only the coaches who know: a reporter is asking questions, and the team has to respond.

It happened again, and this time it isn't only the coaches who know. A local reporter has called the athletic department, {coach} says the team will put out a statement tonight, and teammates are already asking what you're going to say.

1. **Own it in your own words**: You sit down with {coach} and the media staff and write the statement yourself: what you did, that it was wrong, what you'll do now. It runs that night. It's humiliating, and people notice you didn't hide.  
   *(social -4; fun -3; leadership +3; intelligence +1; **draft -2**; {coach} +4; Team +2; modifier drained; sets `caught_yourself`, `second_chance_used`; clears 23 strike flags)*
2. **Let the department answer**: You stay quiet and let a short, vague statement go out. The story fades in a few days, but inside the building people stop trusting what you say.  
   *(energy +1; social -1; ambition +1; leadership -2; **draft -5**; {coach} -6; Team -4; modifier distracted; **conduct scandal**; sets `character_concerns`; clears 23 strike flags)*
3. **Blame the people around you**: Off the record, you tell the reporter your teammates set you up. Your name is in the paper the next morning anyway, next to theirs. {coach} doesn't yell, and that's worse.  
   *(energy +2; social -6; ambition +2; leadership -3; charisma -2; **draft -8**; {coach} -12; Team -10; modifier stressed; **conduct scandal**; sets `character_concerns`; clears 23 strike flags)*

### COL_017 The Pattern
- **Category:** team  
- **Window:** years 2-4, any week; opens on any of `missed_curfew`, `hazing_participant`, `snuck_out_road`, `took_improper_benefit`, `online_incident`, `academic_shortcut`, `skipped_conditioning`, `shared_prescription`, `party_trouble`, `portal_tampering`, `took_unapproved_supplement`, `rivalry_prank`, `stayed_out_late`, `secret_agent_deal`, `hosted_recruit_badly`, `sabotaged_transfer`, `rode_along`, `ran_with_wrong_crowd`, `cash_camp`, `partied_before_pro_day`, `senior_trip_trouble`, `balcony_jump`, `street_race`; needs all of `owned_mistake`  
- **Cast:** {coach}  
- **Premise:** You owned your first mistake, and the staff believed you. Now there's another one, and {coach} wants to know whether the first apology meant anything.

You owned your first mistake, and the staff believed you. Now there's another one, and {coach} wants to know whether that first apology meant anything.

1. **Own it again, and change something**: You don't explain it away. You tell {coach} what happened, what you'll change and who can hold you to it. The coach is quiet for a long time, then says this is the last time this conversation is a conversation.  
   *(energy -3; social -2; leadership +2; intelligence +1; **draft -2**; {coach} +3; modifier drained; sets `owned_it_again`, `second_chance_used`; clears 23 strike flags)*
2. **Say it was different this time**: You explain why this one isn't like the first one. {coach} listens to all of it and doesn't believe any of it, and you can see the moment the coach stops trusting what you say.  
   *(energy +1; ambition +1; leadership -3; **draft -5**; {coach} -10; modifier stressed; **conduct bad**; sets `character_concerns`; clears 23 strike flags)*

### COL_086 The Final Warning
- **Category:** team  
- **Window:** years 2-4, any week; opens on any of `missed_curfew`, `hazing_participant`, `snuck_out_road`, `took_improper_benefit`, `online_incident`, `academic_shortcut`, `skipped_conditioning`, `shared_prescription`, `party_trouble`, `portal_tampering`, `took_unapproved_supplement`, `rivalry_prank`, `stayed_out_late`, `secret_agent_deal`, `hosted_recruit_badly`, `sabotaged_transfer`, `rode_along`, `ran_with_wrong_crowd`, `cash_camp`, `partied_before_pro_day`, `senior_trip_trouble`, `balcony_jump`, `street_race`; needs all of `second_chance_used`  
- **Cast:** Team, {coach}  
- **Premise:** A third incident. {coach} and the head coach sit you down together: one more and you're off the team. This is the last conversation before that one.

Another incident. {coach} and the head coach sit you down together and don't soften it: there are no more warnings after this one, and scouts have already started asking about you.

1. **Accept every condition**: You agree to all of it: early workouts for a month, no road-trip free time, weekly check-ins with {coach}. It costs you a lot of your season, and nobody in that room has to wonder about you again.  
   *(energy -5; fun -4; social -2; leadership +2; intelligence +1; **draft -3**; {coach} +4; modifier drained; sets `last_chance`; clears 23 strike flags)*
2. **Push back on the conditions**: You argue that the conditions are too much for what happened. The head coach ends the meeting early. By the next week, the word around the program is that you're a problem.  
   *(energy +1; fun +1; ambition +2; leadership -3; **draft -8**; {coach} -12; Team -4; modifier stressed; **conduct scandal**; sets `character_concerns`; clears 23 strike flags)*

#### Flags this batch sets, and what they open

- `balcony_jump` (from COL_152) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning
- `caught_yourself` (from COL_071) → nothing reads it yet
- `character_concerns` (from COL_017, COL_071, COL_086) → COL_078 The Long Way Back; COL_106 The Red Flag Interview; COL_126 The Exclusive Deal (locked choice); pro_folder_follows The Folder Follows You; pro_old_crowd The Old Crowd; pro_reporters_question The Reporter's Question
- `college_warning` (from COL_036) → COL_071 The Second Strike; COL_106 The Red Flag Interview; pro_folder_follows The Folder Follows You; pro_reporters_question The Reporter's Question
- `drove_teammates_home` (from COL_153) → nothing reads it yet
- `found_another_ride` (from COL_151) → nothing reads it yet
- `last_chance` (from COL_086) → COL_126 The Exclusive Deal (locked choice); COL_130 The Old Posts (locked choice); pro_old_crowd The Old Crowd
- `owned_it_again` (from COL_017) → nothing reads it yet
- `owned_mistake` (from COL_036) → COL_017 The Pattern; COL_129 The Scout's Dinner (locked choice); pro_rookie_symposium The Rookie Symposium
- `rode_along` (from COL_151, COL_153) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning
- `second_chance_used` (from COL_017, COL_071) → COL_086 The Final Warning
- `street_race` (from COL_154) → COL_017 The Pattern; COL_036 The Coach's Office; COL_071 The Second Strike; COL_086 The Final Warning

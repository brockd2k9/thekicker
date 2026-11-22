# Retirement epilogue: the 12 closing scenes (imported on the branch)

Dry run and import: 12 written, 0 errors, 0 warnings, 0 lint notes. Order: E01=10 ... E12=120 (E02 before E11/E12). E06 needs 8+ pro seasons, or hof_finalist / hof_ring_of_honor, and not hall_of_fame_earned.


## Closing scenes

### PRO_E01 The First Morning After
- **Category:** career  
- **Window:** once, opens on `retired_by_choice` / `retired_out_of_football` / `retired_released` / `retired_unsigned`, pro_seasons 1+  
- **Cast:** {love_interest}, {parent}  
- **Premise:** The first morning with nowhere to be. The way it ended decides how it feels.  
- **Note:** Versions by retirement reason (chose / forced out / dismissed).

The first morning with nowhere to be. No meeting at eight, no tape on your ankle, no film in your bag. The coffee tastes the same, and the house is so quiet you can hear the clock in the hallway.

1. **Sleep until noon**: You go back to bed and sleep until noon, for the first time since you were a teenager. When you wake up, nobody needs you anywhere, and it's terrifying and wonderful at once.  
   *(energy +3; health +2; modifier rested)*
2. **Go for a walk with no plan**: A long walk with no destination, past the park where kids are kicking a ball badly. You stop and watch for a while, and nobody recognizes you, and that's fine.  
   *(fun +1; resilience +2; modifier rested)*
3. 🔒 *locked: needs `retired_by_choice`, shown as "having chosen when to stop"*  
   **Hang the cleats on the wall**: The last pair of cleats goes on a nail in the garage, laces tied together. You chose this ending yourself, and standing in front of them, you're glad you did it on your own terms.  
   *(resilience +2; leadership +1; modifier inspired)*
4. 🔒 *locked: needs `retired_released` or `retired_unsigned` or `retired_out_of_football` or `was_dismissed`, shown as "if the game ended it for you"*  
   **Sit with how it ended**: You sit on the back step with the coffee and let yourself be angry about how it ended, then sad, then something quieter. By lunch you can say it out loud: it's over, and you were good.  
   *(social -1; resilience +3; modifier drained)*

### PRO_E02 The Phone Call From the Club
- **Category:** career  
- **Window:** once, pro_seasons 1+  
- **Cast:** {love_interest}, {parent}  
- **Premise:** Your last club calls with an offer to stay connected.

Your last club calls a month after the end, the general manager and the special teams coach on speaker together. They want you to stay connected, and they've each brought a different idea.

1. **Take the coaching idea**: The coaching idea: assistant special teams coach, starting in the spring, with an office down the hall from where your locker used to be. You say yes before they finish describing the parking space.  
   *(leadership +2; intelligence +1; modifier inspired; sets `coach_after_football`)*
2. **Take the broadcast idea**: The broadcast idea: the club's radio booth, twelve games a year, beside an announcer who has been calling games since before you were born. You say yes, and start practicing in the car.  
   *(fun +1; charisma +2; modifier spotlight; sets `broadcaster_after_football`)*
3. **Thank them and go home**: No to both, with real thanks. You want to find out who you are without a team first, and the general manager says the door stays open, and you believe it.  
   *(social +1; resilience +2; {parent} +2; modifier rested)*

### PRO_E03 Hall of Fame Eligibility
- **Category:** media  
- **Window:** once, opens on `hof_finalist` / `hof_inducted` / `hof_first_ballot`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** Five years after your last kick, your name is on the list of eligible players.  
- **Note:** Only if the career earned it (engine formula, request R10).

Your name goes on the list of players eligible for the Hall of Fame. A reporter calls for a comment, an old teammate texts a row of trophies, and you find yourself checking the news more than you'd like.

1. **Turn off your phone**: The phone goes in a drawer until the vote is done. The waiting is easier without the noise, and you spend the weeks fixing the fence and cooking long dinners.  
   *(energy +1; resilience +2; modifier rested)*
2. **Call the people who got you there**: One by one, the people who got you there get a call: old coaches, a holder, the trainer who taped your ankle. Whatever the vote says, the calls are the part you'll keep.  
   *(social +2; charisma +1; {holder} +2; modifier inspired)*
3. **Give the reporter something honest**: A comment for the reporter: you'd be honored, and you'd be fine either way, because the career already happened. It's the truest thing you've said in a long time.  
   *(charisma +2; intelligence +1; followers +1; modifier focused)*

### PRO_E04 The Nomination
- **Category:** media  
- **Window:** once, needs `hall_of_fame_earned`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** The Hall of Fame vote is in, and your name is on the list of new members.  
- **Note:** Hall of Fame earned.

The Hall of Fame vote is in, and your name is on the list of new members. The list goes up on the league's website at noon, and by five past your phone has a hundred messages.

1. **Read every message**: You read every message, all hundred and then two hundred more, sitting on the kitchen floor. Old teammates, rivals, a kid from a clinic years ago: the whole career, in one afternoon.  
   *(social +2; resilience +1; charisma +1; leadership +1; modifier inspired)*
2. **Call {parent} first**: Before anyone else, you call {parent}. There's a long silence on the line, and then a sound you've never heard {parent} make, and you both laugh at it for a long time.  
   *(social +2; fun +1; {parent} +4; modifier inspired)*
3. **Go to the old field**: The field where you first kicked a ball is a short drive away, and you stand on the old hash mark for a while. Nobody is there, and it's exactly where you wanted to be.  
   *(resilience +2; intelligence +1; modifier rested)*

### PRO_E05 The Call
- **Category:** media  
- **Window:** once, needs `hall_of_fame_earned`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** The call that changes your legacy.  
- **Note:** Hall of Fame earned.

The call comes on a gray Tuesday afternoon: a polite voice from the Hall of Fame, a few formal sentences, and then a pause while the person on the other end waits for you to say anything at all.

1. **Say thank you, twice**: You say thank you twice, because the first one came out as a whisper. The voice on the phone laughs kindly and says almost everyone does that.  
   *(resilience +2; charisma +1; modifier inspired)*
2. **Ask who else is going in**: You ask who else is going in with you, and two of the names are people you played against. You call them both that evening, and the three of you talk past midnight.  
   *(social +2; leadership +1; {tyler} +2; modifier inspired)*
3. **Hand the phone to {sibling}**: You hand the phone to {sibling} without a word, because you can't speak. {sibling} handles the rest of the call like a professional and then hugs you so hard it hurts.  
   *(social +2; fun +1; {sibling} +4; modifier loose)*

### PRO_E06 The Call That Doesn't Come
- **Category:** career  
- **Window:** once, not `hall_of_fame_earned`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** The finalists are announced, and you're not one of them.  
- **Note:** Not earned: a closing scene about what you built anyway.

The finalists are announced, and you're not one of them. The list is on your phone, the names you know and the names you'd expected, and yours isn't there. The house is quiet around it.

1. **Count what you built anyway**: A legal pad and an hour at the kitchen table, writing down what you built anyway: the people you helped, the habits you kept, the kids at the clinics. The list is longer than you expected.  
   *(resilience +3; intelligence +1; modifier drained)*
2. **Call someone who knows**: You call an old teammate who never got in either. He laughs, then gets serious, and says the best thing anyone says to you all year: the vote isn't the career.  
   *(social +2; fun +1; resilience +1; modifier inspired)*
3. 🔒 *locked: needs `hof_finalist`, shown as "having made the finalists before"*  
   **Be proud of the finalist year**: You remember the year your name made the final list and decide that will do. A finalist is a career most kickers would trade for, and you say so out loud, to nobody, in the kitchen.  
   *(resilience +2; charisma +1; modifier inspired)*
4. 🔒 *locked: needs `hof_ring_of_honor`, shown as "with your name in your club's Ring of Honor"*  
   **Visit the Ring of Honor**: At the stadium, you look up at your name in the Ring of Honor, painted above the seats where the fans who knew you best used to sit. That's where you belong, and it's enough.  
   *(fun +1; resilience +2; followers +1; modifier rested)*

### PRO_E07 The Speech of a Lifetime
- **Category:** career  
- **Window:** once, needs `hall_of_fame_earned`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** You write your induction speech and think about everyone who got you there.  
- **Note:** Versions keyed to family and wrong-path flags.

You start writing your induction speech at the kitchen table, and the first draft is forty names long. Every person who got you there wants a line, and you have eight minutes on the stage.

1. **Keep every name**: Every name stays, read quickly, with one sentence each. It runs long, the organizers frown, and every person on the list hears their name in that hall.  
   *(social +2; leadership +1; modifier inspired)*
2. **Tell one story instead**: One story, about the first person who believed in you, and a thank-you to everyone else in a single line. It's shorter, and it lands harder than any list could.  
   *(charisma +2; intelligence +1; modifier focused)*
3. 🔒 *locked: needs `became_parent`, shown as "with kids of your own"*  
   **Write it for your kids**: You write the whole speech for your kids, about what the years cost them and what you hope they took from it. They sit in the front row, and they hear every word.  
   *(social +2; resilience +1; modifier inspired)*
4. 🔒 *locked: needs `was_dismissed` or `pro_character_concerns`, shown as "having fallen and come back"*  
   **Tell them about the fall**: You put the worst part in the speech, the fall and the long way back, because leaving it out would be a lie. The hall goes completely quiet, and then it stands.  
   *(resilience +2; leadership +2; modifier drained)*

### PRO_E08 The Speech, Second Draft
- **Category:** family  
- **Window:** once, needs `hall_of_fame_earned`, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** You read the speech to {love_interest} and cross out half of it.  
- **Note:** Partner version.

You read the speech to {love_interest} at the kitchen table the night before the ceremony, and they listen all the way through, and then reach for a pen and cross out half of it.

1. **Let them cut it**: You let them cut it, every line they want. What's left is shorter and truer, and it sounds like you, which the first draft somehow didn't.  
   *(social +2; resilience +1; intelligence +1; {love_interest} +4; modifier inspired)*
2. **Argue for one line**: You argue for one line, the one about the bad years, and win. {love_interest} puts the pen down and says it's the best line in the speech, and you both laugh.  
   *(fun +1; charisma +2; {love_interest} +3; modifier loose)*
3. **Add a line about them**: The pen comes back to you, and you add a line about {love_interest}, near the end, without telling them. They hear it for the first time in the hall, in the second row.  
   *(social +2; leadership +1; {love_interest} +5; modifier inspired)*

### PRO_E09 The Look Back
- **Category:** family  
- **Window:** once, pro_seasons 1+  
- **Cast:** {love_interest}, {parent}  
- **Premise:** A closing look at the whole career, from the first kick in the backyard.  
- **Note:** Closing summary scene.

A closing look at the whole career, from the first kick in the backyard: the box of old programs {parent} kept, the cleats, the jerseys, a newspaper clipping from a high school game you'd forgotten.

1. **Go through the box slowly**: Every program, every clipping, every photo, one evening at a time over a week. By the end you understand the whole thing a little better, and you're kinder to the kid in the pictures.  
   *(resilience +2; intelligence +1; {parent} +2; modifier rested)*
2. **Give most of it away**: Most of it goes to the youth league and the high school, the jerseys framed for their hallways. The box gets lighter, and so do you.  
   *(social +1; leadership +2; charisma +1; modifier inspired)*
3. **Make a book for the family**: A photo book for the family, built over a month, with captions {sibling} insists on rewriting. Everyone gets a copy, and the arguments about the captions are the best part.  
   *(fun +2; social +1; {sibling} +2; modifier loose)*
4. 🔒 *locked: needs `saved_rookie_check` or `lived_modestly`, shown as "having kept your rookie habits"*  
   **Find the first paycheck stub**: At the bottom of the box is the stub from your first pro paycheck, and the note you wrote yourself about saving it. You laugh, then frame it for the hallway.  
   *(fun +1; resilience +2; modifier rested)*

### PRO_E10 The Kid With Your Number
- **Category:** social  
- **Window:** once, pro_seasons 1+  
- **Cast:** {love_interest}, {parent}  
- **Premise:** Years later, a kid at a youth camp wears your number and doesn't know who you are.

Years later, at a youth camp, a kid is wearing your old number on a homemade shirt. You ask why that number, and the kid shrugs and says it's just a lucky one. They have no idea who you are.

1. **Don't tell them**: You don't tell them. You just help with their plant foot, and the kid gets better by lunch, wearing your number, and that's the whole thing you ever wanted.  
   *(resilience +2; leadership +1; modifier inspired)*
2. **Tell them, later**: At the end of camp you tell them, quietly, and the kid's mouth falls open. They ask for an autograph on the homemade shirt, right across your old number.  
   *(fun +2; charisma +1; modifier loose)*
3. **Ask them about their kicking**: You ask about their kicking instead, and listen for twenty minutes. The kid talks like you used to, all hope and no doubt, and you drive home smiling.  
   *(social +2; intelligence +1; modifier inspired)*

### PRO_E11 Coach, Now
- **Category:** career  
- **Window:** once, needs `coach_after_football`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** Your first season coaching. The kickers call you 'Coach' and you keep looking behind you.  
- **Note:** If you took a coaching path.

Your first season coaching. The kickers call you 'Coach', and every time they do, you turn around to see who they mean. Your office has a window over the field, and the whistle is still new.

1. **Coach the way you were coached**: The way you were coached at your best: honest, patient, a little funny. The young kickers improve, and one of them asks you, in October, how you knew so much.  
   *(leadership +2; intelligence +1; Team +2; modifier inspired)*
2. **Learn from the kickers**: The first month is for listening more than talking, asking the young kickers what they need. It's the best coaching decision you make all year.  
   *(social +2; resilience +1; modifier focused)*
3. **Kick with them, once**: On the last day of camp, in your old cleats, one kick with them, just for fun. It goes where it wants to go, and the kickers cheer anyway, and you never do it again.  
   *(fun +2; charisma +1; modifier loose)*

### PRO_E12 In the Booth
- **Category:** media  
- **Window:** once, needs `broadcaster_after_football`  
- **Cast:** {love_interest}, {parent}  
- **Premise:** Your first broadcast. Your old club is playing.  
- **Note:** If you took a broadcasting path.

Your first broadcast, in a booth high above the field. Your old club is playing, the producer is counting down in your headphones, and the veteran announcer beside you winks and says, 'Just talk.'

1. **Just talk**: You just talk: about the kickers, the wind, the snapper's timing. It's easy once it starts, and the producer says in your ear that you're a natural.  
   *(fun +1; charisma +2; followers +2; modifier spotlight)*
2. **Prepare like a game**: You prepare like it's a game: notes, charts, the stadium's wind. You're the best-prepared voice in the booth, and the veteran announcer borrows your notes at halftime.  
   *(intelligence +2; ambition +1; modifier focused)*
3. **Talk about your old teammates**: You talk about the old teammates still on the field, what they were like on the hard days. Fans write in for a week to say it was the best broadcast all season.  
   *(social +2; leadership +1; followers +1; modifier inspired)*

#### Flags this batch sets, and what they open

- `broadcaster_after_football` (from PRO_E02) → PRO_E12 In the Booth
- `coach_after_football` (from PRO_E02) → PRO_E11 Coach, Now

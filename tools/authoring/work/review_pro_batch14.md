# PRO batch 14: quality pass (rewrites and stat fixes) (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 14: quality pass (rewrites and stat fixes)

### PRO_629 The Rookie Who Calls Home Crying
- **Category:** team  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A rookie in your class calls home after every practice, and the veterans have noticed.

A rookie in your class calls home after every practice, and the veterans have started to notice.

1. **Sit with him at lunch**: You start sitting with him at lunch. He calls home a little less, and laughs a little more.  
   *(social +2; charisma +1; Team +3; modifier loose)*
2. **Tell the veterans to ease up**: You ask the veterans to ease up. One of them tells you about his own first year.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +1; modifier inspired)*
3. **Mind your own business**: You mind your own business. He makes it through, barely.  
   *(energy +2; fun +1; modifier rested)*

### PRO_021 Don't Talk About It
- **Category:** team  
- **Window:** age 26-29, once, fg_streak 6+  
- **Cast:** Team, {holder}  
- **Premise:** The specialists have a superstition: nobody says the streak out loud. A rookie just said it.

The specialists have a superstition: nobody says the streak out loud. A rookie just said it, at lunch, loudly.

1. **Laugh it off**: You laugh and tell the rookie it's fine. The room relaxes, and the streak goes on.  
   *(social +2; charisma +1; Team +3; modifier loose)*
2. **Change nothing**: You keep every part of your routine exactly the same, including the socks.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Make the rookie buy lunch**: You make the rookie buy the specialists lunch as penance. It becomes a tradition.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*

### PRO_026 The Coach for Hire
- **Category:** training  
- **Window:** age 26-29, offseason, once  
- **Cast:** (no cast)  
- **Premise:** A private coach who rebuilt three pro kickers offers you his offseason, for a price.

A private coach who rebuilt three pro kickers offers you his offseason, for a price.

1. **Hire him**: You hire him for the summer. His drills are brutal and brilliant, and your leg feels new by August.  
   *(energy -2; power +1; ambition +2; 3 SP; modifier dialed_in; sets `hired_private_coach`)*
2. **Train with the club's staff**: You stay with the club's staff, who know your body. It's less glamorous and steady.  
   *(energy -1; accuracy +1; intelligence +2; {coach} +2; modifier focused)*
3. **Take the summer off**: You take the summer mostly off. You come back rested and a little rusty.  
   *(energy +2; fun +1; modifier rested)*
4. 🔒 *locked: needs `vetted_trainer` or `trained_with_alum`, shown as "having checked out trainers before"*  
   **Check his record first**: You call two of his former clients before deciding. Both rave. You hire him with your eyes open.  
   *(energy -2; intelligence +1; ambition +1; 2 SP; modifier dialed_in; sets `hired_private_coach`)*

### PRO_031 The Incentive Clause
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.

Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.

1. **Ask your agent to stop**: You ask your agent to stop sending the math. You'll know at the end of the season.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
2. **Chase it**: You put the number on your locker and chase it every practice.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Forget about it**: You forget about it entirely. If it comes, it comes.  
   *(energy +2; fun +1; modifier rested)*

### PRO_032 The Kicker Brought In
- **Category:** team  
- **Window:** age 26-29, weeks 1-3, age-banded variant  
- **Cast:** {coach}, Team  
- **Premise:** The club signs a kicker with a bigger leg and a lower salary, and puts him at the locker next to yours.  
- **Note:** Prime-age version; PRO_133 is the veteran version.

The club signs a kicker with a bigger leg and a lower salary, and puts him at the locker next to yours.

1. **Out-prepare him**: You out-prepare him every single day. He has the leg; you have the habits.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
2. **Get to know him**: You get to know him. He's nervous and decent, and you both kick better without the tension.  
   *(social +2; charisma +1; Team +3; modifier loose)*
3. **Ask {coach} the plan**: You ask {coach} straight out what the plan is. The answer is honest: it's open.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*

### PRO_035 The Bad Week
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** {holder}, {coach}  
- **Premise:** You snapped at {holder}, ignored {coach} and skipped the team meal. It's been that kind of week.

You snapped at {holder}, ignored {coach} and skipped the team meal. It's been that kind of week.

1. **Apologize to {holder}**: You apologize to {holder} before practice. The holds are better that afternoon.  
   *(social +2; charisma +1; {holder} +3; modifier loose)*
2. **Tell {coach} what's going on**: You tell {coach} what's actually going on. The coach listens and gives you a lighter week.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Take a night off**: You take a night completely off: no film, no phone. It resets you.  
   *(energy +2; fun +1; modifier rested)*

### PRO_037 Contract Year: The Payday
- **Category:** career  
- **Window:** age 26-29, age-banded variant, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** This is the contract that sets up your family for life, if you earn it this season.

This is the contract that sets up your family for life, if you earn it this season.

1. **Make the season undeniable**: You make every practice count. Nothing about this season will be an accident.  
   *(energy -2; resilience +1; ambition +2; 2 SP; modifier dialed_in)*
2. **Let your agent work**: You let your agent handle every conversation and keep your head on kicking.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Talk it through at home**: You talk it through with your family. Their calm becomes your calm.  
   *(social +2; charisma +1; {parent} +3; modifier loose)*

### PRO_040 The Hometown Discount
- **Category:** money  
- **Window:** age 26-29, once, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** The club offers less than the market, and asks you to take it because you're family here.

The club offers less than the market and asks you to take it because you're family here.

1. **Take the discount**: You accept the discount. The club remembers, and so does the locker room.  
   *(social +2; charisma +1; **retention +2**; Team +3; modifier loose)*
2. **Meet in the middle**: You ask your agent to find the middle. It takes two weeks, and everyone is a little unhappy and fine.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Test the market**: You decide to test the market next spring and kick like it all year.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*

### PRO_052 The Teammate Traded Away
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** {holder}, Team  
- **Premise:** The club traded your holder's best friend at midnight. He found out from his phone.  
- **Note:** Other players get traded; the player can't be.

The club traded your holder's best friend at midnight. He found out from his phone.

1. **Check on {holder}**: You check on {holder} first thing in the morning and stay through lunch.  
   *(social +2; charisma +1; {holder} +3; modifier loose)*
2. **Talk to the team**: You say something to the specialists about how the business works. It helps the young ones.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
3. **Keep your head down**: You keep your head down. It's the business, and you know it could be you.  
   *(energy +2; fun +1; modifier rested)*

### PRO_069 {parent}'s House
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** {parent}  
- **Premise:** You could pay off {parent}'s mortgage this week. He's told you not to, twice.

You could pay off {parent}'s mortgage this week with one transfer. He's told you not to, twice, in the voice he used when you were twelve.

1. **Do it anyway**: You pay it off and tell him after. He's furious for an hour and doesn't speak at dinner. A month later, he still has the letter from the bank on his fridge.  
   *(social +2; charisma +1; {parent} +6; modifier loose)*
2. **Ask what he'd accept**: You ask {parent} what he would actually accept. He agrees to a loan with no interest, insists on paying it back, and pays it back early.  
   *(energy -1; resilience +1; intelligence +2; {parent} +3; modifier focused)*
3. **Respect his wish**: You respect his wish and let it go. He's proud of that, in his quiet way, and you send money to his church instead.  
   *(energy +2; fun +1; modifier rested)*
4. 🔒 *locked: needs `helped_family_financially`, shown as "having helped your family with money before"*  
   **Do it the way that worked before**: You set it up the way you did last time: quietly, through the bank, with his name on everything. He grumbles and signs.  
   *(energy -1; intelligence +1; {parent} +5; modifier inspired)*

### PRO_077 First Day of School
- **Category:** family  
- **Window:** age 26-29, once, needs `became_parent`  
- **Cast:** {love_interest}  
- **Premise:** Your kid's first day of school is a Thursday practice.

Your kid's first day of school is a Thursday practice.

1. **Ask to come in late**: You ask {coach} to come in an hour late. You're there for the first wave goodbye.  
   *(social +2; charisma +1; {love_interest} +4; modifier loose)*
2. **Go to practice**: You go to practice and get a video. You watch it four times at lunch.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Plan around it**: You plan the morning with the coach and your partner. You make the drop-off and the meeting.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*

### PRO_080 {parent} Is Getting Older
- **Category:** family  
- **Window:** age 26-29, once  
- **Cast:** {parent}, {sibling}  
- **Premise:** {parent} forgets the name of a neighbor he's known for twenty years.

{parent} forgets the name of a neighbor he's known for twenty years.

1. **Go home for a weekend**: You go home for the bye weekend and spend every minute with him.  
   *(social +2; charisma +1; {parent} +5; modifier loose)*
2. **Find him a doctor**: You find him a specialist and go to the first appointment by video.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
3. **Call more often**: You start calling every other day. It's not much, and it's something.  
   *(energy +2; fun +1; modifier rested)*

### PRO_082 {sibling}'s Own Shot
- **Category:** family  
- **Window:** age 26-29, once  
- **Cast:** {sibling}  
- **Premise:** {sibling} has a tryout of his own, and he wants you there.

{sibling} has a tryout of his own, and he wants you there.

1. **Be there**: You fly in for the tryout and stand behind the fence. He looks for you before every kick.  
   *(social +2; charisma +1; {sibling} +6; modifier loose)*
2. **Coach him by phone**: You coach him by phone the night before: one thought, one routine.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*
3. **Send a message**: You send a message and watch the video later. He understands, mostly.  
   *(energy +2; fun +1; modifier rested)*
4. 🔒 *locked: needs `went_home_for_dad` or `came_clean_tape`, shown as "having learned what showing up means"*  
   **Tell him what you learned**: You tell {sibling} the hardest thing you ever learned: show up, tell the truth, let the rest go. Then you're there at the fence.  
   *(energy -2; social +1; leadership +1; {sibling} +7; modifier inspired)*

#### Flags this batch sets, and what they open

- `hired_private_coach` (from PRO_026) → nothing reads it yet

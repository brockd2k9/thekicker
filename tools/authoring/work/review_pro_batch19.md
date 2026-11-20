# PRO batch 19: quality pass (rewrites and stat fixes) (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 19: quality pass (rewrites and stat fixes)

### PRO_371 The Financial Mistake
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** An investment or a purchase wasn't as smart as it looked.

An investment or a purchase wasn't as smart as it looked.

1. **Cut the loss**: You cut the loss and learn from it. It stings for a month.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
2. **Tell {love_interest}**: You tell {love_interest} the whole thing. It's a hard talk and a good one.  
   *(social +2; charisma +1; {love_interest} +3; modifier loose)*
3. **Make it back**: You throw yourself into work to forget it. It doesn't quite work.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `honest_advisor` or `bad_venture`, shown as "having learned about money the hard way"*  
   **Call the advisor you trust**: You call the one advisor who has always told you the truth. You make a plan, and you stick to it.  
   *(energy +1; intelligence +2; modifier focused)*

### PRO_372 The Family Conversation
- **Category:** family  
- **Window:** age 26-29, once, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** (no cast)  
- **Premise:** You and {love_interest} talk about starting a family, and neither of you knows the right time.

You and {love_interest} talk about starting a family, and neither of you knows the right time.

1. **Say now**: You both say now. It's terrifying and right.  
   *(social +2; charisma +1; {love_interest} +5; modifier loose)*
2. **Make a plan**: You make a plan around the contract and the seasons.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
3. **Wait**: You agree to wait. The conversation comes back every few months.  
   *(energy +2; fun +1; modifier rested)*

### PRO_373 The Family Business
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A relative wants your money and your name to expand the family business.

A cousin wants your money and your name to expand the family store into three towns. The whole family is waiting for your answer.

1. **Invest**: You invest and put your name on the sign. The opening is a family party, and for the first time in years, everyone is in one room.  
   *(social +2; charisma +1; {parent} +4; modifier loose; sets `family_business`)*
2. **Invest, quietly**: You put in money but keep your name off the sign. It's safer, and your cousin is a little hurt by the distance.  
   *(energy -1; resilience +1; intelligence +2; modifier focused; sets `family_business`)*
3. **Say no**: You say no, kindly and clearly. Thanksgiving is quieter this year, and you're sure it was the right answer, mostly.  
   *(energy +2; fun +1; modifier rested)*

### PRO_374 The Memorabilia Deal
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A collector wants to pay you to sign five hundred footballs.

A collector wants to pay you to sign five hundred footballs.

1. **Sign them all**: You sign all five hundred in one long afternoon. Your hand hurts for days.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
2. **Sign some for charity**: You sign them and ask for a hundred extra for the children's hospital.  
   *(social +2; charisma +1; followers +2; Team +1; modifier loose)*
3. **Pass**: You pass. You'd rather sign them for kids at the fence.  
   *(energy +2; fun +1; modifier rested)*

### PRO_375 The Young Kicker's Question
- **Category:** social  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A college kicker emails you for career advice, and it's a good question.

A college kicker emails you for career advice, and it's a good question.

1. **Write a real answer**: You write a long, honest answer. He prints it out.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
2. **Call him**: You call him instead. You talk for an hour.  
   *(social +2; charisma +1; Team +3; modifier loose)*
3. **Send a short reply**: You send a short reply and a good luck.  
   *(energy +2; fun +1; modifier rested)*

### PRO_376 The Retirement Savings
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A financial advisor reviews your long-term plan and asks a question you can't answer.

A financial advisor reviews your long-term plan and asks a question you can't answer.

1. **Learn the answer**: You learn the answer, and the next ten questions too.  
   *(energy -1; resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Bring {love_interest}**: You bring {love_interest} to the next meeting. You make the plan together.  
   *(social +2; charisma +1; {love_interest} +3; modifier loose)*
3. **Trust the advisor**: You trust the advisor and stop asking questions.  
   *(energy +2; fun +1; modifier rested)*

### PRO_377 The Public Appearance
- **Category:** media  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** You're asked to attend a high-profile event in a suit you don't own yet.

You're asked to attend a high-profile event in a suit you don't own yet.

1. **Go and enjoy it**: You buy the suit and enjoy the night. You meet people you didn't know existed.  
   *(social +2; charisma +1; followers +2; {love_interest} +3; modifier loose)*
2. **Go and network**: You go with a plan and leave with three useful numbers.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
3. **Skip it**: You skip it and stay home. Nobody notices but your agent.  
   *(energy +2; fun +1; modifier rested)*

### PRO_378 The Family Holiday
- **Category:** family  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The schedule lands on a family holiday again.

The schedule lands on a family holiday again.

1. **Bring the holiday to you**: You fly the family in for the weekend. Dinner is in a hotel, and it's still home.  
   *(social +2; charisma +1; {parent} +4; modifier loose)*
2. **Keep your routine**: You keep your routine and call between meetings.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Celebrate a day late**: You plan a celebration for the day after. Everyone says it's fine. It mostly is.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*

### PRO_379 The Teammates' Dispute
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Two teammates ask you to settle an argument, which means picking a side.

Two teammates ask you to settle an argument, which means picking a side.

1. **Make them talk it out**: You make them talk it out in front of you. It works.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
2. **Pick the right side**: You listen and pick the side that's right. One of them sulks for a week.  
   *(energy -1; intelligence +2; {coach} +2; Team -1; modifier focused)*
3. **Stay out of it**: You tell them to settle it themselves.  
   *(energy +2; fun +1; modifier rested)*

### PRO_380 The Sponsored Posts
- **Category:** media  
- **Window:** age 26-29, once, followers tier verified  
- **Cast:** (no cast)  
- **Premise:** A company offers to pay for sponsored posts, and the product is fine, mostly.

A company offers to pay for sponsored posts, and the product is fine, mostly.

1. **Take the deal**: You take the deal. The posts do well and feel a little hollow.  
   *(energy -2; resilience +1; ambition +2; 2 SP; followers +3; modifier dialed_in)*
2. **Test it first**: You use the product for a month before you post. It's actually good.  
   *(energy -1; resilience +1; intelligence +2; followers +2; modifier focused)*
3. **Decline**: You decline. Your page stays yours.  
   *(energy +2; fun +1; modifier rested)*

### PRO_381 The Long-Term Commitment
- **Category:** family  
- **Window:** age 26-29, once, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** (no cast)  
- **Premise:** {love_interest} wants to talk about where you'll live after football.

{love_interest} wants to talk about where you'll live after football.

1. **Let {love_interest} choose**: You let {love_interest} choose. It's the right call.  
   *(social +2; charisma +1; {love_interest} +5; modifier loose)*
2. **Make a list together**: You make a list together. Your hometown wins.  
   *(energy -1; resilience +1; intelligence +2; {parent} +1; modifier focused)*
3. **Not yet**: You say there's time. {love_interest} says there isn't always.  
   *(energy +2; fun +1; modifier rested)*

### PRO_382 The Injury Prevention Program
- **Category:** health  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The club wants you on a new training and recovery routine.

The club wants you on a new training and recovery routine.

1. **Follow it exactly**: You follow it exactly. Your legs feel younger by October.  
   *(energy -1; toughness +1; intelligence +2; {coach} +2; modifier focused)*
2. **Add your own work**: You do it and add your own work on top. You're stronger, and tired.  
   *(energy -2; ambition +2; 2 SP; modifier dialed_in)*
3. **Do the minimum**: You do the minimum. The trainers notice.  
   *(energy +2; fun +1; modifier rested)*

### PRO_383 The Younger Teammate's Mistake
- **Category:** team  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A rookie makes a mistake and comes to you, not the coaches.

A rookie makes a mistake and comes to you, not the coaches.

1. **Walk him to the coaches**: You walk him to the coaches and stand beside him while he tells them.  
   *(energy -2; social +1; leadership +2; 1 SP; Team +2; modifier inspired)*
2. **Listen first**: You listen first and help him find the words.  
   *(social +2; charisma +1; Team +3; modifier loose)*
3. **Tell him what you'd do**: You tell him exactly what you'd do. He does it.  
   *(energy -1; intelligence +2; {coach} +2; modifier focused)*

#### Flags this batch sets, and what they open

- `family_business` (from PRO_373) → PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `honest_advisor` (from PRO_376) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice); PRO_371 The Financial Mistake (locked choice)

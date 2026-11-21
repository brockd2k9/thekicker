# Money patch round (R3)

Money values on 95 scenes (the 91 R3 scenes plus the league fines in PRO_124, 125, 172, 268), savings gates, two forced follow-ups, text fixes. Dry run and import: 0 errors, 0 warnings, 0 lint notes.


## Money patch

### PRO_003 Your First Real Payday
- **Category:** money  
- **Window:** age 21-25, club season 1, once  
- **Cast:** {parent}  
- **Premise:** Your first real paycheck lands, and it has more zeros than {parent} made in a year.

Your first real paycheck lands, and it has more zeros than {parent} made in a year. Your phone starts buzzing before you've finished reading the number.

1. **Save most of it**: You put most of it into an account you promise not to touch and buy one thing: a mattress that isn't from a dorm. It's dull, and you sleep very well.  
   *(energy +2; fun -1; intelligence +2; modifier rested; sets `saved_rookie_check`)*
2. **Spend it like you earned it**: You buy the car, the watch and dinner for the whole rookie class. It feels incredible for about a month.  
   *(fun +4; social +2; intelligence -1; charisma +1; followers +2; modifier loose; sets `spent_rookie_check`)*
3. **Pay off {parent}'s debts**: {parent} refuses twice when you ask for the number on every bill, then gives in the third time. The calls home sound different after that: lighter, and a lot longer.  
   *(fun -1; leadership +1; {parent} +7; modifier inspired; sets `paid_family_debt`)*
4. 🔒 *locked: needs `saved_first_paycheck` or `helped_family_financially`, shown as "having handled your first paychecks wisely"*  
   **Split it the way you always have**: You do what you did with your first paycheck at sixteen, just with more zeros: a third saved, a third home, a third yours. It's an old habit, and it holds.  
   *(fun +1; intelligence +1; {parent} +3; modifier focused; sets `saved_rookie_check`)*

### PRO_007 Where You Live
- **Category:** money  
- **Window:** age 21-25, club season 1, once  
- **Cast:** (no cast)  
- **Premise:** Half the roster lives in the same glass tower downtown. The rent is a quarter of your salary.

Half the roster lives in the same glass tower downtown, with a rooftop pool and a doorman who knows everyone's name. The rent is a quarter of your salary.

1. **Rent something modest**: You rent a two-bedroom twenty minutes from the facility, above a bakery. The teammates call it 'the bakery'. You save more in a month than some of them save in a year, and the commute is short.  
   *(fun -1; social -1; energy +2; intelligence +2; modifier rested; sets `lived_modestly`)*
2. **Move into the tower**: The lease in the tower gets signed on a Tuesday. The pool parties are legendary and the elevators are full of teammates, and the rent comes out of every check like a tax.  
   *(fun +3; social +3; intelligence -1; Team +2; modifier loose; sets `lived_large`)*
3. **Room with a teammate**: Splitting a place with another rookie is cheaper and louder than you planned. You never eat dinner alone, and you learn more about him than you ever wanted to.  
   *(social +2; energy -1; charisma +1; Team +1; modifier loose)*

### PRO_026 The Coach for Hire
- **Category:** training  
- **Window:** age 26-29, offseason, once  
- **Cast:** (no cast)  
- **Premise:** A private coach who rebuilt three pro kickers offers you his offseason, for a price.

A private kicking coach who rebuilt three pro careers offers you his whole offseason: his field, his methods, his famous temper. The price is a number your agent repeats twice.

1. **Hire him for the summer**: The summer belongs to him: brutal drills at dawn, video at night, a temper that softens by July. Your leg feels new by August, and you've never been so tired.  
   *(energy -3; power +2; ambition +1; 3 SP; modifier dialed_in; sets `hired_private_coach`)*
2. **Stay with the club's staff**: The club's staff knows your body, so you stay. It's less glamorous and steady, and the trainers quietly appreciate the vote of confidence.  
   *(energy -1; accuracy +1; resilience +1; intelligence +1; {coach} +2; modifier focused)*
3. **Take most of the summer off**: Most of the summer, off: lake, family, sleep. You come back rested, a little rusty, and happier than you've been in a long time.  
   *(energy +3; fun +2; {parent} +1; modifier rested)*
4. 🔒 *locked: needs `vetted_trainer` or `trained_with_alum`, shown as "having checked out trainers before"*  
   **Check his record first**: Two of his former clients, called before you decide. Both rave about the results and warn you about the temper. You hire him with your eyes open, and it shows.  
   *(energy -2; intelligence +1; ambition +1; 2 SP; modifier dialed_in; sets `hired_private_coach`)*

### PRO_031 The Incentive Clause
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Your contract pays a bonus if you hit 90 percent this season, and your agent keeps texting you the math.

Your contract pays a bonus if you hit ninety percent this season, and your agent keeps texting you the math: where you are, what's left, what one miss would mean.

1. **Ask your agent to stop**: No more math, please, you text back. You'll find out at the end of the season, and the next three months are quieter.  
   *(energy -1; resilience +2; intelligence +1; modifier focused)*
2. **Chase the number**: The number goes on your locker, and you chase it every practice. It's motivating, and some nights it's all you can think about.  
   *(energy -2; accuracy +1; ambition +2; 2 SP; modifier dialed_in)*
3. **Forget the bonus**: Forgotten, on purpose, and the agent's texts go unread. If it comes, it comes, and you kick more freely than you have in years.  
   *(energy +2; fun +2; modifier rested)*

### PRO_040 The Hometown Discount
- **Category:** money  
- **Window:** age 26-29, once, needs `contract_year`  
- **Cast:** (no cast)  
- **Premise:** The club offers less than the market, and asks you to take it because you're family here.

The club offers less than the market and asks you to take it because 'you're family here'. The general manager says it twice, and puts his hand on your shoulder the second time.

1. **Take the discount**: The discount, accepted. The club remembers it, and so does the locker room, and you never quite know if it was generous or foolish.  
   *(social +2; charisma +1; leadership +1; **retention +2**; Team +2; modifier loose)*
2. **Meet in the middle**: The middle ground, found by your agent over two weeks of calls. Everyone is a little unhappy and fine, which your agent says is how you know it's fair.  
   *(resilience +1; intelligence +2; modifier focused)*
3. **Test the market next spring**: Next spring's open market, it is. You kick like it all year, and every practice feels like an audition for twenty-nine other clubs.  
   *(energy -2; power +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_056 The Big Check
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The signing bonus clears. Your phone lights up with cousins.

Your signing bonus clears on a Tuesday. Within an hour your phone lights up with cousins, a car dealer, two realtors and someone from high school who wants to 'catch up'.

1. **Put it somewhere boring**: You put almost all of it somewhere boring and tell everyone it's tied up. Nobody believes you, and nobody can get to it.  
   *(fun -1; energy +2; intelligence +2; modifier focused; sets `saved_big_check`)*
2. **Celebrate properly**: The whole family, on a trip, and then the house with the pool. It's the best summer anyone in your family has had, and the pool bill arrives in September.  
   *(fun +4; social +2; intelligence -1; {parent} +4; modifier loose; sets `spent_big_check`)*
3. **Set aside a family share**: You set aside one share for family and tell them it's the only one. The cousins grumble. {parent} quietly approves.  
   *(social -1; leadership +1; intelligence +1; {parent} +2; modifier focused; sets `saved_big_check`)*

### PRO_057 The Honest Advisor
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A financial advisor recommended by your snapper walks you through a plan so boring it's almost funny.

A financial advisor recommended by your long snapper walks you through a plan so boring it's almost funny: index funds, a budget, a rule about cars.

1. **Hire the boring advisor**: You hire the advisor and follow the rule about cars, mostly. Nothing exciting happens to your money, which is the point.  
   *(fun -1; intelligence +2; leadership +1; modifier focused; sets `honest_advisor`)*
2. **Ask for more upside**: More upside, you say. The advisor says no, explains why in plain words and doesn't budge. You hire them anyway, partly because they wouldn't budge.  
   *(ambition +1; intelligence +1; modifier focused; sets `honest_advisor`)*
3. **Pass for now**: You say you'll think about it and never call back. The money sits in a checking account doing nothing at all.  
   *(energy +1; fun +1; modifier rested)*

### PRO_059 The Missing Money
- **Category:** money  
- **Window:** once, needs `trusted_flashy_advisor`, savings 800000+  
- **Cast:** (no cast)  
- **Premise:** Your accounts are lighter than they should be, and the advisor isn't answering.  
- **Note:** Works now with flags and stress; the stolen 40% lands with R3.

Your bank calls on a Tuesday morning: a transfer you didn't authorize, the third one this year. The advisor with the boat isn't answering, and his office number goes to a recording.

1. **Call a lawyer before practice**: You make the calls in the parking lot. By Friday the accounts are frozen, a forensic accountant is on it, and you know the number: four of every ten dollars you've earned.  
   *(energy -3; fun -3; resilience +1; intelligence +2; leadership +1; modifier stressed; sets `advisor_stole`)*
2. **Call {parent}**: You call {parent} and say the number out loud. He's quiet for a long time, then tells you about the year he lost his job and what he did the next morning. You write it all down.  
   *(energy -1; fun -2; charisma +1; {parent} +5; modifier stressed; sets `advisor_stole`)*
3. **Keep it quiet and fix it yourself**: You tell nobody, including the three teammates he also manages. You tell them everything's fine, which is a lie, and spend the season doing math in the training room.  
   *(energy -4; fun -1; ambition +2; Team -3; modifier distracted; sets `advisor_stole`, `hid_the_loss`)*
4. 🔒 *locked: needs `good_agent`, shown as "having hired an agent who tells you the truth"*  
   **Call your agent first**: Your agent has seen this before. Within an hour you have a lawyer, an accountant and a plan, and a warning to call the other three players he manages before the news does.  
   *(energy -2; fun -2; intelligence +1; leadership +1; Team +2; modifier stressed; sets `advisor_stole`)*

### PRO_060 The Lawsuit
- **Category:** money  
- **Window:** once, needs `advisor_stole`  
- **Cast:** (no cast)  
- **Premise:** Your lawyer says you can sue the advisor. It'll take three years and your name will be in every story.

Your lawyer says you can sue the advisor who took your money. It'll take three years, cost a fortune in fees, and your name will be in every story about it.

1. **Sue him**: You file. The case drags on for years, you testify twice, and some of the money comes back long after you've stopped counting on it.  
   *(energy -3; fun -2; leadership +1; ambition +1; intelligence +1; followers -1; modifier stressed; sets `sued_advisor`)*
2. **Report him and move on**: You file the report with the regulators and let them handle it. He's barred from the business a year later. You never see a dime.  
   *(energy -1; intelligence +1; modifier focused)*
3. **Join with the other players**: You call the three teammates he also handled. Together you hire one lawyer and split the bill. It's slower, and nobody faces it alone.  
   *(energy -2; social +2; leadership +2; Team +3; modifier inspired; sets `sued_advisor`)*

### PRO_061 The Restaurant
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night.

An old college teammate wants your name and your money on a steakhouse downtown. He has a chef, a location and a business plan he wrote last night, and he keeps saying 'can't miss.'

1. 🔒 *locked: needs `savings >= 500000`, shown as "with enough saved"*  
   **Put your money in**: You sign the papers at his kitchen table. Your name goes up in lights in March, and you eat there twice a week because it's yours.  
   *(fun +3; social +2; intelligence -1; followers +2; modifier inspired; sets `opened_restaurant`)*
2. **Ask to see real numbers**: A real plan, the lease and an accountant's review, please. He's offended, sends half of it, then stops answering. You keep your money and lose some of a friendship.  
   *(social -2; fun -1; intelligence +2; leadership +1; modifier focused)*
3. **Lend your name, not your money**: The opening night, a photo line and nothing more: your name, not your money. He's disappointed and says so, then takes the deal.  
   *(energy -1; social +1; charisma +1; followers +1; modifier loose)*
4. 🔒 *locked: needs `honest_advisor`, shown as "having an advisor you trust"*  
   **Send it to your advisor**: Your advisor reads the plan in an afternoon and circles four things that would sink it. You send the list to your old teammate as a favor. He fixes two of them and opens without you.  
   *(energy -1; social +1; intelligence +2; leadership +1; modifier focused)*

### PRO_062 The Restaurant Is Failing
- **Category:** money  
- **Window:** once, needs `opened_restaurant`  
- **Cast:** (no cast)  
- **Premise:** The steakhouse is losing money every week, and your name is on the sign.

The steakhouse is losing money every week. The chef quit, your old teammate isn't answering, and your name is still lit up over the door.

1. **Close it now**: You close it, pay the staff two weeks' wages from your own pocket and take your name down yourself. It hurts, and it's over.  
   *(fun -2; energy -1; leadership +2; charisma +1; modifier drained; sets `bad_venture`)*
2. **Put more money in**: Another check, to keep it open one more season. The food gets better, the reviews get kinder, and the losses don't change at all.  
   *(fun +1; ambition +1; intelligence -1; modifier stressed; sets `bad_venture`)*
3. **Sell your share to your partner**: You sell your share to your old teammate for whatever he can pay. You lose most of it and keep the friendship, barely.  
   *(social +1; intelligence +1; modifier focused; sets `bad_venture`)*
4. 🔒 *locked: needs `honest_advisor`, shown as "having an advisor you trust"*  
   **Let your advisor run the exit**: Your advisor finds a buyer for the lease and the equipment within a month. You lose money, but a lot less than you would have.  
   *(energy -1; intelligence +2; modifier focused; sets `bad_venture`)*

### PRO_063 The Car Dealership
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A dealership wants you as a partner: your face on the billboards, your money in the lot.

A car dealership wants you as a partner: your face on the billboards, your money in the lot, and a guaranteed parking space with your name on it.

1. 🔒 *locked: needs `savings >= 600000`, shown as "with enough saved"*  
   **Become a partner**: You sign. Your face goes up on the highway, and every teammate calls you about a deal. The dealership's books are the dealer's business, until they aren't.  
   *(fun +2; ambition +2; charisma +1; followers +3; modifier spotlight; sets `dealership_partner`)*
2. **Do the ads, skip the ownership**: You agree to the billboards for a flat fee and keep your money out of the lot. It's less exciting and a lot safer.  
   *(intelligence +2; leadership +1; followers +2; modifier focused)*
3. **Keep your name off the lot**: No dealership, no billboard, no parking space. Your money stays where it is, and the dealership signs a weatherman, whose face you see every day.  
   *(energy +2; fun +1; resilience +1; modifier rested)*

### PRO_064 The Friend's Start-Up
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** {best_friend}  
- **Premise:** {best_friend} is starting a company and asks you to be the first investor.

{best_friend} is starting a company, a real one with a plan, a lawyer and two hires, and asks you over dinner to be the very first investor. They've practiced the pitch.

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

{best_friend}'s company is close: one more check and they make it to the next stage, or they fold this month. They call you late at night, trying hard not to ask.

1. **Write the last check**: You write it. Six months later the company is bought, and your share turns into the best investment of your life. {best_friend} cries on the phone.  
   *(fun +3; ambition +1; {best_friend} +8; modifier inspired)*
2. **Hold the line**: You don't put in more. The company makes it anyway with someone else's money, and your share is smaller than it could have been. You're still glad for them.  
   *(energy +1; intelligence +1; {best_friend} +2; modifier focused)*
3. **Help them find another investor**: Two people from the owner's gala, introduced to {best_friend} by you over coffee. One of them writes the check within a week.  
   *(energy -2; social +2; charisma +1; leadership +1; {best_friend} +6; modifier focused)*
4. 🔒 *locked: needs `honest_advisor`, shown as "having an advisor you trust"*  
   **Ask your advisor to look first**: Your advisor reads the numbers and says this one is real. You write the check with your eyes open, and it pays.  
   *(energy -1; fun +2; intelligence +1; {best_friend} +6; modifier confident)*

### PRO_066 The Tax Letter, Pro
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** You owe taxes in every state you played a road game in, and your old accountant didn't file most of them.

You owe taxes in every state where you played a road game, and your old accountant didn't file most of them. The letters have started to arrive.

1. **Hire a sports accountant**: You hire an accountant who does nothing but athletes. It takes a month of paperwork and a painful check, and it's done.  
   *(energy -2; fun -1; intelligence +2; leadership +1; modifier stressed)*
2. **Ignore the letters**: The letters go in a drawer. They come back with penalties, then with a lawyer's name on the envelope, and every one of them makes your stomach drop.  
   *(energy +1; fun +1; intelligence -2; modifier distracted)*
3. **Ask the veterans at lunch**: Every veteran at the lunch table has a horror story and a phone number. You call the one who sounds least scary, and she fixes it in a month.  
   *(energy -1; social +1; intelligence +1; modifier focused)*
4. 🔒 *locked: needs `saved_first_paycheck`, shown as "having handled money carefully since your first paycheck"*  
   **Pay it from the account you never touch**: You pay it from the account you've never touched since your first paycheck. It's a big number, and it doesn't keep you up at night.  
   *(fun -1; intelligence +1; modifier rested)*

### PRO_067 Family Asks for Money
- **Category:** family  
- **Window:** repeats (15-week cooldown)  
- **Cast:** {sibling}, {parent}  
- **Premise:** {sibling} needs money and doesn't want {parent} to know.

{sibling} needs money, a real amount, and doesn't want {parent} to know. They call late, after the kids are asleep, and apologize three times before they say the number.

1. **Help, and keep the secret**: You send the money quietly and keep the secret. {sibling} pays you back slowly over two years, a little every month, and never forgets that you didn't ask any questions.  
   *(social +2; charisma +1; {sibling} +5; modifier inspired)*
2. **Help, with a plan**: You help, with conditions: an advisor, a budget, a plan written down. {sibling} grumbles and agrees, and it works well enough that they never need to call you like that again.  
   *(intelligence +2; leadership +1; {sibling} +2; modifier focused; sets `honest_advisor`)*
3. **Ask them to tell {parent}**: You gently ask them to tell {parent}. They do, eventually, after a hard week, and the family solves it together, slowly, around the same table where all the big things get solved.  
   *(resilience +2; leadership +1; {sibling} -1; {parent} +2; modifier drained)*

### PRO_068 The Cousin Nobody Remembers
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Someone from your hometown with your last name and a business idea is waiting by your car.

Someone from your hometown with your last name, a folder of drawings and a business idea is waiting by your car after practice. He says you met at a wedding when you were nine.

1. **Hear the pitch, then check it**: You listen, take the paperwork and have your agent look at it. The idea is real; the numbers aren't. You say no with reasons.  
   *(energy -1; intelligence +2; leadership +1; modifier focused)*
2. **Buy him lunch, not the idea**: You buy him lunch and talk about family for an hour. You don't invest, and he leaves happier than he came.  
   *(social +2; fun +1; charisma +1; {parent} +3; {sibling} +1; modifier loose)*
3. **Say no before he finishes**: No, before he's finished his first sentence, and you get in your car. It's quick and a little cold, and {parent} hears about it from three relatives by Sunday.  
   *(energy +2; ambition +1; {parent} -1; modifier rested)*

### PRO_069 {parent}'s House
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** {parent}  
- **Premise:** You could pay off {parent}'s mortgage this week. He's told you not to, twice.

You could pay off {parent}'s mortgage this week with one transfer. He's told you not to, twice, in the voice he used when you were twelve.

1. **Do it anyway**: You pay it off and tell him after. He's furious for an hour and doesn't speak at dinner. A month later, he still has the letter from the bank on his fridge.  
   *(social +2; fun +1; leadership +1; {parent} +6; modifier loose)*
2. **Ask what he'd accept**: You ask {parent} what he would actually accept. He agrees to a loan with no interest, insists on paying it back, and pays it back early.  
   *(energy -1; resilience +1; intelligence +2; {parent} +3; modifier focused)*
3. **Respect his wish**: You respect his wish and let it go. He's proud of that, in his quiet way, and you send money to his church instead.  
   *(energy +2; fun +1; charisma +1; modifier rested)*
4. 🔒 *locked: needs `helped_family_financially`, shown as "having helped your family with money before"*  
   **Do it the way that worked before**: You set it up the way you did last time: quietly, through the bank, with his name on everything. He grumbles and signs.  
   *(energy -1; intelligence +1; {parent} +5; modifier inspired)*

### PRO_070 The Foundation
- **Category:** community  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** Your charity foundation's director is spending more on galas than on kids.

Your charity foundation's director is spending more on galas than on kids: the books show a ballroom, a band and a photographer, and only two new programs all year.

1. **Replace the director**: A new director, hired by you after a hard conversation with the old one. You run the next year closely, and the programs double.  
   *(energy -2; leadership +3; 1 SP; Team +2; modifier inspired; sets `started_foundation`)*
2. **Audit the books**: An outside audit, every line, with new rules on spending afterward. The director stays, chastened, and the money starts reaching kids.  
   *(resilience +1; intelligence +2; modifier focused; sets `started_foundation`)*
3. **Trust the director**: The galas raise money too, you tell yourself, and you let it run. The next annual report is glossy and thin.  
   *(energy +2; fun +1; modifier rested)*

### PRO_071 The Watch, the Car, the Chain
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** Team  
- **Premise:** The locker room has a dress code nobody wrote down, and it costs about your rookie salary.

The locker room has a dress code nobody wrote down: the watch, the car, the chain. It costs about what you made as a rookie.

1. **Keep up**: You buy the watch and the car. You look the part, and every month the statement looks a little worse.  
   *(fun +3; social +2; intelligence -1; followers +2; modifier spotlight)*
2. **Opt out with a joke**: The same old truck shows up every day, and you call it 'retro'. It becomes a running joke in the locker room, and nobody actually minds; one rookie copies you.  
   *(social +1; charisma +1; intelligence +1; modifier loose)*
3. **Ask a veteran who went broke**: The oldest player on the roster takes his watch off when you ask about it, sets it on the table and tells you what it cost him in the end.  
   *(energy -1; intelligence +2; Team +1; modifier focused)*

### PRO_072 Broke in Your Thirties
- **Category:** money  
- **Window:** age 30-33, once, opens on `advisor_stole` / `bad_venture` / `spent_big_check` / `lived_large` / `hid_the_loss`, savings under 1500000  
- **Cast:** (no cast)  
- **Premise:** The money's gone faster than the career, and you have a mortgage, a family and maybe three seasons.

The money's gone faster than the career. There's a mortgage, a family, a car payment, and maybe three seasons left in your leg, if you're very lucky.

1. **Make a hard plan**: An honest advisor and a hard plan: a smaller house, no new cars, a budget taped to the fridge. It hurts, and it works.  
   *(resilience +2; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Tell your family everything**: You tell your family everything at the kitchen table. It's the worst conversation of your life and the best one; nobody leaves.  
   *(social +2; leadership +1; {parent} +3; modifier loose)*
3. **Kick for one more contract**: You decide to kick for one more contract like your family depends on it. It does, and every practice feels heavier.  
   *(energy -2; toughness +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_073 The Pension Meeting
- **Category:** team  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** The players' union holds a meeting about pensions and retirement plans. Six players show up.

The players' union holds a meeting about pensions and retirement plans in a hotel conference room. Six players show up, and you're the youngest by four years.

1. **Go and take notes**: Notes on everything, for two hours. It's boring and important, and you understand your pension for the first time in your career.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Bring twelve teammates next time**: Twelve teammates at the next meeting, recruited by you one at a time. The union rep looks at you like you've performed a miracle.  
   *(energy -2; leadership +3; 1 SP; Team +2; modifier inspired)*
3. **Skip it**: Retirement feels far away, so you skip it. The six who went start a group chat, and you're not in it.  
   *(energy +2; fun +1; modifier rested)*

### PRO_123 The Card Game
- **Category:** social  
- **Window:** once  
- **Cast:** (no cast)  
- **Premise:** The card game in the back of the team plane has a buy-in bigger than your first car.

The card game in the back of the team plane has a buy-in bigger than your first car, and the veterans running it have saved you the seat by the window. The flight is four hours long.

1. **Put the headphones on**: Headphones on, seat back, and four hours of sleep while the shouting carries on behind you. You land rested, and nobody says a word about it the next morning.  
   *(energy +2; health +1; modifier rested)*
2. **Sit up front with the specialists**: Up front with the snapper and {holder}, a crossword and a bag of pretzels. It's the quietest flight of the season, and the three of you finish the puzzle.  
   *(social +1; fun +1; intelligence +1; {holder} +2; modifier loose)*
3. **Take the seat**: The window seat is yours for the flight. By the time the wheels touch down you owe a veteran more than your signing bonus, and the team's security director has heard about the game by lunch.  
   *(social +2; energy -2; charisma +2; leadership -2; **retention -2**; {coach} -2; modifier stressed; **conduct bad**; sets **strike** `pro_gambling_debt`)*
4. 🔒 *locked: needs `honest_advisor`, shown as "with an honest advisor in your corner"*  
   **Text your advisor a photo of the stakes**: You text your advisor a photo of the buy-in, and the reply comes back in four words: absolutely not, go sleep. You laugh, and you do exactly that.  
   *(resilience +1; intelligence +2; modifier rested)*

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

The league office wants a meeting about the strike on your record. It isn't a conversation; it's a hearing, in a gray room, with a lawyer from the players' union at your side.

1. **Accept the suspension**: You accept two games and don't appeal. You practice with the scout team, and the veterans notice that you show up every day anyway.  
   *(energy -2; fun -3; leadership +2; **retention -2**; **suspended 2 games**; Team +2; modifier drained; **conduct bad**; sets `pro_second_chance`; clears every pro strike)*
2. **Fight it**: You appeal and say the league is making an example of you. The appeal fails, the suspension stands, and now the whole league knows your name for the wrong reason.  
   *(fun -2; ambition +2; leadership -2; **retention -4**; **suspended 2 games**; followers -3; {coach} -6; modifier stressed; **conduct scandal**; sets `pro_second_chance`, `pro_character_concerns`; clears every pro strike)*

### PRO_135 The Veteran Minimum
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You're making a third of what you made five years ago, and the rookie next to you has your old car.

You're on the veteran minimum, a third of what you made in your prime. The rookie at the next locker drives your old car; he bought it from the dealer you sold it to.

1. **Laugh about it with him**: Laughing about it together, at the lockers. He offers to sell it back to you at a discount, and you decline, and it becomes your running joke.  
   *(social +2; fun +2; {backup} +3; modifier loose)*
2. **Adjust the budget**: A smaller budget, built at the kitchen table, and nobody in the house misses the things you cut. You're surprised how little you needed.  
   *(resilience +1; intelligence +2; {love_interest} +1; modifier focused)*
3. **Kick for the next deal**: Every practice, like the next deal depends on it, because it does. It's motivating, and on bad days it's heavy.  
   *(energy -2; power +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_163 The Divorce
- **Category:** family  
- **Window:** once, needs `married`, opens on `lied_about_affair` / `affair_public` / `confessed_affair` / `marriage_strained`  
- **Cast:** {love_interest}  
- **Premise:** The lawyers have the paperwork ready, and {love_interest} wants to talk before anyone signs anything.  
- **Note:** Divorce clears married and the other partner flags; the money cost lands with savings (R3). People: kids in the text only.

The lawyers have the paperwork ready on the kitchen table. {love_interest} wants to talk before anyone signs anything, and for the first time in months, neither of you is angry.

1. **Sign it, and be kind**: You sign it together and make the hard parts fair: the house, the holidays, the friends. It hurts for a long time, {parent} calls every night that month, and you're proud of how you did it.  
   *(fun -3; social -1; resilience +1; leadership +2; {love_interest} +3; {parent} +2; modifier drained; sets `divorced`; clears `married`, `engaged`, `new_partner`, `made_long_distance_work`, `committed_to_relationship`)*
2. **Fight over everything**: Every chair, every account, every weekend becomes a fight through lawyers. It takes a year, costs a fortune and leaves you both strangers who used to be married.  
   *(fun -4; energy -3; toughness +1; ambition +1; {love_interest} -6; {parent} -2; modifier stressed; sets `divorced`; clears `married`, `engaged`, `new_partner`, `made_long_distance_work`, `committed_to_relationship`)*
3. **Ask for one more try**: One more try, you ask, with a counselor and no secrets. {love_interest} takes a long breath and agrees to six months. The papers go back in the drawer.  
   *(energy -2; social +1; charisma +1; intelligence +1; {love_interest} +4; modifier focused)*

### PRO_172 The Investigation
- **Category:** career  
- **Window:** once, needs `pro_betting_scandal`  
- **Cast:** {coach}, Team, {parent}  
- **Premise:** Two investigators from the league office are in the general manager's conference room, and they've asked for you by name.  
- **Note:** Follow-up: suspend_weeks 3 (the cap), retention, followers, scandal; character concerns for the pros (pro_character_concerns). Release follows through the discipline chain (R7).

Two investigators from the league office are waiting in the general manager's conference room with a thick folder and a recorder, and they've asked for you by name.

1. **Tell them everything**: Everything, start to finish, and then your signature on the statement. The suspension is long, and the investigators write that you cooperated fully, which matters later more than you know.  
   *(fun -3; resilience +2; leadership +1; **retention -4**; **suspended 6 games**; followers -4; Team +1; modifier drained; **conduct scandal**; sets `pro_character_concerns`)*
2. **Bring a lawyer and say little**: A lawyer beside you, and as few words as possible. It drags out for weeks, every word is careful, and the suspension lands anyway, slightly longer.  
   *(energy +1; fun -2; intelligence +2; **retention -5**; **suspended 8 games**; followers -5; modifier stressed; **conduct scandal**; sets `pro_character_concerns`)*
3. **Deny it**: You deny it, even with the phone records on the table in front of you. The suspension is the longest the league gives, and the whole locker room reads about it on the same morning.  
   *(ambition +2; charisma +1; leadership -3; **retention -6**; **suspended 11 games**; followers -7; {coach} -6; Team -4; modifier stressed; **conduct scandal**; sets `pro_character_concerns`)*
4. **Call {parent} that night**: You cooperate, and then you call {parent} that night and tell the whole story. It's the hardest call you've made, and {parent} stays on the line until you're ready to sleep.  
   *(social +2; fun -3; **retention -4**; **suspended 6 games**; followers -5; {parent} +3; modifier drained; **conduct scandal**; sets `pro_character_concerns`)*

### PRO_233 The Business Grows
- **Category:** career  
- **Window:** once, needs `invested_in_friend`  
- **Cast:** {love_interest}  
- **Premise:** The start-up you backed is opening offices in three cities and wants your face on the launch.

The start-up you backed for a friend is opening offices in three cities, and the founders want your face on the launch: billboards, a video, and a speech at the opening party.

1. **Do the launch**: You do the billboards, the video and the speech, with a lot of practice in the mirror. The launch is a success, your friend hugs you on stage, and your phone fills up with offers.  
   *(energy -2; charisma +2; ambition +1; followers +3; {best_friend} +2; modifier spotlight)*
2. **Stay a silent investor**: You stay a silent investor and let the founders be the faces. It's their company and their moment, and they respect you more for knowing it.  
   *(resilience +2; intelligence +1; modifier focused)*
3. **Ask for a seat at the table**: An advisory seat instead of a billboard is what you ask for. The meetings are long and interesting, and you learn more about business in a year than in your whole career.  
   *(energy -1; intelligence +2; leadership +1; modifier focused; sets `life_after_football`)*

### PRO_234 The Partner Who Cheats You
- **Category:** career  
- **Window:** once, needs `dealership_partner`, savings 500000+  
- **Cast:** {love_interest}  
- **Premise:** Your dealership partner has been cooking the books.

Your accountant calls on a Sunday, which never happens. Your partner in the dealership has been cooking the books for a year, and some of the money missing has your name on the paperwork.

1. **Go to the police**: You go to the police on Monday with the accountant and every document. It's slow and public and humiliating, and it's the only way your name comes out clean.  
   *(resilience +2; leadership +1; modifier stressed; sets `business_fraud_victim`)*
2. **Settle it quietly**: You settle it quietly through the lawyers and take the loss. Nobody outside the family hears about it, and you lie awake for weeks doing sums in the dark.  
   *(energy -2; intelligence +1; charisma +1; modifier stressed; sets `business_fraud_victim`)*
3. **Confront your partner**: You drive to your partner's house and confront them on the porch. They cry and apologize and promise to pay it back, and you never see a cent of it.  
   *(toughness +2; ambition +1; modifier stressed; sets `business_fraud_victim`)*
4. 🔒 *locked: needs `honest_advisor`, shown as "with an honest advisor in your corner"*  
   **Call your advisor**: Your advisor has a plan before you've finished the first sentence: freeze the accounts, call the lawyer, call the police. It's still a bad month, and it's a contained one.  
   *(resilience +1; intelligence +2; modifier focused; sets `business_fraud_victim`)*

### PRO_235 A Franchise Offer
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** {love_interest}  
- **Premise:** A restaurant chain offers you a franchise with your name on it, this time with professionals running it.

A restaurant chain offers you a franchise with your name on it: real professionals running it this time, a real contract, and your face on the menu.

1. **Do it with professionals**: Signed, with professionals running it and two lawyers reading everything first. It opens in March, and the burger named after you is surprisingly good.  
   *(resilience +1; intelligence +2; leadership +1; modifier focused; sets `franchise_owner`)*
2. **Bring family in**: {sibling}, brought in to keep an eye on things for you. It's a family project now, and {sibling} turns out to be good at it.  
   *(social +2; fun +1; leadership +1; {sibling} +3; modifier loose; sets `franchise_owner`)*
3. **Stay out of restaurants**: No franchise for you. You have enough to think about already, and you've watched what restaurants did to two teammates' savings accounts.  
   *(energy +2; fun +1; intelligence +1; modifier rested)*

### PRO_236 Selling the Business
- **Category:** career  
- **Window:** once, opens on `franchise_owner` / `started_foundation`  
- **Cast:** {love_interest}  
- **Premise:** Someone wants to buy what you built, for more than you ever made kicking.

Someone wants to buy what you built, for more than you ever made kicking. The offer is on your kitchen table in a blue folder, and the buyer wants an answer by Friday.

1. **Sell it**: You sign on Friday, after one long night of reading every page. It feels strange to let it go, and also very light, like setting down a bag you'd stopped noticing.  
   *(energy +2; fun +1; modifier rested)*
2. **Keep it**: You keep it, because it's yours and it means something to the people who work there. The buyer is surprised, the staff are relieved, and you go back to work on Monday.  
   *(resilience +1; leadership +2; modifier inspired)*
3. **Sell part and stay on**: You sell a share and stay on to run it, with a partner who knows more than you do. It's a compromise, and it gives the thing you built room to grow.  
   *(intelligence +2; ambition +1; {sibling} +1; modifier focused)*

### PRO_261 The Business Shortcut
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** {coach}, Team  
- **Premise:** Your business is losing money, and your partner has a way to make the books look better.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.

Your business is losing money, and your partner has a way to make the books look better before the bank's review: two invoices, a little creative timing, and nobody gets hurt.

1. **Refuse and call the accountant**: No, and a call to your accountant that afternoon. The bank review is painful and honest, and the loan survives with tougher terms.  
   *(resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Close the business clean**: The business, closed cleanly, with every bill paid and every employee given a reference. It's a loss, and you can look everyone in the eye.  
   *(fun -2; leadership +2; {parent} +1; modifier drained)*
3. **Sign the invoices**: The two invoices, signed at your partner's kitchen table. The bank is satisfied for a year, until an auditor notices the dates and calls your agent before he calls you.  
   *(fun +1; ambition +2; intelligence -2; leadership -2; **retention -3**; followers -3; {coach} -3; modifier stressed; **conduct scandal**; sets **strike** `pro_business_fraud`)*

### PRO_262 Betting to Cover It
- **Category:** money  
- **Window:** age 34-37, once, savings under 1000000  
- **Cast:** {coach}, Team  
- **Premise:** You're short on money, and an old acquaintance says one good week of bets would fix everything.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.

Your savings are thinner than anyone knows: an investment gone wrong, a house you can't sell, a payment due in March. An old acquaintance from home calls with an answer: one good week of bets, through him, and the hole closes.

1. **Hang up and call your advisor**: You hang up and call your advisor the same hour. The plan is slow and humbling, the house goes on the market at a loss, and you sleep for the first time in weeks.  
   *(fun -2; resilience +2; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Tell {parent} how bad it is**: {parent} drives four hours that night and sits at your kitchen table with a calculator and a pot of coffee. By morning there's a plan, and you're not alone with it.  
   *(fun -1; social +2; leadership +1; {parent} +5; modifier drained)*
3. **Sell the thing you love**: The car you bought with your first big check goes to a dealer for less than it's worth. It stings every time you pass one like it, and the March payment is covered.  
   *(fun -3; energy +1; toughness +1; ambition +1; modifier rested)*
4. **Give him the money and the games**: The money and the names of three games go to him, none of them yours. For a month it works. Then the league's investigators find the account, and the commissioner's letter says a full season.  
   *(fun +2; energy +3; leadership -3; intelligence -2; **retention -6**; **suspended 11 games**; followers -6; {coach} -6; Team -4; modifier stressed; **conduct scandal**; sets **strike** `pro_betting_scandal`)*

### PRO_266 The Insurance Claim
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** {coach}, Team  
- **Premise:** Your agent suggests an insurance claim on an injury that's mostly healed.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps.

Your agent suggests an insurance claim on a hamstring injury that's mostly healed: a doctor he knows, a form, and a payout that would cover two years of your kids' school.

1. **Refuse and change agents**: No, and you start looking for a new agent the same week. It's awkward and costly, and you sleep fine.  
   *(resilience +1; toughness +1; leadership +2; modifier focused)*
2. **Ask the union's lawyer**: The union's lawyer, asked quietly what the agent is suggesting. She explains exactly what it is, and you thank her and never mention it again.  
   *(resilience +1; intelligence +2; modifier focused)*
3. **File the claim**: The form, signed in the agent's office. The payout comes in March; the investigators come in June, with questions about the doctor and a copy of your practice schedule.  
   *(fun +2; energy +2; intelligence -2; leadership -2; **retention -3**; followers -3; {coach} -3; modifier stressed; **conduct scandal**; sets **strike** `pro_insurance_fraud`)*

### PRO_268 The Veteran Hearing
- **Category:** team  
- **Window:** age 34-37, once, needs `pro_warning`, opens on any pro strike  
- **Cast:** {coach}, Team  
- **Premise:** Another hearing at your age. The league says experience should have known better.  
- **Note:** Clean no with its own payoff in every scene; never shown using anything. The strike feeds the team-discipline steps. Needs a current strike, like PRO_125; a veteran's second hearing runs longer (R9).

Another hearing, years after the first one, and the union lawyer is younger than your snapper. The league's letter says it plainly: a veteran with your experience should have known better.

1. **Accept it without appeal**: Four games, no appeal. You practice with the scout team every day of it, early, and the young players notice how a veteran takes his punishment.  
   *(energy -1; resilience +1; leadership +2; **retention -3**; **suspended 4 games**; {coach} +1; modifier drained; **conduct bad**; sets `pro_second_chance`; clears every pro strike)*
2. **Fight it**: You appeal and say the league is making an example of an old player. The appeal fails, the suspension doubles to eight games, and the story follows you to every road city.  
   *(fun -2; ambition +2; leadership -2; **retention -5**; **suspended 8 games**; followers -4; {coach} -3; modifier stressed; **conduct scandal**; sets `pro_second_chance`, `pro_character_concerns`; clears every pro strike)*
3. **Accept it, and talk to the rookies**: Four games, accepted, and you ask the club to let you speak to the rookies about what it cost. The room is very quiet, and two of them thank you privately.  
   *(energy -3; social +1; leadership +3; **retention -3**; **suspended 4 games**; Team +3; modifier inspired; **conduct bad**; sets `pro_second_chance`; clears every pro strike)*

### PRO_287 Family Reunion, Pro Edition
- **Category:** family  
- **Window:** age 30-33, offseason, once  
- **Cast:** {parent}, {sibling}  
- **Premise:** The family reunion. Everyone wants a photo, and one uncle wants a loan.

The family reunion, at a lake. Everyone wants a photo with you, an aunt wants your autograph for her mail carrier, and one uncle wants a loan for a boat.

1. **Take every photo**: Every photo, every autograph, and a promise to the uncle that you'll think about it. It's exhausting and warm, and {parent} beams all day.  
   *(social +3; energy -1; {parent} +3; modifier loose)*
2. **Say no to the loan kindly**: No to the boat, kindly and clearly. The uncle sulks through dessert, and three cousins thank you privately for saying it.  
   *(intelligence +2; leadership +1; {parent} +1; modifier focused)*
3. **Leave early**: An early exit, before the speeches. You'll see everyone next time, and {sibling} texts you a photo of the uncle's face.  
   *(energy +2; fun +1; {sibling} +1; modifier rested)*

### PRO_303 A Midnight Call From an Old Teammate
- **Category:** money  
- **Window:** once, pro_seasons 10+  
- **Cast:** Team  
- **Premise:** A teammate from your rookie year is broke and calls you at midnight.

A teammate from your rookie year calls at midnight. He's broke, the house is gone, and he doesn't know who else to call. He apologizes four times before he says why.

1. **Help him get back up**: A plan, not a check: an advisor you trust, a job interview with a friend, a loan for the first three months. He's on his feet by summer.  
   *(intelligence +2; leadership +1; {best_friend} +1; modifier focused)*
2. **Send what he needs tonight**: The money he needs, sent before you hang up. He cries on the phone, and you don't ask when he'll pay it back.  
   *(social +2; charisma +1; Team +2; modifier inspired)*
3. **Listen, and point him to help**: An hour of listening, and the number for the union's assistance program. It's the right help, and you wonder afterward if it was enough.  
   *(energy -1; resilience +2; intelligence +1; charisma +1; modifier drained)*

### PRO_310 The Big Second Contract
- **Category:** money  
- **Window:** once, needs `re_signed`, pro_seasons 4+  
- **Cast:** Team  
- **Premise:** Your agent says this is the contract that matters, and the club agrees, eventually.

Your agent says this is the contract that matters, the one that sets the rest of your life, and the club agrees, eventually, after a month of silence.

1. **Hold firm for your number**: Three tense weeks of holding firm. You get your number, and lose some sleep getting it, and the general manager doesn't smile at you for a while.  
   *(energy -2; resilience +1; toughness +1; ambition +2; {coach} -1; modifier stressed)*
2. **Take the fair deal early**: A fair deal, taken early, and you stop thinking about it entirely. Your agent calls it smart, and means it, and you sleep well all spring.  
   *(energy +1; intelligence +2; {coach} +1; modifier rested)*
3. **Decide it at home**: The decision, made at home, at the kitchen table. The number matters less than you thought, and you sign happily.  
   *(social +2; resilience +1; {parent} +2; modifier loose)*

### PRO_325 The First Endorsement
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A local business offers you your first sponsorship: a billboard, a few appearances, a small check.

A local car wash offers you your first sponsorship: a billboard by the highway, four appearances in a giant foam sponge costume and a check that's small, but yours.

1. **Sign with the car wash**: The billboard goes up by the highway a week later, a little blurry, and every teammate sends you a photo of it. The holder sets it as his phone background.  
   *(fun +2; charisma +1; followers +3; modifier spotlight)*
2. **Ask your agent first**: Your agent negotiates the appearances down to two and the check up by half. The owner still makes you wear the sponge costume once, and you secretly love it.  
   *(energy +1; intelligence +2; leadership +1; followers +2; modifier focused)*
3. **Keep your weeks clear**: No billboard, no sponge suit, no appearances. Your weeks stay clear for kicking, your account stays the same, and the car wash signs a local weatherman instead.  
   *(energy +1; ambition +1; 1 SP; modifier rested)*

### PRO_326 The Old Friend's Request
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Someone from home asks you for money, and you can tell it took a lot to ask.

{best_friend} calls from home on a Sunday night and asks you for money. It's quiet for a long time before they ask, and you can hear how much it costs them to say it.

1. **Send it that night**: The money is in {best_friend}'s account before you hang up, and you never ask what it's for. They cry on the phone, and so, after the call, do you.  
   *(fun -1; social +1; charisma +1; {best_friend} +3; modifier inspired)*
2. **Ask what it's for**: It's rent, three months behind. Paying the landlord directly makes both of you feel better, and {best_friend} sends you a photo of the receipt with a heart on it.  
   *(energy -1; intelligence +1; leadership +1; {best_friend} +2; modifier focused)*
3. **Say no kindly**: No, as kindly as you can manage. It's true and it isn't, and the next phone call with {best_friend} is shorter, and the one after that doesn't come.  
   *(energy +1; ambition +1; {best_friend} -2; modifier stressed)*

### PRO_338 The Equipment Upgrade
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A sales rep wants you on expensive new training equipment, with a price to match.

A sales rep corners you after practice with expensive training equipment: a sensor suit, a kicking machine, and an app that charts every kick you've ever taken. He has a tablet and a very good smile.

1. **Buy the full setup**: All of it, delivered Thursday. The data is incredible, your living room is full of machines, and the bill is the kind you read twice.  
   *(energy -2; ambition +2; 3 SP; modifier dialed_in)*
2. **Use what the club has**: The club's staff charts you with what they already have. It's less fancy and nearly as good, and the trainer likes being asked.  
   *(energy -1; accuracy +1; intelligence +2; {coach} +1; modifier focused)*
3. **Keep it simple**: Your leg doesn't need an app, you decide. The rep leaves his card, your weeks stay simple, and you never think about sensor suits again.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_341 The Family Expectations
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Your family expects more now that you're earning, and they're not shy about it.

Your family expects more now that you're earning. Cousins call about cars, an uncle about a boat, and {parent} about a roof that's been leaking since you were in high school.

1. **Set a family budget**: A yearly amount for family help, set at the kitchen table with {parent}. It's an awkward hour, and it ends the guessing, and the cousins stop calling about cars.  
   *(energy -1; intelligence +2; leadership +1; {parent} +3; modifier focused)*
2. **Say yes to everything**: Yes to every request. It feels wonderful for a month, and your account feels it much longer, and nobody says thank you for the third one.  
   *(fun +2; social +1; charisma +1; intelligence -1; {parent} +4; {sibling} +3; modifier inspired)*
3. **Say not yet**: A rookie contract isn't forever money, you explain, as patiently as you can. Some of them understand. {sibling} doesn't, and says something you'll both remember.  
   *(leadership +1; ambition +1; {sibling} -2; modifier stressed)*

### PRO_342 The Unexpected Bill
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A costly bill arrives at the worst possible time.

Your car's transmission dies the week before a road trip, in the facility parking lot, in front of the whole offensive line. The repair costs more than the car is worth.

1. **Fix it**: Repaired, and a week of buses to practice in the meantime. The veterans think it's hilarious and start leaving bus schedules in your locker.  
   *(fun -1; social +1; intelligence +1; Team +1; modifier tired)*
2. **Buy something new**: A brand-new car the same afternoon. It's lovely, it smells incredible, and the payment is going to follow you around for years.  
   *(fun +3; energy +1; intelligence -1; modifier loose)*
3. **Ride with a teammate**: Rides with a teammate until you figure it out, and the drives turn into the best part of your week. By the time your car is fixed, you're friends.  
   *(social +2; energy -1; charisma +1; Team +2; modifier loose)*

### PRO_350 The Charity Donation
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A family member asks you to donate to a cause back home.

Your aunt calls from home: the church you grew up in needs a new roof, and she's sure you'll want to help. She has already told the whole congregation you're thinking about it.

1. **Give generously**: More than she asked. The church puts your name on a brass plaque by the door, which you'll be embarrassed by forever, and {parent} visits it every Sunday.  
   *(fun -1; social +1; charisma +1; leadership +1; {parent} +3; modifier inspired)*
2. **Give what you planned**: The amount in your budget, with an explanation. She's a little disappointed and grateful anyway, and the roof gets fixed by spring.  
   *(intelligence +2; {parent} +1; modifier focused)*
3. **Run a fundraiser at home**: A fundraiser in your hometown, run with {sibling}, raises twice the money with your time instead of your account. The whole town shows up.  
   *(energy -3; social +2; leadership +2; followers +2; {sibling} +3; modifier tired)*

### PRO_358 The First Big Purchase
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** You can finally afford the car you've wanted since high school.

You can finally afford the car you've wanted since you were fifteen, the one on the poster above your childhood bed. The dealer already knows your name when you walk in.

1. **Buy it and drive it home**: Bought, and driven straight home to {parent}'s driveway. He walks around it three times without speaking, then asks for the keys.  
   *(fun +3; social +1; {parent} +3; modifier loose)*
2. **Buy something sensible**: Something sensible, with good mileage, and the rest goes in the bank. It's a good car. It isn't the car, and you notice every time you see one.  
   *(fun -1; resilience +1; intelligence +2; modifier focused)*
3. **Wait one more year**: A year's wait, on purpose. The wanting fades a little, and so does the fun of it, and you're not sure whether that's wisdom or a loss.  
   *(energy +1; ambition +1; intelligence +1; modifier rested)*

### PRO_359 The Regional Endorsement
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A regional company offers you a sponsorship worth more than your rookie salary.

A regional grocery chain offers you a sponsorship worth more than your whole rookie salary: commercials, store openings, your face on cereal boxes in three states.

1. **Sign the deal**: Signed. The shoots take some weekends, the money is real, and {sibling} buys forty boxes of cereal with your face on them.  
   *(fun +2; energy -1; ambition +1; followers +3; {sibling} +2; modifier spotlight)*
2. **Strike two clauses first**: The fine print, read twice, and two clauses struck: no appearances in season, no exclusivity. They agree, and you keep your Tuesdays.  
   *(intelligence +2; leadership +1; followers +2; modifier focused)*
3. **Keep your weekends**: A pass, and your weekends stay yours. A rival kicker takes the deal, and you see his face in every aisle for a year.  
   *(energy +2; fun +1; resilience +1; modifier rested)*

### PRO_360 The Investment Pitch
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Someone pitches you an investment that sounds too good, and they know it.

A man at a charity dinner pitches you an investment: guaranteed returns, a famous partner, no risk. He's done this before, and he knows you can tell.

1. **Walk away**: You thank him and walk away. Six months later you read his name in the paper, and you pass the article to your teammates.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Ask someone you trust**: You show it to someone you trust. They laugh, then explain exactly how it works. You learn more in an hour than in a year of statements.  
   *(social +1; intelligence +1; charisma +1; {parent} +3; modifier loose)*
3. **Put money in**: You put money in. The statements look great for a while, then they stop coming, and so does he. The shame lasts longer than the loss.  
   *(fun -2; energy -1; ambition +1; 1 SP; modifier stressed; sets `bad_venture`)*

### PRO_365 The First Home Repair
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** The roof leaks the week of a road trip, and the bill is enormous.

The roof leaks the week of a road trip, all over the living room, and the repair estimate is the size of a used car. You're in a hotel two thousand miles away.

1. **Handle it from the hotel**: Contractors, insurance and photos, all handled by phone from the hotel. It gets done, expensively, and you miss a meeting doing it.  
   *(energy -2; intelligence +2; leadership +1; modifier stressed)*
2. **Ask {parent} to oversee it**: {parent} drives over with a ladder and an opinion, and oversees the whole repair. He loves being useful, and the roof is perfect.  
   *(social +1; fun +1; resilience +1; {parent} +3; modifier rested)*
3. **Patch it for now**: A tarp and a bucket for now, the real fix in the offseason. It's cheap, and you sleep under the sound of dripping all winter.  
   *(energy +1; health -1; ambition +1; modifier distracted)*

### PRO_371 The Financial Mistake
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** An investment or a purchase wasn't as smart as it looked.

An investment you were sure about turns out not to be smart: a restaurant that closed, a fund that froze, a statement you read three times in the car outside the facility.

1. **Cut the loss**: The loss, cut cleanly, and a lesson learned. It stings for a month, and then it becomes a story you tell rookies.  
   *(fun -1; resilience +2; intelligence +2; modifier focused)*
2. **Tell {parent} everything**: Everything, at the kitchen table, including the part you were embarrassed about. It's a hard talk and a good one, and you make the next decision together.  
   *(social +1; energy -1; leadership +1; {parent} +2; modifier drained)*
3. **Bury it in work**: Work, to forget it: early mornings, long sessions, no thinking. It doesn't quite work, and the statement is still in the glove box.  
   *(energy -2; power +1; ambition +2; 2 SP; modifier dialed_in)*
4. 🔒 *locked: needs `honest_advisor` or `bad_venture`, shown as "having learned about money the hard way"*  
   **Call the advisor you trust**: The one advisor who has always told you the truth gets a call that afternoon. You make a plan together, you stick to it, and the hole closes by spring.  
   *(energy +1; intelligence +2; modifier focused)*

### PRO_373 The Family Business
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A relative wants your money and your name to expand the family business.

A cousin wants your money and your name to expand the family store into three towns. The whole family is waiting for your answer, and Thanksgiving is in two weeks.

1. **Invest**: You invest and put your name on the sign. The opening is a family party, and for the first time in years, everyone is in one room.  
   *(social +2; fun +2; leadership +1; {parent} +4; modifier loose; sets `family_business`)*
2. **Invest, quietly**: You put in money but keep your name off the sign. It's safer, and your cousin is a little hurt by the distance.  
   *(resilience +1; intelligence +2; modifier focused; sets `family_business`)*
3. **Turn the cousin down**: No, as kindly and clearly as you can manage. Thanksgiving is quieter this year, and you're sure it was the right answer, mostly.  
   *(energy +1; fun -1; ambition +1; {parent} -1; modifier rested)*

### PRO_374 The Memorabilia Deal
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A collector wants to pay you to sign five hundred footballs.

A memorabilia collector wants to pay you to sign five hundred footballs in one afternoon, in a hotel ballroom, with a man counting and a camera to prove each one is real.

1. **Sign all five hundred**: Five hundred signatures in one long afternoon. Your hand hurts for days, the check is large, and the man counting never smiles once.  
   *(energy -2; toughness +1; ambition +2; modifier tired)*
2. **Add a hundred for charity**: All five hundred, plus a hundred extra for the children's hospital auction. The auction raises more than your check, and the collector pays for the extra hundred.  
   *(social +1; leadership +2; charisma +1; followers +2; modifier inspired)*
3. **Sign for kids at the fence**: No ballroom, no counting man. You'd rather sign for kids at the practice fence, for free, and you do, every Thursday.  
   *(energy +1; fun +2; social +1; modifier loose)*

### PRO_376 The Retirement Savings
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A financial advisor reviews your long-term plan and asks a question you can't answer.

A financial advisor reviews your long-term plan and asks a question you can't answer: what does your life cost after football, per year, in today's money?

1. **Learn the answer**: The answer, learned over two weeks of spreadsheets, and the next ten questions too. You understand your own money for the first time, and it's calming.  
   *(intelligence +2; leadership +1; modifier focused; sets `honest_advisor`)*
2. **Bring {parent} to the next meeting**: {parent} comes to the next meeting with a legal pad and better questions than yours. You make the plan together, and he insists on paying for lunch.  
   *(social +2; intelligence +1; {parent} +3; modifier loose)*
3. **Trust the advisor**: The advisor knows best, you decide, and stop asking questions. It's easy and restful, and you never learn the number.  
   *(energy +2; fun +1; modifier rested)*

### PRO_384 The Personal Trainer
- **Category:** training  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A private trainer could change your offseason, for a price.

A private trainer who works with three Olympic athletes could change your whole offseason, for a price that makes your advisor wince. They have one opening.

1. **Hire the trainer**: Hired, for the summer. It's brutal and scientific, and you come back to camp faster, leaner and slightly afraid of the trainer.  
   *(energy -3; power +1; toughness +1; ambition +1; 3 SP; modifier dialed_in)*
2. **Ask for a trial week**: A trial week first. It's good, so you hire them for half the summer, and keep the other half for your own work.  
   *(energy -1; accuracy +1; intelligence +2; 1 SP; modifier focused)*
3. **Train the way you always have**: Your own routine, the one that got you here. It's familiar and cheaper, and you wonder all summer what you're missing.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_394 The Retirement Plan
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** You sit down and work out how much you'll need after football.

You sit down at the kitchen table with a calculator and a yellow pad and try to work out how much you'll need after football. The number is bigger than you expected.

1. **Do the math**: The math, done properly with an honest advisor over three meetings. It's sobering and useful, and you finally know what 'enough' looks like.  
   *(resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Do it with {parent}**: {parent} sits beside you with a second calculator and decades of experience. You make the plan together, and it's better for it.  
   *(social +2; leadership +1; {parent} +2; modifier loose)*
3. **Leave it for next year**: Next year, you decide, and the yellow pad goes in a drawer. The number keeps growing in your head anyway.  
   *(energy +2; fun +1; modifier rested)*

### PRO_400 The Expensive Lifestyle
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** Your household's expenses have quietly doubled.

Your household's expenses have quietly doubled in two years: a second car, a bigger house, three subscriptions to things nobody watches, and a gardener for a garden you never visit.

1. **Cut back together**: An evening with the statements and a highlighter. Some things go, and nobody misses them, and the household feels lighter.  
   *(intelligence +2; leadership +1; modifier focused)*
2. **Make a plan at home**: The plan, made at home, out loud, with everyone in the house. It's an awkward talk and a relief, and the budget goes on the fridge.  
   *(social +2; resilience +1; {parent} +1; modifier loose)*
3. **Let it ride for now**: Later, you'll deal with it later. The statements keep coming, a little bigger each month, and you stop opening them on Mondays.  
   *(energy +2; fun +1; modifier distracted)*

### PRO_401 The Advisor's Concern
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** Your financial advisor questions one of your investments, carefully.

Your financial advisor slides one line of your statement across the table and asks, carefully, whether you still want to be in it. It's the investment a teammate talked you into.

1. **Listen and adjust**: You listen, ask the questions you skipped the first time, and move most of the money out. It costs you a little, and you sleep better.  
   *(resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Get a second opinion**: You show it to someone you trust before deciding. They read it twice, sigh, and explain the part you didn't understand. You get out together.  
   *(social +1; intelligence +1; charisma +1; {parent} +3; modifier loose)*
3. **Keep it**: It stays in your portfolio. You like the idea and the teammate, and you tell yourself the advisor is being careful. The statements keep arriving.  
   *(energy +1; fun +2; ambition +1; modifier rested)*

### PRO_421 The Family Financial Decision
- **Category:** family  
- **Window:** age 30-33, once, opens on `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married`  
- **Cast:** (no cast)  
- **Premise:** You and {love_interest} disagree about a major purchase.

You and {love_interest} disagree about a major purchase: a lake house, two hours away, that one of you loves and the other thinks you'll never use.

1. 🔒 *locked: needs `savings >= 600000`, shown as "with enough saved"*  
   **Let {love_interest} decide**: Their decision, fully. It's the right call, and you know it the first weekend you sit on the dock together.  
   *(social +2; fun +1; {love_interest} +4; modifier loose)*
2. **Sleep on it for a month**: A month, before anyone decides anything at all. The decision makes itself in the end, and neither of you has to win the argument.  
   *(resilience +1; intelligence +2; modifier focused)*
3. **Make your case**: Your case, made carefully at the kitchen table with a spreadsheet and a chart. You win, and the house is very quiet for a whole day.  
   *(leadership +1; ambition +2; {love_interest} -2; modifier confident)*

### PRO_429 The Old Teammate's Request
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A former teammate asks you to back his new venture.

A former teammate is starting a business and asks you to back him. He's earnest, he's prepared, and he's never run anything in his life.

1. **Back it with conditions**: You back it with conditions, a lawyer and a quarterly meeting. He grumbles about the paperwork and thanks you for it later.  
   *(intelligence +2; leadership +1; modifier focused; sets `business_owner`)*
2. **Back him fully**: You back him fully, because he's your friend. It's a risk, and he calls after every small win like a kid with a report card.  
   *(social +2; fun +1; Team +4; modifier loose; sets `business_owner`)*
3. **Say no**: You say no, kindly. He understands, mostly, and you both pretend at the next reunion that it didn't change anything.  
   *(energy +1; resilience +1; ambition +1; modifier rested)*

### PRO_432 The Veteran's Discount
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** The club asks you to take less to stay.

The club asks you to take less to stay, a lot less, because 'you're family here'. The general manager says it twice and puts a hand on your shoulder the second time.

1. **Take the discount**: The discount, accepted, because you want to finish here. The locker room notices, and so does the front office, and it feels right most days.  
   *(social +2; leadership +1; **retention +2**; Team +2; modifier inspired)*
2. **Counter with a fair number**: A counter, fair and calm, through your agent. They meet you two-thirds of the way, and you sign without hard feelings.  
   *(intelligence +2; charisma +1; modifier focused)*
3. **Look elsewhere**: Elsewhere, then. You thank them sincerely and start packing your locker in your head, and two clubs call by the end of the week.  
   *(resilience +1; ambition +2; {coach} -1; modifier stressed)*

### PRO_437 The Retirement Savings Review
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You go over your finances again with a different question in mind.

You go over your finances again with your advisor, but this time the question is different. Not 'how much can I spend', but 'how long does this have to last'.

1. **Plan for forty years**: Forty years, planned on a long spreadsheet with the advisor. It's sobering, and for the first time the numbers feel like a life, not a score.  
   *(resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. 🔒 *locked: needs `made_long_distance_work` or `committed_to_relationship` or `new_partner` or `engaged` or `married`, shown as "with someone at home to plan with"*  
   **Bring {love_interest} in**: {love_interest} at the table, with their own questions, which are better than yours. You leave with a plan you both believe.  
   *(social +2; leadership +1; {love_interest} +3; modifier inspired)*
3. **Trust the plan you have**: The plan you already have, trusted for another year. Your advisor nods, mostly satisfied, and schedules a careful check-in for next spring, in pencil.  
   *(energy +2; fun +1; modifier rested)*

### PRO_445 The Business Offer
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** A former teammate offers you a role in his business.

A former teammate offers you a role in his business after football: a gym chain, three locations, a partner's title. He wants your name now and your time later.

1. **Join as a partner**: A partner, with your name on the door. The gyms do well, and you spend your Tuesdays learning about payroll.  
   *(leadership +2; ambition +1; modifier confident; sets `business_owner`)*
2. **Invest quietly**: Money, but no name and no title on anything. It's safer, and your old teammate understands, mostly, after a long lunch.  
   *(resilience +1; intelligence +2; modifier focused; sets `business_owner`)*
3. **Say not yet**: After football, you tell him, you'll talk properly. He says the offer stands, and you believe him completely, and you shake on it.  
   *(energy +2; fun +1; Team +1; modifier rested)*

### PRO_455 After Football, in the Family Firm
- **Category:** family  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** Your family wants you in a business after football.

Your family wants you in the family business after football: the hardware store {parent} built, three towns now, with a desk already set up with your name on it.

1. **Say yes for after**: Yes, for after football. {parent} cries on the phone, and you start learning the business on Tuesday mornings in the offseason.  
   *(social +2; leadership +1; {parent} +5; modifier inspired; sets `family_business`)*
2. **Invest, but don't work there**: Money to expand, but your own path after football. The family understands, mostly, and the store grows to four towns.  
   *(resilience +1; intelligence +2; {parent} +1; modifier focused; sets `family_business`)*
3. **Say you don't know yet**: Honestly, you don't know yet, you tell them. The desk stays right there, waiting, and {sibling} jokes at every holiday about taking it over.  
   *(energy +1; fun +1; resilience +1; {sibling} +2; modifier rested)*

### PRO_463 The Investment Decision
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** You consider investing heavily in life after football.

Your advisor brings a proposal: a large investment in your life after football, a training facility with your name on it, a business you'd run when your leg finally says no.

1. 🔒 *locked: needs `savings >= 1500000`, shown as "with enough saved"*  
   **Build the facility**: The facility, built over two years, with a kicking field and a gym and your name over the door. It's the biggest bet you've ever made, and it feels like a future.  
   *(energy -1; ambition +2; leadership +2; modifier inspired; sets `business_owner`)*
2. **Start smaller**: Something smaller first: two clinics a summer, rented fields, a real waiting list. If it works, you'll build; if not, you'll have learned cheaply.  
   *(resilience +1; intelligence +2; modifier focused)*
3. **Keep your money safe**: Safe, for now, where it is. Your advisor agrees, a little disappointed, and the idea stays on a napkin in your desk drawer.  
   *(energy +2; fun +1; modifier rested)*

### PRO_481 The Financial Freedom Question
- **Category:** career  
- **Window:** age 38-41, once  
- **Cast:** (no cast)  
- **Premise:** You ask whether you have enough to stop.

A financial planner asks the question across a small round table, with a folder of charts open between you: do you have enough to stop? You realize you've never actually asked it out loud.

1. **Go through every number**: Every account, every debt, every promise to family, gone through line by line for three hours. The answer is clearer than you feared, and you drive home thinking about it.  
   *(resilience +1; intelligence +2; modifier focused; sets `life_after_football`)*
2. **Ask {sibling} to sit in**: You ask {sibling} to sit in, because they're better with money than you'll ever be. They ask the hard questions, and the planner is visibly relieved.  
   *(social +2; intelligence +1; {sibling} +2; modifier focused; sets `life_after_football`)*
3. **Put it off another season**: Another season first, you tell the planner, and close the folder. The question follows you home anyway, and you lie awake with it longer than you'd admit.  
   *(power +1; ambition +2; modifier stressed)*
4. 🔒 *locked: needs , shown as "having saved carefully"*  
   **Show the planner the old savings**: The planner opens the account you set up years ago and goes quiet, then laughs. You have more than enough, it turns out, because a younger you was careful.  
   *(fun +1; resilience +2; modifier rested; sets `life_after_football`)*

### PRO_482 Partners in Something New
- **Category:** career  
- **Window:** age 38-41, once  
- **Cast:** (no cast)  
- **Premise:** A former teammate wants you as a partner.

A former teammate wants you as a partner in something new: a sports-performance gym in a strip mall, with his savings, your name on the sign, and a business plan printed at a copy shop.

1. **Go in as a partner**: You go in as a partner, with lawyers, a real contract and an accountant. The gym opens in the spring, and the sign with your name on it is slightly crooked.  
   *(ambition +2; leadership +1; modifier stressed; sets `business_owner`)*
2. **Lend your name only**: Your name on the sign, and nothing else: no money, no decisions. He's disappointed, then grateful, and the gym does fine without you worrying about it.  
   *(resilience +1; charisma +2; modifier rested)*
3. **Say no kindly**: No, kindly, over a long lunch: you're not ready for the next thing yet. He understands, and asks again a year later, and you're glad he did.  
   *(energy +2; intelligence +1; modifier rested)*
4. 🔒 *locked: needs `business_fraud_victim`, shown as "having been cheated by a business partner"*  
   **Check everything first**: You've been cheated by a partner before, so you check everything: his books, his lease, his references. It all holds up, and you sign with a clear head.  
   *(intelligence +3; modifier focused; sets `business_owner`)*

### PRO_483 Opening an Academy
- **Category:** career  
- **Window:** age 38-41, once  
- **Cast:** (no cast)  
- **Premise:** You consider opening a training academy.

You've been thinking about opening a kicking academy for kids: a field, a few coaches, and a program for the ones who can't afford private lessons. A realtor has found you a field with a broken scoreboard.

1. 🔒 *locked: needs `savings >= 800000`, shown as "with enough saved"*  
   **Buy the field**: You buy the field, fix the scoreboard and hire two coaches. The first summer camp has forty kids, half of them on scholarships, and the noise is wonderful.  
   *(social +1; leadership +2; ambition +1; modifier inspired; sets `business_owner`)*
2. **Start small, rent first**: A rented field on Sundays first, and a single coach. It's small and it works, and you learn what an academy actually needs before spending anything.  
   *(intelligence +2; charisma +1; modifier focused)*
3. **Wait until you're done playing**: Not yet: an academy deserves your full attention, and you don't have it to give. You write the plan down and put it in a drawer to wait for you.  
   *(health +1; resilience +2; modifier rested)*
4. 🔒 *locked: needs `reported_tampering`, shown as "having reported tampering in college"*  
   **Write the rules first**: You write the academy's rules first, about money, recruiters and honesty, because you've seen what happens without them. Parents notice, and the waiting list fills.  
   *(leadership +2; intelligence +1; modifier inspired; sets `business_owner`)*

### PRO_498 The Retirement Financial Plan
- **Category:** career  
- **Window:** age 38-41, once  
- **Cast:** (no cast)  
- **Premise:** You start moving your finances toward life after football.

Your accountant wants to start moving your finances toward life after football: fewer risks, more savings, a plan that assumes the paychecks stop. There's a spreadsheet with three tabs labeled 'soon'.

1. **Make the plan now**: The plan, made now, tab by tab, over three long afternoons. It's dull and important, and when it's done you feel a weight lift that you hadn't known you were carrying.  
   *(resilience +1; intelligence +2; modifier focused; sets `life_after_football`)*
2. **Keep one risk**: One risk kept on purpose: the business idea you've been sitting on for years. The accountant sighs and builds a safe plan around it, and you're grateful.  
   *(ambition +2; charisma +1; modifier stressed)*
3. **Hand it to someone you trust**: You hand the whole thing to {sibling}, who has a head for numbers and a lot of patience. They do it better than you would have, and tease you about it forever.  
   *(social +2; energy +1; {sibling} +2; modifier rested)*
4. 🔒 *locked: needs , shown as "having saved carefully"*  
   **Discover you're already there**: The accountant runs the numbers twice and looks up: you're already there, because you lived small for all those years. You drive home in your old car, laughing.  
   *(fun +1; resilience +2; modifier rested)*

### PRO_505 The Legacy Foundation
- **Category:** career  
- **Window:** age 38-41, once  
- **Cast:** (no cast)  
- **Premise:** You consider a foundation for young athletes.

You've been thinking about a foundation for young athletes from families like yours: equipment, camp fees, rides to practice. A lawyer has sent the paperwork, and the first page asks for a name.

1. **Name it after your first coach**: You name it after your first coach, who cries on the phone when you tell them. The first fifty kids get cleats and camp fees by summer.  
   *(social +2; leadership +1; modifier inspired; sets `started_foundation`)*
2. **Start it quietly**: No name on the door and no gala: just checks for camp fees, sent quietly to coaches who know which kids need them. Nobody knows it's you, which is the point.  
   *(resilience +2; intelligence +1; modifier rested; sets `started_foundation`)*
3. **Wait until you retire**: Not yet: a foundation deserves your full attention. You file the paperwork in a drawer labeled 'after', and it waits there patiently.  
   *(energy +1; ambition +2; modifier focused)*
4. 🔒 *locked: needs `refused_improper_help`, shown as "having refused improper help in college"*  
   **Write the rules about money first**: You write strict rules first, about who can give and what they get, because you once refused help that came with strings. The coaches trust it immediately.  
   *(leadership +2; intelligence +1; modifier inspired; sets `started_foundation`)*

### PRO_526 The Retirement Financial Review
- **Category:** career  
- **Window:** age 42+, once  
- **Cast:** (no cast)  
- **Premise:** You review whether you're ready to stop.

Your financial advisor wants to review whether you're ready to stop: one meeting, every account, and a single question at the end that she's written in capital letters at the top of the page.

1. **Answer the question honestly**: Every account opened, every number read aloud, and at the end you answer her question honestly. The answer is yes, and hearing it said frightens and frees you at once.  
   *(resilience +1; intelligence +2; modifier drained; sets `life_after_football`)*
2. **Bring {sibling}**: {sibling} comes along, because they ask better questions than you do. The meeting runs long, and {sibling} takes notes that you'll use for years.  
   *(social +2; intelligence +1; {sibling} +2; modifier focused)*
3. **Postpone the meeting**: Postponed, for a season, with an apology. The question waits in your inbox, polite and patient, and you think about it every time you see the envelope icon.  
   *(power +1; ambition +2; modifier stressed)*
4. 🔒 *locked: needs , shown as "having saved carefully"*  
   **Laugh at the answer**: She runs the numbers and laughs, because a younger you was so careful there's nothing to worry about. You drive home lighter than you've felt in years.  
   *(fun +1; resilience +2; modifier rested)*

### PRO_558 The Meal Money
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** The per diem envelope on the first road trip is thicker than your college scholarship check.

The per diem envelope on the first road trip is thicker than any scholarship check you ever got in college. The veterans are already planning where theirs is going tonight.

1. **Put it in the bank**: The whole envelope goes in the bank, and you eat the team meals. By December the road trips have quietly paid for your offseason trainer.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
2. **Take the rookies out**: The rookie class eats like kings for one night on your envelope. It's gone by dessert, and four rookies will remember it for years.  
   *(social +3; fun +1; charisma +1; {backup} +2; modifier loose)*
3. **Treat yourself, a little**: A good dinner alone, a good book from the airport and a long nap. It feels like being a grown-up, and you send {parent} a photo of the dessert.  
   *(energy +2; fun +2; health +1; {parent} +1; modifier rested)*

### PRO_559 Rookie Year Taxes
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Your first tax bill as a pro is a number nobody prepared you for.

Your first tax bill as a pro arrives in a thick envelope: a number nobody prepared you for, due in a month, with forms from every state you played a road game in.

1. **Hire an athletes' accountant**: An accountant who only works with athletes takes the whole envelope off your hands. It's done in two weeks, correctly, and you learn what a 'jock tax' is.  
   *(fun -1; resilience +1; intelligence +2; modifier focused)*
2. **Ask a veteran at lunch**: One veteran at lunch gives you his accountant's number and a story about his first year that makes you laugh until your stomach hurts.  
   *(social +2; charisma +1; intelligence +1; Team +2; modifier loose)*
3. **Do it yourself**: A long weekend with spreadsheets and coffee. It's stressful, probably right, and you feel strangely proud when you click the last button.  
   *(energy -2; fun -1; leadership +1; intelligence +2; ambition +1; modifier drained)*

### PRO_560 Free Cleats
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A shoe company offers free cleats and a small contract, if you wear them on camera.

A shoe company offers you free cleats and a small contract, if you wear them on camera. The cleats are bright orange, and your old pair has been with you since college.

1. **Sign and lace up**: Signed, and the orange cleats arrive the next day. They're fine, the check pays for your offseason training, and the veterans call you 'traffic cone'.  
   *(fun +1; ambition +2; 1 SP; followers +2; modifier confident)*
2. **Test them for a week**: A week of testing before you sign anything. They're good, so you sign, with a clause that lets you wear your old pair if they ever hurt.  
   *(energy -1; accuracy +1; intelligence +2; modifier focused)*
3. **Keep your old cleats**: Your old cleats stay. Your feet are happy and your account is the same, and the equipment manager pats them like an old dog.  
   *(energy +1; resilience +2; modifier rested)*

### PRO_569 The Card Signing
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** A trading card company wants your signature on a thousand cards in one afternoon.

A trading card company wants your signature on a thousand cards in one afternoon, in a hotel conference room with bad coffee and a man counting.

1. **Sign all thousand**: A thousand signatures in four hours. Your hand hurts for two days, the check is nice, and your signature gets worse with every hundred.  
   *(energy -2; ambition +2; 1 SP; modifier tired)*
2. **Sign some for charity**: Two hundred cards, and a full set donated to a children's hospital raffle. The raffle raises more than the check would have.  
   *(social +1; leadership +1; charisma +1; followers +2; modifier inspired)*
3. **Pass on the cards**: No cards this time. Your hand is grateful, and the company signs a punter instead, who sends you a smug photo of his check.  
   *(energy +2; fun +1; resilience +1; modifier rested)*

### PRO_594 The Rookie Payday Dinner
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Your rookie class decides to celebrate your first full paycheck together.

Your rookie class decides to celebrate your first full paychecks together at a restaurant you can't pronounce, with a menu that doesn't have prices on it.

1. **Go and enjoy it**: The whole night, every course. The bill is absurd, the night is worth it, and you all take a photo with the chef.  
   *(social +2; fun +3; Team +2; modifier loose)*
2. **Suggest a cheaper place**: A cheaper place with the same view, you suggest. Half the class comes, the rest think you're cheap, and your half has more fun.  
   *(energy -1; intelligence +2; leadership +1; {backup} +1; modifier focused)*
3. **Order in**: Takeout, alone, on the couch. Your account is happier than you are, and you see the photos the next morning.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_607 Your First Credit Card Bill
- **Category:** money  
- **Window:** age 21-25, once  
- **Cast:** (no cast)  
- **Premise:** Your first credit card statement as a pro, and you don't remember half the charges.

Your first credit card statement as a pro arrives, four pages long, and you don't remember half the charges. One of them is a subscription to a magazine about boats.

1. **Go through every line**: Every line, with a highlighter, at the kitchen table. Four subscriptions canceled, including the boat magazine, which you still don't remember ordering.  
   *(energy -1; resilience +1; intelligence +2; modifier focused)*
2. **Pay it and forget it**: Paid in full, and forgotten. The same thing happens next month, and the month after, with slightly different boats, and you stop opening the envelopes.  
   *(energy +2; fun +1; modifier rested)*
3. **Ask a veteran at lunch**: A veteran at lunch shows you the app he uses and his worst statement ever, which makes yours look like a grocery list. You laugh until it hurts.  
   *(social +2; charisma +1; intelligence +1; modifier loose)*

### PRO_632 The Raise
- **Category:** money  
- **Window:** age 26-29, once, opens on `re_signed` / `signed_new_club`  
- **Cast:** (no cast)  
- **Premise:** Your second contract is real money, and everyone you know has noticed.

Your new contract is real money, and everyone you know has noticed: old friends with ideas, cousins with emergencies, a teacher from middle school with a fundraiser.

1. **Set one rule for everyone**: One rule, for everyone, written down. It's fair, it's a little lonely, and the calls slow down within a month.  
   *(intelligence +2; leadership +1; modifier focused)*
2. **Help the ones who need it**: The people who really need it get help, quietly, and nobody else hears about it. {parent} finds out anyway and is proud.  
   *(social +1; fun +1; charisma +1; {parent} +3; modifier inspired)*
3. **Change your number**: A new phone number, given to twelve people. Things get quieter immediately, and two old friends feel shut out and say so.  
   *(energy +2; resilience +1; {best_friend} -1; modifier rested)*

### PRO_633 The House With a Yard
- **Category:** family  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** You buy a house with a yard big enough for a kicking net.

You buy a house with a backyard big enough for a kicking net. The previous owners left a swing set, a lemon tree and a note wishing you luck.

1. **Put up the net**: The net goes up the first weekend. The neighbors watch from their windows, and by Sunday their kids are shagging balls for you.  
   *(energy -1; accuracy +1; ambition +1; 1 SP; modifier dialed_in)*
2. **Throw a housewarming**: Everyone, over, the first Saturday: family, teammates, neighbors. {parent} gives the tour twice, and {sibling} falls off the swing set.  
   *(social +3; fun +2; {parent} +2; {sibling} +2; modifier loose)*
3. **Sit under the lemon tree**: Nothing, in the backyard, under the lemon tree, for a whole afternoon. It's the first time in years you've done nothing on purpose.  
   *(energy +3; health +1; modifier rested)*

### PRO_647 The Investment Club
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A group of teammates forms an investment club and wants you in.

A group of teammates forms an investment club: monthly meetings, a shared account, a lot of opinions about technology stocks. They want you in, and the first meeting is at the quarterback's house.

1. **Join the club**: Joined. The meetings are mostly jokes and some good ideas, and the account does fine, and the friendships do better.  
   *(social +2; fun +1; Team +3; modifier loose)*
2. **Join with limits**: In, with a small amount and one rule: nothing you don't understand. You end up explaining index funds to a linebacker, who becomes your biggest convert.  
   *(resilience +1; intelligence +2; {coach} +2; modifier focused; sets `honest_advisor`)*
3. **Keep money and friends apart**: Money and friends don't mix, for you. You stay out, politely, and still go to the meetings for the food.  
   *(energy +2; fun +1; resilience +1; modifier rested)*

### PRO_648 The Second Car
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** You buy a second car, and then realize you never drive the first one.

You buy a second car on a whim after a good week, a convertible in a color the salesman called 'victory'. Then you realize you haven't driven the first one in a month.

1. **Sell one of them**: One of them goes back on the market by Friday, at a loss. You feel smarter for it, and a little silly every time you see a convertible.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Give the old one to {sibling}**: The old car, keys and all, goes to {sibling}, who cries in the driveway and then honks the horn for ten straight seconds.  
   *(social +2; fun +2; {sibling} +5; modifier loose)*
3. **Keep both cars**: Both stay. They sit side by side in the driveway, shining, and the insurance bill makes you laugh out loud in a bad way.  
   *(fun +2; energy +1; charisma +1; modifier rested)*

### PRO_655 The Mortgage
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Your first mortgage, and the papers are thicker than your playbook.

Your first mortgage, and the papers are thicker than your playbook: forty pages of terms, a stack of signature tabs, and a loan officer who keeps calling you 'the athlete'.

1. **Read every page**: Every page, read, with questions about the three that matter. The loan officer is surprised and fixes one clause in your favor.  
   *(energy -1; intelligence +2; leadership +1; modifier focused)*
2. **Bring {parent} to the signing**: {parent} at the signing, with reading glasses and opinions. He's done this before and asks the questions you didn't know to ask.  
   *(social +1; fun +1; resilience +1; {parent} +3; modifier loose)*
3. **Sign where they point**: Signed where they point, every tab, in twenty minutes. You hope for the best, and for a year you're never quite sure what you agreed to.  
   *(energy +2; fun +1; ambition +1; modifier rested)*

### PRO_659 The Brand Ambassador
- **Category:** media  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A brand wants you as its regional ambassador for three years.

A sporting-goods brand wants you as its regional ambassador for three years: commercials, store openings, a signature cleat. The contract arrives with a pen taped to it.

1. **Sign for three years**: Three years, signed. It's steady money and a lot of store openings, and your signature cleat is ugly in a way you grow to love.  
   *(energy -2; ambition +2; charisma +1; followers +3; modifier spotlight)*
2. **Sign for one year**: One year, with an option for more. They agree, a little surprised, and you keep your freedom for the next negotiation and the one after.  
   *(resilience +1; intelligence +2; followers +2; modifier focused)*
3. **Pass on the cleat**: No contract. Three years is a long time, and the cleat really is ugly. A rival kicker signs instead, and you see his face at the mall.  
   *(energy +2; fun +1; modifier rested)*

### PRO_660 The Kicker Clinic Tour
- **Category:** training  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** A kicking company wants you on a weekend clinic tour.

A kicking company wants you on a weekend clinic tour: eight cities, eight Saturdays, a thousand young kickers who all want to know what your secret is.

1. **Do the whole tour**: All eight cities. You see a thousand young kickers and remember being one, and you lose your voice in the sixth city.  
   *(energy -3; leadership +2; charisma +1; followers +2; modifier inspired)*
2. **Do the dates near home**: The three dates near home, and your own training the rest of the time. It's a good balance, and the kids in your hometown are thrilled.  
   *(energy -1; accuracy +1; ambition +1; 1 SP; {parent} +1; modifier focused)*
3. **Keep your weekends**: No tour. Your weekends stay yours, and you spend them doing nothing much with the people you love most, which is the point.  
   *(energy +2; fun +2; modifier rested)*

### PRO_665 The Contract Bonus
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** You hit a contract bonus, and your agent wants you to celebrate quietly.

You hit a contract bonus on the last day of the season. Your agent calls to congratulate you and asks you, very seriously, to celebrate quietly.

1. **Put it all in savings**: The whole bonus, straight into savings, and you tell almost nobody about it. Your advisor sends a single word by text: 'Proud.'  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Treat the specialists**: A nice dinner for the specialists, on you, and nobody posts about it. {holder} gives a toast to 'the bonus we all earned'.  
   *(social +2; fun +2; {holder} +3; modifier loose)*
3. **Celebrate at home**: Takeout, a movie and a very long sleep at home. It's the quietest celebration in league history, and it's exactly right.  
   *(energy +2; fun +2; health +1; modifier rested)*

### PRO_674 The Retirement Account
- **Category:** money  
- **Window:** age 26-29, once  
- **Cast:** (no cast)  
- **Premise:** Your advisor finally gets you to open a retirement account.

Your advisor finally gets you to open a retirement account, after three years of reminders. The paperwork is waiting on the table, with little yellow arrows.

1. **Do it right**: Done right: every arrow signed, every question asked, contributions set to grow on their own. Your advisor sends a photo of the paperwork, framed, as a joke.  
   *(resilience +1; intelligence +2; leadership +1; modifier focused; sets `honest_advisor`)*
2. **Ask {parent} what he wishes he'd done**: What does {parent} wish he'd done at your age? It's a long, honest talk on the phone, and it changes what you sign.  
   *(social +1; resilience +1; intelligence +1; {parent} +3; modifier loose)*
3. **Sign the minimum**: The minimum, signed and then forgotten about. Your advisor sighs on the phone and sets a reminder for the same day next year.  
   *(energy +2; fun +1; modifier rested)*

### PRO_711 The Second Business
- **Category:** money  
- **Window:** age 30-33, once, opens on `opened_restaurant` / `dealership_partner` / `invested_in_friend` / `franchise_owner` / `family_business` / `business_owner`  
- **Cast:** (no cast)  
- **Premise:** You consider a second business, while the first is still finding its feet.

You're considering a second business while the first is still finding its feet: a gym this time, with your name on the door and a partner who talks very fast.

1. **Wait a year**: A year's wait, until the first business is steady. The fast-talking partner finds someone else, and you're relieved by spring.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Do both**: Both, at once. You don't sleep much for months, and the gym opens in June to a line around the block.  
   *(energy -3; ambition +2; leadership +1; modifier stressed; sets `business_owner`)*
3. **Ask your first partner**: Your partner in the first business, asked honestly over lunch. The answer is 'please not yet', and you listen to them.  
   *(social +2; charisma +1; {best_friend} +2; modifier loose)*

### PRO_712 The Real Estate Pitch
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A real estate agent pitches you on rental properties.

A real estate agent with very white teeth pitches you on rental properties over lunch. The numbers look great on her tablet, and she has a building in mind.

1. **Study the numbers**: You take the numbers home, study them for a week and buy one small building. It's work, and it's yours.  
   *(intelligence +2; leadership +1; modifier focused)*
2. **Ask {parent}**: You ask {parent}, who has strong opinions about landlords and stronger ones about leaky roofs. You don't buy, and you learn a lot.  
   *(social +1; fun +1; intelligence +1; {parent} +3; modifier loose)*
3. **Pass on it**: You pass. You'd rather not fix anyone's sink, and the agent finds a linebacker by the end of the week.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_713 The Investment That Works
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** An investment you made years ago starts paying off.

An investment you made years ago, mostly to stop your advisor asking, has quietly turned into real money. Nobody knows about it but you and your advisor.

1. **Leave it alone**: You leave it alone and let it keep growing. It's the first time money has felt like a plan instead of a pressure.  
   *(resilience +1; intelligence +2; modifier focused)*
2. **Share some of it**: You use some of it to clear a family debt nobody talks about. The call where you tell them is short, and nobody can speak at the end.  
   *(social +2; leadership +1; {parent} +4; modifier loose)*
3. **Treat yourself once**: You treat yourself once, quietly: the watch you looked at for years. You wear it on game days and feel a little foolish and very happy.  
   *(fun +3; energy +1; modifier rested)*

### PRO_714 The Tax Audit
- **Category:** money  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** You're audited, and every receipt from the last three years matters.

You're audited, and every receipt from the last three years matters. A man in a gray suit wants to know about a dinner in 2023 that you don't remember at all.

1. **Hire an accountant**: A good accountant, hired that same afternoon. It's expensive and calm, and the man in the gray suit leaves satisfied.  
   *(energy -1; resilience +1; intelligence +2; modifier focused; sets `honest_advisor`)*
2. **Do it yourself**: Every receipt, organized by you, every night for a month. You learn a great deal about your own life, some of it embarrassing.  
   *(energy -3; resilience +1; intelligence +2; ambition +1; 1 SP; modifier drained)*
3. **Sort receipts with {parent}**: {parent}, at the kitchen table, sorting receipts into shoeboxes with you for a week. He finds the 2023 dinner receipt in a coat pocket.  
   *(social +2; fun +1; {parent} +3; modifier loose)*

### PRO_717 The Public Speaking Gig
- **Category:** community  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A company wants you to give a motivational talk to its employees.

A company wants you to give a motivational talk to two thousand employees in a convention center. The fee is large, and the topic is 'resilience'.

1. **Give a real talk**: A real talk, about failing in public and staying. They stand up at the end, and three people find you afterward to tell their own stories.  
   *(energy -1; leadership +2; charisma +1; modifier inspired)*
2. **Tell stories and laugh**: Funny stories, mostly about your own mistakes. They laugh a lot, and the CEO asks you back for next year.  
   *(social +2; fun +2; modifier loose)*
3. **Turn the speech down**: Speeches aren't your thing, you decide, and you turn it down politely. They book an astronaut instead, who is much better.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_718 The Kids' Book
- **Category:** community  
- **Window:** age 30-33, once  
- **Cast:** (no cast)  
- **Premise:** A publisher wants you to write a kids' book about kicking.

A publisher wants you to write a children's book about learning to kick. The editor says to write it the way you'd tell it to a seven-year-old.

1. **Write it**: You write it at the kitchen table with {sibling}'s kids correcting every page. The dedication is to them, and they read it to their classes.  
   *(energy -1; leadership +2; intelligence +1; 1 SP; {parent} +1; modifier inspired)*
2. **Write it with {holder}**: You write it with {holder}, who insists on a chapter about the holder. It's funnier than the one you'd have written alone.  
   *(social +2; fun +2; {holder} +3; modifier loose)*
3. **Not yet**: You pass for now and tell the editor maybe after football. You keep the email, and some nights you start a first line in your head.  
   *(energy +2; resilience +1; modifier rested)*

### PRO_771 Three Possible Futures
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** A retirement planner shows you three futures, and only one has football in it.

A retirement planner lays three futures on the table: retire now, retire in two years, or play until the body decides. Only one of them has football in it for long.

1. **Choose the two-year plan**: Two more years, planned in detail, with money set aside for the year after. It's the first time the end has felt like a place you can walk to.  
   *(resilience +1; intelligence +2; modifier focused; sets `planning_retirement`)*
2. **Take all three home**: All three futures, taken home and spread out on the dining table. Your family argues for a week and agrees on one.  
   *(social +2; leadership +1; {love_interest} +3; modifier inspired)*
3. **Keep playing and decide later**: Football, for as long as it lasts, and the planning later. The planner sighs and leaves the folder, just in case.  
   *(energy -1; ambition +2; 1 SP; modifier dialed_in)*

### PRO_782 The Last Big Endorsement
- **Category:** media  
- **Window:** age 34-37, once, followers tier verified  
- **Cast:** (no cast)  
- **Premise:** A sponsor offers what may be your last big deal.

A national sponsor offers what may be your last big deal: one season, a commercial, and a farewell campaign about longevity. The ads will have your face on every bus.

1. **Sign the farewell campaign**: Signed, with your face on every bus. The campaign is tasteful and kind, and strangers start telling you to keep going.  
   *(fun +1; charisma +2; followers +4; modifier spotlight)*
2. **Make it about the kids**: Your condition: half the campaign goes to your foundation's youth clinics. They agree, and the ads feature kids kicking instead of you.  
   *(leadership +2; intelligence +1; followers +2; modifier inspired)*
3. **Turn it down**: No farewell campaign before you've actually decided to say farewell. The sponsor understands completely and leaves the door open for next year.  
   *(energy +1; resilience +2; modifier rested)*

### PRO_784 The Veteran Minimum, Again
- **Category:** money  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** Another season at the veteran minimum.

Another season at the veteran minimum, the third in a row. The number is still more than most people make, and it's a long way from what you used to make.

1. **Be grateful out loud**: Grateful, out loud, at your locker and at home. A paycheck to kick a ball at your age is a gift, and saying it makes it feel like one.  
   *(fun +1; resilience +2; modifier rested)*
2. **Tighten the budget**: A tighter budget, built with your advisor and your family. Nobody misses much, and {sibling} thinks the new rules are hilarious.  
   *(intelligence +2; leadership +1; modifier focused)*
3. **Earn a raise**: A raise, earned the old way: the best season of your late career. Your agent has a reason to call the club in March.  
   *(energy -2; accuracy +1; ambition +2; 2 SP; modifier dialed_in)*

### PRO_799 The Family Business Offer
- **Category:** family  
- **Window:** age 34-37, once  
- **Cast:** (no cast)  
- **Premise:** {sibling} wants you to join his business when you retire.

{sibling} wants you to join their business when you retire: a landscaping company with twelve trucks, a good name in town, and a sign they've already designed with both your names.

1. **Say yes, for after**: Yes, for after. {sibling} sends you a photo of the sign the same night, and you start learning the business on Mondays.  
   *(social +2; leadership +1; {sibling} +5; modifier inspired; sets `family_business`)*
2. **Invest instead of joining**: Money for two more trucks, but your own path after football. {sibling} understands, and the trucks have your name on the door anyway.  
   *(resilience +1; intelligence +2; {sibling} +2; modifier focused; sets `family_business`)*
3. **Tell them you need time**: Time, you tell {sibling} honestly over the phone. They say the sign isn't going anywhere, and neither are they, whatever you decide.  
   *(energy +1; fun +1; charisma +1; {sibling} +1; modifier rested)*

#### Flags this batch sets, and what they open

- `advisor_stole` (from PRO_059) → PRO_060 The Lawsuit; PRO_072 Broke in Your Thirties
- `bad_venture` (from PRO_062, PRO_360) → PRO_072 Broke in Your Thirties; PRO_371 The Financial Mistake (locked choice)
- `business_fraud_victim` (from PRO_234) → PRO_482 Partners in Something New (locked choice)
- `business_owner` (from PRO_429, PRO_445, PRO_463, PRO_482, PRO_483, PRO_711) → PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `dealership_partner` (from PRO_063) → PRO_234 The Partner Who Cheats You; PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `divorced` (from PRO_163) → PRO_151 Love Again; PRO_219 Someone New, Later; PRO_220 The Second Wedding
- `family_business` (from PRO_373, PRO_455, PRO_799) → PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `franchise_owner` (from PRO_235) → PRO_236 Selling the Business; PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `hid_the_loss` (from PRO_059) → PRO_072 Broke in Your Thirties
- `hired_private_coach` (from PRO_026) → PRO_467 The Recovery Challenge (locked choice); PRO_491 The Old Training Routine (locked choice)
- `honest_advisor` (from PRO_057, PRO_067, PRO_072, PRO_261, PRO_262, PRO_376, PRO_394, PRO_401, PRO_437, PRO_647, PRO_674, PRO_714) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice); PRO_123 The Card Game (locked choice); PRO_234 The Partner Who Cheats You (locked choice); PRO_371 The Financial Mistake (locked choice)
- `invested_in_friend` (from PRO_064) → PRO_065 The Start-Up Calls; PRO_233 The Business Grows; PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `life_after_football` (from PRO_233, PRO_481, PRO_498, PRO_526) → PRO_137 The Retirement Talk (locked choice); PRO_149 What's Next (locked choice); PRO_149 What's Next (planned locked choice)
- `lived_large` (from PRO_007) → PRO_072 Broke in Your Thirties
- `lived_modestly` (from PRO_007) → PRO_465 The Oldest Player in the League (locked choice)
- `opened_restaurant` (from PRO_061) → PRO_062 The Restaurant Is Failing; PRO_406 The Family Business Dispute; PRO_413 The Business Partner's Exit; PRO_426 The Business Reputation; PRO_711 The Second Business
- `paid_family_debt` (from PRO_003) → PRO_479 The Family Reunion (locked choice)
- `planning_retirement` (from PRO_771) → PRO_138 The Farewell Season; PRO_244 One More Year?; PRO_248 The Announcement; PRO_251 Thank You, {holder}; PRO_255 The Retirement Party; PRO_256 Who Am I Without It; PRO_282 The Last Summer
- `pro_betting_scandal` (from PRO_262) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_172 The Investigation; PRO_268 The Veteran Hearing
- `pro_business_fraud` (from PRO_261) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `pro_character_concerns` (from PRO_125, PRO_172, PRO_268) → PRO_128 Earning It Back
- `pro_gambling_debt` (from PRO_123) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `pro_insurance_fraud` (from PRO_266) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `pro_owned_it` (from PRO_124) → PRO_130 A Clean Year
- `pro_second_chance` (from PRO_125, PRO_268) → PRO_126 The Last Warning, Pro; PRO_129 The League's Counselor
- `pro_warning` (from PRO_124) → PRO_125 League Discipline; PRO_268 The Veteran Hearing
- `saved_big_check` (from PRO_056) → PRO_472 The Team's Salary Decision (locked choice)
- `saved_rookie_check` (from PRO_003) → nothing reads it yet
- `spent_big_check` (from PRO_056) → PRO_072 Broke in Your Thirties
- `spent_rookie_check` (from PRO_003) → PRO_513 The Franchise Legend (locked choice)
- `started_foundation` (from PRO_070, PRO_505) → PRO_236 Selling the Business; PRO_237 The Foundation at Ten; PRO_700 The Charity Foundation Gala (locked choice); PRO_700 The Charity Foundation Gala (planned locked choice); PRO_828 The Gala in Your Honor (locked choice); PRO_828 The Gala in Your Honor (planned locked choice)
- `sued_advisor` (from PRO_060) → PRO_488 One Last Negotiation (locked choice)

## Temptation follow-ups

### pro_fraud_audit The Auditor's Letter
- **Category:** money  
- **Window:** repeats (15-week cooldown)  
- **Cast:** (no cast)  
- **Premise:** (hand-written pro scene: no design row)

The bank's auditor has found the two invoices. The letter is four pages long, names you and your partner, and gives you thirty days to repay the loan in full before the case goes to the authorities.

1. **Repay it and cooperate**: Every dollar repaid, with interest and a fine, and a long meeting where you answer every question honestly. The money hurts for years; the honesty is the only thing that saves your name.  
   *(fun -3; resilience +2; intelligence +1; {coach} +1; modifier drained)*
2. **Sell the business to cover it**: The business, sold in a hurry to a buyer who knows you're desperate. It covers the repayment and the fine, barely, and everything you built is gone by the end of the month.  
   *(fun -3; resilience +1; leadership +1; {sibling} +1; modifier drained)*
3. **Fight it with lawyers**: Lawyers, appeals and months of letters, until the bank settles for more than you owed in the first place. The legal bills arrive long after the story has faded, and keep arriving.  
   *(fun -2; energy -2; toughness +1; ambition +2; followers -3; {coach} -3; modifier stressed; **conduct scandal**)*

### pro_claim_clawback The Investigators' Visit
- **Category:** money  
- **Window:** repeats (15-week cooldown)  
- **Cast:** (no cast)  
- **Premise:** (hand-written pro scene: no design row)

The insurance company's investigators sit in your living room with the doctor's report, your practice schedule and a video of you kicking forty-yarders the week you were supposedly hurt.

1. **Repay it all and admit it**: The whole payout repaid, with a penalty on top, and a signed statement admitting what happened. It's humiliating and expensive, and it ends there, which is worth more than the money.  
   *(fun -3; resilience +2; intelligence +1; modifier drained)*
2. **Hire a lawyer**: A lawyer, a long negotiation, and a settlement that costs more than the payout and the penalty together. Your name stays out of the papers, barely, and your savings don't.  
   *(fun -2; energy -1; intelligence +2; modifier stressed)*
3. **Blame your agent**: It was your agent's idea, you say, which is true and doesn't help. You repay it all anyway, fire the agent, and the story still leaks by the end of the week.  
   *(fun -3; ambition +1; charisma +1; followers -3; {coach} -3; modifier stressed; **conduct scandal**)*

#### Flags this batch sets, and what they open


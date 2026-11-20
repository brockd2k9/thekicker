# PRO batch 38: R8 and R9 scenes (imported)

Dry run and import: 6 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 38: R8 and R9 scenes

### PRO_151 Love Again
- **Category:** romance  
- **Window:** repeats (15-week cooldown), opens on `ended_long_distance` / `dating_classmate` / `broke_up_pro` / `divorced`, not `new_partner` / `engaged` / `married`  
- **Cast:** {love_interest}  
- **Premise:** You're single in a new city, or the person you dated in college has followed you here, and it's starting to feel serious.  
- **Note:** One scene for both paths: a player who ended things with the high school love interest meets someone new; a player who dated the college classmate makes the classmate the pro partner (locked choice). Committing re-points {love_interest} to the new partner (R8). Repeats after a breakup or divorce (cooldown 15 weeks).

You're single in a new city. Then, at a teammate's birthday dinner, the person across the table asks a question about you instead of the league, and you're still talking when the restaurant starts stacking chairs.

1. **Ask to see them again**: A second dinner turns into a Sunday walk, then into a toothbrush at your place. It's new and easy, and you catch yourself smiling in film sessions.  
   *(fun +2; social +2; charisma +1; modifier inspired; sets `new_partner`; clears `enjoying_single_life`, `made_long_distance_work`, `committed_to_relationship`)*
2. **Enjoy being single**: Single, for now, on purpose. You cook badly for friends, sleep in on off days and answer to nobody, and it's the lightest you've felt since college.  
   *(fun +3; energy +2; {best_friend} +2; modifier rested; sets `enjoying_single_life`)*
3. **Keep the season first**: A friendly goodbye at the door, and nothing more. The season gets all of you, and some nights the apartment is very quiet after film.  
   *(energy +1; resilience +1; ambition +2; 1 SP; modifier dialed_in)*
4. 🔒 *locked: needs `dating_classmate`, shown as "having dated your college classmate"*  
   **Ask the classmate to come**: The classmate from statistics, the standing Thursday nights: you call and ask them to move here. They say yes before you finish the question, and the apartment finally sounds like a home.  
   *(social +2; fun +2; leadership +1; modifier inspired; sets `new_partner`; clears `enjoying_single_life`, `made_long_distance_work`, `committed_to_relationship`)*

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

### PRO_219 Someone New, Later
- **Category:** romance  
- **Window:** age 30-33, once, opens on `divorced` / `broke_up_pro`, not `new_partner` / `engaged` / `married`  
- **Cast:** {love_interest}  
- **Premise:** Years after it ended, a friend's dinner party seats you next to someone who doesn't care about football at all.

Years after it ended, a friend's dinner party seats you next to someone who doesn't care about football at all, has never heard of you and wants to talk about birds, of all things.

1. **Ask for their number**: Their number arrives before dessert, written on a napkin with a drawing of a heron. By spring you know more about birds than kicking, almost.  
   *(fun +3; social +2; charisma +1; modifier inspired; sets `new_partner`; clears `enjoying_single_life`, `made_long_distance_work`, `committed_to_relationship`)*
2. **Call {best_friend} first**: {best_friend} listens to the whole story on the drive home and says only, 'Call them.' You don't, yet, but you keep the napkin on your fridge.  
   *(social +1; resilience +1; intelligence +1; {best_friend} +4; modifier focused)*
3. **Not ready yet**: A lovely evening, and a polite goodbye at the door. You're not ready yet, and you're honest enough with yourself to know it, which feels like progress.  
   *(energy +2; fun +1; leadership +1; modifier rested; sets `enjoying_single_life`)*

### PRO_220 The Second Wedding
- **Category:** family  
- **Window:** age 30-33, once, needs `divorced` + `new_partner`, not `married` / `engaged`, rel_love_interest 55+  
- **Cast:** {love_interest}  
- **Premise:** Married before, both of you, and somewhere between the dishes and the dog you start talking about doing it again: smaller, quieter, and somehow harder to plan.  
- **Note:** Covers the decision and the wedding: PRO_074 The Proposal plays once, usually for the first partner.

Married before, both of you. Somewhere between the dishes and the dog, you start talking about doing it again with {love_interest}: smaller, quieter, and somehow harder to plan than the first time.

1. **The courthouse and a long dinner**: A Tuesday at the courthouse, two witnesses, and a long dinner after. Nobody posts anything. It's the happiest day you've had in years, and it belongs only to you.  
   *(fun +3; energy +1; social +1; {love_interest} +6; modifier inspired; sets `married`; clears `engaged`)*
2. **Invite the people who stayed**: Only the people who stayed through everything: {parent}, {sibling}, {best_friend}. Forty chairs in a backyard, and {sibling} gives a toast that makes everyone cry.  
   *(social +3; fun +2; energy -2; charisma +1; {love_interest} +4; {sibling} +3; {parent} +2; modifier inspired; sets `married`; clears `engaged`)*
3. **Wait one more season**: One more season, you agree, until you're both sure. {love_interest} understands, mostly, and the conversation comes back every few weeks, a little shorter each time.  
   *(energy +1; resilience +1; ambition +1; {love_interest} -2; modifier focused)*

### PRO_262 Betting to Cover It
- **Category:** money  
- **Window:** age 34-37, once  
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

#### Flags this batch sets, and what they open

- `divorced` (from PRO_163) → PRO_151 Love Again; PRO_219 Someone New, Later; PRO_220 The Second Wedding
- `enjoying_single_life` (from PRO_151, PRO_219) → nothing reads it yet
- `honest_advisor` (from PRO_262) → PRO_058 The Advisor With the Yacht (locked choice); PRO_058 The Advisor With the Yacht (planned locked choice); PRO_061 The Restaurant (locked choice); PRO_062 The Restaurant Is Failing (locked choice); PRO_062 The Restaurant Is Failing (planned locked choice); PRO_065 The Start-Up Calls (locked choice); PRO_065 The Start-Up Calls (planned locked choice); PRO_371 The Financial Mistake (locked choice)
- `married` (from PRO_220) → PRO_076 The Due Date; PRO_079 Your Partner's Career; PRO_095 The Tabloid; PRO_096 The Marriage on the Road; PRO_137 The Retirement Talk; PRO_158 The Teammate's Friend; PRO_159 The Long Week on the Road; PRO_163 The Divorce; PRO_173 The Spa (locked choice); PRO_175 The Hearing, at Home; PRO_211 The Contract Talk at Home; PRO_218 A Second Child; PRO_221 The Anniversary; PRO_252 The Family Vote; PRO_271 The Family Vacation; PRO_277 Moving House; PRO_364 The Public Relationship; PRO_368 The Offseason Vacation; PRO_372 The Family Conversation; PRO_381 The Long-Term Commitment; PRO_421 The Family Financial Decision; PRO_430 The Next Chapter Conversation; PRO_438 The Family's Patience; PRO_636 The Pregnancy; PRO_639 The In-Laws; PRO_684 The Kicking Net in the Living Room; PRO_703 The Anniversary Trip; PRO_704 The Marriage Counselor; PRO_742 The Partner's New Job; PRO_753 The Contract Year Pressure at Home; PRO_788 The Partner's Patience
- `new_partner` (from PRO_151, PRO_219) → PRO_074 The Proposal; PRO_137 The Retirement Talk; PRO_155 The Fan; PRO_173 The Spa (locked choice); PRO_175 The Hearing, at Home; PRO_211 The Contract Talk at Home; PRO_220 The Second Wedding; PRO_252 The Family Vote; PRO_271 The Family Vacation; PRO_277 Moving House; PRO_364 The Public Relationship; PRO_368 The Offseason Vacation; PRO_372 The Family Conversation; PRO_381 The Long-Term Commitment; PRO_421 The Family Financial Decision; PRO_430 The Next Chapter Conversation; PRO_438 The Family's Patience; PRO_636 The Pregnancy; PRO_639 The In-Laws; PRO_684 The Kicking Net in the Living Room; PRO_703 The Anniversary Trip; PRO_704 The Marriage Counselor; PRO_742 The Partner's New Job; PRO_753 The Contract Year Pressure at Home; PRO_788 The Partner's Patience
- `pro_betting_scandal` (from PRO_262) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_172 The Investigation; PRO_268 The Veteran Hearing
- `pro_character_concerns` (from PRO_268) → PRO_128 Earning It Back
- `pro_second_chance` (from PRO_268) → PRO_126 The Last Warning, Pro; PRO_129 The League's Counselor

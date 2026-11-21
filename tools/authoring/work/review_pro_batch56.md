# PRO batch 56: the two held pool scenes, reworked (imported)

Dry run and import: 13 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 56: the two held pool scenes, reworked

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

### PRO_170 The Office Pool
- **Category:** team  
- **Window:** once  
- **Cast:** Team  
- **Premise:** The locker room runs a pool on the college basketball tournament: twenty dollars a sheet and a lot of trash talk.  
- **Note:** Small strike: league rules forbid it, even on other sports. Conduct bad, a small fine, {coach}. Clean no with a payoff.

The locker room runs a pool on the college basketball tournament: twenty dollars a sheet, a whiteboard of brackets by the cold tub, and a lot of loud trash talk between the linemen.

1. **Run a pool with no money**: You start a second bracket with no money in it: the loser wears the worst jersey in the equipment room for a week. Half the room switches over, and {coach} thanks you quietly.  
   *(fun +1; leadership +2; {coach} +2; modifier inspired)*
2. **Keep your name off the board**: Your name stays off the whiteboard, and you keep out of the trash talk with a smile. Nobody notices, which is exactly how it should go in a league with rules like these.  
   *(resilience +2; intelligence +1; modifier focused)*
3. **Put your twenty in**: You put your twenty in and write your bracket on the board. A week later the league's memo reaches the locker room, the board is wiped, and your name is on a short list of small fines.  
   *(fun +2; social +2; intelligence -1; {coach} -2; modifier stressed; **conduct bad**; sets **strike** `pro_casual_bet`)*

#### Flags this batch sets, and what they open

- `pro_casual_bet` (from PRO_170) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing
- `pro_gambling_debt` (from PRO_123) → PRO_124 The Team Fine; PRO_125 League Discipline; PRO_126 The Last Warning, Pro; PRO_268 The Veteran Hearing

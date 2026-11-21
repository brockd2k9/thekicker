# PRO batch 52: the cross-era pool, set A (imported)

Dry run and import: 5 written, 0 errors, 0 warnings, 0 lint notes.


## PRO batch 52: the cross-era pool, set A

### PRO_154 The Famous Date
- **Category:** romance  
- **Window:** once, not `made_long_distance_work` / `committed_to_relationship` / `new_partner` / `engaged` / `married` / `dating_classmate`  
- **Cast:** Team  
- **Premise:** You're photographed at dinner with someone famous, and by morning the internet has decided you're engaged.  
- **Note:** Followers up; the date has opinions about your schedule.

You're photographed at dinner with someone famous, and by morning the internet has decided you're engaged. You've been on two dates, and your phone hasn't stopped buzzing since dawn.

1. **Laugh it off together**: A joint joke online about the 'engagement' that the whole league shares. It's charming, the followers pour in, and your date has opinions about your schedule by the weekend.  
   *(fun +2; charisma +2; followers +4; modifier spotlight)*
2. **Keep it private**: No comment from either of you. The story dies within a week, and the third date is at a quiet place with no windows, which {sibling} finds hilarious.  
   *(resilience +2; intelligence +1; {sibling} +2; modifier focused)*
3. **End it before it starts**: Too much, too fast, you decide after a long talk with {best_friend}. A kind conversation, a friendly goodbye, and the internet moves on to someone else.  
   *(energy +2; health +1; {best_friend} +2; modifier rested)*

### PRO_155 The Fan
- **Category:** romance  
- **Window:** once, needs `new_partner`, not `engaged` / `married`  
- **Cast:** {love_interest}  
- **Premise:** A fan who's been at every signing this season slips you a hotel key card with your autograph.  
- **Note:** Dating stage. Strike: pro_cheated.

A fan who's been at every signing this season slips you a hotel key card along with the photo you just autographed. You're dating someone, and you've been happy.

1. **Hand it back**: You hand the key card back without a word. You drive home, call {love_interest}, and tell them about your day, and the card feels very far away by the time you hang up.  
   *(social +1; resilience +2; {love_interest} +2; modifier focused)*
2. **Tell security**: You tell team security quietly, and the fan is kept away from future signings. You tell {best_friend} the story that night, and they make it funnier every time.  
   *(intelligence +1; leadership +1; {best_friend} +1; {coach} +1; modifier focused)*
3. **Keep the key card**: You keep the key card in your wallet instead of the trash. What happens next isn't something you can take back, and the next morning you can't look at your phone.  
   *(fun +2; charisma +2; leadership -3; intelligence -1; modifier stressed; **conduct bad**; sets **strike** `pro_cheated`)*

### PRO_157 The Sponsor's Rep
- **Category:** romance  
- **Window:** once, needs `engaged`, not `married`  
- **Cast:** {love_interest}  
- **Premise:** The rep from your biggest sponsor has handled your account for a year. Tonight the dinner is just the two of you, and she suggests a nightcap at her hotel.  
- **Note:** Engaged stage. Going public costs the sponsor (scandal).

The rep from your biggest sponsor has handled your account for a year. Tonight the dinner is just the two of you, and at the end of it they suggest a nightcap at their hotel. You're engaged.

1. **Say goodnight at the table**: Goodnight at the table, with a handshake and a smile. The sponsor relationship stays professional, and you call {love_interest} from the car on the way home.  
   *(resilience +2; leadership +1; {love_interest} +2; modifier focused)*
2. **Ask for a new rep**: Through your agent, the next morning, you ask for a new account rep. Nothing is said about why, and nothing needs to be, and the deal carries on as before.  
   *(energy +1; intelligence +2; modifier focused)*
3. **Go to the hotel**: The hotel, and a decision you can't undo. A photographer in the lobby makes sure it doesn't stay private, and the sponsor ends the deal by Friday.  
   *(fun +2; charisma +2; leadership -3; intelligence -2; followers -5; {coach} -2; modifier stressed; **conduct scandal**; sets **strike** `pro_cheated`, **strike** `affair_public`)*

### PRO_158 The Teammate's Friend
- **Category:** romance  
- **Window:** once, needs `married`, not `became_parent`  
- **Cast:** {love_interest}, Team  
- **Premise:** A teammate's friend keeps showing up at the team's Thursday dinners, and keeps sitting next to you.  
- **Note:** Married stage.

A teammate's friend keeps showing up at the team's Thursday dinners, keeps sitting next to you, and keeps finding reasons to text you late at night. You're married.

1. **Sit somewhere else**: A different seat every Thursday, beside {holder}, and no texts answered. It's awkward for a week, then fine, and {holder} never asks why you moved.  
   *(resilience +2; intelligence +1; {holder} +2; modifier focused)*
2. **Bring {love_interest} to dinner**: You bring {love_interest} to Thursday dinner and introduce them to everyone at the table. The texts stop that same night, and your partner becomes a Thursday regular.  
   *(charisma +2; leadership +1; {love_interest} +3; modifier loose)*
3. **Answer the texts**: You answer the texts, and then more of them, and then make a decision you'll spend a long time regretting, alone in the car outside your own house.  
   *(fun +2; social +2; leadership -3; modifier stressed; **conduct bad**; sets **strike** `pro_cheated`)*

### PRO_159 The Long Week on the Road
- **Category:** romance  
- **Window:** once, needs `married` + `became_parent`  
- **Cast:** {love_interest}  
- **Premise:** Two road games back to back, ten days from home, and a woman at the team hotel who knows exactly who you are and doesn't care that you're married.  
- **Note:** Married with kids. The kids appear only in the text.

Two road games back to back, ten days away from home, and someone at the team hotel who knows exactly who you are and doesn't seem to care that you're married with kids.

1. **Call home every night**: Every night, a call home: homework, bedtime, ten minutes with {love_interest}, five with {parent}. The ten days pass, and nothing happens worth telling.  
   *(social +2; resilience +1; {love_interest} +2; {parent} +1; modifier rested)*
2. **Stay with the team**: Every evening with the specialists: film, cards, early nights. You're never alone in the lobby, on purpose, and the unit has its best road trip in years.  
   *(fun +1; leadership +1; Team +2; modifier focused)*
3. **Stay at the hotel bar**: The hotel bar, alone, one late night. What follows can't be undone, and the flight home is the longest of your life, with your kids' drawings in your bag.  
   *(fun +3; charisma +2; leadership -3; intelligence -1; modifier stressed; **conduct bad**; sets **strike** `pro_cheated`)*

#### Flags this batch sets, and what they open

- `affair_public` (from PRO_157) → PRO_163 The Divorce
- `pro_cheated` (from PRO_155, PRO_157, PRO_158, PRO_159) → PRO_160 Found Out

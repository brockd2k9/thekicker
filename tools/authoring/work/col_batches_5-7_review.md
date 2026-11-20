# College batches 5, 6 and 7 (for review, not imported)

Dry run: batch 5 13 written, batch 6 13 written, batch 7 14 written (9 new college scenes, 4 pro scenes, COL_118 rewrite); 0 errors, 0 warnings, 0 lint notes, alone and together.

### Batch 5: `tools/authoring/work/col_batch5.json`

**COL_089 The Big Deal** (money; year 3, weeks 1-5)  
A cash-advance app wants you as its face on campus: a season of posts, a billboard by the highway and the biggest NIL check on the team. The app charges students interest you'd never pay yourself, and you'd have to say you use it.
1. **Sign the deal**: You sign. The billboard goes up by the highway, the checks clear, and a few replies under your posts ask how you sleep at night. *(fun +2; ambition +2; intelligence -1; followers +6; spotlight; sets `took_big_deal`; deal: the cash-advance app (sp 2))*
2. **Ask for a product you'd use**: You tell them you'd only promote something you actually use. They pass, but a local sporting-goods store hears the story and offers a smaller deal you can sign with a straight face. *(energy -1; intelligence +1; charisma +1; followers +2; focused; deal: the sporting-goods store (sp 1))*
3. **Turn it down**: You say no and explain why to the teammate who set up the meeting. The money would have been nice, and you don't think about the billboard again. *(energy +1; leadership +1; 1 SP; rested)*

**COL_073 The Captain's Vote** (team; year 3, weeks 1-3)  
Captain voting is next week, and someone has written your name on the ballot. Kickers almost never get the votes, but a few teammates say this year could be different.
1. **Run for it**: You say yes and spend the week talking to every position group, not about you but about what the team needs. The vote is close, and when it's counted, you've got the patch. *(energy -3; social +2; leadership +3; Team +4; {coach} +2; inspired; sets `ran_for_captain`)*
2. **Back someone else**: You take your name off the ballot and tell the room to vote for the senior linebacker who has earned it. He wins, and he remembers who stood up for him. *(energy +1; social +2; charisma +1; Team +2; confident; sets `deferred_captaincy`)*
3. **Stay out of it**: You leave your name off and skip the speeches. You spend the extra hour in the film room every night that week instead. *(energy +2; social -1; intelligence +1; 2 SP; focused)*
4. 🔒 *(needs `earned_coach_confidence`: "having earned a coach's full confidence before")* **Ask {coach} first**: You've had a coach who trusted you completely, and you want that again. You ask {coach} what a captain from the specialists would need to do, then run on that answer and win. *(energy -3; leadership +3; intelligence +1; {coach} +5; Team +3; inspired; sets `ran_for_captain`)*

**COL_072 The Runner** (money; year 3)  
A man in a nice jacket catches you in the parking lot after practice. He says he works 'with' an agent, hands you an envelope of cash and a new phone, and says there's more where that came from.
1. **Report him**: You hand the envelope back, take a photo of his license plate and walk straight to compliance. It's an awkward afternoon of forms, and your name never comes up in the story that follows. *(energy -2; social -1; leadership +2; intelligence +1; {coach} +4; confident; conduct good; sets `reported_runner`)*
2. **Hand it back and walk away**: You give it all back and say no thanks. He smiles like he'll try again, and you don't tell anyone. *(energy +1; fun +1; focused)*
3. **Keep the envelope**: You keep the cash and the phone. Three weeks later compliance calls you in: the runner's other players talked, and your name is on a list you can't explain. *(fun +4; energy +2; ambition +2; leadership -2; draft -4; {coach} -6; distracted; conduct bad; sets `took_improper_benefit`)*

**COL_075 The Scouting Questionnaire** (school; year 3)  
A pro team sends you its first questionnaire: forty questions about your family, your habits and your goals. Question 14 asks you to describe any off-field incidents in your college career.
1. **Answer every question straight**: Whatever belongs on the page, you write it plainly, including the parts you'd rather forget, and ask {coach} to read it before you send it. It isn't all flattering, and it's all true. *(energy -1; intelligence +1; leadership +1; draft +1; {coach} +2; focused)*
2. **Shade a few answers**: You leave a couple of things out and soften the rest. It reads well. Whether it matches what the scouts already know is another question. *(energy +1; fun +1; ambition +2; intelligence -1; draft -1; distracted; sets `shaded_questionnaire`)*
3. **Leave it for next year**: You put it in a drawer: it's a junior-year questionnaire, and you have midterms. The team's scout notes that you never sent it back. *(energy +2; ambition -1; grades +0.05; draft -2; rested)*
4. 🔒 *(needs `recruiting_values_clear`: "having been clear about what you wanted in recruiting")* **Add a page about what you stand for**: You answer the hard questions, then add a page about what you want from a pro career and what you won't do for one. A scout calls just to say nobody has ever sent that page before. *(energy -2; charisma +1; leadership +1; intelligence +1; draft +2; confident)*

**COL_079 The Mental Health Day** (health; year 3)  
You're tired in a way sleep doesn't fix. This morning you sat in the car outside the facility for twenty minutes before you could make yourself go in. The team counselor stops you in the hallway and says taking a day isn't weakness.
1. **Take the day**: You tell {coach} you need a day, and the coach just says okay. You sleep, call home and walk for an hour without your phone. The next morning, the drive in is just a drive. *(health +3; energy +5; fun +2; resilience +1; ambition -1; {coach} +1; rested; sets `took_mental_health_day`)*
2. **Push through it**: You go in anyway and get every rep. Nobody notices anything is wrong, which is the problem. *(energy -3; toughness +1; ambition +2; 2 SP; drained)*
3. **Book a session with the counselor**: You don't take the day, but you take the counselor's Thursday slot. Talking it through doesn't fix the week. It does make it feel smaller. *(energy -1; social +1; resilience +1; intelligence +1; 1 SP; focused)*

**COL_084 The Integrity Hearing** (school; year 3; opens on `academic_shortcut`)  
Your professor has reported the paper. The hearing is next Tuesday: three faculty members, the paper on the table, and {teacher} in the chair beside you as your advisor.
1. **Admit it and accept the sanction**: You tell the panel exactly what happened before they ask. You get a zero on the paper and a semester of integrity workshops, and {teacher} says it's the first hearing in years where nobody had to drag the truth out. *(energy -2; intelligence +1; leadership +2; grades -0.1; draft -1; {teacher} +6; {coach} +2; drained; conduct good; sets `accepted_sanction`)*
2. **Ask {teacher} to speak for you**: You admit it, then ask {teacher} to tell the panel about the work you've done since. It doesn't erase anything, but the sanction comes back lighter. *(energy -1; social +1; charisma +1; intelligence +1; grades -0.05; {teacher} +3; focused; sets `accepted_sanction`)*
3. **Say you didn't know it was cheating**: You argue the tutor only 'edited' it. The panel doesn't buy it, the sanction doubles, and the coaches hear about it before you're back at the facility. *(energy +1; ambition +1; leadership -1; grades -0.2; draft -3; {teacher} -4; {coach} -5; stressed; conduct bad)*

**COL_087 The Twenty-First Birthday** (social; year 3)  
A teammate turns twenty-one on a Thursday, and the whole position room is going out to celebrate. Practice is at seven the next morning.
1. **Be the driver**: You come along as the driver, order wings and water, and have everyone home by midnight. At seven you're the only one in the room who looks awake, and the birthday boy texts you a thank-you at noon. *(energy -3; social +3; leadership +2; Team +3; {coach} +1; tired; conduct good; sets `drove_teammates_home`)*
2. **Buy him dinner, then go home**: You take him to dinner early, give a toast and head home at nine. He's a little disappointed, and you're asleep before the night gets loud. *(energy +1; fun +2; social +1; charisma +1; rested)*
3. **Stay out until close**: You stay out until the lights come on and walk into practice at 7:04 in sunglasses. {coach} sends you home, and the whole team watches you go. *(fun +5; social +4; energy -6; leadership -2; draft -2; {coach} -6; Team -2; late_night; conduct bad; sets `stayed_out_late`)*

**COL_098 Hosting a Recruit** (team; year 3)  
A high school kicker is on his official visit this weekend, and {coach} has asked you to host. On the first night, the recruit leans over and says he wants to see 'the real college experience,' and two teammates already have a party planned.
1. **Show him the real thing**: You take him to the team dinner, the film room and the late-night pancake place every player swears by, and you tell him the truth about the hard weeks. He commits a month later and asks for you by name. *(energy -3; social +2; leadership +2; charisma +1; {coach} +5; Team +2; inspired; conduct good; sets `hosted_recruit_well`)*
2. **Keep it short and safe**: You give him the campus tour, have him back at the hotel by ten and call it a night. He's polite about it. He also doesn't commit. *(energy +1; intelligence +1; {coach} +1; rested)*
3. **Take him to the party**: You take him to the party and lose track of him around midnight. His parents call {coach} the next morning, and the recruit commits somewhere else. *(fun +5; social +3; energy -5; leadership -2; draft -2; {coach} -8; late_night; conduct bad; sets `hosted_recruit_badly`)*
4. 🔒 *(needs `communicated_recruiting_loyalty`: "having been honest with every coach in your own recruiting")* **Tell him what you wish you'd heard**: You skip the party, buy him a burger and tell him how you handled your own recruiting: be honest with every coach, early. He asks a hundred questions, and {coach} hears about it from the recruit's dad. *(energy -2; social +1; charisma +1; leadership +2; {coach} +6; confident; sets `hosted_recruit_well`)*

**COL_091 The Ultimatum** (romance; year 3; opens on `made_long_distance_work`)  
You and {love_interest} have made the long distance work for two years of bus tickets and late calls. Now they want next summer, all of it, at home instead of at the summer program on campus. 'For once,' they say, 'pick us.'
1. **Spend the summer at home**: You tell {coach} you'll train at home and send film every week. The coach isn't thrilled. {love_interest} cries on the phone, the good kind. *(fun +2; social +1; ambition -2; {love_interest} +10; {coach} -3; inspired; sets `committed_to_relationship`)*
2. **Stay for the summer program**: You explain why the program matters and promise to visit every other weekend. {love_interest} says they understand, and the call ends quieter than it started. *(ambition +2; 3 SP; {love_interest} -5; {coach} +2; focused)*
3. **Split the summer**: You'll spend half the summer at home and half on campus. Nobody gets everything, there's a lot of driving, and you both feel heard. *(energy -3; social +1; 2 SP; {love_interest} +4; tired; sets `committed_to_relationship`)*

**COL_092 Meeting the Family** (romance; years 3-4; opens on `dating_classmate` / `committed_to_relationship`)  
The person you're dating wants you to meet their family over the long holiday weekend: four days, their parents and their grandmother's cooking. It's the same weekend as the team's leadership retreat.
1. **Go meet the family**: You skip the retreat, drive six hours and spend four days answering questions about kicking from people who have never watched football. On the drive home, you're both quiet and happy. *(fun +3; social +3; energy -2; charisma +1; leadership -1; {coach} -2; inspired; sets `met_the_family`)*
2. **Go to the retreat**: You go to the retreat and promise to meet the family at the next break. It's the right call for the team, and you spend more of the weekend on your phone than you'd like. *(fun -2; social -1; leadership +2; {coach} +3; Team +2; distracted)*
3. **Leave the retreat a day early**: You ask {coach} to let you miss the last day and drive to the family's house for Sunday dinner. It's short, and it's enough to start. *(energy -3; fun +1; social +2; leadership +1; charisma +1; {coach} -1; tired; sets `met_the_family`)*

**COL_097 When the Alum Gets Cut** (training; year 3; opens on `trained_with_alum`)  
The pro kicker who trained you two summers ago gets cut on a Tuesday. He calls you that night, before he has told almost anyone, and he sounds like a different person.
1. **Just listen**: You let him talk for an hour about the tryouts, the waiver wire and what he'll tell his kids. He thanks you for not trying to fix it. *(energy -2; social +2; resilience +1; charisma +1; drained)*
2. **Ask what he'd do differently**: Once he's calmer, you ask what he'd change if he were twenty-one again. You fill three pages, and half of it isn't about kicking. *(energy -2; intelligence +2; ambition +1; 1 SP; focused)*
3. **Go straight to the net**: You hang up and go to the net under the lights. If it can happen to him, it can happen to you. *(energy -4; social -1; fun -1; ambition +2; 3 SP; dialed_in)*

**COL_074 The Captain's Burden** (team; years 3-4; opens on `ran_for_captain` / `joined_council`)  
A starting linebacker missed curfew on a road trip, and the coaches don't know yet. He finds you in the hotel hallway and asks you, as one of the team's leaders, to keep it in the locker room.
1. **Give him until breakfast**: You tell him he has until breakfast to tell {coach} himself, or you will. He tells. He's furious for a week, and then he starts showing up early. *(energy -2; social -2; leadership +3; {coach} +4; Team +2; confident; sets `held_teammate_accountable`)*
2. **Handle it player to player**: You make him run the stadium stairs with you at six the next morning and leave the coaches out of it. The room respects it, and the coaches never hear a thing. *(energy -4; social +1; toughness +1; leadership +2; Team +3; sore; sets `held_teammate_accountable`)*
3. **Let it go**: You tell him not to let it happen again and leave it there. It doesn't come up again, but two younger players saw the whole thing. *(energy +1; fun +1; social +1; leadership -2; Team -2; rested)*

**COL_076 The Agent's Dinner** (money; year 3, offseason)  
An agent you've never met invites you to the best steakhouse in town to 'talk about your future,' and he's picking up the check. It's a year before you're allowed to sign with anyone, and you both know the rules.
1. **Decline and wait**: You thank him, say you'll talk after your last game like the rules say, and mention the invitation to {coach}. He says he respects that. He also says the offer won't be this good next year. *(leadership +1; intelligence +1; ambition -1; {coach} +2; focused; conduct good; sets `waited_for_agents`)*
2. **Go to dinner, sign nothing**: You eat the steak, listen to the pitch and leave without signing anything. It's within the rules, barely, and his texts start arriving every week after. *(fun +3; social +1; ambition +2; intelligence -1; distracted)*
3. **Shake on a secret deal**: He slides an envelope across the table, a 'loan' against your future, and you shake on a deal nobody can know about. You spend the summer checking your phone for a compliance email. *(fun +4; energy +1; ambition +3; leadership -3; draft -5; stressed; conduct bad; sets `secret_agent_deal`)*


### Batch 6: `tools/authoring/work/col_batch6.json`

**COL_104 Senior Year Starts** (team; year 4, weeks 1-1)  
The first practice of your last college season. The grass smells the way it did on your first day, {coach} is already holding the clipboard, and every senior keeps saying the same thing: it goes fast.
1. **Set a goal for every week**: You write ten goals on an index card, one for each week, and tape it inside your locker. Most of them have nothing to do with kicking. *(energy -1; intelligence +1; ambition +2; leadership +1; focused)*
2. **Thank the people who got you here**: Before practice you find the equipment manager, the trainers and the groundskeeper and thank each of them by name. It takes twenty minutes, and you're almost late. *(social +2; charisma +2; Team +2; {coach} -1; inspired)*
3. **Get there early**: You're on the field forty minutes before everyone else, like your freshman year. {coach} notices and doesn't say anything, which is how you know it counts. *(energy -3; 2 SP; {coach} +3; dialed_in)*

**COL_111 The Degree Question** (school; year 4, weeks 6-10)  
You're two classes from a degree. An agent's assistant suggests dropping them this spring to free up hours for draft training, and {teacher} has the registration form open on the screen, waiting for your answer.
1. **Finish the degree**: You keep both classes and plan your training around them. It means early mornings and a lot of reading on buses, and {teacher} prints the graduation checklist with a small smile. *(energy -3; intelligence +2; grades +0.1; {teacher} +5; focused; sets `finished_degree_track`)*
2. **Drop them for training**: You drop both classes and fill the hours with kicking and the weight room. Your leg has never been stronger, and the degree goes into a folder marked 'someday.' *(ambition +2; intelligence -1; 3 SP; {teacher} -3; dialed_in)*
3. **Take one now, one later**: You keep one class and sign up to finish the other online after the draft. It's a compromise, and it leaves you one class short in May. *(energy -1; intelligence +1; 1 SP; grades +0.05; focused)*
4. 🔒 *(needs `ready_for_college_future` or `secured_academic_path`: "having planned your path past football in high school")* **Finish it, with a plan for after**: You already know what the degree is for, so you keep both classes and ask {teacher} to add a Tuesday-night career-planning seminar. You walk out with a plan for football and a plan for after it. *(energy -3; fun -2; intelligence +2; leadership +1; grades +0.1; {teacher} +6; focused; sets `finished_degree_track`)*

**COL_112 Senior Night** (family; year 4, weeks 8-10)  
Senior night. {parent} and {sibling} drove in this morning, and before kickoff the seniors walk out one at a time to their families waiting at midfield.
1. **Walk out with both of them**: You walk out with {parent} on one side and {sibling} on the other. {parent} doesn't say a word the whole way, and his hand on your shoulder says plenty. *(energy -1; fun +2; social +1; {parent} +6; {sibling} +4; inspired)*
2. **Give {sibling} the moment**: You let {sibling} carry your helmet and walk in front. Someday he'll do this himself, and you want him to know what it feels like. *(leadership +1; charisma +1; {sibling} +8; {parent} +2; inspired)*
3. **Keep it short and stay loose**: You hug them at midfield, then jog straight back to the net to stay warm. They understand. Mostly. *(ambition +1; 1 SP; {parent} +1; dialed_in)*
4. 🔒 *(needs `family_college_compromise`: "having found a middle ground with your family over college")* **Thank {parent} out loud**: You take the microphone the announcer offers and thank {parent} for every compromise that got you here. Half the stadium claps. {parent} looks at the grass. *(social +2; charisma +2; {parent} +8; {sibling} +3; inspired)*

**COL_114 The Captain's Last Speech** (team; year 4, weeks 9-10; opens on `ran_for_captain` / `joined_council` / `deferred_captaincy`)  
{coach} asks you to speak to the team before the last game of your college career. You have five minutes, a locker room full of people you've lived with for four years and no idea where to start.
1. **Tell them about your hardest year**: You talk about the worst stretch of your college career and the people in this room who got you through it. Nobody makes a sound until you're done. *(energy -2; leadership +2; charisma +2; Team +5; {coach} +2; inspired)*
2. **Keep it short and loud**: Thirty seconds, loud, and you finish by slamming a locker door. The room explodes. *(energy +1; social +2; fun +2; Team +3; pumped_up)*
3. **Give the floor to the freshmen**: You say a few words, then ask the youngest players what this season meant to them. It turns into the best twenty minutes of the year. *(energy -2; social +1; leadership +3; Team +4; {coach} +3; inspired)*

**COL_115 The Freshman Who Reminds You** (team; year 4)  
A walk-on freshman kicker sits alone at the end of the bench after practice, scrolling through photos from home. Four years ago, that was you.
1. **Sit down next to him**: You sit, and you don't talk about kicking. You tell him about your own first month, the bad one, and give him your number. He texts you every Sunday for the rest of the year. *(energy -1; social +2; leadership +2; charisma +1; Team +2; inspired)*
2. **Bring him to the net**: You hand him a ball and say the best cure for homesick is a hundred kicks. It helps more than you expect, for both of you. *(energy -2; social +1; fun +2; 2 SP; Team +1; loose)*
3. **Mention it to the coaches**: You stop by {coach}'s office on your way out and head home. The coach checks in; you never find out how it goes. *(energy +2; fun +1; {coach} +1; rested)*
4. 🔒 *(needs `mentored_younger_student` or `mentored_next_generation`: "having mentored younger players before")* **Start a specialists' dinner**: You invite every freshman specialist to a weekly dinner at your place, the one you wish you'd had. By October, the juniors say they'll keep it going. *(energy -3; social +3; leadership +3; Team +4; inspired)*

**COL_116 The Holder's Future** (team; year 4)  
{holder} is applying for a graduate assistant job on a coaching staff and asks you for a recommendation. You love working with {holder}, and the honest version includes a few things a coach might not want to read.
1. **Write the honest letter**: You write about the hours, the calm in the worst weather and the habit of being late to meetings, and how {holder} fixed it when you said something. {holder} reads it and laughs: 'That's actually me.' *(energy -2; intelligence +1; leadership +1; {holder} +5; focused)*
2. **Write a glowing letter**: You write the best letter you can, without a single flaw in it. {holder} gets the interview, and you wonder whether the coaches can tell. *(charisma +1; intelligence -1; {holder} +7; confident)*
3. **Help with the whole application**: You write the letter, then give up two evenings to run {holder} through the hardest interview questions you can think of. *(energy -4; fun -2; social +1; charisma +1; intelligence +1; {holder} +8; tired)*

**COL_117 The Backup's Moment** (team; year 4; opens on `mentored_backup` / `iced_out_backup` / `competed_clean` / `undermined_backup`)  
Your hip is sore, and {coach} wants to give {backup} the kickoffs this week to save your leg. {backup} looks over at you before saying yes.
1. **Tell {backup} to take them**: You nod and say, 'They're yours.' {backup} spends the week asking about every detail of your kickoff routine, and you give all of it. *(health +4; leadership +2; {backup} +6; {coach} +2; rested)*
2. **Ask to keep them**: You tell {coach} the hip is fine and you want every kick of your senior year. The coach gives in. The hip doesn't get better. *(health -3; ambition +2; 2 SP; {backup} -3; {coach} -1; sore)*
3. **Split them**: You suggest {backup} takes the deep ones and you take the short squibs. {coach} likes it, and you both get to kick. *(health +2; intelligence +1; 1 SP; {backup} +3; {coach} +1; focused)*
4. 🔒 *(needs `undermined_backup`: "having gotten in {backup}'s head at camp")* **Apologize first**: Before you answer, you tell {backup} you're sorry for the mind games at camp two years ago. It takes a while to get an answer, and then it's: 'I'll take the kickoffs.' *(health +4; energy -2; social -1; leadership +2; {backup} +10; {coach} +2; rested)*

**COL_119 What Comes After** (romance; year 4; opens on `committed_to_relationship` / `met_the_family` / `dating_classmate`)  
On a Sunday walk, the person you're dating finally asks the question you've both been avoiding: what happens to the two of you when college is over and you could end up in any city in the country?
1. **Say you'll figure it out together**: You say there's no version of the future you're planning without them in it. It doesn't answer where you'll live. It answers the question they were really asking. *(energy -1; fun +3; social +2; charisma +1; ambition -1; inspired)*
2. **Say football comes first for now**: You say the next year has to be about football, and you don't want to make a promise you can't keep. It's honest, and the walk home is very quiet. *(fun -3; social -1; ambition +2; intelligence +1; 2 SP; focused)*
3. **Ask what they want**: You turn the question around and really listen. It turns out they've had a job offer in another city for a month and didn't say so. You have a lot more to talk about now. *(energy -2; social +1; intelligence +1; charisma +1; focused)*
4. 🔒 *(needs `committed_to_relationship`: "having spent a summer at home for {love_interest}")* **Say you already chose once**: You remind {love_interest} about the summer you spent at home. 'I picked us then,' you say. 'I'll pick us wherever I end up.' *(energy -1; fun +3; social +2; ambition -1; {love_interest} +10; inspired)*

**COL_120 {parent} at Every Game** (family; year 4)  
{parent} has driven to every game this season, home and away, eight hours some weekends. He says it's nothing. You've seen the gas receipts in his truck, and you know he can't afford it.
1. **Ask him to pick a few games**: You ask him to choose the three games that matter most and watch the rest at home. He argues, then gives in, and you hear the relief in his voice. *(energy +1; intelligence +2; {parent} +3; rested)*
2. **Let him keep coming**: You say nothing. It's his choice, and seeing him behind the bench after every game is the best part of your week. *(fun +2; {parent} +5; inspired)*
3. **Find him a ride**: You ask the booster club whether any fans from home drive to away games. Two of them have been driving down every week anyway and are happy to have the company. *(energy -1; social +1; charisma +1; intelligence +1; {parent} +4; focused)*
4. 🔒 *(needs `helped_family_financially`: "having helped your family with money before")* **Cover his gas yourself**: You put a gas card in his glovebox with a note: 'For the drive. Don't argue.' He doesn't argue. He calls that night to say thank you, twice. *(fun -1; charisma +1; {parent} +8; inspired)*

**COL_122 The Mental Toll** (health; year 4)  
Draft calls, final exams and your last season are all happening at once. You've snapped at {holder} twice this week, you haven't slept a full night in a month, and you don't feel like yourself.
1. **Tell the people closest to you**: You call {parent} and {best_friend} the same night and say it plainly: you're not okay right now. Neither of them tries to fix it, and both of them check in every day after. *(health +3; energy +2; resilience +1; ambition -1; {parent} +3; {best_friend} +3; rested; sets `leaned_on_support`)*
2. **Cut everything but football**: You stop answering texts, skip the study group and live at the facility. The kicking holds up. You don't. *(health -3; social -3; energy -2; ambition +2; 3 SP; drained)*
3. **Apologize and keep going**: You apologize to {holder} before practice and promise yourself you'll sleep more. You do, for about three nights. *(energy +1; social +1; 1 SP; {holder} +4; focused)*
4. 🔒 *(needs `saw_sports_psych` or `got_help_panic`: "having gotten help before")* **Book the sports psychologist again**: You book the Tuesday slot again and say the word 'overwhelmed' out loud for the first time. You leave with a plan that cuts your week into pieces small enough to carry. *(health +3; energy +2; fun -1; resilience +2; intelligence +1; focused; sets `leaned_on_support`)*

**COL_125 The Senior Trip** (social; year 4, weeks 4-9)  
The seniors have booked a beach house for the bye weekend: two nights, twelve players, one last trip before everyone scatters. You have a workout for pro scouts on Monday morning.
1. **Go, and come home early**: You go for the first night, cook breakfast for everyone and drive back Saturday afternoon. You're rested for Monday, and you're in the photo that ends up framed in eleven apartments. *(fun +3; social +3; energy -1; 1 SP; loose)*
2. **Skip it and train**: You stay behind and spend the bye weekend getting ready for Monday. The group chat photos look like the best weekend of their lives. *(fun -2; social -2; ambition +2; 3 SP; dialed_in)*
3. **Stay the whole weekend**: You stay both nights. The neighbors call the police on Saturday, the trip makes the local news, and {coach} hears about it before you're late to Monday's workout with your name in the police report. *(fun +6; social +4; energy -7; leadership -2; draft -3; {coach} -5; late_night; conduct bad; sets `senior_trip_trouble`)*

**COL_131 The Leadership Award** (community; year 4, weeks 5-9)  
The conference names you your school's senior leadership honoree, and Monday's banquet gives you one minute at the podium. {holder} and {coach} are at your table, and you're the only kicker in the room.
1. **Thank the specialists**: You spend the whole minute on the people nobody films: {holder}'s hands, the snapper's five a.m. reps. {holder} pretends not to tear up. *(social +2; charisma +1; {holder} +6; Team +2; inspired)*
2. **Thank {coach}**: You thank {coach} for every hard conversation, by name and by date. The coach shakes your hand afterward and holds on a second too long. *(leadership +1; charisma +1; {coach} +6; confident)*
3. **Talk about the hospital visits**: You use the minute to talk about the team's Tuesday visits to the children's hospital and ask the room to come once. Three boosters sign up at the dessert table. *(energy -1; social +1; leadership +2; charisma +2; followers +3; inspired)*

**COL_133 The Last Practice** (team; year 4, weeks 9-10)  
The last practice of your college career. The field is the one you walked onto four years ago, and when it's over, nobody seems to want to leave.
1. **One last hold from {holder}**: After everyone's gone, you ask {holder} for one more hold, from the spot of your first college practice kick. Neither of you says much. *(fun +2; social +1; {holder} +6; inspired)*
2. **Thank {coach} in private**: You find {coach} in the office and say thank you for the four years, the good ones and the others. The coach says the door stays open, and means it. *(charisma +1; leadership +1; {coach} +6; confident)*
3. **Stay late with the freshmen**: You stay an hour, kicking with the freshmen and answering every question they have. One of them asks if he can have your locker. *(energy -2; leadership +2; 1 SP; Team +4; focused)*


### Batch 7: `tools/authoring/work/col_batch7.json`

**COL_107 Choosing an Agent** (career; year 4, weeks 6-10)  
Three agents want to represent you: a big firm with a glossy binder, a former pro kicker who works out of his garage, and a smooth talker who promises a first-round grade. {parent} has read every contract twice.
1. **Sign with the big firm**: You sign with the big firm. The binder is thick, the staff is huge, and your calls go to an assistant most of the time. *(social -1; ambition +1; draft +2; followers +3; {parent} +1; confident)*
2. **Sign with the former kicker**: You sign with the former kicker. He has three clients and answers every call himself, and the first thing he does is fix your warmup. *(intelligence +1; 2 SP; draft +1; {parent} +3; focused)*
3. **Sign with the smooth talker**: You sign with the one who promised the most. The promises keep coming; the details don't. {parent} stops asking about it after a while. *(fun +2; ambition +2; charisma +1; draft -1; {parent} -3; distracted)*
4. 🔒 *(needs `recruiting_values_clear`: "having known what you wanted in recruiting")* **Interview them with your own list**: You hand each agent the same list of questions about what you want from a career. Only one reads it before answering, and you sign with that one. *(energy -2; intelligence +2; draft +2; {parent} +4; focused)*

**COL_108 Combine Prep** (training; year 4, weeks 5-9)  
A training facility wants to sign you for combine prep the day your season ends, and they want an answer this week. Their brochure promises 'cutting-edge recovery,' and the list of what that includes has names you've never heard of.
1. **Sign for the approved program only**: You ask for the program without the recovery menu and send the list to the team doctor. The facility grumbles and agrees, and your schedule starts the Monday after your last game. *(energy -1; intelligence +2; ambition +1; draft +2; focused; conduct good; sets `combine_ready`)*
2. **Build it with your own staff**: You turn the facility down and plan combine prep with your school's strength staff. It's less glamorous, and it's free. *(energy -2; social +1; intelligence +1; 2 SP; draft +1; dialed_in; sets `combine_ready`)*
3. **Sign for everything**: You sign for all of it, recovery menu included. The team doctor sees the list in your file a week later, and the meeting that follows, with {coach} in the room, ends in compliance. *(energy +2; fun +1; ambition +2; intelligence -1; draft -4; {coach} -5; stressed; conduct bad; sets `took_unapproved_supplement`)*

**COL_109 The Scouts' Workout** (career; year 4, weeks 6-9)  
Scouts from a dozen pro teams are coming to campus Thursday morning to work out the seniors. On Wednesday night, the seniors are throwing a send-off party at the house across from the stadium.
1. **Skip the party and get ready**: You stretch, eat, watch your own tape and are asleep by ten. On Thursday you're the first one on the field, and you look like it. *(energy +4; social -2; fun -2; draft +3; fresh_legs; sets `pro_day_ready`)*
2. **Stop by for an hour**: You stop by, say your goodbyes and leave before ten. Half the room calls you boring, and you're asleep by eleven. *(energy +1; social +2; fun +1; draft +2; rested; sets `pro_day_ready`)*
3. **Stay until the end**: You stay until the end and show up Thursday on two hours of sleep. The scouts write down everything, including the time you arrived. *(fun +5; social +4; energy -7; leadership -1; draft -4; late_night; conduct bad; sets `partied_before_pro_day`)*

**COL_110 Draft Weekend** (family; year 4, weeks 8-10)  
Draft weekend is months away, and everyone already wants to know where you'll watch it. {parent} has been looking at rental halls, {sibling} wants a party, and the team is planning a watch night at the facility.
1. **Watch at home with family**: You tell {parent} to book the hall. Whatever happens, you want to be in a room full of people who were there at the start. *(fun +1; social +1; {parent} +6; {sibling} +3; inspired)*
2. **Watch with the team**: You pick the team watch night. These are the people who were in the weight room at six with you. *(social +2; leadership +1; Team +4; {parent} -2; pumped_up)*
3. **Phone off, small room**: You say you'll watch with your phone off and only {parent} and {sibling} in the room. {parent} is relieved, and {sibling} is disappointed about the party. *(energy +2; fun -1; resilience +1; {parent} +4; {sibling} -2; rested)*
4. 🔒 *(needs `family_college_compromise`: "having found a middle ground with your family before")* **Plan both**: You plan the first night at home with family and the second at the facility with the team. {parent} draws up the schedule himself. *(energy -2; {parent} +5; Team +3; {sibling} +2; inspired)*

**COL_105 The Background Check** (career; year 4, weeks 3-9)  
Pro scouts are interviewing everyone with a chance at the draft. This week you hear they've called your high school coach, your old teammates and a roommate you haven't spoken to since freshman year.
1. **Hand them every number**: You tell the scouts to call anyone they want and send a list with phone numbers. Some of what they hear won't be flattering, and none of it will be a surprise. *(energy -1; fun -1; intelligence +1; leadership +1; draft +2; focused)*
2. **Call the people they called**: You call your old teammates to ask what they told the scouts, and what they should say next time. One of them tells the scout about the call. *(energy +1; social +1; ambition +2; leadership -2; draft -4; stressed; conduct bad; sets `scouts_red_flag`)*
3. 🔒 *(needs `doubled_down_recruiting_lie`: "having stood by a padded recruiting video in high school")* **Come clean about the old video**: Before the scouts find it, you tell them the recruiting video you defended in high school was padded. It's humiliating for five minutes. The scout writes 'honest' in the margin. *(energy -2; leadership +2; charisma -1; draft +2; confident)*
4. 🔒 *(needs `corrected_recruiting_video` or `rebuilt_reputation`: "having owned a mistake and fixed it before")* **Point them to the people who saw you change**: You give the scouts the names of the people who watched you fix it: the coach who gave you the chance, the teammates who held you to it. They call every one. *(energy -2; social -1; intelligence +1; leadership +1; draft +3; confident)*

**COL_106 The Red Flag Interview** (career; year 4; opens on `character_concerns` / `college_warning`)  
A scout sits across the table from you with a folder: every incident from your college career, typed up and dated. He slides it over and says, 'Walk me through it.'
1. **Walk through all of it**: You go line by line and don't blame anyone else for any of it. You tell him what changed and who can confirm it. He closes the folder before you're done. *(energy -3; fun -1; leadership +2; draft +3; drained; sets `took_responsibility_scout`)*
2. **Explain the context**: You explain each incident: the bad influences, the unfair calls, the wrong place at the wrong time. Every explanation is a little bit true. He writes 'deflects' at the top of the page. *(energy +1; ambition +1; charisma +1; draft -3; stressed; sets `scouts_red_flag`)*
3. **Keep the answers short**: You give one-sentence answers and wait for the next question. He doesn't learn anything bad, and he doesn't learn anything good. *(energy +1; intelligence +1; draft -1; focused)*
4. 🔒 *(needs `rebuilt_reputation`: "having taken the long way back")* **Show him the long way back**: You tell him about the six a.m. workouts and the community hours, then give him {coach}'s number. He calls the coach from the parking lot. *(energy -3; fun -2; resilience +1; leadership +2; draft +4; confident; sets `took_responsibility_scout`)*

**COL_129 The Scout's Dinner** (career; year 4)  
A scout takes you to dinner and asks almost nothing about kicking. He spends most of the meal watching how you treat the waiter, the busboy and the kid at the next table who recognizes you.
1. **Just be yourself**: You thank the waiter by name, sign the kid's napkin and talk about your family more than your leg. The scout pays and says he's seen what he came to see. *(energy -1; social +2; charisma +2; draft +2; confident)*
2. **Turn it into a pitch**: You steer every topic back to your numbers, your charts and your work ethic. The scout listens politely and checks his phone twice, and you leave with a sharper pitch for every interview after. *(social -1; ambition +2; intelligence +1; 1 SP; focused)*
3. **Ask what scouts really watch for**: You ask him straight out what he's watching for tonight. He laughs and tells you about a first-round pick who was rude to a valet. *(intelligence +2; charisma +1; draft +1; focused)*
4. 🔒 *(needs `owned_mistake`: "having owned a mistake to your coach")* **Tell him your worst moment first**: Before he can ask, you tell him about the mistake you owned and what it taught you. He puts his fork down and asks follow-up questions for an hour. *(energy -2; leadership +1; charisma +1; draft +3; confident)*

**COL_132 The Coach's Letter** (team; year 4, weeks 8-10)  
{coach} is writing a letter to pro scouts about you and asks what you'd like included, and what you'd rather leave out.
1. **Ask for the honest version**: You tell {coach} to write what's true, the good and the rest. The letter goes out a week later, and the coach sends you a copy without being asked. *(leadership +1; draft +2; {coach} +5; confident; sets `asked_for_honesty`)*
2. **Ask to leave out the low points**: You give {coach} a list of things you'd rather not see in writing. The coach takes it without a word, and you can't tell what that means. *(fun +1; ambition +2; draft +1; {coach} -3; stressed)*
3. **Let {coach} decide**: You say you trust the coach to get it right and leave it there. It's a relief not to think about it. *(energy +2; fun +1; {coach} +2; rested)*
4. 🔒 *(needs `repaired_coach_trust`: "having rebuilt a coach's trust in high school")* **Ask {coach} to include the hard part**: You ask {coach} to write about your worst week here and what you did after it. 'That's the part they need,' you say. The coach agrees. *(energy -2; leadership +2; draft +2; {coach} +6; confident; sets `asked_for_honesty`)*

**COL_150 The Next Level** (career; finale, year 4 week 10)  
The last week of your college career. Whatever happens on draft day, this is where the kicker you became walks off the field. {parent} is waiting by the tunnel, and {coach} has one question for you: 'What's next?'
1. 🔒 *(needs `combine_ready` or `pro_day_ready`: "having prepared for the scouts")* **Say you're ready for the pros**: You tell {coach} you've done everything you can and you're ready for whoever calls. {parent} hears it and nods like he's known for years. *(energy -1; ambition +2; draft +3; {coach} +3; {parent} +3; confident; sets `ready_for_pros`)*
2. 🔒 *(needs `finished_degree_track`: "having stayed on track for your degree")* **Say you'll be okay either way**: You tell them football is the plan and the degree is the backup, and you mean both. Whatever the phone does on draft day, you'll be okay. *(resilience +1; intelligence +2; draft +1; {parent} +5; rested; sets `life_after_football`)*
3. **Say you're still proving it**: You tell {coach} you're not done proving anything, to the scouts or to yourself. The coach smiles: 'Good. Keep that.' *(ambition +3; 2 SP; draft +1; {coach} +3; pumped_up; sets `still_proving_it`)*
4. **Say thank you first**: You don't answer the question yet. You thank {coach}, then walk over and hug {parent} for a long time. 'What's next' can wait a week. *(social +2; charisma +1; {parent} +6; {coach} +4; inspired)*

**pro_folder_follows The Folder Follows You** (team; pro season 1; opens on `character_concerns` / `scouts_red_flag` / `college_warning` / `hosted_recruit_badly` / `shaded_questionnaire`)  
Your first month as a pro, the team's player-development director calls you in. Your college record followed you here, and the club wants to know what kind of player it signed.
1. **Ask for a weekly check-in**: You suggest a weekly check-in yourself and hand over your college coach's number. The director writes it in the file: rookie asked for structure. *(energy -2; leadership +1; retention +3; {coach} +3; focused)*
2. **Say college is over**: You say the folder belongs to a different person and you'd rather be judged on what you do here. The director says that's fair. The file stays open. *(energy +1; fun +1; ambition +2; retention -1; confident)*
3. 🔒 *(needs `rebuilt_reputation` or `took_responsibility_scout`: "having already faced your record honestly")* **Bring your own copy**: You bring a copy of your college record with your own notes in the margins: what happened and what changed. The director keeps it and tells {coach} to stop worrying. *(energy -3; fun -1; leadership +2; retention +4; {coach} +4; confident)*

**pro_old_crowd The Old Crowd** (social; pro season 1-2; opens on `ran_with_wrong_crowd` / `character_concerns` / `last_chance`)  
Three guys you used to run with in college show up in your new city on a Friday with a hotel suite booked and a plan for your first paycheck. Your phone has been buzzing since noon.
1. **Dinner, then home**: You buy them dinner, laugh about the old days and are home by ten. They call you boring. You're at the facility at seven. *(energy -1; fun +1; social +1; retention +2; rested)*
2. **Don't answer**: You let the phone buzz and stay in. It's lonely, and it's the first weekend in a while you don't regret anything. *(energy +3; social -2; fun -2; resilience +1; retention +1; rested)*
3. **Go out with them**: You go out. Saturday's photos end up online, a team official calls on Monday, and {coach} hears about it before you're in the building. *(fun +5; social +4; energy -6; leadership -1; retention -4; {coach} -4; late_night; conduct bad)*

**pro_rookie_symposium The Rookie Symposium** (community; pro season 1-2; opens on `rebuilt_reputation` / `owned_mistake` / `took_responsibility_scout` / `accepted_sanction`)  
The league's rookie symposium wants a player to speak about a mistake from college and what came after. The team's player-development director thinks your story is the one the rookies need to hear.
1. **Tell the whole story**: You stand in front of two hundred rookies and tell them about your worst college year without making yourself the hero. Afterward, a line of players waits to talk to you. *(energy -3; leadership +3; charisma +2; retention +2; followers +3; inspired)*
2. **Tell the safe version**: You give the version with the details smoothed over. It goes fine, and nobody waits afterward. *(energy -1; fun +2; charisma +1; retention +1; focused)*
3. **Say no thanks**: You say you'd rather not relive it in front of a room. The director understands and asks someone else. *(energy +2; fun +1; ambition +1; rested)*

**pro_reporters_question The Reporter's Question** (media; pro season 1; opens on `character_concerns` / `scouts_red_flag` / `college_warning`)  
At your first open locker room, a beat reporter skips the kicking questions and asks about your college record: 'Do you think the stories about you are fair?'
1. **Answer it straight**: You say the stories are true, you're not proud of them and you'd rather be judged on what comes next. The quote runs in full, and it's the least dramatic thing in the paper. *(energy -1; charisma +1; leadership +1; retention +2; followers +2; confident)*
2. **Say no comment**: You say you're only taking football questions. The reporter writes that you 'declined to address' your past, which reads worse than anything you could have said. *(energy +1; fun +1; retention -1; stressed)*
3. **Push back**: You say the stories were overblown and the reporter should do some homework. It's the most-shared clip of the week, and {coach} asks you to stop by the office. *(fun +2; ambition +2; leadership -1; retention -3; followers +6; {coach} -4; spotlight)*

**COL_118 Old Rival, New Stage** (training; year 4, weeks 5-9; opens on `tyler_college_bond` / `tyler_college_feud` / `congratulated_tyler` / `trash_talked_tyler`)  
{tyler} is a draft prospect too, and his agent suggests the two of you spend your Sunday off-days training together at a pro facility halfway between your schools until the season ends.
1. **Train together**: You split the facility, the film and the drive. You push each other harder than any coach could, and some Sundays it's still a rivalry. *(energy -4; social +2; ambition +2; 4 SP; {tyler} +6; dialed_in)*
2. **Train apart, stay in touch**: You keep your Sundays at your own facility and trade film with {tyler} every week. It's friendly, focused and on your terms. *(energy -2; intelligence +1; ambition +1; 3 SP; {tyler} +2; focused)*
3. **Turn it down**: You say no without saying why. You train alone and hear later that {tyler} told his agent he wasn't surprised. *(energy +1; fun +2; ambition +2; 2 SP; {tyler} -4; pumped_up)*
4. 🔒 *(needs `tyler_mutual_respect`: "having earned {tyler}'s respect in high school")* **Say yes, like old times**: You say yes before his agent finishes the pitch. It's the old net sessions again, with better equipment and higher stakes, and you both get better. *(energy -4; fun +2; social +2; charisma +1; 4 SP; {tyler} +10; inspired)*


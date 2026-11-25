extends "res://tests/test_case.gd"
## Stadiums: the team-to-tier mapping per stage, high school always at night,
## capacity deciding when present, away games at the opponent's stadium,
## neutral sites for challenges, and every tier within its draw-call budget.

const FIELD_GOAL := preload("res://scenes/field_goal.tscn")
## Most boxes and planes a stadium may add (the original stadium is 10).
const DRAW_CALL_BUDGET := 30

var t := CareerTuning.get_default()


func _career(stage: String, team: Dictionary) -> CareerData:
	var c := CareerData.create("Stadium Test", t)
	c.stage = stage
	c.team = Progression.team_from(team, stage)
	return c


func test_tiers_by_stage() -> void:
	var hs := CareerData.STAGE_HIGH_SCHOOL
	eq(Stadiums.tier_for({"strength": 35}, hs, t), "hs_1", "small high school: bleachers")
	eq(Stadiums.tier_for({"strength": 55}, hs, t), "hs_2", "mid high school")
	eq(Stadiums.tier_for({"strength": 74}, hs, t), "hs_3", "big high school")
	eq(Stadiums.tier_for({"tier": "small"}, CareerData.STAGE_COLLEGE, t), "college_small", "college tier")
	eq(Stadiums.tier_for({"tier": "top"}, CareerData.STAGE_COLLEGE, t), "college_top", "college tier")
	eq(Stadiums.tier_for({"tier": "juco"}, CareerData.STAGE_JUCO, t), "juco", "junior college")
	eq(Stadiums.tier_for({"strength": 55}, CareerData.STAGE_PRO, t), "pro_1", "small pro club")
	eq(Stadiums.tier_for({"strength": 72}, CareerData.STAGE_FREE_AGENT, t), "pro_3", "free agents count as pro")
	# Every team in the world maps to a real preset.
	for pair in [[CareerContent.high_schools(), hs], [CareerContent.colleges(), CareerData.STAGE_COLLEGE],
			[CareerContent.jucos(), CareerData.STAGE_JUCO], [CareerContent.pro_clubs(), CareerData.STAGE_PRO]]:
		for team in pair[0]:
			var id := Stadiums.tier_for(team, str(pair[1]), t)
			check(id in StadiumSpec.preset_ids(), "%s -> %s" % [team.get("id", ""), id])


func test_capacity_decides_when_present() -> void:
	eq(Stadiums.tier_for({"strength": 35, "capacity": 12000}, CareerData.STAGE_HIGH_SCHOOL, t), "hs_3",
		"a weak team with a big stadium")
	eq(Stadiums.tier_for({"tier": "top", "capacity": 20000}, CareerData.STAGE_COLLEGE, t), "college_small",
		"capacity over tier")
	eq(Stadiums.tier_for({"strength": 72, "capacity": 60000}, CareerData.STAGE_PRO, t), "pro_1",
		"capacity over strength")
	var team := Progression.team_from({"id": "x", "strength": 50, "capacity": 9000, "stadium": "The Pit"},
		CareerData.STAGE_HIGH_SCHOOL)
	eq(int(team.get("capacity", 0)), 9000, "team_from keeps capacity")
	eq(str(team.get("stadium", "")), "The Pit", "and the stadium name")


func test_high_school_always_at_night() -> void:
	var c := _career(CareerData.STAGE_HIGH_SCHOOL, CareerContent.high_schools()[0])
	for w in range(1, 12):
		check(Stadiums.for_game(c, {"week": w, "home": w % 2 == 0, "opponent": {}}, t).night,
			"high school week %d at night" % w)


func test_night_share_and_stable() -> void:
	var nights := 0
	for season in 40:
		for w in range(1, 12):
			if Stadiums.night_game(CareerData.STAGE_PRO, season, w, "a|b", t):
				nights += 1
	var share := nights / 440.0
	check(share > t.pro_night_share - 0.07 and share < t.pro_night_share + 0.07,
		"pro night share about %.0f%% (%.0f%%)" % [t.pro_night_share * 100.0, share * 100.0])
	eq(Stadiums.night_game(CareerData.STAGE_COLLEGE, 3, 5, "a|b", t),
		Stadiums.night_game(CareerData.STAGE_COLLEGE, 3, 5, "a|b", t), "same game, same answer")
	check(not Stadiums.night_game(CareerData.STAGE_JUCO, 3, 5, "a|b", t), "junior college plays by day")


func test_away_games_at_the_opponents_stadium() -> void:
	var small: Dictionary = {}
	var big: Dictionary = {}
	# The smallest small-tier stadium and the biggest top-tier one (stadiums are
	# placed by capacity when a team has one).
	for s in CareerContent.colleges():
		if s.get("tier", "") == "small" and (small.is_empty() or Stadiums._capacity(s) < Stadiums._capacity(small)):
			small = s
		if s.get("tier", "") == "top" and (big.is_empty() or Stadiums._capacity(s) > Stadiums._capacity(big)):
			big = s
	var c := _career(CareerData.STAGE_COLLEGE, small)
	var opp := Progression.team_from(big, CareerData.STAGE_COLLEGE)
	var home := Stadiums.for_game(c, {"week": 2, "home": true, "opponent": opp}, t)
	var away := Stadiums.for_game(c, {"week": 2, "home": false, "opponent": opp}, t)
	eq(home.tier, "college_small", "home: your stadium")
	eq(away.tier, "college_top", "away: theirs")
	var their: Color = Color.from_string(str(big["colors"][0]), Color.BLACK)
	eq(away.crowd_colors[0], their, "their crowd")
	eq(home.night, away.night, "the night pick doesn't depend on who hosts")


func test_challenges_at_neutral_sites() -> void:
	var c := _career(CareerData.STAGE_HIGH_SCHOOL, CareerContent.high_schools()[0])
	var tr := {"purpose": "challenge", "kind": "showcase", "stage": "high_school", "team": c.team["id"]}
	eq(Stadiums.for_tryout(c, tr, t).tier, "college_small", "a showcase at a small college")
	tr["kind"] = "battle"
	check(Stadiums.for_tryout(c, tr, t).tier.begins_with("hs_"), "a kicker battle at home")
	check(not Stadiums.for_tryout(c, tr, t).night, "in the daytime")
	tr = {"purpose": "challenge", "kind": "combine", "stage": "college", "team": ""}
	eq(Stadiums.for_tryout(c, tr, t).tier, "pro_1", "a combine at a pro stadium")
	var p := _career(CareerData.STAGE_PRO, CareerContent.pro_clubs()[0])
	var audition := {"purpose": "audition", "stage": "pro", "team": p.team["id"]}
	eq(Stadiums.for_tryout(p, audition, t).tier, Stadiums.tier_for(p.team, CareerData.STAGE_PRO, t),
		"an audition at your own stadium")


func test_kick_look_carries_the_stadium() -> void:
	var c := _career(CareerData.STAGE_HIGH_SCHOOL, CareerContent.high_schools()[0])
	var m := CareerManager.new(c, t)
	m.rng.seed = 3
	m._start_season(false)
	var look := m.kick_look()
	check(look.get("stadium") is StadiumSpec, "the look has a stadium")
	check((look["stadium"] as StadiumSpec).night, "high school: night")


func test_every_tier_builds_within_budget() -> void:
	var original := StadiumSpec.new()
	eq(original.draw_calls(), 10, "the original stadium")
	eq(_built_meshes(original), 10, "builds as before")
	for id in StadiumSpec.preset_ids():
		var st := StadiumSpec.preset(id)
		eq(st.tier, id, "preset %s exists" % id)
		check(st.draw_calls() <= DRAW_CALL_BUDGET, "%s: %d draw calls (budget %d)" % [id, st.draw_calls(),
			DRAW_CALL_BUDGET])
		for night in [false, true]:
			st.night = night
			eq(_built_meshes(st), st.draw_calls(), "%s%s builds what it promises" % [id,
				" (night)" if night else ""])


## Stadium meshes FieldBuilder adds for a spec (goal end and wings; not the
## posts, the ground or the players).
func _built_meshes(st: StadiumSpec) -> int:
	var game := FIELD_GOAL.instantiate()
	var f := game.get_node("Field") as FieldBuilder
	f.goal_end = f.get_node("GoalEnd")
	f._stadium = st
	var before := f.get_child_count()
	f._build_stands()
	var n := 0
	for child in f.goal_end.get_children():
		if child is MeshInstance3D:
			n += 1
	for i in range(before, f.get_child_count()):
		for child in f.get_child(i).get_children():
			if child is MeshInstance3D:
				n += 1
	game.free()
	return n

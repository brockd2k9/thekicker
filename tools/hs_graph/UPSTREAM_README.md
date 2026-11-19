# Kicker — High School Scenario Dependency System

Godot target: 4.4

## Files
- `high_school_scenarios.json`: 160 scenario records and dependency edges.
- `scenario_manager.gd`: lightweight scheduler/state manager.

## Install
1. Copy `high_school_scenarios.json` into `res://data/high_school_scenarios.json`.
2. Copy `scenario_manager.gd` into your scripts folder.
3. Add the script as an Autoload named `ScenarioManager`, or instantiate it.
4. Call `ScenarioManager.set_year(1)` when freshman year begins.
5. When the player selects a choice, call:
   `ScenarioManager.complete_scenario("HS_101", choice_dictionary)`

## Important integration note
The manager tracks flags, eligibility, exclusions, completion, and selection. It intentionally does not modify player stats; connect choice `effects` to your existing player-stat system.

The 60 new scenario records include their IDs, titles, year assignment, key output flags, and important eligibility requirements. The original 100 are included by ID/title/year, but their exact choice effects and flags must be imported from the original authored scenario text rather than guessed.

## Choice data shape
Each scenario should ultimately contain:
```gdscript
"choices": [
    {
        "id": "honest_choice",
        "effects": {"leadership": 1, "resilience": 1},
        "set_flags": ["earned_coach_trust"],
        "clear_flags": [],
        "unlock_scenarios": ["HS_117"],
        "cancel_scenarios": ["HS_155"]
    }
]
```

## Recommended next step
Import each authored choice into the JSON and make sure every choice has unique IDs and explicit flag outcomes. Then connect `effects` to the player stats system and add delayed triggers if you want consequences to happen a set number of weeks later.

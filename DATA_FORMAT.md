# Team data format

Every team in the game (high school, college and pro) comes from the team
database in `data/teams/`. No team is defined anywhere in code; the game reads
teams only through the `TeamDatabase` autoload
(`scripts/teams/team_database.gd`).

```
data/teams/source/*.csv     you edit these (one or more CSV files per level)
        |  python3 tools/teams/import_teams.py
        v
data/teams/high_school.json, college.json, pro.json    generated: don't edit
data/teams/leagues.json     levels -> divisions -> conferences, start team
data/teams/colors.json      color names -> hex
data/teams/legacy_ids.json  old team ids -> new ids (old saves)
        |  godot --headless --path . res://tools/validate_teams.tscn
        v
"TEAM DATA: 0 error(s), N warning(s)"   exit code = number of errors
```

## Sending team data

Send **one CSV per level** (or one per division, as with the D2 roster). UTF-8,
first row = column names, one team per row. The D2 roster CSV is the model:
its columns import as they are.

| File name starts with | Level |
|---|---|
| `high_school_` | High school |
| `college_` | College (FBS, FCS, D2, JUCO ...) |
| `pro_` | Pro |

(Or add a `Level` column with `high_school`, `college` or `pro`.)

Column names are matched loosely: case, spaces and punctuation don't matter
(`Minimum GPA` = `min_gpa` = `MinimumGPA`). Columns the importer doesn't know
are kept on the team under `extra`, so nothing you send is lost.

## Fields

**Required** (the validator reports a team that's missing one):

| CSV column | JSON field | What |
|---|---|---|
| `ID` | `id` | Stable unique id: lowercase letters, digits, `_` (`hoboken_hs`). Saves refer to it, so **never change an id once it's in use**. Left blank, the importer makes one from the name (`Florida University` -> `florida_university`). |
| `School` (or `Name`, `Club`; pro: `Team Name`) | `name` | School or club name: `Hoboken High School`, `Florida University`, `Buffalo Bisons`. |
| `Team` (or `Nickname`) | `nickname` | Team nickname: `Rebels`. A leading town is dropped (`Burlington Timberhawks` in Burlington -> `Timberhawks`, `New York Guardians` in New York -> `Guardians`). Pro: taken from `Team Name` the same way. |
| `Abbreviation` | `abbr` | 2-4 letters for scoreboards and the field tracker. Blank = generated (see below). |
| `Division` | `division` | High school: `HS` (default when blank). College: `FBS`, `FCS`, `D2`, `JUCO`. Pro: `AFC`, `NFC`. Must be in `leagues.json`. |
| `Conference` | `conference` | The group a team plays in (schedules start there): a high school or college conference, or a pro division (`AFC East`). Must be listed under the division in `leagues.json`. |
| `School Colors` (or `Colors`, `Team Colors`) | `colors` | Comma-separated, primary first: `Red, White, Silver`. Color names from `colors.json` or hex (`#c8102e`). Blank = the home jersey and home pants colors. |

**Optional** (left blank = left out; the game never invents values):

| CSV column | JSON field | Used by the game |
|---|---|---|
| `City` (or `Market`), `State`, `County`, `Region` | `city`, `state`, `county`, `region` | City: team records ("town"), hometown. Others: shown/kept. |
| `League` | `league` | Kept (`Kicker Professional Football League`). |
| `Mascot` | `mascot` | Kept (as `mascot_figure` on the record; the game calls the nickname "mascot"). |
| `Stadium`, `Capacity` (or `Stadium Capacity`) | `stadium.name`, `stadium.capacity` | Kept for game-day presentation. A town repeated at the start of the name is removed on import (see "Import report"). |
| `Prestige` | `ratings.prestige` | 0-100. Sets the team's sim **strength** when `Strength` is blank: spread 35-80 within its division, or over the level's `strength_range` in `leagues.json` (pro: 55-75). |
| `Crowd Noise`, `Draft Rating`, `Fan Base` | `ratings.crowd_noise`, `.draft_rating`, `.fan_base` | 0-100. Kept (reserved for game day, the draft and pro fans). |
| `Recruiting Points`, `Minimum Player OVR`, `Minimum GPA` | `recruiting.points`, `.min_ovr`, `.min_gpa` | Kept per school (reserved: offers currently use the tier thresholds in `progression.json`). |
| `National Championships`, `Conference Championships`, `Bowl Wins` | `history.*` | Kept. |
| `Franchise History` (pro) | `history.conference_titles`, `.league_titles`, `.summary` | `AFC Championship 2; League Titles 1` is read as 2 conference titles, 1 league title; the text is kept as `summary`. |
| `Team Identity` | `identity` | Kept (a line about the team). |
| `Home Jersey`, `Home Pants`, `Home Helmet`, `Away Jersey`, `Away Pants`, `Away Helmet` | `uniforms.home/away.jersey/pants/helmet` | Colors (names or hex). Kept; home jersey/pants fill `colors` when that's blank. |
| `Rival` (or `Primary Rival`), `Rivalry Trophy` | `rival.name`, `rival.trophy`, `rival.id` | The rival's school name; the importer finds its id. Must be a real team. |
| `Strength` (or `Rating`) | `strength` | 0-100 team quality for the game sim. Overrides prestige. Neither given = 50. |
| `Placeholder` | `placeholder` | `yes` = stand-in data (the validator lists these). |
| `Notes` | `notes` | Free text. |

### What a level / division means in game

* **High school**: every career starts at the `start_team` in `leagues.json`
  (`hoboken_hs`, Hoboken High School). The season schedule is drawn from your
  own conference first.
* **College**: each division has a recruiting `tier` in `leagues.json`:
  `FBS` -> `top`, `FCS` -> `mid`, `D2` -> `small`, `JUCO` -> `juco` (the
  junior college route). Tiers set offer thresholds, GPA bars, kick range and
  scout exposure (`data/career/progression.json`). Adding a division = add it
  to `leagues.json` with a tier.
* **Pro**: the draft, contracts, camps and free agency pick from these teams.
  The pro guide groups clubs as Conference (AFC) > Division (AFC East). In the
  team data the group a team plays in is always `conference`, so for pro the
  importer reads the guide's Conference as `division` and its Division as
  `conference` (it swaps them when the Division starts with the Conference).
  A pro season starts with the other three clubs in your division.

### Abbreviations

Must be unique within a conference (an error otherwise) and preferably within
the level (a warning). Generated ones: high school = the town's first three
letters (`Hoboken` -> `HOB`); pro = the market (`Buffalo` -> `BUF`,
`Kansas City` -> `KC`), plus the nickname's first letter when two clubs share
a market (`NYG`, `NYE`); college = initials without "of / the / at"
(`Florida University` -> `FU`), else town letters; a number is added if
everything is taken. Give an abbreviation in the CSV to choose it yourself.

### Colors

Names are case-insensitive and must be in `data/teams/colors.json` (black,
white, silver, gray, red, cardinal red, crimson, scarlet, maroon, orange,
gold, navy, royal blue, kelly green, forest green, purple, teal ... ). A new
name: add it there with its hex. Hex values (`#1f3a8a`) always work.

## Samples (generated JSON)

High school (`data/teams/high_school.json`), required + what the bible gave:

```json
{
 "id": "hoboken_hs", "level": "high_school",
 "name": "Hoboken High School", "nickname": "Rebels", "mascot": "Rebel",
 "abbr": "HOB", "division": "HS", "conference": "South Georgia Coastal-Pine Division",
 "city": "Hoboken", "state": "GA", "county": "Satilla County", "region": "South Georgia",
 "colors": ["Red", "White", "Silver"],
 "uniforms": {"home": {"jersey": "Red", "pants": "Silver", "helmet": "Silver"},
              "away": {"jersey": "White", "pants": "Silver", "helmet": "Silver"}},
 "stadium": {"name": "Rebel Field"}
}
```

College (`data/teams/college.json`):

```json
{
 "id": "florida_university", "level": "college",
 "name": "Florida University", "nickname": "Marshals", "abbr": "FU",
 "division": "FBS", "conference": "Southern Athletic Conference",
 "city": "Gainesville", "state": "FL", "region": "Southeast",
 "colors": ["Royal Blue", "White"],
 "uniforms": {"home": {"jersey": "Royal Blue", "pants": "White"},
              "away": {"jersey": "White", "pants": "Silver"}},
 "stadium": {"name": "Gainesville Marshals Stadium", "capacity": 75000},
 "ratings": {"prestige": 90, "crowd_noise": 79, "draft_rating": 48},
 "recruiting": {"points": 810, "min_ovr": 62, "min_gpa": 3.2},
 "history": {"national_titles": 1, "bowl_wins": 21},
 "rival": {"name": "Georgia University", "trophy": "Heritage Cup", "id": "georgia_university"}
}
```

Pro (`data/teams/pro.json`):

```json
{
 "id": "buffalo_bisons", "level": "pro",
 "name": "Buffalo Bisons", "nickname": "Bisons", "mascot": "Bison", "abbr": "BUF",
 "division": "AFC", "conference": "AFC East", "league": "Kicker Professional Football League",
 "city": "Buffalo", "colors": ["Royal Blue", "Red", "White"],
 "stadium": {"name": "Highmark Prairie Stadium", "capacity": 68400},
 "ratings": {"prestige": 82, "crowd_noise": 94, "fan_base": 80},
 "history": {"conference_titles": 2, "league_titles": 1, "summary": "AFC Championship 2; League Titles 1"},
 "rival": {"name": "Miami Sharks", "id": "miami_sharks"},
 "identity": "Cold-weather identity, physical defense, relentless home crowd."
}
```

The pro guide CSV (`data/teams/source/pro_kpfl.csv`) imports as it came:
`League, Conference, Division, Market, Team Name, Mascot, Stadium, Stadium
Capacity, Crowd Noise, Prestige, Fan Base, Team Colors, Primary Rival,
Franchise History, Team Identity`.

## Team record (what the game sees)

`TeamDatabase.team(id)` returns the JSON entry plus fields the game's systems
use: `mascot` (= nickname), `short` (= abbr), `town` (= city), `colors` as
hex, `color_names`, `strength`, `tier` (college) and `level`. A player's team
and schedule opponents are saved inside the career (`Progression.team_from`),
so a save keeps the names it was played under.

## Validator

`TeamDatabase.validate()` (run by `tools/validate_teams.tscn`, the tests, and
at startup in debug builds) reports:

Errors: missing required field; bad or duplicate id; unknown division or
conference (not in `leagues.json`); abbreviation used twice in a conference;
unknown color; rival that isn't a team; a level with fewer than 2 teams; start
team missing or not a high school.

Warnings: abbreviation in use elsewhere in the level or not 2-4 letters; no
strength or prestige (sim uses 50); a stadium name that repeats a word from
the school name (`Prairie View Prairie Stadium` at Brazos Prairie University);
any other word repeated twice in a row in a name or stadium; a conference with
no teams; placeholder teams.

## Import report

Every import writes `data/teams/import_report.md` for review:

* **Stadium names cleaned**: the importer removes a town repeated at the start
  of a stadium name, judged per row (`clean_stadium`): the town twice in a row
  (`Burlington Burlington Timberhawks Field` -> `Burlington Timberhawks Field`),
  or the town followed by a cut-short Team column (`New Bedford New Redtails
  Field` -> `New Bedford Redtails Field`). The CSVs are left as sent.
* **Stadium names left as they were**: a word repeats but not in those
  patterns (`Beaver Falls Beaver Stadium`), so it may be intended. Check them
  and fix the CSV if needed.
* **Team column cut short**: the Team column holds only a multi-word town's
  first word plus the nickname (`New Redtails` for New Bedford); the nickname
  used and other teams with the same nickname are listed.

## Changing ids, and old saves

Saves store team ids. If an id has to change, add `"old_id": "new_id"` to
`data/teams/legacy_ids.json` and a migration step (see `CareerSave._migrate`).
Version 8 used that file to move saves from the old built-in teams: the
player's high school became Hoboken, other old high schools and colleges map
to database teams of the same level and recruiting tier. Version 9 moved the
12 placeholder pro clubs to league clubs (`"pro"` in the same file).

## Commands

```
python3 tools/teams/import_teams.py                         # CSVs -> data/teams/*.json
godot --headless --path . res://tools/validate_teams.tscn   # check (add -- warnings=0 for errors only)
godot --headless --path . res://tests/run_tests.tscn -- only=test_team_database
```

`tools/teams/guides_to_csv.py` converted the high school bible and the FBS /
FCS program guide PDFs into the source CSVs (needs `pdftotext`); new data
should come as CSV.

# Stadiums: optional team fields (for the story session)

Gameplay picks each game's stadium from the home team (scripts/career/stadiums.gd). Nothing is
required: today high school and pro use `strength`, college uses `tier`, junior college is always
bleachers. Two optional fields on any team in `data/career/world.json` (high_school.schools,
college.schools, juco.schools, pro.clubs):

| Field | Type | Effect |
|---|---|---|
| `capacity` | int (seats) | Decides the stadium tier instead of strength / tier. Bands: high school under 3,000 / under 8,000 / more; college under 30,000 / under 60,000 / more; pro under 62,000 / under 70,000 / more. Junior college ignores it. |
| `stadium` | string | The stadium's name, e.g. "Falcon Field". Carried on the team; not shown on screen yet. |

Example: `{"id": "ridgeline", ..., "strength": 62, "capacity": 4500, "stadium": "Falcon Field"}`.

Story hooks: high school games are always at night; college games are at night 25% of the time
and pro games 20%. There is no scenario flag for night games or the stadium yet; ask if one would
help.

#!/usr/bin/env python3
"""One-off converter: high school story graph skeleton -> our scenario format.

    python3 tools/convert_hs_graph.py            # writes data/career/scenarios_hs_graph.json
    python3 tools/convert_hs_graph.py --check    # exit 1 if the output would change

Source: tools/hs_graph/high_school_scenarios.json (160 id/title/year/flag records plus
dependency edges, from an outside tool; see tools/hs_graph/UPSTREAM_README.md).

Every scenario comes out as a draft ("draft": true, no text, no choices); the
engine never picks drafts and CareerContent.validate() only checks their graph
data. Writing the content later: fill in category, text and choices, then
remove "draft". Re-running keeps what you wrote (category, text, choices,
weight, cooldown, gate, draft) and regenerates only the graph fields, so
change the decision tables below rather than the graph fields in the output.

How the skeleton maps onto our format:
  year 1-4                -> seasons [y, y]   (year 0 = any season, see YEAR0_SEASONS)
  requires_all_flags      -> requires.flags
  requires_any_flags      -> requires.any_flags, plus every unlock edge's flag
                             (except targets in UNGATED: those stay open)
  excludes_any_flags      -> requires.not_flags, plus every exclude edge's flag
  sets_flags              -> expected_flags (the choices must set these), plus the
                             flag of every edge leaving the scenario
  priority "story"        -> story: true with a week window (STORY_WINDOWS)
  repeatable false        -> once: true
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "tools", "hs_graph", "high_school_scenarios.json")
OUT = os.path.join(ROOT, "data", "career", "scenarios_hs_graph.json")

# --- decisions (Step 1, approved) -------------------------------------------------------

# Unlock edges into these stay unenforced: the scenario is open to everyone.
UNGATED = {"HS_021", "HS_041", "HS_073"}

# Story scenarios: seasons + week window, or the offseason after that season.
# They're boosted while the window is open and forced in its last week.
STORY_WINDOWS = {
    "HS_117": {"seasons": [2, 2], "weeks": [2, 6]},
    "HS_121": {"seasons": [3, 3], "when": ["offseason"]},   # summer before senior year
    "HS_125": {"seasons": [3, 3], "weeks": [4, 8]},
    "HS_138": {"seasons": [3, 3], "weeks": [6, 10]},
    "HS_142": {"seasons": [4, 4], "weeks": [2, 6]},         # not in the Step 1 table
    "HS_143": {"seasons": [4, 4], "weeks": [1, 4]},
    "HS_146": {"seasons": [4, 4], "weeks": [1, 3]},
    "HS_150": {"seasons": [4, 4], "weeks": [3, 7]},
    "HS_155": {"seasons": [3, 4], "weeks": [2, 10]},        # not in the Step 1 table
    "HS_158": {"seasons": [4, 4], "weeks": [6, 9]},
}

# Hard story beats (guaranteed, shown once). Their requirements move onto the
# choices (locked choices are shown with lock_text), so the scene always plays.
BEATS = {
    "HS_160": {"beat": {"season_in_stage": 4, "week": 10}, "seasons": [4, 4],
               "choice_locks": ["recruiting_values_clear", "family_college_compromise",
                                "secured_academic_path"]},
}

# Week windows for ordinary scenarios, so a flag's source comes before its reader
# in the same season (Step 1: "same-year edges get split windows").
WINDOWS = {
    "HS_132": [1, 5], "HS_137": [6, 11],    # new-kicker friendship -> rival's message
    "HS_148": [5, 11],                      # after HS_143 (weeks 1-4)
    "HS_144": [1, 7], "HS_145": [1, 8],     # before HS_159 (weeks 9-10)
    "HS_159": [9, 10],
    "HS_152": [1, 9],                       # before HS_160 (week 10)
    "HS_058": [1, 5],
}

# Year-0 ("shared") scenarios: seasons (+ weeks). Anything not listed stays open
# to every high school season.
ENDING = {"seasons": [4, 4], "weeks": [8, 10]}
YEAR0_SEASONS = {
    "HS_091": ENDING, "HS_092": ENDING, "HS_093": ENDING, "HS_095": ENDING,
    "HS_096": ENDING, "HS_097": ENDING, "HS_099": ENDING, "HS_100": ENDING,
    "HS_076": {"seasons": [3, 4]}, "HS_078": {"seasons": [3, 4]},
    "HS_088": {"seasons": [3, 4]}, "HS_098": {"seasons": [3, 4]},
    "HS_094": {"seasons": [2, 4]},          # remembers freshman year (HS_003)
}

# Flags that only the scenario itself sets: dropped from its own requirements.
DROP_SELF_REQUIRES = {"HS_159": ["recognized_team_support"],
                      "HS_160": ["college_decision_pending"]}

# Duplicates (Stage A, after the table is approved):
#   id -> None              drop the scenario
#   id -> "other_id"        drop it and alias it to other_id: edges and expected
#                           flags move to other_id (for an existing scenario they
#                           are listed in its authoring note instead)
DUPLICATES = {
    "HS_010": "hs_part_time_job",   # same scene, already written; no chain
    "HS_037": "HS_112",             # same scene; HS_112 has its outcome flags
    "HS_038": "HS_106",             # HS_106 starts the backup-holder chain (HS_145)
    "HS_041": "hs_recruiter_call",  # already written; it sets recruiter_trust (HS_058, HS_088)
    "HS_042": "hs_grades_warning",  # ours fires off the real GPA; HS_021's flag is flavor
    "HS_047": "HS_121",             # HS_121 (story) is the same junior-year camp conflict
    "HS_050": "HS_130",             # kicker-specific, sets learned_from_senior
    "HS_066": "HS_159",             # payoff of the leadership / holder / coach chain
    "HS_096": "HS_149",             # senior year already has hs_campus_visit and HS_152
    "HS_100": "HS_160",             # the senior week 10 beat
}

# Recurring characters per scenario, for writers (Option B, confirmed):
#   tyler       Tyler Brooks, a kicker on your own team from freshman year (HS_005);
#               friend or rival depending on your choices. He goes on to college and
#               the pros, so he can appear again later (relationship system, Stage B).
#   new_qb      a new quarterback who arrives sophomore year (HS_111); high school
#               only, tracked with flags (no relationship value). In the upstream
#               skeleton he was a second kicker; "Rival" in HS_137's title means him.
PEOPLE = {
    "HS_005": ["tyler"], "HS_030": ["tyler"], "HS_046": ["tyler"], "HS_092": ["tyler"],
    "HS_111": ["new_qb"], "HS_132": ["new_qb"], "HS_137": ["new_qb"], "HS_147": ["tyler"],
}

# Renames applied to the skeleton before converting (the New Kicker is a quarterback).
TITLE_OVERRIDES = {"HS_111": "The New Quarterback"}
FLAG_RENAMES = {
    "welcomed_new_kicker": "welcomed_new_qb",
    "new_kicker_rivalry": "new_qb_rivalry",
    "new_kicker_friendship": "new_qb_friendship",
    "new_kicker_relationship_cool": "new_qb_relationship_cool",
}

# Choice -> follow-up hints for the authoring template (not enforced).
FOLLOW_UP_HINTS = {
    "HS_138": [{"flag": "questionable_recruiting_clip", "id": "HS_155", "weeks": 3}],
    "HS_125": [{"flag": "hid_injury", "id": "HS_143", "weeks": 4}],
}

CONTENT_FIELDS = ["category", "text", "choices", "weight", "cooldown", "gate", "draft", "when"]


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def uniq(xs):
    out = []
    for x in xs:
        if x not in out:
            out.append(x)
    return out


# HS_147 "The Starting Job Is Yours" is about the kicking job, so it belongs to
# Tyler (your teammate kicker), not the new quarterback: open once HS_005 has
# set either Tyler flag, instead of the quarterback's flags.
REASSIGN = {"HS_147": {"requires_any_flags": ["befriended_tyler", "hostile_tyler_rivalry"],
                       "edges_from": "HS_005"}}


def apply_renames(src):
    ren = lambda xs: [FLAG_RENAMES.get(f, f) for f in xs]
    for sid, r in REASSIGN.items():
        src["dependencies"] = [e for e in src["dependencies"] if e["to"] != sid]
        for f in r["requires_any_flags"]:
            src["dependencies"].append({"from": r["edges_from"], "to": sid, "when": f, "type": "unlock"})
        for sc in src["scenarios"]:
            if sc["id"] == sid:
                sc["requires_any_flags"] = list(r["requires_any_flags"])
    for s in src["scenarios"]:
        s["title"] = TITLE_OVERRIDES.get(s["id"], s["title"])
        for k in ("requires_all_flags", "requires_any_flags", "excludes_any_flags", "sets_flags"):
            s[k] = ren(s.get(k, []))
    for e in src["dependencies"]:
        e["when"] = FLAG_RENAMES.get(e["when"], e["when"])
    return src


def convert(src):
    src = apply_renames(src)
    scen = {s["id"]: s for s in src["scenarios"]}
    edges = list(src["dependencies"])
    aliases = {k: v for k, v in DUPLICATES.items() if v}
    existing_alias_notes = {}

    def target(i):
        return aliases.get(i, i)

    # Re-point edges at alias winners; drop edges touching dropped scenarios.
    moved = []
    for e in edges:
        a, b = e["from"], e["to"]
        if (a in DUPLICATES and DUPLICATES[a] is None) or (b in DUPLICATES and DUPLICATES[b] is None):
            continue
        if target(b) not in scen:
            continue  # into an existing written scenario: it isn't gated by graph flags
        moved.append(dict(e, **{"from": target(a), "to": target(b)}))
    edges = moved

    out = []
    for sid, s in scen.items():
        if sid in DUPLICATES:
            continue
        year = int(s.get("year", 0))
        d = {"id": sid, "title": s["title"], "draft": True, "category": "", "text": "",
             "stages": ["high_school"]}
        if year:
            d["seasons"] = [year, year]
        d.update(YEAR0_SEASONS.get(sid, {}) if year == 0 else {})
        if sid in WINDOWS:
            d["weeks"] = WINDOWS[sid]
        d["once"] = not s.get("repeatable", False)
        if s.get("priority") == "story" and sid in STORY_WINDOWS:
            d["story"] = True
            d.update(STORY_WINDOWS[sid])
        beat = BEATS.get(sid)
        if beat:
            d["beat"] = beat["beat"]
            d["seasons"] = beat["seasons"]

        incoming = [e for e in edges if e["to"] == sid]
        all_f = list(s.get("requires_all_flags", []))
        any_f = list(s.get("requires_any_flags", []))
        not_f = list(s.get("excludes_any_flags", []))
        for e in incoming:
            if e["type"] == "unlock" and sid not in UNGATED:
                any_f.append(e["when"])
            elif e["type"] == "exclude":
                not_f.append(e["when"])
        drop = DROP_SELF_REQUIRES.get(sid, [])
        all_f = [f for f in uniq(all_f) if f not in drop]
        any_f = [f for f in uniq(any_f) if f not in drop and f not in all_f]
        req = {}
        if beat:
            any_f = []  # moved onto the choices
        if all_f:
            req["flags"] = all_f
        if any_f:
            req["any_flags"] = any_f
        if not_f:
            req["not_flags"] = uniq(not_f)
        if req:
            d["requires"] = req

        outgoing = [e["when"] for e in edges if e["from"] == sid]
        for a, w in aliases.items():
            if w == sid:
                outgoing += list(scen[a].get("sets_flags", []))
        d["expected_flags"] = uniq(list(s.get("sets_flags", [])) + outgoing)

        note = {}
        if incoming:
            note["unlocked_by"] = [{"from": e["from"], "flag": e["when"], "type": e["type"]}
                                   for e in incoming]
            if sid in UNGATED:
                note["ungated"] = "Open to everyone; the unlock flags are flavor only."
        leads = [{"to": e["to"], "flag": e["when"]} for e in edges if e["from"] == sid]
        if leads:
            note["leads_to"] = leads
        if beat:
            note["choice_locks"] = beat["choice_locks"]
            note["beat_note"] = ("Always plays. Give one choice per lock flag "
                                 "(requires {flags: [flag]} + lock_text) and one open choice.")
        if sid in PEOPLE:
            note["people"] = PEOPLE[sid]
        if sid in FOLLOW_UP_HINTS:
            note["follow_up_hints"] = FOLLOW_UP_HINTS[sid]
        a_from = sorted(a for a, w in aliases.items() if w == sid)
        if a_from:
            note["absorbs"] = a_from
        d["authoring"] = note
        d["choices"] = []
        out.append(d)

    # Aliases onto existing (non-graph) scenarios: record what they must now carry.
    for a, w in aliases.items():
        if w not in scen:
            existing_alias_notes[a] = {"alias_of": w, "title": scen[a]["title"],
                                       "flags_to_add": uniq(list(scen[a].get("sets_flags", []))
                                       + [e["when"] for e in src["dependencies"] if e["from"] == a])}
    return out, existing_alias_notes


def main():
    check = "--check" in sys.argv
    src = load(SRC)
    out, alias_notes = convert(src)
    # Keep authored content from an earlier run.
    if os.path.exists(OUT):
        old = {s["id"]: s for s in load(OUT).get("scenarios", [])}
        for d in out:
            prev = old.get(d["id"])
            if prev:
                for k in CONTENT_FIELDS:
                    if k in prev:
                        d[k] = prev[k]
                    elif k in d and k == "draft":
                        del d[k]
        # Scenarios that aren't in the skeleton (follow-ups added by
        # tools/import_scenarios.py) are kept as they are.
        made = {d["id"] for d in out}
        out += [s for i, s in old.items() if i not in made and s.get("added_by_import")]
    doc = {
        "_doc": ("High school story graph (HS_001-HS_160), generated by tools/convert_hs_graph.py "
                 "from tools/hs_graph/high_school_scenarios.json. Same fields as scenarios_hs.json "
                 "(see its _doc). 'draft': true = no content yet, never picked. 'expected_flags' = flags "
                 "some choice must set (checked once the draft flag is removed). 'authoring' = notes "
                 "for writers (unlocked_by, leads_to, choice_locks, follow_up_hints); the game "
                 "ignores it. Edit category/text/choices here; change graph fields via the "
                 "converter's decision tables."),
        "aliases_to_existing": alias_notes,
        "scenarios": out,
    }
    text = json.dumps(doc, indent="\t", ensure_ascii=False) + "\n"
    if check:
        same = os.path.exists(OUT) and open(OUT, encoding="utf-8").read() == text
        print("up to date" if same else "would change")
        sys.exit(0 if same else 1)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"wrote {OUT}: {len(out)} scenarios ({sum(1 for d in out if d.get('draft'))} drafts)")


if __name__ == "__main__":
    main()

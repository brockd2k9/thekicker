#!/usr/bin/env python3
"""Builds the fill-in templates for the high school story graph.

    python3 tools/make_authoring_templates.py

Writes, from data/career/scenarios_hs_graph.json (the live graph data):
    tools/authoring/hs_template_all.json        every graph scenario (150)
    tools/authoring/hs_template_freshman.json   the freshman starter slice (25)

Each entry has the fields a writer fills in (category, text, choices) and a
read-only "_info" block (season, weeks, requirements, flags it must set,
people involved, where it leads). Choices come pre-shaped: one per expected
flag (2-4), with that flag already in set_flags and a rel slot for every
cast member the scenario involves. Fill them in, then run
tools/import_scenarios.py (see tools/authoring/WRITING_GUIDE.md).

Re-running overwrites both templates, so copy a template before writing in it
(the guide suggests tools/authoring/work/).
"""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GRAPH = os.path.join(ROOT, "data", "career", "scenarios_hs_graph.json")
OUT_DIR = os.path.join(ROOT, "tools", "authoring")

YEARS = {1: "Freshman", 2: "Sophomore", 3: "Junior", 4: "Senior"}

# People a scenario involves, from its title and flags. "new_qb" (the new
# quarterback) has story flags but no relationship value, so no rel slot.
PEOPLE_RULES = [
    # (not the clinic coach of HS_117 / clinic_coach_trust, not a college coach)
    ("coach", r"(?<!college )\bcoach'?s?\b(?! who remembers)|(?<!clinic_)coach_trust|coach_confidence|"
              r"coach_decision|coach_for_help|current_coach|coach_reviewed|coach_customized|new_coach"),
    ("holder", r"holder"),
    ("teacher", r"teacher"),
    ("parent", r"\bdad\b|\bparent|(?<!teammate's )\bfamily\b|family_"),
    ("sibling", r"little brother"),
    ("best_friend", r"\bfriend who\b|\bfriends\b"),
    ("love_interest", r"\bdance\b|\bdate\b|almost-date|breakup|relationship ultimatum"),
]
NO_REL = {"new_qb"}

# The freshman starter slice: chain starters in season 1, the first scenario
# each chain leads to, and freshman scenarios that introduce the cast.
SLICE_STARTERS = ["HS_003", "HS_005", "HS_101", "HS_103", "HS_104", "HS_106", "HS_107", "HS_002"]
SLICE_FIRST_HOPS = ["HS_034", "HS_030", "HS_126", "HS_139", "HS_157", "HS_145", "HS_134"]
SLICE_CAST_INTROS = ["HS_001", "HS_004", "HS_009", "HS_011", "HS_012", "HS_017", "HS_013", "HS_008",
                     "HS_102", "HS_110"]


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def people_for(s):
    found = list(s.get("authoring", {}).get("people", []))
    text = " ".join([s["title"].lower()] + list(s.get("expected_flags", []))
                    + list(s.get("requires", {}).get("any_flags", [])))
    for pid, rx in PEOPLE_RULES:
        if pid not in found and re.search(rx, text):
            found.append(pid)
    return [("rival" if p == "tyler" else p) for p in found]


def when_text(s):
    se = s.get("seasons")
    if s.get("beat"):
        b = s["beat"]
        return f"{YEARS.get(b['season_in_stage'], b['season_in_stage'])} year, week {b['week']} (always plays)"
    if se and se[0] == se[1]:
        yr = f"{YEARS.get(se[0], se[0])} year (season {se[0]})"
    elif se:
        yr = f"seasons {se[0]}-{se[1]} ({YEARS.get(se[0])} to {YEARS.get(se[1])})"
    else:
        yr = "any high school season"
    if s.get("when") == ["offseason"]:
        return yr + ", in the offseason after that season"
    wk = s.get("weeks")
    return yr + (f", weeks {wk[0]}-{wk[1]}" if wk else ", any week")


def entry(s):
    people = people_for(s)
    rel_people = [p for p in people if p not in NO_REL]
    a = s.get("authoring", {})
    flags = list(s.get("expected_flags", []))
    info = {
        "when": when_text(s),
        "story": ("Story event: more likely while its window is open, and it always happens in the "
                  "window's last week if it hasn't yet.") if s.get("story") else None,
        "requires": s.get("requires") or None,
        "must_set_flags": flags or None,
        "people": people or None,
        "unlocked_by": a.get("unlocked_by"),
        "leads_to": a.get("leads_to"),
        "absorbs": a.get("absorbs"),
        "notes": a.get("beat_note") or a.get("ungated") or a.get("note"),
        "follow_up_hints": a.get("follow_up_hints"),
    }
    info = {k: v for k, v in info.items() if v}
    n = max(2, min(4, len(flags) if flags else 3))
    choices = []
    for i in range(n):
        ch = {"label": "", "result": "",
              "stats": {"life": {}, "football": {}, "personality": {}},
              "modifiers": [], "set_flags": {}}
        if i < len(flags):
            ch["set_flags"] = {flags[i]: True}
        if rel_people:
            ch["rel"] = {p: 0 for p in rel_people}
        choices.append(ch)
    # Flags beyond four choices: put them on the last choices too.
    for j, f in enumerate(flags[4:]):
        choices[j % n]["set_flags"][f] = True
    locks = a.get("choice_locks", [])
    if locks:
        choices = []
        for f in locks:
            choices.append({"label": "", "result": "", "requires": {"flags": [f]}, "lock_text": "",
                            "stats": {"life": {}, "football": {}, "personality": {}}, "modifiers": [],
                            "set_flags": {}})
        choices.append({"label": "", "result": "", "stats": {"life": {}, "football": {}, "personality": {}},
                        "modifiers": [], "set_flags": {}})
        for i, f in enumerate(flags):
            choices[i % len(choices)]["set_flags"][f] = True
        choices = choices[:4]
    return {"id": s["id"], "title": s["title"], "_info": info, "category": "", "text": "", "choices": choices}


GUIDE_POINTER = ("Fill in category, text and choices; leave _info alone (it's read-only). See "
                 "tools/authoring/WRITING_GUIDE.md. Import: python3 tools/import_scenarios.py <this file> --dry-run")


def main():
    graph = [s for s in load(GRAPH)["scenarios"] if not s.get("added_by_import")]
    by_id = {s["id"]: s for s in graph}
    os.makedirs(OUT_DIR, exist_ok=True)
    everything = [entry(s) for s in graph]
    slice_ids = SLICE_STARTERS + SLICE_FIRST_HOPS + SLICE_CAST_INTROS
    missing = [i for i in slice_ids if i not in by_id]
    assert not missing, missing
    order = sorted(slice_ids, key=lambda i: (by_id[i].get("seasons", [0])[0], i))
    slice_ = [entry(by_id[i]) for i in order]
    for name, items, about in [
        ("hs_template_all.json", everything, "Every high school story graph scenario."),
        ("hs_template_freshman.json", slice_,
         "Freshman starter slice: the freshman scenarios that start story chains (HS_002, 003, 005, 101, "
         "103, 104, 106, 107), the first scenario each chain leads to (HS_030, 034, 126, 134, 139, 145, "
         "157), and freshman scenarios that introduce the cast (coach, Dad, little brother, teacher, "
         "someone special...). Write and test these first."),
    ]:
        doc = {"_about": about, "_how": GUIDE_POINTER, "scenarios": items}
        with open(os.path.join(OUT_DIR, name), "w", encoding="utf-8") as f:
            f.write(json.dumps(doc, indent="\t", ensure_ascii=False) + "\n")
        print(f"wrote tools/authoring/{name}: {len(items)} scenarios")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""College story graph: design file -> draft scenarios in the game data.

    python3 tools/college_graph/make_college_graph.py           # writes data/career/scenarios_college.json
    python3 tools/college_graph/make_college_graph.py --check   # exit 1 if the output would change

Source: tools/college_graph/college_design.json (the reviewed skeleton: ids, titles,
windows, premises, requirements, flags, cast, chains, callbacks). Every entry becomes a
COL_* scenario in data/career/scenarios_college.json, next to the hand-written college
scenarios (col_*), which are left alone. The game already loads that file
(CareerContent.SCENARIO_FILES), so no code change is needed.

New entries are drafts ("draft": true, no text, no choices): the engine never picks a
draft and CareerContent.validate() only checks their graph data. Re-running keeps what
was written (category, text, choices, weight, cooldown, draft) and regenerates only the
graph fields, so change the design file, not the graph fields in the output.

Graph fields per entry:
  stages ["college"], seasons, weeks, when, story, beat, once: true
  requires        {"any_flags": [...]} and/or {"flags": [...]} from the design
  expected_flags  the design's "sets": every one must be set by some choice
  authoring       writer notes the game ignores: chain, premise, people, hs_callbacks
                  (high school flags for locked choices), college_locks, choice_locks
                  (both together), clears_strikes, note, unlocked_by, leads_to
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DESIGN = os.path.join(ROOT, "tools", "college_graph", "college_design.json")
OUT = os.path.join(ROOT, "data", "career", "scenarios_college.json")
PREFIX = "COL_"
KEEP = ["category", "text", "choices", "weight", "cooldown"]


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def _validator():
    import importlib.util
    spec = importlib.util.spec_from_file_location("vsg", os.path.join(ROOT, "tools", "validate_scenario_graph.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _span_entry(e):
    """The fields validate_scenario_graph.time_span reads, from a design row."""
    d = {"stages": ["college"], "seasons": e["seasons"]}
    for k in ("weeks", "when", "beat"):
        if e.get(k):
            d[k] = e[k]
    return d


def build(design, existing_doc):
    strikes = set(design.get("strike_flags", []))
    rows = design["scenarios"]
    vsg = _validator()
    # A long any_flags list (the wrong-path steps read every strike) keeps only the flags
    # that some scenario can set before the reader's window ends; the game's validate()
    # reports a flag that can only be set later as an error.
    for e in rows:
        req = e.get("requires") or {}
        if len(req.get("any_flags", [])) > 6:
            me = _span_entry(e)
            ok = []
            for f in req["any_flags"]:
                src = [x for x in rows if f in x.get("sets", []) and x["id"] != e["id"]]
                if any(vsg.can_precede(_span_entry(x), me) for x in src):
                    ok.append(f)
            e["requires"] = dict(req, any_flags=ok)
    setters = {}
    for e in rows:
        for f in e.get("sets", []):
            setters.setdefault(f, []).append(e["id"])
    readers = {}
    for e in rows:
        req = e.get("requires") or {}
        for f in req.get("flags", []) + req.get("any_flags", []):
            readers.setdefault(f, []).append(e["id"])
    old = {s["id"]: s for s in existing_doc.get("scenarios", []) if str(s.get("id", "")).startswith(PREFIX)}
    out = []
    for e in rows:
        sid = e["id"]
        d = {"id": sid, "title": e["title"], "draft": True, "category": "", "text": "",
             "stages": ["college"], "seasons": e["seasons"]}
        if e.get("weeks") and not e.get("beat"):
            d["weeks"] = e["weeks"]
        if e.get("when"):
            d["when"] = e["when"]
        if e.get("story"):
            d["story"] = True
        if e.get("beat"):
            d["beat"] = e["beat"]
        d["once"] = True
        req = {k: v for k, v in (e.get("requires") or {}).items() if k in ("flags", "any_flags") and v}
        if req:
            d["requires"] = req
        d["expected_flags"] = list(dict.fromkeys(e.get("sets", [])))
        locks = list(e.get("hs_callbacks", [])) + list(e.get("college_locks", []))
        a = {"chain": e.get("chain", ""), "premise": e.get("premise", ""), "people": e.get("people", [])}
        if e.get("hs_callbacks"):
            a["hs_callbacks"] = e["hs_callbacks"]
        if e.get("college_locks"):
            a["college_locks"] = e["college_locks"]
        if locks:
            a["choice_locks"] = locks
        if e.get("clears"):
            a["clears_strikes"] = True
        if e.get("note"):
            a["note"] = e["note"]
        flags_in = [f for f in req.get("flags", []) + req.get("any_flags", [])]
        if flags_in:
            src = []
            for f in flags_in:
                for s in setters.get(f, []):
                    src.append({"from": s, "flag": f})
            a["unlocked_by"] = src if len(src) <= 12 else [{"from": "any wrong-path strike", "flag": "(strike flags)"}]
        lead = []
        for f in d["expected_flags"]:
            for r in readers.get(f, []):
                if f in strikes and len(readers.get(f, [])) > 0 and r not in ("COL_036",):
                    continue  # strikes lead to every wrong-path step; listed once, on The Coach's Office
                lead.append({"to": r, "flag": f})
        if lead:
            a["leads_to"] = lead
        d["authoring"] = a
        d["choices"] = []
        if sid in old:
            prev = old[sid]
            for k in KEEP:
                if k in prev:
                    d[k] = prev[k]
            if not prev.get("draft"):
                d.pop("draft", None)
        out.append(d)
    others = [s for s in existing_doc.get("scenarios", []) if not str(s.get("id", "")).startswith(PREFIX)]
    doc = dict(existing_doc)
    doc["scenarios"] = others + out
    return doc


def main(argv):
    design = load(DESIGN)
    existing = load(OUT)
    doc = build(design, existing)
    text = json.dumps(doc, indent="\t", ensure_ascii=False) + "\n"
    with open(OUT, encoding="utf-8") as f:
        current = f.read()
    if "--check" in argv:
        print("up to date" if text == current else "out of date: run tools/college_graph/make_college_graph.py")
        return 0 if text == current else 1
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(text)
    n = sum(1 for s in doc["scenarios"] if str(s["id"]).startswith(PREFIX))
    drafts = sum(1 for s in doc["scenarios"] if str(s["id"]).startswith(PREFIX) and s.get("draft"))
    print(f"wrote {os.path.relpath(OUT, ROOT)}: {n} college story scenarios ({drafts} drafts)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

#!/usr/bin/env python3
"""Pro story graph: design file -> draft scenarios in the game data.

    python3 tools/pro_graph/make_pro_graph.py                     # writes data/career/scenarios_pro.json
    python3 tools/pro_graph/make_pro_graph.py --out DIR/file.json # writes a copy elsewhere (dry runs)
    python3 tools/pro_graph/make_pro_graph.py --check             # exit 1 if the output would change

Source: tools/pro_graph/pro_design.json. Every row becomes a PRO_* scenario next to the
hand-written pro scenarios (pro_*), which are left alone. Like the college generator, re-running
keeps written content (category, text, choices, weight, cooldown) and regenerates the graph fields.

Design -> scenario:
  ages [min, max]        requires.min.age / requires.max.age (max 50 means no upper limit)
  seasons_with_club      seasons (the count restarts at every new club)
  kind once / variant    "once": true;  kind repeat: not once, "cooldown": 15;
                         kind per_club: "once_per_club": true (once at each club)
  requires               copied; "(every pro strike)" expands to pro_strike_flags; "strike" is a
                         writer note ("a new pro strike") and goes to authoring
  waits_on, callbacks, note, chain, premise, people  -> authoring (the game ignores it)
Story events need a season window the engine can reach; pro rows without one get no "story".
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DESIGN = os.path.join(ROOT, "tools", "pro_graph", "pro_design.json")
OUT = os.path.join(ROOT, "data", "career", "scenarios_pro.json")
PREFIX = "PRO_"
KEEP = ["category", "text", "choices", "weight", "cooldown"]
REPEAT_COOLDOWN = 15


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def build(design, existing_doc):
    strikes = list(design.get("pro_strike_flags", []))
    old = {s["id"]: s for s in existing_doc.get("scenarios", []) if str(s.get("id", "")).startswith(PREFIX)}
    out = []
    for e in design["scenarios"]:
        sid = e["id"]
        d = {"id": sid, "title": e["title"], "draft": True, "category": "", "text": "", "stages": ["pro"]}
        if e.get("era") == "E":
            # Retirement epilogue (R10): closing scenes after the last snap, once each, by order then id.
            d["stages"] = ["retired"]
            d["when"] = ["epilogue"]
            if e.get("order") is not None:
                d["order"] = e["order"]
        if e.get("seasons_with_club"):
            d["seasons"] = e["seasons_with_club"]
        if e.get("weeks"):
            d["weeks"] = e["weeks"]
        if e.get("when"):
            d["when"] = e["when"]
        if e.get("story") and e.get("seasons_with_club") and (e.get("weeks") or e.get("when") == ["offseason"]):
            d["story"] = True
        if e.get("kind") == "repeat":
            d["cooldown"] = REPEAT_COOLDOWN
        elif e.get("kind") == "per_club":
            d["once_per_club"] = True  # plays once at each club (engine: once_per_club)
        else:
            d["once"] = True
        src = dict(e.get("requires") or {})
        req = {}
        for k in ("flags", "any_flags", "not_flags"):
            fl = []
            for f in src.get(k, []):
                fl += strikes if f == "(every pro strike)" else [f]
            if fl:
                req[k] = fl
        for k in ("followers_tier", "max_followers_tier"):
            if src.get(k):
                req[k] = src[k]
        mn, mx = dict(src.get("min") or {}), dict(src.get("max") or {})
        if e.get("ages"):
            a = e["ages"]
            mn["age"] = a[0]
            if a[1] < 50:
                mx["age"] = a[1]
        if mn:
            req["min"] = mn
        if mx:
            req["max"] = mx
        if req:
            d["requires"] = req
        d["expected_flags"] = list(dict.fromkeys(e.get("sets", [])))
        a = {"chain": e.get("chain", ""), "group": e.get("group", ""), "premise": e.get("premise", ""),
             "people": e.get("people", []), "kind": e.get("kind", "once")}
        for k in ("waits_on", "callbacks"):
            if e.get(k):
                a[k] = e[k]
        if src.get("strike"):
            a["needs"] = src["strike"]
        if e.get("note"):
            a["note"] = e["note"]
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
    out = OUT
    if "--out" in argv:
        out = argv[argv.index("--out") + 1]
    existing = load(out if os.path.exists(out) else OUT)
    doc = build(load(DESIGN), existing)
    text = json.dumps(doc, indent="\t", ensure_ascii=False) + "\n"
    if "--check" in argv:
        with open(out, encoding="utf-8") as f:
            same = f.read() == text
        print("up to date" if same else "out of date: run tools/pro_graph/make_pro_graph.py")
        return 0 if same else 1
    with open(out, "w", encoding="utf-8") as f:
        f.write(text)
    n = sum(1 for s in doc["scenarios"] if str(s["id"]).startswith(PREFIX))
    drafts = sum(1 for s in doc["scenarios"] if str(s["id"]).startswith(PREFIX) and s.get("draft"))
    print(f"wrote {out}: {n} pro story scenarios ({drafts} drafts)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

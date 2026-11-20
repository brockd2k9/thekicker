#!/usr/bin/env python3
"""Writes tools/pro_graph/PRO_DESIGN.md (the readable ID table) from pro_design.json."""
import json
import os
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
d = json.load(open(os.path.join(HERE, "pro_design.json"), encoding="utf-8"))
S = d["scenarios"]


def win(x):
    p = []
    if x.get("ages"):
        a = x["ages"]
        p.append(f"age {a[0]}" if a[0] == a[1] else (f"age {a[0]}+" if a[1] >= 50 else f"age {a[0]}-{a[1]}"))
    if x.get("seasons_with_club"):
        s = x["seasons_with_club"]
        p.append(f"club season {s[0]}" if s[0] == s[1] else (f"club season {s[0]}+" if s[1] >= 99 else f"club seasons {s[0]}-{s[1]}"))
    if x.get("when") == ["offseason"]:
        p.append("offseason")
    if x.get("weeks"):
        p.append(f"weeks {x['weeks'][0]}-{x['weeks'][1]}")
    if x.get("story"):
        p.append("story")
    return ", ".join(p) or "any"


def req(x):
    r = x.get("requires") or {}
    o = []
    if r.get("flags"):
        o.append(" + ".join(r["flags"]))
    if r.get("any_flags"):
        o.append(" / ".join(r["any_flags"]))
    if r.get("not_flags"):
        o.append("not " + " / ".join(r["not_flags"]))
    if r.get("followers_tier"):
        o.append("tier " + r["followers_tier"])
    o += [f"{k} {v}+" for k, v in (r.get("min") or {}).items()]
    o += [f"{k} under {v}" for k, v in (r.get("max") or {}).items()]
    if r.get("strike"):
        o.append(r["strike"])
    return "; ".join(o)


free = [x for x in S if not x["waits_on"]]
r3 = [x for x in S if x["waits_on"] and all(w.startswith("R3") for w in x["waits_on"])]
blocked = [x for x in S if any(not w.startswith("R3") for w in x["waits_on"])]
L = ["# PRO story graph design (skeleton)", "",
     "Skeleton for review: only the six tone-check scenes are written (`tools/authoring/work/pro_tone_check.json`, not imported); nothing is generated into the game data. Source: `pro_design.json` (regenerate this file with `make_pro_design_md.py`). Scoping and engine facts: `PRO_SCOPING.md`.", "",
     "**Timing.** The game has no pro season count, so scenes gate on **age** and on **seasons with the current club** (the count restarts at every new club). Kinds:",
     "- **once**: one time per career.",
     "- **variant**: one of an age-banded set (rookie, prime, veteran).",
     "- **repeat**: re-fires on its trigger, with a 15-week cooldown.", "",
     "**Waits on** the consolidated gameplay request:"]
L += [f"- {k}: {v}" for k, v in d["requests"].items() if k != "R2"]
L += ["", "R2 changes numbers only; no scene waits on it. Money scenes (R3) are written now with flags and stress costs and get `money` values later.", "",
      "**Pro strike flags** (the team-discipline steps PRO_124-128 read and clear only these): " + ", ".join(f"`{f}`" for f in d["pro_strike_flags"]) + ".",
      "**Relationship strike flags** (the cheating storyline PRO_155-163; never read by team discipline): " + ", ".join(f"`{f}`" for f in d["relationship_strike_flags"]) + ".",
      "College flags set severity through locked choices.", "",
      f"**Totals:** {len(S)} scenes. **{len(free) + len(r3)} can be written now**: {len(free)} need nothing new, and {len(r3)} are money scenes written with flags and stress costs. **{len(blocked)} are blocked** until " + ", ".join(sorted({w.split()[0] for x in blocked for w in x["waits_on"] if not w.startswith("R3")})) + " lands. Kinds: " + ", ".join(f"{v} {k}" for k, v in Counter(x["kind"] for x in S).items()) + ".", "",
      "| Waits on | Scenes |", "|---|---|"]
wc = defaultdict(list)
for x in S:
    for q in x["waits_on"]:
        wc[q.split()[0]].append(x["id"][4:])
for k in sorted(wc):
    L.append(f"| {k} | {len(wc[k])}: {', '.join(wc[k])} |")
ERA_ORDER = ["Era 1: Rookie (22-25)", "Era 2: Settled In (26-29)", "Era 3: Veteran (30-33)", "Era 4: Aging Veteran (34-37)",
             "Era 5: Grizzled Veteran (38-41)", "Era 6: Hall of Fame Era (42+)", "Across eras (state-driven)", "Epilogue (after retirement)"]
L += ["", "| Era | Scenes | Written | Waits on R1 | R3 (money values) | R8 | R9 | R10 | Blocked (cannot be written yet) |", "|---|---|---|---|---|---|---|---|---|"]
WRITTEN = set()
for wf in ("pro_batch1", "pro_batch2", "pro_batch3", "pro_tone_check", "pro_tone_check2", "pro_tone_check3"):
    try:
        WRITTEN |= {s["id"] for s in json.load(open(os.path.join(HERE, "..", "authoring", "work", wf + ".json")))["scenarios"]}
    except OSError:
        pass
for g in ERA_ORDER:
    rows = [x for x in S if x["group"] == g]
    if not rows:
        continue
    cnt = lambda r: sum(1 for x in rows if any(w.split()[0] == r for w in x["waits_on"]))
    blk = sum(1 for x in rows if any(not w.startswith("R3") and not w.startswith("R1 no age cap (ages 39-41") for w in x["waits_on"]))
    L.append(f"| {g} | {len(rows)} | {sum(1 for x in rows if x['id'] in WRITTEN)} | {cnt('R1')} | {cnt('R3')} | {cnt('R8')} | {cnt('R9')} | {cnt('R10')} | {blk} |")
L += ["", "Era 5 counts the age-38 scenes as playable now (the cap retires a player after the age-38 season); its ages 39-41 wait on R1. Eras 5 and 6 and the epilogue are proposals until the user confirms them.", "", "**Chains:**"]
chains = defaultdict(list)
for x in S:
    chains[x["chain"]].append(x["id"])
L += [f"- {k}: " + " → ".join(v) for k, v in chains.items() if len(v) > 1]
L.append("")
for g in [g for g in ERA_ORDER if any(x["group"] == g for x in S)] + [g for g in dict.fromkeys(x["group"] for x in S) if g not in ERA_ORDER]:
    rows = [x for x in S if x["group"] == g]
    L += [f"## {g} ({len(rows)})", "", "| ID | Title | Window | Kind | Opens on | Sets | Callbacks (locked choices) | Waits on |", "|---|---|---|---|---|---|---|---|"]
    for x in rows:
        L.append(f"| {x['id']} | {x['title']} | {win(x)} | {x['kind']} | {req(x)} | {', '.join(x['sets'])} | {', '.join(x['callbacks'])} | {'; '.join(x['waits_on'])} |")
    L.append("")
    for x in rows:
        L.append(f"- **{x['id']} {x['title']}**: {x['premise']}" + (f" *({x['note']})*" if x.get("note") else ""))
    L.append("")
open(os.path.join(HERE, "PRO_DESIGN.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
print(f"wrote PRO_DESIGN.md: {len(S)} scenes")

#!/usr/bin/env python3
"""Scenario graph validator (no Godot needed).

    python3 tools/validate_scenario_graph.py
        Checks data/career/scenarios_*.json with the same graph rules as
        CareerContent.validate() (flags required but never set, self-required
        flags, flags only set after the reader's window, expected flags a
        finished scenario doesn't set, story window fields) and prints warnings
        that aren't errors: same-season reads whose windows overlap, flags
        nothing reads, near-duplicate titles, scenarios per high school and college season.
        Exit code 1 if there are errors.

    python3 tools/validate_scenario_graph.py --skeleton <high_school_scenarios.json> [scenarios_*.json ...]
        The Step 1 audit of the upstream skeleton format (id/year/flags + edges).

Skeleton audit checks:
  1. schema       - ids, years, priorities, declared count
  2. flags        - flags read (requires / excludes / edge 'when') but never set,
                    flags set but never read (dead ends)
  3. edges        - endpoints exist, source actually sets the 'when' flag,
                    target's requirements enforce the edge, year order
  4. cycles       - scenarios that require a flag only they (or their cycle) set
  5. reachability - fixpoint over years: which scenarios can never become eligible
  6. titles       - exact / near-duplicate titles (also against existing content)
  7. year 0       - unrestricted "shared" scenarios that read like endings
  8. capacity     - scenarios per year vs. slots per HS year
"""
import json
import os
import re
import sys
from collections import defaultdict
from difflib import SequenceMatcher

PRIORITIES = {"normal", "story"}
# Titles that read like late-career / ending beats. Used only to flag year-0 risk.
ENDING_WORDS = re.compile(
    r"\b(final|last|goodbye|graduation|next chapter|college decision|senior|"
    r"scholarship decision|college visit|recruit|offer)\b", re.I)

# Slots per HS year in our engine (CareerTuning defaults): 10 games x (1 + 0.4)
# + 1 bye x 2 + offseason 2.
SLOTS_PER_YEAR = 10 * 1.4 + 2 + 2


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def norm_title(t):
    t = t.lower()
    t = re.sub(r"^the\s+", "", t)
    t = re.sub(r"[^a-z0-9 ]", "", t)
    return re.sub(r"\s+", " ", t).strip()


def req_flags(s):
    return list(s.get("requires_all_flags", [])) + list(s.get("requires_any_flags", []))


def audit_skeleton(argv):
    data = load(argv[0])
    existing = []
    for p in argv[1:]:
        for s in load(p).get("scenarios", []):
            existing.append((p.rsplit("/", 1)[-1], s.get("id"), s.get("title", "")))

    scen = data.get("scenarios", [])
    edges = data.get("dependencies", [])
    by_id = {}
    out = []
    counts = defaultdict(int)

    def section(title):
        out.append(f"\n## {title}\n")

    def item(kind, text):
        counts[kind] += 1
        out.append(f"- **{kind}** {text}")

    # --- 1. schema -------------------------------------------------------------
    section("1. Schema")
    for s in scen:
        sid = s.get("id")
        if not sid:
            item("ERROR", f"scenario without id: {s.get('title')}")
            continue
        if sid in by_id:
            item("ERROR", f"duplicate id {sid}")
        by_id[sid] = s
        if s.get("year") not in (0, 1, 2, 3, 4):
            item("ERROR", f"{sid}: year {s.get('year')!r} not in 0-4")
        if s.get("priority", "normal") not in PRIORITIES:
            item("ERROR", f"{sid}: unknown priority {s.get('priority')!r}")
        if not s.get("choices"):
            counts["no_choices"] += 1
    if data.get("scenario_count") != len(scen):
        item("ERROR", f"scenario_count says {data.get('scenario_count')}, file has {len(scen)}")
    out.append(f"- {len(scen)} scenarios, {len(edges)} dependency edges.")
    out.append(f"- {counts['no_choices']} of {len(scen)} scenarios have **no text and no choices** "
               "(nothing playable yet). Per-choice flags are unknown, so every `sets_flags` list "
               "below is treated as 'some choice may set this' (optimistic).")

    # --- flag tables -----------------------------------------------------------
    setters = defaultdict(set)   # flag -> scenarios that may set it
    readers = defaultdict(set)   # flag -> scenarios / edges that read it
    for sid, s in by_id.items():
        for f in s.get("sets_flags", []):
            setters[f].add(sid)
        for f in req_flags(s):
            readers[f].add(sid)
        for f in s.get("excludes_any_flags", []):
            readers[f].add(sid)
    for e in edges:
        readers[e.get("when", "")].add(f"edge {e.get('from')}->{e.get('to')}")

    # --- 2. flags --------------------------------------------------------------
    section("2. Flags read but never set")
    for f in sorted(readers):
        if f and f not in setters:
            item("NEVER-SET", f"`{f}` read by {', '.join(sorted(readers[f]))}")
    section("2b. Flags set but never read (dead ends; fine for flavor, but nothing reacts)")
    dead = sorted(f for f in setters if f not in readers)
    out.append(f"- {len(dead)} of {len(setters)} set flags are never read: "
               + ", ".join(f"`{f}`" for f in dead))

    # --- 3. edges --------------------------------------------------------------
    section("3. Dependency edges")
    for e in edges:
        a, b, f, t = e.get("from"), e.get("to"), e.get("when", ""), e.get("type")
        tag = f"{a} -[{t}:{f}]-> {b}"
        if a not in by_id or b not in by_id:
            item("ERROR", f"{tag}: endpoint missing")
            continue
        src, dst = by_id[a], by_id[b]
        if f not in src.get("sets_flags", []):
            others = sorted(setters.get(f, []))
            where = f"(set by {', '.join(others)})" if others else "(set by nothing)"
            item("SOURCE-DOESNT-SET", f"{tag}: {a} doesn't list `{f}` in sets_flags {where}")
        if t == "unlock":
            if f not in req_flags(dst):
                why = "has no requirements, so it fires anyway" if not req_flags(dst) else \
                    f"requires {req_flags(dst)} - `{f}` isn't one of them"
                item("UNENFORCED", f"{tag}: {b} {why}")
        elif t == "exclude":
            if f not in dst.get("excludes_any_flags", []):
                item("INFO", f"{tag}: also listed only as an edge (the uploaded manager does check "
                     "exclude edges, but our import should copy it into the target)")
        ya, yb = src.get("year", 0), dst.get("year", 0)
        if ya and yb and yb < ya:
            item("YEAR-ORDER", f"{tag}: target is year {yb}, source year {ya} - can never unlock")
        elif ya and yb and ya == yb:
            item("SAME-YEAR", f"{tag}: both year {ya} - only works if {a} happens to come first")

    # --- 4. cycles / self-reference ---------------------------------------------
    section("4. Circular or self-referencing requirements")
    for sid, s in sorted(by_id.items()):
        own = set(s.get("sets_flags", []))
        for f in req_flags(s):
            src = setters.get(f, set())
            if sid in src and src == {sid}:
                alt = [g for g in req_flags(s) if g != f]
                item("SELF-REF", f"{sid} requires `{f}`, which only {sid} itself sets"
                     + (f" (dead alternative; other options: {alt})" if alt else " - UNREACHABLE"))
            elif sid in src:
                item("SELF-REF", f"{sid} requires `{f}`, which it also sets (other setters: "
                     f"{sorted(src - {sid})})")
    # scenario graph A -> B when B reads a flag A sets; report SCCs > 1
    g = defaultdict(set)
    for sid, s in by_id.items():
        for f in req_flags(s):
            for a in setters.get(f, ()):
                if a != sid:
                    g[a].add(sid)
    idx, low, stack, on, sccs, n = {}, {}, [], set(), [], [0]

    def strong(v):
        idx[v] = low[v] = n[0]; n[0] += 1; stack.append(v); on.add(v)
        for w in g[v]:
            if w not in idx:
                strong(w); low[v] = min(low[v], low[w])
            elif w in on:
                low[v] = min(low[v], idx[w])
        if low[v] == idx[v]:
            comp = []
            while True:
                w = stack.pop(); on.discard(w); comp.append(w)
                if w == v:
                    break
            if len(comp) > 1:
                sccs.append(sorted(comp))
    for v in list(by_id):
        if v not in idx:
            strong(v)
    for c in sccs:
        item("CYCLE", " -> ".join(c))
    if not sccs:
        out.append("- No multi-scenario cycles.")

    # --- 5. reachability --------------------------------------------------------
    section("5. Reachability (optimistic: any listed flag of a played scenario can be set)")
    # Walk years 1..4; year-0 scenarios may fire in any year.
    have, played, first_year = set(), set(), {}
    for year in (1, 2, 3, 4):
        changed = True
        while changed:
            changed = False
            for sid, s in by_id.items():
                if sid in played or s.get("year", 0) not in (0, year):
                    continue
                if any(f not in have for f in s.get("requires_all_flags", [])):
                    continue
                anyf = s.get("requires_any_flags", [])
                if anyf and not any(f in have for f in anyf):
                    continue
                played.add(sid)
                first_year[sid] = year
                have.update(s.get("sets_flags", []))
                changed = True
    for sid, s in sorted(by_id.items()):
        if sid not in played:
            missing = [f for f in req_flags(s) if f not in have]
            item("UNREACHABLE", f"{sid} '{s['title']}' (year {s.get('year')}) - needs {missing}")
    if len(played) == len(by_id):
        out.append("- Every scenario is reachable in at least one playthrough.")
    late_alts = []
    for sid, s in sorted(by_id.items()):
        y = s.get("year", 0)
        for f in s.get("requires_any_flags", []):
            ys = [by_id[a].get("year", 0) for a in setters.get(f, ())]
            if y and ys and all(v and v > y for v in ys):
                late_alts.append(f"{sid}(y{y}) <- `{f}` only set in year {min(ys)}")
    for t in late_alts:
        item("DEAD-ALT", t)

    # --- 6. titles --------------------------------------------------------------
    section("6. Duplicate / near-duplicate titles")
    items_t = [("upload", sid, s["title"]) for sid, s in by_id.items()] + existing
    seen = set()
    for i in range(len(items_t)):
        for j in range(i + 1, len(items_t)):
            fa, a, ta = items_t[i]
            fb, b, tb = items_t[j]
            if fa != "upload" and fb != "upload":
                continue
            na, nb = norm_title(ta), norm_title(tb)
            r = SequenceMatcher(None, na, nb).ratio()
            wa, wb = set(na.split()), set(nb.split())
            jac = len(wa & wb) / max(len(wa | wb), 1)
            if na == nb:
                kind = "DUP-TITLE"
            elif r >= 0.8 or (jac >= 0.6 and len(wa & wb) >= 2):
                kind = "NEAR-DUP"
            else:
                continue
            key = (a, b)
            if key in seen:
                continue
            seen.add(key)
            la = a if fa == "upload" else f"{a} [{fa}]"
            lb = b if fb == "upload" else f"{b} [{fb}]"
            item(kind, f"{la} '{ta}'  ~  {lb} '{tb}'  (similarity {r:.2f})")

    # --- 7. year 0 --------------------------------------------------------------
    section("7. Year-0 (\"shared\") scenarios with no requirements")
    for sid, s in sorted(by_id.items()):
        if s.get("year", 0) == 0 and not req_flags(s):
            risky = bool(ENDING_WORDS.search(s["title"]))
            item("EARLY-ENDING" if risky else "YEAR0-OPEN",
                 f"{sid} '{s['title']}' can fire from freshman week 1"
                 + (" - reads like a senior/ending beat" if risky else ""))

    # --- 8. capacity ------------------------------------------------------------
    section("8. Capacity per HS year")
    per_year = defaultdict(lambda: {"all": 0, "story": 0, "gated": 0})
    for s in by_id.values():
        y = s.get("year", 0)
        per_year[y]["all"] += 1
        per_year[y]["story"] += s.get("priority") == "story"
        per_year[y]["gated"] += bool(req_flags(s))
    out.append(f"- Our engine shows ~{SLOTS_PER_YEAR:.0f} scenario slots per HS season "
               f"(~{4 * SLOTS_PER_YEAR:.0f} over four years), shared with the existing "
               f"{sum(1 for e in existing if e[0] == 'scenarios_hs.json')} HS scenarios.")
    out.append("\n| year | scenarios | story | flag-gated |\n|---|---|---|---|")
    for y in sorted(per_year):
        p = per_year[y]
        out.append(f"| {y or '0 (any)'} | {p['all']} | {p['story']} | {p['gated']} |")

    # --- summary ----------------------------------------------------------------
    head = ["# Scenario graph validation", "", "| check | count |", "|---|---|"]
    for k in sorted(counts):
        if k != "no_choices":
            head.append(f"| {k} | {counts[k]} |")
    print("\n".join(head + out))
    return 1 if counts["ERROR"] else 0


# --- our data format ----------------------------------------------------------------

ENGINE_FLAGS = {"walk_on", "juco", "failed_tryouts", "fa_attempts", "recruiting_update",
                "traits_reported", "kicking_slump", "kick_slumps", "coach_lost_faith", "benched",
                "benched_for_tyler", "won_job_back", "lost_audition", "contract_year", "re_signed",
                "released", "signed_new_club", "pro_clubs", "was_dismissed", "reputation_week",
                "reputation_text", "dismissed"}
# A choice's "recast": [id] sets recast_<id> (how many times that role was recast).
ENGINE_FLAGS |= {"recast_" + p for p in ("coach", "holder", "backup", "teacher", "best_friend", "rival",
                                          "parent", "sibling", "love_interest")}
STAGE_ORDER = {"high_school": 0, "juco": 1, "college": 2, "pro": 3, "free_agent": 3}


def flags_set(sc):
    out = list(sc.get("expected_flags", [])) if sc.get("draft") else []
    for ch in sc.get("choices", []):
        for f, v in (ch.get("set_flags") or {}).items():
            if v and f not in out:
                out.append(f)
    return out


def flags_read(req):
    out = []
    for k in ("flags", "any_flags", "not_flags"):
        out += [str(f) for f in req.get(k, [])]
    for r in req.get("any_of", []):
        out += flags_read(r)
    return out


def time_span(sc):
    """Mirror of CareerContent._time_span: [stage, season, week] bounds."""
    ranks = [STAGE_ORDER.get(st, 0) for st in sc.get("stages", [])] or [0]
    se, wk = sc.get("seasons"), sc.get("weeks")
    when = sc.get("when", ["season", "bye"])
    s0, s1 = (se[0], se[1]) if isinstance(se, list) and len(se) == 2 else (0, 99)
    w0, w1 = (wk[0], wk[1]) if isinstance(wk, list) and len(wk) == 2 else (1, 98)
    if when == ["offseason"]:
        w0 = 99
    if "offseason" in when:
        w1 = 99
    beat = sc.get("beat")
    if isinstance(beat, dict):
        s0 = s1 = int(beat.get("season_in_stage", 1))
        w0 = 99 if when == ["offseason"] else int(beat.get("week", 1))
    if sc.get("follow_up_only"):
        return [min(ranks), 0, 0], [99, 99, 99]
    return [min(ranks), s0, w0], [max(ranks), s1, w1]


def can_precede(a, b):
    return time_span(a)[0] < time_span(b)[1]


def _strike_flags():
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "college_graph", "college_design.json")
    try:
        return set(load(path).get("strike_flags", []))
    except (OSError, ValueError):
        return set()


STRIKES = _strike_flags()


def forced_cap():
    """CareerTuning.max_forced_per_week."""
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                        "scripts", "career", "career_tuning.gd")
    try:
        m = re.search(r"var max_forced_per_week\s*:\s*int\s*=\s*(\d+)", open(path, encoding="utf-8").read())
        return int(m.group(1)) if m else 2
    except OSError:
        return 2


def stage_seasons():
    """Seasons per stage, from CareerTuning (high_school_seasons, juco_seasons, college_seasons)."""
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                        "scripts", "career", "career_tuning.gd")
    out = {"high_school": 4, "juco": 1, "college": 4}
    try:
        src = open(path, encoding="utf-8").read()
    except OSError:
        return out
    for st in list(out):
        m = re.search(r"var %s_seasons\s*:\s*int\s*=\s*(\d+)" % st, src)
        if m:
            out[st] = int(m.group(1))
    return out


def audit_data(data_dir):
    files = sorted(f for f in os.listdir(data_dir) if f.startswith("scenarios_") and f.endswith(".json"))
    scen = []
    for f in files:
        for s in load(os.path.join(data_dir, f)).get("scenarios", []):
            s["_file"] = f
            scen.append(s)
    errors, warns = [], []
    setters = defaultdict(list)
    for sc in scen:
        for f in flags_set(sc):
            setters[f].append(sc)
    readers = defaultdict(set)
    last_season = stage_seasons()
    for sc in scen:
        sid = sc["id"]
        # A stage's last season has no offseason: it ends in recruiting (high school) or
        # the draft (college), and the next stage starts with its own offseason.
        se = sc.get("seasons")
        if sc.get("when") == ["offseason"] and isinstance(se, list) and len(se) == 2:
            for st in sc.get("stages", []):
                if st in last_season and int(se[0]) >= last_season[st]:
                    errors.append(f"{sid}: offseason in {st} season {se[0]} never happens "
                                  f"(the stage ends after season {last_season[st]}); use weeks instead")
        for ch in sc.get("choices", []):
            off = {f for f, v in (ch.get("set_flags") or {}).items() if v is False and f in STRIKES}
            if len(off) > 1 and off != STRIKES:
                warns.append(f"{sid}: choice '{ch.get('label', '')}' clears {len(off)} of {len(STRIKES)} strike flags "
                             f"(missing {', '.join(sorted(STRIKES - off))})")
            creq = ch.get("requires", {}) or {}
            for f in creq.get("flags", []) + creq.get("any_flags", []):
                src = setters.get(f, [])
                if src and f not in ENGINE_FLAGS and not any(can_precede(x, sc) for x in src if x["id"] != sid):
                    warns.append(f"{sid}: locked choice needs '{f}', only set after this scenario's window")
        req = sc.get("requires", {})
        reads = flags_read(req)
        for ch in sc.get("choices", []):
            reads += flags_read(ch.get("requires", {}))
        if sc.get("draft"):
            reads += sc.get("authoring", {}).get("choice_locks", [])  # future choice requirements
        for f in reads:
            readers[f].add(sid)
            if f not in setters and f not in ENGINE_FLAGS:
                errors.append(f"{sid}: flag '{f}' is required but nothing sets it")
        for f in req.get("flags", []) + req.get("any_flags", []):
            src = setters.get(f, [])
            if src and all(x["id"] == sid for x in src):
                errors.append(f"{sid}: requires flag '{f}' that only it sets")
            elif src and f not in ENGINE_FLAGS and not any(can_precede(x, sc) for x in src):
                errors.append(f"{sid}: flag '{f}' is only set after this scenario's window")
            elif src and f not in ENGINE_FLAGS:
                # Same season, overlapping windows: works only if the order cooperates.
                t0, t1 = time_span(sc)
                ok_early = [x for x in src if time_span(x)[1] < t0]
                if not ok_early and len(src) == 1 and time_span(src[0])[0][:2] == t0[:2] == t1[:2]:
                    warns.append(f"{sid}: '{f}' comes from {src[0]['id']} in the same season "
                                 "with overlapping weeks (order not guaranteed)")
        if not sc.get("draft"):
            have = flags_set(sc)
            for f in sc.get("expected_flags", []):
                if f not in have:
                    errors.append(f"{sid}: no choice sets expected flag '{f}'")
        if sc.get("story"):
            if "beat" in sc:
                errors.append(f"{sid}: story and beat can't both be set")
            if not (isinstance(sc.get("seasons"), list) and len(sc["seasons"]) == 2):
                errors.append(f"{sid}: story needs seasons")
            if sc.get("when") != ["offseason"] and not (isinstance(sc.get("weeks"), list) and len(sc["weeks"]) == 2):
                errors.append(f"{sid}: story needs weeks (or when [offseason])")

    # Forced weeks: story events in the last week of their window and story beats. More than
    # max_forced_per_week in one stage / season / week and the extra story event is lost.
    cap = forced_cap()
    forced = defaultdict(list)
    for sc in scen:
        if sc.get("draft") or sc.get("follow_up_only"):
            continue
        for st in sc.get("stages", []):
            if isinstance(sc.get("beat"), dict):
                b = sc["beat"]
                key = (st, int(b.get("season_in_stage", 1)), "offseason" if sc.get("when") == ["offseason"] else int(b.get("week", 1)))
            elif sc.get("story") and isinstance(sc.get("seasons"), list):
                wk = "offseason" if sc.get("when") == ["offseason"] else (sc.get("weeks") or [0, 0])[1]
                key = (st, int(sc["seasons"][1]), wk)
            else:
                continue
            forced[key].append(sc["id"])
    for key, ids in sorted(forced.items(), key=str):
        if len(ids) > cap:
            warns.append(f"forced week {key[0]} season {key[1]} week {key[2]}: {len(ids)} story events / beats "
                         f"({', '.join(ids)}), more than max_forced_per_week {cap}")

    dead = sorted(f for f in setters if f not in readers)
    # Titles (live + drafts, all files).
    for i in range(len(scen)):
        for j in range(i + 1, len(scen)):
            a, b = scen[i], scen[j]
            na, nb = norm_title(a.get("title", "")), norm_title(b.get("title", ""))
            r = SequenceMatcher(None, na, nb).ratio()
            if na == nb or r >= 0.85:
                warns.append(f"title: {a['id']} '{a['title']}' ~ {b['id']} '{b['title']}' ({r:.2f})")
    per = defaultdict(lambda: [0, 0])
    for sc in scen:
        if "high_school" not in sc.get("stages", []):
            continue
        se = sc.get("seasons") or [1, 4]
        for y in range(int(se[0]), min(int(se[1]), 4) + 1):
            per[y][0 if sc.get("draft") else 1] += 1

    print("# Scenario graph check (data/career)\n")
    print(f"{len(scen)} scenarios in {len(files)} files, {sum(1 for s in scen if s.get('draft'))} drafts.\n")
    print(f"## Errors ({len(errors)})\n")
    print("\n".join(f"- {e}" for e in errors) or "- none")
    print(f"\n## Warnings ({len(warns)})\n")
    print("\n".join(f"- {w}" for w in warns) or "- none")
    print(f"\n## Flags nothing reads ({len(dead)}; fine as flavor)\n")
    print(", ".join(dead) or "none")
    print("\n## High school scenarios available per season (a scenario open to several seasons counts in each)\n")
    print("| season | finished | drafts |\n|---|---|---|")
    for y in sorted(per):
        print(f"| {y} | {per[y][1]} | {per[y][0]} |")
    col = defaultdict(lambda: [0, 0])
    for sc in scen:
        if "college" not in sc.get("stages", []) or sc.get("follow_up_only"):
            continue
        se = sc.get("seasons") or [1, 4]
        for y in range(int(se[0]), min(int(se[1]), 4) + 1):
            col[y][0 if sc.get("draft") else 1] += 1
    print("\n## College scenarios available per season (story graph and hand-written; "
          "a scenario open to several seasons counts in each)\n")
    print("| season | finished | drafts |\n|---|---|---|")
    for y in sorted(col):
        print(f"| {y} | {col[y][1]} | {col[y][0]} |")
    return 1 if errors else 0


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--skeleton":
        if len(sys.argv) < 3:
            print(__doc__)
            sys.exit(2)
        sys.exit(audit_skeleton(sys.argv[2:]))
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.exit(audit_data(os.path.join(root, "data", "career")))

#!/usr/bin/env python3
"""Imports filled-in scenario templates into the game's scenario data.

    python3 tools/import_scenarios.py FILE [FILE ...] --dry-run   check only, write nothing
    python3 tools/import_scenarios.py FILE [FILE ...]             check, then write

FILE is a template from tools/make_authoring_templates.py (or the same shape:
{"scenarios": [{id, title, category, text, choices, ...}]}). See
tools/authoring/WRITING_GUIDE.md for every field and rule.

What happens:
  * Entries with no text and no choice labels yet are skipped ("not written yet"),
    so you can import a template while it's only partly written.
  * Every written entry is checked (errors block the import, warnings don't):
    category, text, 2-4 choices, labels and results, stat names and ranges,
    game-day modifiers, flags (no typos: a flag must be expected here or used
    somewhere), people in rel and their range, requirements, lock_text,
    follow-ups, placeholders like {coach}, and the content rules.
  * The written entries are merged into the data file that holds that id
    (the story graph's drafts lose their "draft" mark and become playable), and
    the whole graph is checked again (flags required but never set, flags set
    too late...). New follow-up-only scenarios (ids not in the game yet) are
    added to scenarios_hs_graph.json.
  * Nothing is written if there is any error: fix and run again.
Exit code: 0 = imported (or dry run clean), 1 = errors.
Afterwards run the Godot tests (README, Tests) for the engine's own check.
"""
import argparse
import importlib.util
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import scenario_lint  # noqa: E402  (style lint: pronouns, names, quotes, game kicks, one-sided choices)

GROUP_KEYS = {
    "life": ["health", "energy", "fun", "social"],
    "football": ["power", "accuracy", "resilience", "toughness"],
    "personality": ["charisma", "ambition", "leadership", "intelligence"],
}
CATEGORIES = ["social", "school", "training", "health", "work", "media", "family", "money", "team",
              "romance", "community", "career"]
METRICS = ["recruiting", "draft", "retention", "gpa", "age"]
# Hard limits per choice (errors). Typical values are in the writing guide.
STAT_RANGE = {"life": (-20, 15), "football": (-2, 5), "personality": (-4, 6)}
PROGRESS_RANGE = {"recruiting": (-3, 8), "grades": (-0.2, 0.4), "draft": (-10, 6), "retention": (-6, 6)}
# Followers (scripts/career/followers.gd): "followers" is buzz (-20..20, scaled by stage),
# "followers_exact" a raw count, "conduct" good / bad / scandal (a scandal ends brand deals),
# "deal" a brand deal {id, name, kind, value, seasons}.
FOLLOWERS_RANGE = (-20, 20)
CONDUCTS = {"good", "bad", "scandal"}


def _gd_list(name, fallback):
    """A const string list from scripts/career/followers.gd, so the tool follows the game."""
    try:
        src = open(os.path.join(ROOT, "scripts", "career", "followers.gd"), encoding="utf-8").read()
        m = re.search(r"const " + name + r" := \[(.*?)\]", src, re.S)
        return re.findall(r'"([a-z_]+)"', m.group(1)) if m else fallback
    except OSError:
        return fallback


DEAL_KINDS = set(_gd_list("DEAL_KINDS", ["sp", "range", "fun"]))
FOLLOWER_TIERS = _gd_list("TIER_IDS", [])
# Wrong-path strike flags (tools/college_graph/college_design.json): a choice that sets one
# must carry conduct bad or scandal.
try:
    STRIKE_FLAGS = set(json.load(open(os.path.join(ROOT, "tools", "college_graph", "college_design.json"),
                                      encoding="utf-8")).get("strike_flags", []))
except (OSError, ValueError):
    STRIKE_FLAGS = set()
# Pro wrong-path strikes (tools/pro_graph/pro_design.json): same two rules (conduct, clear them all).
try:
    PRO_STRIKE_FLAGS = set(json.load(open(os.path.join(ROOT, "tools", "pro_graph", "pro_design.json"),
                                          encoding="utf-8")).get("pro_strike_flags", []))
except (OSError, ValueError):
    PRO_STRIKE_FLAGS = set()
# Optional: skill points a choice awards (negative = practice skipped). Typical
# +1 to +3, training choices +2 to +4 (WRITING_GUIDE.md).
SKILL_POINTS_RANGE = (-2, 6)
REL_RANGE = (-15, 15)
STATS_PER_CHOICE_WARN = 7
TEXT_WARN_CHARS = 320
WHEN_VALUES = {"season", "bye", "offseason"}
CHOICE_FIELDS = {"label", "result", "stats", "modifiers", "set_flags", "rel", "requires", "lock_text",
                 "follow_up", "recruiting", "grades", "draft", "retention", "skill_points",
                 "followers", "followers_exact", "conduct", "deal", "suspend_weeks"}
SCENARIO_FIELDS = {"id", "title", "_info", "category", "text", "choices", "weight", "cooldown", "when",
                   "follow_up_only", "stages", "seasons", "weeks", "once", "_note"}
# Fields a template may set on a scenario that already exists (graph fields stay
# with tools/convert_hs_graph.py).
WRITABLE = ["category", "text", "choices", "weight", "cooldown", "when"]


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def data_path(name, data_dir):
    return os.path.join(data_dir, name)


class Report:
    def __init__(self):
        self.lines = {}

    def add(self, sid, kind, msg):
        self.lines.setdefault(sid, []).append((kind, msg))

    def errors(self):
        return sum(1 for v in self.lines.values() for k, _ in v if k == "ERROR")

    def warnings(self):
        return sum(1 for v in self.lines.values() for k, _ in v if k == "warning")

    def lints(self):
        return sum(1 for v in self.lines.values() for k, _ in v if k == "lint")


def is_blank(e):
    return not str(e.get("text", "")).strip() and not any(
        str(c.get("label", "")).strip() for c in e.get("choices", []) if isinstance(c, dict))


def clean_choice(ch):
    """Drops empty template slots: empty stat groups, zero values, empty dicts."""
    out = {}
    for k in ["label", "result", "requires", "lock_text"]:
        if ch.get(k) not in (None, "", {}, []):
            out[k] = ch[k]
    stats = {}
    for g, d in (ch.get("stats") or {}).items():
        d = {k: v for k, v in (d or {}).items() if v not in (0, 0.0, None)}
        if d:
            stats[g] = d
    out["stats"] = stats
    out["modifiers"] = list(ch.get("modifiers") or [])
    for k in ["recruiting", "grades", "draft", "retention", "skill_points", "followers", "followers_exact",
              "suspend_weeks"]:
        if ch.get(k) not in (None, 0, 0.0):
            out[k] = ch[k]
    if ch.get("conduct") not in (None, ""):
        out["conduct"] = ch["conduct"]
    if ch.get("deal") not in (None, {}, ""):
        out["deal"] = ch["deal"]
    sf = {k: v for k, v in (ch.get("set_flags") or {}).items()}
    if sf:
        out["set_flags"] = sf
    rel = {k: v for k, v in (ch.get("rel") or {}).items() if v not in (0, 0.0, None)}
    if rel:
        out["rel"] = rel
    if ch.get("follow_up"):
        out["follow_up"] = ch["follow_up"]
    return out


def flags_read(req):
    out = []
    for k in ("flags", "any_flags", "not_flags"):
        out += list(req.get(k, []))
    for r in req.get("any_of", []):
        out += flags_read(r)
    return out


def check_requires(rep, sid, where, req, people, known_flags):
    if not isinstance(req, dict):
        rep.add(sid, "ERROR", f"{where}: requires must be an object")
        return
    for bound in ("min", "max"):
        for k, v in (req.get(bound) or {}).items():
            ok = any(k in ks for ks in GROUP_KEYS.values()) or k in METRICS or k == "followers" or \
                (k.startswith("rel_") and k[4:] in people)
            if not ok:
                rep.add(sid, "ERROR", f"{where}: unknown requirement '{k}' (stats, {', '.join(METRICS)}, "
                        f"or rel_<person>: {', '.join('rel_' + p for p in people)})")
            if not isinstance(v, (int, float)):
                rep.add(sid, "ERROR", f"{where}: requirement '{k}' needs a number")
    for f in flags_read(req):
        if f not in known_flags:
            rep.add(sid, "ERROR", f"{where}: requires flag '{f}' that nothing in the game sets (typo?)")
    for k in req:
        if k not in ("min", "max", "traits", "any_traits", "flags", "any_flags", "not_flags", "any_of",
                     "followers_tier", "max_followers_tier"):
            rep.add(sid, "ERROR", f"{where}: unknown requires field '{k}'")
    for k in ("followers_tier", "max_followers_tier"):
        if k in req and FOLLOWER_TIERS and req[k] not in FOLLOWER_TIERS:
            rep.add(sid, "ERROR", f"{where}: {k} '{req[k]}' must be one of: {', '.join(FOLLOWER_TIERS)}")


def check_text(rep, sid, where, text, blocked, placeholders):
    low = f" {text.lower()} "
    for w in blocked:
        if w in low:
            rep.add(sid, "ERROR", f"{where}: content rule - contains '{w}' (data/career/content_rules.json)")
    for ph in re.findall(r"\{([^}]*)\}", text):
        if ph not in placeholders:
            rep.add(sid, "ERROR", f"{where}: unknown placeholder {{{ph}}} (valid: "
                    f"{', '.join('{' + p + '}' for p in sorted(placeholders))})")


def dominates(a, b):
    """True if choice a is at least as good as b in every number (stats, skill points,
    recruiting, grades, rel) and better in one."""
    better, worse = scenario_lint.compare(a, b)
    return bool(better) and not worse


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--dry-run", action="store_true", help="check only; write nothing")
    ap.add_argument("--data-dir", default=os.path.join(ROOT, "data", "career"),
                    help="scenario data folder (default data/career)")
    args = ap.parse_args(argv)
    data_dir = args.data_dir

    files = sorted(f for f in os.listdir(data_dir) if f.startswith("scenarios_") and f.endswith(".json"))
    docs = {f: load(data_path(f, data_dir)) for f in files}
    where_is = {}
    for f, d in docs.items():
        for s in d.get("scenarios", []):
            where_is[s["id"]] = f
    modifiers = {m["id"] for m in load(data_path("modifiers.json", data_dir))["modifiers"]}
    people_doc = load(data_path("people.json", data_dir))
    people = [p["id"] for p in people_doc["people"]]
    blocked = load(data_path("content_rules.json", data_dir)).get("blocked_words", [])
    placeholders = set(people) | {"tyler"}

    # Every flag the game knows: set by a choice, expected by a draft, read by
    # a requirement, or set by the engine.
    # kicking_slump / kick_slumps: set by KickTrust when misses pile up.
    known_flags = {"walk_on", "juco", "failed_tryouts", "fa_attempts", "recruiting_update", "traits_reported",
                   "kicking_slump", "kick_slumps"}
    for d in docs.values():
        for s in d.get("scenarios", []):
            known_flags.update(s.get("expected_flags", []))
            known_flags.update(flags_read(s.get("requires", {})))
            for ch in s.get("choices", []):
                known_flags.update((ch.get("set_flags") or {}).keys())
                known_flags.update(flags_read(ch.get("requires", {})))

    entries = []
    for path in args.files:
        try:
            doc = load(path)
        except (OSError, json.JSONDecodeError) as e:
            print(f"ERROR {path}: can't read it as JSON ({e})")
            return 1
        items = doc.get("scenarios", doc if isinstance(doc, list) else [])
        entries += [(path, e) for e in items]

    rep = Report()
    written, skipped = [], []
    new_ids = {e.get("id") for _, e in entries if e.get("id") not in where_is}
    for e in [e for _, e in entries if e.get("id") in new_ids and e.get("follow_up_only")]:
        known_flags.update(fl for ch in e.get("choices", []) for fl in (ch.get("set_flags") or {}))
    follow_targets = set()
    for path, e in entries:
        sid = str(e.get("id", "?"))
        if is_blank(e):
            skipped.append(sid)
            continue
        written.append((sid, e))
        for ch in e.get("choices", []):
            fu = ch.get("follow_up") if isinstance(ch, dict) else None
            if fu:
                follow_targets.add(fu if isinstance(fu, str) else fu.get("id"))

    seen = set()
    for sid, e in written:
        if sid in seen:
            rep.add(sid, "ERROR", "this id appears twice in the import")
        seen.add(sid)
        existing = None
        if sid in where_is:
            existing = next(s for s in docs[where_is[sid]]["scenarios"] if s["id"] == sid)
            if e.get("title") and e["title"] != existing.get("title"):
                rep.add(sid, "warning", f"title differs from the game's ('{existing.get('title')}'); "
                        "the game's title is kept")
        elif not e.get("follow_up_only"):
            rep.add(sid, "ERROR", "unknown id: only existing scenarios, or new follow-up-only ones "
                    "(\"follow_up_only\": true), can be imported")
        elif sid not in follow_targets:
            rep.add(sid, "warning", "new follow-up-only scenario that no choice in this import "
                    "follows up into (it can't be reached)")
        for k in e:
            if k == "draft":
                rep.add(sid, "ERROR", "\"draft\" at scenario level marks an unwritten graph entry; leave it "
                        "out (importing removes it). Draft points go on a choice: \"draft\": -3")
            elif k not in SCENARIO_FIELDS:
                rep.add(sid, "ERROR", f"unknown field '{k}'")
        if existing is not None:
            for k in ("stages", "seasons", "weeks", "once", "follow_up_only"):
                if k in e and e[k] != existing.get(k):
                    rep.add(sid, "ERROR", f"'{k}' is graph data; change it in the graph generator "
                            "(tools/convert_hs_graph.py or tools/college_graph/make_college_graph.py)")
            if "when" in e and (existing.get("story") or existing.get("beat")):
                rep.add(sid, "ERROR", "'when' of a story event is set by its window (the graph generator)")
        if e.get("category") not in CATEGORIES:
            rep.add(sid, "ERROR", f"category '{e.get('category')}' must be one of: {', '.join(CATEGORIES)}")
        text = str(e.get("text", "")).strip()
        if not text:
            rep.add(sid, "ERROR", "text is empty")
        elif len(text) > TEXT_WARN_CHARS:
            rep.add(sid, "warning", f"text is {len(text)} characters; aim for 1-3 short sentences")
        check_text(rep, sid, "text", text, blocked, placeholders)
        check_text(rep, sid, "title", str(e.get("title", "")), blocked, placeholders)
        for w in e.get("when", []) or []:
            if w not in WHEN_VALUES:
                rep.add(sid, "ERROR", f"when '{w}' must be season, bye or offseason")
        choices = [c for c in e.get("choices", []) if isinstance(c, dict)]
        if not (2 <= len(choices) <= 4):
            rep.add(sid, "ERROR", f"needs 2-4 choices (has {len(choices)})")
        must = (existing or {}).get("expected_flags", [])
        set_by_choices = set()
        cleaned = []
        for i, raw in enumerate(choices, 1):
            w = f"choice {i}"
            for k in raw:
                if k not in CHOICE_FIELDS:
                    rep.add(sid, "ERROR", f"{w}: unknown field '{k}'")
            ch = clean_choice(raw)
            cleaned.append(ch)
            if not str(ch.get("label", "")).strip():
                rep.add(sid, "ERROR", f"{w}: label is empty")
            if not str(ch.get("result", "")).strip():
                rep.add(sid, "ERROR", f"{w}: result is empty")
            for k in ("label", "result", "lock_text"):
                check_text(rep, sid, f"{w} {k}", str(ch.get(k, "")), blocked, placeholders)
            n_stats = 0
            for g, d in ch["stats"].items():
                if g not in GROUP_KEYS:
                    rep.add(sid, "ERROR", f"{w}: unknown stat group '{g}' (life, football, personality)")
                    continue
                lo, hi = STAT_RANGE[g]
                for k, v in d.items():
                    if k not in GROUP_KEYS[g]:
                        rep.add(sid, "ERROR", f"{w}: '{k}' is not a {g} stat ({', '.join(GROUP_KEYS[g])})")
                    elif not isinstance(v, (int, float)):
                        rep.add(sid, "ERROR", f"{w}: {k} needs a number")
                    elif not lo <= v <= hi:
                        rep.add(sid, "ERROR", f"{w}: {k} {v:+} is outside the {g} range {lo:+} to {hi:+}")
                    n_stats += 1
            for k, (lo, hi) in PROGRESS_RANGE.items():
                if k in ch:
                    if not isinstance(ch[k], (int, float)) or not lo <= ch[k] <= hi:
                        rep.add(sid, "ERROR", f"{w}: {k} {ch[k]} is outside {lo} to {hi}")
                    n_stats += 1
            if "skill_points" in ch:
                sp = ch["skill_points"]
                lo, hi = SKILL_POINTS_RANGE
                if not isinstance(sp, int) or isinstance(sp, bool) or not lo <= sp <= hi:
                    rep.add(sid, "ERROR", f"{w}: skill_points {sp} must be a whole number from {lo} to {hi}")
                n_stats += 1
            if "followers" in ch:
                v = ch["followers"]
                if not isinstance(v, (int, float)) or isinstance(v, bool) or not FOLLOWERS_RANGE[0] <= v <= FOLLOWERS_RANGE[1]:
                    rep.add(sid, "ERROR", f"{w}: followers {v} must be a number from {FOLLOWERS_RANGE[0]} to "
                            f"{FOLLOWERS_RANGE[1]} (buzz, scaled by stage)")
                n_stats += 1
            if "followers_exact" in ch:
                if not isinstance(ch["followers_exact"], int) or isinstance(ch["followers_exact"], bool):
                    rep.add(sid, "ERROR", f"{w}: followers_exact must be a whole number (a raw follower count)")
                n_stats += 1
            if "suspend_weeks" in ch:
                v = ch["suspend_weeks"]
                if not isinstance(v, int) or isinstance(v, bool) or not 1 <= v <= 3:
                    rep.add(sid, "ERROR", f"{w}: suspend_weeks {v} must be a whole number 1-3 (games sat out)")
                elif ch.get("conduct") not in ("bad", "scandal"):
                    rep.add(sid, "warning", f"{w}: suspend_weeks without conduct bad or scandal")
            if "conduct" in ch and ch["conduct"] not in CONDUCTS:
                rep.add(sid, "ERROR", f"{w}: conduct '{ch['conduct']}' must be good, bad or scandal")
            if "deal" in ch:
                d = ch["deal"]
                if not isinstance(d, dict) or not d.get("id") or not d.get("name"):
                    rep.add(sid, "ERROR", f"{w}: deal needs an object with id and name")
                elif d.get("kind") not in DEAL_KINDS:
                    rep.add(sid, "ERROR", f"{w}: deal kind '{d.get('kind')}' must be one of: {', '.join(sorted(DEAL_KINDS))}")
                elif not isinstance(d.get("value"), (int, float)) or not isinstance(d.get("seasons", 1), int):
                    rep.add(sid, "ERROR", f"{w}: deal needs a number value and whole-number seasons")
            if isinstance(raw.get("draft"), bool):
                rep.add(sid, "ERROR", f"{w}: \"draft\": {str(raw['draft']).lower()} on a choice - on a choice, "
                        "\"draft\" is draft points (a number, e.g. -3); \"draft\": true only marks an "
                        "unwritten scenario in the graph files")
            strikes = [f for f, v in (ch.get("set_flags") or {}).items() if v is True and f in STRIKE_FLAGS | PRO_STRIKE_FLAGS]
            if strikes and ch.get("conduct") not in ("bad", "scandal"):
                rep.add(sid, "ERROR", f"{w}: sets wrong-path strike '{strikes[0]}' but has no conduct "
                        "bad or scandal")
            cleared = {f for f, v in (ch.get("set_flags") or {}).items() if v is False and f in STRIKE_FLAGS}
            if len(cleared) > 1 and cleared != STRIKE_FLAGS:
                missing = sorted(STRIKE_FLAGS - cleared)
                rep.add(sid, "ERROR", f"{w}: a wrong-path step must clear every strike flag; missing "
                        f"{', '.join(missing)} (strike_flags in tools/college_graph/college_design.json)")
            pro_off = {f for f, v in (ch.get("set_flags") or {}).items() if v is False and f in PRO_STRIKE_FLAGS}
            if len(pro_off) > 1 and pro_off != PRO_STRIKE_FLAGS:
                rep.add(sid, "ERROR", f"{w}: a pro discipline step must clear every pro strike flag; missing "
                        f"{', '.join(sorted(PRO_STRIKE_FLAGS - pro_off))} (pro_strike_flags in tools/pro_graph/pro_design.json)")
            if n_stats == 0:
                rep.add(sid, "ERROR", f"{w}: changes no stats (every choice needs at least one stat change)")
            elif n_stats > STATS_PER_CHOICE_WARN:
                rep.add(sid, "warning", f"{w}: {n_stats} stat changes; 2-5 reads better")
            mods = ch["modifiers"]
            if not mods:
                rep.add(sid, "ERROR", f"{w}: needs a game-day modifier")
            for m in mods:
                if m not in modifiers:
                    rep.add(sid, "ERROR", f"{w}: unknown modifier '{m}' ({', '.join(sorted(modifiers))})")
            if len(mods) > 2:
                rep.add(sid, "warning", f"{w}: {len(mods)} modifiers; one (two at most) reads better")
            for f, v in ch.get("set_flags", {}).items():
                if not isinstance(v, bool):
                    rep.add(sid, "ERROR", f"{w}: set_flags '{f}' must be true or false")
                if not re.fullmatch(r"[a-z][a-z0-9_]*", f):
                    rep.add(sid, "ERROR", f"{w}: flag '{f}' must be lower_snake_case")
                elif f not in known_flags and f not in must:
                    rep.add(sid, "ERROR", f"{w}: unknown flag '{f}' - not expected here and not used "
                            "anywhere (typo? see _info.must_set_flags)")
                if v is True:
                    set_by_choices.add(f)
            for p, v in ch.get("rel", {}).items():
                if p not in people:
                    rep.add(sid, "ERROR", f"{w}: unknown person '{p}' in rel ({', '.join(people)})")
                elif not isinstance(v, (int, float)) or not REL_RANGE[0] <= v <= REL_RANGE[1]:
                    rep.add(sid, "ERROR", f"{w}: rel {p} {v} is outside {REL_RANGE[0]} to {REL_RANGE[1]}")
            if "requires" in ch:
                check_requires(rep, sid, w, ch["requires"], people, known_flags)
                only_flags = not any(ch["requires"].get(k) for k in ("min", "max", "traits", "any_traits"))
                if only_flags and not ch.get("lock_text"):
                    rep.add(sid, "ERROR", f"{w}: a flag requirement needs lock_text (what the player "
                            "sees on the locked choice, e.g. \"a clear recruiting plan\")")
            fu = ch.get("follow_up")
            if fu is not None:
                fid = fu if isinstance(fu, str) else (fu.get("id") if isinstance(fu, dict) else None)
                weeks = 1 if isinstance(fu, str) else (fu.get("weeks", 1) if isinstance(fu, dict) else 0)
                tgt_new = next((x for s2, x in written if s2 == fid), None)
                tgt_old = None
                if fid in where_is:
                    tgt_old = next(s for s in docs[where_is[fid]]["scenarios"] if s["id"] == fid)
                tgt = tgt_new if tgt_new is not None else tgt_old
                if tgt is None:
                    rep.add(sid, "ERROR", f"{w}: follow_up '{fid}' doesn't exist (add it to this import "
                            "with \"follow_up_only\": true)")
                elif not (tgt.get("follow_up_only") or (tgt_old or {}).get("follow_up_only")):
                    rep.add(sid, "ERROR", f"{w}: follow_up '{fid}' must be a follow-up-only scenario; "
                            "for a graph scenario, set the flag it requires instead")
                if not isinstance(weeks, int) or not 1 <= weeks <= 6:
                    rep.add(sid, "ERROR", f"{w}: follow_up weeks must be 1-6")
        for f in must:
            if f not in set_by_choices:
                rep.add(sid, "ERROR", f"no choice sets '{f}' (listed in _info.must_set_flags)")
        for a in range(len(cleaned)):
            for b in range(len(cleaned)):
                if a != b and not cleaned[b].get("requires") and dominates(cleaned[a], cleaned[b]):
                    rep.add(sid, "warning", f"choice {a + 1} is at least as good as choice {b + 1} in every "
                            f"stat; give choice {b + 1} an upside (no choice should be strictly best)")
        lint_names = scenario_lint.names_from_people(people_doc)
        for code, where, msg in scenario_lint.lint_entry({"title": (existing or e).get("title", ""),
                                                          "text": text, "choices": cleaned}, lint_names):
            if code != "dominated":  # reported as a warning above
                rep.add(sid, "lint", f"{code} - {where}: {msg}")
        e["_clean_choices"] = cleaned

    # Merge into copies of the data files.
    graph_file = "scenarios_hs_graph.json"
    COLLEGE_FILE = "scenarios_college.json"  # the college story graph (COL_*) lives here
    changed = set()
    for sid, e in written:
        if sid in where_is:
            f = where_is[sid]
            s = next(s for s in docs[f]["scenarios"] if s["id"] == sid)
        else:
            f = COLLEGE_FILE if sid.startswith("COL_") else graph_file
            stage = ["college"] if sid.startswith("COL_") else ["high_school"]
            s = {"id": sid, "title": e.get("title", sid), "stages": e.get("stages", stage),
                 "follow_up_only": True, "added_by_import": True}
            docs[f]["scenarios"].append(s)
            where_is[sid] = f
        for k in WRITABLE:
            if k == "choices":
                s["choices"] = e["_clean_choices"]
            elif k in e and e[k] not in (None, ""):
                s[k] = e[k]
        s.pop("draft", None)
        changed.add(f)

    # Whole-graph check on the merged data (same rules as CareerContent.validate()).
    if rep.errors() == 0 and written:
        spec = importlib.util.spec_from_file_location("vsg", os.path.join(ROOT, "tools", "validate_scenario_graph.py"))
        vsg = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(vsg)
        merged = []
        for f, d in docs.items():
            for s in d.get("scenarios", []):
                merged.append(s)
        for msg in graph_errors(vsg, merged):
            sid = msg.split(":")[0]
            rep.add(sid, "ERROR", "graph: " + msg.split(":", 1)[1].strip())

    # Report.
    print(f"Import {'(dry run) ' if args.dry_run else ''}- {len(written)} written, {len(skipped)} not written yet "
          f"(skipped), {rep.errors()} error(s), {rep.warnings()} warning(s), {rep.lints()} lint note(s)\n")
    for sid in sorted(rep.lines):
        print(sid)
        for kind, msg in rep.lines[sid]:
            print(f"  {kind}: {msg}")
    ok_ids = [sid for sid, _ in written if not any(k == "ERROR" for k, _ in rep.lines.get(sid, []))]
    if ok_ids:
        print("\nOK: " + ", ".join(ok_ids))
    if rep.errors():
        print("\nNothing was written. Fix the errors above and run again.")
        return 1
    if args.dry_run:
        print("\nDry run: nothing written." + (" Run again without --dry-run to import." if written else ""))
        return 0
    for f in sorted(changed):
        with open(data_path(f, data_dir), "w", encoding="utf-8") as out:
            out.write(json.dumps(docs[f], indent="\t", ensure_ascii=False) + "\n")
        print(f"wrote {os.path.relpath(data_path(f, data_dir), ROOT)}")
    print("Next: run the Godot tests (README, Tests) - they include the engine's own content check.")
    return 0


def graph_errors(vsg, scen):
    """The error half of validate_scenario_graph.audit_data, on in-memory data."""
    errors = []
    setters = {}
    for sc in scen:
        for f in vsg.flags_set(sc):
            setters.setdefault(f, []).append(sc)
    for sc in scen:
        sid = sc["id"]
        req = sc.get("requires", {})
        reads = vsg.flags_read(req)
        for ch in sc.get("choices", []):
            reads += vsg.flags_read(ch.get("requires", {}))
        for f in reads:
            if f not in setters and f not in vsg.ENGINE_FLAGS:
                errors.append(f"{sid}: flag '{f}' is required but nothing sets it")
        for f in req.get("flags", []) + req.get("any_flags", []):
            src = setters.get(f, [])
            if src and all(x["id"] == sid for x in src):
                errors.append(f"{sid}: requires flag '{f}' that only it sets")
            elif src and f not in vsg.ENGINE_FLAGS and not any(vsg.can_precede(x, sc) for x in src):
                errors.append(f"{sid}: flag '{f}' is only set after this scenario's window")
    return errors


if __name__ == "__main__":
    sys.exit(main())

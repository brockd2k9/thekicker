#!/usr/bin/env python3
"""Style lint for scenarios already in the game data (advice only, exit 0).

    python3 tools/lint_scenarios.py              # written scenarios in the high school graph
    python3 tools/lint_scenarios.py --all        # every written scenario in data/career/scenarios_*.json
    python3 tools/lint_scenarios.py --only pronoun,game_kick

Same checks as the importer's "lint" notes (tools/scenario_lint.py): pronouns on
gender-neutral cast placeholders, hand-written cast names, curly quotes, game-kick
language, and choices that beat another on every number (or all but one).
"""
import argparse
import collections
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import scenario_lint  # noqa: E402


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--all", action="store_true", help="every scenario file, not just the high school graph")
    ap.add_argument("--only", default="", help="comma-separated codes to show")
    ap.add_argument("--data-dir", default=os.path.join(ROOT, "data", "career"))
    args = ap.parse_args(argv)
    only = {c for c in args.only.split(",") if c}
    names = scenario_lint.names_from_people(json.load(open(os.path.join(args.data_dir, "people.json"))))
    pattern = "scenarios_*.json" if args.all else "scenarios_hs_graph.json"
    counts, checked, written = collections.Counter(), 0, []
    for path in sorted(glob.glob(os.path.join(args.data_dir, pattern))):
        for s in json.load(open(path, encoding="utf-8")).get("scenarios", []):
            if s.get("draft"):
                continue
            checked += 1
            written.append(s)
    corpus = scenario_lint.corpus_findings(written)
    for s in written:
        for code, where, msg in scenario_lint.lint_entry(s, names) + corpus.get(s["id"], []):
            if only and code not in only:
                continue
            counts[code] += 1
            print(f"{s['id']}  {code} - {where}: {msg}")
    for code, where, msg in scenario_lint.rel_balance_findings(
            [s for s in written if scenario_lint.is_pro_story(s)], scenario_lint.REL_SHARE):
        if not only or code in only:
            counts[code] += 1
            print(f"(pro stage)  {code} - {where}: {msg}")
    print(f"\n{checked} written scenario(s) checked, {sum(counts.values())} lint note(s)" +
          ("".join(f"\n  {c}: {n}" for c, n in sorted(counts.items())) if counts else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())

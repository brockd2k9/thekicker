#!/usr/bin/env python3
"""One-time helper: turn the team guide PDFs into source CSVs (dev tool).

The game's team pipeline starts from CSV files in data/teams/source/ (see
DATA_FORMAT.md). This script converts the PDF guides that came before that
format existed:

  * the high school division "bible" (one record per school: Town / County /
    Mascot / Stadium / School colors / Home uniform / Away uniform)
  * the FBS and FCS program guides (one record per program: location line,
    stadium, prestige, crowd noise, draft rating, recruiting points, minimum
    OVR, minimum GPA, history, rivalry, home / away uniforms)

The D2 roster already came as a CSV in the target column format, so it is
copied, not converted.

Usage (needs `pdftotext` from poppler):
  python3 tools/teams/guides_to_csv.py --hs HS.pdf --fbs FBS.pdf --fcs FCS.pdf --out data/teams/source

Then run tools/teams/import_teams.py to rebuild data/teams/*.json.
"""

import argparse
import csv
import os
import re
import subprocess
import sys

# Same column order as the D2 roster CSV, plus the optional columns the
# importer understands (DATA_FORMAT.md).
COLUMNS = ["ID", "Division", "Region", "Conference", "School", "City", "State", "County", "Team",
           "Mascot", "Abbreviation", "Stadium", "Capacity", "Crowd Noise", "Prestige", "Draft Rating",
           "Recruiting Points", "Minimum Player OVR", "Minimum GPA", "National Championships",
           "Conference Championships", "Bowl Wins", "School Colors", "Home Jersey", "Home Pants",
           "Home Helmet", "Away Jersey", "Away Pants", "Away Helmet", "Rival", "Rivalry Trophy",
           "Strength", "Placeholder", "Notes"]


def pdf_text(path):
    return subprocess.run(["pdftotext", path, "-"], check=True, capture_output=True, text=True).stdout


def title(s):
    """'Forest green' -> 'Forest Green' (color names are matched case-insensitively anyway)."""
    return " ".join(w[:1].upper() + w[1:] for w in s.strip().split())


def slug(s):
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


# --- high school bible -------------------------------------------------------------------

def parse_hs(text, league):
    rows = []
    lines = [l.strip() for l in text.splitlines()]
    head = re.compile(r"^(\d\d)\. (.+?) — (.+)$")
    i = 0
    while i < len(lines):
        m = head.match(lines[i])
        if not m or "High School" not in m.group(2):
            i += 1
            continue
        school, team = m.group(2).strip(), m.group(3).strip()
        rec = {"School": school, "Team": team}
        j = i + 1
        while j < len(lines) and not head.match(lines[j]) and j < i + 14:
            l = lines[j]
            if l.startswith("Town:"):
                # "Mascot:" is sometimes on its own line further down.
                mm = re.match(r"Town:\s*(.+?)\s+County:\s*(.+?)(?:\s+Mascot:\s*(.+))?$", l)
                if mm:
                    rec["City"], rec["County"] = mm.group(1), mm.group(2)
                    if mm.group(3):
                        rec["Mascot"] = mm.group(3)
            elif l.startswith("Mascot:"):
                rec["Mascot"] = l.split(":", 1)[1].strip()
            elif l.startswith("Stadium:"):
                rec["Stadium"] = l.split(":", 1)[1].strip()
            elif l.startswith("School colors:"):
                rec["School Colors"] = ", ".join(title(c) for c in l.split(":", 1)[1].split(","))
            elif l.startswith("Home uniform:") or l.startswith("Away uniform:"):
                mm = re.match(r"(Home|Away) uniform:\s*(.+?) jersey / (.+?) pants", l)
                if mm:
                    rec[mm.group(1) + " Jersey"] = title(mm.group(2))
                    rec[mm.group(1) + " Pants"] = title(mm.group(3))
            j += 1
        town = rec.get("City", "")
        rec["ID"] = "hoboken_hs" if town == "Hoboken" else slug(town) + "_hs"
        rec["Division"] = "HS"
        rec["Conference"] = league
        rec["State"] = "GA"
        rec["Region"] = "South Georgia"
        rows.append(rec)
        i = j
    # Hoboken's helmet is the one helmet color the bible defines.
    for r in rows:
        if r["ID"] == "hoboken_hs":
            r["Home Helmet"] = r["Away Helmet"] = "Silver"
    return rows


# --- FBS / FCS program guides -------------------------------------------------------------

LOC = re.compile(r"^(.+?), ([A-Z]{2}) \| Region: (.+?) \| Conference: (.+)$")
SKIP = re.compile(r"^(Kicker • Fictional College Football Universe|Page \d+)$")


def parse_guide(text, division):
    lines = [l.strip() for l in text.splitlines()]
    lines = [l for l in lines if l and not SKIP.match(l)]
    starts = [i for i in range(1, len(lines)) if LOC.match(lines[i]) and " — " in lines[i - 1]]
    rows = []
    prev_end = 0
    for n, s in enumerate(starts):
        end = starts[n + 1] - 1 if n + 1 < len(starts) else len(lines)
        block = lines[s - 1:end]
        # Page breaks can push a few of this program's lines (e.g. "PROGRAM /
        # Prestige") above its header, after the previous program's away uniform.
        pre = lines[prev_end:s - 1]
        jerseys = [k for k in range(s - 1, end) if lines[k].startswith("Jersey:")]
        prev_end = (jerseys[1] + 1) if len(jerseys) >= 2 else end
        school, team = [x.strip() for x in block[0].split(" — ", 1)]
        city, state, region, conf = LOC.match(block[1]).groups()
        rec = {"School": school, "Team": team, "Mascot": "", "City": city, "State": state,
               "Region": region, "Conference": conf, "Division": division, "ID": slug(school)}
        body = "\n".join(pre + block[2:])

        def num(pattern):
            m = re.search(pattern, body)
            return m.group(1).replace(",", "") if m else ""

        m = re.search(r"^(.+?) • Capacity ([\d,]+)", body, re.M)
        if m:
            rec["Stadium"], rec["Capacity"] = m.group(1), m.group(2).replace(",", "")
        rec["Prestige"] = num(r"Prestige (\d+)/100")
        rec["Crowd Noise"] = num(r"Crowd noise (\d+)/100")
        rec["Draft Rating"] = num(r"Draft rating (\d+)/100")
        rec["Recruiting Points"] = num(r"Minimum ([\d,]+) points")
        rec["Minimum Player OVR"] = num(r"Minimum (\d+) OVR")
        rec["Minimum GPA"] = num(r"Minimum GPA ([\d.]+)/4")
        rec["National Championships"] = num(r"National titles (\d+)")
        rec["Bowl Wins"] = num(r"Bowl wins (\d+)")
        # The rivalry line follows the RIVALRY label: "Opponent — Trophy".
        m = re.search(r"RIVALRY\n(.+?) — (.+)\n", body + "\n")
        if m:
            rec["Rival"], rec["Rivalry Trophy"] = m.group(1).strip(), m.group(2).strip()
        uni = re.findall(r"Jersey: (.+?) • Pants: (.+)$", body, re.M)
        if len(uni) >= 1:
            rec["Home Jersey"], rec["Home Pants"] = title(uni[0][0]), title(uni[0][1])
        if len(uni) >= 2:
            rec["Away Jersey"], rec["Away Pants"] = title(uni[1][0]), title(uni[1][1])
        rows.append(rec)
    return rows


def write(rows, path):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in COLUMNS})
    print("wrote %s (%d teams)" % (path, len(rows)))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--hs", help="high school division bible PDF")
    ap.add_argument("--hs-league", default="South Georgia Coastal-Pine Division")
    ap.add_argument("--fbs", help="FBS program guide PDF")
    ap.add_argument("--fcs", help="FCS program guide PDF")
    ap.add_argument("--out", default="data/teams/source")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    if a.hs:
        rows = parse_hs(pdf_text(a.hs), a.hs_league)
        write(rows, os.path.join(a.out, "high_school_south_georgia.csv"))
    for div, path in (("FBS", a.fbs), ("FCS", a.fcs)):
        if path:
            rows = parse_guide(pdf_text(path), div)
            write(rows, os.path.join(a.out, "college_%s.csv" % div.lower()))
    return 0


if __name__ == "__main__":
    sys.exit(main())

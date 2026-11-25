#!/usr/bin/env python3
"""Fictional all-time record book: data/records/record_book.json (dev tool).

Run once; the file is checked in and the game never regenerates it:

    python3 tools/records/generate_records.py            # writes the file
    python3 tools/records/generate_records.py --check    # summary only, nothing written

The book is a set of fictional kickers with every season they played (team,
attempts, makes by distance, extra points, longest kick), generated from a
fixed seed. The game (RecordBook, scripts/records/record_book.gd) builds every
ranked list from those seasons when a list is first shown, so lists are
consistent by construction: points = 3 x FG + XP, distance buckets add up to
the FGs made, the longest kick sits in its bucket, and a team's list is a
subset of its conference's, division's and league's.

Teams, divisions and conferences come from data/teams (the TeamDatabase
data): nothing here names a team.

The model, per level (real-life scale, 10 / 12 / 17-game seasons today):
  * Each team has a history that starts in a year set by its size and prestige
    (older, bigger programs: deeper books) and runs to LAST_YEAR.
  * A team has one kicker at a time. College and high school kickers play 1-4
    seasons at one school; pro kickers can play 20+ seasons and change teams.
  * Each season: games (by era), attempts per game, a distance for every
    attempt (by era and leg), a make chance by distance, era and accuracy, and
    extra points from the team's offense. Strong programs (strength or
    prestige) land better kickers and score more.
  * Eras: kicking got more accurate and longer over the decades; college
    kickers could use a tee until 1988 (more very long attempts).
"""

import argparse
import json
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import names  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "records", "record_book.json")
SEED = 20261121
LAST_YEAR = 2025
FORMAT = 1
# Field goal distance buckets (same as CareerRecords.BUCKETS): 20-29 ... 60+.
BUCKET_LOW = [0, 30, 40, 50, 60]


def bucket(yd):
    for i in range(4, -1, -1):
        if yd >= BUCKET_LOW[i]:
            return i
    return 0


def load_teams(level):
    with open(os.path.join(ROOT, "data", "teams", level + ".json"), encoding="utf-8") as f:
        return json.load(f)["teams"]


def lerp(a, b, f):
    return a + (b - a) * max(0.0, min(1.0, f))


# --- level models -------------------------------------------------------------------------

class Level:
    name = ""
    seasons_max = 4
    att_per_game = 1.5        # league-average field goal attempts per game, modern era
    xp_per_game = 3.0         # extra points made per game, average offense
    # Make chance by bucket for an average kicker: (oldest era, modern era).
    make_old = [0.80, 0.60, 0.40, 0.25, 0.10]
    make_new = [0.97, 0.88, 0.75, 0.55, 0.30]
    era_from = 1960           # year the "modern" curve starts to take over
    era_to = 2015
    dist_mean = 37.0          # mean attempt distance, modern era
    dist_sd = 9.5
    second_kicker = 0.2       # chance a season has a second kicker (part of the season)
    long_cap = 66             # nobody attempts beyond this
    long_try = 0.4            # chance a 56+ yard attempt is really taken

    def games(self, year):
        return 10

    def era(self, year):
        return (year - self.era_from) / float(self.era_to - self.era_from)

    def start_year(self, team, rng):
        return 1975

    def tee_bonus(self, year):
        return 0.0


class Pro(Level):
    name = "pro"
    seasons_max = 22
    att_per_game = 1.8
    xp_per_game = 2.35
    make_old = [0.78, 0.58, 0.38, 0.22, 0.06]
    make_new = [0.985, 0.92, 0.83, 0.70, 0.40]
    era_from = 1960
    era_to = 2018
    dist_mean = 37.5
    dist_sd = 9.5
    long_cap = 66
    long_try = 0.55
    second_kicker = 0.3

    def games(self, year):
        return 14 if year <= 1977 else (16 if year <= 2020 else 17)

    def start_year(self, team, rng):
        # Older franchises: more titles and a bigger fan base.
        h = team.get("history", {})
        age = h.get("league_titles", 0) * 2 + h.get("conference_titles", 0) \
            + (team.get("ratings", {}).get("fan_base", 80) - 74) / 3.0
        return int(round(lerp(1996, 1960, age / 10.0)))


class College(Level):
    name = "college"
    seasons_max = 4
    att_per_game = 1.45
    xp_per_game = 3.6
    make_old = [0.80, 0.58, 0.38, 0.24, 0.12]
    make_new = [0.96, 0.85, 0.70, 0.52, 0.28]
    era_from = 1955
    era_to = 2015
    dist_mean = 36.5
    dist_sd = 9.0
    long_cap = 69
    long_try = 0.25
    second_kicker = 0.3

    # Division scale: FBS the most kicking, D2 the least.
    DIV = {"FBS": (1.0, 1.0, 0.0), "FCS": (0.93, 0.92, -0.03), "D2": (0.82, 0.85, -0.06)}

    def games(self, year):
        return 10 if year < 1970 else (11 if year < 2006 else 12)

    def tee_bonus(self, year):
        return 4.0 if year <= 1988 else 0.0

    def start_year(self, team, rng):
        div = team["division"]
        p = team.get("ratings", {}).get("prestige", 50)
        cap = team.get("stadium", {}).get("capacity", 10000)
        size = (p / 100.0) * 0.7 + min(cap / 100000.0, 1.0) * 0.3
        lo, hi = {"FBS": (1950, 1975), "FCS": (1956, 1985), "D2": (1964, 1995)}.get(div, (1970, 1995))
        return int(round(lerp(hi, lo, size))) + rng.randint(-2, 2)


class HighSchool(Level):
    name = "high_school"
    seasons_max = 4
    att_per_game = 0.95
    xp_per_game = 3.6
    make_old = [0.70, 0.45, 0.25, 0.10, 0.03]
    make_new = [0.88, 0.70, 0.48, 0.28, 0.10]
    era_from = 1975
    era_to = 2018
    dist_mean = 33.5
    dist_sd = 8.0
    long_cap = 62
    long_try = 0.3

    def games(self, year):
        return 10

    def start_year(self, team, rng):
        return 1975  # the bible gives no history: every school starts together


LEVELS = {"pro": Pro(), "college": College(), "high_school": HighSchool()}


# --- team strength ------------------------------------------------------------------------

def team_quality(level, team, teams):
    """0..1: the team's place in its level by stored strength or prestige (0.5 without)."""
    def raw(t):
        if "strength" in t:
            return float(t["strength"])
        return float(t.get("ratings", {}).get("prestige", -1))
    vals = [raw(t) for t in teams if raw(t) >= 0 and t.get("division") == team.get("division")]
    v = raw(team)
    if v < 0 or not vals or max(vals) == min(vals):
        return 0.5
    return (v - min(vals)) / (max(vals) - min(vals))


# --- kickers ------------------------------------------------------------------------------

class Namer:
    def __init__(self, rng):
        self.rng = rng
        self.used = set()

    def take(self):
        for _ in range(10000):
            f = self.rng.randrange(len(names.FIRST))
            l = self.rng.randrange(len(names.LAST))
            if (f, l) not in self.used:
                self.used.add((f, l))
                return f, l
        raise RuntimeError("name pools exhausted")


def new_kicker(rng, quality, level):
    """accuracy (-1..1-ish), leg (extra yards), and how long he can last."""
    acc = rng.gauss(0.0, 0.45) + (quality - 0.5) * 0.7
    leg = rng.gauss(0.0, 3.0) + (quality - 0.5) * 2.5
    return {"acc": acc, "leg": leg}


def make_chance(lv, b, year, acc):
    e = lv.era(year)
    base = lerp(lv.make_old[b], lv.make_new[b], e)
    # Accuracy moves the miss rate: a good kicker misses less at every distance.
    miss = (1.0 - base) * math.exp(-0.75 * acc)
    return max(0.01, min(0.995, 1.0 - miss))


def play_season(lv, rng, k, year, quality, div_scale=(1.0, 1.0, 0.0), share=1.0):
    """One season: [fg_att, xp_made, b0..b4 made, long]."""
    games = max(1, int(round(lv.games(year) * share)))
    att_scale, xp_scale, acc_shift = div_scale
    e = lv.era(year)
    apg = lv.att_per_game * att_scale * lerp(0.85, 1.0, e) * rng.uniform(0.8, 1.2)
    if lv.name == "high_school":
        # High school coaches send a sure, strong-legged kicker out much more
        # (and go for it on fourth down with a shaky one).
        apg *= min(1.6, math.exp(0.2 * k["acc"] + 0.03 * k["leg"]))
    att = 0
    for _ in range(games):
        # Poisson-ish attempts per game.
        n = 0
        lam = apg
        L = math.exp(-lam)
        p = 1.0
        while True:
            p *= rng.random()
            if p <= L:
                break
            n += 1
        att += n
    made = [0, 0, 0, 0, 0]
    long_ = 0
    # Reach: 6 yards short of the level's cap for an average leg; a big leg
    # (or a college tee before 1989) gets closer. Nobody kicks past the cap.
    reach = min(float(lv.long_cap), lv.long_cap - 6 + k["leg"] * 0.8 + lv.tee_bonus(year) * 0.5)
    mean = lv.dist_mean + lerp(-2.5, 0.0, e) + lv.tee_bonus(year) * 0.5 + k["leg"] * 0.4
    for _ in range(att):
        yd = int(round(rng.gauss(mean, lv.dist_sd + lv.tee_bonus(year) * 0.3)))
        # Coaches rarely send the kicker out from very far: most of those
        # drives end in a punt or a fourth-down try instead.
        while yd >= 56 and rng.random() > lv.long_try:
            yd = int(round(rng.gauss(mean, lv.dist_sd)))
        yd = max(18, min(int(reach), yd))
        b = bucket(yd)
        # Range: kicks near the leg's limit are harder still.
        p = make_chance(lv, b, year, k["acc"] + acc_shift)
        if yd > reach - 6:
            p *= 0.75
        if rng.random() < p:
            made[b] += 1
            long_ = max(long_, yd)
    xp_rate = lv.xp_per_game * xp_scale * lerp(0.8, 1.25, quality) * rng.uniform(0.8, 1.2)
    xp_pct = lerp(0.93, 0.985, e) if lv.name != "pro" else (0.94 if year >= 2015 else lerp(0.95, 0.99, e))
    xp_att = sum(1 for _ in range(int(round(xp_rate * games))))
    xp = sum(1 for _ in range(xp_att) if rng.random() < xp_pct)
    return [att, xp] + made + [long_]


def gen_one_school_level(lv, teams, rng, namer):
    """College / high school: kickers stay at one school, 1-4 seasons."""
    players = []
    for ti, t in enumerate(teams):
        q = team_quality(lv.name, t, teams)
        div_scale = College.DIV.get(t.get("division", ""), (1.0, 1.0, 0.0)) if lv.name == "college" else (1.0, 1.0, 0.0)
        year = lv.start_year(t, rng)
        while year <= LAST_YEAR:
            k = new_kicker(rng, q, lv)
            span = rng.choices([1, 2, 3, 4], weights=[22, 30, 26, 22])[0] if lv.name == "college" \
                else rng.choices([1, 2, 3, 4], weights=[30, 36, 24, 10])[0]
            span = min(span, LAST_YEAR - year + 1)
            seasons = []
            for i in range(span):
                y = year + i
                k["acc"] += rng.gauss(0.08, 0.12)  # kickers improve with age
                k["leg"] += rng.gauss(0.5, 0.8)
                # Some seasons a second kicker takes part of the kicks
                # (injury, a slump, a strong-legged backup for long tries).
                share = 1.0
                if rng.random() < lv.second_kicker:
                    share = rng.uniform(0.55, 0.9)
                    b = new_kicker(rng, q * 0.8, lv)
                    bf, bl = namer.take()
                    players.append([bf, bl, ti, y, [play_season(lv, rng, b, y, q, div_scale, 1.0 - share)]])
                seasons.append(play_season(lv, rng, k, y, q, div_scale, share))
            f, l = namer.take()
            players.append([f, l, ti, year, seasons])
            year += span
    return players


def gen_pro(lv, teams, rng, namer):
    """Pro: one kicker per team at a time; kickers last years and move teams."""
    tq = [team_quality("pro", t, teams) for t in teams]
    starts = [lv.start_year(t, rng) for t in teams]
    kickers = []          # {f, l, acc, leg, age, seasons: [[year, team_i, ...]], active}
    current = [None] * len(teams)
    free = []             # veterans without a team
    for year in range(min(starts), LAST_YEAR + 1):
        for ti, t in enumerate(teams):
            if year < starts[ti]:
                continue
            k = current[ti]
            if k is None:
                vets = [v for v in free if v["age"] <= 37 and v["acc"] > -0.2]
                if vets and rng.random() < 0.3:
                    k = rng.choice(vets)
                    free.remove(k)
                else:
                    k = new_kicker(rng, tq[ti], lv)
                    k.update({"age": rng.randint(22, 24), "seasons": [], "name": None})
                    kickers.append(k)
                current[ti] = k
            share = 1.0
            if rng.random() < lv.second_kicker:
                # An injury or a midseason cut: a stand-in (a free veteran or
                # a rookie) kicks part of the season.
                share = rng.uniform(0.3, 0.85)
                vets = [v for v in free if v["age"] <= 38]
                if vets and rng.random() < 0.5:
                    b = rng.choice(vets)
                else:
                    b = new_kicker(rng, tq[ti] * 0.7, lv)
                    b.update({"age": rng.randint(22, 26), "seasons": [], "name": None})
                    kickers.append(b)
                    free.append(b)
                row = play_season(lv, rng, b, year, tq[ti], share=1.0 - share)
                b["seasons"].append([year, ti] + row)
            row = play_season(lv, rng, k, year, tq[ti], share=share)
            k["seasons"].append([year, ti] + row)
        # Off-season: age, form, and who keeps the job.
        for ti in range(len(teams)):
            k = current[ti]
            if k is None or k["seasons"][-1][0] != year:
                continue
            k["age"] += 1
            k["acc"] += rng.gauss(0.04 if k["age"] < 30 else -0.03 * (k["age"] - 30) / 4.0, 0.1)
            k["leg"] += rng.gauss(0.3 if k["age"] < 28 else -0.35, 0.5)
            last = k["seasons"][-1]
            att, made = last[2], sum(last[4:9])
            pct = made / att if att else 0.5
            # League-average FG% this year (a typical mix of distances).
            expect = sum(w * make_chance(lv, b, year, 0.0) for b, w in enumerate((0.27, 0.3, 0.28, 0.14, 0.01)))
            # Even a great kicker leaves some years (injury, money, a new coach).
            keep = min(0.92, 0.7 + (pct - expect) * 2.0 + min(len(k["seasons"]), 5) * 0.015) \
                - max(0, k["age"] - 35) * 0.04
            if len(k["seasons"]) >= lv.seasons_max or k["age"] >= 46 or rng.random() > keep:
                current[ti] = None
                if k["age"] < 36 and rng.random() < 0.55:
                    free.append(k)
        free = [v for v in free if v["seasons"][-1][0] >= year - 1]
    players = []
    for k in kickers:
        f, l = namer.take()
        players.append([f, l, k["seasons"]])
    return players


# --- lists (summary and the nesting fix) --------------------------------------------------

def season_rows(level, data, teams):
    """[(player_index, year, team_index, row)] for every season."""
    out = []
    for pi, p in enumerate(data):
        if level == "pro":
            for s in p[2]:
                out.append((pi, s[0], s[1], s[2:]))
        else:
            for i, s in enumerate(p[4]):
                out.append((pi, p[3] + i, p[2], s))
    return out


def career_pct_by_scope(level, data, teams, scope_of):
    """{scope: best career FG% (min 50 att)} where scope_of(team) -> list of scopes."""
    agg = {}
    for pi, year, ti, row in season_rows(level, data, teams):
        for sc in scope_of(teams[ti]):
            a = agg.setdefault((sc, pi), [0, 0])
            a[0] += row[0]
            a[1] += sum(row[2:7])
    best = {}
    for (sc, pi), (att, made) in agg.items():
        if att >= 50:
            best[sc] = max(best.get(sc, 0.0), made / att)
    return best, agg


def fix_pro_pct_nesting(data, teams):
    """A pro kicker's best stint (one team) can't beat the league's best career
    FG%. Turns makes into misses in the offending stint until it doesn't."""
    def scopes(t):
        return ["L", "C:" + t["division"], "D:" + t["conference"], "T:" + t["id"]]
    parent = {"C": "L", "D": "C", "T": "D"}
    changed = 0
    for _ in range(200):
        best, agg = career_pct_by_scope("pro", data, teams, scopes)
        bad = None
        for (sc, pi), (att, made) in agg.items():
            if att < 50 or sc == "L":
                continue
            kind = sc[0]
            t = None
            if kind == "T":
                t = next(x for x in teams if x["id"] == sc[2:])
                up = "D:" + t["conference"]
            elif kind == "D":
                t = next(x for x in teams if x["conference"] == sc[2:])
                up = "C:" + t["division"]
            else:
                up = "L"
            if made / att > best.get(up, 1.0) + 1e-9:
                bad = (sc, pi)
                break
        if bad is None:
            return changed
        sc, pi = bad
        for s in data[pi][2]:
            t = teams[s[1]]
            if sc in scopes(t):
                for b in (0, 1, 2, 3, 4):
                    if s[4 + b] > 0:
                        s[4 + b] -= 1
                        changed += 1
                        made_now = sum(s[4:9])
                        if made_now == 0:
                            s[9] = 0
                        elif bucket(s[9]) == b and s[4 + b] == 0:
                            hi = max(i for i in range(5) if s[4 + i] > 0)
                            s[9] = min(s[9], BUCKET_LOW[hi] + 9 if hi < 4 else s[9])
                        break
                break
    raise RuntimeError("pct nesting fix did not converge")


# --- output -------------------------------------------------------------------------------
# Compact encoding (RecordBook decodes it): numbers in base 36, fixed width.
#   high school / college: levels.<level>.teams = {team_id: "player,player,..."}
#     player = FF LL YY + seasons, each season 11 chars:
#       AA fg_att, XX xp_made, 5 x one char: FG made 20-29 / 30-39 / 40-49 /
#       50-59 / 60+, LG longest made FG
#     FF / LL: index into names.first / names.last; YY: first season - 1900.
#     Seasons are consecutive years.
#   pro: levels.pro.players = "player,player,...", team index into levels.pro.teams
#     player = FF LL + seasons, each 15 chars: YY year - 1900, TT team, then the 11 above.

B36 = "0123456789abcdefghijklmnopqrstuvwxyz"


def b36(n, width):
    if n < 0 or n >= 36 ** width:
        raise ValueError("%d doesn't fit in %d base-36 chars" % (n, width))
    out = ""
    for _ in range(width):
        out = B36[n % 36] + out
        n //= 36
    return out


def enc_season(row):
    att, xp, b0, b1, b2, b3, b4, lg = row
    return b36(att, 2) + b36(xp, 2) + "".join(b36(x, 1) for x in (b0, b1, b2, b3, b4)) + b36(lg, 2)


def encode_school_level(players, teams):
    by_team = {t: [] for t in teams}
    for f, l, ti, y0, seasons in players:
        by_team[teams[ti]].append(b36(f, 2) + b36(l, 2) + b36(y0 - 1900, 2) + "".join(enc_season(s) for s in seasons))
    return {t: ",".join(v) for t, v in by_team.items()}


def encode_pro(players):
    out = []
    for f, l, seasons in players:
        out.append(b36(f, 2) + b36(l, 2) + "".join(
            b36(s[0] - 1900, 2) + b36(s[1], 2) + enc_season(s[2:]) for s in seasons))
    return ",".join(out)


def generate():
    """{level: (teams, players)} in the plain form (summary, tests)."""
    rng = random.Random(SEED)
    namer = Namer(rng)
    out = {}
    for level in ("high_school", "college", "pro"):
        teams = [t for t in load_teams(level) if t.get("division") != "JUCO"]
        teams.sort(key=lambda t: t["id"])
        lv = LEVELS[level]
        if level == "pro":
            data = gen_pro(lv, teams, rng, namer)
            fix_pro_pct_nesting(data, teams)
        else:
            data = gen_one_school_level(lv, teams, rng, namer)
        out[level] = ([t["id"] for t in teams], data)
    return out


def book_json(gen):
    levels = {}
    for level, (teams, data) in gen.items():
        if level == "pro":
            levels[level] = {"teams": teams, "players": encode_pro(data)}
        else:
            levels[level] = {"teams": encode_school_level(data, teams)}
    book = {
        "_doc": ("Fictional all-time record book, generated once by tools/records/generate_records.py "
                 "(seed %d). Don't edit by hand. The game (RecordBook) builds every ranked list from these "
                 "seasons. Encoding: see the comment above encode_school_level in the generator." % SEED),
        "format": FORMAT, "seed": SEED, "last_year": LAST_YEAR,
        "names": {"first": names.FIRST, "last": names.LAST},
        "levels": levels,
    }
    return json.dumps(book, ensure_ascii=False, indent=1) + "\n"


def summary(gen):
    for level, (teams, data) in gen.items():
        rows = season_rows(level, data, teams)
        made = sorted((sum(r[3][2:7]) for r in rows), reverse=True)
        att = sorted((r[3][0] for r in rows), reverse=True)
        xp = sorted((r[3][1] for r in rows), reverse=True)
        pts = sorted((3 * sum(r[3][2:7]) + r[3][1] for r in rows), reverse=True)
        lng = sorted((r[3][7] for r in rows), reverse=True)
        car = {}
        for pi, y, ti, r in rows:
            c = car.setdefault(pi, [0, 0, 0, 0, 0])
            c[0] += r[0]
            c[1] += sum(r[2:7])
            c[2] += r[1]
            c[3] += 1
            c[4] += r[6]
        cm = sorted((c[1] for c in car.values()), reverse=True)
        cp = sorted((3 * c[1] + c[2] for c in car.values()), reverse=True)
        cx = sorted((c[2] for c in car.values()), reverse=True)
        c60 = sorted((c[4] for c in car.values()), reverse=True)
        print("%s: %d kickers, %d seasons" % (level, len(data), len(rows)))
        print("  season FG made #1/#25: %d/%d  att #1: %d  XP #1/#25: %d/%d  pts #1/#25: %d/%d  long #1/#25: %d/%d"
              % (made[0], made[24], att[0], xp[0], xp[24], pts[0], pts[24], lng[0], lng[24]))
        print("  career FG made #1/#50: %d/%d  XP #1: %d  pts #1/#25: %d/%d  60+ made #1: %d  seasons max: %d"
              % (cm[0], cm[min(49, len(cm) - 1)], cx[0], cp[0], cp[24], c60[0], max(c[3] for c in car.values())))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="print the summary, write nothing")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()
    gen = generate()
    summary(gen)
    text = book_json(gen)
    print("size: %.0f KB" % (len(text.encode("utf-8")) / 1024.0))
    if not a.check:
        os.makedirs(os.path.dirname(a.out), exist_ok=True)
        with open(a.out, "w", encoding="utf-8") as f:
            f.write(text)
        print("wrote " + os.path.relpath(a.out, ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""Record book data: python3 -m unittest discover -s tests -p 'test_*.py'

Checks tools/records/generate_records.py and data/records/record_book.json:
the checked-in file is exactly what the fixed seed makes, every name is
unique across the whole book, no real kicker's surname is used, and the
compact encoding decodes to consistent seasons.
"""
import json
import os
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools", "records"))
import generate_records as gen  # noqa: E402
import names  # noqa: E402

PATH = os.path.join(ROOT, "data", "records", "record_book.json")


def load():
    with open(PATH, encoding="utf-8") as f:
        return json.load(f)


def n36(s, at, w):
    v = 0
    for i in range(w):
        v = v * 36 + gen.B36.index(s[at + i])
    return v


def decode(book):
    """[(level, name, [(year, team, att, xp, b[5], long)])]"""
    first, last = book["names"]["first"], book["names"]["last"]
    out = []
    for level, lv in book["levels"].items():
        if level == "pro":
            for p in lv["players"].split(","):
                seasons = []
                for at in range(4, len(p), 15):
                    s = at + 4
                    seasons.append((1900 + n36(p, at, 2), lv["teams"][n36(p, at + 2, 2)], n36(p, s, 2),
                                    n36(p, s + 2, 2), [n36(p, s + 4 + i, 1) for i in range(5)], n36(p, s + 9, 2)))
                out.append((level, first[n36(p, 0, 2)] + " " + last[n36(p, 2, 2)], seasons))
        else:
            for team, raw in lv["teams"].items():
                for p in raw.split(","):
                    y0 = 1900 + n36(p, 4, 2)
                    seasons = []
                    for k, at in enumerate(range(6, len(p), 11)):
                        seasons.append((y0 + k, team, n36(p, at, 2), n36(p, at + 2, 2),
                                        [n36(p, at + 4 + i, 1) for i in range(5)], n36(p, at + 9, 2)))
                    out.append((level, first[n36(p, 0, 2)] + " " + last[n36(p, 2, 2)], seasons))
    return out


class RecordBookDataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.book = load()
        cls.players = decode(cls.book)

    def test_seed_determinism(self):
        with open(PATH, encoding="utf-8") as f:
            self.assertEqual(gen.book_json(gen.generate()), f.read(),
                             "record_book.json isn't what the seed makes: run tools/records/generate_records.py")
        self.assertEqual(self.book["seed"], gen.SEED)

    def test_names_unique_across_the_whole_book(self):
        all_names = [p[1] for p in self.players]
        self.assertEqual(len(all_names), len(set(all_names)))
        self.assertGreater(len(all_names), 10000)

    def test_no_real_kicker_surnames(self):
        for _, name, _ in self.players:
            self.assertNotIn(name.split(" ", 1)[1], names.REAL_KICKER_SURNAMES, name)
        self.assertFalse(set(self.book["names"]["last"]) & names.REAL_KICKER_SURNAMES)

    def test_seasons_are_consistent(self):
        low = gen.BUCKET_LOW
        for level, name, seasons in self.players:
            self.assertTrue(seasons, name)
            for year, team, att, xp, b, long_ in seasons:
                made = sum(b)
                self.assertLessEqual(made, att, name)
                self.assertLessEqual(year, self.book["last_year"])
                if made == 0:
                    self.assertEqual(long_, 0, name)
                else:
                    top = max(i for i in range(5) if b[i] > 0)
                    self.assertEqual(gen.bucket(long_), top, "%s %d: longest %d in bucket %d" % (name, year, long_, top))
                    self.assertGreaterEqual(long_, max(18, low[top]))

    def test_teams_match_the_team_database(self):
        for level in ("high_school", "college", "pro"):
            with open(os.path.join(ROOT, "data", "teams", level + ".json"), encoding="utf-8") as f:
                ids = sorted(t["id"] for t in json.load(f)["teams"] if t.get("division") != "JUCO")
            lv = self.book["levels"][level]
            got = sorted(lv["teams"]) if isinstance(lv["teams"], list) else sorted(lv["teams"].keys())
            self.assertEqual(got, ids, level)

    def test_file_size(self):
        self.assertLess(os.path.getsize(PATH), 700 * 1024)


if __name__ == "__main__":
    unittest.main()

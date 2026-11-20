"""Style lint for written scenarios (advice, never blocks an import).

Used by tools/import_scenarios.py (every written entry, dry run or not) and by
tools/lint_scenarios.py (scenarios already in the game data). Each finding is
(code, where, message). Codes:

  pronoun        he/she/him/her/his/hers right after a gender-neutral cast
                 placeholder ({coach}, {teacher}, {holder}, {best_friend},
                 {love_interest}): their names come from mixed lists
  hardcoded_name a cast name written by hand ("Dad", "Tyler", "Coach Rourke",
                 "Ms. Alvarez", a love interest's name...): use the placeholder
  curly_quote    ’ ‘ “ ”: the game data uses straight quotes
  game_kick      language that describes a game kick or its result; scenarios
                 happen off the field and the player kicks the real game
  dominated      a choice at least as good as another in every number
                 (stats, skill points, recruiting, grades, rel) and better in one
  near_dominated the same except for a single number: probably too one-sided

The checks are heuristics: read the line before changing it.
"""
import re

NEUTRAL = {"coach", "teacher", "holder", "best_friend", "love_interest", "backup"}
# {tyler}/{rival}, {sibling} and {parent} are always male; {team} is a group.
GENDERED = re.compile(r"\b(he|she|him|her|his|hers|himself|herself)\b", re.I)
PLACEHOLDER = re.compile(r"\{([a-z_]+)\}")
CURLY = re.compile("[‘’“”]")
GAME_KICK = [re.compile(p, re.I) for p in [
    r"\b(the|your|his|their) (kick|field goal|extra point|attempt) (is|was) good\b",
    r"\b(kick|field goal|extra point|ball) (goes|went|sails|sailed) (through|wide|left|right)\b",
    r"\bsplits? the uprights\b",
    r"\bgoes through\b",
    r"\bgame[- ]winn(ing|er)\b",
    r"\blate in (a|the) (close |tight |big )?game\b",
    r"\b(you|we) (won|lost|win|lose) the game\b",
    r"\b(make|made|miss|missed|nail|nailed|drill|drilled) the (game[- ]winner|winning kick)\b",
]]
# Words that read as a hand-written cast name. Teacher / love interest names come
# from people.json ("names"); see names_from_people().
FIXED_NAMES = ["Dad", "Tyler", "Brooks"]
TITLE_NAME = re.compile(r"\b(Coach|Mr\.|Ms\.|Mrs\.|Dr\.) [A-Z][a-z]+")


def names_from_people(people_doc):
    names = set(FIXED_NAMES)
    for lst in (people_doc.get("names") or {}).values():
        for n in lst:
            names.add(n.split(" ")[-1])  # "Ms. Alvarez" -> "Alvarez"
    return sorted(names)


def _fields(entry):
    """(where, text) for the scenario text, every label/result/lock_text."""
    out = [("text", str(entry.get("text", "")))]
    for i, ch in enumerate(entry.get("choices") or []):
        if not isinstance(ch, dict):
            continue
        for k in ("label", "result", "lock_text"):
            if ch.get(k):
                out.append((f"choice {i + 1} {k}", str(ch[k])))
    return out


def _other_referent(text):
    """True if the scenario text already uses he/she for someone who isn't a neutral cast member
    (an NPC like "a transfer quarterback", or {tyler}): choice lines may then mean that person."""
    last = None
    for m in sorted([(m.start(), "ph", m.group(1)) for m in PLACEHOLDER.finditer(text)] +
                    [(m.start(), "pr", m.group(0)) for m in GENDERED.finditer(text)]):
        if m[1] == "ph":
            last = m[2]
        elif last not in NEUTRAL:
            return True
    return False


def _pronoun_findings(entry):
    found = []
    text = str(entry.get("text", ""))
    text_ph = PLACEHOLDER.findall(text)
    context = text_ph[-1] if text_ph else None  # who a choice line talks about by default
    ambiguous = _other_referent(text)
    for where, s in _fields(entry):
        if ambiguous:
            break  # the scene already has a he/she for someone else: too unsure to flag
        last = None if where == "text" else context
        tokens = sorted([(m.start(), "ph", m.group(1)) for m in PLACEHOLDER.finditer(s)] +
                        [(m.start(), "pr", m.group(0)) for m in GENDERED.finditer(s)])
        for _, kind, val in tokens:
            if kind == "ph":
                last = val
            elif last in NEUTRAL:
                found.append(("pronoun", where, f"'{val}' after {{{last}}}: use they or rephrase "
                              "(names for this person aren't all one gender)"))
    return found


def _numbers(ch):
    v = {}
    for d in (ch.get("stats") or {}).values():
        for k, x in (d or {}).items():
            if x:
                v[k] = x
    for k in ("skill_points", "recruiting", "grades", "draft", "retention"):
        if ch.get(k):
            v[k] = ch[k]
    for p, x in (ch.get("rel") or {}).items():
        if x:
            v["rel_" + p] = x
    return v


def compare(a, b):
    """(better, worse) key lists of choice a against choice b."""
    va, vb = _numbers(a), _numbers(b)
    keys = set(va) | set(vb)
    better = sorted(k for k in keys if va.get(k, 0) > vb.get(k, 0))
    worse = sorted(k for k in keys if va.get(k, 0) < vb.get(k, 0))
    return better, worse


def dominance_findings(choices):
    found = []
    open_choices = [(i, c) for i, c in enumerate(choices) if isinstance(c, dict) and not c.get("requires")]
    for i, a in open_choices:
        for j, b in open_choices:
            if i == j:
                continue
            better, worse = compare(a, b)
            if better and not worse:
                found.append(("dominated", f"choice {i + 1}", f"at least as good as choice {j + 1} in every "
                              f"number; give choice {j + 1} an upside"))
            elif len(better) >= 2 and len(worse) == 1:
                found.append(("near_dominated", f"choice {i + 1}", f"beats choice {j + 1} on everything except "
                              f"{worse[0]} ({', '.join(better)}); choice {j + 1} may be too weak"))
    return found


def lint_entry(entry, names):
    found = _pronoun_findings(entry)
    for where, s in _fields(entry):
        if CURLY.search(s):
            found.append(("curly_quote", where, "curly quote; use straight ' and \""))
        practice = re.search(r"\b(practice|warmup|warm-up|drills?|scrimmage|net)\b", s, re.I)
        for p in GAME_KICK if not practice else []:
            m = p.search(s)
            if m:
                found.append(("game_kick", where, f"'{m.group(0)}': scenarios happen off the field; "
                              "don't describe a game kick or its result"))
                break
        for n in names:
            if re.search(r"\b" + re.escape(n) + r"\b", s):
                found.append(("hardcoded_name", where, f"'{n}' looks like a cast name; use its placeholder"))
        m = TITLE_NAME.search(s)
        if m:
            found.append(("hardcoded_name", where, f"'{m.group(0)}' looks like a cast name; use its placeholder"))
    found += dominance_findings(entry.get("choices") or [])
    return found

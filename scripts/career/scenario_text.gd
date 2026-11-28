class_name ScenarioText
extends RefCounted
## How a scene's text is read on the scenario screen: split into short beats
## (tap to continue), one key phrase highlighted, and the person it features.
##
## Data fields (all optional, on the scene):
##   key      a phrase copied from the text to highlight; default: the last
##            sentence (the choice you face), cut to its last clause if long
##   speaker  a cast id (people.json) shown as the speaker strip; default:
##            the first {person} the text names; "" = none

## A beat holds about this many characters: 2 to 3 lines on a phone.
const BEAT_CHARS := 120
## An automatic key phrase longer than this is cut to its last clause; still
## too long and nothing is highlighted.
const KEY_MAX := 90


## The text in beats of whole sentences, each up to max_chars (a longer
## sentence is a beat of its own). Short text is one beat.
static func beats(text: String, max_chars := BEAT_CHARS) -> Array:
	var out: Array = []
	var cur := ""
	for s in sentences(text):
		if cur == "":
			cur = s
		elif cur.length() + 1 + s.length() <= max_chars:
			cur += " " + s
		else:
			out.append(cur)
			cur = s
	if cur != "":
		out.append(cur)
	return out


## Sentences: split after . ! ? (and a closing quote), keeping the marks.
static func sentences(text: String) -> Array:
	var out: Array = []
	var re := RegEx.create_from_string("[^.!?]+(?:[.!?]+[\"')\\x{201d}]*|$)")
	for m in re.search_all(text.strip_edges()):
		var s := m.get_string().strip_edges()
		if s != "":
			out.append(s)
	return out


## The phrase to highlight: the scene's "key" if it's in the text, else the
## last sentence (or its last clause when that sentence is long). "" = none.
static func key_phrase(s: Dictionary, text: String) -> String:
	var k := str(s.get("key", ""))
	if k != "":
		return k if text.contains(k) else ""
	var ss := sentences(text)
	if ss.size() < 2:
		return ""
	var last := str(ss[ss.size() - 1])
	if last.length() <= KEY_MAX:
		return last
	for sep in [", but ", " but ", ", and ", ", so ", "; ", ", "]:
		var i := last.rfind(sep)
		if i > 0:
			var tail := last.substr(i + sep.length())
			if tail.length() >= 12 and tail.length() <= KEY_MAX:
				return tail
	return ""


## The cast id this scene features: "speaker" in the data, else the first
## {person} its raw (unfilled) text names. "" = nobody.
static func speaker(s: Dictionary) -> String:
	if s.has("speaker"):
		return str(s["speaker"])
	var raw := str(s.get("text", ""))
	var best := ""
	var at := -1
	for id in Relationships.ids():
		var i := raw.find("{%s}" % id)
		if i >= 0 and (at < 0 or i < at):
			at = i
			best = str(id)
	return best


## BBCode for a beat: escaped, with the key phrase (if it's in this beat) in
## the accent color and the strong font.
static func bbcode(beat: String, key: String, accent: Color) -> String:
	var i := beat.find(key) if key != "" else -1
	if i < 0:
		return escape(beat)
	return "%s[color=#%s][b]%s[/b][/color]%s" % [escape(beat.substr(0, i)), accent.to_html(false),
		escape(key), escape(beat.substr(i + key.length()))]


static func escape(t: String) -> String:
	return t.replace("[", "[lb]")

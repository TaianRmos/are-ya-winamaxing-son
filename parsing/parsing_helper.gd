class_name ParsingHelper
extends RefCounted


static var _regex_cache: Dictionary = {}


## Compiles a regex and cache the pattern for more efficiency
static func rx(pattern: String) -> RegEx:
	if not _regex_cache.has(pattern):
		_regex_cache[pattern] = RegEx.create_from_string(pattern)
	return _regex_cache[pattern]


## Takes a price and convert it to a float
static func to_float(s: String) -> float:
	return s.replace(",", ".").replace("€", "").strip_edges().to_float()


## Chips print as plain integers (e.g. "1000"), currency keeps 2 decimals (e.g. "0.20").
static func format_amount(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return "%d" % int(round(value))
	return "%.2f" % value


## Transforms an array of CardDatas into a string
static func cards_to_string(cards: Array[CardData]) -> String:
	var parts: Array[String] = []
	for c in cards:
		parts.append(str(c))
	return " ".join(parts)

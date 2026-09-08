## Helpers used for formatting in the "_to_string" functions
class_name PokerTextUtil

## Chips print as plain integers (e.g. "1000"), currency keeps 2 decimals (e.g. "0.20").
static func format_amount(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return "%d" % int(round(value))
	return "%.2f" % value


## Transforms an array of PokerCards into a string
static func cards_to_string(cards: Array[PokerCard]) -> String:
	var parts: Array[String] = []
	for c in cards:
		parts.append(str(c))
	return " ".join(parts)

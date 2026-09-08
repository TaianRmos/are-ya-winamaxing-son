## Everything that happened on one street: the cards revealed and the actions taken.
## A street simply won't exist in PokerRound.streets if it never happened.
class_name StreetData
extends RefCounted

var street: PokerEnums.Street
var new_board_cards: Array[PokerCard] = []  # cards revealed ON this street only
var actions: Array[HandAction] = []


func _to_string() -> String:
	var header := "--- %s" % PokerEnums.Street.find_key(street)
	if not new_board_cards.is_empty():
		header += " [%s]" % PokerTextUtil.cards_to_string(new_board_cards)
	header += " ---"

	var lines: Array[String] = [header]
	if actions.is_empty():
		lines.append("  (no actions)")
	else:
		for a in actions:
			lines.append("  %s" % str(a))
	return "\n".join(lines)

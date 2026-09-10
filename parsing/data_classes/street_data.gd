## Everything that happened on one street: the cards revealed and the actions taken.
class_name StreetData
extends RefCounted


var street: PokerEnums.Street
var actions: Array[ActionData] = []

# Cards reveal only on this street
var new_board_cards: Array[CardData] = []


func _to_string() -> String:
	var header := "--- %s" % PokerEnums.Street.find_key(street)
	if not new_board_cards.is_empty():
		header += " [%s]" % ParsingHelper.cards_to_string(new_board_cards)
	header += " ---"

	var lines: Array[String] = [header]
	if actions.is_empty():
		lines.append("  (no actions)")
	else:
		for a in actions:
			lines.append("  %s" % str(a))
	return "\n".join(lines)

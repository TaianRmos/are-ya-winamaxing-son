## Represents one action during showdown
class_name ShowdownData
extends RefCounted


var seat: int = 0
var player_name: String = ""
var position: String = ""
var shown_cards: Array[CardData] = []
var hand_description: String = ""  # e.g. "Two pairs : Kings and 7"
var won_amount: float = 0.0
var is_winner: bool = false


func _to_string() -> String:
	var text := "%s on seat %d" % [player_name, seat]
	if position != "":
		text += " (%s)" % position
	if not shown_cards.is_empty():
		text += " showed [%s]" % ParsingHelper.cards_to_string(shown_cards)
	if hand_description != "":
		text += " (%s)" % hand_description
	if is_winner:
		text += " and won %s" % ParsingHelper.format_amount(won_amount)
	return text

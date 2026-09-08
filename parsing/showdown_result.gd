## One seat's outcome as reported in the *** SUMMARY *** block.
class_name ShowdownResult
extends RefCounted

var seat: int = 0
var player_name: String = ""
var position: String = ""          # "button", "small blind", "big blind", or ""
var shown_cards: Array[PokerCard] = []
var hand_description: String = ""  # e.g. "Two pairs : Kings and 7"
var won_amount: float = 0.0
var is_winner: bool = false
var fold_detail: String = ""       # raw text, e.g. "before Flop" — see note below


func _to_string() -> String:
	var text := "%s on seat %d" % [player_name, seat]
	if position != "":
		text += " (%s)" % position
	if not shown_cards.is_empty():
		text += " showed [%s]" % PokerTextUtil.cards_to_string(shown_cards)
	if hand_description != "":
		text += " (%s)" % hand_description
	if is_winner:
		text += " and won %s" % PokerTextUtil.format_amount(won_amount)
	elif fold_detail != "":
		text += " folded %s" % fold_detail
	return text

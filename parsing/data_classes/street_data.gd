## Everything that happened on one street: the cards revealed and the actions taken.
class_name StreetData
extends RefCounted


var street: PokerEnums.Street
var actions: Array[ActionData] = []

# Cards reveal only on this street
var new_board_cards: Array[CardData] = []


## Returns the profit made by the given player during this street
func get_player_profit(player_name: String = Globals.player_name) -> float:
	var profit: float = 0.0
	var already_payed: float = 0.0
	for action in actions:
		if action.player_name == player_name:
			# Winning profit when collecting
			if action.action_type == PokerEnums.ActionType.COLLECTED:
				profit += action.amount
			
			# When raising, the total_amount doesn't include what was 
			# already payed by the player during that street
			elif action.action_type == PokerEnums.ActionType.RAISE:
				var adding_to_pot: float = action.total_amount - already_payed
				already_payed += adding_to_pot
				profit -= adding_to_pot
			
			# Antes are always lost and are not counted in the pot for other bets
			# e.g. if you posted 50 ante and need to call 200, you will lose 250 total
			# if you posted 50 as small blind and need to call 200
			# you're adding only 150 and lose 200 total
			elif action.action_type == PokerEnums.ActionType.POST_ANTE:
				profit -= action.amount
			
			# Bet, calls and other actions, we lose profit and keep track of what we payed
			else:
				already_payed += action.amount
				profit -= action.amount
	
	return profit


func _to_string() -> String:
	var header := "--- %s" % PokerEnums.Street.find_key(street)
	if not new_board_cards.is_empty():
		header += " [%s]" % ParsingHelper.cards_to_string(new_board_cards)
	header += " ---"

	var lines: Array[String] = [header]
	if actions.is_empty():
		lines.append("  (no actions)")
	else:
		for action in actions:
			lines.append("  %s" % str(action))
	return "\n".join(lines)

## Represents one action made by one player during any street
class_name ActionData
extends RefCounted

var street: PokerEnums.Street
var player_name: String = ""
var action_type: PokerEnums.ActionType

# If the action is "Player X raises 1500 to 2500", amount = 1500, total_amount = 2500
var amount: float = 0.0
var total_amount: float = 0.0
var is_all_in: bool = false

# Used for showdown
var cards: Array[CardData] = []
var description: String = ""

func _to_string() -> String:
	match action_type:
		PokerEnums.ActionType.POST_ANTE:
			return "%s posts ante %s" % [player_name, ParsingHelper.format_amount(amount)]
		PokerEnums.ActionType.POST_SB:
			return "%s posts small blind %s" % [player_name, ParsingHelper.format_amount(amount)]
		PokerEnums.ActionType.POST_BB:
			return "%s posts big blind %s" % [player_name, ParsingHelper.format_amount(amount)]
		PokerEnums.ActionType.FOLD:
			return "%s folds" % player_name
		PokerEnums.ActionType.CHECK:
			return "%s checks" % player_name
		PokerEnums.ActionType.CALL:
			return "%s calls %s%s" % [player_name, ParsingHelper.format_amount(amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.BET:
			return "%s bets %s%s" % [player_name, ParsingHelper.format_amount(amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.RAISE:
			return "%s raises %s to %s%s" % [player_name, ParsingHelper.format_amount(amount), ParsingHelper.format_amount(total_amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.SHOWS:
			return "%s shows [%s] (%s)" % [player_name, ParsingHelper.cards_to_string(cards), description]
		PokerEnums.ActionType.MUCKS:
			return "%s mucks" % player_name
		PokerEnums.ActionType.COLLECTED:
			return "%s collected %s from pot" % [player_name, ParsingHelper.format_amount(amount)]
		PokerEnums.ActionType.UNCALLED_RETURNED:
			return "Uncalled bet (%s) returned to %s" % [ParsingHelper.format_amount(amount), player_name]
		_:
			return "%s <%s>" % [player_name, PokerEnums.ActionType.find_key(action_type)]

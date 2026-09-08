## A single action within one street
class_name HandAction
extends RefCounted

var street: PokerEnums.Street
var player_name: String = ""
var action_type: PokerEnums.ActionType
var amount: float = 0.0        # increment: call/bet size, or raise increment
var total_amount: float = 0.0  # for RAISE: the "to X" total
var is_all_in: bool = false
var cards: Array[PokerCard] = []   # used for SHOWS
var description: String = ""       # used for SHOWS, e.g. "Full of 7 and 8"

func _to_string() -> String:
	match action_type:
		PokerEnums.ActionType.POST_ANTE:
			return "%s posts ante %s" % [player_name, PokerTextUtil.format_amount(amount)]
		PokerEnums.ActionType.POST_SB:
			return "%s posts small blind %s" % [player_name, PokerTextUtil.format_amount(amount)]
		PokerEnums.ActionType.POST_BB:
			return "%s posts big blind %s" % [player_name, PokerTextUtil.format_amount(amount)]
		PokerEnums.ActionType.FOLD:
			return "%s folds" % player_name
		PokerEnums.ActionType.CHECK:
			return "%s checks" % player_name
		PokerEnums.ActionType.CALL:
			return "%s calls %s%s" % [player_name, PokerTextUtil.format_amount(amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.BET:
			return "%s bets %s%s" % [player_name, PokerTextUtil.format_amount(amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.RAISE:
			return "%s raises %s to %s%s" % [player_name, PokerTextUtil.format_amount(amount), PokerTextUtil.format_amount(total_amount), " [ALL-IN]" if is_all_in else ""]
		PokerEnums.ActionType.SHOWS:
			return "%s shows [%s] (%s)" % [player_name, PokerTextUtil.cards_to_string(cards), description]
		PokerEnums.ActionType.MUCKS:
			return "%s mucks" % player_name
		PokerEnums.ActionType.COLLECTED:
			return "%s collected %s from pot" % [player_name, PokerTextUtil.format_amount(amount)]
		PokerEnums.ActionType.UNCALLED_RETURNED:
			return "Uncalled bet (%s) returned to %s" % [PokerTextUtil.format_amount(amount), player_name]
		_:
			return "%s <%s>" % [player_name, PokerEnums.ActionType.find_key(action_type)]

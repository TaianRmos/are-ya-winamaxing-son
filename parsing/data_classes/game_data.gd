## Base class that represents a whole game of poker
class_name GameData
extends RefCounted


var name: String
var rounds: Array[RoundData]
var summary: SummaryData = null


## Returns the amount of money you won/lost playing that game
func get_profits() -> float:
	# If it's a tournament, get the profit from the summary
	if summary:
		return summary.get_profit()
	
	# If it's a CashGame, the profit is the starting stack at the last last hand minus the first hand played
	var starting_stack: float = rounds[0].get_player(Globals.player_name).starting_stack
	var last_stack: float = rounds[rounds.size() - 1].get_player(Globals.player_name).starting_stack
	var last_profit: float = rounds[rounds.size() - 1].get_player_profit()
	return last_stack - starting_stack + last_profit


func _to_string() -> String:
	var lines: Array[String] = []
	ParsingHelper.set_money_ticker("€")
	lines.append(name)
	lines.append("")
	lines.append("---Statistics---")
	lines.append("  Profits: %s" % ParsingHelper.format_amount(get_profits()))
	lines.append("  Amount of hands played: %d" % rounds.size())
	return "\n".join(lines)

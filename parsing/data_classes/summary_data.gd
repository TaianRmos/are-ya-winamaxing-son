## Represents the content of a summary files for tournaments
class_name SummaryData
extends RefCounted

var tournament_name: String = ""
var tournament_id: String = ""
var player_name: String = ""

var buy_in: float = 0.0
var buy_in_rake: float = 0.0
var buy_in_bounty: float = 0.0
var late_registration: bool = false

var rebuy_cost: float = 0.0
var rebuy_cost_rake: float = 0.0
var addon_cost: float = 0.0
var addon_cost_rake: float = 0.0

var your_rebuys: int = 0
var your_addons: int = 0

# Total amount of rebuys/addon by all players in the tournament
var total_rebuys: int = 0
var total_addons: int = 0

var registered_players: int = 0
var mode: PokerEnums.TournamentMode = PokerEnums.TournamentMode.UNKNOWN
var mode_raw: String = ""
var format: PokerEnums.TournamentFormat = PokerEnums.TournamentFormat.UNKNOWN
var format_raw: String = ""

# Can be turbo for expresso
var speed: String = ""

var prizepool: float = 0.0
var start_datetime_str: String = ""
var duration_played_str: String = ""
var duration_played_seconds: int = 0

var finish_place: int = 0
var cashed: bool = false
var won_amount: float = 0.0
var won_bounty: float = 0.0

var raw_text: String = ""


## Returns the profit you made on that tournament
func get_profit() -> float:
	var profit: float = 0.0
	var total_buy_in_cost: float = buy_in + buy_in_rake + buy_in_bounty
	var total_rebuy_cost: float = rebuy_cost + rebuy_cost_rake
	var total_addon_cost: float = addon_cost + addon_cost_rake
	
	var total_cost: float = total_buy_in_cost + (your_rebuys * total_rebuy_cost) + (your_addons * total_addon_cost)
	profit = won_amount + won_bounty - total_cost
	return profit


func _to_string() -> String:
	var lines: Array[String] = []
	lines.append("=== Summary: %s (#%s) ===" % [tournament_name, tournament_id])
	lines.append("Player: %s | Buy-in: %s€%s%s" % [
		player_name,
		ParsingHelper.format_amount(buy_in),
		" + %s€ rake" % ParsingHelper.format_amount(buy_in_rake) if buy_in_rake > 0 else "",
		" + %s€ bounty" % ParsingHelper.format_amount(buy_in_bounty) if buy_in_bounty > 0 else "",
	])
	lines.append("Mode: %s | Format: %s | Registered: %d%s" % [
		mode_raw,
		format_raw,
		registered_players,
		" - Late Registration" if late_registration else ""
	])
	lines.append("Prizepool: %s€ | Started: %s | Played: %s" % [
		ParsingHelper.format_amount(prizepool), start_datetime_str, duration_played_str,
	])
	lines.append("Finished: %d | Cashed: %s%s" % [
		finish_place, str(cashed),
		" (won %s€%s)" % [
			ParsingHelper.format_amount(won_amount),
			" + %s€ bounty" % ParsingHelper.format_amount(won_bounty) if won_bounty > 0 else "",
		] if cashed else "",
	])
	lines.append("Profit: %s€" % ParsingHelper.format_amount(get_profit()))
	return "\n".join(lines)

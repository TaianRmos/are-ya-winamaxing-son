## A fully parsed Winamax round.
class_name PokerRound
extends RefCounted

const STREET_ORDER: Array[PokerEnums.Street] = [
	PokerEnums.Street.PREFLOP,
	PokerEnums.Street.FLOP,
	PokerEnums.Street.TURN,
	PokerEnums.Street.RIVER,
	PokerEnums.Street.SHOWDOWN,
]

var round_id: String = ""
var game_type: PokerEnums.GameType
var variant: String = ""
var small_blind: float = 0.0
var big_blind: float = 0.0
var currency: String = "€"
var datetime_str: String = ""

# Tournament-only fields (default/unused for cash games)
var tournament_name: String = ""
var buy_in: float = 0.0
var buy_in_rake: float = 0.0
var buy_in_bounty: float = 0.0 # only set for knockout tournaments
var level: int = 0

# Now shared by both game types
var ante: float = 0.0

var table_name: String = ""
var max_seats: int = 0
var real_money: bool = false
var button_seat: int = 0
var players: Array[PokerPlayer] = []

var hero_name: String = ""
var hero_cards: Array[PokerCard] = []

var streets: Dictionary[PokerEnums.Street, StreetData] = {} # All data that happened in the street
var board: Array[PokerCard] = [] # final board from the summary

var total_pot: float = 0.0
var rake: float = 0.0
var showdown_results: Array[ShowdownResult] = []

var raw_text: String = ""


func get_street_data(street: PokerEnums.Street) -> StreetData:
	return streets.get(street, null)


func get_player(name: String) -> PokerPlayer:
	for p in players:
		if p.name == name:
			return p
	return null


func went_to_showdown() -> bool:
	return streets.has(PokerEnums.Street.SHOWDOWN)



func _to_string() -> String:
	var lines: Array[String] = []
	var game_label := "CashGame" if game_type == PokerEnums.GameType.CASH_GAME else "Tournament"
	
	lines.append("=== Round #%s (%s) ===" % [round_id, game_label])
	
	if game_type == PokerEnums.GameType.TOURNAMENT:
		var buy_in_str := "%s€ + %s€" % [PokerTextUtil.format_amount(buy_in), PokerTextUtil.format_amount(buy_in_rake)]
		if buy_in_bounty > 0:
			buy_in_str += " + %s€ bounty" % PokerTextUtil.format_amount(buy_in_bounty)
		lines.append("Tournament: \"%s\" | Buy-in: %s€ | Level: %d" % [tournament_name, buy_in_str, level])
	
	var blinds_str := "%s/%s" % [PokerTextUtil.format_amount(small_blind), PokerTextUtil.format_amount(big_blind)]
	if ante > 0:
		blinds_str += " (ante %s)" % PokerTextUtil.format_amount(ante)
	lines.append("Variant: %s | Blinds: %s" % [variant, blinds_str])
	lines.append("Table: '%s' %d-max | Button seat: %d" % [table_name, max_seats, button_seat])
	lines.append("Date: %s" % datetime_str)
	lines.append("")
	
	lines.append("Players:")
	for p in players:
		lines.append("  %s" % str(p))
	lines.append("")
	
	if hero_name != "":
		lines.append("Hero: %s [%s]" % [hero_name, PokerTextUtil.cards_to_string(hero_cards)])
		lines.append("")
	
	for street in STREET_ORDER:
		if streets.has(street):
			lines.append(str(streets[street]))
			lines.append("")
	
	if not board.is_empty():
		lines.append("Board: [%s]" % PokerTextUtil.cards_to_string(board))
	lines.append("Total pot: %s | Rake: %s" % [PokerTextUtil.format_amount(total_pot), PokerTextUtil.format_amount(rake)])
	lines.append("")
	
	if not showdown_results.is_empty():
		lines.append("Summary:")
		for r in showdown_results:
			lines.append("  %s" % str(r))
	
	lines.append("=".repeat(40))
	return "\n".join(lines)

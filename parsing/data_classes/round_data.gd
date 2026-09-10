## Represents one full round of a game with all the actions that happened
class_name RoundData
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
var ante: float = 0.0
var currency: String = "€"
var datetime_str: String = ""

# Tournament-only fields (default/unused for cash games)
var tournament_name: String = ""
var buy_in: float = 0.0
var buy_in_rake: float = 0.0
var buy_in_bounty: float = 0.0 # only set for knockout tournaments
var level: int = 0

var table_name: String = ""
var max_seats: int = 0
var real_money: bool = false
var button_seat: int = 0
var players: Array[PlayerData] = []

# Player who won the round
var hero_name: String = ""
var hero_cards: Array[CardData] = []

# Dictionary of StreetData for every action that happened during each street
var streets: Dictionary[PokerEnums.Street, StreetData] = {}

# Final board given by the summary
var board: Array[CardData] = []

var total_pot: float = 0.0
var rake: float = 0.0
var showdown: Array[ShowdownData] = []

var raw_text: String = ""


func get_street_data(street: PokerEnums.Street) -> StreetData:
	return streets.get(street, null)


func get_player(name: String) -> PlayerData:
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
		var buy_in_str := "%s€ + %s€" % [ParsingHelper.format_amount(buy_in), ParsingHelper.format_amount(buy_in_rake)]
		if buy_in_bounty > 0:
			buy_in_str += " + %s€ bounty" % ParsingHelper.format_amount(buy_in_bounty)
		lines.append("Tournament: \"%s\" | Buy-in: %s€ | Level: %d" % [tournament_name, buy_in_str, level])
	
	var blinds_str := "%s/%s" % [ParsingHelper.format_amount(small_blind), ParsingHelper.format_amount(big_blind)]
	if ante > 0:
		blinds_str += " (ante %s)" % ParsingHelper.format_amount(ante)
	lines.append("Variant: %s | Blinds: %s" % [variant, blinds_str])
	lines.append("Table: '%s' %d-max | Button seat: %d" % [table_name, max_seats, button_seat])
	lines.append("Date: %s" % datetime_str)
	lines.append("")
	
	lines.append("Players:")
	for p in players:
		lines.append("  %s" % str(p))
	lines.append("")
	
	if hero_name != "":
		lines.append("Hero: %s [%s]" % [hero_name, ParsingHelper.cards_to_string(hero_cards)])
		lines.append("")
	
	for street in STREET_ORDER:
		if streets.has(street):
			lines.append(str(streets[street]))
			lines.append("")
	
	if not board.is_empty():
		lines.append("Board: [%s]" % ParsingHelper.cards_to_string(board))
	lines.append("Total pot: %s | Rake: %s" % [ParsingHelper.format_amount(total_pot), ParsingHelper.format_amount(rake)])
	lines.append("")
	
	if not showdown.is_empty():
		lines.append("Summary:")
		for r in showdown:
			lines.append("  %s" % str(r))
	
	lines.append("=".repeat(40))
	return "\n".join(lines)

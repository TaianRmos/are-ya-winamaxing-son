## Parses Winamax "hand" files which correspond to a full round
class_name RoundParser
extends RefCounted


static var current_round: int = 0
static var current_file: String = ""
static var current_line: int = 0


## Parses the given folder
static func parse_folder(path: String) -> Array[RoundData]:
	var rounds: Array[RoundData] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ParserEngine: could not open folder %s" % path)
		return rounds
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and not file_name.ends_with("_summary.txt"):
			current_file = file_name
			rounds.append_array(parse_file(path.path_join(file_name)))
	return rounds


## Parses the given file and creates the rounds
static func parse_file(path: String) -> Array[RoundData]:
	var full_text: String = FileAccess.get_file_as_string(path)
	var normalized: String = full_text.replace("\r\n", "\n")
	normalized = ParsingHelper.rx("\\n{2,}").sub(normalized, "\n\n", true)
	
	var rounds: Array[RoundData] = []
	for block in normalized.split("\n\n"):
		var trimmed := block.strip_edges()
		if not trimmed.is_empty():
			current_round += 1
			rounds.append(_parse_round(trimmed))
	return rounds


## Parses a string with cards into an array of CardData
static func _parse_cards(cards_to_parse: String) -> Array[CardData]:
	var cards: Array[CardData] = []
	for card_str in cards_to_parse.split(" ", false):
		cards.append(CardData.from_string(card_str))
	return cards


## Parses a single round, core of the parsing logic
static func _parse_round(round_text: String) -> RoundData:
	var poker_round := RoundData.new()
	poker_round.raw_text = round_text

	var current_street: PokerEnums.Street = PokerEnums.Street.PREFLOP
	var in_summary := false
	var seen_header := false
	var seen_table := false
	current_line = 0
	
	for raw_line in round_text.split("\n"):
		current_line += 1
		var line := raw_line.strip_edges()
		if line.is_empty():
			continue
		
		if not seen_header:
			_parse_header(line, poker_round)
			seen_header = true
			continue
		
		if not seen_table:
			_parse_table_line(line, poker_round)
			seen_table = true
			continue
		
		if line.begins_with("Seat ") and not in_summary:
			_parse_seat_line(line, poker_round)
			continue
		
		if line.begins_with("***"):
			if line.begins_with("*** SUMMARY ***"):
				in_summary = true
				continue
			var marker := _match_street_marker(line)
			if not marker.is_empty():
				current_street = marker["street"]
				if not poker_round.streets.has(current_street):
					var sd := StreetData.new()
					sd.street = current_street
					for token in marker["new_cards"]:
						sd.new_board_cards.append(CardData.from_string(token))
					poker_round.streets[current_street] = sd
			continue
		
		if in_summary:
			_parse_summary_line(line, poker_round)
			continue
		
		if line.begins_with("Dealt to "):
			_parse_dealt_line(line, poker_round)
			continue
		
		if line.find(" posts ") != -1:
			var blind_action := _parse_blind_line(line, current_street)
			if blind_action:
				poker_round.streets[current_street].actions.append(blind_action)
			continue
		
		var action := _parse_action_line(line, current_street)
		if action:
			poker_round.streets[current_street].actions.append(action)
		else:
			push_warning("ParsingEngine: unrecognized line: %s" % line)
			push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
	
	return poker_round


## Parsing the header of a poker round (first line)
static func _parse_header(line: String, poker_round: RoundData) -> void:
	if line.find("Winamax Poker - Tournament") != -1:
		_parse_tournament_header(line, poker_round)
	else:
		_parse_cashgame_header(line, poker_round)


## Parses the header of a Cash Game
static func _parse_cashgame_header(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch = ParsingHelper.rx("^Winamax Poker - CashGame - HandId: #(\\S+) - (.+?) \\((.+?)\\) - (.+?) UTC$").search(line)
	if matches == null:
		push_warning("ParsingEngine: could not parse cash game header: %s" % line)
		push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
		return
	
	poker_round.game_type = PokerEnums.GameType.CASH_GAME
	poker_round.round_id = matches.get_string(1)
	poker_round.variant = matches.get_string(2)
	_parse_blinds(matches.get_string(3), poker_round)
	poker_round.datetime_str = matches.get_string(4)


## Parses the header of a Tournament
static func _parse_tournament_header(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch = ParsingHelper.rx("^Winamax Poker - Tournament \"(.+?)\" buyIn: (.+?) level: (\\d+) - HandId: #(\\S+) - (.+?) \\((.+?)\\) - (.+?) UTC$").search(line)
	if matches == null:
		push_warning("ParsingEngine: could not parse tournament header: %s" % line)
		push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
		return
	
	poker_round.game_type = PokerEnums.GameType.TOURNAMENT
	poker_round.tournament_name = matches.get_string(1)
	_parse_buy_in(matches.get_string(2), poker_round)
	poker_round.level = int(matches.get_string(3))
	poker_round.round_id = matches.get_string(4)
	poker_round.variant = matches.get_string(5)
	_parse_blinds(matches.get_string(6), poker_round)
	poker_round.datetime_str = matches.get_string(7)


## Parses the blind depending of the format (with or without ante)
static func _parse_blinds(raw: String, poker_round: RoundData) -> void:
	var parts := raw.split("/")
	var values: Array[float] = []
	for p in parts:
		values.append(ParsingHelper.to_float(p))
	
	match values.size():
		2:
			poker_round.ante = 0.0
			poker_round.small_blind = values[0]
			poker_round.big_blind = values[1]
		3:
			poker_round.ante = values[0]
			poker_round.small_blind = values[1]
			poker_round.big_blind = values[2]
		_:
			push_warning("ParsingEngine: unexpected blinds format: %s" % raw)
			push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])


## Parses the buy-in, including Freerolls, rake, and bounties
static func _parse_buy_in(raw: String, hand: RoundData) -> void:
	var parts := raw.split(" + ")
	var values: Array[float] = []
	for p in parts:
		values.append(ParsingHelper.to_float(p))
	
	hand.buy_in = values[0] if values.size() > 0 else 0.0
	hand.buy_in_rake = values[1] if values.size() > 1 else 0.0
	hand.buy_in_bounty = values[2] if values.size() > 2 else 0.0


## Parses the second line of the round which correspond to the table we're playing at
static func _parse_table_line(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch = ParsingHelper.rx("^Table: '(.+)' (\\d+)-max(?: \\((real money|play money)\\))? Seat #(\\d+) is the button$").search(line)
	if matches == null:
		push_warning("ParsingEngine: could not parse table line: %s" % line)
		push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
		return
	
	poker_round.table_name = matches.get_string(1)
	poker_round.max_seats = int(matches.get_string(2))
	poker_round.real_money = matches.get_string(3) == "real money"
	poker_round.button_seat = int(matches.get_string(4))


## Gets the number of the seat and the player sitting
static func _parse_seat_line(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch = ParsingHelper.rx("^Seat (\\d+): (.+) \\((.+)\\)$").search(line)
	if matches == null:
		push_warning("ParsingEngine: could not parse seat line: %s" % line)
		push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
		return
	
	var player := PlayerData.new()
	player.seat = int(matches.get_string(1))
	player.name = matches.get_string(2)
	_parse_seat_stack(matches.get_string(3), player)
	poker_round.players.append(player)


## Handles the stack wether or not the bounty is included
static func _parse_seat_stack(raw: String, player: PlayerData) -> void:
	var parts := raw.split(", ")
	player.starting_stack = ParsingHelper.to_float(parts[0])
	
	if parts.size() > 1:
		var bounty_match: RegExMatch = ParsingHelper.rx("^([\\d.,]+)€? bounty$").search(parts[1])
		if bounty_match:
			player.bounty = ParsingHelper.to_float(bounty_match.get_string(1))
		else:
			push_warning("ParsingEngine: unexpected seat stack suffix: %s" % parts[1])
			push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])


## Parses the hand dealt to the main player
static func _parse_dealt_line(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch = ParsingHelper.rx("^Dealt to (.+?) \\[([^\\]]+)\\]$").search(line)
	if matches == null:
		return
	
	poker_round.hero_name = matches.get_string(1)
	poker_round.hero_cards = _parse_cards(matches.get_string(2))


## Parses the blinds and antes during the round
static func _parse_blind_line(line: String, street: PokerEnums.Street) -> ActionData:
	var matches: RegExMatch = ParsingHelper.rx("^(.+?) posts (small blind|big blind|ante) ([\\d.,]+)€?$").search(line)
	if matches == null:
		return null
	
	var action := ActionData.new()
	action.street = street
	action.player_name = matches.get_string(1)
	match matches.get_string(2):
		"small blind": action.action_type = PokerEnums.ActionType.POST_SB
		"big blind": action.action_type = PokerEnums.ActionType.POST_BB
		"ante": action.action_type = PokerEnums.ActionType.POST_ANTE
	
	action.amount = ParsingHelper.to_float(matches.get_string(3))
	action.total_amount = action.amount
	return action


## Finds the street written on the line
static func _match_street_marker(line: String) -> Dictionary:
	if line.begins_with("*** ANTE/BLINDS ***"):
		return {"street": PokerEnums.Street.PREFLOP, "new_cards": []}
	
	if line.begins_with("*** PRE-FLOP ***"):
		return {"street": PokerEnums.Street.PREFLOP, "new_cards": []}
	
	if line.begins_with("*** FLOP ***"):
		var matches := ParsingHelper.rx("\\[([^\\]]+)\\]").search(line)
		var new_cards: Array[String] = []
		if matches != null:
			for card in matches.get_string(1).split(" ", false):
				new_cards.append(card)
		
		return {"street": PokerEnums.Street.FLOP, "new_cards": new_cards}
	
	if line.begins_with("*** TURN ***"):
		var all_matches := ParsingHelper.rx("\\[([^\\]]+)\\]").search_all(line)
		var new_cards: Array[String] = []
		if all_matches.size() > 1:
			new_cards = [all_matches[1].get_string(1)]
		
		return {"street": PokerEnums.Street.TURN, "new_cards": new_cards}
	
	if line.begins_with("*** RIVER ***"):
		var all_matches := ParsingHelper.rx("\\[([^\\]]+)\\]").search_all(line)
		var new_cards: Array[String] = []
		if all_matches.size() > 1:
			new_cards = [all_matches[1].get_string(1)]
		
		return {"street": PokerEnums.Street.RIVER, "new_cards": new_cards}
	
	if line.begins_with("*** SHOW DOWN ***"):
		return {"street": PokerEnums.Street.SHOWDOWN, "new_cards": []}
	
	return {}


## Gets the action made by the player
static func _parse_action_line(line: String, street: PokerEnums.Street) -> ActionData:
	var matches: RegExMatch
	
	# Folding
	matches = ParsingHelper.rx("^(.+?) folds$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.FOLD
		return action
	
	# Checking
	matches = ParsingHelper.rx("^(.+?) checks$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.CHECK
		return action
	
	# Calling
	matches = ParsingHelper.rx("^(.+?) calls ([\\d.,]+)€?( and is all-in)?$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.CALL
		action.amount = ParsingHelper.to_float(matches.get_string(2))
		action.total_amount = action.amount
		action.is_all_in = matches.get_string(3) != ""
		return action
	
	# Betting
	matches = ParsingHelper.rx("^(.+?) bets ([\\d.,]+)€?( and is all-in)?$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.BET
		action.amount = ParsingHelper.to_float(matches.get_string(2))
		action.total_amount = action.amount
		action.is_all_in = matches.get_string(3) != ""
		return action
	
	# Raising
	matches = ParsingHelper.rx("^(.+?) raises ([\\d.,]+)€? to ([\\d.,]+)€?( and is all-in)?$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.RAISE
		action.amount = ParsingHelper.to_float(matches.get_string(2))
		action.total_amount = ParsingHelper.to_float(matches.get_string(3))
		action.is_all_in = matches.get_string(4) != ""
		return action
	
	# Showing
	matches = ParsingHelper.rx("^(.+?) shows \\[([^\\]]+)\\] \\((.+)\\)$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.SHOWS
		action.cards = _parse_cards(matches.get_string(2))
		action.description = matches.get_string(3)
		return action
	
	# Collecting the pot
	matches = ParsingHelper.rx("^(.+?) collected ([\\d.,]+)€? from (?:the )?(?:side |main )?pot(?:.*)?$").search(line)
	if matches:
		var action := ActionData.new()
		action.street = street
		action.player_name = matches.get_string(1)
		action.action_type = PokerEnums.ActionType.COLLECTED
		action.amount = ParsingHelper.to_float(matches.get_string(2))
		return action
	
	return null


## Parses the summary at the end of the round
static func _parse_summary_line(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch
	
	matches = ParsingHelper.rx("^Total pot ([\\d.,]+)€? \\| (Rake ([\\d.,]+)€?|No rake)$").search(line)
	if matches:
		poker_round.total_pot = ParsingHelper.to_float(matches.get_string(1))
		if matches.get_string(3) == "No rake":
			poker_round.rake = 0.0
		else:
			poker_round.rake = ParsingHelper.to_float(matches.get_string(3))
		return
	
	matches = ParsingHelper.rx("^Board: \\[([^\\]]*)\\]$").search(line)
	if matches:
		poker_round.board = _parse_cards(matches.get_string(1))
		return
	
	if line.begins_with("Seat "):
		_parse_summary_seat_line(line, poker_round)
		return
	
	push_warning("ParsingEngine: unrecognized summary line: %s" % line)
	push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])


## Parses the seat inside the summary block
static func _parse_summary_seat_line(line: String, poker_round: RoundData) -> void:
	var matches: RegExMatch
	matches = ParsingHelper.rx("^Seat (\\d+): (.+?)(?: \\((button|small blind|big blind)\\))? (showed|mucked|collected|won) (.*)$").search(line)
	if matches == null:
		push_warning("ParsingEngine: could not parse summary seat line: %s" % line)
		push_warning("Error happened in file %s round %s line %s" % [current_file, current_round, current_line])
		return
	
	var result := ShowdownData.new()
	result.seat = int(matches.get_string(1))
	result.player_name = matches.get_string(2)
	result.position = matches.get_string(3)
	
	var verb := matches.get_string(4)
	var rest := matches.get_string(5)
	
	match verb:
		"showed":
			matches = ParsingHelper.rx("^\\[([^\\]]+)\\] and (won|lost)(?: ([\\d.,]+)€?)? with (.+)$").search(rest)
			if matches:
				result.shown_cards = _parse_cards(matches.get_string(1))
				result.is_winner = matches.get_string(2) == "won"
				if matches.get_string(3) != "":
					result.won_amount = ParsingHelper.to_float(matches.get_string(3))
				result.hand_description = matches.get_string(4)
		"collected":
			matches = ParsingHelper.rx("^([\\d.,]+)€?$").search(rest)
			if matches:
				result.is_winner = true
				result.won_amount = ParsingHelper.to_float(matches.get_string(1))
		"won":
			matches = ParsingHelper.rx("^([\\d.,]+)€?$").search(rest)
			if matches:
				result.is_winner = true
				result.won_amount = ParsingHelper.to_float(matches.get_string(1))
		"mucked":
			matches = ParsingHelper.rx("^\\[([^\\]]+)\\]").search(rest)
			if matches:
				result.shown_cards = _parse_cards(matches.get_string(1))
	
	poker_round.showdown.append(result)

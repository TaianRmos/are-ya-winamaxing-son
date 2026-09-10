## Parses Winamax tournament summary files
class_name SummaryParser
extends RefCounted


static var current_file: String = ""
static var current_line: int = 0


## Parses a single summary file
static func parse_folder(path: String) -> Array[SummaryData]:
	var summaries: Array[SummaryData] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ParserEngine: could not open folder %s" % path)
		return summaries
	
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and file_name.ends_with("_summary.txt"):
			current_file = file_name
			summaries.append(parse_file(path.path_join(file_name)))
	return summaries


static func parse_file(path: String) -> SummaryData:
	var text := FileAccess.get_file_as_string(path)
	var summary := SummaryData.new()
	current_file = path
	current_line = 0
	summary.raw_text = text
	
	var normalized := text.replace("\r\n", "\n")
	var lines := normalized.split("\n")
	
	for line in lines:
		current_line += 1
		line = line.strip_edges()
		if line.is_empty():
			continue
		
		# Skipping levels and flight id since we don't need them
		if line.begins_with("Levels") or line.begins_with("Flight ID"):
			continue
		
		_parse_line(line, summary)
	
	return summary


## Splits "0.90€ + 0.20€" or "0.90€ + 0.90€ + 0.20€" into up to 3 floats.
static func _split_amounts(raw: String) -> Array[float]:
	var values: Array[float] = []
	for part in raw.split(" + "):
		values.append(ParsingHelper.to_float(part))
	return values


## Parses "1h 2min 6s" / "2min 58s" / "4h 16min 55s" into total seconds.
static func _parse_duration_seconds(raw: String) -> int:
	var total := 0
	var h := ParsingHelper.rx("(\\d+)h").search(raw)
	var m := ParsingHelper.rx("(\\d+)min").search(raw)
	var s := ParsingHelper.rx("(\\d+)s").search(raw)
	if h: total += int(h.get_string(1)) * 3600
	if m: total += int(m.get_string(1)) * 60
	if s: total += int(s.get_string(1))
	return total


## Matches the line with the proper RegEx to parse its content
static func _parse_line(line: String, summary: SummaryData) -> void:
	var matches: RegExMatch
	
	# Header
	matches = ParsingHelper.rx("^Winamax Poker - Tournament summary : (.+)\\((\\d+)\\)( - Late Registration)?$").search(line)
	if matches:
		summary.tournament_name = matches.get_string(1).strip_edges().replace("\\u20ac", "€")
		summary.tournament_id = matches.get_string(2)
		summary.late_registration = matches.get_string(3) != ""
		return
	
	# Player
	matches = ParsingHelper.rx("^Player : (.+)$").search(line)
	if matches:
		summary.player_name = matches.get_string(1)
		return
	
	# Buy-in
	matches = ParsingHelper.rx("^Buy-In : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.buy_in = values[0] if values.size() > 0 else 0.0
		summary.buy_in_rake = values[1] if values.size() > 1 else 0.0
		summary.buy_in_bounty = values[2] if values.size() > 2 else 0.0
		return
	
	# Rebuy
	matches = ParsingHelper.rx("^Rebuy cost : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.rebuy_cost = values[0] if values.size() > 0 else 0.0
		summary.rebuy_cost_rake = values[1] if values.size() > 1 else 0.0
		return
	
	# Addons
	matches = ParsingHelper.rx("^Addon cost : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.addon_cost = values[0] if values.size() > 0 else 0.0
		summary.addon_cost_rake = values[1] if values.size() > 1 else 0.0
		return
	
	# The amount of times you have re-entered
	matches = ParsingHelper.rx("^Your rebuys : (\\d+)$").search(line)
	if matches:
		summary.your_rebuys = int(matches.get_string(1))
		return
	
	# Your addons
	matches = ParsingHelper.rx("^Your addons : (\\d+)$").search(line)
	if matches:
		summary.your_addons = int(matches.get_string(1))
		return
	
	# Total amount of rebuys
	matches = ParsingHelper.rx("^Total rebuys : (\\d+)$").search(line)
	if matches:
		summary.total_rebuys = int(matches.get_string(1))
		return
	
	# Total amount of addons
	matches = ParsingHelper.rx("^Total addons : (\\d+)$").search(line)
	if matches:
		summary.total_addons = int(matches.get_string(1))
		return
	
	# Amount of registered players
	matches = ParsingHelper.rx("^Registered players : (\\d+)$").search(line)
	if matches:
		summary.registered_players = int(matches.get_string(1))
		return
	
	# Game mode
	matches = ParsingHelper.rx("^Mode : (\\w+)$").search(line)
	if matches:
		summary.mode_raw = matches.get_string(1)
		match summary.mode_raw:
			"sng": summary.mode = PokerEnums.TournamentMode.SNG
			"mtt": summary.mode = PokerEnums.TournamentMode.MTT
			_: summary.mode = PokerEnums.TournamentMode.UNKNOWN
		return
	
	# Format of the tournament
	matches = ParsingHelper.rx("^Type : (\\w+)$").search(line)
	if matches:
		summary.format_raw = matches.get_string(1)
		match summary.format_raw:
			"sitngo": summary.format = PokerEnums.TournamentFormat.SIT_N_GO
			"knockout": summary.format = PokerEnums.TournamentFormat.KNOCKOUT
			"normal": summary.format = PokerEnums.TournamentFormat.NORMAL
			_: summary.format = PokerEnums.TournamentFormat.UNKNOWN
		return
	
	# Speed of the tournament (like nitro for expressos)
	matches = ParsingHelper.rx("^Speed : (.+)$").search(line)
	if matches:
		summary.speed = matches.get_string(1)
		return
	
	# Prizepool
	matches = ParsingHelper.rx("^Prizepool : ([\\d.,]+)€?$").search(line)
	if matches:
		summary.prizepool = ParsingHelper.to_float(matches.get_string(1))
		return
	
	# Starting date of the tournament
	matches = ParsingHelper.rx("^Tournament started (.+) UTC$").search(line)
	if matches:
		summary.start_datetime_str = matches.get_string(1)
		return
	
	# Amount of time you played
	matches = ParsingHelper.rx("^You played (.+)$").search(line)
	if matches:
		summary.duration_played_str = matches.get_string(1)
		summary.duration_played_seconds = _parse_duration_seconds(matches.get_string(1))
		return
	
	# Your position at the end
	matches = ParsingHelper.rx("^You finished in (\\d+)\\D+ place$").search(line)
	if matches:
		summary.finish_place = int(matches.get_string(1))
		return
	
	# The amount you won
	matches = ParsingHelper.rx("^You won ([\\d.,]+)?€?(?: \\+ )?(?:Bounty ([\\d.,]+)€?)?$").search(line)
	if matches:
		summary.cashed = true
		if matches.get_string(1) != "":
			summary.won_amount = ParsingHelper.to_float(matches.get_string(1))
		if matches.get_string(2) != "":
			summary.won_bounty = ParsingHelper.to_float(matches.get_string(2))
		return
	
	push_warning("SummaryParser: unrecognized line: %s" % line)
	push_warning("Error happened in file %s line %s" % [current_file, current_line])

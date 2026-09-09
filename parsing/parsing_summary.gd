## Parses Winamax tournament summary files
class_name WinamaxSummaryParser
extends RefCounted

static var _regex_cache: Dictionary = {}
static var current_file: String = ""
static var current_line: int = 0


static func _rx(pattern: String) -> RegEx:
	if not _regex_cache.has(pattern):
		_regex_cache[pattern] = RegEx.create_from_string(pattern)
	return _regex_cache[pattern]


static func _to_float(s: String) -> float:
	return s.replace(",", ".").replace("€", "").strip_edges().to_float()


## Splits "0.90€ + 0.20€" or "0.90€ + 0.90€ + 0.20€" into up to 3 floats.
static func _split_amounts(raw: String) -> Array[float]:
	var values: Array[float] = []
	for part in raw.split(" + "):
		values.append(_to_float(part))
	return values


## Parses "1h 2min 6s" / "2min 58s" / "4h 16min 55s" into total seconds.
static func _parse_duration_seconds(raw: String) -> int:
	var total := 0
	var h := _rx("(\\d+)h").search(raw)
	var m := _rx("(\\d+)min").search(raw)
	var s := _rx("(\\d+)s").search(raw)
	if h: total += int(h.get_string(1)) * 3600
	if m: total += int(m.get_string(1)) * 60
	if s: total += int(s.get_string(1))
	return total


## Parses a single summary file
static func parse_file(path: String) -> PokerSummary:
	var text := FileAccess.get_file_as_string(path)
	var summary := PokerSummary.new()
	current_file = path
	summary.raw_text = text
	
	var normalized := text.replace("\r\n", "\n")
	var lines := normalized.split("\n")
	
	var i := 0
	while i < lines.size():
		current_line += 1
		var line: String = lines[i].strip_edges()
		if line.is_empty():
			i += 1
			continue
		
		# "Levels :" content can be a long bracketed list; skip forward until
		# we've consumed the closing "]", in case it ever wraps onto multiple lines.
		if line.begins_with("Levels"):
			#while i < lines.size() and lines[i].find("]") == -1:
				#i += 1
			i += 1
			continue
		
		_parse_line(line, summary)
		i += 1
	
	return summary


static func parse_folder(path: String) -> Array[PokerSummary]:
	var summaries: Array[PokerSummary] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ParserEngine: could not open folder %s" % path)
		return summaries
	
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and file_name.ends_with("_summary.txt"):
			current_file = file_name
			summaries.append(parse_file(path.path_join(file_name)))
	return summaries


static func _parse_line(line: String, summary: PokerSummary) -> void:
	var matches: RegExMatch
	
	matches = _rx("^Winamax Poker - Tournament summary : (.+)\\((\\d+)\\)( - Late Registration)?$").search(line)
	if matches:
		summary.tournament_name = matches.get_string(1).strip_edges().replace("\\u20ac", "€")
		summary.tournament_id = matches.get_string(2)
		summary.late_registration = matches.get_string(3) != ""
		return
	
	matches = _rx("^Player : (.+)$").search(line)
	if matches:
		summary.player_name = matches.get_string(1)
		return
	
	matches = _rx("^Buy-In : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.buy_in = values[0] if values.size() > 0 else 0.0
		summary.buy_in_rake = values[1] if values.size() > 1 else 0.0
		summary.buy_in_bounty = values[2] if values.size() > 2 else 0.0
		return
	
	matches = _rx("^Rebuy cost : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.rebuy_cost = values[0] if values.size() > 0 else 0.0
		summary.rebuy_cost_rake = values[1] if values.size() > 1 else 0.0
		return
	
	matches = _rx("^Addon cost : (.+)$").search(line)
	if matches:
		var values := _split_amounts(matches.get_string(1))
		summary.addon_cost = values[0] if values.size() > 0 else 0.0
		summary.addon_cost_rake = values[1] if values.size() > 1 else 0.0
		return
	
	matches = _rx("^Your rebuys : (\\d+)$").search(line)
	if matches:
		summary.your_rebuys = int(matches.get_string(1))
		return
	
	matches = _rx("^Your addons : (\\d+)$").search(line)
	if matches:
		summary.your_addons = int(matches.get_string(1))
		return
	
	matches = _rx("^Total rebuys : (\\d+)$").search(line)
	if matches:
		summary.total_rebuys = int(matches.get_string(1))
		return
	
	matches = _rx("^Total addons : (\\d+)$").search(line)
	if matches:
		summary.total_addons = int(matches.get_string(1))
		return
	
	matches = _rx("^Registered players : (\\d+)$").search(line)
	if matches:
		summary.registered_players = int(matches.get_string(1))
		return
	
	matches = _rx("^Mode : (\\w+)$").search(line)
	if matches:
		summary.mode_raw = matches.get_string(1)
		match summary.mode_raw:
			"sng": summary.mode = PokerEnums.TournamentMode.SNG
			"mtt": summary.mode = PokerEnums.TournamentMode.MTT
			_: summary.mode = PokerEnums.TournamentMode.UNKNOWN
		return
	
	matches = _rx("^Type : (\\w+)$").search(line)
	if matches:
		summary.format_raw = matches.get_string(1)
		match summary.format_raw:
			"sitngo": summary.format = PokerEnums.TournamentFormat.SIT_N_GO
			"knockout": summary.format = PokerEnums.TournamentFormat.KNOCKOUT
			"normal": summary.format = PokerEnums.TournamentFormat.NORMAL
			_: summary.format = PokerEnums.TournamentFormat.UNKNOWN
		return
	
	matches = _rx("^Speed : (.+)$").search(line)
	if matches:
		summary.speed = matches.get_string(1)
		return
	
	matches = _rx("^Flight ID : (.+)$").search(line)
	if matches:
		summary.flight_id = matches.get_string(1)
		return
	
	matches = _rx("^Prizepool : ([\\d.,]+)€?$").search(line)
	if matches:
		summary.prizepool = _to_float(matches.get_string(1))
		return
	
	matches = _rx("^Tournament started (.+) UTC$").search(line)
	if matches:
		summary.start_datetime_str = matches.get_string(1)
		return
	
	matches = _rx("^You played (.+)$").search(line)
	if matches:
		summary.duration_played_str = matches.get_string(1)
		summary.duration_played_seconds = _parse_duration_seconds(matches.get_string(1))
		return
	
	matches = _rx("^You finished in (\\d+)\\D+ place$").search(line)
	if matches:
		summary.finish_place = int(matches.get_string(1))
		return
	
	matches = _rx("^You won ([\\d.,]+)?€?(?: \\+ )?(?:Bounty ([\\d.,]+)€?)?$").search(line)
	if matches:
		summary.cashed = true
		if matches.get_string(1) != "":
			summary.won_amount = _to_float(matches.get_string(1))
		if matches.get_string(2) != "":
			summary.won_bounty = _to_float(matches.get_string(2))
		return
	
	push_warning("WinamaxSummaryParser: unrecognized line: %s" % line)
	push_warning("Error happened in file %s line %s" % [current_file, current_line])

class_name Parser
extends RefCounted


static var current_file: String = ""
static var nb_files_to_parse: int = 0
static var nb_files_parsed: int = 0
static var is_parsing: bool = false


## Parses all the data from the history files
static func parse_data() -> Array[GameData]:
	var games: Array[GameData] = []
	nb_files_to_parse = 0
	nb_files_parsed = 0
	is_parsing = true
	var dir := DirAccess.open(Globals.history_folder_path)
	if dir == null:
		push_error("ParserEngine: could not open folder %s" % Globals.history_folder_path)
		return games
	
	# Computes the total amount of files there is to parse
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and not file_name.ends_with("_summary.txt"):
			nb_files_to_parse += 1
	
	# Parses the files to extract the Data
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and not file_name.ends_with("_summary.txt"):
			current_file = file_name
			games.append(_parse_game(Globals.history_folder_path.path_join(file_name)))
			nb_files_parsed += 1
	
	is_parsing = true
	return games


## Returns the percentage of completion during parsing
static func get_percentage_parsed() -> int:
	if not is_parsing:
		return 100
	
	@warning_ignore("integer_division")
	return 100 * nb_files_parsed / nb_files_to_parse


## Parses the data of one game
static func _parse_game(path: String) -> GameData:
	var file_name: String = path.get_file().get_basename()
	var summary_file_path: String = path.get_basename() + "_summary.txt"
	
	var game_data := GameData.new()
	game_data.name = file_name
	game_data.rounds = RoundParser.parse_file(path)
	
	# Parses summary if the file exists
	if FileAccess.file_exists(summary_file_path):
		game_data.summary = SummaryParser.parse_file(summary_file_path)
	
	return game_data

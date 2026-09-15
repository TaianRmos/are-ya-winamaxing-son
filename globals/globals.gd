extends Node


var history_folder_path: String
var accounts: Array[String]
var player_name: String
var game_data: Array[GameData]

var current_file: String = ""
var nb_files_to_parse: int = 0
var nb_files_parsed: int = 0
var is_parsing: bool = false
var was_parsed: bool = false

signal parsing_finished



func _ready() -> void:
	_detect_history_folder()
	if accounts.size() == 1:
		player_name = accounts[0]
		parse_data()


func get_game_data(game_name: String) -> GameData:
	for game in game_data:
		if game.name == game_name:
			return game
	
	push_warning("No game was found with name %s" % game_name)
	return null


func parse_data() -> void:
	var games: Array[GameData] = []
	nb_files_to_parse = 0
	nb_files_parsed = 0
	is_parsing = true
	var dir := DirAccess.open(Globals.history_folder_path)
	if dir == null:
		push_error("ParserEngine: could not open folder %s" % Globals.history_folder_path)
		game_data = games
		was_parsed = true
		is_parsing = false
		parsing_finished.emit()
		return
	
	# Computes the total amount of files there is to parse
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and not file_name.ends_with("_summary.txt"):
			nb_files_to_parse += 1
	
	# Parses the files to extract the Data
	for file_name in dir.get_files():
		if file_name.get_extension() == "txt" and not file_name.ends_with("_summary.txt"):
			current_file = file_name
			games.append(Parser.parse_game(history_folder_path.path_join(file_name)))
			nb_files_parsed += 1
	
	is_parsing = false
	game_data = games
	was_parsed = true
	parsing_finished.emit()


## Returns the percentage of completion during parsing
func get_percentage_parsed() -> int:
	if not is_parsing:
		return 100
	
	@warning_ignore("integer_division")
	return 100 * nb_files_parsed / nb_files_to_parse


## Selects the given account to parse the data
func select_account(account_name: String) -> void:
	history_folder_path = history_folder_path.path_join(account_name).path_join("history")
	player_name = account_name
	parse_data()



## Locates the Winamax hand history folder under AppData and creates the folder path
func _detect_history_folder() -> void:
	var appdata := OS.get_environment("APPDATA")
	if appdata == "":
		push_warning("Could not resolve %APPDATA% environment variable")
		return
	
	var accounts_path := appdata.path_join("winamax/documents/accounts")
	var dir := DirAccess.open(accounts_path)
	if dir == null:
		push_warning("Accounts folder not found at %s" % accounts_path)
		return
	
	# Lists all accounts available
	var accounts_folder: Array[String] = []
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and entry != "." and entry != "..":
			accounts_folder.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	
	if accounts_folder.size() == 1:
		history_folder_path = accounts_path.path_join(accounts_folder[0]).path_join("history")
		accounts = accounts_folder
	elif accounts_folder.size() > 1:
		accounts = accounts_folder
		history_folder_path = accounts_path
	else:
		push_warning("No account folders found in %s" % accounts_path)

extends Node


var history_folder_path: String
var accounts: Array[String]
var game_data: Array[GameData]


func get_game_data(game_name: String) -> GameData:
	for game in game_data:
		if game.name == game_name:
			return game
	
	push_warning("No game was found with name %s" % game_name)
	return null


func _ready() -> void:
	_detect_history_folder()


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
	elif accounts.size() > 1:
		accounts = accounts_folder
		history_folder_path = accounts_path
	else:
		push_warning("No account folders found in %s" % accounts_path)

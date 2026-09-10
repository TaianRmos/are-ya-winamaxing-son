extends Control

@onready var debug_round_text_raw: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextRaw
@onready var debug_round_text_parsed: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextParsed
@onready var round_label: Label = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundLabel
@onready var round_input: LineEdit = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundInput

@onready var debug_summary_text_raw: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextRaw
@onready var debug_summary_text_parsed: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextParsed
@onready var summary_label: Label = $TabMargin/TabContainer/Summaries/ButtonsMargin/VBoxContainer/SummaryLabel
@onready var summary_input: LineEdit = $TabMargin/TabContainer/Summaries/ButtonsMargin/VBoxContainer/SummaryInput

@onready var account_selection_margin: MarginContainer = $AccountSelectionMargin
@onready var tab_margin: MarginContainer = $TabMargin
@onready var accounts_container: VBoxContainer = $AccountSelectionMargin/AccountsContainer

var round_index = 0
var rounds_raw: Array[String]
var rounds: Array[RoundData]

var summary_index = 0
var summaries_raw: Array[String]
var summaries: Array[SummaryData]

var folder_path: String = ""
var account_folders: Array[String] = []

## Locates the Winamax hand history folder under AppData and creates the folder path
func _detect_winamax_history_folder() -> void:
	var appdata := OS.get_environment("APPDATA")
	if appdata == "":
		push_warning("WinamaxLocator: could not resolve %APPDATA% environment variable")
		return
	
	var accounts_path := appdata.path_join("winamax/documents/accounts")
	var dir := DirAccess.open(accounts_path)
	if dir == null:
		push_warning("WinamaxLocator: accounts folder not found at %s" % accounts_path)
		return
	
	# Lists all accounts available
	var accounts: Array[String] = []
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and entry != "." and entry != "..":
			accounts.append(entry)
		entry = dir.get_next()
	dir.list_dir_end()
	
	if accounts.size() == 1:
		folder_path = accounts_path.path_join(accounts[0]).path_join("history")
		account_folders = accounts
	elif accounts.size() > 1:
		account_folders = accounts
		folder_path = accounts_path
	else:
		push_warning("WinamaxLocator: no account folders found in %s" % accounts_path)


func _split_rounds_raw(text: String) -> Array[String]:
	var splitted: Array[String]
	for line in text.split("\n\n", false):
		line = line.strip_edges()
		if line != "":
			splitted.append(line)
	return splitted


func _parse_rounds_in_folder(path: String) -> Array[String]:
	var parsed_rounds_raw: Array[String] = []
	var dir = DirAccess.open(path)
	for file_name in dir.get_files():
		if file_name.ends_with(".txt") and not file_name.ends_with("_summary.txt"):
			var text = FileAccess.get_file_as_string(path.path_join(file_name))
			for round_text in _split_rounds_raw(text):
				parsed_rounds_raw.append(round_text)
	return parsed_rounds_raw


func _parse_summaries_in_folder(path: String) -> Array[String]:
	var parsed_summaries_raw: Array[String] = []
	var dir = DirAccess.open(path)
	for file_name in dir.get_files():
		if file_name.ends_with("_summary.txt"):
			var text = FileAccess.get_file_as_string(path.path_join(file_name))
			parsed_summaries_raw.append(text)
	return parsed_summaries_raw


func _parse_winamax_data() -> void:
	rounds_raw = _parse_rounds_in_folder(folder_path)
	rounds = RoundParser.parse_folder(folder_path)
	if rounds_raw.size() != rounds.size():
		push_error("Not the same amount of rounds parsed: %d raw and %d parsed" % [rounds_raw.size(), rounds.size()])
	
	summaries_raw = _parse_summaries_in_folder(folder_path)
	summaries = SummaryParser.parse_folder(folder_path)
	if summaries_raw.size() != summaries.size():
		push_error("Not the same amount of summaries parsed: %d raw and %d parsed" % [summaries_raw.size(), summaries.size()])
	
	_set_debug_round_text()
	_set_debug_summary_text()


func _select_account() -> void:
	# Enables the account selection and disable the tab
	account_selection_margin.visible = true
	account_selection_margin.process_mode = Node.PROCESS_MODE_INHERIT
	tab_margin.visible = false
	tab_margin.process_mode = Node.PROCESS_MODE_DISABLED
	
	for account in account_folders:
		var button := Button.new()
		button.text = account
		button.pressed.connect(_on_account_button_pressed.bind(account))
		accounts_container.add_child(button)


func _ready() -> void:
	_detect_winamax_history_folder()
	if account_folders.size() == 1:
		_parse_winamax_data()
	else:
		_select_account()


func _set_debug_round_text() -> void:
	debug_round_text_raw.text = rounds_raw[round_index]
	debug_round_text_parsed.text = str(rounds[round_index])
	round_label.text = str(round_index + 1) + " / " + str(rounds_raw.size())


func _set_debug_summary_text() -> void:
	debug_summary_text_raw.text = summaries_raw[summary_index]
	debug_summary_text_parsed.text = str(summaries[summary_index])
	summary_label.text = str(summary_index + 1) + " / " + str(summaries_raw.size())


func _on_account_button_pressed(account: String) -> void:
	folder_path = folder_path.path_join(account).path_join("history")
	_parse_winamax_data()
	account_selection_margin.visible = false
	account_selection_margin.process_mode = Node.PROCESS_MODE_DISABLED
	tab_margin.visible = true
	tab_margin.process_mode = Node.PROCESS_MODE_INHERIT


func _on_previous_round_button_pressed() -> void:
	round_index = (round_index - 1) % rounds_raw.size()
	if round_index < 0:
		round_index += rounds_raw.size()
	_set_debug_round_text()


func _on_next_round_button_pressed() -> void:
	round_index = (round_index + 1) % rounds_raw.size()
	_set_debug_round_text()


func _on_round_input_text_submitted(new_text: String) -> void:
	round_index = int(new_text) - 1
	round_input.text = ""
	_set_debug_round_text()


func _on_previous_summary_button_pressed() -> void:
	summary_index = (summary_index - 1) % summaries_raw.size()
	if summary_index < 0:
		summary_index += summaries_raw.size()
	_set_debug_summary_text()


func _on_next_summary_button_pressed() -> void:
	summary_index = (summary_index + 1) % summaries_raw.size()
	_set_debug_summary_text()


func _on_summary_input_text_submitted(new_text: String) -> void:
	summary_index = int(new_text) - 1
	summary_input.text = ""
	_set_debug_summary_text()

extends Control

@onready var debug_round_text_raw: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextRaw
@onready var debug_round_text_parsed: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextParsed
@onready var round_label: Label = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundLabel
@onready var round_input: LineEdit = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundInput

@onready var debug_summary_text_raw: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextRaw
@onready var debug_summary_text_parsed: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextParsed

@onready var account_selection_margin: MarginContainer = $AccountSelectionMargin
@onready var tab_margin: MarginContainer = $TabMargin
@onready var tab_container: TabContainer = $TabMargin/TabContainer
@onready var accounts_container: VBoxContainer = $AccountSelectionMargin/AccountsContainer

@onready var games_selection_container: VBoxContainer = $GameSelectionMargin/ScrollContainer/GamesSelection
@onready var game_selection_margin: MarginContainer = $GameSelectionMargin


var selected_game: GameData
var round_index = 0
var account_folders: Array[String] = []


func _ready() -> void:
	if Globals.accounts.size() == 1:
		_parse_data()
	else:
		_select_account()


func _parse_data() -> void:
	Globals.game_data = Parser.parse_data()
	for game in Globals.game_data:
		var button := Button.new()
		button.text = game.name
		button.add_theme_font_size_override("font_size", 32)
		button.pressed.connect(_on_select_game_pressed.bind(game.name))
		games_selection_container.add_child(button)


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


func _set_debug_round_text() -> void:
	debug_round_text_raw.text = selected_game.rounds[round_index].raw_text
	debug_round_text_parsed.text = str(selected_game.rounds[round_index])
	round_label.text = str(round_index + 1) + " / " + str(selected_game.rounds.size())


func _set_debug_summary_text() -> void:
	if selected_game.summary:
		debug_summary_text_raw.text = selected_game.summary.raw_text
		debug_summary_text_parsed.text = str(selected_game.summary)
	else:
		debug_summary_text_raw.text = "No summary for this game"
		debug_summary_text_parsed.text = "No summary for this game"


func _on_select_game_pressed(game_name: String) -> void:
	selected_game = Globals.get_game_data(game_name)
	game_selection_margin.visible = false
	game_selection_margin.process_mode = Node.PROCESS_MODE_DISABLED
	tab_margin.visible = true
	tab_margin.process_mode = Node.PROCESS_MODE_INHERIT

	_set_debug_round_text()
	_set_debug_summary_text()


func _on_account_button_pressed(account: String) -> void:
	Globals.history_folder_path = Globals.history_folder_path.path_join(account).path_join("history")
	_parse_data()
	account_selection_margin.visible = false
	account_selection_margin.process_mode = Node.PROCESS_MODE_DISABLED
	tab_margin.visible = true
	tab_margin.process_mode = Node.PROCESS_MODE_INHERIT


func _on_previous_round_button_pressed() -> void:
	round_index = (round_index - 1) % selected_game.rounds.size()
	if round_index < 0:
		round_index += selected_game.rounds.size()
	_set_debug_round_text()


func _on_next_round_button_pressed() -> void:
	round_index = (round_index + 1) % selected_game.rounds.size()
	_set_debug_round_text()


func _on_round_input_text_submitted(new_text: String) -> void:
	round_index = int(new_text) - 1
	round_input.text = ""
	_set_debug_round_text()


func _on_back_button_pressed() -> void:
	game_selection_margin.visible = true
	game_selection_margin.process_mode = Node.PROCESS_MODE_INHERIT
	tab_margin.visible = false
	tab_margin.process_mode = Node.PROCESS_MODE_DISABLED
	round_index = 0
	tab_container.current_tab = 0

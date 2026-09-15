extends Control


@export_file_path("*.tscn") var main_menu_scene_path: String

@onready var debug_round_text_raw: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextRaw
@onready var debug_round_text_parsed: TextEdit = $TabMargin/TabContainer/Rounds/TextMargin/TextSplit/DebugTextParsed
@onready var round_label: Label = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundLabel
@onready var round_input: LineEdit = $TabMargin/TabContainer/Rounds/ButtonsMargin/VBoxContainer/RoundInput

@onready var debug_summary_text_raw: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextRaw
@onready var debug_summary_text_parsed: TextEdit = $TabMargin/TabContainer/Summaries/TextMargin/TextSplit/DebugTextParsed
@onready var stats_text: TextEdit = $TabMargin/TabContainer/Stats/TextMargin/StatsText

@onready var tab_margin: MarginContainer = $TabMargin
@onready var tab_container: TabContainer = $TabMargin/TabContainer

@onready var games_selection_container: VBoxContainer = $GameSelectionMargin/ScrollContainer/GamesSelection
@onready var game_selection_margin: MarginContainer = $GameSelectionMargin


var selected_game: GameData
var round_index = 0


func _ready() -> void:
	if Globals.was_parsed:
		_create_game_selection()
	
	Globals.parsing_finished.connect(_create_game_selection)


## Creates the buttons linked to each game
func _create_game_selection() -> void:
	for game in Globals.game_data:
		var button := Button.new()
		button.text = game.name
		button.add_theme_font_size_override("font_size", 32)
		button.pressed.connect(_on_select_game_pressed.bind(game.name))
		games_selection_container.add_child(button)


## Writes the content of a round in the text edits
func _set_debug_round_text() -> void:
	debug_round_text_raw.text = selected_game.rounds[round_index].raw_text
	debug_round_text_parsed.text = str(selected_game.rounds[round_index])
	round_label.text = str(round_index + 1) + " / " + str(selected_game.rounds.size())


## Writes the content of a summary in the text edits
func _set_debug_summary_text() -> void:
	if selected_game.summary:
		debug_summary_text_raw.text = selected_game.summary.raw_text
		debug_summary_text_parsed.text = str(selected_game.summary)
	else:
		debug_summary_text_raw.text = "No summary for this game"
		debug_summary_text_parsed.text = "No summary for this game"


## Selects the given game and display its content
func _on_select_game_pressed(game_name: String) -> void:
	selected_game = Globals.get_game_data(game_name)
	game_selection_margin.visible = false
	game_selection_margin.process_mode = Node.PROCESS_MODE_DISABLED
	tab_margin.visible = true
	tab_margin.process_mode = Node.PROCESS_MODE_INHERIT
	
	stats_text.text = str(selected_game)
	_set_debug_round_text()
	_set_debug_summary_text()


## Goes to previous round
func _on_previous_round_button_pressed() -> void:
	round_index = (round_index - 1) % selected_game.rounds.size()
	if round_index < 0:
		round_index += selected_game.rounds.size()
	_set_debug_round_text()


## Goes to next round
func _on_next_round_button_pressed() -> void:
	round_index = (round_index + 1) % selected_game.rounds.size()
	_set_debug_round_text()


## Goes to the given round
func _on_round_input_text_submitted(new_text: String) -> void:
	round_index = int(new_text) - 1
	round_input.text = ""
	_set_debug_round_text()


## Goes back to the selection menu
func _on_back_button_pressed() -> void:
	game_selection_margin.visible = true
	game_selection_margin.process_mode = Node.PROCESS_MODE_INHERIT
	tab_margin.visible = false
	tab_margin.process_mode = Node.PROCESS_MODE_DISABLED
	round_index = 0
	tab_container.current_tab = 0


## Goes back to main menu
func _on_go_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)

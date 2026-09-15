extends Control


@export_file_path("*.tscn") var main_menu_scene_path: String

@onready var progress_bar: ProgressBar = $LoadingContainer/VBoxContainer/ProgressBar
@onready var loading_container: CenterContainer = $LoadingContainer
@onready var account_selection_container: MarginContainer = $AccountSelectionContainer
@onready var buttons_container: VBoxContainer = $AccountSelectionContainer/ButtonsContainer


func _ready() -> void:
	Globals.parsing_finished.connect(_on_parsing_finished)
	
	# If more than one account was found, we select one
	if Globals.accounts.size() > 1:
		_create_account_selection()
		_toggle_container_visibility()
	
	# If the loading is too fast, we need to call the 
	# method manually because the signal fired before
	# we had the time to connect to it
	if Globals.get_percentage_parsed() == 100 and Globals.accounts.size() == 1:
		call_deferred("_on_parsing_finished")


## Displays the loading percentage
func _process(_delta: float) -> void:
	progress_bar.value = Globals.get_percentage_parsed()


## Creates a list of buttons to select your account
func _create_account_selection() -> void:
	for account in Globals.accounts:
		var button := Button.new()
		button.text = account
		button.add_theme_font_size_override("font_size", 48)
		button.pressed.connect(_on_account_button_pressed.bind(account))
		buttons_container.add_child(button)


## Makes loading invisible and account selection visible or the opposite
func _toggle_container_visibility() -> void:
	loading_container.visible = !loading_container.visible
	account_selection_container.visible = !account_selection_container.visible
	loading_container.set_process(!loading_container.is_processing())
	account_selection_container.set_process(!account_selection_container.is_processing())


## Selects the given account
func _on_account_button_pressed(account_name: String) -> void:
	Globals.select_account(account_name)
	_toggle_container_visibility()


## Goes to the main menu once the parsing is done
func _on_parsing_finished() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)

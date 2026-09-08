extends Control

@onready var debug_text_raw: TextEdit = $TextMargin/TextSplit/DebugTextRaw
@onready var debug_text_parsed: TextEdit = $TextMargin/TextSplit/DebugTextParsed
@onready var round_label: Label = $ButtonsMargin/VBoxContainer/RoundLabel
@onready var round_input: LineEdit = $ButtonsMargin/VBoxContainer/RoundInput

var hand_index = 0
var hands: Array[String]
var rounds: Array[PokerRound]

const FOLDER_PATH: String = "C:\\Users\\Utilisateur\\AppData\\Roaming\\winamax\\documents\\accounts\\TaianRmos\\history"


func split_hands(text: String) -> Array[String]:
	var splitted: Array[String]
	for line in text.split("\n\n", false):
		line = line.strip_edges()
		if line != "":
			splitted.append(line)
	return splitted


func parse_folder(path: String) -> Array[String]:
	var parsed_hands: Array[String] = []
	var dir = DirAccess.open(path)
	for file_name in dir.get_files():
		if file_name.ends_with(".txt") and not file_name.ends_with("_summary.txt"):
			var text = FileAccess.get_file_as_string(path.path_join(file_name))
			for hand_text in split_hands(text):
				#parsed_hands.append(parse_hand(hand_text))
				parsed_hands.append(hand_text)
	return parsed_hands


func _ready() -> void:
	hands = parse_folder(FOLDER_PATH)
	debug_text_raw.text = hands[hand_index]
	round_label.text = str(hand_index + 1) + " / " + str(len(hands))
	
	rounds = ParsingEngine.parse_folder(FOLDER_PATH)
	debug_text_parsed.text = str(rounds[hand_index])


func _on_previous_button_pressed() -> void:
	hand_index = (hand_index - 1) % len(hands)
	if hand_index < 0:
		hand_index += len(hands)
	
	debug_text_raw.text = hands[hand_index]
	debug_text_parsed.text = str(rounds[hand_index])
	round_label.text = str(hand_index + 1) + " / " + str(len(hands))


func _on_next_button_pressed() -> void:
	hand_index = (hand_index + 1) % len(hands)
	debug_text_raw.text = hands[hand_index]
	debug_text_parsed.text = str(rounds[hand_index])
	round_label.text = str(hand_index + 1) + " / " + str(len(hands))


func _on_hand_input_text_submitted(new_text: String) -> void:
	hand_index = int(new_text) - 1
	round_input.text = ""
	debug_text_raw.text = hands[hand_index]
	debug_text_parsed.text = str(rounds[hand_index])
	round_label.text = str(hand_index + 1) + " / " + str(len(hands))

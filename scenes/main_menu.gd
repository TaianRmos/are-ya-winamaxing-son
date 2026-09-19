extends Control


@export_file_path("*.tscn") var debug_scene_path: String
@export_file_path("*.tscn") var profit_chart_scene_path: String


func _on_go_to_debug_pressed() -> void:
	get_tree().change_scene_to_file(debug_scene_path)


func _on_go_to_profits_pressed() -> void:
	get_tree().change_scene_to_file(profit_chart_scene_path)

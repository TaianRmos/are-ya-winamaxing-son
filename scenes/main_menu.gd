extends Control


@export var debug_scene: PackedScene


func _on_go_to_debug_pressed() -> void:
	get_tree().change_scene_to_packed(debug_scene)

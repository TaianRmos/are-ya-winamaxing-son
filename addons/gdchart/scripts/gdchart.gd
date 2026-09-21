@abstract
class_name GDChart
extends Control


var function: Function


func _ready() -> void:
	for child in get_children():
		if child is Function:
			function = child
			break
	
	if not function and not Engine.is_editor_hint():
		push_error("No function were found by the chart, no data will be drawn. Please add a Function node to the Chart.")

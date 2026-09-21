@tool
class_name GDLineChart
extends GDScatterChart


const GDLine := preload("res://addons/gdchart/scripts/gdline.gd")


func _create_nodes() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	
	var margin_container := MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 60)
	margin_container.add_theme_constant_override("margin_right", 60)
	margin_container.add_theme_constant_override("margin_top", 60)
	margin_container.add_theme_constant_override("margin_bottom", 60)
	
	var grid: GDGrid = GDGrid.new()
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	if not Engine.is_editor_hint():
		grid.material = diagonal_shader.duplicate()
	margin_container.add_child(grid)
	
	var line: GDLine = GDLine.new()
	line.set_anchors_preset(Control.PRESET_FULL_RECT)
	if not Engine.is_editor_hint():
		line.material = swipe_shader.duplicate()
	margin_container.add_child(line)
	
	var scatter: GDScatter = GDScatter.new()
	scatter.set_anchors_preset(Control.PRESET_FULL_RECT)
	if not Engine.is_editor_hint():
		scatter.material = swipe_shader.duplicate()
	margin_container.add_child(scatter)
	
	add_child(margin_container)

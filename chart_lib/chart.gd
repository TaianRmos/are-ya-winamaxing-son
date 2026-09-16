class_name Chart
extends Control


@export_category("Grid Settings")
@export_subgroup("X Axis")
@export var auto_set_x_axis: bool = true
@export var x_min: float = 0.0
@export var x_max: float = 100.0
@export var x_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.ANCHORED
@export var x_anchor_point: float = 0.0
@export var x_center_point: float = 0.0
@export_range(0, 100, 1, "or_greater") var x_sections: int = 4

@export_subgroup("Y Axis")
@export var auto_set_y_axis: bool = true
@export var y_min: float = 0.0
@export var y_max: float = 100.0
@export var y_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.ANCHORED
@export var y_anchor_point: float = 0.0
@export var y_center_point: float = 0.0
@export_range(0, 100, 1, "or_greater") var y_sections: int = 3

@export_subgroup("Label Font")
@export var font: FontFile
@export_range(1, 100, 1, "or_greater", "suffix:px") var font_size: int = 12



func _draw() -> void:
	print("Je draw")


func point_to_pixel_coordinates(p: Vector2, node_size: Vector2) -> Vector2:
	var rx = (p.x - x_min) / (x_max - x_min)
	var ry = (p.y - y_min) / (y_max - y_min)
	return Vector2(rx * node_size.x, node_size.y - ry * node_size.y)

class_name Chart
extends Control


@export_category("Grid Settings")
@export_subgroup("X Axis")
@export var auto_set_x_axis: bool = true
@export var round_x_axis_values: bool = true
@export var x_min: float = 0.0
@export var x_max: float = 100.0
@export var x_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.ANCHORED
@export var x_anchor_point: float = 0.0
@export var x_center_point: float = 0.0
@export_range(0, 100, 1, "or_greater") var x_sections: int = 4

@export_subgroup("Y Axis")
@export var auto_set_y_axis: bool = true
@export var round_y_axis_values: bool = true
@export var y_min: float = 0.0
@export var y_max: float = 100.0
@export var y_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.ANCHORED
@export var y_anchor_position: ChartUtils.AnchorPosition = ChartUtils.AnchorPosition.BOTTOM
@export var y_anchor_point: float = 0.0
@export var y_center_point: float = 0.0
@export_range(0, 100, 1, "or_greater") var y_sections: int = 3

@export_subgroup("Label Font")
@export var font: FontFile
@export_range(1, 100, 1, "or_greater", "suffix:px") var font_size: int = 12


var data_x: Array[float]
var data_y: Array[float]
var data: Array[Vector2] = []


func _ready() -> void:
	data_y = [0.0]
	data_x = [0.0]
	var cumulation: float = 0.0
	
	for i in range(Globals.game_data.size()):
		cumulation += Globals.game_data[i].get_profits()
		data_y.append(cumulation)
		data_x.append(i+1)
	
	if data_x.size() != data_y.size():
		push_error("X and Y axis have not the same amount of values.")
	
	for i in range(data_x.size()):
		data.append(Vector2(data_x[i], data_y[i]))
	
	var max_data_x: float = data_x.max()
	var max_data_y: float = data_y.max()
	var min_data_x: float = data_x.min()
	var min_data_y: float = data_y.min()
	
	# Finding best x axis parameters automatically
	if auto_set_x_axis:
		var offset = abs(max_data_x - min_data_x) * 0.05
		x_max = max_data_x + offset
		if x_axis_mode == ChartUtils.AxisMode.ANCHORED:
			x_min = min_data_x
		else:
			x_min = min_data_x - offset
	
	# Using the user's choice for the x axis
	else:
		if x_axis_mode == ChartUtils.AxisMode.ANCHORED:
			var offset = abs(max_data_x - x_anchor_point) * 0.05
			x_min = x_anchor_point
			x_max = max_data_x + offset
		elif x_axis_mode == ChartUtils.AxisMode.CENTERED:
			var max_distance = max(abs(x_center_point - max_data_x), abs(x_center_point - min_data_x))
			var offset = abs(max_distance - x_center_point) * 0.05
			x_min = x_center_point - max_distance - offset
			x_max = x_center_point + max_distance + offset
	
	# Finding best x axis parameters automatically
	if auto_set_y_axis:
		var offset = abs(max_data_y - min_data_y) * 0.05
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED and y_anchor_position == ChartUtils.AnchorPosition.TOP:
			y_max = max_data_y
		else:
			y_max = max_data_y + offset
		
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED and y_anchor_position == ChartUtils.AnchorPosition.BOTTOM:
			y_min = min_data_y
		else:
			y_min = min_data_y - offset
	
	# Using the user's choice for the y axis
	else:
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED:
			if y_anchor_position == ChartUtils.AnchorPosition.BOTTOM:
				var offset = abs(max_data_y - y_anchor_point) * 0.05
				y_min = y_anchor_point
				y_max = max_data_y + offset
			else:
				var offset = abs(max_data_y - y_anchor_point) * 0.05
				y_min = min_data_y - offset
				y_max = y_anchor_point
		
		elif y_axis_mode == ChartUtils.AxisMode.CENTERED:
			var max_distance = max(abs(y_center_point - max_data_y), abs(y_center_point - min_data_y))
			var offset = abs(max_distance - y_center_point) * 0.05
			y_min = y_center_point - max_distance - offset
			y_max = y_center_point + max_distance + offset


func point_to_pixel_coordinates(p: Vector2, node_size: Vector2) -> Vector2:
	var rx = (p.x - x_min) / (x_max - x_min)
	var ry = (p.y - y_min) / (y_max - y_min)
	return Vector2(rx * node_size.x, node_size.y - ry * node_size.y)

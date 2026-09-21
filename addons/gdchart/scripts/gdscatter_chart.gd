@tool
class_name GDScatterChart
extends GDChart


const GDGrid := preload("res://addons/gdchart/scripts/gdgrid.gd")
const GDScatter := preload("res://addons/gdchart/scripts/gdscatter.gd")


@export_subgroup("X Axis")
@export var auto_set_x_axis: bool = true:
	set(v): auto_set_x_axis = v; _request_update()
@export var round_x_axis_values: bool = true:
	set(v): round_x_axis_values = v; _request_update()
@export var x_min: float = 0.0:
	set(v): x_min = v; _request_update()
@export var x_max: float = 100.0:
	set(v): x_max = v; _request_update()
@export var x_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.ANCHORED:
	set(v): x_axis_mode = v; _request_update()
@export var x_anchor_point: float = 0.0:
	set(v): x_anchor_point = v; _request_update()
@export var x_center_point: float = 0.0:
	set(v): x_center_point = v; _request_update()
@export_range(0, 100, 1, "or_greater") var x_sections: int = 4:
	set(v): x_sections = v; _request_update()

@export_subgroup("Y Axis")
@export var auto_set_y_axis: bool = true:
	set(v): auto_set_y_axis = v; _request_update()
@export var round_y_axis_values: bool = true:
	set(v): round_y_axis_values = v; _request_update()
@export var y_min: float = 0.0:
	set(v): y_min = v; _request_update()
@export var y_max: float = 100.0:
	set(v): y_max = v; _request_update()
@export var y_axis_mode: ChartUtils.AxisMode = ChartUtils.AxisMode.CENTERED:
	set(v): y_axis_mode = v; _request_update()
@export var y_anchor_position: ChartUtils.AnchorPosition = ChartUtils.AnchorPosition.BOTTOM:
	set(v): y_anchor_position = v; _request_update()
@export var y_anchor_point: float = 0.0:
	set(v): y_anchor_point = v; _request_update()
@export var y_center_point: float = 0.0:
	set(v): y_center_point = v; _request_update()
@export_range(0, 100, 1, "or_greater") var y_sections: int = 3:
	set(v): y_sections = v; _request_update()

@export_subgroup("Label Font")
@export var font: FontFile = preload("res://addons/gdchart/assets/SourceSans3-Regular.ttf"):
	set(v): font = v; _request_update()
@export_range(1, 100, 1, "or_greater", "suffix:px") var font_size: int = 12:
	set(v): font_size = v; _request_update()


var data: PackedVector2Array
var _update_queued: bool = false
var _x_min: float
var _x_max: float
var _y_min: float
var _y_max: float


func _ready() -> void:
	_create_nodes()
	super._ready()
	if Engine.is_editor_hint():
		data = _create_mock_data()
	else:
		data = function.get_data()
	set_axis()


func _request_update() -> void:
	if not is_node_ready() or _update_queued:
		return
	
	_update_queued = true
	_update.call_deferred()


func _update() -> void:
	_update_queued = false
	set_axis()
	_destroy_nodes()
	_create_nodes()


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
	margin_container.add_child(grid)
	
	var scatter: GDScatter = GDScatter.new()
	scatter.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_child(scatter)
	
	add_child(margin_container)


func _destroy_nodes() -> void:
	for node in get_children():
		node.queue_free()


func set_axis() -> void:
	var bounds: Dictionary[String, float] = _get_bounds(data)
	var max_data_x: float = bounds["max_x"]
	var max_data_y: float = bounds["max_y"]
	var min_data_x: float = bounds["min_x"]
	var min_data_y: float = bounds["min_y"]
	_x_min = x_min
	_x_max = x_max
	_y_min = y_min
	_y_max = y_max
	
	# Finding best x axis parameters automatically
	if auto_set_x_axis:
		var offset = abs(max_data_x - min_data_x) * 0.05
		_x_max = max_data_x + offset
		if x_axis_mode == ChartUtils.AxisMode.ANCHORED:
			_x_min = min_data_x
		else:
			_x_min = min_data_x - offset
	
	# Using the user's choice for the x axis
	else:
		if x_axis_mode == ChartUtils.AxisMode.ANCHORED:
			var offset = abs(max_data_x - x_anchor_point) * 0.05
			_x_min = x_anchor_point
			_x_max = max_data_x + offset
		elif x_axis_mode == ChartUtils.AxisMode.CENTERED:
			var max_distance = max(abs(x_center_point - max_data_x), abs(x_center_point - min_data_x))
			var offset = abs(max_distance - x_center_point) * 0.05
			_x_min = x_center_point - max_distance - offset
			_x_max = x_center_point + max_distance + offset
	
	# Finding best x axis parameters automatically
	if auto_set_y_axis:
		var offset = abs(max_data_y - min_data_y) * 0.05
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED and y_anchor_position == ChartUtils.AnchorPosition.TOP:
			_y_max = max_data_y
		else:
			_y_max = max_data_y + offset
		
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED and y_anchor_position == ChartUtils.AnchorPosition.BOTTOM:
			_y_min = min_data_y
		else:
			_y_min = min_data_y - offset
	
	# Using the user's choice for the y axis
	else:
		if y_axis_mode == ChartUtils.AxisMode.ANCHORED:
			if y_anchor_position == ChartUtils.AnchorPosition.BOTTOM:
				var offset = abs(max_data_y - y_anchor_point) * 0.05
				_y_min = y_anchor_point
				_y_max = max_data_y + offset
			else:
				var offset = abs(max_data_y - y_anchor_point) * 0.05
				_y_min = min_data_y - offset
				_y_max = y_anchor_point
		
		elif y_axis_mode == ChartUtils.AxisMode.CENTERED:
			var max_distance = max(abs(y_center_point - max_data_y), abs(y_center_point - min_data_y))
			var offset = abs(max_distance - y_center_point) * 0.05
			_y_min = y_center_point - max_distance - offset
			_y_max = y_center_point + max_distance + offset
	
	if _x_min == _x_max:
		push_error("Error: min and max are equal on X axis: min = %s, max = %s" % [_x_min, _x_max])
	if _y_min == _y_max:
		push_error("Error: min and max are equal on y axis: min = %s, max = %s" % [_y_min, _y_max])


func _create_mock_data() -> PackedVector2Array:
	var points: Array[Vector2] = []
	var points_to_create := 20
	var growth := 4.0
	
	var y_lo := minf(y_min, y_max)
	var y_hi := maxf(y_min, y_max)
	var y_range := y_hi - y_lo
	
	for i in points_to_create:
		var t := float(i) / float(points_to_create - 1)
		var curve := (exp(growth * t) - 1.0) / (exp(growth) - 1.0)
		var x := lerpf(x_min, x_max, t)
		var y := lerpf(y_min, y_max, curve)
		points.append(Vector2(x, y))
	
	return PackedVector2Array(points)


func _get_bounds(points: PackedVector2Array) -> Dictionary[String, float]:
	if points.is_empty():
		return { "min_x": 0.0, "min_y": 0.0, "max_x": 0.0, "max_y": 0.0 }
	
	var first := points[0]
	var min_x := first.x
	var max_x := first.x
	var min_y := first.y
	var max_y := first.y
	
	for i in range(1, points.size()):
		var p := points[i]
		if p.x < min_x:
			min_x = p.x
		elif p.x > max_x:
			max_x = p.x
		if p.y < min_y:
			min_y = p.y
		elif p.y > max_y:
			max_y = p.y
	
	return { "min_x": min_x, "min_y": min_y, "max_x": max_x, "max_y": max_y }


func point_to_pixel_coordinates(p: Vector2, node_size: Vector2) -> Vector2:
	var rx = (p.x - _x_min) / (_x_max - _x_min)
	var ry = (p.y - _y_min) / (_y_max - _y_min)
	return Vector2(rx * node_size.x, node_size.y - ry * node_size.y)

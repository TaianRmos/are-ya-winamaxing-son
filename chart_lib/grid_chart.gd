class_name GridChartTemp
extends Control


var chart: ChartTemp
var grid_offset: int = 10
var label_offset := Vector2i(15, 20)


func _ready() -> void:
	chart = get_parent().get_parent() as ChartTemp


func _draw() -> void:
	var x_axis_size: float = (chart.x_max - chart.x_min)
	var y_axis_size: float = (chart.y_max - chart.y_min)
	var x_grid_step: float = x_axis_size / chart.x_sections
	var y_grid_step: float = y_axis_size / chart.y_sections
	
	# Drawing the X sections when centered
	if not chart.auto_set_x_axis and chart.x_axis_mode == ChartUtils.AxisMode.CENTERED:
		draw_x_line(chart.x_center_point)
		for section_index in range(1, ceil(chart.x_sections / 2.0) + 1):
			draw_x_line(chart.x_center_point + x_grid_step * section_index)
			draw_x_line(chart.x_center_point - x_grid_step * section_index)
	
	# Drawing the X sections in the regular case
	else:
		for section_index in range(chart.x_sections + 1):
			draw_x_line(chart.x_min + x_grid_step * section_index)
	
	
	# Drawing the Y sections when centered
	if not chart.auto_set_y_axis and chart.y_axis_mode == ChartUtils.AxisMode.CENTERED:
		draw_y_line(chart.y_center_point)
		for section_index in range(1, ceil(chart.y_sections / 2.0) + 1):
			draw_y_line(chart.y_center_point + y_grid_step * section_index)
			draw_y_line(chart.y_center_point - y_grid_step * section_index)
	
	# Drawing the Y sections from top to bottom when it's necessary
	elif not chart.auto_set_y_axis and chart.y_axis_mode == ChartUtils.AxisMode.ANCHORED \
		 and chart.y_anchor_position == ChartUtils.AnchorPosition.TOP:
		for section_index in range(chart.y_sections + 1):
			draw_y_line(chart.y_max - y_grid_step * section_index)
	
	# Drawing the Y sections in the regular case
	else:
		for section_index in range(chart.y_sections + 1):
			draw_y_line(chart.y_min + y_grid_step * section_index)
	
	# Drawing the border
	draw_x_line(chart.x_min)
	draw_x_line(chart.x_max)
	draw_y_line(chart.y_min)
	draw_y_line(chart.y_max)


func draw_x_line(x: float, color: Color = Color.WHITE) -> void:
	var p1: Vector2 = chart.point_to_pixel_coordinates(Vector2(x, chart.y_min), size)
	var p2: Vector2 = chart.point_to_pixel_coordinates(Vector2(x, chart.y_max), size)
	draw_line(
		p1 - Vector2(0, -grid_offset),
		p2 + Vector2(0, -grid_offset),
		color
	)
	draw_string_aligned(
		chart.font,
		p1 - Vector2(0, -label_offset.y),
		number_to_string(x, chart.round_x_axis_values),
		HORIZONTAL_ALIGNMENT_CENTER,
		chart.font_size
	)


func draw_y_line(y: float, color: Color = Color.WHITE) -> void:
	var p1: Vector2 = chart.point_to_pixel_coordinates(Vector2(chart.x_min, y), size)
	var p2: Vector2 = chart.point_to_pixel_coordinates(Vector2(chart.x_max, y), size)
	draw_line(
		p1 - Vector2(grid_offset, 0),
		p2 + Vector2(grid_offset, 0),
		color
	)
	draw_string_aligned(
		chart.font,
		p1 - Vector2(label_offset.x, 0),
		number_to_string(y, chart.round_y_axis_values),
		HORIZONTAL_ALIGNMENT_RIGHT,
		chart.font_size
	)


func number_to_string(value: float, need_round: bool) -> String:
	if is_equal_approx(value, round(value)) or need_round:
		return str(int(round(value)))
	else:
		return "%.2f" % value


func draw_string_aligned(font: Font, anchor: Vector2, text: String, alignment: HorizontalAlignment, font_size: int = 16, color: Color = Color.WHITE) -> void:
	var label_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var pos := Vector2()
	match alignment:
		HORIZONTAL_ALIGNMENT_LEFT:
			pos.x = anchor.x
		HORIZONTAL_ALIGNMENT_CENTER:
			pos.x = anchor.x - label_size.x / 2.0
		HORIZONTAL_ALIGNMENT_RIGHT:
			pos.x = anchor.x - label_size.x
	pos.y = anchor.y - label_size.y / 2.0 + font.get_ascent(font_size)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

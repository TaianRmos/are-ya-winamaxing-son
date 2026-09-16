class_name GridChart
extends Control


var chart: Chart
var grid_offset: int = 10
var label_offset := Vector2i(15, 20)


func _ready() -> void:
	chart = get_parent().get_parent() as Chart


func _draw() -> void:
	#var x_axis: float = chart.x_anchor_point if chart.x_axis_mode == ChartUtils.AxisMode.ANCHORED else chart.x_center_point
	#var y_axis: float = chart.y_anchor_point if chart.y_axis_mode == ChartUtils.AxisMode.ANCHORED else chart.y_center_point
	#draw_line(
		#chart.point_to_pixel_coordinates(Vector2(x_axis, chart.y_min), size),
		#chart.point_to_pixel_coordinates(Vector2(x_axis, chart.y_max), size),
		#Color.WHITE
	#)
	#draw_line(
		#chart.point_to_pixel_coordinates(Vector2(chart.x_min, y_axis), size),
		#chart.point_to_pixel_coordinates(Vector2(chart.x_max, y_axis), size),
		#Color.WHITE
	#)
	
	var x_axis_size: float = (chart.x_max - chart.x_min)
	var y_axis_size: float = (chart.y_max - chart.y_min)
	
	var x_grid_step: float = x_axis_size / chart.x_sections
	for section_index in range(chart.x_sections + 1):
		var x_line: float = chart.x_min + x_grid_step * section_index
		var p1: Vector2 = chart.point_to_pixel_coordinates(Vector2(x_line, chart.y_min), size)
		var p2: Vector2 = chart.point_to_pixel_coordinates(Vector2(x_line, chart.y_max), size)
		draw_line(
			p1 - Vector2(0, -grid_offset),
			p2 + Vector2(0, -grid_offset),
			Color.WHITE
		)
		draw_string_aligned(
			chart.font,
			p1 - Vector2(0, -label_offset.y),
			number_to_string(x_line),
			HORIZONTAL_ALIGNMENT_CENTER,
			chart.font_size
		)
	
	var y_grid_step: float = y_axis_size / chart.y_sections
	for section_index in range(chart.y_sections + 1):
		var y_line: float = chart.y_min + y_grid_step * section_index
		var p1: Vector2 = chart.point_to_pixel_coordinates(Vector2(chart.x_min, y_line), size)
		var p2: Vector2 = chart.point_to_pixel_coordinates(Vector2(chart.x_max, y_line), size)
		draw_line(
			p1 - Vector2(grid_offset, 0),
			p2 + Vector2(grid_offset, 0),
			Color.WHITE
		)
		draw_string_aligned(
			chart.font,
			p1 - Vector2(label_offset.x, 0),
			number_to_string(y_line),
			HORIZONTAL_ALIGNMENT_RIGHT,
			chart.font_size
		)


func number_to_string(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	else:
		return "%.2f" % value


func draw_string_centered(font: Font, center: Vector2, text: String, font_size: int = 16, color: Color = Color.WHITE) -> void:
	var label_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var pos := Vector2()
	pos.x = center.x - label_size.x / 2.0
	# label_size.y is the font's line height (ascent + descent); baseline sits `ascent` below the top
	pos.y = center.y - label_size.y / 2.0 + font.get_ascent(font_size)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


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

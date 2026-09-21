extends Control


var chart: GDMetricChart


func _format_metric(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return "%d" % int(round(value))
	return "%.2f" % value



func _draw() -> void:
	var metric: String = _format_metric(chart.metric) + chart.unit
	chart.refit(size)
	
	var font := chart.get_font()
	var string_size := font.get_string_size(metric, HORIZONTAL_ALIGNMENT_LEFT, -1, chart.font_size)
	var x := 0.0
	
	match chart.h_align:
		HORIZONTAL_ALIGNMENT_CENTER: x = (size.x - string_size.x) * 0.5
		HORIZONTAL_ALIGNMENT_RIGHT: x = size.x - string_size.x
	
	# draw_string's y is the baseline, so offset by the ascent
	var y := font.get_ascent(chart.font_size)
	draw_string(font, Vector2(x, y), metric, HORIZONTAL_ALIGNMENT_LEFT, -1, chart.font_size, chart.color)

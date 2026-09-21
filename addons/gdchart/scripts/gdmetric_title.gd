extends Control


var chart: GDMetricChart


func _draw() -> void:
	var title: String = str(chart.title)
	chart.refit(size)
	
	var font := chart.get_font()
	var string_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, chart.font_size)
	var x := 0.0
	
	match chart.h_align:
		HORIZONTAL_ALIGNMENT_CENTER: x = (size.x - string_size.x) * 0.5
		HORIZONTAL_ALIGNMENT_RIGHT: x = size.x - string_size.x
	
	# draw_string's y is the baseline, so offset by the ascent
	var y := size.y
	draw_string(font, Vector2(x, y), title, HORIZONTAL_ALIGNMENT_LEFT, -1, chart.font_size, chart.color)

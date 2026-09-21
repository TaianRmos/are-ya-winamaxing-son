extends Control


var chart: GDLineChart


func _ready() -> void:
	chart = get_parent().get_parent() as GDLineChart


func _draw() -> void:
	for i in range(chart.data.size() - 1):
		draw_line(
			chart.point_to_pixel_coordinates(chart.data[i], size),
			chart.point_to_pixel_coordinates(chart.data[i+1], size),
			Color.BLUE_VIOLET
		)

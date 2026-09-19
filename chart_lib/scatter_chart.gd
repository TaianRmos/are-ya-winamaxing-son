class_name ScatterChartTemp
extends Control


var chart: ChartTemp


func _ready() -> void:
	chart = get_parent().get_parent() as ChartTemp


func _draw() -> void:
	for point in chart.data:
		draw_circle(chart.point_to_pixel_coordinates(point, size), 5.0, Color.BLUE_VIOLET)

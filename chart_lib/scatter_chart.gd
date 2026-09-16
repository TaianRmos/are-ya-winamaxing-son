class_name ScatterChart
extends Control


var chart: Chart


func _ready() -> void:
	chart = get_parent().get_parent() as Chart


func _draw() -> void:
	for point in chart.data:
		draw_circle(chart.point_to_pixel_coordinates(point, size), 5.0, Color.RED)

extends Control


var chart: GDScatterChart


func _ready() -> void:
	chart = get_parent().get_parent() as GDScatterChart


func _draw() -> void:
	for point in chart.data:
		draw_circle(chart.point_to_pixel_coordinates(point, size), 5.0, Color.BLUE_VIOLET)

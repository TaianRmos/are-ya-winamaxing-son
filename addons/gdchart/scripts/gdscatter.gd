extends Control


var chart: GDScatterChart
var animation_time := 1.0
var animation_delay := 0.5


func _ready() -> void:
	chart = get_parent().get_parent() as GDScatterChart
	if not Engine.is_editor_hint():
		material.set_shader_parameter("rect_size", size)
		resized.connect(func(): material.set_shader_parameter("rect_size", size))
		_appear()


func _appear() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(material, "shader_parameter/progress", 1.0, animation_time).set_delay(animation_delay)


func _draw() -> void:
	for point in chart.data:
		draw_circle(chart.point_to_pixel_coordinates(point, size), 5.0, Color.BLUE_VIOLET)

extends Control


var chart: GDLineChart
var animation_time := 1.0
var animation_delay := 0.5


func _ready() -> void:
	chart = get_parent().get_parent() as GDLineChart
	if not Engine.is_editor_hint():
		material.set_shader_parameter("rect_size", size)
		resized.connect(func(): material.set_shader_parameter("rect_size", size))
		_appear()


func _appear() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(material, "shader_parameter/progress", 1.0, animation_time).set_delay(animation_delay)


func _draw() -> void:
	for i in range(chart.data.size() - 1):
		draw_line(
			chart.point_to_pixel_coordinates(chart.data[i], size),
			chart.point_to_pixel_coordinates(chart.data[i+1], size),
			Color.BLUE_VIOLET
		)

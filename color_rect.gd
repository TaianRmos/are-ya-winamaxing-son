extends Control


@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	material.set_shader_parameter("rect_size", size)
	resized.connect(func(): material.set_shader_parameter("rect_size", size))
	appear()


func appear() -> void:
	var tw: Tween = create_tween()
	tw.set_parallel()
	tw.tween_property(material, "shader_parameter/progress", 1.0, 5.0)


func _draw() -> void:
	draw_line(Vector2(0, 1080), Vector2(1920, 0), Color.WHITE)
	draw_circle(Vector2(0, 0), 500, Color.WHITE)

class_name Function
extends Node


func get_data() -> PackedVector2Array:
	return PackedVector2Array(data())


func get_metric() -> float:
	return metric()


func data() -> Array[Vector2]:
	return []


func metric() -> float:
	return 0.0

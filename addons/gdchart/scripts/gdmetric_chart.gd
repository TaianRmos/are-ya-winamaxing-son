@tool
class_name GDMetricChart
extends GDChart


const GDMetric = preload("res://addons/gdchart/scripts/gdmetric.gd")
const GDMetricTitle = preload("res://addons/gdchart/scripts/gdmetric_title.gd")

@export var title: String = "Metric":
	set(v): title = v; _request_update()
@export var unit: String = "":
	set(v): unit = v; _request_update()
@export var font: Font:
	set(v): font = v; _request_update()
@export var color := Color.WHITE:
	set(v): color = v; _request_update()
@export var h_align := HORIZONTAL_ALIGNMENT_CENTER:
	set(v): h_align = v; _request_update()
@export var min_font_size := 4
@export var max_font_size := 512


var font_size := 16
var metric_node: GDMetric
var metric: float
var _update_queued: bool = false

var panel: Panel
var margin_container: MarginContainer


func _ready() -> void:
	_create_nodes()
	super._ready()
	if Engine.is_editor_hint():
		metric = 1512.50
	else:
		metric = function.get_metric()


func _request_update() -> void:
	if not is_node_ready() or _update_queued:
		return
	
	_update_queued = true
	_update.call_deferred()


func _update() -> void:
	_update_queued = false
	_destroy_nodes()
	_create_nodes()


func _create_nodes() -> void:
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	
	margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 60)
	margin_container.add_theme_constant_override("margin_right", 60)
	margin_container.add_theme_constant_override("margin_top", 60)
	margin_container.add_theme_constant_override("margin_bottom", 60)
	
	var vbox_container := VBoxContainer.new()
	vbox_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var metric_title: GDMetricTitle = GDMetricTitle.new()
	metric_title.set_anchors_preset(Control.PRESET_FULL_RECT)
	metric_title.size_flags_vertical = Control.SIZE_EXPAND_FILL
	metric_title.chart = self
	vbox_container.add_child(metric_title)
	
	var metric_number: GDMetric = GDMetric.new()
	metric_number.set_anchors_preset(Control.PRESET_FULL_RECT)
	metric_number.size_flags_vertical = Control.SIZE_EXPAND_FILL
	metric_number.size_flags_stretch_ratio = 3.0
	metric_number.chart = self
	vbox_container.add_child(metric_number)
	
	margin_container.add_child(vbox_container)
	add_child(margin_container)


func _destroy_nodes() -> void:
	panel.queue_free()
	margin_container.queue_free()


func refit(metric_size: Vector2) -> void:
	if metric_size.x <= 0.0 or metric_size.y <= 0.0:
		return
	
	var f := get_font()
	var lo := min_font_size
	var hi := max_font_size
	# Binary search for the largest size that fits in both dimensions
	while lo < hi:
		var mid := (lo + hi + 1) >> 1
		var s := f.get_string_size(str(metric), HORIZONTAL_ALIGNMENT_LEFT, -1, mid)
		if s.x <= metric_size.x and s.y <= metric_size.y:
			lo = mid
		else:
			hi = mid - 1
	font_size = lo


func get_font() -> Font:
	return font if font else get_theme_default_font()

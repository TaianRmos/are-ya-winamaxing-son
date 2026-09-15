extends Control


@onready var chart: Chart = $MarginContainer/MarginContainer/Chart


func _ready() -> void:
	if Globals.was_parsed:
		draw_chart()
	
	Globals.parsing_finished.connect(draw_chart)


func draw_chart() -> void:
	var cumulative_profits: Array[float] = [0.0]
	var x_axis: Array[int] = [0]
	var cumulation: float = 0.0
	
	for i in range(Globals.game_data.size()):
		cumulation += Globals.game_data[i].get_profits()
		cumulative_profits.append(cumulation)
		x_axis.append(i+1)
	
	var profit_function := Function.new(
		x_axis,
		cumulative_profits,
		"Profit Chart",
		{
			type = Function.Type.LINE,
			marker = Function.Marker.CIRCLE,
			color = Color("399dfdff"),
			interpolation = Function.Interpolation.SPLINE,
		}
	)
	
	var props := ChartProperties.new()
	props.title = "Bankroll over time"
	props.interactive = true
	props.smooth_domain = true
	props.draw_origin = true
	
	chart.plot([profit_function], props)

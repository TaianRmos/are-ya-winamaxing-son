class_name ChartFunctionTemp
extends Control


var chart: ChartTemp


func _ready() -> void:
	chart = get_parent().get_parent() as ChartTemp
	var cumulative_profits: Array[float] = [0.0]
	var x_axis: Array[float] = [0]
	var cumulation: float = 0.0
	
	for i in range(Globals.game_data.size()):
		cumulation += Globals.game_data[i].get_profits()
		cumulative_profits.append(cumulation)
		x_axis.append(i+1)
	
	chart.data_x = x_axis
	chart.data_y = cumulative_profits

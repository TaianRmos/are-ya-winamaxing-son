class_name ProfitFunction
extends Function


func data() -> Array[Vector2]:
	var profits: Array[Vector2] = [Vector2(0.0, 0.0)]
	var cumulation: float = 0.0
	
	for i in range(Globals.game_data.size()):
		cumulation += Globals.game_data[i].get_profits()
		profits.append(Vector2(i+1, cumulation))
	
	return profits


func metric() -> float:
	var profits: float = 0.0
	
	for i in range(Globals.game_data.size()):
		profits += Globals.game_data[i].get_profits()
	
	return profits

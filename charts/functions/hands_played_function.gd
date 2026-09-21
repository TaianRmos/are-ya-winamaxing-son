extends Function


func metric() -> float:
	var hands: int = 0
	for game in Globals.game_data:
		hands += game.rounds.size()
	return hands

## Shared enums for the poker hand model.
class_name PokerEnums

enum GameType {
	CASH_GAME,
	TOURNAMENT 
}

enum Street {
	PREFLOP,
	FLOP,
	TURN,
	RIVER,
	SHOWDOWN
}

enum Suit {
	SPADES,
	CLUBS,
	DIAMONDS,
	HEARTS
}

enum ActionType {
	POST_ANTE,
	POST_SB,
	POST_BB,
	FOLD,
	CHECK,
	CALL,
	BET,
	RAISE,
	SHOWS,
	MUCKS,
	COLLECTED,
	UNCALLED_RETURNED,
}

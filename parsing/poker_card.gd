## Class representing a playing card
## e.g. "Ah" -> rank 14 (Ace), suit HEARTS.
class_name PokerCard
extends RefCounted

## Rank of the card, from 2 to 14 with 11=J, 12=Q...
var rank: int = 0

## Suit of the card
var suit: PokerEnums.Suit

const CHAR_TO_RANK: Dictionary[String, int] = {
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8,
	"9": 9, "T": 10, "J": 11, "Q": 12, "K": 13, "A": 14,
}

const RANK_TO_CHAR: Dictionary[int, String] = {
	2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8",
	9: "9", 10: "T", 11: "J", 12: "Q", 13: "K", 14: "A",
}

const CHAR_TO_SUIT: Dictionary[String, PokerEnums.Suit] = {
	"s": PokerEnums.Suit.SPADES,
	"c": PokerEnums.Suit.CLUBS,
	"d": PokerEnums.Suit.DIAMONDS,
	"h": PokerEnums.Suit.HEARTS,
}

const SUIT_TO_CHAR: Dictionary[PokerEnums.Suit, String] = {
	PokerEnums.Suit.SPADES: "s",
	PokerEnums.Suit.CLUBS: "c",
	PokerEnums.Suit.DIAMONDS: "d",
	PokerEnums.Suit.HEARTS: "h",
}

## Creates a PokerCard from a string
static func from_string(card_str: String) -> PokerCard:
	var card := PokerCard.new()
	var card_str_clean: String = card_str.strip_edges()
	card.rank = CHAR_TO_RANK.get(card_str_clean.substr(0, 1), 0)
	card.suit = CHAR_TO_SUIT.get(card_str_clean.substr(1, 1), -1)
	
	if card.rank == 0 or card.suit == -1:
		push_warning("Unrecognized card: " + card_str)
	
	return card


## Transform a PokerCard to the String version
func _to_string() -> String:
	return "%s%s" % [RANK_TO_CHAR.get(rank, "?"), SUIT_TO_CHAR.get(suit, "?")]

## Represents a Player at the table
class_name PokerPlayer
extends RefCounted

var name: String = ""
var seat: int = 0
var starting_stack: float = 0.0
var bounty: float = 0.0


func _to_string() -> String:
	var text := "%s on seat %d, stack: %s" % [name, seat, PokerTextUtil.format_amount(starting_stack)]
	if bounty > 0:
		text += " (bounty %s)" % PokerTextUtil.format_amount(bounty)
	return text

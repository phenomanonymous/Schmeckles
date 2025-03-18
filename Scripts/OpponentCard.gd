extends Node2D

var hand_position
#var card_slot_card_is_in
var card_value
var card_suit

var ValueLabel
var SuitLabel

func _ready():
	ValueLabel = $Value
	SuitLabel = $Suit

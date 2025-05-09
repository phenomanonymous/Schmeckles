extends Node2D

#const HAND_COUNT = 7
const CARD_WIDTH = 100
const HAND_Y_POSITION = 0
const DEFAULT_CARD_MOVE_SPEED = 0.1

var opponent_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready():
	center_screen_x = get_viewport().size.x / 2


func add_card_to_hand(card, speed):
	if card not in opponent_hand:
		card.SuitLabel.text = card.card_suit
		card.ValueLabel.text = card.card_value
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)

func update_hand_positions(speed):
	for i in range(opponent_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = opponent_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var x_offset = (opponent_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x - index * CARD_WIDTH + x_offset / 2
	return x_position

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

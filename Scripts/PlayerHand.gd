extends Node2D

#const HAND_COUNT = 7
const CARD_WIDTH = 100
const HAND_Y_POSITION = 1080
const DEFAULT_CARD_MOVE_SPEED = 0.1

var player_hand = []
var center_screen_x

############################################
##### borrowed from godot_ui_components repo
@export var time_multiplier: float = 2.0
var time: float = 0.0
var sine_offset_mult: float = 0.1
############################################

# Called when the node enters the scene tree for the first time.
func _ready():
	center_screen_x = get_viewport().size.x / 2


func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_position

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Idle animation of card y positions to be more visually interesting
	time += delta
	for i in range(player_hand.size()):
		var c = player_hand[i]
		var val: float = sin(i + (time * time_multiplier))
		c.position.y += val * sine_offset_mult
		#print(c)
		#print(val)
		#print(c.position)
	pass

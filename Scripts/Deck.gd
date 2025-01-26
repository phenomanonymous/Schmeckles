extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.5

var player_deck = ["AoS", "AoS", "AoS"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#print($Area2D.collision_mask)
	$RichTextLabel.text = str(player_deck.size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	# If player drew the last card in the deck, disable the deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$DeskSprite.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	#for i in range(player_deck.size()):
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)

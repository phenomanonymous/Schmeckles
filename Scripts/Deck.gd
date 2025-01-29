extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.5
const STARTING_HAND_SIZE = 7

#var player_deck = []
#var player_deck = ["Spades 1", "Spades 2", "Spades 3"]
var player_deck = ["Clubs 1","Clubs 2","Clubs 3","Clubs 4","Clubs 5","Clubs 6","Clubs 7","Clubs 8","Clubs 9","Clubs 10","Clubs 11","Clubs 12","Clubs 13","Diamonds 1","Diamonds 2","Diamonds 3","Diamonds 4","Diamonds 5","Diamonds 6","Diamonds 7","Diamonds 8","Diamonds 9","Diamonds 10","Diamonds 11","Diamonds 12","Diamonds 13","Hearts 1","Hearts 2","Hearts 3","Hearts 4","Hearts 5","Hearts 6","Hearts 7","Hearts 8","Hearts 9","Hearts 10","Hearts 11","Hearts 12","Hearts 13","Spades 1","Spades 2","Spades 3","Spades 4","Spades 5","Spades 6","Spades 7","Spades 8","Spades 9","Spades 10","Spades 11","Spades 12","Spades 13"]
var card_database_reference
var drawn_card_this_turn = false
var played_card_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#for suit in ["Clubs", "Diamonds", "Hearts", "Spades"]:
		#for value in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13']:
			#name = str(suit, " ", value)
			#print(name)
			#player_deck.append(name)
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func draw_card():
	if drawn_card_this_turn:
		return
	
	drawn_card_this_turn = true
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	# If player drew the last card in the deck, disable the deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$DeckSprite.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/Playing Cards Pixelart Asset Pack/Sprites/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	#new_card.get_node("Value").text = card_database_reference.CARDS[card_drawn_name][0]
	#new_card.get_node("Suit").text = card_database_reference.CARDS[card_drawn_name][1]
	new_card.card_value = card_database_reference.CARDS[card_drawn_name][0]
	new_card.card_suit = card_database_reference.CARDS[card_drawn_name][1]
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

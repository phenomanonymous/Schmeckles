extends Node

const CARD_MOVE_SPEED = 0.2
const CARD_SMALLER_SCALE = 0.6

var battle_timer
var discard_pile
var opponent_hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opponent_hand = $"../OpponentHand".opponent_hand
	discard_pile = $"../CardSlot"
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	opponent_turn()

func _on_card_manager_game_over() -> void:
	$"../TurnLabel".text = "Player wins!"
	end_game()

#func _on_deck_player_turn_ended() -> void:
	#opponent_turn()

func _on_input_manager_player_turn_ended() -> void:
	opponent_turn()

func _on_card_manager_player_turn_ended() -> void:
	opponent_turn()

#func _on_end_player_turn_signal() -> void:
	#opponent_turn()

func opponent_turn():
	$"../TurnLabel".text = "Opponent's turn"
	# Wait 1 second
	battle_timer.start()
	await battle_timer.timeout
	
	choose_and_play_card()
	
	if opponent_hand.size() == 0:
		$"../TurnLabel".text = "Ace wins!"
		end_game()
	else:
		end_opponent_turn()

func print_all_properties(input_node):
	print ("\nNode Property List for node: ", input_node.name)
	var property_list = input_node.get_property_list()
	for prop in property_list:
		print (prop.name, get(prop.name))
	print("\n")

func choose_and_play_card():
	var card_to_play
	var reason
	var value_dict = {'1':'Ace', '2':'Two', '3':'Three', '4':'Four', '5':'Five', '6':'Six', '7':'Seven', '8':'Eight', '9':'Nine', '10':'Ten', '11':'Jack', '12':'Queen', '13':'King'}
	
	# use some kind of priority system. decide the priority of cards based on how much power/playability they may have
	
	# discard pile is empty -- start of game, or potential special case later on?
	if discard_pile.card_in_slot.size() == 0:
	#if discard_pile.card_in_slot:
		card_to_play = opponent_hand[0]
		reason = "discard pile is empty, playing any card"
	else:
		var top_card = discard_pile.card_in_slot[-1]
		for card in opponent_hand:
			var results = global_scripts.validate_card_move(card, discard_pile)
			if results[1]:
				card_to_play = card
				reason = results[2]
			##print(results)
			##card.SuitLabel.text = str(results[1])
			##print_all_properties(card)
			#if card.card_suit == top_card.card_suit:
				#card_to_play = card
				##print("suit match " + card.name)
			#elif card.card_value == top_card.card_value:
				#card_to_play = card
				##print("value match " + card.name)
		if card_to_play == null:
			print("no match")
			$"../Deck".draw_card("opponent")
			# Say the played card in speech bubble
			$"../Ace/SpeechBubble".text = "[right]Guess I'll draw...[/right]"
			return
	
	# Say the played card in speech bubble
	$"../Ace/SpeechBubble".text = "[right]" + value_dict[card_to_play.card_value] + " of " + card_to_play.card_suit + "[/right]"
	$"../Ace/ValidationLabel".text = reason
	
	card_to_play.z_index = -1
	
	
	# Play the card decided above
	if discard_pile.card_in_slot:
		#print(card_slot_found.card_in_slot)
		for card in discard_pile.card_in_slot:
			card.rotation += 15
			card.z_index -= 1
	card_to_play.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
	discard_pile.card_in_slot.append(card_to_play)
	
	#for card in discard_pile.card_in_slot:
		#print(card.card_value + card.card_suit + ":" + str(card.z_index))
	
	# Animate card into position
	var tween = get_tree().create_tween()
	tween.tween_property(card_to_play, "position", $"../CardSlot".position, CARD_MOVE_SPEED)
	card_to_play.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponent hand
	$"../OpponentHand".remove_card_from_hand(card_to_play)

func end_opponent_turn():
	# End turn
	# Reset player deck draw
	$"../TurnLabel".text = "Player's turn"
	pass

func end_game():
	$"../Deck/Area2D/CollisionShape2D".disabled = true
	$"../Deck/DeckSprite".visible = false
	$"../Deck/RichTextLabel".visible = false
	for card in $"../PlayerHand".player_hand:
		card.get_node("Area2D/CollisionShape2D").disabled = true

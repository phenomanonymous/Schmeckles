extends Node2D

signal player_turn_ended
signal game_over

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const CARD_SMALLER_SCALE = 0.6

var screen_size
var card_being_dragged
var is_hovered_on_card
var player_hand_reference
var ace_rules

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	ace_rules = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func finish_drag():
	card_being_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = raycast_check_for_card_slot()
	var valid_move
	var reason
	if card_slot_found:
		var results = validate_card_move(card_being_dragged, card_slot_found)
		valid_move = results[0]
		reason = results[1]
	
	if reason:
		print(reason)
	
	if valid_move == true:
		card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
		card_being_dragged.z_index = -1
		card_being_dragged.card_slot_card_is_in = card_slot_found
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		if card_slot_found.card_in_slot:
			#print(card_slot_found.card_in_slot)
			for card in card_slot_found.card_in_slot:
				card.rotation += 15
				card.z_index -= 1
		#card_slot_found.card_in_slot = true
		#card_slot_found.card_in_slot = card_being_dragged
		card_slot_found.card_in_slot.append(card_being_dragged)
		
		for card in card_slot_found.card_in_slot:
			print(card.card_value + card.card_suit + ":" + str(card.z_index))
			
		if player_hand_reference.player_hand.size() == 0:
			game_over.emit()
		else:
			player_turn_ended.emit()
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null

func validate_card_move(card_being_dragged, card_slot_found):
	# check if we are finishing the drag over a card slot, aka a valid area to place the card
	var valid_move = false
	var reason
	
	if not card_slot_found.card_in_slot:
		# Card dropped in empty slot
		valid_move = true
	elif card_slot_found.card_in_slot[-1].card_value == card_being_dragged.card_value:
		# values match
		valid_move = true
	elif card_slot_found.card_in_slot[-1].card_suit == card_being_dragged.card_suit:
		# suits match
		valid_move = true
	
	#for rule in ace_rules:
		#if rule
	
	# Rules for non-empty discard piles
	if card_slot_found.card_in_slot.size() > 0:
		# Lonely Hearts
		if (card_slot_found.card_in_slot.size() >= 2 and card_slot_found.card_in_slot[-1].card_suit == "Hearts" and card_slot_found.card_in_slot[-2].card_suit != "Hearts") or (card_slot_found.card_in_slot.size() == 1 and card_slot_found.card_in_slot[-1].card_suit == "Hearts"):
			# Lonely Heart on the discard pile
			if card_being_dragged.card_suit != "Hearts":
				valid_move = false
				reason = "You can't create a Lonely Heart. Hearts must be paired with at least one other Hearts card."
		# Top Ace
		if card_slot_found.card_in_slot[-1].card_value == "1":
			# Aces Fly Solo
			if card_being_dragged.card_value == "1":
				valid_move = false
				reason = "Ace's fly solo, you can't group them together like that"
		# Top Deuce
		if card_slot_found.card_in_slot[-1].card_value == "2":
			pass
		# Top Three
		if card_slot_found.card_in_slot[-1].card_value == "3":
			# Three's a crowd
			if (card_slot_found.card_in_slot.size() >= 2 and card_slot_found.card_in_slot[-1].card_value == "3" and card_slot_found.card_in_slot[-2].card_value == "3"):
				valid_move = false
				reason = "Two's company, three's a crowd. But THREE threes? That's like putting a hat on a hat."
		# Top Four
		if card_slot_found.card_in_slot[-1].card_value == "4":
			pass
		# Top Five
		if card_slot_found.card_in_slot[-1].card_value == "5":
			pass
		# Top Six
		if card_slot_found.card_in_slot[-1].card_value == "6":
			# Mark of the Beast
			if (card_slot_found.card_in_slot.size() >= 2 and card_slot_found.card_in_slot[-1].card_value == "6" and card_slot_found.card_in_slot[-2].card_value == "6"):
				valid_move = false
				reason = "666? That's the mark of the beast! Best not to bring any bad luck into this..."
		# Top Seven
		if card_slot_found.card_in_slot[-1].card_value == "7":
			pass
		# Top Eight
		if card_slot_found.card_in_slot[-1].card_value == "8":
			pass
		# Top Nine
		if card_slot_found.card_in_slot[-1].card_value == "9":
			# Because Seven Ate Nine
			if card_being_dragged.card_value == "7":
				valid_move = true
				reason = "You can always plays Sevens on Nines, because Seven Ate Nine!"
		# Top Ten
		if card_slot_found.card_in_slot[-1].card_value == "10":
			pass
		# Top Jack
		if card_slot_found.card_in_slot[-1].card_value == "11":
			pass
		# Top Queen
		if card_slot_found.card_in_slot[-1].card_value == "12":
			if card_being_dragged.card_value == "13":
				valid_move = true
				reason = "Every Queen needs her King"
		# Top King
		if card_slot_found.card_in_slot[-1].card_value == "13":
			if card_being_dragged.card_value == "12":
				valid_move = true
				reason = "Every King needs his Queen"
	
	# Rules ideas
	# some sort of math based things, like primes can go but only if they're escalating, or you can put any factor/product of a number on the pile, etc.
	
	return [valid_move, reason]

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func on_hovered_over_card(card):
	if !is_hovered_on_card:
		is_hovered_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card.card_slot_card_is_in:
		if !card_being_dragged:
			highlight_card(card, false)
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovered_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	# Assume the first card in cards array has the highest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Loop through the rest of the cards checking for a higher z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

class_name global_scripts

static func validate_card_move(card_being_dragged, card_slot_found):
	# check if we are finishing the drag over a card slot, aka a valid area to place the card
	var valid_move = false
	var reason
	
	var top_discard = card_slot_found.card_in_slot[-1]
	
	if not card_slot_found.card_in_slot:
		# Card dropped in empty slot
		valid_move = true
		reason = "Discard is empty"
		return [card_being_dragged, valid_move, reason]
	
	
	if top_discard.card_value == card_being_dragged.card_value:
		# values match
		valid_move = true
		reason = "Values match"
	elif top_discard.card_suit == card_being_dragged.card_suit:
		# suits match
		valid_move = true
		reason = "Suits match"
	else: # matches neither value nor suit
		reason = "You need to at least match the card suit or value"
	
	#for rule in ace_rules:
		#if rule
	
	# Rules for non-empty discard piles, extra checks may validate or invalidate previous rulings
	if card_slot_found.card_in_slot.size() > 0:
		# Lonely Hearts
		if (card_slot_found.card_in_slot.size() >= 2 and top_discard.card_suit == "Hearts" and card_slot_found.card_in_slot[-2].card_suit != "Hearts") or (card_slot_found.card_in_slot.size() == 1 and top_discard.card_suit == "Hearts"):
			# Lonely Heart on the discard pile
			if card_being_dragged.card_suit != "Hearts":
				valid_move = false
				reason = "You can't create a Lonely Heart. Hearts must be paired with at least one other Hearts card."
		# Top Ace
		if top_discard.card_value == "1":
			# Aces Fly Solo
			if card_being_dragged.card_value == "1":
				valid_move = false
				reason = "Ace's fly solo, you can't group them together like that"
		# Top Deuce
		if top_discard.card_value == "2":
			pass
		# Top Three
		if top_discard.card_value == "3":
			# Three's a crowd
			if (card_slot_found.card_in_slot.size() >= 2 and top_discard.card_value == "3" and card_slot_found.card_in_slot[-2].card_value == "3"):
				valid_move = false
				reason = "Two's company, three's a crowd. But THREE threes? That's like putting a hat on a hat."
		# Top Four
		if top_discard.card_value == "4":
			pass
		# Top Five
		if top_discard.card_value == "5":
			pass
		# Top Six
		if top_discard.card_value == "6":
			# Mark of the Beast
			if (card_slot_found.card_in_slot.size() >= 2 and top_discard.card_value == "6" and card_slot_found.card_in_slot[-2].card_value == "6"):
				if card_being_dragged.card_value == "1":
					valid_move = false
					reason = "666? That's the mark of the beast! Best not to bring any bad luck into this..."
		# Top Seven
		if top_discard.card_value == "7":
			pass
		# Top Eight
		if top_discard.card_value == "8":
			pass
		# Top Nine
		if top_discard.card_value == "9":
			# Because Seven Ate Nine
			if card_being_dragged.card_value == "7" and card_being_dragged.card_suit != top_discard.card_suit:
				valid_move = true
				reason = "You can always plays Sevens on Nines, because Seven Ate Nine!"
		# Top Ten
		if top_discard.card_value == "10":
			pass
		# Top Jack
		if top_discard.card_value == "11":
			pass
		# Top Queen
		if top_discard.card_value == "12":
			if card_being_dragged.card_value == "13":
				valid_move = true
				reason = "Every Queen needs her King"
		# Top King
		if top_discard.card_value == "13":
			if card_being_dragged.card_value == "12":
				valid_move = true
				reason = "Every King needs his Queen"
	
	if valid_move and card_being_dragged.card_value == '1':
		#ace_makes_new_rule
		reason = "Ooo, I get to make a new rule... >:)"
	
	# Rules ideas
	# some sort of math based things, like primes can go but only if they're escalating, or you can put any factor/product of a number on the pile, etc.
	
	return [card_being_dragged, valid_move, reason]

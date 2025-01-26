extends Node2D

signal hovered
signal hovered_off

var hand_position

# Called when the node enters the scene tree for the first time.
func _ready():
	# All cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_entered():
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited():
	emit_signal("hovered_off", self)
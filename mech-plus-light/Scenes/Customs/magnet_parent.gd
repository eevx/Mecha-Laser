extends StaticBody2D

@export var magnet : Area2D
@export var pull_strength: float = 500.0 
var is_active: bool = false              

func toggle_magnet(state: bool) -> void:
	is_active = state
	magnet.MOn = is_active
	print("toggled_on: ",is_active)

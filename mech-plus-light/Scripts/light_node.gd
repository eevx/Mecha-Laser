extends Node2D
@export var object_to_disable: Node2D 

func i_am_light_dependent() -> bool:
	return true

func disable() -> void : 
	print("Finally something is happening")

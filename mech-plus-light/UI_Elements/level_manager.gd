extends Node2D
@export var levels : Array[Node]

signal level_complete
func _ready() -> void:
	level_complete.connect(_on_level_complete)

func _on_level_complete():
	for level in levels:
		pass

extends Area2D

var is_on = false
@export var button_tex_1 : Texture
@export var button_tex_2 : Texture
@export var sprite_2d : Sprite2D
func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		is_on = !is_on
		
		if is_on:
			sprite_2d.texture = button_tex_1
		else:
			sprite_2d.texture = button_tex_1

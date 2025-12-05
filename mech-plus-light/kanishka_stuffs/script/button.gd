extends Area2D

var is_on = false
var player_is_in = false
@export var button_tex_1 : Texture
@export var button_tex_2 : Texture
@export var sprite_2d : Sprite2D

func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBody2D:
		player_is_in = true
		print("area entered")
		

func _input(event: InputEvent) -> void:
	if player_is_in:
		if Input.is_action_pressed("button_interact") and event.is_pressed():
			print("e pressed")
			is_on = !is_on
			if is_on:
				print("on")
				sprite_2d.texture = button_tex_1
			else:
				print("off")
				sprite_2d.texture = button_tex_2

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false
		print("area entered")

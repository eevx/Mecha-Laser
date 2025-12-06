extends Area2D

var is_on = false
var player_is_in = false

signal on_button_press(state: bool)

@export var button_tex_1 : Texture
@export var button_tex_2 : Texture
@export var sprite_2d : Sprite2D

@onready var magnets = $"../magnets"


func _ready() -> void:
	for magnet in magnets.get_children():
		if magnet.has_method("toggle_magnet"):
			on_button_press.connect(magnet.toggle_magnet)
			print("Connected to:", magnet.name)


func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBody2D:
		player_is_in = true
		print("Player inside button area")


func _input(event: InputEvent) -> void:
	if player_is_in and event.is_action_pressed("button_interact"):
		
		is_on = !is_on 

		sprite_2d.texture = button_tex_1 if is_on else button_tex_2

		print("Button toggled ->", is_on)

		emit_signal("on_button_press", is_on)  


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false
		print("Player left button area")

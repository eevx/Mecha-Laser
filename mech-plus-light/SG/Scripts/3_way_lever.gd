extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

# possible states for the lever
enum Position { LEFT, CENTER, RIGHT }

var current_position: int = Position.CENTER
var is_player_near: bool = false
var is_active: bool = false # True when player has pressed 'E'
@export var master_portal : Node = null

func _ready() -> void:
	update_visuals()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: 
		is_player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_near = false
		is_active = false

func _input(event: InputEvent) -> void:
	if not is_player_near:
		return

	# 1. Toggle "Active" mode with E
	if Input.is_key_pressed(KEY_E) and event.is_pressed() and not event.is_echo():
		is_active = not is_active
		print("Lever Control: ", is_active)
	
	if is_active:
		if Input.is_key_pressed(KEY_A) and event.is_pressed() and not event.is_echo():
			change_position(-1) # Move Left
			
		elif Input.is_key_pressed(KEY_D) and event.is_pressed() and not event.is_echo():
			change_position(1)  # Move Right


func change_position(direction: int) -> void:
	var new_index = current_position + direction
	
	new_index = clamp(new_index, Position.LEFT, Position.RIGHT)
	
	if new_index != current_position:
		current_position = new_index
		update_visuals()

func update_visuals() -> void:
	match current_position:
		Position.LEFT:
			animated_sprite.play("Left")
			print("Lever is LEFT")
			if master_portal:
				master_portal.change_color(Color.GREEN)
			
		Position.CENTER:
			animated_sprite.play("Center")
			print("Lever is CENTER")
			if master_portal:
				master_portal.change_color(Color.YELLOW)
			
		Position.RIGHT:
			animated_sprite.play("Right")
			print("Lever is RIGHT")
			if master_portal:
				master_portal.change_color(Color.RED)

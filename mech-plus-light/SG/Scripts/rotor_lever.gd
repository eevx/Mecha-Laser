extends Area2D


# 1. The object to control	
@export var object_to_rotate: Node2D 

# 2. Angle Limits and Speed
@export var min_angle: float = -90.0
@export var max_angle: float = 90.0
@export var rotation_speed: float = 100.0 # Degrees per second

var current_angle: float = 0.0 

var direction = 0.0
var is_player_near: bool = false
var is_active: bool = false 

func _ready() -> void:
	if object_to_rotate:
		current_angle = object_to_rotate.rotation_degrees

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: 
		is_player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_near = false
		is_active = false 
	direction = 0

func _input(event: InputEvent) -> void:
	if not is_player_near:
		return

	if Input.is_key_pressed(KEY_E) and event.is_pressed() and not event.is_echo():
		is_active = not is_active
		print("Lever Control: ", is_active)

func _physics_process(delta: float) -> void:
	if is_active and object_to_rotate:
		handle_rotation_input(delta)

func handle_rotation_input(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_A):
		direction = -1.0
	elif Input.is_key_pressed(KEY_D):
		direction = 1.0
	
	if direction != 0.0:
		current_angle += direction * rotation_speed * delta
		
		current_angle = clamp(current_angle, min_angle, max_angle)
		
		object_to_rotate.rotation_degrees = current_angle
		

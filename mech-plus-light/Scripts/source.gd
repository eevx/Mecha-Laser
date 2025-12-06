extends RigidBody2D

@export_group('Settings')
@export var move_speed := 600.0
@export var drag_factor := 10.0
@export var lasers : Array[Light]
var current_velocity := Vector2.ZERO

func _process(_delta: float) -> void:
	#look_at(get_global_mouse_position())
	#laser.is_casting = Input.is_action_pressed("fire_weapon")
	for laser in lasers:
		laser.is_casting = true #Input.is_action_pressed("fire_weapon")
	#
	#var input_velocity := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#var desired_velocity := input_velocity * move_speed
	#var distance := current_velocity.distance_to(desired_velocity)
#
	#current_velocity = current_velocity.move_toward(desired_velocity, distance * drag_factor * delta)
	#position += current_velocity * delta

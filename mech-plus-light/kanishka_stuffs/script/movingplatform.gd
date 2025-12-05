# MovingPlatformWithCarry.gd
extends Node2D

@export var point_a: Vector2 = Vector2(-200, 0)
@export var point_b: Vector2 = Vector2(200, 0)
@export var speed: float = 120.0
@export var arrive_threshold: float = 2.0
@export var wait_time: float = 0.0


var _target: Vector2
var _waiting_time_remaining: float = 0.0
var _previous_position: Vector2
var _bodies := []   # list of Node references currently on platform
var original_speed: float = 120.0

func _ready():
	_target = point_b
	global_position = point_a
	_previous_position = global_position
	original_speed = speed
	
func _physics_process(delta: float) -> void:
	if _waiting_time_remaining > 0.0:
		_waiting_time_remaining -= delta
		_previous_position = global_position
		return

	var to_target = _target - global_position
	var dist = to_target.length()
	if dist <= arrive_threshold:
		if _target == point_b: 
			_target = point_a
		else: 
			_target =point_b
		_waiting_time_remaining = wait_time
	else:
		var dir = to_target / dist
		var motion = dir * speed * delta
		if motion.length() > dist:
			motion = dir * dist
		global_position += motion

	# compute motion this frame and apply to bodies
	var platform_motion = global_position - _previous_position
	if platform_motion != Vector2.ZERO:
		for body in _bodies:
			if not is_instance_valid(body):
				continue
			# cheap but effective: translate the body by platform motion
			# If body is a CharacterBody2D with a velocity system, prefer adding the motion to its velocity.
			body.global_position += platform_motion
	_previous_position = global_position

func _on_body_entered(body: Node) -> void:
	# optionally filter: only carry physics/bodies you want
	_bodies.append(body)

func _on_body_exited(body: Node) -> void:
	_bodies.erase(body)
	
func change_speed(new_speed: float) -> void:
	speed = new_speed
	
func get_og_speed() -> float:
	return original_speed

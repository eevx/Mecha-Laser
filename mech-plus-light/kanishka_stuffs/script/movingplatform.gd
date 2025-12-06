## MovingPlatformWithCarry.gd
#extends Node2D
#
#@export var point_a: Vector2 = Vector2(-200, 0)
#@export var point_b: Vector2 = Vector2(200, 0)
#@export var speed: float = 120.0
#@export var arrive_threshold: float = 2.0
#@export var wait_time: float = 0.0
#
#
#var _target: Vector2
#var _waiting_time_remaining: float = 0.0
#var _previous_position: Vector2
#var _bodies := []   # list of Node references currently on platform
#
#func _ready():
	#_target = point_b
	#global_position = point_a
	#_previous_position = global_position
	#
#func _physics_process(delta: float) -> void:
	#if _waiting_time_remaining > 0.0:
		#_waiting_time_remaining -= delta
		#_previous_position = global_position
		#return
#
	#var to_target = _target - global_position
	#var dist = to_target.length()
	#if dist <= arrive_threshold:
		#if _target == point_b: 
			#_target = point_a
		#else: 
			#_target =point_b
		#_waiting_time_remaining = wait_time
	#else:
		#var dir = to_target / dist
		#var motion = dir * speed * delta
		#if motion.length() > dist:
			#motion = dir * dist
		#global_position += motion
#
	## compute motion this frame and apply to bodies
	#var platform_motion = global_position - _previous_position
	#if platform_motion != Vector2.ZERO:
		#for body in _bodies:
			#if not is_instance_valid(body):
				#continue
			## cheap but effective: translate the body by platform motion
			## If body is a CharacterBody2D with a velocity system, prefer adding the motion to its velocity.
			#body.global_position += platform_motion
	#_previous_position = global_position
#
#func _on_body_entered(body: Node) -> void:
	## optionally filter: only carry physics/bodies you want
	#_bodies.append(body)
#
#func _on_body_exited(body: Node) -> void:
	#_bodies.erase(body)

extends Node2D

@export var horizontal: bool = true    # true = move on X axis, false = move on Y axis
@export var distance: float = 200.0     # how far from start point it moves
@export var speed: float = 120.0
@export var arrive_threshold: float = 2.0
@export var wait_time: float = 0.0

var start_point: Vector2
var end_point: Vector2
var _target: Vector2
var _waiting_time_remaining := 0.0
var _previous_position: Vector2
var _bodies := []


func _ready():
	# Start point is where you placed the platform
	start_point = global_position

	# Calculate end point based on the user choice (horizontal/vertical)
	if horizontal:
		end_point = start_point + Vector2(distance, 0)
	else:
		end_point = start_point + Vector2(0, distance)

	_target = end_point
	_previous_position = global_position


func _physics_process(delta: float):
	if _waiting_time_remaining > 0.0:
		_waiting_time_remaining -= delta
		_previous_position = global_position
		return

	var to_target = _target - global_position
	var dist = to_target.length()

	if dist <= arrive_threshold:
		# Swap movement direction
		_target = start_point if _target == end_point else end_point
		_waiting_time_remaining = wait_time
	else:
		var motion = to_target.normalized() * speed * delta
		if motion.length() > dist:
			motion = to_target.normalized() * dist
		global_position += motion

	# Carry bodies with platform
	var platform_motion = global_position - _previous_position
	if platform_motion != Vector2.ZERO:
		for body in _bodies:
			if is_instance_valid(body):
				body.global_position += platform_motion

	_previous_position = global_position


func _on_body_entered(body: Node):
	_bodies.append(body)


func _on_body_exited(body: Node):
	_bodies.erase(body)

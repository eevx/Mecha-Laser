extends CharacterBody2D
class_name PlayerMovement

@export_category("Settings")
@export var MAX_SPEED: float = 220.0
@export var ACCEL: float = 1800.0
@export var FRICTION: float = 1500.0


@export var GRAVITY: float = 2000.0
@export var JUMP_VELOCITY: float = -520.0
@export var JUMP_CUT_MULT: float = 0.5
@export var MAX_FALL_SPEED: float = 1200.0


@export var COYOTE_TIME: float = 0.12
@export var JUMP_BUFFER_TIME: float = 0.12


@export var DASH_SPEED: float = 1100.0
@export var DASH_TIME: float = 0.14
@export var DASH_GRACE_AFTER_LAND: float = 0.08
@export var allow_air_control_during_dash: bool = false


@export var facing: int = 1


@export var coyote_timer: float = 0.0
@export var jump_buffer_timer: float = 0.0
@export var dash_timer: float = 0.0
@export var dash_cooldown_timer: float = 0.0
@export var dash_grace_timer: float = 0.0


var is_dashing: bool = false
var can_dash: bool = true
var dash_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var input_dir: float = _get_input_direction()
	var on_floor = is_on_floor()

	if on_floor:
		coyote_timer = COYOTE_TIME
		can_dash = true
		dash_grace_timer = DASH_GRACE_AFTER_LAND
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
		dash_grace_timer = max(dash_grace_timer - delta, 0.0)

	if jump_buffer_timer > 0.0:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			_end_dash()
		else:
			if not allow_air_control_during_dash:
				velocity = dash_dir * DASH_SPEED
			else:
				var control_blend = 0.25
				var target = dash_dir * DASH_SPEED
				velocity = velocity.lerp(target, control_blend)

			move_and_slide()
			return

	if not on_floor:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
	else:
		if velocity.y > 0:
			velocity.y = 0

	if input_dir != 0:
		facing = sign(input_dir)
		var target_speed = input_dir * MAX_SPEED
		velocity.x = move_toward(velocity.x, target_speed, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		_do_jump()
		jump_buffer_timer = 0.0

	move_and_slide()

	if on_floor:
		is_dashing = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if event.is_action_pressed("ui_accept") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULT

	if event.is_action_pressed("dash"):
		_try_dash()

func _get_input_direction() -> float:
	var dir = 0.0
	if Input.is_action_pressed("ui_left"):
		dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir += 1.0
	return dir

func _do_jump() -> void:
	velocity.y = JUMP_VELOCITY
	coyote_timer = 0.0

func _try_dash() -> void:
	if not can_dash:
		return

	if not is_on_floor() and dash_grace_timer <= 0.0 and not can_dash:
		return

	var ix = 0.0
	var iy = 0.0
	if Input.is_action_pressed("ui_left"):
		ix -= 1
	if Input.is_action_pressed("ui_right"):
		ix += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("up"):
		iy -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("down"):
		iy += 1

	var input_vec = Vector2(ix, iy)
	if input_vec == Vector2.ZERO:
		input_vec = Vector2(facing, 0)
	else:
		input_vec = input_vec.normalized()

	_start_dash(input_vec)

func _start_dash(direction: Vector2) -> void:
	is_dashing = true
	can_dash = false
	dash_dir = direction
	dash_timer = DASH_TIME
	velocity = dash_dir * DASH_SPEED

func _end_dash() -> void:
	is_dashing = false
	dash_dir = Vector2.ZERO
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func move_toward(value: float, target: float, delta_val: float) -> float:
	if value == target:
		return value
	var diff = target - value
	var step = sign(diff) * delta_val
	if abs(step) > abs(diff):
		return target
	return value + step

func _get_property_list() -> Array:
	return []

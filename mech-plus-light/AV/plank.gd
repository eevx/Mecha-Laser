extends RigidBody2D

# Seesaw Physics Configuration - Adjust these to tune behavior

@export_group("Responsiveness")
@export var torque_power: float = 3.5
@export var center_deadzone_pixels: float = 20.0

@export_group("Stability")
@export var plank_mass: float = 80.0
@export var plank_inertia: float = 300.0
@export var angular_damping: float = 8.0
@export var linear_damping: float = 4.0
@export var manual_damping_factor: float = 0.75

@export_group("Oscillation Prevention")
@export var velocity_deadzone: float = 0.02
@export var rotation_deadzone_degrees: float = 0.3
@export var torque_smoothing_factor: float = 0.75
@export var min_torque_threshold: float = 10.0
@export var stable_frames_needed: int = 30
@export var stable_torque_multiplier: float = 0.1

@export_group("Rotation Limits")
@export var max_tilt_angle_degrees: float = 25.0

@export_group("Surface Properties")
@export var plank_friction: float = 1.5
@export var plank_bounce: float = 0.0

var feet_area: Area2D = null
var stable_frame_count: int = 0
var smoothed_torque: float = 0.0

func _ready() -> void:
	lock_rotation = false
	freeze = false
	can_sleep = false
	sleeping = false
	
	if has_node("FeetDetector"):
		feet_area = $FeetDetector
	else:
		push_error("FeetDetector node not found! Create an Area2D child named 'FeetDetector'")
	
	mass = plank_mass
	inertia = plank_inertia
	linear_damp = linear_damping
	angular_damp = angular_damping
	gravity_scale = 0.0
	continuous_cd = RigidBody2D.CCD_MODE_DISABLED
	contact_monitor = false
	
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = plank_friction
	physics_mat.bounce = plank_bounce
	physics_material_override = physics_mat

func _physics_process(delta: float) -> void:
	sleeping = false
	
	var bodies: Array = []
	if feet_area:
		bodies = feet_area.get_overlapping_bodies()
	
	var raw_torque: float = 0.0
	var active_body_count: int = 0
	
	for body in bodies:
		if not is_instance_valid(body):
			continue
		if not (body is PhysicsBody2D or body.is_in_group("player")):
			continue
		
		var local_position: Vector2 = to_local(body.global_position)
		var lever_arm_distance: float = local_position.x
		
		# Ignore bodies near center to reduce sensitivity
		if abs(lever_arm_distance) < center_deadzone_pixels:
			continue
		
		active_body_count += 1
		var body_weight: float = body.mass if (body is RigidBody2D) else 75.0
		raw_torque += lever_arm_distance * body_weight * 9.8
	
	# Smooth torque to prevent sudden changes
	smoothed_torque = lerp(smoothed_torque, raw_torque, torque_smoothing_factor)
	
	var is_nearly_stopped: bool = abs(angular_velocity) < velocity_deadzone
	var is_balanced: bool = abs(smoothed_torque) < 150.0
	var is_stable: bool = is_nearly_stopped and is_balanced
	
	# Apply torque with stability detection
	if active_body_count > 0 and abs(smoothed_torque) > min_torque_threshold:
		if is_stable:
			stable_frame_count += 1
			if stable_frame_count < stable_frames_needed:
				apply_torque(smoothed_torque * torque_power * stable_torque_multiplier)
		else:
			stable_frame_count = 0
			apply_torque(smoothed_torque * torque_power)
	else:
		stable_frame_count = 0
		smoothed_torque = lerp(smoothed_torque, 0.0, 0.1)
	
	# Return to horizontal when empty
	if active_body_count == 0 and abs(rotation) > deg_to_rad(1.0):
		apply_torque(-rotation * 150.0)
	
	# Manual damping and deadzones to kill oscillation
	angular_velocity *= manual_damping_factor
	
	if abs(angular_velocity) < velocity_deadzone:
		angular_velocity = 0.0
	
	if active_body_count == 0 and abs(rotation) < deg_to_rad(rotation_deadzone_degrees):
		rotation = 0.0
		angular_velocity = 0.0
		smoothed_torque = 0.0
	
	# Hard rotation limits
	var max_rotation_rad: float = deg_to_rad(max_tilt_angle_degrees)
	if rotation > max_rotation_rad:
		rotation = max_rotation_rad
		angular_velocity = 0.0
	elif rotation < -max_rotation_rad:
		rotation = -max_rotation_rad
		angular_velocity = 0.0

extends Player_State

var was_on_light: bool = false

func Enter():
	# Check if light walk mode is active
	was_on_light = _is_light_walk_active()
	player.PlayerSprite.play("light_run" if was_on_light else "run")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(delta):
	var dir := Input.get_axis("left", "right")
	
	# Check if light walk toggle changed, update animation immediately
	var light_active = _is_light_walk_active()
	if light_active != was_on_light:
		was_on_light = light_active
		player.PlayerSprite.play("light_run" if light_active else "run")
	
	var floor_dir = player.get_floor_normal().rotated(PI/2.)
	
	if dir != 0:
		if abs(player.velocity.x) < player.data.maxSpeed:
			player.velocity += floor_dir * player.acceleration * dir * delta
		else:
			player.velocity = floor_dir * player.data.maxSpeed * dir
	else:
		_decelerate(delta, floor_dir)
	
	player._apply_gravity()
	
	if is_zero_approx(abs(player.velocity.x)):
		Transition("IdleState")
		return
	if not player.is_on_floor():
		Transition("AirState")
		return
	if Input.is_action_just_pressed("jump"):
		#print("To Air from run")
		Transition("AirState")
	
	# Only allow dash if cooldown is ready
	if Input.is_action_just_pressed("dash") and player.dashCount > 0 and get_parent().get_node("DashState").dashcool:
		Transition("DashState")
	# Check if player has minimum fuel to start thruster (using is_action_pressed for held input)
	if Input.is_action_pressed("thruster") and player.thruster_fuel >= player.data.thruster_min_fuel_to_start:
		Transition("ThrusterState")

func _decelerate(delta:float, floor_dir:Vector2):
	var v = player.velocity.x
	if abs(v) <= abs(player.deceleration * delta):
		player.velocity.x = 0
	elif v > 0:
		player.velocity -= floor_dir * player.deceleration * delta
	elif v < 0:
		player.velocity += floor_dir * player.deceleration * delta

func Exit():
	pass

# Helper function to check if light walk mode is active (regardless of floor contact)
func _is_light_walk_active() -> bool:
	var lights = get_tree().get_nodes_in_group("Light")
	for light in lights:
		if light.can_walk_on_light and light.is_casting:
			return true
	return false

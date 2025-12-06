extends Player_State

func Enter():
	# Play run animation when entering run state
	player.PlayerSprite.play("run")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(delta):
	var dir := Input.get_axis("left", "right")
	
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

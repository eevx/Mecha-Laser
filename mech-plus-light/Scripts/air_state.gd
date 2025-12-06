extends Player_State

var dir 

func Enter():
	# Play jump animation when entering air state from ground (jumping)
	if player.velocity.y < 0:
		player.PlayerSprite.play("jump")
	else:
		# Play fall animation if already moving downward
		player.PlayerSprite.play("fall")
	
	if Input.is_action_just_pressed("jump") and player.jumpCount > 0:
		print("jump")
		player.velocity.y = -player.jumpMagnitude
		player.jumpCount -= 1
		# Ensure jump animation plays on double jump
		player.PlayerSprite.play("jump")

func Physics_Update(delta):
	player._apply_gravity()
	
	# Switch to fall animation when moving downward
	if player.velocity.y > 0 and player.PlayerSprite.animation != "fall":
		player.PlayerSprite.play("fall")
	
	dir = Input.get_axis("left","right")
	
	# Check if player has minimum fuel to start thruster (using is_action_pressed for held input)
	if Input.is_action_pressed("thruster") and player.thruster_fuel >= player.data.thruster_min_fuel_to_start:
		Transition("ThrusterState")
	
	if dir != 0:
		if abs(player.velocity.x) < player.data.maxSpeed:
			player.velocity.x += player.air_acceleration * dir * delta
		else:
			player.velocity.x = player.data.maxSpeed * dir
	else:
		_air_decel(delta)
	
	if player.data.shortHopAct and Input.is_action_just_released("jump") and player.velocity.y < 0:
			player.velocity.y /= player.data.jumpVariable
	
	if player.is_on_floor():
		if abs(player.velocity.x) > 0:
			Transition("RunState")
		else:
			Transition("IdleState")
	
	# Only allow dash if cooldown is ready
	if Input.is_action_just_pressed("dash") and player.dashCount > 0 and get_parent().get_node("DashState").dashcool:
		Transition("DashState")

func _air_decel(delta):
	#print("airdecel ACTIVE")
	var v = player.velocity.x
	#im not proud of this shit, but im tired atp
	if abs(v) > player.data.maxSpeed:
		if v > 0:
			player.velocity.x = player.data.maxSpeed
		else:
			player.velocity.x = -player.data.maxSpeed
	if abs(v) <= abs(player.air_deceleration * delta):
		player.velocity.x = 0
	elif v > 0:
		player.velocity.x -= player.air_deceleration * delta
	elif v < 0:
		player.velocity.x += player.air_deceleration * delta

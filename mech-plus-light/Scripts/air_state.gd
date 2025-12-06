extends Player_State

var dir 
var was_on_light: bool = false

func Enter():
	# Check if light walk mode is active
	was_on_light = _is_light_walk_active()
	
	# Play jump animation when entering air state from ground (jumping)
	if player.velocity.y < 0:
		player.PlayerSprite.play("light_jump" if was_on_light else "jump")
	else:
		# Play fall animation if already moving downward
		player.PlayerSprite.play("light_fall" if was_on_light else "fall")
	
	if Input.is_action_just_pressed("jump") and player.jumpCount > 0:
		print("jump")
		player.velocity.y = -player.jumpMagnitude * sign(player.data.gravityScale)
		player.jumpCount -= 1
		# Ensure jump animation plays on double jump
		player.PlayerSprite.play("light_jump" if was_on_light else "jump")

func Physics_Update(delta):
	player._apply_gravity()
	
	# Check if light walk mode is active
	var light_active = _is_light_walk_active()
	
	# If light walk toggle changed, update animation immediately
	if light_active != was_on_light:
		was_on_light = light_active
		if player.velocity.y > 0:
			player.PlayerSprite.play("light_fall" if light_active else "fall")
		else:
			player.PlayerSprite.play("light_jump" if light_active else "jump")
	
	# Switch to fall animation when moving downward
	if player.velocity.y > 0:
		var current_anim = player.PlayerSprite.animation
		var fall_anim = "light_fall" if light_active else "fall"
		if current_anim != fall_anim:
			player.PlayerSprite.play(fall_anim)
	
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

# Helper function to check if light walk mode is active (regardless of floor contact)
func _is_light_walk_active() -> bool:
	var lights = get_tree().get_nodes_in_group("Light")
	for light in lights:
		if light.can_walk_on_light and light.is_casting:
			return true
	return false

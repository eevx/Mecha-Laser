extends Player_State

func Enter():
	player.PlayerSprite.play("jump")
	if Input.is_action_just_pressed("jump") and player.jumpCount > 0:
		player.velocity.y = -player.jumpMagnitude
		player.jumpCount -= 1

func Physics_Update(delta):
	player._apply_gravity()
	
	var dir := Input.get_axis("left","right")
	
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
	if Input.is_action_just_pressed("dash") and player.dashCount > 0:
		Transition("DashState")
	player.move_and_slide()

func _air_decel(delta):
	#if abs(player.velocity.x) > 0:
		#player.velocity.x = lerp(player.velocity.x, 0.0, 50. * delta)
	var v = player.velocity.x

	if abs(v) <= abs(player.air_deceleration * delta):
		player.velocity.x = 0
	elif v > 0:
		player.velocity.x -= player.air_deceleration * delta
	elif v < 0:
		player.velocity.x += player.air_deceleration * delta

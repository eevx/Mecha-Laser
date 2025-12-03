extends Player_State

func Enter():
	if Input.is_action_just_pressed("jump") and player.jumpCount > 0:
		player.velocity.y = -player.jumpMagnitude
		player.jumpCount -= 1
		player.PlayerSprite.play("jump")

func Physics_Update(delta):
	player._apply_gravity()
	
	var dir := Input.get_axis("left","right")
	
	if dir != 0:
		if abs(player.velocity.x) < player.data.maxSpeed:
			player.velocity.x += player.acceleration * dir * delta
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

func _air_decel(_delta):
	if abs(player.velocity.x) > 0:
		player.velocity.x = lerp(player.velocity.x, 0.0, 0.1)

extends Player_State

func Enter():
	player.PlayerSprite.play("run")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(delta):
	if not player.is_on_floor():
		Transition("AirState")
		return
	
	var dir := Input.get_axis("left", "right")
	
	if dir != 0:
		if abs(player.velocity.x) < player.data.maxSpeed:
			player.velocity.x += player.acceleration * dir * delta
		else:
			player.velocity.x = player.data.maxSpeed * dir
	else:
		print("To idle from run")
		_decelerate(delta)
		if is_zero_approx(abs(player.velocity.x)):
			Transition("IdleState")
		return
	
	if Input.is_action_just_pressed("jump"):
		print("To Air from run")
		Transition("AirState")
	
	if Input.is_action_just_pressed("dash") and player.dashCount > 0:
		Transition("DashState")

func _decelerate(_delta:float):
	var v = player.velocity.x

	if abs(v) <= abs(player.deceleration * _delta):
		player.velocity.x = 0
	elif v > 0:
		player.velocity.x -= player.deceleration * _delta
	elif v < 0:
		player.velocity.x += player.deceleration * _delta

func Exit():
	pass

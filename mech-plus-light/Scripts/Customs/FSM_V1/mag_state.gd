extends Player_State

func Enter():
	pass


func Physics_Update(_delta:float):
	if is_zero_approx(player.velocity.x):
		player.PlayerSprite.play("idle")

	if Input.is_action_pressed("jump") and player.jumpCount > 0:
		print("transition")
		Transition("AirState")


func Update(_delta:float):
	pass

func Exit():
	pass

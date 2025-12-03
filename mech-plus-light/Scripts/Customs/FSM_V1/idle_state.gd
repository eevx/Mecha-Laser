extends Player_State

func Enter():
	player.PlayerSprite.play("idle")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(_delta:float):
	var dir := Input.get_axis("left","right")
	if not player.is_on_floor():
		print("why")
		Transition("AirState")
		return
	if dir != 0:
		Transition("RunState")
		print("State to run ")
		return
	
	if Input.is_action_pressed("jump") and player.jumpCount > 0:
		Transition("AirState")
	
	if Input.is_action_pressed("dash") and player.dashCount > 0:
		Transition("DashState")
	

func Exit():
	pass

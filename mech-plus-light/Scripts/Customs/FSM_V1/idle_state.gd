extends Player_State

func Enter():
	player.PlayerSprite.play("idle")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(_delta:float):
	var dir := Input.get_axis("left","right")
	player._apply_gravity()
	if not player.is_on_floor():
		Transition("AirState")
		return

	if dir != 0:
		Transition("RunState")
		return

	if Input.is_action_pressed("jump") and player.jumpCount > 0:
		Transition("AirState")

	if Input.is_action_pressed("dash") and player.dashCount > 0:
		Transition("DashState")
	
	if player.in_field:
		Transition("MagState")
func Exit():
	pass

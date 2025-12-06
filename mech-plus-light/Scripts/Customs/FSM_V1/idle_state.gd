extends Player_State

func Enter():
	# Play idle animation when entering idle state
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
	
	# Only allow dash if cooldown is ready
	if Input.is_action_pressed("dash") and player.dashCount > 0 and get_parent().get_node("DashState").dashcool:
		Transition("DashState")
	
	# Check if player has minimum fuel to start thruster (using is_action_pressed for held input)
	if Input.is_action_pressed("thruster") and player.thruster_fuel >= player.data.thruster_min_fuel_to_start:
		Transition("ThrusterState")

func Exit():
	pass

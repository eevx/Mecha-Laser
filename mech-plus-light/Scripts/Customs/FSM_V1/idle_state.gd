extends Player_State

var was_on_light: bool = false

func Enter():
	# Check if light walk mode is active
	was_on_light = _is_light_walk_active()
	player.PlayerSprite.play("light_idle" if was_on_light else "idle")
	player.jumpCount = 1
	player.dashCount = 1

func Physics_Update(_delta:float):
	var dir := Input.get_axis("left","right")
	player._apply_gravity()
	
	# Check if light walk toggle changed, update animation immediately
	var light_active = _is_light_walk_active()
	if light_active != was_on_light:
		was_on_light = light_active
		player.PlayerSprite.play("light_idle" if light_active else "idle")
	
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

# Helper function to check if light walk mode is active (regardless of floor contact)
func _is_light_walk_active() -> bool:
	var lights = get_tree().get_nodes_in_group("Light")
	for light in lights:
		if light.can_walk_on_light and light.is_casting:
			return true
	return false

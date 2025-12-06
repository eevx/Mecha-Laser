extends Player_State

var dashcool := true
var was_on_light: bool = false

func Enter():
	# Only dash if cooldown is ready
	if dashcool and player.dashCount > 0:
		# Check if light walk mode is active
		was_on_light = _is_light_walk_active()
		player.PlayerSprite.play("light_dash" if was_on_light else "dash")
		player.dashCount -= 1
		
		# Get dash direction based on input or last facing direction
		var input = Input.get_axis("left","right")
		var dir = input if input != 0. else (1. if player.wasMovingR else -1.)
		
		# Set horizontal dash velocity only
		player.velocity = Vector2(player.data.dashMagnitude * dir, 0)
		player._pause_gravity(player.data.dashTime)
		player._start_dash(player.data.dashTime)
	else:
		# If dash is on cooldown or no dashes available, return to air state
		Transition("AirState")

func Physics_Update(_delta:float):
	# Check if light walk toggle changed, update animation immediately
	var light_active = _is_light_walk_active()
	if light_active != was_on_light:
		was_on_light = light_active
		player.PlayerSprite.play("light_dash" if light_active else "dash")
	
	# Transition to air state when dash ends
	if not player.dashing:
		Transition("AirState")

func Exit():
	# Start cooldown timer
	dashcool = false
	await get_tree().create_timer(player.data.dashCoolTime).timeout
	dashcool = true

# Helper function to check if light walk mode is active (regardless of floor contact)
func _is_light_walk_active() -> bool:
	var lights = get_tree().get_nodes_in_group("Light")
	for light in lights:
		if light.can_walk_on_light and light.is_casting:
			return true
	return false

extends Player_State

var dashcool := true

func Enter():
	# Only dash if cooldown is ready
	if dashcool and player.dashCount > 0:
		# Play dash animation when entering dash state
		player.PlayerSprite.play("dash")
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
	# Transition to air state when dash ends
	if not player.dashing:
		Transition("AirState")

func Exit():
	# Start cooldown timer
	dashcool = false
	await get_tree().create_timer(player.data.dashCoolTime).timeout
	dashcool = true

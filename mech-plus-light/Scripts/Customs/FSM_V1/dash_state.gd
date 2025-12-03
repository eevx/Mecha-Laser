extends Player_State

func Enter():
	player.PlayerSprite.play("dash")
	player.dashCount -= 1
	
	var input = Input.get_axis("left","right")
	var dir = input if input != 0 else (1 if player.wasMovingR else -1)
	
	player.velocity = Vector2(player.data.dashMagnitude * dir, 0)
	
	player._pause_gravity(player.data.dashTime)
	player._start_dash(player.data.dashTime)

func Physics_Update(_delta:float):
	if not player.dashing:
		Transition("AirState")
	
	player.move_and_slide()

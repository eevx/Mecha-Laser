extends Player_State

var dashcool := true

func Enter():
	if dashcool:
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



func Exit():
	dashcool = false
	await get_tree().create_timer(player.data.dashCoolTime).timeout
	dashcool = true

extends Player_State
class_name MagState

func Enter():
	pass

func Physics_Update(delta: float) -> void:
	if not player.in_field:
		Transition("AirState")
		return

	if player.is_on_ceiling():
		player.jumpCount += 1
		if Input.is_action_just_pressed("jump") and player.jumpCount > 0 :
			player.velocity.y += player.jumpMagnitude
			player.jumpCount -= 1

func Update(delta: float) -> void:
	pass

func Exit():
	pass

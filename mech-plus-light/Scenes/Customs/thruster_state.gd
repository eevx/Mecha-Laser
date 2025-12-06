#
#extends Player_State
#class_name ThrusterState
#
#func Enter() -> void:
	#if not player.can_use_thruster():
		#Transition("AirState")
		#return
	#player.start_thruster_effects()
#
#func Physics_Update(delta: float) -> void:
	#var pressing := Input.is_action_pressed("thruster")
	#if pressing and player.thruster_fuel > 0.0:
		#player.apply_thruster_force(delta)
		#player.thruster_fuel = max(player.thruster_fuel - player.thruster_drain_rate * delta, 0.0)
		#player.thruster_refill_timer = 0.0
		#if player.thruster_fuel <= 0.0:
			#player.stop_thruster_effects()
			#Transition("AirState")
	#else:
		#player.stop_thruster_effects()
		#Transition("AirState")
#
	## safety: if landed, go to ground
	#if player.is_on_floor():
		#Transition("IdleState")
#
#func Exit() -> void:
	#player.stop_thruster_effects()

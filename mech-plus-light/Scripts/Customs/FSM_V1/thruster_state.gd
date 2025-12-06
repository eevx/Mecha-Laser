extends Player_State

@onready var thruster_ui: Line2D = $"../Thruster_UI"

func Enter() -> void:
	# Check if player has minimum fuel required to start thruster
	if player.thruster_fuel < player.data.thruster_min_fuel_to_start:
		Transition("AirState")
		return
	# Play thruster animation when entering thruster state
	player.PlayerSprite.play("thruster")
	start_thruster_effects()

func Physics_Update(delta: float) -> void:
	var pressing := Input.is_action_pressed("thruster")
	
	if pressing and player.thruster_fuel > 0.0:
		apply_thruster_force(delta)
		player.thruster_fuel = max(player.thruster_fuel - player.data.thruster_drain_rate * delta, 0.0)
		thruster_ui.points[1] = Vector2(0,(player.max_thruster_fuel - player.thruster_fuel)*40.)
		#thruster_ui.points[0] = Vector2(0, player.max_thruster_fuel * 40.)
		player.thruster_refill_timer = 0.0
		
		if player.thruster_fuel <= 0.0:
			stop_thruster_effects()
			Transition("AirState")
	else:
		stop_thruster_effects()
		Transition("AirState")
	
	# safety: if landed, go to ground
	if player.is_on_floor() and not Input.is_action_pressed("thruster"):
		if is_zero_approx(player.velocity.x):
			Transition("IdleState")
		else:
			Transition("RunState")

func Exit() -> void:
	stop_thruster_effects()

func can_use_thruster() -> bool:
	return player.thruster_fuel > 0.0

func apply_thruster_force(delta: float) -> void:
	player.velocity.y += player.data.thruster_force * delta

func start_thruster_effects() -> void:
	player.thruster_using = true
	# if has_node("ThrusterParticles"): $ThrusterParticles.emitting = true
	# if has_node("AudioThruster"): $AudioThruster.play()

func stop_thruster_effects() -> void:
	player.thruster_using = false
	# if has_node("ThrusterParticles"): $ThrusterParticles.emitting = false
	# if has_node("AudioThruster"): $AudioThruster.stop()

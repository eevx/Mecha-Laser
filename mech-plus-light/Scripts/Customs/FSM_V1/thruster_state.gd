extends Player_State

@onready var thruster_ui: Line2D = $"../Thruster_UI"
var was_on_light: bool = false

func Enter() -> void:
	# Check if player has minimum fuel required to start thruster
	if player.thruster_fuel < player.data.thruster_min_fuel_to_start:
		Transition("AirState")
		return
	
	# Check if light walk mode is active
	was_on_light = _is_light_walk_active()
	player.PlayerSprite.play("light_thruster" if was_on_light else "thruster")
	start_thruster_effects()

func Physics_Update(delta: float) -> void:
	var pressing := Input.is_action_pressed("thruster")
	
	# Check if light walk toggle changed, update animation immediately
	var light_active = _is_light_walk_active()
	if light_active != was_on_light:
		was_on_light = light_active
		player.PlayerSprite.play("light_thruster" if light_active else "thruster")
	
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
	player.velocity.y += player.data.thruster_force * sign(player.data.gravityScale) * delta

func start_thruster_effects() -> void:
	player.thruster_using = true
	# if has_node("ThrusterParticles"): $ThrusterParticles.emitting = true
	# if has_node("AudioThruster"): $AudioThruster.play()

func stop_thruster_effects() -> void:
	player.thruster_using = false
	# if has_node("ThrusterParticles"): $ThrusterParticles.emitting = false
	# if has_node("AudioThruster"): $AudioThruster.stop()

# Helper function to check if light walk mode is active (regardless of floor contact)
func _is_light_walk_active() -> bool:
	var lights = get_tree().get_nodes_in_group("Light")
	for light in lights:
		if light.can_walk_on_light and light.is_casting:
			return true
	return false

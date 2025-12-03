extends CharacterBody2D

@export var speed: float = 200.0        # Left-right speed
@export var jump_force: float = -400.0 # Upward jump force
var can_walk: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	var direction = 0.0

	# --- Left / Right movement ---
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	else:
		direction = 0
		
	if Input.is_action_pressed("toggle"):
		if can_walk:
			for source in get_tree().get_nodes_in_group("Source"):
				for child in source.get_children():
					if child is RayCast2D:
						var sb := StaticBody2D.new()
						sb.name = "StaticFromCharacter"
						var cs := CollisionShape2D.new()
					# simple rectangle - change to fit your needs
						var rect := RectangleShape2D.new()
						rect.extents = Vector2(8, 8) # adjust size
						cs.shape = rect
						sb.add_child(cs)
					# keep shape owner so it appears correctly in editor if needed
						#sb.set_owner(get_tree().current_scene)
			set_collision_layer_value(9, false)
			set_collision_mask_value(9, false)
			can_walk = false
		else:
			set_collision_layer_value(9, true)
			set_collision_mask_value(9, true)
			can_walk = true
	
		
	velocity.x = direction * speed
	
	# --- Apply gravity ---
	velocity.y += gravity * delta
	
	# --- Jump (Up) ---
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_force
	move_and_slide()

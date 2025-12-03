extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0
@onready var playerspr: AnimatedSprite2D = $Playerspr


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction == -1:
		playerspr.flip_h = true
	if direction == 1:
		playerspr.flip_h = false
	if direction == 0:
		playerspr.play("idle")
	else:
		playerspr.play("run")
	if velocity.y != 0:
		playerspr.play("jump")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

extends CharacterBody2D

class_name PlatformerController2D

@export_category("Necesary Nodes")
## The AnimatedSprite2D used to display the player character.
@export var PlayerSprite: AnimatedSprite2D
## The CollisionShape2D used for player collisions.
@export var PlayerCollider: CollisionPolygon2D

#INFO HORIZONTAL MOVEMENT 
@export_category("Horizontal Movement")
##The max speed Player will move
@export var maxSpeed: float = 200.0
##How fast Player will reach max speed from rest (in seconds)
@export var timeToReachMaxSpeed: float = 0.2
##How fast Player will reach zero speed from max speed (in seconds)
@export var timeToReachZeroSpeed: float = 0.2
##If true, Player will instantly move and switch directions. Overrides the "timeToReach" variables, setting them to 0.
@export var directionalSnap: bool = false

#INFO JUMPING 
@export_category("Jumping and Gravity")
##The peak height of jump
@export var jumpHeight: float = 2.0
##How many jumps before needing to touch the ground again.
@export var jumps: int = 1
##The gravity
@export var gravityScale: float = 20.0
##The fastest Player can fall
@export var terminalVelocity: float = 500.0
##Player will move this amount faster when falling providing a less floaty jump curve.
@export var descendingGravityFactor: float = 1.3
##Enabling this toggle makes it so that when the player releases the jump key while still jumping, their vertical velocity will cut by the height cut, providing variable jump height.
@export var shortHopAct: bool = true
##How much the jump height is cut by.
@export var jumpVariable: float = 2

#INFO DASHING
@export_category("Dashing")
##How many dashes before needing to hit the ground.
@export var dashes: int = 1
##How long the player will dash.
@export var dashTime: float = 2.5
##how fast the dash is.
@export var dashMagnitude: float = 4

# --- Core Internal Variables ---
var appliedGravity: float
var maxSpeedLock: float
var acceleration: float
var deceleration: float
var instantAccel: bool
var jumpMagnitude: float
var jumpCount: int
var dashCount: int
var gravityActive: bool = true
var dashing: bool = false

var wasMovingR: bool 
var anim: AnimatedSprite2D
var animScaleLock : Vector2


func _ready():
	anim = PlayerSprite
	
	animScaleLock = abs(anim.scale) 
	
	_update_data()
	
func _update_data():
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	
	jumpCount = jumps
	dashCount = dashes
	
	maxSpeedLock = maxSpeed
	
	
func _process(_delta):
	#Decides the direction the model is facing
	if !dashing:
		if Input.is_action_pressed("right"):
			anim.scale.x = animScaleLock.x
		elif Input.is_action_pressed("left"):
			anim.scale.x = animScaleLock.x * -1

#anims
	# NOTE: You will need to define 'idle', 'run', 'jump', and 'falling' animations 
	
	if dashing:
		anim.play("dash")
	elif is_on_floor():
		if abs(velocity.x):
			anim.play("run")
		else:
			anim.play("idle")
		jumpCount = jumps
		dashCount = dashes
	elif velocity.y :
		anim.play("jump")


func _physics_process(delta):
	
	
	var left_hold = Input.is_action_pressed("left")
	var right_hold = Input.is_action_pressed("right")
	var up_hold = Input.is_action_pressed("ui_up") 
	var down_hold = Input.is_action_pressed("ui_down")
	var jump_tap = Input.is_action_just_pressed("jump")
	var jump_release = Input.is_action_just_released("jump")
	var dash_tap = Input.is_action_just_pressed("dash")
	
	var direction = 0.0
	if right_hold and !left_hold:
		direction = 1.0
	elif left_hold and !right_hold:
		direction = -1.0

	if direction != 0.0 && not dashing:
		if abs(velocity.x) < maxSpeed and not instantAccel:
			velocity.x += acceleration * direction * delta
		else:
			velocity.x = maxSpeed * direction
		
	
		if direction == 1.0:
			wasMovingR = true
		elif direction == -1.0:
			wasMovingR = false
			
	else:
		# Decel
		_decelerate(delta)

	# Gravity
	if gravityActive:
		if velocity.y > 0:
			appliedGravity = gravityScale * descendingGravityFactor
		else:
			appliedGravity = gravityScale
		
		if velocity.y < terminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > terminalVelocity:
			velocity.y = terminalVelocity


	#Jumping
	if jump_tap and jumpCount > 0 and not dashing:
		velocity.y = -jumpMagnitude
		jumpCount -= 1
	if shortHopAct and jump_release and velocity.y < 0:
		velocity.y = velocity.y / jumpVariable
	
	# Dashing 
	if dash_tap and dashCount > 0 and not dashing:
		var horizontal_input = Input.get_vector("left", "right", "ui_down", "ui_up").x
		var dash_vector = Vector2.ZERO
		
		if horizontal_input != 0:
			dash_vector = Vector2(dashMagnitude * horizontal_input, 0)
		else:
			dash_vector = Vector2(dashMagnitude * (1 if wasMovingR else -1), 0)
		
		if dash_vector != Vector2.ZERO:
			velocity = dash_vector
			_pause_gravity(dashTime)
			_dashing_time(dashTime)
			dashCount -= 1
	
	move_and_slide()
	

func _decelerate(delta):
	if not dashing:
		if (abs(velocity.x) > 0) and (abs(velocity.x) <= abs(deceleration * delta)):
			velocity.x = 0 
		elif velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta


func _pause_gravity(time):
	gravityActive = false
	await get_tree().create_timer(time).timeout
	gravityActive = true


func _dashing_time(time):
	dashing = true
	await get_tree().create_timer(time).timeout
	dashing = false

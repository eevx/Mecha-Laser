extends  CharacterBody2D
class_name Player

#fill these exports unless you want to crash shit
@export var initial_state : Player_State
@export var PlayerSprite : AnimatedSprite2D
@export var PlayerCol : CollisionPolygon2D
@export var data : PlayerData

#running vars
var jumpCount : int
var dashCount : int
var acceleration : float
var deceleration : float
var air_acceleration : float
var air_deceleration : float
var jumpMagnitude : float
var gravityActive := true
var dashing := false
var wasMovingR := true
var current_state : Player_State
var states : Dictionary = {}
var animScaleLock : Vector2
var in_field := false
var was_on_floor := false
func _ready() -> void:
	animScaleLock = abs(PlayerSprite.scale)
	
	_calc_cached_val()
	
	for child in get_children():
		if child is Player_State:
			states[child.name] = child
			child.player = self
			child.State_Transition.connect(on_child_transition)
			#for key in states.keys():
				#print(key, "->", states[key])
	if initial_state:
		print("state set")
		current_state = initial_state
		current_state.Enter()

func _process(delta: float) -> void:
	current_state.Update(delta)
	if Input.is_action_just_pressed("toggle_view"):
		toggle_view()

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	_handle_facing()
	
	current_state.Physics_Update(delta)

func _calc_cached_val():
	acceleration = data.maxSpeed / data.timeToReachMaxSpeed
	deceleration = data.maxSpeed / data.timeToReachZeroSpeed
	
	air_acceleration = 1. * data.maxSpeed / data.timeToReachMaxSpeed
	air_deceleration = 0.05 * data.maxSpeed / data.timeToReachZeroSpeed
	
	jumpMagnitude = data.jumpHeight * data.gravityScale
	jumpCount = data.jumps
	dashCount = data.dashes

func _handle_facing():
	if dashing:
		return
	if in_field:
		PlayerSprite.scale.y = -animScaleLock.y
	if Input.is_action_pressed("right"):
		PlayerSprite.scale.x = animScaleLock.x
		wasMovingR = true 
	elif Input.is_action_pressed("left"):
		PlayerSprite.scale.x = -animScaleLock.x
		wasMovingR = false

func _apply_gravity():
	if self.is_on_floor():
		
		#print("doing the snap")
		var dot := self.velocity.dot(self.get_floor_normal())
		if dot > 0:
			self.velocity -= self.get_floor_normal()*dot*5

	if not gravityActive: 
		return

	var g = data.gravityScale

	if velocity.y > 0:
		g *= data.descendingGravityFactor
	
	velocity.y += g
	
	if velocity.y > data.terminalVelocity:
		velocity.y = data.terminalVelocity
	
func _pause_gravity(t):
	gravityActive = false
	
	await get_tree().create_timer(t).timeout
	gravityActive  = true

func _start_dash(t):
	dashing = true
	await get_tree().create_timer(t).timeout
	dashing = false

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	state.Exit()
	var new_state = states.get(new_state_name)
	if !new_state:
		return
	current_state = new_state
	new_state.Enter()
	

#view toggling
@onready var cam := $Camera2D

var zoom_normal := Vector2(4, 4)
var zoom_out := Vector2(1, 1)
var zoom_toggled := false

func toggle_view():
	zoom_toggled = !zoom_toggled
	var target_zoom = zoom_out if zoom_toggled else zoom_normal
	
	var tween := create_tween()
	tween.tween_property(cam, "zoom", target_zoom, 0.3)

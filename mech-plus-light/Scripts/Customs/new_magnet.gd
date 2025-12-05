#extends Area2D
#
#@export_category("Magnetic Field properties")
###Strength with which the magnetic field  pulls up
#@export var MStrength : float
###Width of the magnetic field
#@export var MWidth : float
###Height of the magnetic field
#@export var MHeight : float
#
#var player_in := false
#var player : CharacterBody2D
#var field : CollisionShape2D
#var dirM : Vector2
#
#func _ready() -> void:
	#self.body_entered.connect(_fent)
	#self.body_exited.connect(_fext)
	#field = self.get_child(0)
	#if field:
		#print("chid found")
		#field.shape.size.x = MWidth
		#field.shape.size.y = MHeight
		#field.position.y = (MHeight)
#
#func _process(_delta: float) -> void:
	#dirM = _calc_vect()
	#print("Direct of Pull is: ", + dirM)
	#_attract(dirM)
#
#func _attract(vect):
	#if player:
		#print("Velocity of player is: ", player.velocity)
		#player.velocity += MStrength*vect
#
#func _calc_vect():
	#if not player:
		#return Vector2.ZERO
	#if player:
		#var diff := player.global_position - self.global_position
		#var dir := Vector2.ZERO
		#if abs(diff.x) > abs(diff.y):
			#dir.x = sign(-diff.x)
		#else:
			#dir.y = sign(-diff.y)
		#return dir
#func _fext(body):
	#if body.is_in_group("object"):
		#print("player out")
		#player_in = false
		#player.in_field = false
		#player = null
#
#func _fent(body):
	#if body.is_in_group("object"):
		#print("player in")
		#player_in = true
		#player = body
		#player.in_field = true

extends Area2D

@export var increased_gravity : float = 2000.0    # when magnet is below player (on ground)
@export var decreased_gravity : float = 300.0     # when magnet is above player (on ceiling)

var player : CharacterBody2D = null
var original_gravity := 0.0

func _on_body_entered(body):
	if body is CharacterBody2D:
		print("I am here")
		player = body
		# store original gravity
		original_gravity = player.get_gravity_value()

		# check relative position
		if global_position.y > player.global_position.y:
			# magnet is below → increase gravity
			player.change_gravity(increased_gravity)
			#player.gravity = increased_gravity
		else:
			# magnet is above → decrease gravity
			player.change_gravity(increased_gravity)
			#player.gravity = decreased_gravity

func _on_body_exited(body):
	if body == player:
		print("I am going")
		# restore original gravity
		player.change_gravity(original_gravity)
 		#player.gravity = original_gravity
		player = null

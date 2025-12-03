extends Node2D

@export_category("Required Nodes")
##The sprite of the magnet itself
@export var MSprite : Texture2D

@export_category("Magnetic Field properties")
##Strength with which the magnetic field  pulls up
@export var MStrength : float
##Width of the magnetic field
@export var MWidth : float
##Height of the magnetic field
@export var MHeight : float


#working variables
var player_in := false
var player : CharacterBody2D
var dist_vect : Vector2
var spritedim : Vector2
var magnet_tip : Vector2

func _ready() -> void:
	_make_magnet()

func _process(delta: float) -> void:
	_vect_calc()
	#print(dist_vect)
	#insert a condition here for turning the magnet on and off if you want, or make me
	_attract(dist_vect)


func _vect_calc():
	magnet_tip.y = (spritedim.y/2) 
	if player:
		dist_vect = (player.global_position  - magnet_tip).normalized()
	else:
		dist_vect = Vector2.ZERO
func _attract(dist:Vector2):
	if player:
		player.velocity.y += dist.y * MStrength
		player.velocity.x += -dist.x * MStrength

func _make_magnet():
	var field := Area2D.new()
	var sprite := Sprite2D.new()
	var field_shape := CollisionShape2D.new()
	var field_dimensions := RectangleShape2D.new()
	field_dimensions.size.x = MWidth
	field_dimensions.size.y = MHeight
	
	sprite.texture = MSprite
	spritedim = sprite.texture.get_size()

	
	self.add_child(sprite)
	self.add_child(field)
	field.add_child(field_shape)
	field_shape.shape = field_dimensions
	
	field.position.y = (spritedim.y/2) + (field_dimensions.size.y/2)
	field.monitoring = true
	field.collision_layer = 1
	field.collision_mask = 2
	field.body_entered.connect(_fent)
	field.body_exited.connect(_fext)

func _fext(body):
	if body.is_in_group("object"):
		print("player out")
		player_in = false
		player = null
func _fent(body):
	if body.is_in_group("object"):
		print("player in")
		player_in = true
		player = body

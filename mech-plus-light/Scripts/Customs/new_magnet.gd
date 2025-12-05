extends Area2D

@export_category("Magnetic Field properties")
##Strength with which the magnetic field  pulls up
@export var MStrength : float
##Width of the magnetic field
@export var MWidth : float
##Height of the magnetic field
@export var MHeight : float

var player_in := false
var player : CharacterBody2D
var field : CollisionShape2D
var dirM : Vector2

func _ready() -> void:
	self.body_entered.connect(_fent)
	self.body_exited.connect(_fext)
	field = self.get_child(0)
	if field:
		print("chid found")
		field.shape.size.x = MWidth
		field.shape.size.y = MHeight
		field.position.y = (MHeight)

func _process(_delta: float) -> void:
	dirM = _calc_vect()
	_attract(dirM)

func _attract(vect):
	if player:
		player.velocity += MStrength*vect

func _calc_vect():
	if not player:
		return Vector2.ZERO
	if player:
		var diff := player.global_position - self.global_position
		var dir := Vector2.ZERO
		if abs(diff.x) > abs(diff.y):
			dir.x = sign(-diff.x)
		else:
			dir.y = sign(-diff.y)
		return dir
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

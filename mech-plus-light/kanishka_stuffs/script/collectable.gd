extends Area2D
@onready var collectable: Sprite2D = $Coin
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup: AudioStreamPlayer2D = $pickup

var coinscore=0
func _on_body_entered(_body) -> void:
	coinscore=coinscore+1
	collectable.visible=false
	collision_shape_2d.disabled=true
	pickup.playing=true
	print ("your collected a coin")

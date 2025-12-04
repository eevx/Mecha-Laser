extends Area2D
@onready var collectable: Sprite2D = $Coin
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup: AudioStreamPlayer2D = $pickup
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var coinscore=0
func _on_body_entered(_body) -> void:
	coinscore=coinscore+1
	collectable.visible=false


	print ("your collected a coin")
	animation_player.play("new_animation")

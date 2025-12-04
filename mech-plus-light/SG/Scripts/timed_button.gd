extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer 
@export var moving_platform: PackedScene


func _on_body_entered(_body: Node2D) -> void:
	if not timer.is_stopped():
		return 
		
	animated_sprite_2d.play("Press Down")
	timer.start()
	var platform = moving_platform.instantiate()
	get_parent().add_child(platform)
	platform.name = "chaltahua"
	


func _on_timer_timeout() -> void:
	print("TIMEOUT - Unpressing Button")
	animated_sprite_2d.play("Press Up")
	timer.stop()
	var target := get_node_or_null("../chaltahua")
	if target:
		target.queue_free()
	

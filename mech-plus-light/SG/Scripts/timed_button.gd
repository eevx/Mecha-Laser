extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer 


func _on_body_entered(body: Node2D) -> void:
	if not timer.is_stopped():
		return 
		
	animated_sprite_2d.play("Press Down")
	timer.start()


func _on_timer_timeout() -> void:
	print("TIMEOUT - Unpressing Button")
	animated_sprite_2d.play("Press Up")
	timer.stop()
	
	

extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body) -> void:
	print("you ded")
	Engine.time_scale = 0.2
	timer.start()



func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1

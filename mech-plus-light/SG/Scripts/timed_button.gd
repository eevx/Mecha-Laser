extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer 

var player_is_in = false
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = true


func _input(event: InputEvent) -> void:
	if player_is_in:
		if Input.is_action_pressed("button_interact") and event.is_pressed():
			print("e pressed")
			if not timer.is_stopped():
				return 
			
			animated_sprite_2d.play("Press Down")
			timer.start()
			#is_on = !is_on
			#if is_on:
				#print("on")
				#sprite_2d.texture = button_tex_1
			#else:
				#print("off")
				#sprite_2d.texture = button_tex_2

func _on_timer_timeout() -> void:
	print("TIMEOUT - Unpressing Button")
	animated_sprite_2d.play("Press Up")
	timer.stop()
	

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false

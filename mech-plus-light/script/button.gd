extends Area2D

var is_on = false

#func _input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton and event.pressed:
		#is_on = !is_on
		#
		#if is_on:
			#$Sprite2D.texture = preload("res://.godot/imported/CGB02-green_M_btn.png-344e7e5052ba59cab36bd6d31803666a.ctex")
		#else:
			#$Sprite2D.texture = preload("res://.godot/imported/CGB02-red_M_btn.png-328e7a623089bff89dbfd65914627f21.ctex")


func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		is_on = !is_on
		
		if is_on:
			$Sprite2D.texture = preload("res://.godot/imported/CGB02-green_M_btn.png-344e7e5052ba59cab36bd6d31803666a.ctex")
		else:
			$Sprite2D.texture = preload("res://.godot/imported/CGB02-red_M_btn.png-328e7a623089bff89dbfd65914627f21.ctex")

extends Area2D




func _on_body_entered(body: Node2D) -> void:
	print("Inside coin")
	queue_free()

extends Node2D



func _on_killzone_body_entered(_body: Node2D) -> void:

	get_tree().reload_current_scene()

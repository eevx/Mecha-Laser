extends Node2D

func _on_killzone_area_entered(_area: Area2D) -> void:
	get_tree().reload_current_scene()

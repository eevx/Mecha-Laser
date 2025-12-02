# OutputPortal.gd
extends Node2D

@export var color: Color = Color.RED
@export var exit_face_name: String = "ExitFace"  # Marker2D child

func get_exit_info() -> Dictionary:
	# returns {"exit_position": Vector2, "exit_normal": Vector2, "node": self}
	if not has_node(exit_face_name):
		push_error("OutputPortal missing ExitFace Marker2D")
		return {"exit_position": global_position, "exit_normal": Vector2.RIGHT, "node": self}

	var face := get_node(exit_face_name) as Node2D
	var exit_pos := face.global_position
	var exit_normal := Vector2.RIGHT.rotated(face.global_rotation).normalized()
	return {"exit_position": exit_pos, "exit_normal": exit_normal, "node": self}

func is_output_portal() -> bool:
	return true

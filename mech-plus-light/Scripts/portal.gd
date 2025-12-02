# Portal.gd
extends Node2D

@export var face_a_name: String = "FaceA"
@export var face_b_name: String = "FaceB"

func is_portal() -> bool:
	return true

# Return a dictionary with exit info for a hit near this portal.
# Input: hit_world_pos = world-space point where ray hit entry collider.
# Output: {"exit_position": Vector2, "exit_normal": Vector2}
func get_other_face(hit_world_pos: Vector2) -> Dictionary:
	# Ensure face nodes exist
	if not has_node(face_a_name) or not has_node(face_b_name):
		push_error("Portal missing FaceA or FaceB children.")
		return {"exit_position": global_position, "exit_normal": Vector2.RIGHT}

	var face_a := get_node(face_a_name) as Node2D
	var face_b := get_node(face_b_name) as Node2D

	# Decide which face was hit by comparing distances to the two face origins.
	var d_a := hit_world_pos.distance_to(face_a.global_position)
	var d_b := hit_world_pos.distance_to(face_b.global_position)

	var from_face: Node2D = face_a
	var to_face: Node2D = face_b
	if d_b < d_a:
		from_face = face_b
		to_face = face_a

	# exit position = the other face's global position
	var exit_position: Vector2 = to_face.global_position
	# exit normal is the face's local +X in world space (perpendicular to face)
	var exit_normal: Vector2 = Vector2.RIGHT.rotated(to_face.global_rotation).normalized()

	return {
		"exit_position": exit_position,
		"exit_normal": exit_normal
	}

# OutputPortal.gd
extends Node2D
class_name SlavePortal

@export_enum("RED", "BLUE", "GREEN") var color_of_the_portal : String = "RED"
var color: Color
@export var exit_face_name: String = "ExitFace"  # Marker2D child name
@export var is_casting: bool = false : set = set_is_casting
@export var beam_width : float = 80.
@onready var laser: Light = null

func _ready() -> void:
	match color_of_the_portal:
		"RED":
			color = Color.RED
		"BLUE":
			color = Color.BLUE
		"GREEN":
			color = Color.GREEN
	# Ensure the Laser child exists and is a Light instance
	if has_node("Laser"):
		var node = get_node("Laser")
		if node is Light:
			laser = node as Light
		else:
			push_error("SlavePortal: 'Laser' child exists but is not a Light.")
			laser = null
	else:
		push_error("SlavePortal: missing child node 'Laser' (expected a Light).")
		laser = null

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	laser.beam_width = beam_width
	# propagate to the Laser child if present
	if laser:
		laser.is_casting = is_casting

func stop() -> void:
	# convenience to stop this portal
	set_is_casting(false)

func get_exit_info() -> Dictionary:
	# returns {"exit_position": Vector2, "exit_normal": Vector2, "node": self}
	# If the exit face isn't present, fallback to the portal transform and a default normal.
	if not has_node(exit_face_name):
		push_warning("SlavePortal: ExitFace Marker2D not found — using portal transform as fallback.")
		return {
			"exit_position": global_position,
			"exit_normal": Vector2.RIGHT.rotated(global_rotation).normalized(),
			"node": self
		}

	var face := get_node(exit_face_name) as Node2D
	var exit_pos := face.global_position
	var exit_normal := Vector2.RIGHT.rotated(face.global_rotation).normalized()
	return {"exit_position": exit_pos, "exit_normal": exit_normal, "node": self}

func is_output_portal() -> bool:
	return true

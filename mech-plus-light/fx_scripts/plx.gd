extends Node
class_name Plx

@export_range(-30, 30) var depth := 0 ### -20 to +30 

var _node : Node2D
var _init_pos : Vector2

func _ready() -> void:
	if get_parent() is Node2D:
		_node = get_parent()
		_init_pos = _node.position
		_node.z_index = depth
		_node.scale *= (1. + float(depth) / 30.)
		#if depth > 0: 
			#_node.light_mask = 2**1
		#_node.modulate = lerp(Color.WHITE, Color.BLACK, float(abs(depth))/5.)
	else:
		queue_free()

func _physics_process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if not _node or not camera:
		return
	
	var parent_offset = _node.global_position - _node.position
	var camera_pos = camera.global_position - parent_offset
	var offset = camera_pos - _init_pos
	var true_depth : float = -float(depth) / 30.
	_node.position = _init_pos + offset * true_depth

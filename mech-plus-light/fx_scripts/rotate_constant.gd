extends Node
class_name RotateConstant

enum DIR {CW, ACW}
var _node: Node2D
@export var rotation_speed := 0.3;
@export var dir := DIR.CW;

func _ready() -> void:
	if get_parent() is Node2D:
		_node = get_parent()
	else:
		queue_free()
		return

func _process(delta: float) -> void:
	if not _node:
		return
	var d = 1 if dir == DIR.CW else -1
	_node.rotation += d * rotation_speed * delta;

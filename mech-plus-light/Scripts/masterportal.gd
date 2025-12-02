# MasterPortal.gd
extends Node2D

@export var color: Color = Color.RED
@export var outputs_parent_name: String = "OutputsParent"  # Node containing outputs (optional)
# optional: if you want explicit outputs, export NodePath array; for now we auto-collect children under outputs_parent

func is_master_portal() -> bool:
	return true

func get_matching_outputs() -> Array:
	var out := []
	if get_parent().has_node(outputs_parent_name):
		print("I got some parents here")
		var parent := get_parent().get_node(outputs_parent_name) as Node
		for child in parent.get_children():
			print("I got some child which can be output")
			if child == null: continue
			# child may be OutputPortal or a node with OutputPortal.gd
			print("Child is non empty")
			if child.has_method("get_exit_info") and child.has_method("is_output_portal"):
				var info : Dictionary = child.get_exit_info()
				# color match: exact match (you can add tolerance)
				print("Child is having the functions")
				if child.color == color:
					out.append(info)
					print("I got an output portal")
	print("I am returning from the function")
	print("The size of the out array is : ", out.size())
	return out

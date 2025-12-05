# MasterPortal.gd
extends Node2D

@export_enum("RED", "BLUE", "GREEN") var color_of_the_portal : String = "RED"
var color := Color.RED
#@export var outputs_parent_name: String = "OutputsParent"  # Node containing outputs (optional)
# optional: if you want explicit outputs, export NodePath array; for now we auto-collect children under outputs_parent
func _ready() -> void:
	match color_of_the_portal:
		"RED":
			color = Color.RED
		"BLUE":
			color = Color.BLUE
		"GREEN":
			color = Color.GREEN
func is_master_portal() -> bool:
	return true

func get_matching_outputs() -> Array:
	var out := []
	var portals = self.get_parent() as Node
	for child in portals.get_children():
		#print("I got some child which can be output")
		if child == null: continue
			# child may be OutputPortal or a node with OutputPortal.gd
		#print("Child is non empty")
		if child.has_method("get_exit_info") and child.has_method("is_output_portal"):
			var info : Dictionary = child.get_exit_info()
				# color match: exact match (you can add tolerance)
			#print("Child is having the functions")
			if child.color == color:
				out.append(info)
				#print("I got an output portal")
	#print("I am returning from the function")
	#print("The size of the out array is : ", out.size())
	return out

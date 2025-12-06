extends Node

class_name Player_State
signal State_Transition(state, new_state: String)

var player : Player
func Enter():
	pass

func Exit():
	pass

func Update(_delta:float):
	pass

func Physics_Update(_delta:float):
	pass

func Transition(new_state:String):
	print("[STATE] ", self.name, " -> transition requested: '", new_state, "'")
	State_Transition.emit(self,new_state)

extends CanvasLayer

enum {mainmenu, cutscene0, lvl1,  cutscene1, lvl2,  cutscene2, lvl3, cutscene3,  end}

@onready var MainMenuScene 
@onready var EndScene 
@onready var CutScene0 
@onready var CutScene1 
@onready var CutScene2  
@onready var CutScene3 
@onready var lvl1Scene = "res://lvl1-1.tscn"
@onready var lvl2Scene = "res://lvl2.tscn"
@onready var lvl3Scene = "res://level_3-1.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var transition: ColorRect = $Transition


func change_scene(SceneName: String):
	get_tree().paused = false
	var newScene: String
	match SceneName:
		"cutscene0":
			newScene = CutScene0
		"lvl1":
			newScene = lvl1Scene
		"cutscene1":
			newScene = CutScene1
		"lvl2":
			newScene = lvl2Scene
		"cutscene2":
			newScene = CutScene2
		"lvl3":
			newScene = lvl3Scene
		"cutscene3":
			newScene = CutScene3
		"end":
			newScene = EndScene
	
	get_tree().change_scene_to_file(newScene)

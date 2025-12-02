class_name SubMenu

extends Control

@onready var lv1: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/Control/lv1


@onready var GAME = preload("res://Scenes/Defaults(guide)/game.tscn") as PackedScene
func _ready():
	lv1.button_down.connect(self.on_lv1_pressed)
	
func on_lv1_pressed() ->void:
	get_tree().change_scene_to_packed(GAME)

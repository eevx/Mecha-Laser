class_name main_menu
extends Control

@onready var button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Button as Button

@onready var button_2: Button = $MarginContainer/HBoxContainer/VBoxContainer/Button2 as Button

@onready var sub_menu = preload("res://Scenes/Defaults(guide)/sub_menu.tscn")

func _ready():
	button.button_down.connect(on_start_pressed)
	button_2.button_down.connect(on_exit_pressed)
	
func on_start_pressed() ->void:
	get_tree().change_scene_to_packed(sub_menu)
func on_exit_pressed() -> void:
	get_tree().quit()

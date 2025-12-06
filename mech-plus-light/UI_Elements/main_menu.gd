extends Control
@export var main_menu : VBoxContainer
@export var level_selector : VBoxContainer
@export var options_screen : VBoxContainer
@export var title_screen_bg : Sprite2D
@export var title : Label

@export var level_1 : PackedScene
@export var level_2 : PackedScene
@export var level_3 : PackedScene
@export var audio_scene : PackedScene

@export var bg : CompressedTexture2D
@export var bg_blurred : CompressedTexture2D

func _ready() -> void:
	for b : TextureButton in level_selector.get_children() + options_screen.get_children():
		b.disabled = true
	level_selector.hide()
	options_screen.hide()

func _on_start_pressed() -> void:
	title.hide()
	title_screen_bg.texture = bg_blurred
	level_selector.show()
	for b : TextureButton in level_selector.get_children():
		b.disabled = false

func _on_options_pressed() -> void:
	title.hide()
	title_screen_bg.texture = bg_blurred
	show_options(true)
	show_main_menu_screen(false)


func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_packed(level_1)


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_packed(level_2)


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_packed(level_3)


func _on_main_menu_button_pressed() -> void:
	title.show()
	title_screen_bg.texture = bg
	show_level_selector(false)
	show_options(false)
	show_main_menu_screen(true)


func _on_audio_pressed() -> void:
	get_tree().change_scene_to_packed(audio_scene)


func _on_keymapping_pressed() -> void:
	pass # Replace with function body.

func show_options(value : bool= true):
	if value == true:
		for b : TextureButton in options_screen.get_children():
			b.disabled = false
		options_screen.show()
	else:
		for b : TextureButton in options_screen.get_children():
			b.disabled = true
		options_screen.hide()
		
func show_level_selector(value : bool= true):
	if value == true:
		for b : TextureButton in level_selector.get_children():
			b.disabled = false
		level_selector.show()
	else:
		for b : TextureButton in level_selector.get_children():
			b.disabled = true
		level_selector.hide()
		
func show_main_menu_screen(value : bool= true):
	if value == true:
		for b : TextureButton in main_menu.get_children():
			b.disabled = false
		main_menu.show()
	else:
		for b : TextureButton in main_menu.get_children():
			b.disabled = true
		main_menu.hide()

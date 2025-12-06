extends Area2D

var is_on = false
var player_is_in = false

@export var button_tex_1 : Texture
@export var button_tex_2 : Texture
@export var sprite_2d : Sprite2D

@export var platform: Node2D
var platform_parent: Node

@export var mirror: Node2D
var mirror_parent: Node

@export var moving_platform: Node2D

# NEW: optional "popped into existence" object
@export var new_object: Node2D

@export var newer_object: Node2D

@export var magnet: Node2D
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
# NEW: optional light this button controls

@export var disappear_on_active_1 := true
@export var disappear_on_active_2 := true
@export var stop_on_active := true

func _ready() -> void:
	if platform:
		platform_parent = platform.get_parent()
	if mirror:
		mirror_parent = mirror.get_parent()
	# NEW: start with new_object hidden/disabled
	if magnet: 
		magnet.disable_magnet()
	_hide_new_object()
	#_hide_newer_object()

func _on_body_entered(_body: Node2D) -> void:
	if _body is CharacterBody2D:
		player_is_in = true
		print("area entered")

func _input(event: InputEvent) -> void:
	if player_is_in:
		if Input.is_action_pressed("button_interact") and event.is_pressed():
			print("e pressed")
			is_on = !is_on
			if is_on:
				print("on")
				sprite_2d.texture = button_tex_1

				if disappear_on_active_1: 
					_remove_platform_from_scene()
				else: 
					_add_platform_to_scene()

				if disappear_on_active_2:
					_remove_mirror_from_scene()
				else: 
					_add_mirror_to_scene()

				if stop_on_active: 
					_stop_moving_platform()
				else:
					_move_moving_platform()
				if magnet:
					magnet.enable_magnet()# NEW: when ON → show object 
				_show_new_object()
<<<<<<< Updated upstream
<<<<<<< Updated upstream
				#_show_newer_object()

=======
				
>>>>>>> Stashed changes
=======
				
>>>>>>> Stashed changes
			else:
				print("off")
				sprite_2d.texture = button_tex_2

				if !disappear_on_active_1: 
					_remove_platform_from_scene()
				else: 
					_add_platform_to_scene()

				if !disappear_on_active_2:
					_remove_mirror_from_scene()
				else: 
					_add_mirror_to_scene()

				if !stop_on_active: 
					_stop_moving_platform()
				else:
					_move_moving_platform()
				if magnet: 
					magnet.disable_magnet()# NEW: when OFF → hide object
				_hide_new_object()
				#_hide_newer_object()
func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false
		print("area entered")

func _remove_platform_from_scene() -> void:
	if platform and platform_parent and platform.get_parent():
		platform_parent.remove_child(platform)

func _add_platform_to_scene() -> void:
	if platform and platform_parent and not platform.get_parent():
		platform_parent.add_child(platform)

func _remove_mirror_from_scene() -> void:
	if mirror and mirror_parent and mirror.get_parent():
		mirror_parent.remove_child(mirror)

func _add_mirror_to_scene() -> void:
	if mirror and mirror_parent and not mirror.get_parent():
		mirror_parent.add_child(mirror)
		
func _stop_moving_platform() -> void: 
	if moving_platform:
		moving_platform.change_speed(0)

func _move_moving_platform() -> void:
	if moving_platform:
		moving_platform.change_speed(moving_platform.get_og_speed()) 

# NEW: show/hide object instead of removing from tree
func _hide_new_object() -> void:
	if new_object:
		new_object.visible = false
		if new_object.has_node("CollisionShape2D"):
			new_object.get_node("CollisionShape2D").disabled = true

func _show_new_object() -> void:
	if new_object:
		new_object.visible = true
		if new_object.has_node("CollisionShape2D"):
			new_object.get_node("CollisionShape2D").disabled = false
			
#func _hide_newer_object() -> void:
	#if newer_object:
		#newer_object.visible = false
		#if newer_object.has_node("CollisionShape2D"):
			#newer_object.get_node("CollisionShape2D").disabled = true
#
#func _show_newer_object() -> void:
	#if newer_object:
		#newer_object.visible = true
		#if newer_object.has_node("CollisionShape2D"):
			#newer_object.get_node("CollisionShape2D").disabled = false

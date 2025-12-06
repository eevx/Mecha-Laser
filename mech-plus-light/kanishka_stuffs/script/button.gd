extends Area2D

var is_on: bool = false
var player_is_in: bool = false

@export var button_tex_1: Texture2D
@export var button_tex_2: Texture2D
@export var sprite_2d: Sprite2D

@export var platform: Node2D
var platform_parent: Node

@export var mirror: Node2D
var mirror_parent: Node

@export var moving_platform: Node2D

# Optional "popped into existence" object
@export var new_object: Node2D
@export var newer_object: Node2D

@export var magnet: Node2D

@export var disappear_on_active_1 := true
@export var disappear_on_active_2 := true
# stop_on_active removed – behavior is now fixed: ON = move, OFF = stop

func _ready() -> void:
	if platform:
		platform_parent = platform.get_parent()

	if mirror:
		mirror_parent = mirror.get_parent()
		_remove_mirror_from_scene()

	# Start with magnet disabled
	if magnet:
		magnet.disable_magnet()

	# Start with new_object hidden/disabled
	_hide_new_object()
	# _hide_newer_object()

	# IMPORTANT:
	# Defer stopping the moving platform so its own _ready()
	# can store its original speed first.
	if moving_platform:
		call_deferred("_stop_moving_platform")


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = true
		print("area entered")


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false
		print("area exited")


func _input(event: InputEvent) -> void:
	if not player_is_in:
		return

	# Simpler & safer: use event.is_action_pressed
	if event.is_action_pressed("button_interact"):
		print("e pressed")
		is_on = !is_on

		if is_on:
			_turn_on()
		else:
			_turn_off()


func _turn_on() -> void:
	print("on")
	if sprite_2d and button_tex_1:
		sprite_2d.texture = button_tex_1

	# Platform visibility / presence
	if disappear_on_active_1:
		_remove_platform_from_scene()
	else:
		_add_platform_to_scene()

	# Mirror
	if disappear_on_active_2:
		_add_mirror_to_scene()
	else:
		_remove_mirror_from_scene()

	# When ON → start platform moving
	_move_moving_platform()

	# Magnet ON
	if magnet:
		magnet.enable_magnet()

	# Show object
	_show_new_object()
	# _show_newer_object()


func _turn_off() -> void:
	print("off")
	if sprite_2d and button_tex_2:
		sprite_2d.texture = button_tex_2

	# Platform visibility / presence (inverse logic)
	if not disappear_on_active_1:
		_remove_platform_from_scene()
	else:
		_add_platform_to_scene()

	# Mirror (inverse)
	if not disappear_on_active_2:
		_remove_mirror_from_scene()
	else:
		_add_mirror_to_scene()

	# When OFF → stop platform
	_stop_moving_platform()

	# Magnet OFF
	if magnet:
		magnet.disable_magnet()

	# Hide object
	_hide_new_object()
	# _hide_newer_object()


# ------------ Platform & mirror helpers ------------

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


# ------------ Moving platform control ------------

func _stop_moving_platform() -> void:
	if moving_platform and moving_platform.has_method("change_speed"):
		# Stop the platform
		moving_platform.change_speed(0.0)


func _move_moving_platform() -> void:
	if moving_platform and moving_platform.has_method("change_speed") and moving_platform.has_method("get_og_speed"):
		var og_speed = moving_platform.get_og_speed()
		moving_platform.change_speed(og_speed)


# ------------ Show/hide spawned object ------------

func _hide_new_object() -> void:
	if new_object:
		new_object.visible = false
		if new_object.has_node("CollisionShape2D"):
			var col = new_object.get_node("CollisionShape2D")
			if col is CollisionShape2D:
				col.disabled = true


func _show_new_object() -> void:
	if new_object:
		new_object.visible = true
		if new_object.has_node("CollisionShape2D"):
			var col = new_object.get_node("CollisionShape2D")
			if col is CollisionShape2D:
				col.disabled = false


# If you want the newer_object too, just uncomment + wire it up in the editor.
# func _hide_newer_object() -> void:
# 	if newer_object:
# 		newer_object.visible = false
# 		if newer_object.has_node("CollisionShape2D"):
# 			var col = newer_object.get_node("CollisionShape2D")
# 			if col is CollisionShape2D:
# 				col.disabled = true
#
# func _show_newer_object() -> void:
# 	if newer_object:
# 		newer_object.visible = true
# 		if newer_object.has_node("CollisionShape2D"):
# 			var col = newer_object.get_node("CollisionShape2D")
# 			if col is CollisionShape2D:
# 				col.disabled = false

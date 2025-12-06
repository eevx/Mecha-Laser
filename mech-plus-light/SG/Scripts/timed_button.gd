extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer 

var player_is_in = false
var is_on = false

# --------------------------------------------------
# Objects this timer button can control
# --------------------------------------------------

@export var platform: AnimatableBody2D
var platform_parent: Node

@export var mirror: AnimatableBody2D
var mirror_parent: Node

@export var moving_platform: AnimatableBody2D

# an optional object that appears/disappears
@export var new_object: Node2D

@export var disappear_on_active_1 := true     # platform disappears when ON
@export var disappear_on_active_2 := true     # mirror disappears when ON
@export var stop_on_active := true            # moving platform stops when ON


# --------------------------------------------------
# READY
# --------------------------------------------------

func _ready() -> void:
	if platform:
		platform_parent = platform.get_parent()

	if mirror:
		mirror_parent = mirror.get_parent()

	# new_object starts hidden
	_hide_new_object()


# --------------------------------------------------
# Player enters trigger
# --------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = true


# --------------------------------------------------
# Input
# --------------------------------------------------

func _input(event: InputEvent) -> void:
	if not player_is_in:
		return

	if Input.is_action_pressed("button_interact") and event.is_pressed():
		# Prevent re-triggering while timer runs
		if not timer.is_stopped():
			return

		animated_sprite_2d.play("Press Down")
		timer.start()
		_activate_behavior()


# --------------------------------------------------
# Timer ends → turn OFF again
# --------------------------------------------------

func _on_timer_timeout() -> void:
	animated_sprite_2d.play("Press Up")
	timer.stop()
	_deactivate_behavior()


# --------------------------------------------------
# Player exits trigger
# --------------------------------------------------

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_is_in = false


# ==================================================
# ON / OFF BEHAVIOR (THIS IS WHAT YOU REQUESTED)
# ==================================================

func _activate_behavior() -> void:
	is_on = true

	# platform
	if disappear_on_active_1:
		_remove_platform()
	else:
		_add_platform()

	# mirror
	if disappear_on_active_2:
		_remove_mirror()
	else:
		_add_mirror()

	# moving platform
	if stop_on_active:
		_stop_moving_platform()
	else:
		_move_moving_platform()

	# extra object
	_show_new_object()


func _deactivate_behavior() -> void:
	is_on = false

	# platform
	if not disappear_on_active_1:
		_remove_platform()
	else:
		_add_platform()

	# mirror
	if not disappear_on_active_2:
		_remove_mirror()
	else:
		_add_mirror()

	# moving platform
	if not stop_on_active:
		_stop_moving_platform()
	else:
		_move_moving_platform()

	# extra object
	_hide_new_object()


# ==================================================
# HELPER FUNCTIONS
# ==================================================

func _remove_platform() -> void:
	if platform and platform_parent and platform.get_parent():
		platform_parent.remove_child(platform)

func _add_platform() -> void:
	if platform and platform_parent and not platform.get_parent():
		platform_parent.add_child(platform)


func _remove_mirror() -> void:
	if mirror and mirror_parent and mirror.get_parent():
		mirror_parent.remove_child(mirror)

func _add_mirror() -> void:
	if mirror and mirror_parent and not mirror.get_parent():
		mirror_parent.add_child(mirror)


func _stop_moving_platform() -> void:
	if moving_platform:
		moving_platform.change_speed(0)

func _move_moving_platform() -> void:
	if moving_platform:
		moving_platform.change_speed(moving_platform.get_og_speed())


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

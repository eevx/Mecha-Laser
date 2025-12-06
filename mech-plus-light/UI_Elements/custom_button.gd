extends Label
class_name CustomButton

signal pressed

@export var texture_normal: Texture2D
@export var texture_hover: Texture2D
@export var texture_pressed: Texture2D
@export var texture_disabled: Texture2D

@export var hover_scale: float = 1.08
@export var hover_time: float = 0.12
@export var press_scale: float = 0.95
@export var press_time: float = 0.06

@export var disabled: bool = false : set = set_disabled
@export var play_click_sound: bool = true

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var area: Area2D = get_node_or_null("Area2D") as Area2D
@onready var click_sound: AudioStreamPlayer2D = get_node_or_null("ClickSound") as AudioStreamPlayer2D

var _mouse_inside: bool = false
var _is_pressed: bool = false
var _tween: Tween = null

func _ready() -> void:
	# Basic sanity checks
	if not sprite:
		push_warning("CustomButton: missing child node 'Sprite2D'. Click visuals won't work.")
	if not area:
		push_warning("CustomButton: missing child node 'Area2D'. Clicks won't be detected.")
	else:
		# Make sure there's a CollisionShape2D so input is detected
		var cs := area.get_node_or_null("CollisionShape2D") or area.get_node_or_null("CollisionPolygon2D")
		if not cs:
			push_warning("CustomButton: Area2D has no CollisionShape2D/CollisionPolygon2D. Add one to receive clicks.")
		# Connect signals safely (only if area exists)
		area.mouse_entered.connect(Callable(self, "_on_mouse_entered"))
		area.mouse_exited.connect(Callable(self, "_on_mouse_exited"))
		area.input_event.connect(Callable(self, "_on_area_input_event"))

	# Set initial visuals
	_update_visual()

func set_disabled(value: bool) -> void:
	disabled = value
	_is_pressed = false
	_mouse_inside = false
	_update_visual()
	scale = Vector2.ONE

# SIGNAL CALLBACKS
func _on_mouse_entered() -> void:
	if disabled:
		return
	_mouse_inside = true
	if not _is_pressed:
		_play_scale(hover_scale, hover_time)
		_update_visual()

func _on_mouse_exited() -> void:
	_mouse_inside = false
	if not _is_pressed:
		_play_scale(1.0, hover_time)
		_update_visual()

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if disabled:
		return
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_pressed = true
			_play_scale(press_scale, press_time)
			_update_visual()
		else:
			if _is_pressed and _mouse_inside:
				_emit_click()
			_is_pressed = false
			if _mouse_inside:
				_play_scale(hover_scale, hover_time)
			else:
				_play_scale(1.0, hover_time)
			_update_visual()

func _emit_click() -> void:
	if click_sound and play_click_sound:
		click_sound.play()
	emit_signal("pressed")

# VISUALS
func _update_visual() -> void:
	if not sprite:
		return
	if disabled and texture_disabled:
		sprite.texture = texture_disabled
		return
	if _is_pressed and texture_pressed:
		sprite.texture = texture_pressed
		return
	if _mouse_inside and texture_hover:
		sprite.texture = texture_hover
		return
	sprite.texture = texture_normal

func _play_scale(target: float, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "scale", Vector2(target, target), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

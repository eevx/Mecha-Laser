extends Area2D
class_name Portal

@export_enum("RED","GREEN","BLUE") var portal_color := "RED"
enum portal_type {ENTER,EXIT}
@export var sprite : Sprite2D
signal light_entered(portal_color, portal_type)

func _ready() -> void:
	#change this after asset comes
	match portal_color:
		"RED":
			sprite.modulate = Color.RED
		"BLUE":
			sprite.modulate = Color.BLUE
		"GREEN":
			sprite.modulate = Color.GREEN
	light_entered.connect(_on_light_entered)

func _on_area_entered(area: Area2D) -> void:
	emit_signal("light_entered",portal_color, portal_type.ENTER)

func _on_light_entered(_portal_color, _portal_type):
	if _portal_type == portal_type.ENTER:
		pass
	if _portal_type == portal_type.EXIT:
		pass
		

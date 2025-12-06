extends Area2D
class_name Hurtbox
#Uncomment names to use it
#I used classes here to signify objecs such as pickups, Hazards,Light etc that may interact with body
# if the above explaination is not sufficient, 
#each of the objects that are referenced in the functions are the objects that you are presumably working with.
#Replace their names here with the appropriate conditionals for your object.
#var _player : Player
#
#func _ready():
	#if not get_parent() is Player:
		#queue_free()
		#return
	#else: 
		#_player = get_parent()
#
#func _on_body_entered(body: Node2D) -> void:
	#var direction = (body.global_position - _player.global_position).normalized()
	#if body is Keys:
		#_player.get_key()
	#if body is Pickup:
		#_player.handle_pickup(body.get_name()) #assuming getname is a function of the Pickups class
	#if body is DangerousLight:
		#_player.hit_by_light(direction)
	#if body is Hazards:
		#_play_death_animation()
#
#
#func _on_area_entered(area: Area2D) -> void:
	#var direction = (area.global_position - _player.global_position).normalized()
	#if area is Keys:
		#_player.get_key()
	#if area is Pickup:
		#_player.handle_pickup(area.get_name()) #assuming getname is a function of the Pickups class
	#if area is DangerousLight:
		#_player.hit_by_light(direction)
	#if area is Hazards:
		#_play_death_animation()
#
#func _play_death_animation() -> void:
	#_player.PlayerSprite.play("death")
	#_player.velocity = Vector2.ZERO
	#_player.set_physics_process(false)
	#
	#await _player.PlayerSprite.animation_finished
	#
	#get_tree().reload_current_scene()

class_name Light
extends RayCast2D

@export var cast_speed := 7000.0
## Maximum length of the laser in pixels.
@export var max_length := 1400.0
## Distance in pixels from the origin to start drawing and firing the laser.
@export var start_distance := 40.0
## Base duration of the tween animation in seconds.
@export var growth_time := 0.1
@export var color := Color.RED
@export var new_color := color

## If `true`, the laser is firing.
## It plays appearing and disappearing animations when it's not animating.
## See `appear()` and `disappear()` for more information.
@export var is_casting : bool = false: set = set_is_casting

@export var max_reflections := 3

var tween: Tween = null
@onready var line_2d: Line2D = $Line2D
@onready var slaves : Array = []
@onready var line_width := line_2d.width

func _init(base_color : Color) -> void:
	new_color = base_color
	

func _ready() -> void:
	# safe to access onready nodes now
	set_color() 
	set_is_casting(is_casting) 
	line_2d.points[0] = Vector2.RIGHT * start_distance 
	line_2d.points[1] = Vector2.ZERO 
	line_2d.visible = false

func _physics_process(delta: float) -> void:
	# Grow laser until full length
	target_position = target_position.move_toward(Vector2.RIGHT * max_length, cast_speed * delta)
	var points: Array = []
	var start_local: Vector2 = line_2d.points[0]
	var world_start: Vector2 = global_position + start_local
	# initial direction in WORLD space (node rotation applied)
	var dir_world: Vector2 = Vector2.RIGHT.rotated(global_rotation).normalized()
	var remaining_length: float = max_length
	var reflections: int = 0
	points.append(start_local)

	# Safety limit to avoid infinite loops
	var loop_iterations := 0
	while reflections <= max_reflections and remaining_length > 0.0 and loop_iterations < 32:
		loop_iterations += 1
		# compute end in world space for this segment based on remaining_length
		var end_world: Vector2 = world_start + dir_world * remaining_length
		# Ray query in WORLD space (don't add global_position again)
		var params: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
		params.from = world_start
		params.to = end_world
		params.exclude = [self]
		# params.collision_mask = <set if you want specific layers>
		var result := get_world_2d().direct_space_state.intersect_ray(params)
		
		if result:
			# world-space collision info
			var collision_point_world: Vector2 = result.position
			var collision_point_local: Vector2 = to_local(collision_point_world)
			var normal_world: Vector2 = (result.normal).normalized()
			var collider : Node = result.collider if result.has("collider") and result.collider != null else null
			var maybe_master: Node = null
			if collider:
				var collider_node: Node = result.collider
				maybe_master = collider_node
				if maybe_master != null:
					if maybe_master.has_method("get_matching_outputs") and maybe_master.has_method("is_master_portal"):
						#slaves = handle_master_hit(collider_node)
							# append the entry collision point to main beam and stop (or continue per design)
						points.append(collision_point_local)
							# break or continue depending on whether master blocks main beam; here we stop the main beam
						break
					else: 
						#despawn
						#despawn_new_beam(slaves)
						maybe_master = null
			#despawn
			#despawn_new_beam(slaves)
			points.append(collision_point_local)
			# prepare for the next reflection (all in world space)
			world_start = collision_point_world
			if normal_world != Vector2.ZERO:
				dir_world = dir_world.bounce(normal_world).normalized()
			# remaining length measured from the original local start point
			remaining_length = max_length - (collision_point_local - points[0]).length()
			reflections += 1
		else:
			# no hit: append local-space equivalent of end_world and break
			points.append(to_local(end_world))
			#despawn
			#despawn_new_beam(slaves)
			break

	# Update Line2D (local-space points)
	line_2d.points = points

	
func set_color() -> void:
	color = new_color
	if line_2d == null:
		return
	line_2d.modulate = new_color
	
func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)
	
	#if new_value == false :
		#despawn_new_beam(slaves)

	if is_casting:
		var laser_start := Vector2.RIGHT * start_distance
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		appear()
	else:
		target_position = Vector2.ZERO
		disappear()

func appear() -> void:
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", line_width, growth_time * 2.0).from(0.0)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)

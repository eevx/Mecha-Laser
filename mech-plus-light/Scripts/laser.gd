## Casts a laser along a raycast, emitting particles on the impact point.
## Use `is_casting` to make the laser fire and stop.
## You can attach it to a weapon or a ship; the laser will rotate with its parent.
@tool
extends RayCast2D

## Speed at which the laser extends when first fired, in pixels per seconds.
@export var cast_speed := 7000.0
## Maximum length of the laser in pixels.
@export var max_length := 1400.0
## Distance in pixels from the origin to start drawing and firing the laser.
@export var start_distance := 40.0
## Base duration of the tween animation in seconds.
@export var growth_time := 0.1
@export var color := Color.WHITE: set = set_color

## If `true`, the laser is firing.
## It plays appearing and disappearing animations when it's not animating.
## See `appear()` and `disappear()` for more information.
@export var is_casting := false: set = set_is_casting

@export var max_reflections := 3

var tween: Tween = null

@onready var line_2d: Line2D = $Line2D
@onready var casting_particles: GPUParticles2D = $CastingParticles2D
@onready var collision_particles: GPUParticles2D = $CollisionParticles2D
@onready var beam_particles: GPUParticles2D = $BeamParticles2D

@onready var line_width := line_2d.width


func _ready() -> void:
	set_color(color)
	set_is_casting(is_casting)
	line_2d.points[0] = Vector2.RIGHT * start_distance
	line_2d.points[1] = Vector2.ZERO
	line_2d.visible = false
	casting_particles.position = line_2d.points[0]
	if not Engine.is_editor_hint():
		set_physics_process(false)


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
	var hit_final: bool = false
	var hit_position: Vector2 = Vector2.ZERO
	var hit_normal: Vector2 = Vector2.ZERO
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
			var normal_world: Vector2 = result.normal
			var collider : Node = result.collider if result.has("collider") and result.collider != null else null
			var portal_data: Variant = null
			if collider:
				# If the collider is a shape child (CollisionShape2D) or some child,
				# the portal script may be on an ancestor. Walk up until root or found.
				var maybe_portal: Node = collider
				while maybe_portal != null:
					if maybe_portal.has_method("get_other_face") and maybe_portal.has_method("is_portal"):
						# found the portal node
						portal_data = maybe_portal.get_other_face(collision_point_world)
						break
					# climb to parent (stop if parent is not Node)
					if maybe_portal.get_parent() and maybe_portal.get_parent() is Node:
						maybe_portal = maybe_portal.get_parent() as Node
					else:
						maybe_portal = null
			
			if portal_data != null:
				# portal_data is a Dictionary (but typed Variant here)
				# Append collision point on entry face (local)
				points.append(collision_point_local)
				# compute traveled length so far (local-space)
				var traveled_local_len: float = (collision_point_local - points[0]).length()
				remaining_length = max_length - traveled_local_len
				# teleport start to exit_position + epsilon along exit_normal to avoid immediate re-hit
				var exit_pos_world: Vector2 = portal_data["exit_position"]
				var exit_normal_world: Vector2 = (portal_data["exit_normal"]).normalized()
				var offset_eps: float = 4.0
				world_start = exit_pos_world + exit_normal_world * offset_eps
				# force exit direction perpendicular to exit face
				dir_world = exit_normal_world
				# continue without incrementing reflections (portal traversal isn't counted)
				continue
			# Normal (non-portal) hit handling: treat as a reflective surface
			points.append(collision_point_local)
			# prepare for the next reflection (all in world space)
			world_start = collision_point_world
			dir_world = dir_world.bounce(normal_world).normalized()
			# remaining length measured from the original local start point
			remaining_length = max_length - (collision_point_local - points[0]).length()
			hit_final = true
			hit_position = collision_point_local
			hit_normal = normal_world
			reflections += 1
		else:
			# no hit: append local-space equivalent of end_world and break
			points.append(to_local(end_world))
			break

	# Update Line2D (local-space points)
	line_2d.points = points
	# Update beam particles using first and last point in local space
	var laser_start: Vector2 = points[0]
	var laser_end: Vector2 = points[points.size() - 1]
	beam_particles.position = laser_start + (laser_end - laser_start) * 0.5
	beam_particles.process_material.emission_box_extents.x = laser_end.distance_to(laser_start) * 0.5
	# Collision particles only at final impact (non-portal final)
	if hit_final:
		collision_particles.position = hit_position
		collision_particles.global_rotation = hit_normal.angle()
		collision_particles.emitting = true
	else:
		collision_particles.emitting = false

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)

	if beam_particles == null:
		return

	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting

	if is_casting:
		var laser_start := Vector2.RIGHT * start_distance
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		casting_particles.position = laser_start

		appear()
	else:
		target_position = Vector2.ZERO
		collision_particles.emitting = false
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


func set_color(new_color: Color) -> void:
	color = new_color

	if line_2d == null:
		return

	line_2d.modulate = new_color
	casting_particles.modulate = new_color
	collision_particles.modulate = new_color
	beam_particles.modulate = new_color

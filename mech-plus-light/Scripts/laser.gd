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
@onready var slaves : Array = []
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

# Create a secondary Line2D beam that is independent of the main beam.
# It will cast from the given world start and direction using your same casting logic,
# but draws into a new Line2D child named "SecondaryBeam".
#func spawn_secondary_beam(slave_node: Node,world_start: Vector2, dir_world: Vector2, remaining_length: float, beam_color: Color, recursion_depth: int = 0) -> void:
	## safety: avoid runaway recursion
	#if recursion_depth > 6:
		#return
#
	## create a Line2D for visualizing this secondary beam
	#print(slave_node)
	#var sec_node := Node2D.new()
	#slave_node.add_child(sec_node)
	##sec_node.owner = owner  # if you want it saved in scenes (optional)
#
	#var sec_line := Line2D.new()
	#sec_line.width = line_2d.width
	#sec_line.default_color = beam_color
	#sec_line.z_index = line_2d.z_index
	#sec_node.add_child(sec_line)
#
	## cast one beam segment using same logic as main, but independent:
	#var seg_points: Array = []
	#seg_points.append(to_local(world_start))  # local to laser node, but store local for Line2D that is child of laser
	#var world_from := world_start
	#var dir := dir_world.normalized()
	#var rem_len := remaining_length
	#var local_origin : Vector2 = seg_points[0]  # starting local point
#
	#var iter := 0
	#var max_iter := 12
	#var _hit_any := false
	#while rem_len > 0.0 and iter < max_iter:
		#iter += 1
		#var end_world := world_from + dir * rem_len
#
		#var params := PhysicsRayQueryParameters2D.new()
		#params.from = world_from
		#params.to = end_world
		#params.exclude = [self]
		#var res := get_world_2d().direct_space_state.intersect_ray(params)
		#if res:
			#var hit_world : Vector2 = res.position
			#var hit_local := to_local(hit_world)
			#seg_points.append(hit_local)
			#_hit_any = true
#
			## If hit a master portal, let it spawn outputs recursively
			#var collider_node: Node = res.collider
			## climb to parent to find master portal if needed
			#var maybe_portal := collider_node
			#while maybe_portal != null:
				#if maybe_portal.has_method("get_matching_outputs") and maybe_portal.has_method("is_master_portal"):
					## spawn outputs from master
					#var outputs : Array = maybe_portal.get_matching_outputs()
					#for info in outputs:
						## call spawn_secondary_beam for each output (perpendicular exit)
						#var exit_pos = info["exit_position"] as Vector2
						#var exit_normal = (info["exit_normal"] as Vector2).normalized()
						## compute new remaining length measured as before
						#var traveled_local_len := (hit_local - local_origin).length()
						#var new_rem : Variant = max(0.0, remaining_length - traveled_local_len)
						#spawn_secondary_beam(info["node"],exit_pos + exit_normal * 2.0, exit_normal, new_rem, beam_color, recursion_depth + 1)
					#break
				#if maybe_portal.get_parent() and maybe_portal.get_parent() is Node:
					#maybe_portal = maybe_portal.get_parent() as Node
				#else:
					#maybe_portal = null
#
			## reflect on normal for non-portal colliders
			#var normal_world : Vector2 = res.normal
			#dir = dir.bounce(normal_world).normalized()
			#world_from = hit_world
			#rem_len = remaining_length - (hit_local - local_origin).length()
		#else:
			#seg_points.append(to_local(end_world))
			#break
#
	## set points on sec_line (Line2D expects points in LOCAL space of the node it's attached to)
	#sec_line.points = seg_points
#
	## optional: queue_free after a short time (so secondary beams don't persist forever)
	#sec_node.set_physics_process(false)
	##sec_node.call_deferred("set_physics_process", false)
	#sec_node.queue_free()
	##sec_node.call_deferred("queue_free", 0.2)  # adjust lifetime as needed
	#
func spawn_new_beam(slave_node: Node) -> void:
	#print("I am spawning")
	var laser := RayCast2D.new()
	slave_node.add_child(laser)
	laser.global_transform = slave_node.global_transform
	laser.enabled = true
	laser.target_position = Vector2(0, 2000)
	
	var laser_line := Line2D.new()
	laser_line.width = line_2d.width
	laser_line.default_color = Color.RED
	laser_line.z_index = line_2d.z_index
	slave_node.add_child(laser_line)
	
	laser_line.points = [ Vector2.ZERO, Vector2(0,2000) ]
	
	#laser.rotation = slave_node.rotation
	
	#print("Spawned..")
	

func handle_master_hit(sure_master: Node) -> Array:
	var outputs : Array = sure_master.get_matching_outputs()
	for info in outputs:
		spawn_new_beam(info["node"])
		#spawn_secondary_beam(info["node"],exit_pos + exit_normal * 2.0, exit_normal, remaining_length, beam_color)
	return outputs

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
			var normal_world: Vector2 = (result.normal).normalized()
			var collider : Node = result.collider if result.has("collider") and result.collider != null else null
			var maybe_master: Node = null
			#var portal_data: Variant = null
			if collider:
				# If the collider is a shape child (CollisionShape2D) or some child,
				# the portal script may be on an ancestor. Walk up until root or found.
				#var res := get_world_2d().direct_space_state.intersect_ray(params)
				#if res:
				var collider_node: Node = result.collider
					# climb to parent to find master portal
				maybe_master = collider_node
				if maybe_master != null:
					if maybe_master.has_method("get_matching_outputs") and maybe_master.has_method("is_master_portal"):
							# compute remaining_length (as you already do)
						#var traveled_local_len: float = (collision_point_local - points[0]).length()
						#var new_rem : Variant = max(0.0, max_length - traveled_local_len)
							# use line color (your laser color) to match outputs
						slaves = handle_master_hit(collider_node)
							# append the entry collision point to main beam and stop (or continue per design)
						points.append(collision_point_local)
							# break or continue depending on whether master blocks main beam; here we stop the main beam
						break
						# climb parent
					else: 
						#despawn
						for slave in slaves : 
							for child in slave["node"].get_children() :
								if child is RayCast2D or child is Line2D :
									child.queue_free() 
						slaves.clear()
						maybe_master = null
					#if maybe_master.get_parent() and maybe_master.get_parent() is Node:
						#maybe_master = maybe_master.get_parent() as Node
			# Normal (non-portal) hit handling: treat as a reflective surface
			#despawn
			for slave in slaves : 
				print("@")
				for child in slave["node"].get_children() :
					if child is RayCast2D or child is Line2D :
						child.queue_free() 
			slaves.clear()
			points.append(collision_point_local)
			# prepare for the next reflection (all in world space)
			world_start = collision_point_world
			if normal_world != Vector2.ZERO:
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
			#despawn
			for slave in slaves : 
				print("#")
				for child in slave["node"].get_children() :
					if child is RayCast2D or child is Line2D :
						child.queue_free() 
			slaves.clear()
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
	
	if new_value == false :
		for slave in slaves : 
				print("#")
				for child in slave["node"].get_children() :
					if child is RayCast2D or child is Line2D :
						child.queue_free() 
		slaves.clear()

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

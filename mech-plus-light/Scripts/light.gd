class_name Light
extends RayCast2D

@export var cast_speed := 7000.0
# Maximum length of the laser in pixels.
@export var max_length := 1400.0
# Distance in pixels from the origin to start drawing and firing the laser.
@export var start_distance := 40.0
# Base duration of the tween animation in seconds.
@export var growth_time := 0.1
@export var color := Color.RED
@export var player_ref : Player
var walkable_collider: CollisionShape2D
@onready var static_body_2d: StaticBody2D = $StaticBody2D

var can_walk_on_light := false

# If `true`, the laser is firing.
# It plays appearing and disappearing animations when it's not animating.
# See `appear()` and `disappear()` for more information.
@export var is_casting : bool = false: set = set_is_casting

@export var max_reflections := 3
@onready var slaves : Array = []

var tween: Tween = null
var line_2d : Line2D
var line_width : float
var angle_of_incidence : float

# pool settings
@export var max_segment_colliders: int = 12
@export var ray_cast_collision_layer := 3
var _collider_pool: Array = []
var _active_colliders: int = 0
const LightScene := preload("res://Scenes/laser.tscn")


func _ready() -> void:
	line_2d = Line2D.new()
	add_child(line_2d)
	line_width = line_2d.width
	set_color(color) 
	set_is_casting(is_casting)
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
	line_2d.points[0] = Vector2.RIGHT * start_distance 
	line_2d.points[1] = Vector2.ZERO 
	line_2d.visible = false
	
	_init_collider_pool()

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
		var end_world: Vector2 = world_start + dir_world * remaining_length
		# Ray query in WORLD space (Reminder: don't add global_position)
		var params := PhysicsRayQueryParameters2D.new()
		params.from = world_start
		params.to = end_world
		# excluding self and static_body_2d so that the query won't hit the colliders
		params.exclude = [self, static_body_2d, player_ref] + static_body_2d.get_children()

		params.collision_mask = ray_cast_collision_layer
		var result := get_world_2d().direct_space_state.intersect_ray(params)
		
		#if result:
			#var col = result.collider
			#var name = col.get_name() if col != null and col.has_method("get_name") else str(col)
			#var layer_info := ""
			#if col and col.has_meta("collision_layer") == false:
				## attempt safe access if the collider is a PhysicsBody2D/CollisionObject2D
				#if "collision_layer" in col:
					#layer_info = " layer=" + str(col.collision_layer)
			##print_debug("Ray hit -> ", name, " at ", result.position, layer_info)
		##else:
			##print_debug("Ray: no hit from ", params.from, " to ", params.to)
		
		if result:
			# world-space collision info
			var collision_point_world: Vector2 = result.position
			var collision_point_local: Vector2 = to_local(collision_point_world)
			var normal_world: Vector2 = (result.normal).normalized()
			var collider : Node = result.collider if result.has("collider") and result.collider != null else null
			var maybe_master: Node = null
			var maybe_light_node : Node = null
			if collider:
				var collider_node: Node = result.collider
				maybe_master = collider_node
				maybe_light_node = collider_node
				if maybe_master != null:
					if maybe_master.has_method("get_matching_outputs") and maybe_master.has_method("is_master_portal"):
						slaves = handle_master_hit(collider_node)
							# append the entry collision point to main beam and stop (or continue per design)
						points.append(collision_point_local)
							# break or continue depending on whether master blocks main beam; here we stop the main beam
						break
					else: 
						#despawn
						despawn_new_beam()
						maybe_master = null
				if maybe_light_node != null : 
					print(maybe_light_node)
					print(maybe_master)
					print("1st Step")
					if maybe_light_node.has_method("i_am_light_dependent") :
						print("2nd Step")
						maybe_light_node.disable()
						points.append(collision_point_local)
						break
			#despawn
			despawn_new_beam()
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
			despawn_new_beam()
			break

	line_2d.points = points
	makeColliders(points)

##helper function for multiple collider initiation
func makeColliders(points : Array) -> void:
	# no. of segments
	#print(points)
	var seg_count = max(0, points.size() - 1)

	# If more segments than pool, clamp (or expand pool)
	if seg_count > _collider_pool.size():
		seg_count = _collider_pool.size()

	for cs in _collider_pool:
		cs.shape = null
		cs.disabled = true

	_active_colliders = 0
	for i in range(seg_count):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]

		if a.distance_to(b) < 1.0: #degenerate segments
			continue

		var cs = _collider_pool[_active_colliders]
		_active_colliders += 1

		var dir := b - a
		var length := dir.length()
		var thickness := 8.0  # adjustable collision thickness

		var rect := RectangleShape2D.new()
		rect.size = Vector2(length, thickness)
		cs.shape = rect
		cs.disabled = false

		cs.position = (a + b) * 0.5
		cs.rotation = dir.angle()

func transformCollider(fromTargetPos: Vector2, toTargetPos: Vector2, walkableCollider: CollisionShape2D) -> void:
	var dir := toTargetPos - fromTargetPos
	var length := dir.length()
	if length <= 0.0001:
		return

	var thickness := 8.0
	var rect := RectangleShape2D.new()
	rect.size = Vector2(length, thickness)
	walkableCollider.shape = rect

	walkableCollider.position = (fromTargetPos + toTargetPos) * 0.5
	walkableCollider.rotation = dir.angle()

func isWalkable(value : bool):
	if value:
		var bit := 1 << (walkable_layer - 1)
		static_body_2d.collision_layer = bit
		static_body_2d.collision_mask = bit
	else:
		static_body_2d.collision_layer = 0
		static_body_2d.collision_mask = 0
	#if value == true:
		#set_collision_mask_value(2, true) #player
	#else:
		#set_collision_mask_value(2, false) #null

func set_color(new_color : Color) -> void:
	color = new_color
	if line_2d == null:
		return
	line_2d.modulate = new_color
	
func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)
	
	if new_value == false :
		despawn_new_beam()

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
	
func spawn_new_beam(slave_node: Node) -> void:
	var laser := RayCast2D.new()
	slave_node.add_child(laser)
	laser.global_transform = slave_node.global_transform
	laser.enabled = true
	laser.target_position = Vector2(0, 2000)
	
	var laser_line := Line2D.new()
	laser_line.width = line_2d.width
	laser_line.default_color = color
	laser_line.z_index = line_2d.z_index
	slave_node.add_child(laser_line)
	
	laser_line.points = [ Vector2.ZERO, Vector2(0,2000) ]

#func spawn_new_beam(slave_node: Node) -> void:
	#var new_light: Light = LightScene.instantiate()
	#slave_node.add_child(new_light)
	#new_light.global_transform = slave_node.global_transform
	#new_light.color = color
	#new_light.max_length = max_length
	#new_light.cast_speed = cast_speed
	#new_light.max_reflections = max_reflections
	#new_light.is_casting = true  # start casting immediately
#
	## You can copy any other variables you need:
	#new_light.player_ref = player_ref  

func despawn_new_beam() -> void: 
	for slave in slaves : 
		for child in slave["node"].get_children() :
			if child is RayCast2D or child is Line2D :
				child.queue_free() 
	slaves.clear()

func handle_master_hit(sure_master: Node) -> Array:
	var outputs : Array = sure_master.get_matching_outputs()
	for info in outputs:
		spawn_new_beam(info["node"])
	return outputs

@export var walkable_layer : int = 1  # the layer number (1..32) that the player sits on

func _init_collider_pool() -> void:
	# Put static body at Light origin
	static_body_2d.position = Vector2.ZERO

	# Set collision layers/masks using bitmasks so we avoid confusion:
	# bitmask: layer n -> 1 << (n - 1)
	var bit := 1 << (walkable_layer - 1)
	static_body_2d.collision_layer = bit
	static_body_2d.collision_mask = bit

	# create a pool of CollisionShape2D nodes as children of static_body_2d
	for i in range(max_segment_colliders):
		var cs := CollisionShape2D.new()
		cs.shape = null
		cs.disabled = true
		static_body_2d.add_child(cs)
		_collider_pool.append(cs)
	_active_colliders = 0
	#static_body_2d.position = Vector2.ZERO
	#static_body_2d.collision_layer = 9  # example: player layer
	#static_body_2d.collision_mask = 9  # what it should collide with
#
	## create a pool of CollisionShape2D nodes as children of static_body_2d
	#for i in range(max_segment_colliders):
		#var cs := CollisionShape2D.new()
		## start disabled (no shape attached)
		#cs.shape = null
		#cs.disabled = true
		#static_body_2d.add_child(cs)
		#_collider_pool.append(cs)
		#
	#_active_colliders = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("walk_on_light") and event.is_action_pressed("walk_on_light"):
		can_walk_on_light = !can_walk_on_light
		isWalkable(can_walk_on_light)

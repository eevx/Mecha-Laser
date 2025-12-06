class_name Light
extends RayCast2D

@export var cast_speed := 7000.0
@export var max_length := 1400.0
@export var start_distance := 0.0
@export var growth_time := 0.1
@export var color : Color = Color.RED

@export var beam_width : float = 8.0 : set = set_beam_width

@export var is_casting : bool = false: set = set_is_casting

@export var max_reflections := 3
@export var max_segment_colliders: int = 12
@export var ray_cast_collision_layer := 3
@export var walkable_layer : int = 1

@export var canWalkable: bool = false : set = set_can_walkable

var walkable_collider: CollisionShape2D
var slave_portals_in_scene : Array = []
@onready var static_body_2d: StaticBody2D = $StaticBody2D

var can_walk_on_light: bool = false
@onready var slaves : Array = []
var tween: Tween = null
var line_2d : Line2D
var line_width : float = 8.0
var angle_of_incidence : float

var _collider_pool: Array = []
var _rect_shape_pool: Array = []
var _active_colliders: int = 0

var target_pos : Vector2 = Vector2.ZERO
var _current_master: Node = null
var player_ref : Player

func _ready() -> void:
	add_to_group("Light")
	line_2d = Line2D.new()
	add_child(line_2d)
	line_width = beam_width
	line_2d.width = line_width
	line_2d.default_color = color
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
	line_2d.points[0] = Vector2.RIGHT * start_distance
	line_2d.points[1] = Vector2.ZERO
	line_2d.visible = false
	slave_portals_in_scene = []
	collect_slave_portals_dfs(slave_portals_in_scene)
	_init_collider_pool()
	set_is_casting(is_casting)
	isWalkable(canWalkable)
	
	can_walk_on_light = canWalkable
	
	if not is_casting:
		_disable_all_colliders()
	player_ref = auto_collect_player_ref()

func _physics_process(delta: float) -> void:
	target_pos = target_pos.move_toward(Vector2.RIGHT * max_length, cast_speed * delta)
	var master_hit_this_frame: bool = false
	var points: Array = []
	var start_local: Vector2 = line_2d.points[0]
	var world_start: Vector2 = global_position + start_local
	var dir_world: Vector2 = Vector2.RIGHT.rotated(global_rotation).normalized()
	var remaining_length: float = max_length
	var reflections: int = 0
	points.append(start_local)
	var loop_iterations := 0
	while reflections <= max_reflections and remaining_length > 0.0 and loop_iterations < 32:
		loop_iterations += 1
		var end_world: Vector2 = world_start + dir_world * remaining_length
		var exclude_rids: Array = []
		var exclude_candidates := [self, static_body_2d, player_ref]
		for child in static_body_2d.get_children():
			exclude_candidates.append(child)
		for obj in exclude_candidates:
			if obj == null:
				continue
			if obj is CollisionObject2D:
				exclude_rids.append(obj.get_rid())
		var params := PhysicsRayQueryParameters2D.new()
		params.from = world_start
		params.to = end_world
		params.exclude = exclude_rids
		var walkable_bit := 1 << (walkable_layer - 1)
		params.collision_mask = ray_cast_collision_layer & ~walkable_bit
		var result := get_world_2d().direct_space_state.intersect_ray(params)
		if result:
			var collider = null
			if result.has("collider"):
				collider = result.collider
			var hit_light_node = null
			var maybe_node = collider
			while maybe_node != null:
				if maybe_node is Light:
					hit_light_node = maybe_node
					break
				maybe_node = maybe_node.get_parent()
			if hit_light_node != null and hit_light_node != self:
				var advance_amount = max(0.5, beam_width * 0.1)
				world_start += dir_world * advance_amount
				remaining_length = max(0.0, remaining_length - advance_amount)
				continue
			var collision_point_world: Vector2 = result.position
			var collision_point_local: Vector2 = to_local(collision_point_world)
			var normal_world: Vector2 = result.normal.normalized()
			var collider_node: Node = collider if collider != null else null
			if collider_node != null:
				var maybe_master: Node = collider_node
				while maybe_master != null:
					if maybe_master.has_method("get_matching_outputs") and maybe_master.has_method("is_master_portal"):
						master_hit_this_frame = true
						if _current_master != maybe_master:
							despawn_new_beam()
							_current_master = maybe_master
							slaves = handle_master_hit(maybe_master)
						else:
							if slaves.is_empty():
								slaves = handle_master_hit(maybe_master)
						points.append(collision_point_local)
						break
					maybe_master = maybe_master.get_parent()
				if master_hit_this_frame:
					break
			points.append(collision_point_local)
			world_start = collision_point_world
			if normal_world != Vector2.ZERO:
				dir_world = dir_world.bounce(normal_world).normalized()
			remaining_length = max_length - (collision_point_local - points[0]).length()
			reflections += 1
		else:
			points.append(to_local(end_world))
			break
	line_2d.points = points
	line_2d.width = line_width
	line_2d.default_color = color
	makeColliders(points)
	if not master_hit_this_frame and _current_master != null:
		despawn_new_beam()
		_current_master = null

func _init_collider_pool() -> void:
	if static_body_2d != null:
		static_body_2d.position = Vector2.ZERO
	_enable_walkable_layer_on_static_body()
	_collider_pool.clear()
	_rect_shape_pool.clear()
	for i in range(max_segment_colliders):
		var cs := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(1.0, beam_width)
		cs.shape = null
		cs.disabled = true
		static_body_2d.add_child(cs)
		_collider_pool.append(cs)
		_rect_shape_pool.append(rect)
	_active_colliders = 0

func makeColliders(points : Array) -> void:
	if not is_casting:
		_disable_all_colliders()
		return
	var seg_count = max(0, points.size() - 1)
	if seg_count > _collider_pool.size():
		seg_count = _collider_pool.size()
	for cs in _collider_pool:
		cs.disabled = true
		cs.shape = null
	_active_colliders = 0
	for i in range(seg_count):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		if a.distance_to(b) < 1.0:
			continue
		var cs = _collider_pool[_active_colliders]
		var rect = _rect_shape_pool[_active_colliders]
		_active_colliders += 1
		var dir := b - a
		var length := dir.length()
		var thickness = max(0.1, beam_width)
		rect.size = Vector2(max(1.0, length), thickness)
		cs.shape = rect
		cs.disabled = false
		cs.position = (a + b) * 0.5
		cs.rotation = dir.angle()
	for j in range(_active_colliders, _collider_pool.size()):
		_collider_pool[j].disabled = true
		_collider_pool[j].shape = null

func _disable_all_colliders() -> void:
	for cs in _collider_pool:
		cs.disabled = true
		cs.shape = null
	_active_colliders = 0
	if static_body_2d != null:
		static_body_2d.collision_layer = 0
		static_body_2d.collision_mask = 0

func _enable_walkable_layer_on_static_body() -> void:
	if static_body_2d != null:
		var bit := 1 << (walkable_layer - 1)
		static_body_2d.collision_layer = bit
		static_body_2d.collision_mask = bit

func set_beam_width(new_width: float) -> void:
	if new_width <= 0.0:
		new_width = 0.1
	beam_width = new_width
	line_width = beam_width
	if line_2d != null:
		line_2d.width = line_width
	for i in range(_rect_shape_pool.size()):
		var rect = _rect_shape_pool[i]
		if rect != null and rect is RectangleShape2D:
			var sz = rect.size
			if sz.x <= 0.0:
				sz.x = 1.0
			sz.y = beam_width
			rect.size = sz
	if is_casting:
		makeColliders(line_2d.points)

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)
	if new_value == false:
		_disable_all_colliders()
		despawn_new_beam()
	if is_casting:
		if canWalkable:
			_enable_walkable_layer_on_static_body()
		var laser_start := Vector2.RIGHT * start_distance
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		appear()
	else:
		target_pos = Vector2.ZERO
		disappear()

func appear() -> void:
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", beam_width, growth_time * 2.0).from(0.0)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)

func spawn_new_beam(slave_node: Node) -> void:
	if slave_node == null:
		return
	if slave_node.has_method("set_is_casting"):
		slave_node.set_is_casting(true)
	else:
		if slave_node.has_node("Laser"):
			var l = slave_node.get_node("Laser")
			if l != null:
				if l.has_method("set_is_casting"):
					l.set_is_casting(true)
				elif "is_casting" in l:
					l.is_casting = true

func despawn_new_beam() -> void:
	for entry in slaves:
		var node_ref: Node = null
		if typeof(entry) == TYPE_DICTIONARY and entry.has("node"):
			node_ref = entry["node"]
		elif entry is Node:
			node_ref = entry
		if node_ref == null:
			continue
		if node_ref.has_method("set_is_casting"):
			node_ref.set_is_casting(false)
		else:
			if node_ref.has_node("Laser"):
				var l = node_ref.get_node("Laser")
				if l != null:
					if l.has_method("set_is_casting"):
						l.set_is_casting(false)
					elif "is_casting" in l:
						l.is_casting = false
	slaves.clear()

func handle_master_hit(sure_master: Node) -> Array:
	var outputs : Array = sure_master.get_matching_outputs()
	var spawned := []
	var master_color: Color
	if sure_master != null and "color" in sure_master:
		master_color = sure_master.color
	for info in outputs:
		if info.has("node") and info["node"] != null:
			var candidate = info["node"]
			var do_spawn := true
			if master_color != null and ("color" in candidate):
				if candidate.color != master_color:
					do_spawn = false
			if do_spawn:
				spawn_new_beam(candidate)
				spawned.append({"node": candidate})
	return spawned

func isWalkable(value : bool) -> void:
	if value:
		_enable_walkable_layer_on_static_body()
	else:
		if static_body_2d != null:
			static_body_2d.collision_layer = 0
			static_body_2d.collision_mask = 0

func set_can_walkable(new_value: bool) -> void:
	if canWalkable == new_value:
		return
	canWalkable = new_value
	isWalkable(canWalkable)

func transformCollider(fromTargetPos: Vector2, toTargetPos: Vector2, walkableCollider: CollisionShape2D) -> void:
	var dir := toTargetPos - fromTargetPos
	var length := dir.length()
	if length <= 0.0001:
		return
	var rect := RectangleShape2D.new()
	rect.size = Vector2(length, beam_width)
	walkableCollider.shape = rect
	walkableCollider.position = (fromTargetPos + toTargetPos) * 0.5
	walkableCollider.rotation = dir.angle()

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("walk_on_light") and event.is_action_pressed("walk_on_light"):
		can_walk_on_light = !can_walk_on_light
		isWalkable(can_walk_on_light)
		
		for light in get_tree().get_nodes_in_group("Light"):
			if light != self and light.has_method("isWalkable"):
				light.can_walk_on_light = can_walk_on_light
				light.isWalkable(can_walk_on_light)

func collect_slave_portals_dfs(out: Array, start_node: Node = null) -> void:
	if start_node == null:
		start_node = collect_top_ancestor(self)
	if start_node is SlavePortal:
		out.push_back(start_node)
	for child in start_node.get_children():
		collect_slave_portals_dfs(out, child)

func collect_top_ancestor(node: Node) -> Node:
	var parent := node.get_parent()
	if parent == null:
		return node
	return collect_top_ancestor(parent)

func auto_collect_player_ref(start_node : Node = collect_top_ancestor(self)) -> Player:
	if start_node is Player:
		return start_node
	for child in start_node.get_children():
		var res := auto_collect_player_ref(child)
		if res:
			return res
	return

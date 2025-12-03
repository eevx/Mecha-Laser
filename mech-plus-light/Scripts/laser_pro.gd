class_name Light
extends RayCast2D

@export_group("Settings")
@export var max_reflections: int = 3
@export var cast_speed : float = 7000.0
@export var max_length : float = 1400.0
@export var line_width : float = 10.0
@export var start_distance : float = 40.0
@export var growth_time : float = 0.1

@export_group("Visuals")
@export var color: Color = Color() #Color daalna hai abhi

#Internal Variables
var is_casting: bool = false : set = set_is_casting
var tween: Tween

#this holds the next beam is the reflection chain
var reflected_beam: Light = null

# References to child nodes
@onready var line_2d: Line2D = $Line2D
@onready var beam_particles: GPUParticles2D = $BeamParticles
@onready var casting_particles: GPUParticles2D = $CastingParticles
@onready var collision_particles: GPUParticles2D = $CollisionParticles

func _ready() -> void:
	# Initialize visual state
	set_physics_process(false)
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
	line_2d.width = 0
	target_position = Vector2.RIGHT * max_length
	
func _physics_process(_delta: float) -> void:
	# 1. Update Raycast
	target_position = Vector2.RIGHT * max_length
	force_raycast_update()
	
	var cast_point := target_position
	var is_colliding_now := is_colliding()
	
	if is_colliding_now:
		cast_point = to_local(get_collision_point())
		# Handle Reflection Logic
		process_reflection(get_collision_point(), get_collision_normal())
	else:
		# If not hitting anything, turn off the next reflection
		despawn_reflection()

	# 2. Update Visuals
	line_2d.points[1] = cast_point
	casting_particles.position = cast_point
	collision_particles.emitting = is_colliding_now
	collision_particles.position = cast_point
	
# --- Core Logic from your Reference ---

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
		
	is_casting = new_value
	set_physics_process(is_casting)
	
	# Handle Particles
	if beam_particles: beam_particles.emitting = is_casting
	if casting_particles: casting_particles.emitting = is_casting
	
	if is_casting:
		# Reset line to start position before expanding
		line_2d.points[0] = Vector2.ZERO
		line_2d.points[1] = Vector2.ZERO 
		appear()
	else:
		# Turn off collision particles immediately
		if collision_particles: collision_particles.emitting = false
		despawn_reflection() # Kill the reflection chain
		disappear()

func appear() -> void:
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	# Animate width from 0 to target width
	tween.tween_property(line_2d, "width", line_width, growth_time).from(0.0)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	# Animate width from current to 0, then hide
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)

func set_color(new_color: Color) -> void:
	color = new_color
	# Wait for ready before accessing nodes
	if not is_node_ready(): 
		return
		
	line_2d.default_color = new_color
	line_2d.modulate = new_color # Helper for glow effects
	if beam_particles: beam_particles.modulate = new_color
	if casting_particles: casting_particles.modulate = new_color
	if collision_particles: collision_particles.modulate = new_color

# --- Reflection Logic ---

func process_reflection(collision_point: Vector2, normal: Vector2) -> void:
	# Stop reflecting if we reached the max bounce limit
	if max_reflections <= 0:
		return

	# Calculate reflection direction
	# The ray is pointing right locally, so we need global direction
	var incoming_dir = global_transform.x.normalized()
	var reflect_dir = incoming_dir.bounce(normal)
	
	# Create the next beam if it doesn't exist
	if reflected_beam == null:
		create_new_reflection()
	
	# Update the child beam
	reflected_beam.global_position = collision_point
	reflected_beam.global_rotation = reflect_dir.angle()
	
	# Only turn it on if it wasn't already casting
	if not reflected_beam.is_casting:
		reflected_beam.is_casting = true

func create_new_reflection() -> void:
	# Duplicate this node to create the reflected beam
	# This ensures the reflection has the same particles/settings
	reflected_beam = self.duplicate()
	
	# Reduce the reflection count for the child so it doesn't go infinite
	reflected_beam.max_reflections = max_reflections - 1
	
	# Add to scene
	get_tree().current_scene.add_child(reflected_beam)
	
	# We don't want the child to process immediately, the parent controls it
	reflected_beam.is_casting = false 

func despawn_reflection() -> void:
	# We don't delete the node (expensive), we just turn it off
	if reflected_beam and reflected_beam.is_casting:
		reflected_beam.is_casting = false

# Clean up if this node is deleted
func _exit_tree() -> void:
	if reflected_beam and is_instance_valid(reflected_beam):
		reflected_beam.queue_free()

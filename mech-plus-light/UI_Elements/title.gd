extends Label

var shine_value: float = 10.0
var shine_speed: float = 2.0   

func _ready():
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("text_size", size)

	resized.connect(_on_resized)


func _on_resized():
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("text_size", size)


func _process(delta: float) -> void:
	var mat := material as ShaderMaterial
	if not mat:
		return

	# Update shine progress
	shine_value += shine_speed * delta

	# Loop between 0 and 10
	if shine_value > 10.0:
		shine_value = 0.0

	mat.set_shader_parameter("shine_progress", shine_value)

shader_type canvas_item;

uniform sampler2D line_texture : repeat_enable;
uniform float time_scale = 0.6;
uniform float texture_scale = 1.4;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 line_text = texture(line_texture, vec2(UV.x * texture_scale - TIME * time_scale, UV.y));
	COLOR *= line_text;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

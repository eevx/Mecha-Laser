shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float mirror_screen_y = 0.5;
uniform float mirror_strength = 0.15;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 screen_reflect_col = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x, 2. * mirror_screen_y - SCREEN_UV.y));
	COLOR = (COLOR + mix(screen_col, screen_reflect_col, mirror_strength)) * COLOR.a;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

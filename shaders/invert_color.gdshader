shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float reverse_color(float color_component){
	//Might need to change this function
	return clamp((1.0 - color_component) * 3.0, 0.0, 1.0);
}

void fragment() {
	vec4 init_color = COLOR;
	vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = vec4(reverse_color(screen_color.r),reverse_color(screen_color.g),reverse_color(screen_color.b), COLOR.a);
	vec4 double_reverse = vec4(reverse_color(COLOR.r),reverse_color(COLOR.g),reverse_color(COLOR.b), COLOR.a);
	COLOR = mix(COLOR, double_reverse, 1.0 - length(init_color.rgb));
}

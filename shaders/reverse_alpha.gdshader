shader_type canvas_item;

void fragment() {
	vec4 default_color = COLOR;
	COLOR = vec4(default_color.r, default_color.g, default_color.b, 1.0 - default_color.a);
}

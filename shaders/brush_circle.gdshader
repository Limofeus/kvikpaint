shader_type canvas_item;

uniform vec2 object_pixel_size = vec2(1024.0, 1024.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float circle_radius = 10.0;
uniform float circle_width = 0.0; //Well this thing turned out to be pretty much useless, but I'll leve it be
uniform float circle_feather = 2.0;

uniform float font_size_mult = 4.0;
uniform float font_size_indicator_width = 1.5;
uniform float font_size_indicator_minimum_length = 5.0;
uniform float font_size_indicator_horizontal_feather = 1.0;
uniform float font_size_indicator_vertical_feather = 0.5;

//Bruh, I cant in to math... would need to rework this probably, though for now it works

float reverse_color(float color_component){
	//Might need to change this function
	return clamp((1.0 - color_component) * 3.0, 0.0, 1.0);
}

void fragment() {
	vec2 centered_uv = (UV * object_pixel_size) - (object_pixel_size * 0.5);
	float radius_squared = circle_radius * circle_radius;
	float square_sum = (centered_uv.x * centered_uv.x) + (centered_uv.y * centered_uv.y);
	
	float difference = square_sum - radius_squared;
	float real_distance = sqrt(abs(difference));
	
	float circle_alpha = 1.0 - smoothstep((circle_width * circle_radius), (circle_width + circle_feather) * circle_radius, abs(difference));
	
	float text_indicator_height = circle_radius * font_size_mult; //It'll go closer to center from here (because text does not fully fill the space)
	
	float horizontal_text_indecator_alpha = min((1.0 - smoothstep(0.0, circle_radius / 2.0 + font_size_indicator_minimum_length, abs(centered_uv.x))) / font_size_indicator_horizontal_feather, 1.0); //circle_radius / 2.0 is line length here, could later be changed to some other value
	float vertical_text_indecator_alpha = clamp((1.0 - smoothstep(0.0, (font_size_indicator_width / 2.0), abs(abs(centered_uv.y) - text_indicator_height - font_size_indicator_width))) / font_size_indicator_vertical_feather, 0.0, 1.0);
	
	float text_indicator_alpha = horizontal_text_indecator_alpha * vertical_text_indecator_alpha;
	
	float final_alpha = clamp(circle_alpha + text_indicator_alpha, 0.0, 1.0);
	
	vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = vec4(reverse_color(screen_color.r),reverse_color(screen_color.g),reverse_color(screen_color.b), final_alpha);
}

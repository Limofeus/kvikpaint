shader_type canvas_item;

uniform vec2 canv_position = vec2(0.0, 0.0);
uniform float canv_zoom = 1.0;
uniform float canv_linear_zoom = 1.0;

uniform vec4 main_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform vec4 stroke_color : source_color = vec4(0.4, 0.4, 0.4, 1.0);

uniform float grid_size = 100.0;

uniform float line_width = 5.0;

void fragment() {
	
	vec2 uv = SCREEN_UV;
	uv /= vec2(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y);
	
	float grid_scale_factor = exp(max(floor((10.0 * -canv_linear_zoom) / 10.0), 0.0));
	
	float current_width = line_width * grid_scale_factor;
	
	uv /= canv_zoom;
	
	uv += vec2(current_width, current_width) / 2.0;
	uv -= canv_position;
	
	float current_grid_size = grid_size;
	
	//current_grid_size *= grid_scale_factor;
	
	uv = vec2(mod(uv.x, current_grid_size), mod(uv.y, current_grid_size));
	
	if(uv.x < current_width || uv.y < current_width){
		COLOR = stroke_color;
	}
	else
	{
		COLOR = main_color;
	}
	//COLOR = vec4(uv.x, uv.y, 0.0, 1.0);
}

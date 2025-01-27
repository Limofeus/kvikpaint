extends CanvasDrawState
class_name LineDrawState

@export var line_buffer : Line2D = null
@export var line_color : Color = Color.WHITE
#@export var line_width : float = 5

var mouse_button = MOUSE_BUTTON_LEFT

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == mouse_button and event.pressed:
			super._set_current()
			line_buffer.default_color = line_color
			#line_buffer.width = line_width
			line_buffer.add_point(canvas.get_canvas_coordinates(event.position))

	if event is InputEventMouseMotion:
		if is_current:
			line_buffer.add_point(canvas.get_canvas_coordinates(event.position))

func _on_exit():
	draw_to_canvas(true)
	line_buffer.clear_points()
extends CanvasDrawState
class_name TextDrawState

const MOUSE_MOVE_THRESHOLD = 5

@export var text_holder : Control = null
@export var text_buffer : Label = null
@export var stop_draw_state : StopDrawingState = null
var current_string : String = ""

var start_type_mouse_coords = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:

		if Input.is_action_pressed("ctrl_modifier_key"):
			if is_current:
				stop_draw_state._set_current()
			return

		var key_name = OS.get_keycode_string(event.key_label)
		var key_string = str(char(event.unicode))

		#print(key_name)
		#print(str(event.unicode))

		if key_name == "Enter":
			key_string = "\n"

		if key_name == "Backspace" and is_current:
			if current_string.length() > 0:
				current_string = current_string.substr(0, current_string.length() - 1)
				text_buffer.text = current_string

		if key_string.length() != 1:
			return

		current_string += key_string

		if !is_current:
			super._set_current()
			text_holder.position = canvas.get_canvas_coordinates(get_viewport().get_mouse_position())

			start_type_mouse_coords = get_viewport().get_mouse_position()
		
		text_buffer.text = current_string

	if event is InputEventMouseMotion and current_string.length() > 0:
		if get_viewport().get_mouse_position().distance_to(start_type_mouse_coords) > MOUSE_MOVE_THRESHOLD:
			stop_draw_state._set_current()

func _on_exit():
	draw_to_canvas()
	current_string = ""
	text_buffer.text = current_string

extends CanvasDrawState
class_name TextDrawState

@export var text_holder : Control = null
@export var text_buffer : Label = null
@export var stop_draw_state : StopDrawingState = null
var current_string : String = ""

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:

		if Input.is_action_pressed("ctrl_modifier_key"):
			if is_current:
				stop_draw_state._set_current()
			return

		var key_string = OS.get_keycode_string(event.key_label)
		key_string = key_string.replace("Space", " ")
		if key_string.length() != 1:
			return

		current_string += key_string

		if !is_current:
			super._set_current()
			text_holder.position = canvas.get_canvas_coordinates(get_viewport().get_mouse_position())
		
		text_buffer.text = current_string

	if event is InputEventMouseMotion and current_string.length() > 0:
		stop_draw_state._set_current()

func _on_exit():
	draw_to_canvas()
	current_string = ""
	text_buffer.text = current_string

extends CanvasDrawState
class_name BoxSelectState

signal selection_box_updated()

@export var stop_draw_state : StopDrawingState = null

var start_point : Vector2 = Vector2.ZERO
var canvas_selection_box : Rect2 = Rect2(0, 0, 0, 0)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:

		if Input.is_action_pressed("ctrl_modifier_key") and Input.is_action_just_pressed_by_event("box_select", event):
			super._set_current()

			start_point = canvas.get_canvas_coordinates(get_viewport().get_mouse_position())
			canvas_selection_box.position = start_point
			canvas_selection_box.end = start_point

			selection_box_updated.emit()
			return

	if event is InputEventMouseMotion:
		if is_current:
			var new_point = canvas.get_canvas_coordinates(get_viewport().get_mouse_position())

			canvas_selection_box.position = start_point.min(new_point)
			canvas_selection_box.end = start_point.max(new_point)
			
			selection_box_updated.emit()
			return

	if event is InputEventKey and !event.pressed:
		if Input.is_action_just_released_by_event("box_select", event) and is_current:
			stop_draw_state._set_current() #Replace?..

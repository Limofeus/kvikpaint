extends DrawState
class_name StopDrawingState

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_released() and !event.is_action("zoom_in") and !event.is_action("zoom_out") and !event.is_action("drag_canvas"):
			super._set_current()
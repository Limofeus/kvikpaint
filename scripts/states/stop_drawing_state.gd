extends DrawState
class_name StopDrawingState

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			super._set_current()
extends Control

func _input(event):
	if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
		visible = false

func open_hint():
	visible = true
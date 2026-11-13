extends Control
class_name LatexEditDisplay

@export var drag_button : Button

var mouse_button_offset : Vector2 = Vector2.ZERO

func _ready():
	drag_button.button_down.connect(drag_button_down)

func _input(event):
	if event is InputEventMouseMotion:
		if drag_button.button_pressed:
			global_position = mouse_button_offset + get_viewport().get_mouse_position()

func drag_button_down():
	mouse_button_offset = global_position - get_viewport().get_mouse_position()
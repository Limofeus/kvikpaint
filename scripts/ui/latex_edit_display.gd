extends Control
class_name LatexEditDisplay

@export var visible_lambda : float = 30.0
@export var drag_button : Button

var mouse_button_offset : Vector2 = Vector2.ZERO
var display_visible : bool = false

func _ready():
	drag_button.button_down.connect(drag_button_down)

func _process(delta):
	scale.y = StaticUtility.lerp_dampen(scale.y, 1.0 if display_visible else 0.0, visible_lambda, delta)
	visible = scale.y >= 0.01

func _input(event):
	if event is InputEventMouseMotion:
		if drag_button.button_pressed:
			global_position = mouse_button_offset + get_viewport().get_mouse_position()

func drag_button_down():
	mouse_button_offset = global_position - get_viewport().get_mouse_position()

func set_display_visibility(set_display_visible:bool) -> void:
	display_visible = set_display_visible
	print("set to " + str(display_visible))
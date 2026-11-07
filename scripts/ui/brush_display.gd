extends Control
class_name BrushDisplay

@export var canvas_drag_reference : CanvasDrag = null
@export var brush_circle_texture : ColorRect = null #Not used right now
@export var brush_arrow_texture : TextureRect = null
@export var brush_shader : ShaderMaterial = null

@export var base_brush_size : float = 10.0
@export var text_size_mult : float = 4.0

@export var canvas_center_position : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_viewport().get_mouse_position()
	update_brush_size()
	update_brush_arrow()
	
func set_brush_display_size(brush_size : float, new_text_size_mult : float):
	base_brush_size = brush_size / 2.0
	text_size_mult = new_text_size_mult
	update_brush_size()

func update_brush_size():
	brush_shader.set_shader_parameter("circle_radius", base_brush_size * canvas_drag_reference.camera_zoom)
	brush_shader.set_shader_parameter("font_size_mult", text_size_mult)

func update_brush_arrow():
	var towards_center_vector = canvas_center_position - canvas_drag_reference.get_canvas_coordinates(get_viewport().get_mouse_position())
	if towards_center_vector.length() > canvas_center_position.length():
		brush_arrow_texture.visible = true
		brush_arrow_texture.rotation = atan2(towards_center_vector.y, towards_center_vector.x)
	else:
		brush_arrow_texture.visible = false

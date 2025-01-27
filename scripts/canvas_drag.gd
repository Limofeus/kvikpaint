extends Node
class_name CanvasDrag

@export var camera : Camera2D = null
@export var canvas_holder : Control = null

@export var background_shader : ShaderMaterial = null

var camera_zoom_linear : float = 0.0
var camera_zoom : float = 1.0
var canvas_pos : Vector2 = Vector2.ZERO
var is_dragging : bool = false

const ZOOM_AMMOUNT : float = 0.2

func _input(event):
	is_dragging = Input.is_action_pressed("drag_canvas")

	if event is InputEventMouseMotion and is_dragging:
		canvas_pos += event.relative * (1.0 / camera_zoom)
		update_canvas_pos()

	if Input.is_action_pressed("sift_modifier_key"):
		return

	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_just_pressed("zoom_in"):
			camera_zoom_linear += ZOOM_AMMOUNT
			update_camera_zoom()
		elif Input.is_action_just_pressed("zoom_out"):
			camera_zoom_linear -= ZOOM_AMMOUNT
			update_camera_zoom()

func update_camera_zoom():
	
	var center_pos_dif = camera.get_screen_center_position()

	camera_zoom =  exp(camera_zoom_linear)
	camera.zoom = Vector2.ONE * camera_zoom

	center_pos_dif = center_pos_dif - camera.get_screen_center_position()

	canvas_pos -= center_pos_dif

	#print(center_pos_dif) Naaah, trying to find a formula to not use camera.get_screen_center_position() is WAAAY TOO HARD
	update_canvas_pos()

func update_canvas_pos():
	canvas_holder.position = canvas_pos
	update_canv_shader()

func update_canv_shader():	
	if background_shader != null:
		background_shader.set_shader_parameter("canv_position", canvas_pos) #If you want to allow user to change ui scale, then multiply by this: * get_window().content_scale_factor
		background_shader.set_shader_parameter("canv_zoom", camera_zoom)
		background_shader.set_shader_parameter("canv_linear_zoom", camera_zoom_linear)
		#print(camera_zoom, camera_zoom_linear);

func get_canvas_coordinates(point : Vector2):
	return (Vector2(point.x, point.y) / camera_zoom) - canvas_pos
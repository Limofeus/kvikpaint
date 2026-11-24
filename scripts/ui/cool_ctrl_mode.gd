extends Node
class_name CoolControlMode

@export var background_control : ColorRect

@export var cool_mode_background_color : Color = Color.BLACK
@export var cool_mode_grid_color : Color = Color.WHITE

@export var cool_mode_background_lerp_power : float = 15.0
@export var cool_mode_grid_lerp_power : float = 5.0

var default_background_color : Color = Color.BLACK
var default_grid_color : Color = Color.WHITE

var is_in_control_mode : bool = false

var current_bg_color = Color.BLACK
var current_grid_color = Color.BLACK

func _ready():
	default_background_color = background_control.material.get_shader_parameter("main_color")
	default_grid_color = background_control.material.get_shader_parameter("stroke_color")
	current_bg_color = default_background_color
	current_grid_color = default_grid_color

func _input(event):
	is_in_control_mode = Input.is_action_pressed("ctrl_modifier_key")

func _process(delta):
	current_bg_color = StaticUtility.lerp_dampen(current_bg_color, cool_mode_background_color if is_in_control_mode else default_background_color, cool_mode_background_lerp_power, delta)
	current_grid_color = StaticUtility.lerp_dampen(current_grid_color, cool_mode_grid_color if is_in_control_mode else default_grid_color, cool_mode_grid_lerp_power, delta)
	background_control.material.set_shader_parameter("main_color", current_bg_color)
	background_control.material.set_shader_parameter("stroke_color", current_grid_color)
extends Node
class_name BrushController

const FONT_SIZE_TO_ACTUAL_TEXT_SIZE = 0.8

@export var _default_brush_settings : BrushSettings = preload("res://resources/custom/brush settings/default_brush_settings.tres")
@export var _brush_settings : BrushSettings = null

@export var brush_display : BrushDisplay = null

@export var main_draw_state : LineDrawState = null

@export var line_buffer : Line2D = null
@export var text_buffer : Label = null

@export var brush_size_spinbox : SpinBox = null
@export var text_size_mult_spinbox : SpinBox = null

func _ready() -> void:
	# Add a function to save users brush settings
	if _brush_settings == null:
		_brush_settings = _default_brush_settings.duplicate()

	apply_brush_settings(_brush_settings)


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("sift_modifier_key"):
		if event is InputEventMouseButton and event.pressed:
			if Input.is_action_just_pressed("brush_size_increase"):
				print("INCREASE BRUSH")
				_brush_settings.brush_size += 1 + floor(_brush_settings.brush_size / 10.0)
				_brush_settings.brush_size = min(_brush_settings.brush_size, 500)
				apply_brush_settings(_brush_settings)
			elif Input.is_action_just_pressed("brush_size_decrease"):
				_brush_settings.brush_size -= 1 + floor(_brush_settings.brush_size / 10.0)
				_brush_settings.brush_size = max(_brush_settings.brush_size, 1)
				apply_brush_settings(_brush_settings)

func change_brush_size(new_size : float):
	_brush_settings.brush_size = new_size
	apply_brush_settings(_brush_settings)

func change_brush_text_size_mult(new_size : float):
	_brush_settings.brush_text_size_mult = new_size
	apply_brush_settings(_brush_settings)

func change_brush_color(new_color : Color):
	_brush_settings.brush_color = new_color
	apply_brush_settings(_brush_settings)

func apply_brush_settings(brush_setting : BrushSettings):
	apply_brush_color(brush_setting.brush_color)
	apply_brush_size(brush_setting.brush_size, brush_setting.brush_text_size_mult)

func apply_brush_color(brush_color : Color):
	main_draw_state.line_color = brush_color
	text_buffer.set("theme_override_colors/font_color", brush_color)

func apply_brush_size(brush_size : float, brush_text_size_mult : float):
	brush_display.set_brush_display_size(brush_size, brush_text_size_mult * FONT_SIZE_TO_ACTUAL_TEXT_SIZE) #This is to make indicator size match text size more closely, maybe I'll rework / remove this

	brush_size_spinbox.value = brush_size
	text_size_mult_spinbox.value = brush_text_size_mult

	line_buffer.width = brush_size
	text_buffer.set("theme_override_font_sizes/font_size", brush_size * brush_text_size_mult)

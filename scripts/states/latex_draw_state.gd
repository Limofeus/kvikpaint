extends DrawState
class_name LatexDrawState

@export var latex_render_recs : TextureRect
@export var latex_text_field : TextEdit
@export var brush_controller : BrushController = null
@export var error_label : Label = null

func _ready():
	latex_text_field.text_changed.connect(text_field_updated)

func _unhandled_input(event):
	if !Input.is_action_pressed("alt_modifier_key") and Input.is_action_pressed("ctrl_modifier_key") and Input.is_action_just_pressed_by_event("enter_latex_equation", event):
		super._set_current()
		print("Register")

func _on_exit():
	latex_text_field.release_focus()

func text_field_updated() -> void:
	if !is_current: super._set_current()
	update_latex_texture(latex_text_field.text)


func update_latex_texture(latex_string : String) -> void:
	var err_msg: String = MicroTeX.validate_latex(latex_string)
	if err_msg != "":
		error_label.text = "ERR: " + err_msg
		return
	error_label.text = ""

	var latex_color := brush_controller.get_brush_settings().brush_color
	var background_color := Color(latex_color.r, latex_color.g, latex_color.b, 0.0)

	latex_render_recs.texture = MicroTeX.latex_to_texture(
		latex_string,
		26.0,
		2.0,
		latex_color,
		background_color,
		14
	)

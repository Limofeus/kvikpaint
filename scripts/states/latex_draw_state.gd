extends CanvasDrawState
class_name LatexDrawState

@export var latex_render_recs : TextureRect = null
@export var latex_text_field : TextEdit = null
@export var brush_controller : BrushController = null
@export var error_label : Label = null
@export var latex_edit_display : LatexEditDisplay = null

#var latex_position : Vector2 = Vector2.ZERO

func _ready():
	latex_text_field.text_changed.connect(text_field_updated)

func _unhandled_input(event):
	if !Input.is_action_pressed("alt_modifier_key") and Input.is_action_pressed("ctrl_modifier_key") and Input.is_action_just_pressed_by_event("enter_latex_equation", event):
		_set_current()
		print("Register")

func _set_current():
	latex_edit_display.set_display_visibility(true)
	latex_edit_display.position = get_viewport().get_mouse_position()
	latex_text_field.text = ""
	update_latex_texture("")
	latex_text_field.grab_focus()
	latex_render_recs.visible = true
	latex_render_recs.size = Vector2.ZERO
	latex_render_recs.position = canvas.get_canvas_coordinates(get_viewport().get_mouse_position())
	super()

func _on_exit():
	draw_to_canvas(true)
	latex_render_recs.visible = false
	latex_text_field.release_focus()
	latex_edit_display.set_display_visibility(false)

func text_field_updated() -> void:
	if !is_current: _set_current()
	update_latex_texture(latex_text_field.text)

func update_latex_texture(latex_string : String) -> void:
	#print("String updated: ", latex_string)
	if latex_string == "":
		latex_render_recs.texture = ImageTexture.create_from_image(Image.create_empty(2, 2, false, Image.FORMAT_RGBA8))

	var err_msg: String = MicroTeX.validate_latex(latex_string)
	if err_msg != "":
		error_label.text = "ERR: " + err_msg
		return
	error_label.text = ""

	var latex_color := brush_controller.get_brush_settings().brush_color
	var background_color := Color(latex_color.r, latex_color.g, latex_color.b, 0.0)

	latex_render_recs.texture = MicroTeX.latex_to_texture(
		latex_string,
		20.0,
		2.0,
		latex_color,
		background_color,
		14
	)

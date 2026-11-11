extends MarginContainer

@onready var latex_input: LineEdit = %LatexInput
@onready var render_btn: Button = %RenderBtn
@onready var metrics_label: Label = %MetricsLabel
@onready var preview_texture: TextureRect = %PreviewTexture
@onready var gallery_list: VBoxContainer = %GalleryList

const PRESET_FORMULAS: Array[Dictionary] = [
	{
		"title": "Gaussian Integral",
		"latex": "\\int_{-\\infty}^{\\infty} e^{-x^2} \\, dx = \\sqrt{\\pi}"
	},
	{
		"title": "Quadratic Formula",
		"latex": "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}"
	},
	{
		"title": "Basel Problem",
		"latex": "\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}"
	},
	{
		"title": "Matrix & Determinant",
		"latex": "A = \\begin{pmatrix} a_{11} & a_{12} \\\\ a_{21} & a_{22} \\end{pmatrix}, \\quad \\det(A) = a_{11}a_{22} - a_{12}a_{21}"
	},
	{
		"title": "Piecewise Function",
		"latex": "|x| = \\begin{cases} x & \\text{if } x \\geq 0 \\\\ -x & \\text{if } x < 0 \\end{cases}"
	},
	{
		"title": "Binomial Theorem",
		"latex": "(x + y)^n = \\sum_{k=0}^{n} \\binom{n}{k} x^{n-k} y^k"
	}
]

func _ready() -> void:
	MicroTeX.init_resources("res://addons/microtex/res")
	render_btn.pressed.connect(_on_render_pressed)
	latex_input.text_submitted.connect(func(_t: String) -> void: _on_render_pressed())
	_on_render_pressed()
	_populate_gallery()

func _on_render_pressed() -> void:
	var expr: String = latex_input.text
	var info: Dictionary = MicroTeX.parse_latex_with_metrics(
		expr,
		26.0,
		Color(0.95, 0.97, 1.0, 1.0),
		Color(0.14, 0.17, 0.24, 1.0),
		14
	)
	if info.get("error", "") != "":
		metrics_label.text = "Error: " + str(info["error"])
		return

	metrics_label.text = "Size: %dx%d px  |  Depth: %d px  |  Baseline ratio: %.3f  |  SVG length: %d chars" % [
		info["width"], info["height"], info["depth"], info["baseline"], str(info["svg"]).length()
	]
	preview_texture.texture = MicroTeX.latex_to_texture(
		expr,
		26.0,
		2.0,
		Color(0.95, 0.97, 1.0, 1.0),
		Color(0.14, 0.17, 0.24, 1.0),
		14
	)

func _populate_gallery() -> void:
	var renderer := MicroTeX.new()
	renderer.default_font_size = 24.0
	renderer.default_foreground = Color(0.90, 0.95, 1.0, 1.0)
	renderer.default_background = Color(0.12, 0.15, 0.21, 1.0)
	renderer.default_padding = 12

	for item in PRESET_FORMULAS:
		var lbl := Label.new()
		lbl.text = item["title"] + "  —  " + item["latex"]
		gallery_list.add_child(lbl)

		var tex_rect := TextureRect.new()
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP
		tex_rect.texture = renderer.get_texture(item["latex"], 1.5)
		gallery_list.add_child(tex_rect)

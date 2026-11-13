extends MarginContainer

@onready var preset_bar: HBoxContainer = %PresetBar
@onready var latex_input: TextEdit = %LatexInput
@onready var render_btn: Button = %RenderBtn
@onready var metrics_label: Label = %MetricsLabel
@onready var preview_texture: TextureRect = %PreviewTexture
@onready var gallery_list: VBoxContainer = %GalleryList

const PRESET_FORMULAS: Array[Dictionary] = [
	{
		"title": "Multilingual BMP Text",
		"latex": "\\text{Hello Привет こんにちは カタカナ 数学}"
	},
	{
		"title": "Complex Multi-Line Array",
		"latex": "%Complex formula test\n\\begin{array}{l}\n  \\forall\\varepsilon\\in\\mathbb{R}_+^*\\ \\exists\\eta>0\\ |x-x_0|<\\eta\\implies|f(x)-f(x_0)|<\\varepsilon\\\\\n  \\det\\begin{bmatrix}a_{11}&a_{12}&\\cdots&a_{1n}\\\\a_{21}&\\ddots&&\\vdots\\\\\\vdots&&\\ddots&\\vdots\\\\a_{n1}&\\cdots&\\cdots&a_{nn}\\end{bmatrix}\\overset{\\mathrm{def}}{=}\\sum_{\\sigma\\in\\mathfrak{S}_n}\\varepsilon(\\sigma)\\prod_{k=1}^n a_{k,\\sigma(k)}\\\\\n  \\sideset{_\\alpha^\\beta}{_\\gamma^\\delta}{\\begin{pmatrix}a&b\\\\c&d\\end{pmatrix}}\n\\end{array}"
	},
	{
		"title": "Gaussian Integral",
		"latex": "\\int_{-\\infty}^{\\infty} e^{-x^2} \\, dx = \\sqrt{\\pi}"
	},
	{
		"title": "Quadratic Formula",
		"latex": "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}"
	},
	{
		"title": "Piecewise Function",
		"latex": "|x| = \\begin{cases} x & \\text{if } x \\geq 0 \\\\ -x & \\text{otherwise} \\end{cases}"
	},
	{
		"title": "Binomial Theorem",
		"latex": "(x + y)^n = \\sum_{k=0}^{n} \\binom{n}{k} x^{n-k} y^k"
	}
]

func _ready() -> void:
	MicroTeX.init_resources("res://addons/microtex/res")
	render_btn.pressed.connect(_on_render_pressed)
	latex_input.text_changed.connect(_on_text_changed)
	_populate_preset_buttons()
	_on_render_pressed()
	_populate_gallery()

func _populate_preset_buttons() -> void:
	for item in PRESET_FORMULAS:
		var btn := Button.new()
		btn.text = item["title"]
		var formula_text: String = item["latex"]
		btn.pressed.connect(func() -> void:
			latex_input.text = formula_text
			_on_render_pressed()
		)
		preset_bar.add_child(btn)

func _on_text_changed() -> void:
	# Silent validation check before updating texture: prevents console error spam while typing
	var expr: String = latex_input.text
	var err_msg: String = MicroTeX.validate_latex(expr)
	if err_msg != "":
		metrics_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
		metrics_label.text = "Syntax incomplete / invalid (preview kept): " + err_msg
		return
	_on_render_pressed()

func _on_render_pressed() -> void:
	var expr: String = latex_input.text
	var err_msg: String = MicroTeX.validate_latex(expr)
	if err_msg != "":
		metrics_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
		metrics_label.text = "Syntax error: " + err_msg
		return

	var info: Dictionary = MicroTeX.parse_latex_with_metrics(
		expr,
		26.0,
		Color(0.95, 0.97, 1.0, 1.0),
		Color(0.14, 0.17, 0.24, 1.0),
		14
	)
	if info.get("error", "") != "":
		metrics_label.modulate = Color(1.0, 0.55, 0.55, 1.0)
		metrics_label.text = "Error: " + str(info["error"])
		return

	metrics_label.modulate = Color(0.85, 0.95, 0.88, 1.0)
	metrics_label.text = "Valid LaTeX  |  Size: %dx%d px  |  Depth: %d px  |  Baseline ratio: %.3f  |  SVG length: %d chars" % [
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
	renderer.default_font_size = 22.0
	renderer.default_foreground = Color(0.90, 0.95, 1.0, 1.0)
	renderer.default_background = Color(0.12, 0.15, 0.21, 1.0)
	renderer.default_padding = 12

	for item in PRESET_FORMULAS:
		var lbl := Label.new()
		lbl.text = item["title"]
		gallery_list.add_child(lbl)

		var tex_rect := TextureRect.new()
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP
		if renderer.check_latex_valid(item["latex"]):
			tex_rect.texture = renderer.get_texture(item["latex"], 1.5)
		gallery_list.add_child(tex_rect)

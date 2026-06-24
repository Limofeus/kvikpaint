extends Control
class_name OffsetCanvases

@export var _grid_expand : Vector2i = Vector2i.ZERO
@export var _canvas_spacing : Vector2 = Vector2.ZERO
@export var _scaling_curve : Curve

@export var _lerp_dampen_lambda : float = 10.0

@export var canvas_coords_label : Label = null

var selected_canvas_coords : Vector2i = Vector2i.ZERO
var _lerp_dampen_target : Vector2 = Vector2.ZERO

func _ready() -> void:
	create_offset_canvas_grid(_grid_expand)

func _process(delta: float) -> void:
	dampen_to_target(Vector2(selected_canvas_coords) * _canvas_spacing, delta)
	scale_offset_canvses()

func dampen_to_target(target_position : Vector2, delta : float) -> void:
	_lerp_dampen_target = StaticUtility.lerp_dampen(_lerp_dampen_target, target_position, _lerp_dampen_lambda, delta)
	position = _lerp_dampen_target - (Vector2(selected_canvas_coords) * _canvas_spacing)

func create_offset_canvas_grid(grid_expand : Vector2i) -> void:
	for i in range(-grid_expand.x, grid_expand.x + 1):
		for j in range(-grid_expand.y, grid_expand.y + 1):
			var coords = Vector2i(i, j)
			
			if coords == Vector2i.ZERO:
				continue

			var texture_rect = TextureRect.new()

			var canvas_image = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
			canvas_image.fill(Color.WHITE)
			
			texture_rect.texture = ImageTexture.create_from_image(canvas_image)
			add_child(texture_rect)

			texture_rect.pivot_offset = texture_rect.size / 2.0

			var coordinate_length = coords.length()
			var scale = _scaling_curve.sample_baked(max(abs(coords.x), abs(coords.y)) / float(max(grid_expand.x, grid_expand.y)))
			texture_rect.scale = Vector2.ONE * scale

			texture_rect.position = _canvas_spacing * Vector2(coords)

func scale_offset_canvses() -> void:
	for child_control : Control in get_children():
		var coords : Vector2 = (child_control.position + position) / _canvas_spacing
		child_control.scale = Vector2.ONE * _scaling_curve.sample_baked(max(abs(coords.x), abs(coords.y)) / float(max(_grid_expand.x, _grid_expand.y)))

func select_canvas(coords : Vector2i, smoothing : bool = true) -> void:
	selected_canvas_coords = coords
	canvas_coords_label.text = str(selected_canvas_coords)

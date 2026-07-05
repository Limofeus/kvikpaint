extends Control
class_name OffsetCanvases

@export var _grid_expand : Vector2i = Vector2i.ZERO
@export var _canvas_spacing : Vector2 = Vector2.ZERO
@export var _scaling_curve : Curve

@export var _lerp_dampen_lambda : float = 10.0

@export var canvas_coords_label : Label = null

@export var _enable_hidden_expand : bool = true

var _canvas_loader : CanvasLoader = null
var selected_canvas_coords : Vector2i = Vector2i.ZERO

var _lerp_dampen_target : Vector2 = Vector2.ZERO

var _hidden_expand_vector : Vector2 = Vector2.ZERO

#func _ready() -> void:
	#create_offset_canvas_grid(_grid_expand)

func _process(delta: float) -> void:
	dampen_to_target(Vector2(selected_canvas_coords) * _canvas_spacing, delta)
	scale_offset_canvses()
	dampen_transparency_target(float(Input.is_action_pressed("ctrl_modifier_key")), delta)

func set_canvas_loader(canvas_loader : CanvasLoader) -> void:
	_canvas_loader = canvas_loader
	_canvas_loader.canvas_finished_loading.connect(canvas_data_finished_loading)
	create_offset_canvas_grid(_grid_expand)

func canvas_data_finished_loading(coords : Vector2i) -> void:
	var active_canvas = _get_child_by_canvas_coords(coords)
	if active_canvas != null:
		var canvas_data = _canvas_loader.request_canvas_data(coords)
		canvas_data._canvas_load_mutex.lock()
		update_canvas_texture(active_canvas, canvas_data._canvas_texture)
		canvas_data._canvas_load_mutex.unlock()

func update_canvas_texture(canvas_control : Control, texture : ImageTexture) -> void:
	if texture == null:
		canvas_control.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	else:
		canvas_control.self_modulate = Color.WHITE
		canvas_control.texture = texture

func dampen_to_target(target_position : Vector2, delta : float) -> void:
	_lerp_dampen_target = StaticUtility.lerp_dampen(_lerp_dampen_target, target_position, _lerp_dampen_lambda, delta)
	
	position = -(_lerp_dampen_target - (Vector2(selected_canvas_coords) * _canvas_spacing)) - (_hidden_expand_vector * _canvas_spacing)

func dampen_transparency_target(target_alpha : float, delta : float) -> void:
	modulate.a = StaticUtility.lerp_dampen(modulate.a, target_alpha, _lerp_dampen_lambda, delta)

func create_offset_canvas_grid(grid_expand : Vector2i) -> void:
	for i in range(-grid_expand.x, grid_expand.x + 1 + (int(_enable_hidden_expand))):
		for j in range(-grid_expand.y, grid_expand.y + 1 + (int(_enable_hidden_expand))):
			var coords = Vector2i(i, j)
			
			#if coords == Vector2i.ZERO:
				#continue

			var texture_rect = TextureRect.new()

			var canvas_image = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
			canvas_image.fill(Color.WHITE)
			
			texture_rect.texture = ImageTexture.create_from_image(canvas_image)
			add_child(texture_rect)

			texture_rect.pivot_offset = texture_rect.size / 2.0

			var distance_to_center = max(abs(coords.x), abs(coords.y)) #Using manhattan distance
			var grid_max = float(max(grid_expand.x, grid_expand.y))
			var scale = _scaling_curve.sample_baked(distance_to_center / grid_max)
			var rescale_after_curve = lerp(1.0, 0.0, clamp(distance_to_center - grid_max, 0.0, 1.0))
			texture_rect.scale = Vector2.ONE * scale * rescale_after_curve

			texture_rect.position = _canvas_spacing * Vector2(coords)

func update_canvas_grid_data() -> void:
	for i in range(-_grid_expand.x, _grid_expand.x + 1 + (int(_enable_hidden_expand))):
		for j in range(-_grid_expand.y, _grid_expand.y + 1 + (int(_enable_hidden_expand))):
			var coords = Vector2i(i, j) + selected_canvas_coords
			
			var canvas_data = _canvas_loader.request_canvas_data(coords, false)
			var active_canvas := _get_child_by_canvas_coords(coords)
			if active_canvas == null:
				continue

			update_canvas_texture(active_canvas, canvas_data._canvas_texture)

func _get_child_by_canvas_coords(coords : Vector2i) -> Control:
	var relative_coords : Vector2i = coords - selected_canvas_coords
	relative_coords += Vector2i(_grid_expand)
	relative_coords += Vector2i(_hidden_expand_vector)
	var child_index = (relative_coords.x * (_grid_expand.y * 2 + 1 + (int(_enable_hidden_expand)))) + relative_coords.y
	
	if child_index < 0 or child_index >= get_child_count():
		return null
	return get_child(child_index)

func scale_offset_canvses() -> void:
	for child_control : Control in get_children():
		var coords : Vector2 = (child_control.position + position) / _canvas_spacing
		var distance_to_center = max(abs(coords.x), abs(coords.y)) #Using manhattan distance
		var grid_max = float(max(_grid_expand.x, _grid_expand.y))
		var base_scale = _scaling_curve.sample_baked(distance_to_center / grid_max)
		var rescale_after_curve = lerp(1.0, 0.0, clamp(distance_to_center - grid_max, 0.0, 1.0))
		var rescale_center = clamp(distance_to_center, 0.0, 1.0)
		child_control.scale = Vector2.ONE * base_scale * rescale_after_curve * rescale_center

func select_canvas(coords : Vector2i, smoothing : bool = true) -> void:
	_hidden_expand_vector.x = float(selected_canvas_coords.x <= coords.x) if _enable_hidden_expand else 0.0
	_hidden_expand_vector.y = float(selected_canvas_coords.y <= coords.y) if _enable_hidden_expand else 0.0
	
	selected_canvas_coords = coords
	canvas_coords_label.text = str(selected_canvas_coords)

	update_canvas_grid_data.call_deferred()
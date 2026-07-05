class_name CanvasLoader

const MAX_LOADED_CANVAS_COUNT = 50 #Default canvas grid is 7x7=49... and an extra one for good measure

var absolute_canvas_path_template : String = ""
var canvases_by_coords : Dictionary[Vector2i, CanvasData] = {}
var canvas_queue : Array[CanvasData] = []

signal canvas_finished_loading(canvas_coords : Vector2i)

class CanvasData:
	var _canvas_image : Image = null
	#var _canvas_texture : ImageTexture = null
	var _canvas_coords : Vector2i = Vector2i.ZERO
	var _canvas_load_mutex : Mutex = Mutex.new()
	var _canvas_load_thread : Thread = Thread.new()
	var _canvas_load_state : int = CanvasLoadingState.UNLOADED

	signal canvas_load_state_changed(canvas_load_state : CanvasLoadingState)

	enum CanvasLoadingState {UNLOADED, NO_FILE, LOADING, LOADED, FAILED}

	func set_canvas_loading_state(state : int) -> void:
		_canvas_load_mutex.lock()
		_canvas_load_state = state
		print("On canvas ", _canvas_coords, " state changed to: ", _canvas_load_state)
		_canvas_load_mutex.unlock()
		canvas_load_state_changed.emit(_canvas_load_state)

	func load_canvas_from_file(filepath : String, multithreaded : bool = true) -> void:
		if _canvas_load_state == CanvasLoadingState.LOADING:
			return
		if !FileAccess.file_exists(filepath):
			set_canvas_loading_state(CanvasLoadingState.NO_FILE)
			return
		set_canvas_loading_state(CanvasLoadingState.LOADING)
		if multithreaded:
			_canvas_load_thread.start(_load_canvas_from_file.bind(filepath))
		else:
			_load_canvas_from_file(filepath)

	func _load_canvas_from_file(filepath : String) -> void:
		_canvas_image = Image.load_from_file(filepath)
		#_canvas_texture = ImageTexture.create_from_image(_canvas_image)
		set_canvas_loading_state(CanvasLoadingState.LOADED)

	func _init(canvas_coords : Vector2i) -> void:
		_canvas_coords = canvas_coords

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			_canvas_load_thread.wait_to_finish()

func _on_canvas_load_state_changed(canvas_load_state : int, coords : Vector2i) -> void:
	if canvas_load_state == CanvasData.CanvasLoadingState.LOADED:
		canvas_finished_loading.emit(coords)

func create_canvas_data(coords : Vector2i) -> CanvasData:
	var canvas_data = CanvasData.new(coords)
	canvas_data.canvas_load_state_changed.connect(_on_canvas_load_state_changed.bind(coords))

	canvases_by_coords[coords] = canvas_data
	canvas_queue.push_back(canvas_data)
	if canvas_queue.size() > MAX_LOADED_CANVAS_COUNT:
		canvases_by_coords.erase(canvas_queue.pop_front()._canvas_coords)
	return canvas_data

func set_canvas_data_image(coords : Vector2i, image : Image) -> void:
	print("Setting image of canvas with coords: ", coords)
	var canvas_data = canvases_by_coords[coords]
	canvas_data._canvas_image = image.duplicate()
	#if canvas_data._canvas_texture == null:
	#	canvas_data._canvas_texture = ImageTexture.create_from_image(image)
	#else:
	#	canvas_data._canvas_texture.set_image(image)

func load_canvas_at_coords(coords : Vector2i, force_load : bool = false) -> void:
	var canvas_data = null
	if canvases_by_coords.has(coords):
		canvas_data = canvases_by_coords[coords]
	else:
		canvas_data = create_canvas_data(coords)
	canvas_data.load_canvas_from_file(absolute_canvas_path_template % [coords.x, coords.y], !force_load)

func request_canvas_data(coords : Vector2i, force_load : bool = false) -> CanvasData:
	print("Requested canvas for coords: ", coords)
	if canvases_by_coords.has(coords):
		print("Fast returning canvas with: ", canvases_by_coords[coords]._canvas_coords)
		return canvases_by_coords[coords]
	load_canvas_at_coords(coords, force_load)
	print("Load returning canvas with: ", canvases_by_coords[coords]._canvas_coords)
	return canvases_by_coords[coords]

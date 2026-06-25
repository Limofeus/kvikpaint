class_name CanvasLoader

var canvases_by_coords : Dictionary[Vector2i, CanvasData] = {}
var canvas_queue : Array[CanvasData] = []

class CanvasData:
	var canvas_image : Image = null
	var canvas_coords : Vector2i = Vector2i.ZERO
	var canvas_load_mutex : Mutex = Mutex.new()
	var canvas_load_state : int = CanvasLoadingState.UNLOADED

	enum CanvasLoadingState {UNLOADED, NO_FILE, LOADING, LOADED, FAILED}

	func set_canvas_loading_state(state : int) -> void:
		canvas_load_mutex.lock()
		canvas_load_state = state
		canvas_load_mutex.unlock()
extends Node
class_name SaveSystem

const SAVE_SYSTEM_VERSION := 1

const SAVE_FILE_PATH = "user://save_file.funky"
const SAVED_CANVASES_PATH = "user://saved_canvases/"
const CANVAS_NAME_TEMPLATE = "save_canvas_%d_%d.png"
const CANVAS_NAME_COORDS_SEPARATOR = "_"

@export var brush_controller : BrushController = null
@export var palette_controller : PaletteController = null
@export var canvas_controller : CanvasController = null

var canvas_loader : CanvasLoader = CanvasLoader.new()
var async_saving_thread_pool : Array[Thread] = []
var thread_pool_mutex : Mutex = Mutex.new()

@export var hint_node : Control = null

func _ready():
	#get_tree().set_auto_accept_quit(false) # :)
	canvas_controller.changing_canvas.connect((save_current_canvas.bind(true).unbind(1)))
	canvas_loader.absolute_canvas_path_template = SAVED_CANVASES_PATH + CANVAS_NAME_TEMPLATE
	
	var save_resource = load_save_resource()
	save_resource = apply_backward_compatibility(save_resource)
	if save_resource != null:
		apply_save_resource(save_resource)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Close request")
		for thread in async_saving_thread_pool:
			thread.wait_to_finish()

		save_to_file(compose_save_file())
		save_current_canvas()

func extract_ints_from_filename(filename: String) -> Vector2i:
	var parts := filename.substr(0, filename.find(".")).split(CANVAS_NAME_COORDS_SEPARATOR)
	return Vector2i(int(parts[-2]), int(parts[-1]))

func compose_save_file() -> SaveResource:
	print("Composing save file")
	var composed_save_resource = SaveResource.new()

	composed_save_resource.brush_settings = brush_controller._brush_settings.duplicate()
	composed_save_resource.palette = palette_controller.current_palette.duplicate()
	#composed_save_resource.canvas_image = canvas_controller.get_image()

	composed_save_resource.selected_canvas = canvas_controller.canvas_offset

	return composed_save_resource

func apply_save_resource(save_resource : SaveResource) -> void:	

	brush_controller._brush_settings = save_resource.brush_settings
	palette_controller.current_palette = save_resource.palette
	
	canvas_controller.set_canvas_loader(canvas_loader)
	canvas_controller.set_canvas_offset(save_resource.selected_canvas)
	#canvas_controller.set_image(save_resource.canvas_image)

	hint_node.visible = false

func save_to_file(save_resource : SaveResource) -> void:
	print("Saving to file")
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	#print(save_resource)
	save_file.store_var(save_resource, true)
	save_file.close()

func save_current_canvas(async_save : bool = false) -> void:
	if async_save:
		var image_to_save = canvas_controller.get_image()
		var save_coords = canvas_controller.canvas_offset

		var save_thread = Thread.new()
		thread_pool_mutex.lock()
		async_saving_thread_pool.append(save_thread)
		thread_pool_mutex.unlock()
		save_thread.start(save_canvas_at_coords.bind(image_to_save, save_coords, save_thread))
	else:
		save_canvas_at_coords(canvas_controller.get_image(), canvas_controller.canvas_offset)

func save_canvas_at_coords(canvas_image : Image, coords : Vector2i, async_thread : Thread = null) -> void:
	if canvas_image == null:
		return
	var canvas_filename = CANVAS_NAME_TEMPLATE % [coords.x, coords.y]
	if !DirAccess.dir_exists_absolute(SAVED_CANVASES_PATH):
		DirAccess.make_dir_absolute(SAVED_CANVASES_PATH)
	canvas_image.save_png(SAVED_CANVASES_PATH + canvas_filename)

	if async_thread != null:
		thread_pool_mutex.lock()
		async_saving_thread_pool.erase(async_thread)
		thread_pool_mutex.unlock()

func load_save_resource() -> SaveResource:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file")
		return null
	print("Found save file")
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var save_resource = save_file.get_var(true)
	save_file.close()

	return save_resource

func load_canvases_filenames() -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(SAVED_CANVASES_PATH):
		print("No canvas directory")
		DirAccess.make_dir_absolute(SAVED_CANVASES_PATH)
	return DirAccess.get_files_at(SAVED_CANVASES_PATH)

func apply_backward_compatibility(save_resource : SaveResource) -> SaveResource:
	if save_resource.save_file_version != SAVE_SYSTEM_VERSION:
		print("Save file version mismatch: Save file version: %s, Current version: %s" % [save_resource.save_file_version, SAVE_SYSTEM_VERSION])
	if not "selected_canvas" in save_resource:
		print("No selected canvas")
		save_resource.selected_canvas = Vector2i.ZERO
	if save_resource.canvas_image != null:
		print("Canvas image is stored in save resource, saving separately")
		save_canvas_at_coords(save_resource.canvas_image, Vector2.ZERO)
		save_resource.canvas_image = null
	return save_resource

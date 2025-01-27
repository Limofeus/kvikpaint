extends Node
class_name SaveSystem

const SAVE_FILE_PATH = "user://save_file.funky"

@export var brush_controller : BrushController = null
@export var palette_controller : PaletteController = null
@export var canvas_controller : CanvasController = null

@export var hint_node : Control = null

func _ready():
	var save_resource = load_from_file()
	if save_resource != null:
		brush_controller._brush_settings = save_resource.brush_settings
		palette_controller.current_palette = save_resource.palette
		canvas_controller.set_image(save_resource.canvas_image)

		hint_node.visible = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_file(compose_save_file())

func compose_save_file() -> SaveResource:
	var composed_save_resource = SaveResource.new()

	composed_save_resource.brush_settings = brush_controller._brush_settings.duplicate()
	composed_save_resource.palette = palette_controller.current_palette.duplicate()
	composed_save_resource.canvas_image = canvas_controller.get_image()

	return composed_save_resource

func save_to_file(save_resource : SaveResource) -> void:
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	print(save_resource)
	save_file.store_var(save_resource, true)
	save_file.close()

func load_from_file() -> SaveResource:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return null
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var save_resource = save_file.get_var(true)
	save_file.close()

	return save_resource

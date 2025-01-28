extends Node
class_name CanvasController

@export var canvas : Canvas = null

@onready var image_save_path : String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ctrl_modifier_key"):
		if Input.is_action_just_pressed("copy_image"):
			DisplayServer.clipboard_set("Sorry, Godot can't copy images yet, so like in MS Paint you'll have to use screenshot hotkey for now, I'll update the app when support for copying images is added!")
		
		if Input.is_action_just_pressed("undo_draw"):
			canvas.undo_last_draw()

		if Input.is_action_just_pressed("save_image"):
			save_image(image_save_path)

		if Input.is_action_just_pressed("clear_canvas"):
			canvas.clear_canvas()

func set_image(image : Image):
	canvas.call_deferred("set_image", image)

func get_image() -> Image:
	return canvas.get_image()

func save_image(path : String):
	var image : Image = get_image()

	var image_filename = "epic_drawing"

	var image_save_path = path + "/" + image_filename + ".png"

	var counter = 0
	while FileAccess.file_exists(image_save_path):
		counter += 1
		image_save_path = path + "/" + image_filename + "_" + str(counter) + ".png"

		if counter > 100:
			image_save_path = path + "/" + image_filename + "_" + str(Time.get_unix_time_from_system()) + ".png"

	image.save_png(image_save_path)
	OS.shell_show_in_file_manager(image_save_path)
extends Node
class_name CanvasController

@export var canvas : Canvas = null
@export var canvas_offseter : OffsetCanvases = null

var canvas_offset : Vector2i = Vector2i.ZERO
var _canvas_loader : CanvasLoader = null

signal changing_canvas(change_coords : Vector2i, is_altered : bool, is_clean : bool)

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

		if Input.is_action_pressed("ctrl_modifier_key"):
			if Input.is_action_just_pressed("arrow_right"):
				offset_canvas(Vector2i.RIGHT)
			if Input.is_action_just_pressed("arrow_left"):
				offset_canvas(Vector2i.LEFT)
			if Input.is_action_just_pressed("arrow_down"):
				offset_canvas(Vector2i.DOWN)
			if Input.is_action_just_pressed("arrow_up"):
				offset_canvas(Vector2i.UP)

func offset_canvas(offset : Vector2i):
	if offset == Vector2i.ZERO:
		return
	changing_canvas.emit(canvas_offset, canvas.is_altered, canvas.is_clean)
	
	if canvas.is_altered:
		if canvas.is_clean:
			_canvas_loader.set_canvas_data_image(canvas_offset, null)
		else:
			_canvas_loader.set_canvas_data_image(canvas_offset, get_image())
	
	set_canvas_offset(canvas_offset + offset)
	print("New canvas offset: ", canvas_offset)

func set_canvas_loader(canvas_loader : CanvasLoader):
	_canvas_loader = canvas_loader
	canvas_offseter.set_canvas_loader(canvas_loader)

func set_canvas_offset(offset : Vector2i):
	canvas_offset = offset
	canvas_offseter.select_canvas(canvas_offset)
	
	var canvas_data = _canvas_loader.request_canvas_data(canvas_offset, true)
	var new_image = canvas_data._canvas_image
	if new_image == null:
		new_image = Image.create(1600, 900, false, Image.FORMAT_RGBA8)
		new_image.fill(Color.WHITE)
	else:
		new_image = new_image.duplicate()
	set_image(new_image)

func set_image(image : Image):
	canvas.set_image(image)
	canvas.is_altered = false
	canvas.is_clean = false

func get_image() -> Image:
	return canvas.get_image()

func save_image(path : String):
	var image : Image = get_image()

	var image_filename = "epic_drawing"

	var save_path = path + "/" + image_filename + ".png"

	if OS.get_name() == "Web":
		print("OS is Web, saving using JS")
		
		var image_data : PackedByteArray = image.save_png_to_buffer()

		var base_64_data = Marshalls.raw_to_base64(image_data)
		var url = "data:image/jpg;base64," + base_64_data
		var comand = "
			var a = document.createElement('a'); 
			a.href = '" + url + "';  //<---- single qoutes and double quotes
			a.setAttribute( 'download' , 'epic_drawing.png' );
			a.click(); 
		"
		JavaScriptBridge.eval(comand, true)

	else:
		print("OS is not Web, saving using counter")
		var counter = 0
		while FileAccess.file_exists(save_path):
			counter += 1
			save_path = path + "/" + image_filename + "_" + str(counter) + ".png"

			if counter > 100:
				save_path = path + "/" + image_filename + "_" + str(Time.get_unix_time_from_system()) + ".png"

		image.save_png(save_path)
		OS.shell_show_in_file_manager(save_path)

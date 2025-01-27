extends Node
class_name CanvasController

@export var canvas : Canvas = null

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ctrl_modifier_key"):
		if Input.is_action_just_pressed("copy_image"):
			DisplayServer.clipboard_set("Sorry, Godot can't copy images yet, so like in MS Paint you'll have to use screenshot hotkey for now, I'll update the app when support for copying images is added!")
		
		if Input.is_action_just_pressed("undo_draw"):
			canvas.undo_last_draw()

func set_image(image : Image):
	canvas.call_deferred("set_image", image)

func get_image() -> Image:
	return canvas.get_image()
extends Resource
class_name SaveResource #Main save resource, canvas images saved separately


@export var brush_settings : BrushSettings = null
@export var palette : PaletteResource = null

@export var selected_canvas : Vector2i = Vector2i.ZERO

@export var save_file_version : int = 0
# DEPRECATING, USE scripts/resources/saved_canvas.gd
@export var canvas_image : Image = null #Might look in to better ways to serialize images (e.g. save as png)
extends Resource
class_name SaveResource


@export var brush_settings : BrushSettings = null
@export var palette : PaletteResource = null
@export var canvas_image : Image = null #Might look in to better ways to serialize images (e.g. save as png)
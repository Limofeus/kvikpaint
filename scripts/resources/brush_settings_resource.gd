extends Resource
class_name BrushSettings

@export var brush_size : float = 5.0 #Width of the brush in pixels (Diameter of brush circle)
@export var brush_color : Color = Color(0.0, 0.0, 0.0, 1.0) #Used for both line and text drawing

enum TextAlignHorizontal {LEFT, CENTER, RIGHT}
enum TextAlignVertical {TOP, CENTER, BOTTOM}

@export var brush_text_size_mult : float = 4.0
@export var text_align_horizontal : TextAlignHorizontal = TextAlignHorizontal.LEFT
@export var text_align_vertical : TextAlignVertical = TextAlignVertical.CENTER

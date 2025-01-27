extends DrawState
class_name CanvasDrawState

@export var canvas : Canvas = null

func draw_to_canvas(blur_edges : bool = false):
	canvas.apply_buffer(blur_edges)
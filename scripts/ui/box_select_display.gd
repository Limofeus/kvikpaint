extends Control
class_name BoxSelectDisplay

@export var box_select_state : BoxSelectState = null
@export var canvas_dragger : CanvasDrag = null

var selection_box : Rect2 = Rect2(0, 0, 0, 0) #In canvas coords so as not to update every time canvas is moved (tho may be changed later)

func _ready():
	box_select_state.selection_box_updated.connect(update_selection_box_coordinates)
	canvas_dragger.canvas_moved.connect(update_selection_box_visual)

func update_selection_box_coordinates() -> void:
	selection_box = box_select_state.canvas_selection_box
	update_selection_box_visual()

func update_selection_box_visual()-> void:
	position = canvas_dragger.get_viewport_coordinates(selection_box.position)
	size = canvas_dragger.camera_zoom * selection_box.size
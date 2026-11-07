extends Control
class_name PointerDisplay

@export var main_pointer_line : Line2D = null
@export var pointer_display : PointerState = null

func _ready() -> void:
	pointer_display.pointer_line_ended.connect(copy_clear_pointer_line)

func copy_clear_pointer_line():
	var copied_line = main_pointer_line.duplicate()
	add_child(copied_line)
	fade_line(copied_line)
	main_pointer_line.clear_points()

func fade_line(line : Line2D):
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0, 0.5)
	tween.tween_callback(line.queue_free)

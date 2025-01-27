extends SpinBox


func _ready() -> void:
	value_changed.connect(loose_focus.unbind(1))


func loose_focus() -> void:
	get_line_edit().release_focus()

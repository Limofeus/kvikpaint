extends MarginContainer
class_name ColorSlot

@export var fill_rect : TextureRect = null
@export var slot_button : Button = null

func setup_slot(fill_color : Color, slot_id : int) -> Button: #Returns button so that user can click on the slot to select color (Click signal should be connected elsewhere)
	change_slot_color(fill_color)
	#slot_button.text = str(slot_id)

	slot_button.text = InputMap.action_get_events("color_slot_" + str(slot_id + 1))[0].as_text().left(1)
	
	return slot_button

func change_slot_color(fill_color) -> void:
	fill_rect.self_modulate = fill_color

extends Node
class_name PaletteController

const COLOR_SLOTS_COUNT = 10 #All palettes should have 10 colors, maybe this will be reworked (probably not)

@export var brush_controller : BrushController = null

@export var color_slot_holder : Control = null
@export var color_slot_scene : PackedScene = null

@export var palette_selector : OptionButton = null

@export var palettes : Array[PaletteResource] = []

var current_palette : PaletteResource = null
var color_slots : Array[ColorSlot] = []

func _ready() -> void:

	palette_selector.clear()
	for palette : PaletteResource in palettes:
		palette_selector.add_item(palette.palette_name)

	if current_palette == null:
		current_palette = palettes[0]
	else:
		palette_selector.text = current_palette.palette_name

	for slot_id : int in range(COLOR_SLOTS_COUNT):
		var color_slot : ColorSlot = color_slot_scene.instantiate()
		
		var slot_button : Button = color_slot.setup_slot(current_palette.palette_colors[slot_id], slot_id)
		slot_button.pressed.connect(change_color.bind(slot_id))
		
		color_slot_holder.add_child(color_slot) #Maybe call this before setting up slots, but should work either way
		color_slots.append(color_slot)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ctrl_modifier_key"):
		for i : int in COLOR_SLOTS_COUNT:
			if Input.is_action_just_pressed("color_slot_" + str(i + 1)):
				change_color(i)

func change_palette_by_id(palette_id : int):
	change_palette(palettes[palette_id])

func change_palette(new_palette : PaletteResource):
	current_palette = new_palette

	for slot_id : int in range(COLOR_SLOTS_COUNT):
		color_slots[slot_id].change_slot_color(new_palette.palette_colors[slot_id])

func change_color(slot_id : int):
	brush_controller.change_brush_color(current_palette.palette_colors[slot_id])

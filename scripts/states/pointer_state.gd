extends DrawState
class_name PointerState

const START_POINTER_CHARGE_MIN : float = 180.0
const START_POINTER_CHARGE_MAX : float = 300.0


@export var brush_controller : BrushController = null
@export var pointer_line : Line2D = null
@export var charge_to_brightness_curve : Curve = null

@export var charge_at_which_allow_battery_change : float = 50.0
@export var charge_at_which_show_warning : float = 25.0

@export var pointer_recharge_control : Control = null
@export var pointer_recharge_button : Button = null
@export var pointer_animation_player : AnimationPlayer = null
@export var pointer_low_power_label : Label = null

var pointer_charge : float = 0.0
var has_battery : bool = true
var can_recharge : bool = false
var recharge_tween : Tween = null

signal pointer_line_ended()

func _ready():
	pointer_charge = randf_range(START_POINTER_CHARGE_MIN, START_POINTER_CHARGE_MAX)
	pointer_recharge_button.pressed.connect(recharge_button_pressed)

func _unhandled_input(event):
	if has_battery == false:
		return

	if event is InputEventMouseButton and Input.is_action_pressed("alt_modifier_key"):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			super._set_current()
			var color = brush_controller.get_brush_settings().brush_color
			color.a = charge_to_brightness_curve.sample_baked(pointer_charge)
			pointer_line.gradient.set_color(1, color)
			color.a = 0
			pointer_line.gradient.set_color(0, color)
			#pointer_line.width = line_width
			pointer_line.add_point(event.position)

	if event is InputEventMouseMotion:
		if is_current:
			pointer_line.add_point(event.position)
			
			var new_grad_color = brush_controller.get_brush_settings().brush_color
			new_grad_color.a = charge_to_brightness_curve.sample_baked(pointer_charge)
			pointer_line.gradient.set_color(1, new_grad_color)

			var point_count = pointer_line.get_point_count()
			var travel_vector = pointer_line.get_point_position(point_count - 1) - pointer_line.get_point_position(point_count - 2)
			
			pointer_charge -= (travel_vector / pointer_line.get_viewport_rect().size).length()
			update_charge()

func _on_exit():
	pointer_line_ended.emit()

func recharge_button_pressed() -> void:
	if can_recharge:
		if has_battery:
			has_battery = false
			can_recharge = false
			pointer_animation_player.play("remove_battery")
			await pointer_animation_player.animation_finished
			can_recharge = true
		else:
			can_recharge = false
			pointer_animation_player.play("add_battery")
			await pointer_animation_player.animation_finished
			has_battery = true
			pointer_low_power_label.visible = false
			pointer_charge = randf_range(START_POINTER_CHARGE_MIN, START_POINTER_CHARGE_MAX)
			recharge_tween = create_tween()
			recharge_tween.set_ease(Tween.EASE_IN)
			recharge_tween.tween_property(pointer_recharge_control, "modulate:a", 0.0, 0.5)

func update_charge() -> void:
	if pointer_charge < charge_at_which_show_warning:
		pointer_low_power_label.visible = true
	else:
		pointer_low_power_label.visible = false

	if pointer_charge < charge_at_which_allow_battery_change:
		pointer_recharge_button.visible = true
		if (recharge_tween == null or !recharge_tween.is_running()) and !can_recharge:
			recharge_tween = create_tween()
			recharge_tween.set_ease(Tween.EASE_OUT)
			recharge_tween.tween_property(pointer_recharge_control, "modulate:a", 1.0, 0.5)
			await recharge_tween.finished
			can_recharge = true

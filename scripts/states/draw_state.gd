extends Node
class_name DrawState

@export var state_machine : DrawStateMachine = null
var is_current : bool = false

func _on_exit():
	pass

func _set_current():
	state_machine.change_state(self)
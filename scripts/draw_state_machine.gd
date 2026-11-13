extends Node
class_name DrawStateMachine

var current_state : DrawState = null
var state_locked : bool = false

func change_state(new_state : DrawState):
	print("New draw state: ", new_state.get_script().get_global_name())
	if state_locked:
		return
	if current_state != null:
		current_state._on_exit()
		current_state.is_current = false
	current_state = new_state
	current_state.is_current = true

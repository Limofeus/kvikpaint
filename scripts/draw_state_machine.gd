extends Node
class_name DrawStateMachine

var current_state : DrawState = null

func change_state(new_state : DrawState):
	if current_state != null:
		current_state._on_exit()
		current_state.is_current = false
	current_state = new_state
	current_state.is_current = true

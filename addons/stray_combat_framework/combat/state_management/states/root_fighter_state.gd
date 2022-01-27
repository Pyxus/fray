extends "fighter_state.gd"

var condition_dict: Dictionary

func chain(fighter_state: Reference, input: InputData, chain_conditions: PoolStringArray = [], active_condition: String = "", transition_animation: String = "") -> bool:
	if .chain(fighter_state, input, chain_conditions, active_condition, transition_animation):
		fighter_state.root = self
		return true
	return false


func connect_extender(fighter_state: Reference, transition_animation: String = "") -> bool:
	if .connect_extender(fighter_state, transition_animation):
		fighter_state.root = self
		return true
	return false
	
	
func is_condition_true(condition: String) -> bool:
	if condition_dict.has(condition):
		return condition_dict[condition]
	
	return false


func _is_all_conditions_met(state_connection: StateConnection) -> bool:
	var active_condition: String = state_connection.to.active_condition
	if not active_condition.empty() and not is_condition_true(state_connection.to.active_condition):
		return false

	for condition in state_connection.chain_conditions:
		if not is_condition_true(condition):
			return false

	return true

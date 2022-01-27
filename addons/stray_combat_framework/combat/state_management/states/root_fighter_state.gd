extends "fighter_state.gd"


var condition_dict: Dictionary

var _global_connections: Array


func add_global_chain(fighter_state: Reference, input_data: InputData, chain_conditions: PoolStringArray = [], active_condition: String = "", transition_animation: String = "") -> void:
	var state_connection := StateConnection.new()
	state_connection.input_data = input_data
	state_connection.transition_animation = transition_animation
	state_connection.chain_conditions = chain_conditions
	state_connection.to = fighter_state
	fighter_state.root = self

	for connection in _global_connections:
		if connection.is_identical_to(state_connection):
			push_warning("Chain with identical chain conditions, and input data already exists")
			return

	_global_connections.append(state_connection)


func remove_global_chain() -> void:
	#TODO:
	# Chain with specific fighter_state, input_data, and chain_conditions
	pass


func get_global_connections() -> Array:
	return _global_connections


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

	
func get_next_global_state(detected_input: DetectedInput) -> Reference:
	for connection in get_global_connections():
		if _is_matching_input(detected_input, connection.input_data) and _is_all_conditions_met(connection):
			if _connected_global_tags.has(connection.to.global_tag):
				return connection.to
	return null

	
func _is_all_conditions_met(state_connection: StateConnection) -> bool:
	var active_condition: String = state_connection.to.active_condition
	if not active_condition.empty() and not is_condition_true(state_connection.to.active_condition):
		return false

	for condition in state_connection.chain_conditions:
		if not is_condition_true(condition):
			return false

	return true

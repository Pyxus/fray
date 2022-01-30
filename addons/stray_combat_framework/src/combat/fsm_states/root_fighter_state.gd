extends "fighter_state.gd"


var condition_dict: Dictionary

var _global_chains: Array
var _associated_states: Array


func _init(situation: Reference, animation: String, active_condition: String = "").(animation, active_condition) -> void:
	_situation_ref = weakref(situation)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_associated_states.clear()


func add_global_chain(global_tag: String, fighter_state: Reference, input_data: InputData, chain_conditions: PoolStringArray = [], transition_animation: String = "") -> void:
	var state_connection := StateConnection.new()
	state_connection.input_data = input_data
	state_connection.transition_animation = transition_animation
	state_connection.chain_conditions = chain_conditions
	state_connection.to = fighter_state
	fighter_state.global_tag = global_tag
	fighter_state._situation_ref = _situation_ref

	for connection in _global_chains:
		if connection.is_identical_to(state_connection):
			push_warning("Chain with identical chain conditions, and input data already exists")
			return

	_global_chains.append(state_connection)
	_associate_state_with_root(fighter_state)


func remove_global_chain(fighter_state: Reference, input_data: InputData, chain_conditions: PoolStringArray = []) -> void:
	for connection in _global_chains:
		if connection.has_identical_details(fighter_state, input_data, chain_conditions):
			_chain_connections.erase(connection)
			_unassociate_state_with_root(connection.to)
			connection.to._situation = null
			break
	pass


func has_global_chain_to(fighter_state: Reference) -> bool:
	for connection in _global_chains:
		if connection.to == fighter_state:
			return true

	return false


func get_global_chains() -> Array:
	return _global_chains

	
func is_condition_true(condition: String) -> bool:
	if condition_dict.has(condition):
		return condition_dict[condition]
	
	return false

	
func get_next_global_state(detected_input: DetectedInput) -> Reference:
	for connection in get_global_chains():
		if _is_matching_input(detected_input, connection.input_data) and _is_all_conditions_met(connection):
			if _global_chain_tags.has(connection.to.global_tag):
				return connection.to
	return null


func _associate_state_with_root(state: Reference) -> void:
	if not _associated_states.has(state):
		_associated_states.append(state)


func _unassociate_state_with_root(state: Reference) -> void:
	if _associated_states.has(state):
		_associated_states.erase(state)
			
			
func _is_all_conditions_met(state_connection: StateConnection) -> bool:
	if state_connection.to == null:
		return false
		
	var active_condition: String = state_connection.to.active_condition
	if not active_condition.empty() and not is_condition_true(state_connection.to.active_condition):
		return false

	for condition in state_connection.chain_conditions:
		if not is_condition_true(condition):
			return false

	return true

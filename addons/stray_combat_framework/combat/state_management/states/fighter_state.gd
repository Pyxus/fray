extends Reference

const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_sequence.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_virtual_input.gd")

const StateConnection = preload("state_connection.gd")
const InputData = preload("input_data/input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")

var animation: String
var active_condition: String
var root: Reference setget set_root

var _chain_connections: Array 
var _extender_connections: Array
var _extending_state: Reference


func set_root(new_root: Reference) -> void:
	root = new_root
	
	for connection in (_chain_connections + _extender_connections):
		if connection.to.root != root:
			connection.to.root = root


func get_connection(to_state: Reference) -> StateConnection:
	for connection in (_chain_connections + _extender_connections):
		if connection.to == to_state:
			return connection
	return null


func add_extender_state(fighter_state: Reference, transition_animation: String) -> void:
	if fighter_state == self:
		push_error("FighterState can not extend it self.")
		return

	if fighter_state._extender_connections.has(self):
		push_error("Failed to extend state. FighterState '%s' is already an extender of state '%s'. Cylical extensions are not allowed." % [self, fighter_state])
		return

	if fighter_state.active_condition.empty():
		push_warning("Active condition not set for extender state '%s'. This state can ever be reached." % fighter_state)

	var state_connection := StateConnection.new()
	state_connection.transition_animation = transition_animation

	fighter_state._extending_state = self
	_extender_connections.append(state_connection)


func chain(fighter_state: Reference, input: InputData, chain_conditions: PoolStringArray = [], active_condition: String = "", transition_animation: String = "") -> void:
	if has_state_chained(fighter_state):
		push_warning("FighterState '%s' has already been chained" % fighter_state)
		return
	
	var state_connection := StateConnection.new()
	state_connection.input = input
	state_connection.transition_animation = transition_animation
	state_connection.chain_conditions = chain_conditions
	state_connection.to = fighter_state

	for connection in _chain_connections:
		if connection.is_identical_to():
			push_warning("FighterState with identical chain_conditions and input data on connection is already chained")
			return

	_chain_connections.append(fighter_state)
	

func unchain(fighter_state: Reference) -> void:
	for connection in _chain_connections:
		if connection.to == fighter_state:
			_chain_connections.erase(connection)
			connection.to.root = null
			break


func has_state_chained(fighter_state: Reference) -> bool:
	for connection in _chain_connections:
		if connection.to == fighter_state:
			return true
	return false


func is_extended_by(fighter_state: Reference) -> bool:
	for connection in _extender_connections:
		if connection.to == fighter_state:
			return true
	return false


func has_connection_to(fighter_state: Reference) -> bool:
	return is_extended_by(fighter_state) or has_state_chained(fighter_state)

	
func is_extending(fighter_state: Reference) -> bool:
	return fighter_state == _extending_state

	
func get_next_state(detected_input: DetectedInput) -> Reference:
	for connection in _chain_connections:
		if _is_matching_input(detected_input, connection.input_data) and _is_all_conditions_met(connection):
			return connection.to

	if _extending_state != null:
		return _extending_state.get_next_state(detected_input)
	
	return null


func _is_all_conditions_met(state_connection: StateConnection) -> bool:
	if root == null:
		push_error("Failed to check conditions, state root is not set. State connections may not trace up to any root.")
		return false
	
	if not root.is_condition_true(state_connection.to.active_condition):
		return false

	for condition in state_connection.chain_conditions:
		if not root.is_condition_true(condition):
			return false

	return true


func _is_matching_input(detected_input: DetectedInput, input_data: InputData) -> bool:
	if detected_input is DetectedVirtualInput and input_data is VirtualInputData:
		return detected_input.input_id == input_data.input_id
	elif detected_input is DetectedSequence and input_data is SequenceInputData:
		return detected_input.sequence_name == input_data.sequence_name
	
	return false


func _is_match_vir(input_id: int, is_pressed: bool, input_data: InputData) -> bool:
	return input_data is VirtualInputData and input_id == input_data.input_id and is_pressed != input_data.is_activated_on_release


func _is_match_seq(sequence_name: String, input_data: InputData) -> bool:
	return input_data is SequenceInputData and sequence_name == input_data.sequence_name
extends Reference

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_sequence.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")

const StateConnection = preload("state_connections/state_connection.gd")
const ChainConnection = preload("res://addons/stray_combat_framework/src/combat/fsm_states/state_connections/chain_connection.gd")
const ExtensionConnection = preload("res://addons/stray_combat_framework/src/combat/fsm_states/state_connections/extension_connection.gd")
const InputData = preload("state_connections/input_data/input_data.gd")
const SequenceInputData = preload("state_connections/input_data/sequence_input_data.gd")
const VirtualInputData = preload("state_connections/input_data/virtual_input_data.gd")
var FighterState = load("res://addons/stray_combat_framework/src/combat/fsm_states/fighter_state.gd")

var animation: String
var active_condition: String
var global_tag: String

var _global_chain_tags: Array
var _chain_connections: Array 
var _extender_connections: Array
var _extended_state: Reference
var _situation_ref: WeakRef setget _set_situation_ref


func _init(animation: String, active_condition: String = "") -> void:
	self.animation = animation
	self.active_condition = active_condition

# TODO: Test method
func chain(fighter_state: Reference, input_data: InputData, chain_conditions: PoolStringArray = []) -> void:
	assert(fighter_state is FighterState, "The passed argument needs to be of type FighterState")
	
	if has_state_chained(fighter_state):
		push_warning("FighterState '%s' has already been chained" % fighter_state)
		return
	
	var chain_connection := ChainConnection.new()
	chain_connection.input_data = input_data
	chain_connection.chain_conditions = chain_conditions
	chain_connection.to = fighter_state
	fighter_state._situation_ref = _situation_ref

	for chain in _chain_connections:
		if chain.is_identical_to(chain_connection):
			push_warning("Chain with identical chain conditions, and input data already exists.")
			return

	_chain_connections.append(chain_connection)
	_associate_state_with_root(fighter_state)
	
# TODO: Test method
func unchain(fighter_state: Reference, input_data: InputData, chain_conditions: PoolStringArray = []) -> void:
	for connection in _chain_connections:
		if connection.has_identical_details(fighter_state, input_data, chain_conditions):
			_chain_connections.erase(connection)
			connection.to._situation_ref = null
			_unassociate_state_with_root(fighter_state)
			break

# TODO: Test method
func unchain_all_with_state(fighter_state: Reference) -> void:
	for connection in _chain_connections:
		if connection.to == fighter_state:
			_chain_connections.erase(connection)
			_unassociate_state_with_root(fighter_state)
			connection.to._situation = null

# TODO: Test method
func chain_global(tag: String) -> void:
	if not _global_chain_tags.has(tag):
		_global_chain_tags.append(tag)

# TODO: Test method
func unchain_global(tag: String) -> void:
	if _global_chain_tags.has(tag):
		_global_chain_tags.erase(tag)

# TODO: Test method
func connect_extender(fighter_state: Reference, transition_animation_to: String = "", transition_animation_from = "") -> void:
	assert(fighter_state is FighterState, "The passed argument needs to be of type FighterState")
	
	if fighter_state == self:
		push_error("FighterState can not extend it self.")
		return

	if fighter_state._extender_connections.has(self):
		push_error("Failed to extend state. FighterState '%s' is already an extender of state '%s'. Cylical extensions are not allowed." % [self, fighter_state])
		return

	if fighter_state.active_condition.empty():
		push_warning("Active condition not set for extender state '%s'. This state can never be reached as an extender." % fighter_state)

	var extension_connection := ExtensionConnection.new()
	extension_connection.transition_animation_to = transition_animation_to
	extension_connection.transition_animation_from = transition_animation_from
	extension_connection.to = fighter_state

	fighter_state._extended_state = self
	fighter_state._situation_ref = _situation_ref
	_extender_connections.append(extension_connection)
	_associate_state_with_root(fighter_state)

# TODO: Test method
func disconnect_extender(fighter_state: Reference) -> void:
	for connection in _extender_connections:
		if connection.to == fighter_state:
			fighter_state._extended_state = null
			_extender_connections.erase(connection)
			_unassociate_state_with_root(fighter_state)
			break


func get_next_connection(detected_input: DetectedInput) -> Reference:
	var next_connection = get_next_chain(detected_input)
	
	if next_connection != null:
		return next_connection
		
	next_connection = get_next_global_chain(detected_input)
	if next_connection != null:
		return next_connection
	
	next_connection = get_next_extension()
	if next_connection != null:
		return next_connection
	
	return null


# TODO: Test method
func get_next_chain(detected_input: DetectedInput) -> Reference:
	if _extended_state != null:
		var next_chain = _extended_state.get_next_chain(detected_input)
		if next_chain != null and next_chain.to != self:
			return next_chain

	for connection in _chain_connections:
		if _is_matching_input(detected_input, connection.input_data) and _is_all_conditions_met(connection):
			return connection
			
	return null

# TODO: Test method
func get_next_global_chain(detected_input: DetectedInput) -> Reference:
	var situation: Reference = get_situation()
	if situation == null:
		push_error("Failed to check global chains. State may not exist within a situation")
		return null
		
	if _extended_state != null:
		var next_chain = _extended_state.get_next_global_chain(detected_input)
		if next_chain != null and next_chain.to != self:
			return next_chain
	
	var root = situation.get_root()
	for connection in root.get_global_chains():
		if _is_matching_input(detected_input, connection.input_data) and _is_all_conditions_met(connection):
			if _global_chain_tags.has(connection.to.global_tag):
				return connection
	return null

# TODO: Test method
func get_next_extension() -> Reference:
	for connection in _extender_connections:
		if  _is_all_conditions_met(connection):
			return connection
			
	return null

# TODO: Test method
func get_connection_to(to_state: Reference) -> StateConnection:
	if _extended_state != null:
		return _extended_state.get_connection(to_state)
		
	var situation: Reference = get_situation()
	if situation == null:
		push_error("Failed to check global chains. State may not exist within a situation")
		return null
		
	var root = situation.get_root()
	for connection in (_chain_connections + _extender_connections + root.get_global_chains()):
		if connection.to == to_state:
			return connection
	return null

# TODO: Test method
func has_connection_to(fighter_state: Reference) -> bool:
	if _extended_state != null:
		return _extended_state.has_connection_to(fighter_state)
	var situation: Reference = get_situation()
	
	if situation == null:
		push_error("Failed to check global chains. State may not exist within a situation")
		return false
		
	var root = situation.get_root()
	var has_global_connection := false
	if root != null:
		has_global_connection = root.has_global_chain_to(fighter_state)

	return is_extended_by(fighter_state) or has_state_chained(fighter_state) or has_global_connection

# TODO: Test method
func has_state_chained(fighter_state: Reference) -> bool:
	for connection in _chain_connections:
		if connection.to == fighter_state:
			return true
	return false

# TODO: Test method
func is_extended_by(fighter_state: Reference) -> bool:
	for connection in _extender_connections:
		if connection.to == fighter_state:
			return true
	return false

# TODO: Test method
func is_extending(fighter_state: Reference) -> bool:
	return fighter_state == _extended_state


func is_extender() -> bool:
	return _extended_state != null

# TODO: Test method
func get_extended_state() -> Reference:
	return _extended_state

# TODO: Test method
func get_situation() -> Reference:
	return  _situation_ref.get_ref() if _situation_ref != null else null

# TODO: Test method
func _associate_state_with_root(state: Reference) -> void:
	var situation := get_situation()
	if situation != null:
		var root: Reference = situation.get_root()
		root._associate_state_with_root(state)
		
		for connection in (_chain_connections + _extender_connections):
			root._associate_state_with_root(connection.to)
	
# TODO: Test method
func _unassociate_state_with_root(state: Reference) -> void:
	var situation := get_situation()
	if situation != null:
		var root: Reference = situation.get_root()
		root._unassociate_state_with_root(state)
		
		for connection in (_chain_connections + _extender_connections):
			root._unassociate_state_with_root(connection.to)

# TODO: Test method
func _set_situation_ref(value: WeakRef) -> void:
	_situation_ref = value
	for connection in (_chain_connections + _extender_connections):
		if connection.to != null and connection.to._situation_ref != value:
			connection.to._situation_ref = value

# TODO: Test method
func _is_all_conditions_met(state_connection: StateConnection) -> bool:
	var situation: Reference = get_situation()
	if situation == null:
		push_error("Failed to check conditions, state may not exist within a situation.")
		return false
		
	var root = situation.get_root()
	if root == null:
		push_error("Unexpected error! Failed to check conditions, situation root does not exist.")
		return false

	if state_connection is ChainConnection:
		for condition in state_connection.chain_conditions:
			if not root.is_condition_true(condition):
				return false
		return true
	elif state_connection is ExtensionConnection:
		var active_condition: String = state_connection.to.active_condition
		if not active_condition.empty() and not root.is_condition_true(state_connection.to.active_condition):
			return false
		return true
		
	return false

# TODO: Test method
func _is_matching_input(detected_input: DetectedInput, input_data: InputData) -> bool:
	if detected_input is DetectedVirtualInput and input_data is VirtualInputData:
		return detected_input.input_id == input_data.input_id and detected_input.is_pressed != input_data.is_activated_on_release
	elif detected_input is DetectedSequence and input_data is SequenceInputData:
		return detected_input.sequence_name == input_data.sequence_name
	
	return false

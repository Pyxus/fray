extends Resource


const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_sequence.gd")

const InputData = preload("transitions/input_data/input_data.gd")
const SequenceInputData = preload("transitions/input_data/input_data.gd")
const VirtualInputData = preload("transitions/input_data/virtual_input_data.gd")
const StringCondition = preload("conditions/string_condition.gd")

var Chain = load("res://addons/stray_combat_framework/src/combat/state_management/transitions/chain.gd")
var Situation = load("res://addons/stray_combat_framework/src/combat/state_management/situation.gd")
var CombatState = load("res://addons/stray_combat_framework/src/combat/state_management/combat_state.gd")

var tag: String
var situation: Resource setget set_situation, get_situation

var _chains: Array
var _global_chain_tags: Array
var _situation := WeakRef.new()


func chain_to(to_state: Resource, input_data: InputData, chain_conditions: Array = [], min_input_delay: float = 0) -> void:
	assert(to_state is CombatState, "The passed argument is not of type CombatState")
	var chain = Chain.new()
	chain.to = to_state
	chain.input_data = input_data
	chain.chain_conditions = chain_conditions
	chain.min_input_delay = min_input_delay

	_chains.append(chain)

	if self.situation != null:
		self.situation.associate_state(to_state)


func get_next_chain(condition_dict: Dictionary, detected_input: DetectedInput, time_since_last_input: float) -> Resource:
	for chain in _chains:
		if chain.is_reachable(condition_dict, detected_input, time_since_last_input):
			return chain
	
	for chain in self.situation.get_global_chains():
		if chain.is_reachable(condition_dict, detected_input, time_since_last_input):
			if chain.to.tag in _global_chain_tags:
				return chain
			elif self.situation.is_global_chain_rule(tag, chain.to.tag):
				return chain
			
	return null


func set_situation(value: Resource) -> void:
	assert(value is Situation, "The passed argument is not of type Situation.")
	_situation = weakref(value)

	for chain in _chains:
		if chain.to.situation != value:
			chain.to.situation = value


func get_situation() -> Resource:
	return _situation.get_ref()


func get_chained_states(states: Array = []) -> Array:
	for chain in _chains:
		if not states.has(chain.to):
			states.append(chain.to)
			for s in chain.to.get_chained_states((states)):
				states.append(s)
	
	return states

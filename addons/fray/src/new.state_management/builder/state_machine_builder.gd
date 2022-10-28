extends Reference
## Base transition builder

const TransitionConfigBuilder = preload("transition_config_builder.gd")
const State = preload("../state/state.gd")
const StateCommpound = preload("../state/state_compound.gd")
const Condition = preload("../transition/condition/condition.gd")

## If true then conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

## Type: Condition[]
var _condition_cache: Array

## Dictionary<String, State>
## Hint: <state name, >
var _state_by_name: Dictionary

## Type: TransitionData[]
var _transition_data: Array 

## Constructs a state machine, represented by a StateCommpound, using the current build configuration.
## After building the builder is reset and can be used again. 
## Keep in mind that the condition cache does not reset autoatmically.
##
## `start_state` sets the initial state of the state machine.
## The initial state must have already been added to the builder.
##
## Returns a newly constructed CombatSituation
func build(start_state: String = "") -> StateCommpound:
	var root := StateCommpound.new()

	for state_name in _state_by_name:
		root.add_state(state_name, _state_by_name[state_name])
	
	for td in _transition_data:
		root.add_transition(td.from, td.to, td.builder.build())
	
	if not start_state.empty():
		if root.has_state(start_state):
			root.start_state = start_state
		else:
			push_warning("Failed to set start state. State machine does not contain state '%s'" % start_state)
	
	_state_by_name.clear()
	_transition_data.clear()
	return root

## Adds a new state to the state machine if it doesn't already exist.
##
## Note: 
##		States are added automatically when making transitions.
## 		So unless you need to provide a specific state object calling this
## 		method is unncessary.
##
## Returns a reference to this StateMachineBuilder
func add_state(name: String, state := State.new()) -> Reference:
	_state_by_name[name] = state
	return self

## Creates a new transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this StateMachineBuilder
func transition(from: String, to: String, config_builder := TransitionConfigBuilder.new()) -> Reference:
	if enable_condition_caching:
		config_builder.set_confition_caching_func(funcref(self, "_cache_condition"))

	add_state(from)
	add_state(to)
	_transition_data.append(TransitionData.new(from, to, config_builder))
	return self

## Convinience method which returns a new TransitionConfigBuilder
func config() -> TransitionConfigBuilder:
	return TransitionConfigBuilder.new()

func _cache_condition(condition: Condition) -> Condition:
	for cached_condition in _condition_cache:
		if cached_condition.equals(condition):
			return cached_condition

	_condition_cache.append(condition)
	return condition


class TransitionData:
	extends Reference
	
	const TransitionConfigBuilder = preload("transition_config_builder.gd")

	func _init(from_state: String, to_state: String, tc: TransitionConfigBuilder) -> void:
		from = from_state
		to = to_state
		builder = tc

	var from: String
	var to: String
	var builder: TransitionConfigBuilder
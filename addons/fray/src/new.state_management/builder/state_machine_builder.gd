extends Reference
## Base transition builder

const State = preload("../state/state.gd")
const StateCommpound = preload("../state/state_compound.gd")
const Condition = preload("../state/transition/condition.gd")
const Transition = preload("../state/transition/transition.gd")

## If true then conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

## Type: Condition[]
var _condition_cache: Array

## Type: Dictionary<String, State>
## Hint: <state name, >
var _state_by_name: Dictionary

## Type: Dictionary<String, Transition[]>
## Hint: <state name>
var _adjacency_by_state: Dictionary 

## Constructs a state machine, represented by a StateCommpound, using the current build configuration.
## After building the builder is reset and can be used again. 
## Keep in mind that the condition cache does not reset autoatmically.
##
## `start_state` sets the initial state of the state machine.
## The initial state must have already been added to the builder.
##
## Returns a newly constructed CombatSituation
func build(start_state: String = ""):
	var root := StateCommpound.new()
	_configure_state_machine(start_state, root)
	clear()
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

	if not _adjacency_by_state.has(name):
		_adjacency_by_state[name] = []

	return self

## Creates a new transition from one state to another.
## States used will automatically be added.
##
## Returns a reference to this StateMachineBuilder
func transition(from: String, to: String, config: Dictionary = {}) -> Reference:
	add_state(from)
	add_state(to)

	var transition := Transition.new()
	_configure_transition(to, transition, config)
	_adjacency_by_state[from].append(transition)
	return self

## Helper method to create new condition
func new_condition(name: String, invert: bool = false) -> Condition:
	return _cache_condition(Condition.new(name, invert))

## Clears the condition cache
func clear_cache() -> void:
	_condition_cache.clear()

## Clears builder state not including cache
func clear() -> void:
	_state_by_name.clear()
	_adjacency_by_state.clear()


func _configure_transition(to: String, transition: Transition, config: Dictionary) -> void:
	add_state(to)

	transition.to = to
	transition.advance_conditions = _cache_conditions(config.get("advance_conditions", []))
	transition.prereqs = _cache_conditions(config.get("prereqs", []))
	transition.auto_advance = config.get("auto_advance", false)
	transition.priority = config.get("priority", 0)
	transition.switch_mode = config.get("switch_mode", Transition.SwitchMode.IMMEDIATE)


func _configure_state_machine(start_state: String, root: StateCommpound) -> void:
	for state_name in _state_by_name:
		root.add_state(state_name, _state_by_name[state_name])

	for state in _adjacency_by_state:
		for transition in _adjacency_by_state[state]:
			root.add_transition(state, transition)
	
	if not start_state.empty():
		if root.has_state(start_state):
			root.start_state = start_state
		else:
			push_warning("Failed to set start state. State machine does not contain state '%s'" % start_state)


func _cache_condition(condition: Condition) -> Condition:
	if enable_condition_caching:
		for cached_condition in _condition_cache:
			if cached_condition.equals(condition):
				return cached_condition

		_condition_cache.append(condition)
	return condition


func _cache_conditions(conditions: Array) -> Array:
	var c: Array
	for condition in conditions:
		c.append(_cache_condition(condition))
	return c
extends RefCounted
## State machine builder
##
## @desc:
##		The state machine builder can be used to create state machines programatically.
##		The builder supports using optional method chaining for the construction.
##		
##		Example:
##		var sm = builder\
##			.transition("a", "b")\
##			.transition("b", "c")\
##			.build()
##
##		Note: '\' is necessary for GDScript to read the next line when multi-line method chaning

const StateNode = preload("../node/state_node.gd")
const StateNodeStateMachine = preload("../node/state_node_state_machine.gd")
const Condition = preload("../node/transition/condition.gd")
const StateMachineTransition = preload("../node/transition/state_machine_transition.gd")

## If true then conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

## Type: Condition[]
var _condition_cache: Array

## Type: Dictionary<String, StateNode>
## Hint: <state name, >
var _state_by_name: Dictionary

## Type: Transition[]
var _transitions: Array

var _start_state: String
var _end_state: String

## Constructs a state machine, represented by a StateCommpound, using the current build configuration.
## After building the builder is reset and can be used again. 
## Keep in mind that the condition cache does not reset autoatmically.
##
## Returns a newly constructed CombatSituation
func build() -> StateNodeStateMachine:
	return _build_impl()

## Adds a new state to the state machine.
##
## Note: 
##		States are added automatically when making transitions.
## 		So unless you need to provide a specific state object,
##		calling this method is unncessary.
##
## Returns a reference to this builder
func add_state(name: String, state := StateNode.new()) -> RefCounted:
	if name.is_empty():
		push_error("State name can not be empty")
	else:
		_state_by_name[name] = state
	return self

## Creates a new transition from one state to another.
## States used will automatically be added.
##
## `config` is a dictionary used to configure transition options:
##		`advance_conditions: Condition[]`
##		`prereqs: Condition[]`
##		`auto_advance: bool`
##		`priority: int`
##		`switch_mode: int`
##
## Returns a reference to this builder
func transition(from: String, to: String, config: Dictionary = {}) -> RefCounted:
	var tr := _create_transition(from, to, StateMachineTransition.new())
	_configure_transition(tr.transition, config)
	return self

## Sets the starting state.
## State used will automatically be added.
##
## Returns a reference to this builder
func start_at(state: String) -> RefCounted:
	_add_state_once(state)
	_start_state = state
	return self

## Sets the end state.
## State used will automatically be added.
##
## Returns a reference to this builder
func end_at(state: String) -> RefCounted:
	_add_state_once(state)
	_end_state = state
	return self

## Clears the condition cache
func clear_cache() -> void:
	_condition_cache.clear()

## Clears builder state not including cache
func clear() -> void:
	_clear_impl()


func _create_transition(from: String, to: String, transition: StateMachineTransition) -> Transition:
	var tr := Transition.new()
	tr.from = from
	tr.to = to
	tr.transition = transition
	
	_add_state_once(from)
	_add_state_once(to)
	_transitions.append(tr)
	return tr


func _add_state_once(state: String) -> void:
	if not _state_by_name.has(state):
		add_state(state)


func _configure_transition(transition: StateMachineTransition, config: Dictionary) -> void:
	transition.advance_conditions = _cache_conditions(config.get("advance_conditions", []))
	transition.prereqs = _cache_conditions(config.get("prereqs", []))
	transition.auto_advance = config.get("auto_advance", false)
	transition.priority = config.get("priority", 0)
	transition.switch_mode = config.get("switch_mode", StateMachineTransition.SwitchMode.IMMEDIATE)


func _configure_state_machine(root: StateNodeStateMachine) -> void:
	for state_name in _state_by_name:
		root.add_node(state_name, _state_by_name[state_name])
	
	for tr in _transitions:
		root.add_transition(tr.from, tr.to, tr.transition)

	if not _start_state.is_empty():
		root.start_node = _start_state
	
	if not _end_state.is_empty():
		root.end_node = _end_state


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


func _build_impl() -> StateNodeStateMachine:
	var root := StateNodeStateMachine.new()
	_configure_state_machine(root)
	clear()
	return root


func _clear_impl() -> void:
	_state_by_name.clear()
	_transitions.clear()


class Transition:
	extends RefCounted
	
	const StateMachineTransition = preload("../node/transition/state_machine_transition.gd")

	var from: String
	var to: String
	var transition: StateMachineTransition

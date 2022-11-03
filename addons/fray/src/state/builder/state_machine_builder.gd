extends Reference
## Base transition builder

const GraphNode = preload("../graph_node/graph_node.gd")
const GraphNodeStateMachine = preload("../graph_node/graph_node_state_machine.gd")
const Condition = preload("../graph_node/transition/condition.gd")
const StateMachineTransition = preload("../graph_node/transition/state_machine_transition.gd")

## If true then conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

## Type: Condition[]
var _condition_cache: Array

## Type: Dictionary<String, GraphNode>
## Hint: <state name, >
var _state_by_name: Dictionary

## Type: Transition[]
var _transitions: Array

## Constructs a state machine, represented by a StateCommpound, using the current build configuration.
## After building the builder is reset and can be used again. 
## Keep in mind that the condition cache does not reset autoatmically.
##
## `start_state` sets the initial state of the state machine.
## The initial state must have already been added to the builder.
##
## Returns a newly constructed CombatSituation
func build(start_state: String = "") -> GraphNodeStateMachine:
	return _build_impl(start_state)

## Adds a new state to the state machine if it doesn't already exist.
##
## Note: 
##		States are added automatically when making transitions.
## 		So unless you need to provide a specific state object,
##		calling this method is unncessary.
##
## Returns a reference to this builder
func add_state(name: String, state := GraphNode.new()) -> Reference:
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
func transition(from: String, to: String, config: Dictionary = {}) -> Reference:
	var tr := _create_transition(from, to, StateMachineTransition.new())
	_configure_transition(tr.transition, config)
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

	add_state(from)
	add_state(to)
	_transitions.append(tr)
	return tr

func _configure_transition(transition: StateMachineTransition, config: Dictionary) -> void:
	transition.advance_conditions = _cache_conditions(config.get("advance_conditions", []))
	transition.prereqs = _cache_conditions(config.get("prereqs", []))
	transition.auto_advance = config.get("auto_advance", false)
	transition.priority = config.get("priority", 0)
	transition.switch_mode = config.get("switch_mode", StateMachineTransition.SwitchMode.IMMEDIATE)


func _configure_state_machine(start_state: String, root: GraphNodeStateMachine) -> void:
	for state_name in _state_by_name:
		root.add_node(state_name, _state_by_name[state_name])
	
	for tr in _transitions:
		root.add_transition(tr.from, tr.to, tr.transition)

	if not start_state.empty():
		if root.has_node(start_state):
			root.start_node = start_state
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


func _build_impl(start_state: String) -> GraphNodeStateMachine:
	var root := GraphNodeStateMachine.new()
	_configure_state_machine(start_state, root)
	clear()
	return root


func _clear_impl() -> void:
	_state_by_name.clear()
	_transitions.clear()


class Transition:
	extends Reference
	
	const StateMachineTransition = preload("../graph_node/transition/state_machine_transition.gd")

	var from: String
	var to: String
	var transition: StateMachineTransition

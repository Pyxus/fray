class_name FrayStateMachineBuilder
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


## If true then conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

# Type: Dictionary<StringName, StateNode>
# Hint: <state name, >
var _state_by_name: Dictionary

var _condition_cache: Array[FrayCondition]
var _transitions: Array[Transition]
var _start_state: StringName
var _end_state: StringName

## Returns a newly constructed state machine node.
## [br]
## Constructs a state machine using the current build configuration.
## After building the builder is reset and can be used again. 
## Keep in mind that the condition cache does not reset autoatmically.
func build() -> FrayStateNodeStateMachine:
	return _build_impl()

## Adds a new state to the state machine.
## [br]
## Returns a reference to this builder
## [br][br]
## [b]Note[/b]: 
## States are added automatically when making transitions.
## So unless you need to provide a specific state object,
## calling this method is unncessary.
func add_state(name: StringName, state := FrayStateNode.new()) -> FrayStateMachineBuilder:
	if name.is_empty():
		push_error("State name can not be empty")
	else:
		_state_by_name[name] = state
	return self

## Creates a new transition from one state to another.
## States used will automatically be added.
## [br]
## Returns a reference to this builder
## [br][br]
## [kbd]config[/kbd] is an optional dictionary used to configure [FrayStateMachineTransition] properties.
func transition(from: StringName, to: StringName, config: Dictionary = {}) -> FrayStateMachineBuilder:
	var tr := _create_transition(from, to, FrayStateMachineTransition.new())
	_configure_transition(tr.transition, config)
	return self

## Sets the starting state.
## State used will automatically be added.
##
## Returns a reference to this builder
func start_at(state: StringName) -> FrayStateMachineBuilder:
	_add_state_once(state)
	_start_state = state
	return self

## Sets the end state.
## State used will automatically be added.
##
## Returns a reference to this builder
func end_at(state: StringName) -> FrayStateMachineBuilder:
	_add_state_once(state)
	_end_state = state
	return self

## Clears the condition cache
func clear_cache() -> void:
	_condition_cache.clear()

## Clears builder state not including cache
func clear() -> void:
	_clear_impl()


func _create_transition(from: StringName, to: StringName, transition: FrayStateMachineTransition) -> Transition:
	var tr := Transition.new()
	tr.from = from
	tr.to = to
	tr.transition = transition
	
	_add_state_once(from)
	_add_state_once(to)
	_transitions.append(tr)
	return tr


func _add_state_once(state: StringName) -> void:
	if not _state_by_name.has(state):
		add_state(state)


func _configure_transition(transition: FrayStateMachineTransition, config: Dictionary) -> void:
	for property in transition.get_property_list():
		if config.has(property.name):
			var data = config.get(property.name)

			if data is FrayCondition:
				transition[property.name] = _cache_condition(data)
			elif data is Array[FrayCondition]:
				transition[property.name] = _cache_conditions(data)
			else:
				transition[property.name] = data


func _configure_state_machine(root: FrayStateNodeStateMachine) -> void:
	for state_name in _state_by_name:
		root.add_node(state_name, _state_by_name[state_name])
	
	for tr in _transitions:
		root.add_transition(tr.from, tr.to, tr.transition)

	if not _start_state.is_empty():
		root.start_node = _start_state
	
	if not _end_state.is_empty():
		root.end_node = _end_state


func _cache_condition(condition: FrayCondition) -> FrayCondition:
	if enable_condition_caching:
		for cached_condition in _condition_cache:
			if cached_condition.equals(condition):
				return cached_condition

		_condition_cache.append(condition)
	return condition


func _cache_conditions(conditions: Array[FrayCondition]) -> Array[FrayCondition]:
	var c: Array[FrayCondition]
	for condition in conditions:
		c.append(_cache_condition(condition))
	return c


func _build_impl() -> FrayStateNodeStateMachine:
	var root := FrayStateNodeStateMachine.new()
	_configure_state_machine(root)
	clear()
	return root


func _clear_impl() -> void:
	_state_by_name.clear()
	_transitions.clear()


class Transition:
	extends RefCounted
	
	const StateMachineTransition = preload("../node/transition/state_machine_transition.gd")

	var from: StringName
	var to: StringName
	var transition: StateMachineTransition

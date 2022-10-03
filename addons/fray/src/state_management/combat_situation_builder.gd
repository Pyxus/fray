extends Reference

const CombatSituation = preload("combat_situation.gd")
const CombatState = preload("combat_state.gd")
const InputCondition = preload("transitions/conditions/input_condition.gd")
const InputTransition = preload("transitions/input_transition.gd")
const InputButtonCondition = preload("transitions/conditions/input_button_condition.gd")
const InputSequenceCondition = preload("transitions/conditions/input_sequence_condition.gd")


## If true then input conditions will be cached to prevent identical conditions from being instantiated.
var enable_condition_caching: bool = true

## Type: InputButtonCondition[]
var _button_condition_cache: Array

## Type: Dictionary<String, InputSequenceCondition>
var _sequence_condition_cache: Dictionary

## Type: Dictionary<String, CombatState>
var _state_by_name: Dictionary

## Type: Dictionary<[String, String], TransitionBuilder>
var _builder_by_state_tuple: Dictionary 

## Type: Dictionary<String, TransitionBuilder)
var _global_builder_by_state: Dictionary 

## Type: Dictionary<String, String[]>
var _transition_rules: Dictionary

var _func_new_button: FuncRef
var _func_new_sequence: FuncRef

func _init() -> void:
	_func_new_button = funcref(self, "_new_button")
	_func_new_sequence = funcref(self, "_new_sequence")

## Constructs a CombatSituation using current build configuration.
## After building the CombatSituationBuilder is reset and can be used to build
## Another CombatSiutation.
##
## initial_state sets the initial state of the CombatSituation.
## The initial state must have already been added to the builder.
##
## Returns a newly constructed CombatSituation
func build(initial_state: String) -> CombatSituation:
	var cs := CombatSituation.new()
	for state_name in _state_by_name:
		cs.add_state(state_name, _state_by_name[state_name])

	for from in _transition_rules:
		for to in _transition_rules[from]:
			cs.add_global_transition_rule(from, to)

	for state_tuple in _builder_by_state_tuple:
		var builder: TransitionBuilder = _builder_by_state_tuple[state_tuple]
		var transition := _get_transition(builder)
		var from: String = state_tuple[0]
		var to: String = state_tuple[1]

		if not is_instance_valid(transition):
			push_error(
				"Failed to add transition. "+
				"No input defined for transition from state '%s' to state '%s'. " % [from, to]+
				"Use either 'on_button' or 'on_sequence' method to define input"
			)
			continue

		cs.add_transition(from, to, transition)

	for state in _global_builder_by_state:
		var builder: TransitionBuilder = _global_builder_by_state[state]
		var transition := _get_transition(builder)
		if not is_instance_valid(transition):
			push_error(
				"Failed to add transition. " +
				"No input defined for transition to global state '%s'. " % state +
				"Use either 'on_button' or 'on_sequence' method to define input"
			)
			continue
		cs.add_global_input_transition(state, transition.input_condition, transition.prerequisites, transition.min_input_delay)

	cs.initialize(initial_state)

	_state_by_name.clear()
	_builder_by_state_tuple.clear()
	_global_builder_by_state.clear()
	_transition_rules.clear()
	return cs

## Adds a new state to the situation.
##
## Note: States are added automatically when making transitions.
func add_state(name: String, state := CombatState.new()) -> Reference:
	if not _state_by_name.has(name):
		_state_by_name[name] = state
	return self

## Sets the state instance of a given state.
## Note: State must already have been added in order to be set.
func set_state(state_name: String, state: CombatState) -> Reference:
	if _state_by_name.has(state_name):
		_state_by_name[state_name] = state
	else:
		push_warning("Failed to set state. State with name '%s' does not exist." % state_name)
	return self

## Creates a new transition from one state to another.
## If states does not already exist they will be created.
##
## Returns a TransitionBuilder which can be used to further configure transition
func transition(from: String, to: String) -> TransitionBuilder:
	add_state(from)
	add_state(to)
	var tb := TransitionBuilder.new(_func_new_button, _func_new_sequence, weakref(self))
	_builder_by_state_tuple[[from, to]] = tb
	return tb

## Creates a new global transition to specified state.
## If the states does not already exist it will be created.
##
## Returns a TransitionBuilder which can be used to further configure transition.
func global_transition(to: String) -> TransitionBuilder:
	add_state(to)
	var tb = TransitionBuilder.new(_func_new_button, _func_new_sequence, weakref(self))
	_global_builder_by_state[to] = tb
	return tb

## Adds a new transition rule to be used by global transitions.
##
## Returns a reference to this builder
func add_rule(from_tag: String, to_tag: String) -> Reference:
	if not _transition_rules.has(from_tag):
		_transition_rules[from_tag] = []
	_transition_rules[from_tag].append(to_tag)
	return self

## Set the tags of a specified state.
## If the states does not already exist it will be created.
##
## Returns a reference to this builder
func set_tags(state: String, tags: PoolStringArray) -> Reference:
	add_state(state)
	_state_by_name[state].tags = tags
	return self

## Appends given tags onto all given states.
## If the states does not already exist it will be created.
##
## Returns a reference to this builder
func tag(states: PoolStringArray, tags: PoolStringArray) -> Reference:
	for state in states:
		add_state(state)

		for tag in tags:
			_state_by_name[state].tags.append(tag)
	return self


func _get_transition(t_builder: TransitionBuilder) -> InputTransition:
	var transition := t_builder.transition
	if not is_instance_valid(transition):
		transition.prerequisites = t_builder.prerequisites
		transition.min_input_delay = t_builder.min_input_delay
	return transition


func _new_button(fray_input: String, is_triggered_on_release: bool = false) -> InputButtonCondition:
	if enable_condition_caching:
		for button in _button_condition_cache:
			if button.input == fray_input and button.is_triggered_on_release == is_triggered_on_release:
				return button

	var new_condition := InputButtonCondition.new(fray_input, is_triggered_on_release)
	_button_condition_cache.append(new_condition)
	return new_condition


func _new_sequence(sequence_name: String) -> InputSequenceCondition:
	if enable_condition_caching and _sequence_condition_cache.has(sequence_name):
		return _sequence_condition_cache[sequence_name]
	
	var new_condition := InputSequenceCondition.new(sequence_name)
	_sequence_condition_cache[sequence_name] = new_condition
	return new_condition


class TransitionBuilder:
	extends Reference
	
	const InputTransition = preload("transitions/input_transition.gd")
	const InputButtonCondition = preload("transitions/conditions/input_button_condition.gd")
	const InputSequenceCondition = preload("transitions/conditions/input_sequence_condition.gd")
	const EvaluatedCondition = preload("transitions/conditions/evaluated_condition.gd")

	var min_input_delay: float = 0
	var prerequisites: Array
	var transition: InputTransition

	var _func_new_button: FuncRef
	var _func_new_sequence: FuncRef
	var _situation_builder: WeakRef


	func _init(func_new_button: FuncRef, func_new_sequence: FuncRef, situation_builder: WeakRef) -> void:
		_func_new_button = func_new_button
		_func_new_sequence = func_new_sequence
		_situation_builder = situation_builder

	## Configures the input that will trigger this transition
	##
	## Returns a reference to the CombatSiutionatBuilder that created this TransitionBuilder
	func on_button(input: String, is_triggered_on_release: bool = false) -> Reference:
		transition = InputTransition.new(_func_new_button.call_func(input, is_triggered_on_release))
		return _situation_builder.get_ref()


	## Configures the sequence that will trigger this transition
	##
	## Returns a reference to the CombatSiutionatBuilder that created this TransitionBuilder
	func on_sequence(sequence_name: String) -> Reference:
		transition = InputTransition.new(_func_new_sequence.call_func(sequence_name))
		return _situation_builder.get_ref()

	## Configures the minimum input delay of this transition.
	##
	## Returns a reference to this TransitionBuilder
	func with_min_input_delay(delay: float) -> Reference:
		min_input_delay = delay
		return self

	## Configures the prerequisites of this transition.
	##
	## prereqs is an array of type EvaluatedCondition
	##
	## Returns a reference to this TransitionBuilder
	func with_prereqs(prereqs: Array) -> Reference:
		prerequisites = prereqs
		return self

	## Configures the prerequisites of this transition using string conditions.
	##
	##
	## Returns a reference to this TransitionBuilder
	func with_prereqs_str(prereqs: PoolStringArray) -> Reference:
		var arr := []
		for prereq in prereqs:
			arr.append(EvaluatedCondition.new(prereq))
		return with_prereqs(arr)

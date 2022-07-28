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


func build(initial_state: String) -> CombatSituation:
	var cs := CombatSituation.new()
	for state_name in _state_by_name:
		cs.add_state(state_name, _state_by_name[state_name])

	for from in _transition_rules:
		for to in _transition_rules[from]:
			cs.add_global_transition_rule(from, to)

	for state_tuple in _builder_by_state_tuple:
		var builder: TransitionBuilder = _builder_by_state_tuple[state_tuple]
		var from: String = state_tuple[0]
		var to: String = state_tuple[1]
		cs.add_transition(from, to, _get_transition(builder))

	for state in _global_builder_by_state:
		var builder: TransitionBuilder = _global_builder_by_state[state]
		var transition := _get_transition(builder) 
		cs.add_global_input_transition(state, transition.input_condition, transition.prerequisites, transition.min_input_delay)

	cs.initialize(initial_state)

	_state_by_name.clear()
	_builder_by_state_tuple.clear()
	_global_builder_by_state.clear()
	_transition_rules.clear()
	return cs


func transition(from: String, to: String) -> TransitionBuilder:
	_add_state(from)
	_add_state(to)
	var tb := TransitionBuilder.new(_func_new_button, _func_new_sequence)
	_builder_by_state_tuple[[from, to]] = tb
	return tb


func global_transition(to: String) -> TransitionBuilder:
	_add_state(to)
	var tb = TransitionBuilder.new(_func_new_button, _func_new_sequence)
	_global_builder_by_state[to] = tb
	return tb


func add_rule(from_tag: String, to_tag: String) -> void:
	if not _transition_rules.has(from_tag):
		_transition_rules[from_tag] = []
	_transition_rules[from_tag].append(to_tag)


func set_tags(state: String, tags: PoolStringArray) -> void:
	_add_state(state)
	_state_by_name[state].tags = tags


func tag(states: PoolStringArray, tags: PoolStringArray) -> void:
	for state in states:
		_add_state(state)

		for tag in tags:
			_state_by_name[state].tags.append(tag)


func _add_state(name: String) -> void:
	if not _state_by_name.has(name):
		_state_by_name[name] = CombatState.new()


func _get_transition(t_builder: TransitionBuilder) -> InputTransition:
	var transition := t_builder.transition
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

	var min_input_delay: float = 0
	var prerequisites: Array
	var transition := InputTransition.new()

	var _func_new_button: FuncRef
	var _func_new_sequence: FuncRef


	func _init(func_new_button: FuncRef, func_new_sequence: FuncRef) -> void:
		_func_new_button = func_new_button
		_func_new_sequence = func_new_sequence


	func on_button(input: String, is_triggered_on_release: bool = false) -> TransitionBuilder:
		transition = InputTransition.new(_func_new_button.call_func(input, is_triggered_on_release))
		return self

	
	func on_sequence(sequence_name: String) -> TransitionBuilder:
		transition = InputTransition.new(_func_new_sequence.call_func(sequence_name))
		return self

	
	func set_min_input_delay(delay: float) -> TransitionBuilder:
		min_input_delay = delay
		return self

	
	func set_prereq(prereqs: Array) -> TransitionBuilder:
		prerequisites = prereqs
		return self
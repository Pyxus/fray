extends Reference

const InputButtonCondition = preload("transitions/conditions/input_button_condition.gd")
const InputSequenceCondition = preload("transitions/conditions/input_sequence_condition.gd")

## If true then input conditions will be cached to prevent identical configurations from being created.
var enable_caching: bool = true

## Type: InputButtonCondition[]
var _button_condition_cache: Array

## Type: Dictionary<String, InputSequenceCondition>
var _sequence_condition_cache: Dictionary

func new_button(fray_input: String, is_triggered_on_release: bool = false) -> InputButtonCondition:
	if enable_caching:
		for button in _button_condition_cache:
			if button.input == fray_input and button.is_triggered_on_release == is_triggered_on_release:
				return button

	var new_condition := InputButtonCondition.new(fray_input, is_triggered_on_release)
	_button_condition_cache.append(new_condition)
	return new_condition


func new_sequence(sequence_name: String) -> InputSequenceCondition:
	if enable_caching and _sequence_condition_cache.has(sequence_name):
		return _sequence_condition_cache[sequence_name]
	
	var new_condition := InputSequenceCondition.new(sequence_name)
	_sequence_condition_cache[sequence_name] = new_condition
	return new_condition

"""
const InputTransition = preload("transitions/input_transition.gd")

## Type: Array[InputTransition]
var _button_transitions: Array

## Type: Array[InputTransition]
var _sequence_transitions: Array

func new_button(fray_input: String, prereqs: Array = [], min_input_delay: float = 0) -> InputTransition:
	return _create_button_transition(_create_button_condition(fray_input), prereqs, min_input_delay)


func new_sequence(sequence_name: String, prereqs: Array = [], min_input_delay: float = 0) -> InputTransition:
	return _create_sequence_transition(_create_sequence_condition(sequence_name), prereqs, min_input_delay)
	

func _create_button_transition(input_condition: InputButtonCondition, prereqs: Array = [], min_input_delay: float = 0) -> InputTransition:
	if false: # NOTE: Create meaningful way to compare prerequisites
		for transition in _button_transitions:
			if transition.prerequisites == prereqs and min_input_delay == min_input_delay:
				return transition

	var new_transition := InputTransition.new(input_condition, prereqs, min_input_delay)
	_button_transitions.append(new_transition)
	return new_transition


func _create_sequence_transition(input_condition: InputSequenceCondition, prereqs: Array = [], min_input_delay: float = 0) -> InputTransition:
	if false: # NOTE: Create meaningful way to compare prerequisites
		for transition in _sequence_transitions:
			if transition.prerequisites == prereqs and min_input_delay == min_input_delay:
				return transition

	var new_transition := InputTransition.new(input_condition, prereqs, min_input_delay)
	_sequence_transitions.append(new_transition)
	return new_transition
"""

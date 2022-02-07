extends "transition.gd"

const InputData = preload("input_data/input_data.gd")
const CombatState = preload("../combat_state.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_sequence.gd")
const SequenceInputData = preload("../transitions/input_data/input_data.gd")
const VirtualInputData = preload("../transitions/input_data/virtual_input_data.gd")
const StringCondition = preload("../conditions/string_condition.gd")

var to: CombatState setget set_to_state, get_to_state
var input_data: InputData
var chain_conditions: Array
var min_input_delay: float

var _to := WeakRef.new()


func set_to_state(state: CombatState) -> void:
	_to = weakref(state)


func get_to_state() -> CombatState:
	return _to.get_ref()


func is_reachable(condition_dict: Dictionary, detected_input: DetectedInput, time_since_last_input: float) -> bool:
	return _is_matching_input(detected_input) and _is_conditions_true(condition_dict) and time_since_last_input >= min_input_delay


func _is_matching_input(detected_input: DetectedInput) -> bool:
	if detected_input is DetectedVirtualInput and input_data is VirtualInputData:
		return detected_input.input_id == input_data.input_id and detected_input.is_pressed != input_data.is_triggered_on_release
	elif detected_input is DetectedSequence and input_data is SequenceInputData:
		return detected_input.sequence_name == input_data.sequence_name
	
	return false


func _is_conditions_true(condition_dict: Dictionary) -> bool:
	for condition in chain_conditions:
		if condition is StringCondition:
			if not condition_dict.has(condition.condition_name):
				return false

			if not condition_dict[condition.condition_name]:
				return false
			
			return condition_dict[condition.condition_name]
	return true

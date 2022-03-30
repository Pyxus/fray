extends "input_condition.gd"

const DetectedSequence = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_sequence.gd")

var SequenceInputCondition = load("res://addons/stray_combat_framework/src/combat/state_management/input_data/sequence_input_condition.gd")

export var sequence_name: String


func _init(sequence_name: String) -> void:
	self.sequence_name = sequence_name

func is_satisfied_by(detected_input: DetectedInput) -> bool:
	if detected_input is DetectedSequence:
		return detected_input.sequence_name == sequence_name
		
	return false


func equals(input_condition: Reference) -> bool:
	.equals(input_condition)
	if input_condition is SequenceInputCondition:
		return input_condition.sequence_name == sequence_name
	return false

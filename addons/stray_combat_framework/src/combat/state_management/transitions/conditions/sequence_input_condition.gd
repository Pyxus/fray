extends "input_condition.gd"

const DetectedSequence = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_sequence.gd")

export var sequence_name: String


func _init(sequence_name: String) -> void:
	self.sequence_name = sequence_name

func is_satisfied_by(detected_input: DetectedInput) -> bool:
	if detected_input is DetectedSequence:
		return detected_input.sequence_name == sequence_name
		
	return false
extends "input_condition.gd"
## Class representing sequence condition

const BufferedInputSequence = preload("../../buffered_input/buffered_input_sequence.gd")

export var sequence_name: String


func _init(sequence_name: String) -> void:
	self.sequence_name = sequence_name

func is_satisfied_by(buffered_input: BufferedInput) -> bool:
	if buffered_input is BufferedInputSequence:
		return buffered_input.sequence_name == sequence_name
		
	return false

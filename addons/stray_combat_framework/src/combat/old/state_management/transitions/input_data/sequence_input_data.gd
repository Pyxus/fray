extends "input_data.gd"

var SequenceInputData = load("res://addons/stray_combat_framework/src/combat/state_management/transitions/input_data/sequence_input_data.gd")

export var sequence_name: String


func _init(sequence_name: String) -> void:
	self.sequence_name = sequence_name


func equals(input_data: Reference) -> bool:
	.equals(input_data)
	if input_data is SequenceInputData:
		return input_data.sequence_name == sequence_name
	return false

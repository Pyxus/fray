extends Reference

const InputData = preload("input_data/input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")

var input_data: InputData
var transition_animation: String = ""
var chain_conditions: PoolStringArray
var to: Reference


func is_identical_to(state_connection: Reference) -> bool:
	if not _is_same_input(state_connection.input_data, input_data):
		return false
	
	if chain_conditions.size() != state_connection.chain_conditions.size():
		return false
	
	for condition in chain_conditions:
		if not condition in state_connection.chain_conditions:
			return false
	
	return true


func _is_same_input(input_data1: InputData, input_data2: InputData) -> bool:
	if input_data1 is SequenceInputData:
		if input_data2 is SequenceInputData:
			if input_data1.sequence_name == input_data2.sequence_name:
				return true
	elif input_data1 is VirtualInputData:
		if input_data2 is VirtualInputData:
			if input_data1.input_id == input_data2.input_id:
				return true
	return false

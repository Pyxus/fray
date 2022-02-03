extends "state_connection.gd"

const InputData = preload("input_data/input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")

var input_data: InputData
var chain_conditions: PoolStringArray


func has_input(input_data: InputData) -> bool:
	return self.input_data.equals(input_data)


func is_identical_to(state_connection: Reference) -> bool:
	.is_identical_to(state_connection)
	
	if not has_input(state_connection.input_data):
		return false
	
	if chain_conditions.size() != state_connection.chain_conditions.size():
		return false
		
	for condition in state_connection.chain_conditions:
		if not condition in chain_conditions:
			return false
		
	return true

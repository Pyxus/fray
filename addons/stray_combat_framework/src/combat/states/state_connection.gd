extends Reference

const InputData = preload("input_data/input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")

var input_data: InputData
var transition_animation: String = ""
var chain_conditions: PoolStringArray
var to: Reference setget connect_to, to_state

var _to_ref: WeakRef


func connect_to(state: Reference) -> void:
	_to_ref = weakref(state)
	

func to_state() -> Reference:
	return _to_ref.get_ref()

func is_identical_to(state_connection: Reference) -> bool:
	return has_identical_details(state_connection.input_data, state_connection.chain_conditions)


func has_identical_details(input_data: InputData, chain_conditions: PoolStringArray) -> bool:
	if not has_input(input_data):
		return false

	if self.chain_conditions.size() != chain_conditions.size():
		return false

	for condition in self.chain_conditions:
		if not condition in chain_conditions:
			return false
	
	return true
	

func has_input(input_data: InputData) -> bool:
	if self.input_data is SequenceInputData:
		if input_data is SequenceInputData:
			if self.input_data.sequence_name == input_data.sequence_name:
				return true
	elif self.input_data is VirtualInputData:
		if input_data is VirtualInputData:
			if self.input_data.input_id == input_data.input_id:
				return true
	return false

extends Reference
## docstring

class SequenceInput extends Reference:
	const CInput = preload("cinput.gd")

	var input: CInput
	var charge_duration: float

#signals

#enums

#constants

const BufferedInput = preload("buffered_input.gd")
const CInput = preload("cinput.gd")

#exported variables

var sequence_inputs: Array
var name: String

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func add_action_aggregate(actions: Array, charge_duration: float = 0) -> void:
	var input := CInput.new()
	for action in actions:
		input.actions.append(action)

	add_input(input, charge_duration)

func add_action(action: String, charge_duration: float = 0) -> void:
	var input := CInput.new()
	input.actions.append(action)

	add_input(input, charge_duration)

func add_input(input: CInput, charge_duration: float = 0) -> void:
	var sequence_input := SequenceInput.new()
	sequence_input.input = input
	sequence_input.charge_duration = charge_duration
	sequence_inputs.push_back(sequence_input)

func is_valid_input(inputs: Array) -> bool:
	if inputs.size() != sequence_inputs.size():
		return false

	for i in len(inputs):
		var buffered_input := inputs[i] as BufferedInput
		var sequence_input := sequence_inputs[i] as SequenceInput
		var is_charged: bool = buffered_input.time_held >= sequence_input.charge_duration
		var is_action_same: bool = _is_array_equal(buffered_input.input.actions, sequence_input.input.actions)

		if not is_action_same or not is_charged:
			return false

	return true

func is_equal_to(sequence: Reference) -> bool:
	return _is_array_equal(sequence_inputs, sequence.sequence_inputs)

func _is_array_equal(array1: Array, array2: Array) -> bool:
	if array1.empty() or array2.empty():
		return false

	if array1.size() != array2.size():
		return false

	for i in len(array1):
		if array1[i] != array2[i]:
			return false

	return true

#signal methods

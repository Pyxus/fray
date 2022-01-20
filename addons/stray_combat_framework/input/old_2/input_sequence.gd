extends Reference

class SequenceInputData extends Reference:
    const SimpleInput = preload("simple_input.gd")

    var actions: Array
    var charge_duration: float


const BufferedInput = preload("buffered_input.gd")
const SimpleInput = preload("simple_input.gd")

var _sequence: Array
var name: String


func queue_action(action: String, charge_duration: float = 0) -> void:
    var input_data := SequenceInputData.new()
    input_data.actions = [action]
    input_data.charge_duration = charge_duration

func queue_action_combination(actions: Array, charge_duration: float = 0) -> void:
    for action in actions:
        queue_action(action)

func queue_input(input: SimpleInput, charge_duration: float = 0) -> void:
    queue_action_combination(input.get_actions(), charge_duration)


func matches(buffered_inputs: Array) -> bool:
	if buffered_inputs.size() != _sequence.size():
		return false

	for i in len(buffered_inputs):
		assert(buffered_inputs[i] is BufferedInput, "Passed inputs must be of type BufferedInputs")

		var seq_input_data := _sequence[i] as SequenceInputData
		var buffered_input := buffered_inputs[i] as BufferedInput
		var is_charged: bool = buffered_input.time_held >= seq_input_data.charge_duration
		var is_action_same: bool = _is_array_equal(buffered_input.input.get_actions(), seq_input_data.actions)
		
		if not is_action_same or not is_charged:
			return false

	return true


func equals(sequence: Reference) -> bool:
	return _is_array_equal(_sequence, sequence._sequence)


func _is_array_equal(array1: Array, array2: Array) -> bool:
	if array1.empty() or array2.empty():
		return false

	if array1.size() != array2.size():
		return false

	for i in len(array1):
		if array1[i] != array2[i]:
			return false

	return true
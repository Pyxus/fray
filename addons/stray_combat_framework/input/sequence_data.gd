extends Reference

const BufferedInput = preload("buffered_input.gd")
const SequenceParseResult = preload("sequence_parse_result.gd")

const DEFAULT_MAX_DELAY: float = 0.2
const INFINITE_DELAY: int = -1

var sequence: Array

func append_input(id: int, max_delay: float = DEFAULT_MAX_DELAY, charge_duration: float = 0.0) -> void:
	var input_data := InputData.new()
	input_data.id = id
	input_data.charge_duration = charge_duration
	input_data.max_delay = max_delay

	sequence.append(input_data)


func append_inputs(ids: PoolIntArray, max_delay: float = DEFAULT_MAX_DELAY) -> void:
	for id in ids:
		append_input(id, max_delay)


func parse(buffered_inputs: Array, start_index: int = 0) -> SequenceParseResult:
	for input in buffered_inputs:
		assert(input is BufferedInput, "Object %s is not of type BufferedInput." % input)

	var parse_result := SequenceParseResult.new()	

	if buffered_inputs.size() >= 2 and buffered_inputs.size() >= sequence.size():
		for i in range(start_index, buffered_inputs.size()):
			if _is_sequence_match(buffered_inputs, i):
				parse_result.discovered_at_index = i
				parse_result.is_match = true
				break

	return parse_result


func _is_sequence_match(buffered_inputs: Array, start_index: int) -> bool:
	var buffered_input: BufferedInput = buffered_inputs[start_index]
	var prev_buffered_input: BufferedInput = buffered_input
	var has_enough_buffered_inputs: bool = buffered_inputs.size() - start_index >= sequence.size()
	

	if not has_enough_buffered_inputs:
		return false

	for j in len(sequence):
		var input_data: InputData = sequence[j]
		var prev_input_data: InputData = sequence[j - 1] if j - 1 >= 0 else null
		var is_delay_infinite: bool = prev_input_data != null and prev_input_data.max_delay >= 0

		buffered_input = buffered_inputs[start_index + j]

		if input_data.id != buffered_input.id:
			return false
		
		if prev_input_data != null:
			if prev_input_data.max_delay >= 0 and buffered_input.get_time_between(prev_buffered_input) > input_data.max_delay:
				print(is_delay_infinite, ":", input_data.id)
				return false

		if buffered_input.time_held < input_data.charge_duration:
			return false

		prev_buffered_input = buffered_input
	return true


class InputData:
	extends Reference

	var id: int
	var charge_duration: float
	var max_delay: float

extends Reference

const SequenceData = preload("sequence_data.gd")
const SequenceParseResult = preload("sequence_parse_result.gd")


var _sequences: Array
var _discovered_at_indexes: PoolIntArray


func set_sequence(main_sequence: SequenceData, alternative_sequences: Array = []) -> void:
	_sequences.clear()

	_sequences.append(main_sequence)

	for alt_sequence in alternative_sequences:
		assert(alt_sequence is SequenceData, "alternative sequences array must include only objects of type SequenceData.")
		_sequences.append(alt_sequence)

	if main_sequence in alternative_sequences:
		push_warning("Unnecessary inclusion of main sequence '%s' in alternative sequences" % main_sequence)


func parse(buffered_inputs: Array) -> SequenceParseResult:
	for i in len(_sequences):
		var sequence_data: SequenceData = _sequences[i]
		var sequence_parse_result: SequenceParseResult = sequence_data.parse(buffered_inputs, get_start_index())

		if sequence_parse_result.is_match and not sequence_parse_result.discovered_at_index in _discovered_at_indexes:
			sequence_parse_result.is_alternative_input = true
			_discovered_at_indexes.append(sequence_parse_result.discovered_at_index)
			return sequence_parse_result

	return SequenceParseResult.new()

func get_start_index() -> int:
	if not _discovered_at_indexes.empty():
		return _discovered_at_indexes[_discovered_at_indexes.size() - 1] + 1
	return 0


func clear_discovered_indexes() -> void:
	_discovered_at_indexes = []

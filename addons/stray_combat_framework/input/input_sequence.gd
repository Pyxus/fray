extends Reference

const SequenceData = preload("sequence_data.gd")
const SequenceParseResult = preload("sequence_parse_result.gd")


var _sequences: Array
var _discovered_at_indexes: PoolIntArray


func set_sequence(clean_sequence: SequenceData, dirty_sequences: Array = []) -> void:
	_sequences.clear()

	_sequences.append(clean_sequence)

	for dirty_sequence in dirty_sequences:
		assert(dirty_sequence is SequenceData, "dirty_sequence array must include only objects of type SequenceData.")
		_sequences.append(dirty_sequences)

	if clean_sequence in dirty_sequences:
		push_warning("Unnecessary inclusion of main sequence in dirty sequences")


func is_match(buffered_inputs: Array) -> bool:
	for sequence_data in _sequences:
		var sequence_parse_result: SequenceParseResult = sequence_data.parse(buffered_inputs, get_start_index())
		if sequence_parse_result.is_match and not sequence_parse_result.discovered_at_index in _discovered_at_indexes:
			_discovered_at_indexes.append(sequence_parse_result.discovered_at_index)
			return true

	return false


func get_start_index() -> int:
	if not _discovered_at_indexes.empty():
		return _discovered_at_indexes[_discovered_at_indexes.size() - 1] + 1
	return 0


func clear_discovered_indexes() -> void:
	_discovered_at_indexes = []

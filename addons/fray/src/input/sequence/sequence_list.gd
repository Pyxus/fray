extends Resource
## Contains a list of input sequencs
##
## @desc:
##		List of sequences used by the SequenceAnalyzer.
##		A sequence is a name associated with one or more sequence paths.

const SequencePath = preload("sequence_path.gd")

## Type: Dictionary<String, Sequence[]>
## Hint: <sequence name, sub sequence array>
var _sequence_path_by_name: Dictionary

## Adds a sequence to list under a given name.
## 
## name is the name of the sequence, a name can be associated with many sequence paths.
## A sequence can have many paths which allows support for 'lenient inputs'.
## These are inputs that do not exactly match the intended sequence.
##
## sequence_path is a collection of input requirements that define a path.
func add(sequence_name: String, sequence_path: SequencePath) -> void:
	if not _sequence_path_by_name.has(sequence_name):
		_sequence_path_by_name[sequence_name] = []
	_sequence_path_by_name[sequence_name].append(sequence_path)

## Removes a sequence path at given index.
func remove_sequence_path(sequence_name: String, path_index: int) -> void:
	if _sequence_path_by_name.has(sequence_name):
		var sequences: Array = _sequence_path_by_name[sequence_name]
		if sequences.size() < path_index and path_index >= 0:
			sequences.remove(path_index)
		else:
			push_error("Index out of range")

## Removes all sequence paths associated with a given sequence.
func remove_sequence_path_all(sequence_name: String) -> void:
	if _sequence_path_by_name.has(sequence_name):
		_sequence_path_by_name[sequence_name].clear()

## Removes sequence along with all its paths.
func remove_sequence(sequence_name: String) -> void:
	if _sequence_path_by_name.has(sequence_name):
		_sequence_path_by_name.erase(sequence_name)

## Returns the sequence path at a given index.
func get_sequence_path(sequence_name: String, path_index: int = 0) -> SequencePath:
	if _sequence_path_by_name.has(sequence_name):
		var sequences: Array = _sequence_path_by_name[sequence_name]
		if sequences.size() < path_index and path_index >= 0:
			return sequences[path_index]
		else:
			push_error("Index out of range")
	return null

## Returns an array of all sequence paths associated with the given sequence name.
func get_sequence_paths(sequence_name: String) -> Array:
	if _sequence_path_by_name.has(sequence_name):
		return _sequence_path_by_name[sequence_name]
	return []

## Returns an array of all sequence names in the list.
func get_sequence_names() -> PoolStringArray:
	return PoolStringArray(_sequence_path_by_name.keys())

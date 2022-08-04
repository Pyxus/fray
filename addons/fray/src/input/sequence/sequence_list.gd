extends Resource

const SequencePath = preload("sequence_path.gd")

## Type: Dictionary<String, Sequence[]>
## Hint: <sequence name, sub sequence array>
var _sequence_path_by_name: Dictionary

## Adds a sequence to list under a given name.
## 
## name is the name of the sequence, a name can be associated with many sequence paths.
## A sequence can have many paths which allows support for 'lenient inputs'.
## Which are inputs that do not exactly match a sequence.
##
## sequence_path is a collection of input requirements that define a path.
func add(sequence_name: String, sequence_path: SequencePath) -> void:
	if not _sequence_path_by_name.has(sequence_name):
		_sequence_path_by_name[sequence_name] = []
	_sequence_path_by_name[sequence_name].append(sequence_path)


func remove_sub_squence(sequence_name: String, index: int) -> void:
	if _sequence_path_by_name.has(sequence_name):
		var sequences: Array = _sequence_path_by_name[sequence_name]
		if sequences.size() < index and index >= 0:
			sequences.remove(index)
		else:
			push_error("Index out of range")


func clear(sequence_name: String) -> void:
	if _sequence_path_by_name.has(sequence_name):
		_sequence_path_by_name[sequence_name].clear()


func get_sequence_path(sequence_name: String, index: int = 0) -> SequencePath:
	if _sequence_path_by_name.has(sequence_name):
		var sequences: Array = _sequence_path_by_name[sequence_name]
		if sequences.size() < index and index >= 0:
			return sequences[index]
		else:
			push_error("Index out of range")
	return null


func get_sequence_paths(sequence_name: String) -> Array:
	if _sequence_path_by_name.has(sequence_name):
		return _sequence_path_by_name[sequence_name]
	return []


func get_sequence_names() -> PoolStringArray:
	return PoolStringArray(_sequence_path_by_name.keys())

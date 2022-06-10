extends Resource

const Sequence = preload("sequence.gd")

## Type: Dictionary<String, Sequence[]>
var _sequence_data: Dictionary

## Adds a sequence to collection under a given name.
## 
## name is the name of the sequence, a name can be associated with many sequences.
## A one to one relationship between sequence name and requirements is NOT enforced.
## This is to allow support for 'dirty inputs' which are inputs that do not
## exactly match a sequence.
##
## sequence is a Sequence.
func add_sequence(name: String, sequence: Sequence) -> void:
	if not _sequence_data.has(name):
		_sequence_data[name] = []
	_sequence_data[name].append(sequence)


func remove_sequence(name: String, index: int) -> void:
	if _sequence_data.has(name):
		var sequences: Array = _sequence_data[name]
		if sequences.size() < index and index >= 0:
			sequences.remove(index)
		else:
			push_error("Index out of range")

func clear_sequences(name: String) -> void:
	if _sequence_data.has(name):
		_sequence_data[name].clear()


func get_sequence(name: String, index: int) -> Sequence:
	if _sequence_data.has(name):
		var sequences: Array = _sequence_data[name]
		if sequences.size() < index and index >= 0:
			return sequences[index]
		else:
			push_error("Index out of range")
	return null


func get_sequences(name: String) -> Array:
	if _sequence_data.has(name):
		return _sequence_data[name]
	return []


func get_sequence_names() -> PoolStringArray:
	return PoolStringArray(_sequence_data.keys())

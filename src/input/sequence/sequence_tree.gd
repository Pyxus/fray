class_name FraySequenceTree
extends Resource
## Contains a mapping of sequence names to [FraySequenceBranch]
##
## A sequence name can be associated with one or more sequence branches.
## This is to support sequence leneiency where partial or 'dirty' sequences
## will still be considered valid.

# Type: Dictionary<StringName, Sequence[]>
# Hint: <sequence name, sub sequence array>
var _sequence_branch_by_name: Dictionary

## Adds a sequence to list under a given name.
## [br][br]
## [kbd]sequence_name[/kbd] is the name of the sequence, a name can be associated with many sequence branches.
## A sequence can have many branchs which allows support for 'lenient inputs'.
## These are inputs that do not exactly match the intended sequence.
## [br][br]
## [kbd]sequence_branch[/kbd] is a collection of input requirements that define a branch.
func add(sequence_name: StringName, sequence_branch: FraySequenceBranch) -> void:
	if not _sequence_branch_by_name.has(sequence_name):
		_sequence_branch_by_name[sequence_name] = []
	_sequence_branch_by_name[sequence_name].append(sequence_branch)

## Removes a sequence branch at given index.
func remove_sequence_branch(sequence_name: StringName, branch_index: int) -> void:
	if _sequence_branch_by_name.has(sequence_name):
		var sequences: Array = _sequence_branch_by_name[sequence_name]
		if sequences.size() < branch_index and branch_index >= 0:
			sequences.remove_at(branch_index)
		else:
			push_error("Index out of range")

## Removes all sequence branchs associated with a given sequence.
func remove_sequence_branch_all(sequence_name: StringName) -> void:
	if _sequence_branch_by_name.has(sequence_name):
		_sequence_branch_by_name[sequence_name].clear()

## Removes sequence along with all its branchs.
func remove_sequence(sequence_name: StringName) -> void:
	if _sequence_branch_by_name.has(sequence_name):
		_sequence_branch_by_name.erase(sequence_name)

## Returns the sequence branch at a given index.
func get_sequence_branch(sequence_name: StringName, branch_index: int = 0) -> FraySequenceBranch:
	if _sequence_branch_by_name.has(sequence_name):
		var sequences: Array = _sequence_branch_by_name[sequence_name]
		if sequences.size() < branch_index and branch_index >= 0:
			return sequences[branch_index]
		else:
			push_error("Index out of range")
	return null

## Returns an array of all sequence branchs associated with the given sequence name.
func get_sequence_branchs(sequence_name: StringName) -> Array:
	if _sequence_branch_by_name.has(sequence_name):
		return _sequence_branch_by_name[sequence_name]
	return []

## Returns an array of all sequence names in the list.
func get_sequence_names() -> PackedStringArray:
	return PackedStringArray(_sequence_branch_by_name.keys())

extends Reference

const FrayInputEvent = preload("fray_input_event.gd")
const InputRequirement = preload("sequence/input_requirement.gd")
const SequenceList = preload("sequence/sequence_list.gd")

## Emmited when a sequence match is found.
##
## sequence_name is the name of the sequence.
##
## inputs is an array of input ids that was used to match the sequence.
signal match_found(sequence_name, inputs)


var _root: InputNode
var _current_node: InputNode
var _sequence_list: SequenceList

## Type: FrayInputEvent[]
var _input_queue: Array 

var _scan_start_index: int = 0


func initialize(sequence_list: SequenceList) -> void:
	_root = InputNode.new()
	_current_node = _root
	_sequence_list = sequence_list

	for name in sequence_list.get_sequence_names():
		var path_index := 0
		for sequence_path in sequence_list.get_sequence_paths(name):
			var next_node := _root
			var depth := 0

			for req in sequence_path.input_requirements:
				var parent := next_node
				next_node = parent.get_next(req.input, req.is_charge_input())

				if depth > 0 and req.is_charge_input():
					push_warning("Charge inputs should only be the first input in any path")

				if next_node == null:
					next_node = InputNode.new()
					next_node.input = req.input
					parent.add_node(next_node)
				depth += 1
			
			if next_node.sequence_name.empty():
				next_node.sequence_name = name
			else:
				push_error(
					"Collision for sequence '%s' at path index '%d'. " % [name, path_index] +
					"There can only be 1 sequence per path. " +
					"This sequence will be ignored"
					)
			path_index += 1
			

## Used to feed next inputs to analyzer.
func read(input_event: FrayInputEvent) -> void:
	if _root == null:
		push_error("Sequence analyzer is not initialized.")
		return
	

## Returns true if the given sequence of FrayInputEvents meets the input requirements of the sequence data.
static func is_match(fray_input_events: Array, input_requirements: Array) -> bool:
	if fray_input_events.size() != input_requirements.size():
		return false
	
	for i in len(input_requirements):
		var input_event: FrayInputEvent = fray_input_events[i]
		var input_requirement: InputRequirement = input_requirements[i]
		
		if input_event.input != input_requirement.input:
			return false

		if input_event.pressed == input_requirement.trigger_on_release:
			return false

		if not input_event.pressed and input_event.time_held < input_requirement.min_time_held:
			return false
		
		if i > 0:
			var time_since_last_input := input_event.get_time_between(fray_input_events[i - 1])
			if input_requirement.max_delay >= 0 and time_since_last_input > input_requirement.max_delay:
				return false

	return true


class InputNode:
	extends Reference

	var is_released_input: bool
	var sequence_name: String
	var input: String

	## Type: InputNode[]
	var _next_nodes: Array


	func add_node(node: InputNode) -> void:
		if not sequence_name.empty():
			push_warning("There can not be two sequences on the same path. Additional sequences will be ingored")
		_next_nodes.append(node)


	func get_next(input: String, released: bool) -> InputNode:
		for node in _next_nodes:
			if node.input == input and is_released_input == released:
				return node
		return null


	func has_next(input: String, released: bool) -> bool:
		return get_next(input, released) != null
	

	func get_child_count() -> int:
		return _next_nodes.size()


	func clear() -> void:
		_next_nodes.clear()

"""
- Design Notes -
>	Inputs should be processed in bundles.
	> 	Inputs that occur at the same time should be packed into the same bundle.
		If an input needed for a sequence and one that is not needed
		is received at the same time we can just ignore the uneeded input.
		This is to make inputs more lenient.
	>	If more than 1 input in the bundle matches to a next node in the path
		creating an amibguous situation resolve based on bundle order.
		A priority system could possibly be added but even then equivalent priorities
		are ambigious so for now leave if FCFC.

>	Ignore the max_delay of the first input in a sequence
	>	The delay is between inputs so it should do nothing for the first one

> 	Release inputs are ignored after depth 1
	except released inputs that end a sequence
	>	This lets us support negative edge
	>	depth 1 inputs can be released inputs to support charged inputs

> 	All paths must end with a leaf that contains a sequence

X> 	There can be no more paths added after a node with a sequence

>	When an input breaks a sequence the top of the queue will be popped and the whole queue re-evaluated
	>	This is to support 'path switching' where a player changes from one
		path to another. We assume the sequence may have broke because they
		were switched to enter a different sequence.
"""
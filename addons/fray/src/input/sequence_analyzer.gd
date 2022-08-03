extends Reference

const LinkedList = preload("res://addons/fray/lib/data_structures/linked_list.gd")
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
var _input_queue: LinkedList ## Type: LinkedList<InputFrame>
var _match_path: Array ## Type: InputEvent[]
var _current_frame: InputFrame

var _scan_start_index: int = 0


func initialize(sequence_list: SequenceList) -> void:
	_root = InputNode.new()
	_root.is_root = true
	_input_queue = LinkedList.new()
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
					push_warning("Charge inputs should only be the first input of any path. Sequence: '%s', Path Index: '%d'" % [name, path_index] )

				if next_node == null:
					next_node = InputNode.new()
					next_node.input = req.input
					next_node.is_press_input = not req.is_charge_input()
					parent.add_node(next_node)
				depth += 1
			
			if next_node.sequence_name.empty():
				next_node.sequence_name = name
				next_node.allow_negative_edge = sequence_path.allow_negative_edge
			else:
				push_error(
					"Collision for sequence '%s' at path index '%d'. " % [name, path_index] +
					"There can only be 1 sequence per path. " +
					"This sequence will be ignored"
					)
			path_index += 1
	_root.print_tree()

## Used to feed next inputs to analyzer.
func read(input_event: FrayInputEvent) -> void:
	if _root == null:
		push_error("Sequence analyzer is not initialized.")
		return

	if _ignore_released_input(input_event):
		print("IGNORED: ", input_event.input)
		return

	var next_node := _current_node.get_next(input_event.input, input_event.pressed)

	if next_node != null:
		_current_node = next_node
		_match_path.append(input_event)
	
	if _current_frame == null:
		_current_frame = _create_frame(input_event)

	if _current_frame.physics_frame == input_event.physics_frame:
		_current_frame.inputs.append(input_event)
	else:
		_current_frame = _create_frame(input_event)

		if next_node == null:
			_handle_sequence_break()
			pass
	
	if _current_node.has_sequence():
		var string: String
		for input in _match_path:
			string += input.input + ", "
		print(string)
		_reset()

			
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


func _ignore_released_input(input_event: FrayInputEvent) -> bool:
	return (
		not _match_path.empty() 
		and not input_event.pressed 
		and not _current_node.child_has_sequence())

func _reset() -> void:
	_current_frame = null
	_current_node = _root
	_match_path.clear()


func _handle_sequence_break() -> void:
	var next_node := _root
	while not _input_queue.empty() and next_node != null:
		var start_frame: InputFrame = _input_queue.get_head().data

		if not _match_path.empty() and start_frame.inputs.has(_match_path[0]):
			start_frame.inputs.remove(_match_path[0])
		else:
			_input_queue.remove_first()
		_match_path.clear()

		for frame in _input_queue:
			next_node = frame.trace(next_node, _match_path)
			_current_frame = frame

			if next_node == null:
				_current_frame = null
				break

	_current_node = next_node if next_node else _root

func _create_frame(input_event: FrayInputEvent) -> InputFrame:
	var frame = InputFrame.new()
	frame.physics_frame = input_event.physics_frame
	frame.inputs.append(input_event)
	_input_queue.add(frame)
	_input_queue.print_list()
	return frame


class InputFrame:
	extends Reference

	const FrayInputEvent = preload("fray_input_event.gd")
	
	## FrayInputEvent[]
	var inputs: Array
	var physics_frame: int

	func _to_string() -> String:
		var string := "[%d| " % physics_frame
		for i in len(inputs):
			var input: FrayInputEvent = inputs[i]

			string += input.input
			if not input.pressed:
				string += ".r"
			
			if i != inputs.size() - 1:
				string += ", "
			
		string += "]"
		return string

	func trace(start_node: InputNode, match_path: Array) -> InputNode:
		var end_node: InputNode
		var next_node := start_node
		for input in inputs:
			next_node = next_node.get_next(input.input, input.pressed)
			if next_node != null:
				match_path.append(input)
				end_node = next_node
		return end_node

class InputNode:
	extends Reference

	const CROSS = " ┠╴";
	const CORNER = " ┖ ";
	const VERTICAL = " ┃ ";
	const SPACE = "   ";

	var is_root: bool
	var is_press_input: bool
	var allow_negative_edge: bool
	var sequence_name: String
	var input: String

	## Type: InputNode[]
	var _next_nodes: Array

	func _to_string() -> String:
		if is_root:
			return "ROOT"

		var string := ""
		if sequence_name.empty():
			string = "[%s]" % input
		else:
			string = "[%s:%s]" % [input, sequence_name]
		
		if not is_press_input:
			string += ".r"
		return string

	func child_has_sequence() -> bool:
		for node in _next_nodes:
			if not node.sequence_name.empty():
				return true
		return false

	func add_node(node: InputNode) -> void:
		if not sequence_name.empty():
			push_warning("There can not be two sequences on the same path. Additional sequences will be ingored")
		_next_nodes.append(node)


	func get_next(input: String, is_pressed: bool) -> InputNode:
		for node in _next_nodes:
			if node.input == input and is_press_input == is_pressed or allow_negative_edge:
				return node
		return null


	func get_child(index: int) -> InputNode:
		return _next_nodes[index]


	func has_next(input: String, released: bool) -> bool:
		return get_next(input, released) != null
	

	func has_sequence() -> bool:
		return not sequence_name.empty()


	func get_child_count() -> int:
		return _next_nodes.size()


	func clear() -> void:
		_next_nodes.clear()


	func print_tree() -> void:
		_print_tree("", true)


	func _print_tree(prefix: String, is_last: bool) -> void:
		var new_prefix = CORNER if is_last else CROSS
		print(prefix + new_prefix + _to_string())

		for i in len(_next_nodes):
			var node = _next_nodes[i]
			new_prefix = SPACE if is_last else VERTICAL
			node._print_tree(prefix + new_prefix, i == _next_nodes.size() - 1)

"""
- Design Notes -
X>	Inputs should be processed in bundles.
	X> 	Inputs that occur at the same time should be packed into the same bundle.
		If an input needed for a sequence and one that is not needed
		is received at the same time we can just ignore the uneeded input.
		This is to make inputs more lenient.
	X>	Attempt to match all inputs in a frame in the order they appear but don't trigger
		a sequence break if one does not match.

?> 	Release inputs are ignored after depth 1
	except released inputs that end a sequence
	>	This lets us support negative edge
	>	depth 1 inputs can be released inputs to support charged inputs

?>	When an input breaks a sequence the top of the queue will be popped and the whole queue re-evaluated
	>	This is to support 'path switching' where a player changes from one
		path to another. We assume the sequence may have broke because they
		were switched to enter a different sequence.

>	Ignore the max_delay of the first input in a sequence
	>	The delay is between inputs so it should do nothing for the first one

X> 	All paths must end with a leaf that contains a sequence

X> 	There can be no more paths added after a node with a sequence

"""

extends Reference
## Used to detect input sequences
##
## @desc:
## 		The sequence analyzer can be used to detect input sequences such as
##		motion inputs which are common to many fighting games.
##		Search 'fighting game motion inputs' for more info on the concept.
##
##		To use you must first initialize the analyzer with a sequence list:
##
##		var sequence_analyzer := SequenceAnalyzer.new()
##		var sequence_list := SequenceList.new()
##
##		sequence_list.add("236p", SequencePath.new()\
##			.add("down").add("down_forward").add("backward").add("punch"))
##
##		sequence_analyzer.initialize(sequence_list)		

## Emmitted when a sequence match is found.
##
## `sequence_name: String` is the name of the sequence.
##
## `inputs: InputEvent[]` is an array of input events that was used to match the sequence.
signal match_found(sequence_name, inputs)

const LinkedList = preload("res://addons/fray/lib/data_structures/linked_list.gd")
const FrayInputEvent = preload("events/fray_input_event.gd")
const FrayInputEventBind = preload("events/fray_input_event_bind.gd")
const FrayInputEventComposite = preload("events/fray_input_event_composite.gd")
const InputRequirement = preload("sequence/input_requirement.gd")
const SequenceList = preload("sequence/sequence_list.gd")

## Type: LinkedList<InputFrame>
var _input_queue: LinkedList

## Type: InputEvent[]
var _match_path: Array

var _root: InputNode
var _current_node: InputNode
var _current_frame: InputFrame

## Returns true if the given sequence of FrayInputEvents meets the input requirements of the sequence data.
static func is_match(fray_input_events: Array, input_requirements: Array) -> bool:
	if fray_input_events.size() != input_requirements.size():
		return false
	
	for i in len(input_requirements):
		var input_event: FrayInputEvent = fray_input_events[i]
		var input_requirement: InputRequirement = input_requirements[i]
		
		if input_event.input != input_requirement.input:
			return false
		
		if not input_event.pressed and input_event.get_time_held_sec() < input_requirement.min_time_held:
			return false
		
		if i > 0:
			var sec_since_last_input := input_event.get_time_between_sec(fray_input_events[i - 1])
			if input_requirement.max_delay >= 0 and sec_since_last_input > input_requirement.max_delay:
				return false

	return true

## Initialzes the analyzer
##
## sequence list is used to register the sequences recognized by this analyzer
func initialize(sequence_list: SequenceList) -> void:
	_root = InputNode.new()
	_root.is_root = true
	_input_queue = LinkedList.new()
	_current_node = _root

	for name in sequence_list.get_sequence_names():
		var path_index := 0
		for sequence_path in sequence_list.get_sequence_paths(name):
			var next_node := _root

			for req in sequence_path.input_requirements:
				var parent := next_node
				next_node = parent.get_next(req.input, not req.is_charge_input())

				if parent != _root and req.is_charge_input():
					push_warning("Charge inputs should only be the first input of any path. Sequence: '%s', Path Index: '%d'" % [name, path_index] )

				if next_node == null:
					next_node = InputNode.new() 
					next_node.input = req.input
					next_node.is_press_input = not req.is_charge_input()
					parent.add_node(next_node)
			
			if not next_node.has_sequence():
				next_node.sequence_name = name
				next_node.sequence_path = sequence_path
				next_node.allow_negative_edge = sequence_path.allow_negative_edge
			else:
				push_error(
					"Collision for sequence '%s' at path index '%d' at input '%s'. " % [name, path_index, next_node.input] +
					"There can only be 1 sequence per path. " +
					"This sequence will be ignored"
					)
			path_index += 1

## Used to feed next inputs to analyzer.
func read(input_event: FrayInputEvent) -> void:
	if _root == null:
		push_error("Sequence analyzer is not initialized.")
		return
	
	if input_event is FrayInputEventBind and input_event.is_overlapping:
		return
	
	if not input_event.echo:
		var next_node := _current_node.get_next(input_event.input, input_event.pressed)
		if next_node != null:
			_current_node = next_node
			_match_path.append(input_event)

		if _current_frame == null:
			if next_node != null:
				_current_frame = _create_frame(input_event)
		elif _current_frame.physics_frame == input_event.physics_frame:
			_current_frame.add(input_event)
		else:
			# NOTE: Unexpected behavior discovered
			# If the first input in a new frame is a release input then even if
			# the following input would break the sequence it gets ignored if its within the newly created frame.
			# This behavior was unexpected but it allows inputs like 623P to accept 6236P.
			# Im keeping it for now as this result is somewhat desireable as a sort of input leniancy.
			# In an older itteration the approach to leniancy was to create sort of 'alias' branches that accepted 'bad' inputs.
			# If problems occur while testing let this note serve as a reminder of a possible source.
			# To remove this 'accidental feature' just move the sequence break resolution check outside of this else statement
			_current_frame = _create_frame(input_event)

			if next_node == null and input_event.pressed:
				_resolve_sequence_break()
		
		if _current_node.has_sequence():
			if is_match(_match_path, _current_node.sequence_path.input_requirements):
				emit_signal("match_found", _current_node.sequence_name, _match_path)
				_reset()
			else:
				_resolve_sequence_break()


func _resolve_sequence_break() -> void:
	var successful_retrace := false
	var next_node := _root
	var new_current_node := _root

	while not successful_retrace and not _input_queue.empty():
		var first_frame: InputFrame = _input_queue.get_head().data
		var can_remove_first_frame: bool = (
			_match_path.empty()
			or not first_frame.try_remove(_match_path.front())
			or first_frame.empty()
			)

		if can_remove_first_frame:
			_input_queue.remove_first()
		
		_match_path.clear()

		var has_break := false
		for frame in _input_queue:
			var node: InputNode = frame.trace(next_node, _match_path)
			
			if node != null:
				next_node = node
				new_current_node = node
			elif not frame.only_has_release():
				has_break = true
				next_node = _root
				break

		successful_retrace = not has_break

	_current_node = new_current_node


func _reset() -> void:
	_current_frame = null
	_current_node = _root
	_input_queue.clear()
	_match_path.clear()


func _create_frame(input_event: FrayInputEvent) -> InputFrame:
	var frame = InputFrame.new()
	frame.physics_frame = input_event.physics_frame
	frame.add(input_event)
	_input_queue.add(frame)
	return frame


class InputFrame:
	extends Reference

	const FrayInputEvent = preload("events/fray_input_event.gd")
	
	## FrayInputEvent[]
	var inputs: Array
	var physics_frame: int

	func _to_string() -> String:
		var string := "%d| " % physics_frame
		for i in len(inputs):
			var input: FrayInputEvent = inputs[i]

			string += input.input
			if not input.pressed:
				string += ".r"
			
			if i != inputs.size() - 1:
				string += ", "
		return string


	func add(input_event: FrayInputEvent) -> void:
		inputs.append(input_event)
	

	func try_remove(input_event: FrayInputEvent) -> bool:
		if inputs.has(input_event):
			inputs.erase(input_event)
			return true
		return false


	func empty() -> bool:
		return inputs.empty()


	func only_has_release() -> bool:
		for input in inputs:
			if input.pressed:
				return false
		return inputs.empty()


	func trace(start_node: InputNode, match_path: Array) -> InputNode:
		var match_node: InputNode
		for input in inputs:
			var node = start_node.get_next(input.input, input.pressed)
			if node != null:
				match_path.append(input)
				match_node = node
		return match_node

class InputNode:
	extends Reference

	const SequencePath = preload("sequence/sequence_path.gd")

	const CROSS = " ┠╴";
	const CORNER = " ┖ ";
	const VERTICAL = " ┃ ";
	const SPACE = "   ";

	var is_root: bool
	var is_press_input: bool
	var allow_negative_edge: bool
	var sequence_name: String
	var sequence_path: SequencePath
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


	func is_next_accepting_release(input: String) -> bool:
		for node in _next_nodes:
			if node.input == input and not node.sequence_name.empty() and (not node.is_press_input or node.allow_negative_edge):
				return true
		return false		


	func add_node(node: InputNode) -> void:
		if not sequence_name.empty():
			push_warning("There can not be two sequences on the same path. Additional sequences will be ingored")
		_next_nodes.append(node)


	func get_next(next_input: String, is_pressed: bool) -> InputNode:
		for node in _next_nodes:
			if node.input == next_input and (node.is_press_input == is_pressed or node.allow_negative_edge):
				return node
		return null


	func get_child(index: int) -> InputNode:
		return _next_nodes[index]


	func has_next(input: String, released: bool) -> bool:
		return get_next(input, released) != null
	

	func has_node(node: InputNode) -> bool:
		for next in _next_nodes:
			if next == node:
				return true
		return false

	func has_sequence() -> bool:
		return not sequence_name.empty() and sequence_path != null


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

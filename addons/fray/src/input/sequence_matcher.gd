class_name FraySequenceMatcher
extends RefCounted
## Used to detect input sequences
##
## The sequence matcher can be used to detect input sequences such as
## motion inputs which are common to many fighting games.
## Search "fighting game motion inputs" for more info on the concept.
## [br]
## To use you must first initialize the matcher with a sequence tree:
## [codeblock]
## var sequence_matcher := FraySequenceMatcher.new()
## var sequence_tree := SequenceTree.new()
##
## sequence_tree.add("236p", SequenceBranch.builder().then("down").then("down_forward").then("backward").then("punch").build())
##
## sequence_matcher.initialize(sequence_tree)
## [/codeblock]
##
## @tutorial(What Are Motion Inputs?): https://mugen.fandom.com/wiki/Command_input#Motion_input

## Emmitted when a sequence match is found.
signal match_found(sequence_name: StringName)

const _LinkedList = preload("res://addons/fray/lib/data_structures/linked_list.gd")

## If [code]true[/code], indistinct inputs will be ignored.
## [br]
## A composite input requires its binds to be pressed for it to be considered pressed.
## If all occuring inputs are fed directly to the sequence matcher
## then composites will always fail to match due to their binds causing sequence breaks.
## This option aims to prevent that by filtering out indistinct inputs. However, this means a composite's
## binds are likely to be ignored by the matcher when enabled; the same is true for lower priority composite's that share binds.
## It is recommend to design sequence branch's to only use inputs which will always be distinct.
## Alternatively this can be disabled and the user can implement their own input filtration when feeding inputs.
var can_ignore_indistinct_inputs: bool = true

# Type: LinkedList<InputFrame>
var _input_queue: _LinkedList

var _match_branch: Array[FrayInputEvent]
var _root: _InputNode
var _current_node: _InputNode
var _current_frame: _InputFrame

## Returns [code]true[/code] if the given sequence of inputs meets the input requirements of the sequence data.
static func is_match(events: Array[FrayInputEvent], input_requirements: Array[FrayInputRequirement]) -> bool:
	if events.size() != input_requirements.size():
		return false
	
	for i in len(input_requirements):
		var input_event: FrayInputEvent = events[i]
		var input_requirement: FrayInputRequirement = input_requirements[i]
		
		if input_event.input != input_requirement.input:
			return false
		
		if not input_event.is_pressed and input_event.get_time_held_msec() < input_requirement.min_time_held:
			return false
		
		if i > 0:
			var sec_since_last_input := input_event.get_time_between_msec(events[i - 1])
			if input_requirement.max_delay >= 0 and sec_since_last_input > input_requirement.max_delay:
				return false

	return true

## Initialzes the matcher
## [br]
## [kbd]sequence_tree[/kbd] is used to register the sequences recognized by this matcher
func initialize(sequence_tree: FraySequenceTree) -> void:
	_root = _InputNode.new()
	_root.is_root = true
	_input_queue = _LinkedList.new()
	_current_node = _root

	for name in sequence_tree.get_sequence_names():
		var branch_index := 0
		for sequence_branch in sequence_tree.get_sequence_branchs(name):
			var next_node := _root

			for req in sequence_branch.input_requirements:
				var parent := next_node
				next_node = parent.get_next(req.input, not req.is_charge_input())

				if parent != _root and req.is_charge_input():
					push_warning("Charge inputs should only be the first input of any branch. Sequence: '%s', branch Index: '%d'" % [name, branch_index] )

				if next_node == null:
					next_node = _InputNode.new() 
					next_node.input = req.input
					next_node.is_press_input = not req.is_charge_input()
					parent.add_node(next_node)
			
			if not next_node.has_sequence():
				next_node.sequence_name = name
				next_node.sequence_branch = sequence_branch
				next_node.is_negative_edge_enabled = sequence_branch.is_negative_edge_enabled
			else:
				push_error(
					"Collision for sequence '%s' at branch index '%d' at input '%s'. " % [name, branch_index, next_node.input] +
					"There can only be 1 sequence per branch. " +
					"This sequence will be ignored"
					)
			branch_index += 1

## Used to feed next inputs to matcher.
func read(input_event: FrayInputEvent) -> void:
	if _root == null:
		push_error("Sequence matcher is not initialized.")
		return

	if _can_ignore_input(input_event):
		return
	
	var next_node := _current_node.get_next(input_event.input, input_event.is_pressed)
	if next_node != null:
		_current_node = next_node
		_match_branch.append(input_event)

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

		if next_node == null and input_event.is_pressed:
			_resolve_sequence_break()
	
	if _current_node.has_sequence():
		if is_match(_match_branch, _current_node.sequence_branch.input_requirements):
			emit_signal("match_found", _current_node.sequence_name)
			_reset()
		else:
			_resolve_sequence_break()

## Returns current array of inputs used to attempt to match a sequence branch
## If called during a [signal match_found] signal callback then this array contains the exact input events that triggered the match.
func get_match_branch() -> Array[FrayInputEvent]:
	return _match_branch

## Prints a tree visualizing the branchs available on the sequence matcher
func print_tree() -> void:
	if _root == null:
		push_error("Sequence matcher is not initialized.")
		return

	_root.print_tree()


func _resolve_sequence_break() -> void:
	var successful_retrace := false
	var next_node := _root
	var new_current_node := _root

	while not successful_retrace and not _input_queue.empty():
		var first_frame: _InputFrame = _input_queue.get_head().data
		var can_remove_first_frame: bool = (
			_match_branch.is_empty()
			or not first_frame.try_remove(_match_branch.front())
			or first_frame.empty()
			)

		if can_remove_first_frame:
			_input_queue.remove_first()
		
		_match_branch.clear()

		var has_break := false
		for frame in _input_queue:
			var node: _InputNode = frame.trace(next_node, _match_branch)
			
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
	_match_branch.clear()


func _create_frame(input_event: FrayInputEvent) -> _InputFrame:
	var frame = _InputFrame.new()
	frame.physics_frame = input_event.physics_frame
	frame.add(input_event)
	_input_queue.add(frame)
	return frame


func _can_ignore_input(input_event: FrayInputEvent) -> bool:
	return(
		input_event.is_echo
		or can_ignore_indistinct_inputs and not input_event.is_distinct
	)


class _InputFrame:
	extends RefCounted

	var inputs: Array[FrayInputEvent]
	var physics_frame: int

	func _to_string() -> String:
		var string := "%d| " % physics_frame
		for i in len(inputs):
			var input: FrayInputEvent = inputs[i]

			string += input.input
			if not input.is_pressed:
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
		return inputs.is_empty()


	func only_has_release() -> bool:
		for input in inputs:
			if input.is_pressed:
				return false
		return inputs.is_empty()


	func trace(start_node: _InputNode, match_branch: Array) -> _InputNode:
		var match_node: _InputNode
		for input in inputs:
			var node = start_node.get_next(input.input, input.is_pressed)
			if node != null:
				match_branch.append(input)
				match_node = node
		return match_node

class _InputNode:
	extends RefCounted

	const CROSS = " ┠╴";
	const CORNER = " ┖ ";
	const VERTICAL = " ┃ ";
	const SPACE = "   ";

	var is_root: bool
	var is_press_input: bool
	var is_negative_edge_enabled: bool
	var sequence_name: StringName
	var sequence_branch: FraySequenceBranch
	var input: StringName

	var _next_nodes: Array[_InputNode]

	func _to_string() -> String:
		if is_root:
			return "ROOT"

		var string := ""
		if sequence_name.is_empty():
			string = "[%s]" % input
		else:
			string = "[%s] -> %s" % [input, sequence_name]
		
		if not is_press_input:
			string += ".r"
		return string


	func is_next_accepting_release(input: StringName) -> bool:
		for node in _next_nodes:
			if node.input == input and not node.sequence_name.is_empty() and (not node.is_press_input or node.is_negative_edge_enabled):
				return true
		return false		


	func add_node(node: _InputNode) -> void:
		if not sequence_name.is_empty():
			push_warning("There can not be two sequences on the same branch. Additional sequences will be ingored")
		_next_nodes.append(node)


	func get_next(next_input: StringName, is_pressed: bool) -> _InputNode:
		for node in _next_nodes:
			if node.input == next_input and (node.is_press_input == is_pressed or node.is_negative_edge_enabled):
				return node
		return null


	func get_child(index: int) -> _InputNode:
		return _next_nodes[index]


	func has_next(input: StringName, released: bool) -> bool:
		return get_next(input, released) != null
	

	func has_node(node: _InputNode) -> bool:
		for next in _next_nodes:
			if next == node:
				return true
		return false

	func has_sequence() -> bool:
		return not sequence_name.is_empty() and sequence_branch != null


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

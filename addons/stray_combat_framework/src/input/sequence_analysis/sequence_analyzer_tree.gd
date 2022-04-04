extends "sequence_analyzer.gd"
## docstring

#TODO: Add support for charged inputs
	# Right now only pressed inputs are fed to the sequence analyzer.
	# This is because if released inputs were also fed the analyzer would always fail to find a match.
	# Since charged inputs by necessity must be released this means there is no support for them at the moment.
	# Maybe I could feed released inputs to the analyzer and have it ignore them if there is no path for them?
	# Idea: Feed released inputs, have them ingored if no path. Perform a sub check from root to see if a path is open
	# if a path is open keep track of the sub match until a mismatch is detected or a sequence is found. 
	# If found accept this sub match and switch to this path. This will mean released inputs have priority in this case but I think that is alright.

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

#public variables

var _root := InputNode.new()
var _current_node: InputNode = _root
var _sequence_by_path: Dictionary # Dictionary<string, SequenceInput[]>
var _input_queue: Array # DetectedInputButton[]
var _rescan_start_index: int = 1

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func read(input_button: DetectedInputButton) -> void:
	var next_node := _current_node.get_next(input_button.id)

	# Ignore released inputs if node not found
	if next_node == null and not input_button.is_pressed:
		return

	_input_queue.append(input_button)

	if next_node != null:
		_current_node = next_node
	else:
		_rescan()

	var _input_path := _get_inputs_as_path()
	if _sequence_by_path.has(_input_path):
		for sequence_input in _sequence_by_path[_input_path]:
			if sequence_input.is_satisfied_by(_input_queue):
				_rescan_start_index = _input_queue.size()
				emit_signal("match_found", sequence_input.sequence_name)

	if _current_node != _root and _current_node.get_child_count() == 0:
		revert()


func add_sequence(sequence_data: SequenceData) -> void:
	if sequence_data.sequence_name.empty():
		push_error("Failed to add sequence. Sequence is not given a name")
		return

	var path: PoolStringArray
	var next_node := _root

	for req in sequence_data.input_requirements:
		var prev_node = next_node
		next_node = next_node.get_next(req.input_id)

		if next_node == null:
			next_node = InputNode.new()
			next_node.id = req.input_id
			prev_node.add_node(next_node)
	
		path.append(str(req.input_id))
	
	var path_string = path.join(">")
	if not _sequence_by_path.has(path_string):
		_sequence_by_path[path_string] = []

	_sequence_by_path[path_string].append(sequence_data)


func revert() -> void:
	_current_node = _root
	_rescan_start_index = 1
	_input_queue.clear()


func destroy_tree() -> void:
	_sequence_by_path.clear()
	_root.clear()
	_current_node = _root


func _rescan() -> void:
	var has_sub_sequence_match: bool = false
	var last_button: DetectedInputButton = _input_queue.back()

	if _input_queue.size() >= 2:
		var input_count: int = _input_queue.size() 
		
		for scan_index in range(_rescan_start_index, input_count):
			var next_node = _root

			for i in range(scan_index, input_count):
				next_node = next_node.get_next(_input_queue[i].id)

				if next_node == null:
					break

			if next_node != null:
				_current_node = next_node
				_input_queue = _input_queue.slice(scan_index, input_count)
				has_sub_sequence_match = true
				_rescan_start_index = 1
				return

	revert()


func _get_inputs_as_path() -> String:
	var path: PoolStringArray

	for input in _input_queue:
		path.append(str(input.id))

	return path.join(">")

#signal methods

class InputNode:
	extends Reference
	
	const InputRequirement = preload("input_requirement.gd")

	var id: int

	var _next_nodes: Array # InputNode[]

	func add_node(node: InputNode) -> void:
		_next_nodes.append(node)


	func get_next(id: int) -> InputNode:
		for node in _next_nodes:
			if node.id == id:
				return node
		return null


	func has_next(id: int) -> bool:
		return get_next(id) != null
	

	func get_child_count() -> int:
		return _next_nodes.size()


	func clear() -> void:
		_next_nodes.clear()

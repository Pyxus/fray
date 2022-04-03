extends Resource
## docstring

signal match_found(sequence_name)

#enums

const SequenceData = preload("sequence_data.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")

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

func advance(input_button: DetectedInputButton) -> void:
	var next_node := _current_node.get_next(input_button.id)
	_input_queue.append(input_button)
	print("Detected Input: ", input_button.id)
	if next_node != null:
		_current_node = next_node
	else:
		print("Triggered Rescan: ", input_button.id)
		_rescan()

	var _input_path := _get_inputs_as_path()
	if _sequence_by_path.has(_input_path):
		for sequence_input in _sequence_by_path[_input_path]:
			if sequence_input.is_satisfied_by(_input_queue):
				_rescan_start_index = _input_queue.size()
				print(sequence_input.sequence_name)
				emit_signal("match_found", sequence_input.sequence_name)

	if _current_node != _root and _current_node.get_child_count() == 0:
		revert()

func revert() -> void:
	_current_node = _root
	#_has_discovered_sequence = false
	_rescan_start_index = 1
	_input_queue.clear()


func register_sequence(sequence_data: SequenceData) -> void:
	if sequence_data.sequence_name.empty():
		push_error("Failed to register sequence. Sequence is not give a name")
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
				print("Successful Rescan")
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

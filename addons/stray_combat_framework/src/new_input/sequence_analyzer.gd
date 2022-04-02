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
var _accepted_inputs: Array # BufferedInput[]
var _travel_path: String = ""

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func advance(input_button: DetectedInputButton) -> bool:
	var is_input_consumed := false
	var next_node := _current_node.get_next(input_button.id)

	if next_node != null:
		_current_node = next_node
		_travel_path += str(input_button.id) + "-"
		_accepted_inputs.append(input_button)
		is_input_consumed = true
	else:
		is_input_consumed = false
		revert()

	if _sequence_by_path.has(_travel_path):
		for sequence_input in _sequence_by_path[_travel_path]:
			if sequence_input.is_satisfied_by(_accepted_inputs):
				emit_signal("match_found", sequence_input.name)

	return is_input_consumed

func revert() -> void:
	_current_node = _root
	_accepted_inputs.clear()
	_travel_path = ""

func register_sequence(sequence_data: SequenceData) -> void:
	var path_string := ""
	var next_node := _root

	for req in sequence_data.input_requirements:
		var prev_node = next_node
		next_node = next_node.get_next(req.input_id)

		if next_node == null:
			next_node = InputNode.new()
			next_node.id = req.input_id
			prev_node.add_node(next_node)
	
		path_string += str(req.input_id) + "-"
	
	if not _sequence_by_path.has(path_string):
		_sequence_by_path[path_string] = []

	_sequence_by_path[path_string].append(sequence_data)

func clear() -> void:
	_sequence_by_path.clear()
	_root.clear()
	_current_node = _root
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
	

	func clear() -> void:
		_next_nodes.clear()

class_name FraySequencePath
extends Resource
## Contains data on the inputs required for a sequence to be recognized.

## Array holding the InputRequirements used to detect a sequence.
var input_requirements: Array[FrayInputRequirement]

## If true the final input in the sequence is allowed to be triggered by a button release..
## Search "fighting game negative edge" for more info on the concept
var is_negative_edge_enabled: bool

func _init(path_allow_nedge = false) -> void:
	is_negative_edge_enabled = path_allow_nedge

## Returns a sequence path using the given inputs.
static func from_inputs(inputs: PackedStringArray, max_delay := .2) -> FraySequencePath:
	var path := FraySequencePath.new()
	
	for input in inputs:
		path.then(input, max_delay)

	return path

## Appends an input requirement to the end of the input_requirements array
## [br]
## Returns a reference to this sequence path.
## [br][br]
## [kbd]max_delay[/kbd] is the maximum time in seconds between two inputs. 
## [br]
## [kbd]min_time_held[/kbd] is the minimum time in seconds that the input is required to be held.
func then(input: StringName, max_delay := .2, min_time_held := 0.0) -> FraySequencePath:
	var input_requirement := FrayInputRequirement.new()
	input_requirement.input = input
	input_requirement.max_delay = max_delay
	input_requirement.min_time_held = min_time_held
	input_requirements.append(input_requirement)
	return self

## Sets [method is_negative_edge_enabled] to [code]true[/code]. 
##
## Returns a reference to this sequence path.
func enable_negative_edge() -> FraySequencePath:
	is_negative_edge_enabled = true
	return self

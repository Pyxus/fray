class_name FraySequencePath
extends Resource
## Contains data on the inputs required for a sequence to be recognized.

## Array holding the InputRequirements used to detect a sequence.
var input_requirements: Array[FrayInputRequirement]

## If true the final input in the sequence is allowed to be triggered by a button release
## Search 'fighting game negative edge' for more info on the concept
var allow_negative_edge: bool

func _init(path_allow_nedge = false, inputs: PackedStringArray = [], max_delay := .2) -> void:
	allow_negative_edge = path_allow_nedge
	for input in inputs:
		then(input, max_delay)

## Appends an input requirement to the end of the input_requirements array
##
## [kbd]max_delay[/kbd] is the maximum time in seconds between two inputs. 
##
## [kbd]min_time_held[/kbd] is the minimum time in seconds that the input is required to be held.
##
## Returns a reference to this sequence path allowing for chained method calls
func then(input: StringName, max_delay := .2, min_time_held := 0.0) -> FraySequencePath:
	var input_requirement := FrayInputRequirement.new()
	input_requirement.input = input
	input_requirement.max_delay = max_delay
	input_requirement.min_time_held = min_time_held
	input_requirements.append(input_requirement)
	return self

## Setter for 'allow_negative_edge. 
##
## Returns a reference to this sequence path allowing for chained method calls
func enable_negative_edge(allow: bool = true) -> FraySequencePath:
	allow_negative_edge = allow
	return self

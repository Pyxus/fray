extends Resource
## Contains data on the inputs required for a sequence to be recognized.

const InputRequirement = preload("input_requirement.gd")

## Array holding the InputRequirements used to detect a sequence.
var input_requirements: Array # InputRequirement[]

## If true the final input in the sequence is allowed to be triggered by a button release
## Search 'fighting game negative edge' for more info on the concept
var allow_negative_edge: bool

func _init(path_allow_nedge = false, inputs: PackedStringArray = []) -> void:
	allow_negative_edge = path_allow_nedge
	for input in inputs:
		then(input)

## Appends an input requirement to the end of the input_requirements array
##
## max_delay is the maximum time in seconds between two inputs. 
##
## min_time_held is the minimum time in seconds that the input is required to be held.
##
## Returns a reference to this sequence path allowing for chained method calls
func then(input: String, min_time_held := 0.0, max_delay := .2) -> RefCounted:
	var input_requirement := InputRequirement.new()
	input_requirement.input = input
	input_requirement.max_delay = max_delay
	input_requirement.min_time_held = min_time_held
	input_requirements.append(input_requirement)
	return self

## Setter for 'allow_negative_edge. 
##
## Returns a reference to this sequence path allowing for chained method calls
func enable_negative_edge(allow: bool = true) -> RefCounted:
	allow_negative_edge = allow
	return self
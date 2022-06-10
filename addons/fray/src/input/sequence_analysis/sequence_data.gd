extends Resource
## Contains data on the inputs required for a sequence to be recognized.

# Imports
const InputRequirement = preload("input_requirement.gd")
const DetectedInput = preload("../events/fray_input_event.gd")

## Name of the sequence. This name does not need to be unique.
var sequence_name: String

## Array holding the InputRequirements used to detect a sequence.
var input_requirements: Array # InputRequirement[]

func _init(name: String = "", input_ids: PoolIntArray = []) -> void:
	sequence_name = name
	
	for id in input_ids:
		append_input(id)

## Appends an input requirement to the end of the input_requirements array
##
## max_delay is the maximum time in seconds between 2 inputs. 
## Depending on the SequenceAnalyzer implementation the max_delay of the first requirement does nothing.
##
## min_time_held is the minimum time in seconds that the input is required to be held.
func append_input(id: int, max_delay: float = 0.3, min_time_held: float = 0.0) -> void:
	var input_requirement := InputRequirement.new()
	input_requirement.input_id = id
	input_requirement.max_delay = max_delay
	input_requirement.min_time_held = min_time_held
	input_requirements.append(input_requirement)

"""
func equals(requirements: Resource) -> bool:
	if requirements.size() != inputrequirements.requirements.size():
		return false

	for i in len(requirements):
		var my_requirement: InputRequirement = requirements[i]
		var other_requirement: InputRequirement = inputrequirements.requirements[i]

		if not my_requirement.equals(other_requirement):
			return false
	
	return true
"""

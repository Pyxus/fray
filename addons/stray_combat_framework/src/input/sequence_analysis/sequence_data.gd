#TODO: Make sure sequences support infinite time between inputs

extends Resource
## Contains data on the inputs required for a sequence to be recognized

const InputRequirement = preload("input_requirement.gd")
const DetectedInput = preload("../detected_inputs/detected_input.gd")

var sequence_name: String
var input_requirements: Array # InputRequirement[]

func _init(name: String = "", requirements: PoolIntArray = []) -> void:
    sequence_name = name
    
    append_inputs(requirements)

## Appends an input requirement to the end of the input_requirements array
func append_input(id: int, max_delay: float = 0.2, min_time_held: float = 0.0) -> void:
    var input_requirement := InputRequirement.new()
    input_requirement.input_id = id
    input_requirement.max_delay = max_delay
    input_requirement.min_time_held = min_time_held
    input_requirements.append(input_requirement)

## Appends multiple inputs to the end of input_requirements
func append_inputs(ids: PoolIntArray, max_delay: float = 0.2) -> void:
    for id in ids:
        append_input(id)

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
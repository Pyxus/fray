extends Resource

const InputRequirement = preload("input_requirement.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")

var sequence_name: String
var input_requirements: Array

func _init(name: String = "", requirements: Array = []) -> void:
    sequence_name = name
    input_requirements = requirements


func append_input(id: int, max_delay: float = 0.2, min_time_held: float = 0.0) -> void:
    var input_requirement := InputRequirement.new()
    input_requirement.input_id = id
    input_requirement.max_delay = max_delay
    input_requirement.min_time_held = min_time_held
    input_requirements.append(input_requirement)


func append_inputs(ids: PoolIntArray) -> void:
    for id in ids:
        append_input(id)


func is_satisfied_by(input_sequence: Array) -> bool:
    if input_requirements.size() != input_sequence.size():
        return false
    
    for i in len(input_requirements):
        var input_requirement: InputRequirement = input_requirements[i]
        var detected_input: DetectedInput = input_sequence[i]

        if detected_input.id != input_requirement.input_id:
            return false
        
        if detected_input.is_pressed != input_requirement.is_pressed_input:
            return false
            
        if detected_input.time_held < input_requirement.min_time_held:
            return false
        
        if i > 0 and detected_input.get_time_between(input_sequence[i - 1]) > input_requirement.max_delay:
            return false

    return true

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
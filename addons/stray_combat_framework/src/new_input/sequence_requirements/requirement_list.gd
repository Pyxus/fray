extends Resource
## docstring

#signals

#enums

#constants

const InputRequirement = preload("input_requirement.gd")

#exported variables

var name: String

var requirements: Array # InputRequirement[]

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods


func append_input(id: int, max_delay: float = 0.2, min_time_held: float = 0.0) -> void:
    var input_requirement := InputRequirement.new()
    input_requirement.input_id = id
    input_requirement.max_delay = max_delay
    input_requirement.min_time_held = min_time_held
    requirements.append(input_requirement)


func append_inputs(ids: PoolIntArray) -> void:
    for id in ids:
        append_input(id)


func size() -> int:
    return requirements.size()

    
func equals(inputrequirements: Resource) -> bool:
    if requirements.size() != inputrequirements.requirements.size():
        return false

    for i in len(requirements):
        var my_requirement: InputRequirement = requirements[i]
        var other_requirement: InputRequirement = inputrequirements.requirements[i]

        if not my_requirement.equals(other_requirement):
            return false
    
    return true

#private methods

#signal methods
extends Reference

const InputState = preload("input_data/state/input_state.gd")

## Type: Dictionary<string, InputState>
var input_state_by_name: Dictionary

## Type: Dictionary<String, bool>
var bool_by_condition: Dictionary

## Type: Dictionary<String, bool>
## Hint: Pseudo-Hashset
var filtered_inputs: Dictionary

func filter(inputs: PoolStringArray) -> void:
    for input in inputs:
        filtered_inputs[input] = true

func unfilter(inputs: PoolStringArray) -> void:
    for input in inputs:
        if filtered_inputs.has(input):
            filtered_inputs.erase(input)

func has_filtered(input: String) -> bool:
    return filtered_inputs.has(input)


func has_all_filtered(components: PoolStringArray) -> bool:
    return filtered_inputs.has_all(components)


func get_pressed_inputs() -> PoolStringArray:
    var pressed_inputs: PoolStringArray
    for input in input_state_by_name:
        if input_state_by_name[input].pressed:
            pressed_inputs.append(input)
    return pressed_inputs


func get_unpressed_inputs() -> PoolStringArray:
    var unpressed_inputs: PoolStringArray
    for input in input_state_by_name:
        if not input_state_by_name[input].pressed:
            unpressed_inputs.append(input)
    return unpressed_inputs


func get_all_inputs() -> PoolStringArray:
    return PoolStringArray(input_state_by_name.keys())


func get_input_state(input_name: String) -> InputState:
    if input_state_by_name.has(input_name):
        return input_state_by_name[input_name]
    return register_input_state(input_name)


func register_input_state(input_name: String) -> InputState:
    var input_state := InputState.new(input_name)
    input_state_by_name[input_name] = input_state
    return input_state


func is_condition_true(condition: String) -> bool:
    if bool_by_condition.has(condition):
        return bool_by_condition[condition]
    return false


func set_condition(condition: String, value: bool) -> void:
    bool_by_condition[condition] = value


func clear_conditions() -> void:
    bool_by_condition.clear()

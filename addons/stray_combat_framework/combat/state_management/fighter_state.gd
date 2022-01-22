extends Reference

const InputData = preload("input_data/input_data.gd")
const SequenceInputData = preload("input_data/sequence_input_data.gd")
const VirtualInputData = preload("input_data/virtual_input_data.gd")
const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_sequence.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_virtual_input.gd")

var animation: String

var extending_state: Reference setget extend

var _chained_action_states: Array


func extend(fighter_state: Reference) -> void:
    if fighter_state == self:
        push_warning("FighterState can not extend it self.")
        return

    extending_state = fighter_state


func chain_action(action_state: Reference) -> void:
    if _chained_action_states.has(action_state):
        push_warning("ActionState is already chained")
        return

    for chained_action_state in _chained_action_states:
        if _is_same_input_data(action_state.input, chained_action_state.input):
            push_warning("ActionState with identical input is already chained")
            return

    _chained_action_states.append(action_state)

func unchain_action(action_state: Reference) -> void:
    if _chained_action_states.has(action_state):
        _chained_action_states.erase(action_state)


func unchain_action_index(index: int) -> void:
    if index < _chained_action_states.size():
        _chained_action_states.remove(index)


func get_next_action(detected_input: DetectedInput) -> Reference:
    for action_state in _chained_action_states:
        if _is_same_input_detected(detected_input, action_state.input):
            return action_state
    return null


func get_chain_count() -> int:
    return _chained_action_states.size()


func _is_same_input_data(input_data1: InputData, input_data2: InputData) -> bool:
    if input_data1 is SequenceInputData:
        if input_data2 is SequenceInputData:
            if input_data1.sequence == input_data2.input.sequence:
                return true
    elif input_data1 is VirtualInputData:
        if input_data2 is VirtualInputData:
            if input_data1.id == input_data2.id:
                return true
    return false

func _is_same_input_detected(detected_input: DetectedInput, input_data: InputData) -> bool:
    if detected_input is DetectedSequence:
        if input_data is SequenceInputData:
            if detected_input.sequence == input_data.input.sequence:
                return true
    elif detected_input is DetectedVirtualInput:
        if input_data is VirtualInputData:
            if detected_input.id == input_data.id and detected_input.is_pressed != input_data.is_activated_on_release:
                return true
    return false
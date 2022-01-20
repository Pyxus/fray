extends Reference

const SimpleInput = preload("simple_input.gd")
const BufferedInput = preload("buffered_input.gd")

var _sequence: Array

func append_input(input: SimpleInput) -> void:
    _sequence.append(input)

func append_action(action: String, charge_duration: float = 0) -> void:
    var simple_input := SimpleInput.new()
    simple_input.actions.append(action)
    simple_input.charge_duration = charge_duration
    append_input(simple_input)


func append_combination_action(actions: Array, charge_duration: float = 0) -> void:
    var simple_input := SimpleInput.new()
    simple_input.actions = actions
    simple_input.charge_duration = charge_duration
    append_input(simple_input)



func matches(buffered_inputs: Array) -> bool:
    if buffered_inputs.empty():
        return false

    if buffered_inputs.size() < _sequence.size():
        return false

    var last_input: BufferedInput
    for sequence_input in _sequence:
        var buffered_input_time_held: float = buffered_inputs.front().time_held
        sequence_input = sequence_input as SimpleInput

        # Check if input matches accounting for combination inputs
        for i in len(sequence_input.actions):
            var buffered_input: BufferedInput = buffered_inputs.pop_front()

            if last_input != null:
                if (buffered_input.time_stamp - last_input.time_stamp) <= 0.001:
                    return false

            if not sequence_input.actions.has(buffered_input):
                return false
            
            if buffered_input_time_held < buffered_input.time_held:
                buffered_input_time_held = buffered_input.time_held

            last_input = buffered_input
        
        if buffered_input_time_held < sequence_input.charge_duration:
            return false

    return true
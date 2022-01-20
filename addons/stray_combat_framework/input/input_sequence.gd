extends Reference

const BufferedInput = preload("buffered_input.gd")


var _sequence: Array


func append_input(id: int, max_delay: float = 0.1, charge_duration: float = 0.0) -> void:
    var input_data := InputData.new()
    input_data.id = id
    input_data.charge_duration = charge_duration
    input_data.max_delay = max(0, max_delay)

    _sequence.append(input_data)


func is_match(buffered_inputs: Array) -> bool:
    for input in buffered_inputs:
        assert(input is BufferedInput, "Object %s is not of type BufferedInput." % input)

    if buffered_inputs.empty():
        return false

    if buffered_inputs.size() < _sequence.size():
        return false

    var last_input: BufferedInput
    for i in len(buffered_inputs):
        var buffered_input: BufferedInput = buffered_inputs[i]
        var seq_input_data: InputData = _sequence[i]

        if buffered_input.id != seq_input_data.id:
            return false

        if last_input != null:
            if buffered_input.calc_time_between(last_input) > seq_input_data.max_delay:
                return false
        
        if buffered_input.time_held < seq_input_data.charge_duration:
            return false

    return true


class InputData:
    extends Reference

    var id: int
    var charge_duration: float
    var max_delay: float
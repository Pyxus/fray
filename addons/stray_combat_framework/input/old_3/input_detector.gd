extends Node

signal sequence_inputed(sequence_name, device)

const SequenceInput = preload("sequence_input.gd")
const BufferedInput = preload("buffered_input.gd")

var _buffer_by_device: Dictionary
var _sequence_by_name: Dictionary


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_type():
        print("hgell")
    if event is InputEventAction:
        print("unhandled input")
        if event.pressed:
            var buffered_input := BufferedInput.new()
            buffered_input.device = event.device
            buffered_input.action = event.action
            buffered_input.time_stamp = OS.get_ticks_msec()

            if !_buffer_by_device.has(event.device):
                _buffer_by_device[event.device] = InputBuffer.new()

            _buffer_by_device[event.device].inputs.append(buffered_input)


func _process(delta: float) -> void:
    for device in _buffer_by_device:
        var input_buffer: InputBuffer = _buffer_by_device[device]
        for buffered_input in input_buffer.inputs:
            buffered_input.increment_held_time(delta)

        for sequence in _sequence_by_name:
            if _sequence_by_name[sequence].matches(input_buffer.inputs):
                emit_signal("sequence_inputed", sequence, device)
                break

func register_sequence(name: String, sequence_input: SequenceInput) -> void:
    if name.empty():
        push_warning("A sequence name must be given")
        return

    if _sequence_by_name.has(name):
        push_warning("A sequence with name '%s' already exists." % name)
        return

    _sequence_by_name[name] = sequence_input

class InputBuffer:
    extends Reference

    var inputs: Array
    var buffer_duration: float = 2
    var _time_since_input: float = 0.0

    func update(delta: float) -> void:
        if not inputs.empty():
            _time_since_input += delta
            if _time_since_input >= buffer_duration:
                clear()
                _time_since_input = 0
    
    func clear() -> void:
        for input in len(inputs):
            if input.is_released():
                inputs.erase(input)
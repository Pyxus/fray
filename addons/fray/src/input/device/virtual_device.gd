extends Reference

const DeviceState = preload("device_state.gd")

signal disconnection_request(id)

var _device_state: DeviceState
var _id: int

func _init(device_state: DeviceState, id: int):
    _device_state = device_state
    _id = id

## presses given input on virtual device
func press(input: String) -> void:
    match _device_state.get_input_state(input):
        var input_state:
            input_state.press()
        null:
            push_error("Unrecognized input '%s. Failed to press input on virtual device with id '%d'" % [input, _id])
            pass
    pass

## Unpresses given input on virtual device
func unpress(input: String) -> void:
    match _device_state.get_input_state(input):
        var input_state:
            input_state.unpress()
        null:
            push_error("Unrecognized input '%s. Failed to unpress input on virtual device with id '%d'" % [input, _id])
            pass
    pass

## Returns the integer id used by the FrayInput singleton to store
## the virtual device's device state.
func get_id() -> int:
    return _id

## 
func request_disconnect() -> void:
    emit_signal("disconnection_request", _id)
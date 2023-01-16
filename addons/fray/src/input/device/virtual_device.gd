extends RefCounted
## Manually controlled virtual device
##
## @desc:
## 		A virtual device's whos inputs must be manually controlled through code.

signal disconnect_requested()

const DeviceState = preload("device_state.gd")

var _device_state: DeviceState
var _id: int

func _init(device_state: DeviceState, id: int):
    _device_state = device_state
    _id = id

func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        unplug()

## presses given input on virtual device
func press(input: String, press_strength: float = 1.0) -> void:
    match _device_state.get_input_state(input):
        var input_state:
            input_state.strength = press_strength
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

## Disconnects the virtual device by removing it from the FrayInput singleton.
## Is automatically called when the virtual device is no longer being referenced.
func unplug() -> void:
    emit_signal("disconnect_requested")
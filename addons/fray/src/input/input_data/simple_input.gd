tool
extends "complex_input.gd"
## A complex input used as a wrapper around input binds
##
## @desc:
## 		Simple inputs will ignore their components.
##      They are similar to godot actions in that they hold an array of input binds and are
##      considered to be pressed when any bind in the array is pressed.
##      Simple inputs are intended to be the 'leaf' of any composition.

var binds: PoolStringArray


func get_binds() -> PoolStringArray:
    return binds


func _is_pressed(device: int, input_interface: InputInterface) -> bool:
    for bind in binds:
        var bind_state: InputState = input_interface.get_bind_state(bind, device)
        if bind_state.pressed:
            return true
    return false


func _decompose(device: int, input_interface: InputInterface) -> PoolStringArray:
    push_error("Method not implemented.")
    return PoolStringArray()

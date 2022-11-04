tool
extends "composite_input.gd"
## A composite input used as a wrapper around input binds
##
## @desc:
## 		Simple inputs do nothing with thier component and will ignore them.
##      They are similar to godot actions in that they hold an array of input binds and are
##      considered to be pressed when any bind in the array is pressed.
##      Simple inputs are intended to be the 'leaf' that ends any input composition.

var binds: PoolStringArray


func _is_pressed_impl(device: int, input_interface: InputInterface) -> bool:
    for bind in binds:
        var bind_state: InputState = input_interface.get_bind_state(bind, device)
        if bind_state.pressed:
            return true
    return false

func set_virtual(value: bool) -> void:
    .set_virtual(value)
    if is_virtual:
        push_warning("Conditionals by design always overlap with their components. A conditional will never trigger a virtual press.")

        
func _decompose_impl(device: int, input_interface: InputInterface) -> PoolStringArray:
    # Returns the most recently pressed bind
    var most_recent_bind: InputState
    for bind in binds:
        var bind_state: InputState = input_interface.get_bind_state(bind, device)

        if most_recent_bind != null:
            if most_recent_bind.time_pressed < bind_state.time_pressed:
                most_recent_bind = bind_state
        else:
            most_recent_bind = bind_state
    
    return PoolStringArray([most_recent_bind.input])

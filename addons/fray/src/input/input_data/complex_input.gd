tool
extends Resource
## Abstract base class for all complex inputs
##
## @desc:
##      Complex inputs are inputs composed of other complex inputs.

const InputInterface = preload("state/input_interface.gd")
const InputState = preload("state/input_state.gd")

## If true component binds that are still held when the combination is released
## will be treated as if they were pressed again.
var is_virtual: bool setget set_virtual

## Type: ComplexInput[]
var _components: Array 

## get_bind_state is a FuncRef of the type (string) -> InputState
func is_pressed(device: int, input_interface: InputInterface) -> bool:
    return _is_pressed(device, input_interface)


func add_component(component: Resource) -> void:
    for comp in _components:
        if comp == component:
            push_warning("Component '%s' has already been added." % comp)
            return

    _components.append(component)
    _component_added(component)

## Decomposes complex input into binds
func decompose() -> PoolStringArray:
    return PoolStringArray()

## Returns the binds associated with this node
func get_binds() -> PoolStringArray:
    var binds: PoolStringArray

    for component in _components:
        binds += component.get_binds()

    return binds

## is_virtual setter
func set_virtual(value: bool) -> void:
    is_virtual = value


## Virtual method used to define press checking behavior
func _is_pressed(device: int, input_interface: InputInterface) -> bool:
    push_error("Method not implemented.")
    return false

## Virtual method used to define decomposition procedure
func _decompose(device: int, input_interface: InputInterface) -> PoolStringArray:
    push_error("Method not implemented.")
    return PoolStringArray()


func _component_added(component: Resource) -> void:
    pass
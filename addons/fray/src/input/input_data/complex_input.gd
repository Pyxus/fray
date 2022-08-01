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

## Type: ComplexInput
var _root: Resource

## get_bind_state is a FuncRef of the type (string) -> InputState
func is_pressed(device: int, input_interface: InputInterface) -> bool:
    return _is_pressed(device, input_interface)

## Adds a component to this input
func add_component(component: Resource) -> void:
    if component._root != null:
        if component._root == get_root():
            push_warning("Component '%s' already belongs to this system." % component)
            return
        else:
            push_error("Failed to add component. Component already belongs to another system.")
            return

    for comp in _components:
        if comp == component:
            push_warning("Component '%s' has already been added." % comp)
            return

    component._root = get_root()
    _components.append(component)

## Decomposes complex input into binds
func decompose(device: int, input_interface: InputInterface) -> PoolStringArray:
    return _decompose(device, input_interface)

## is_virtual setter
func set_virtual(value: bool) -> void:
    is_virtual = value

## Returns the root of this complex input
## Returns: ComplexInput
func get_root() -> Resource:
    return _root if _root else self

## Virtual method used to define press check procedure
func _is_pressed(device: int, input_interface: InputInterface) -> bool:
    push_error("Method not implemented.")
    return false

## Virtual method used to define decomposition procedure
func _decompose(device: int, input_interface: InputInterface) -> PoolStringArray:
    push_error("Method not implemented.")
    return PoolStringArray()
tool
extends Resource
## Abstract base class for all composite inputs
##
## @desc:
##      Composite inputs are inputs composed of other composite inputs.

const InputInterface = preload("state/input_interface.gd")
const InputState = preload("state/input_state.gd")

## If true, components that are still held when the composite is released
## will be treated as if they were just pressed again.
var is_virtual: bool setget set_virtual

## The composite input's priority. Higher priority composites are processed first.
var priority: int

## Type: CompositeInput[]
var _components: Array 

## Type: CompositeInput
var _root_wf: WeakRef

## get_bind_state is a FuncRef of the type (string) -> InputState
func is_pressed(device: int, input_interface: InputInterface) -> bool:
	return _is_pressed_impl(device, input_interface)

## Adds a component to this input
func add_component(component: Resource) -> void:
	if component.get_root() == self:
		push_warning("Component '%s' already belongs to this system." % component)
		return
	elif component.get_root() != null:
		push_error("Failed to add component. Component already belongs to another system.")
		return

	for comp in _components:
		if comp == component:
			push_warning("Component '%s' has already been added." % comp)
			return

	component._root_wf = weakref(get_root())
	_components.append(component)

## Decomposes composite input into binds
func decompose(device: int, input_interface: InputInterface) -> PoolStringArray:
	return _decompose_impl(device, input_interface)

## Returns true if the composite input can decompose into the given binds
## 'is_exact' If true then the given binds need to exactly match the input's decomposition
func can_decompose_into(device: int, input_interface: InputInterface, binds: PoolStringArray, is_exact := true)  -> bool:
	var my_components := decompose(device, input_interface)

	if binds.empty() or my_components.empty():
		return false

	if binds.size() < my_components.size():
		return false
	
	if is_exact:
		if binds.size() != my_components.size():
			return false

		for bind in binds:
			var has_bind := false
			for component in my_components:
				if bind == component:
					has_bind = true
			if not has_bind:
				return false
	else:
		for bind in binds:
			if not bind in my_components:
				return false
	return true

	#var my_component_str := decompose(device, input_interface).join(" ")
	#var bind_str := binds.join(" ")
	#return my_component_str == bind_str


## is_virtual setter
func set_virtual(value: bool) -> void:
	is_virtual = value

	if get_root() != null:
		push_warning("Virtual on a non-root component has no affect.") 

## Returns the root of this composite input
## Returns: CompositeInput
func get_root() -> Resource:
	var ref = _root_wf.get_ref() if _root_wf else null
	return ref

## Abstract method used to define press check procedure
func _is_pressed_impl(device: int, input_interface: InputInterface) -> bool:
	push_error("Method not implemented.")
	return false

## Abstract method used to define decomposition procedure
func _decompose_impl(device: int, input_interface: InputInterface) -> PoolStringArray:
	push_error("Method not implemented.")
	return PoolStringArray()

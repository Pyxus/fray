@tool
class_name FrayCompositeInput
extends Resource
## Abstract base class for all composite inputs
##
## Composite inputs are inputs composed of other composite inputs.

## If true, components that are still held when the composite is released
## will be treated as if they were just pressed again.
var is_virtual: bool:
	set(value):
		is_virtual = value

		if get_root() != null:
			push_warning("Enabling virtual on a non-root component has no effect.")

## The composite input's priority. Higher priority composites are processed first.
var priority: int

var _components: Array[FrayCompositeInput]

# Type: WeakRef<CompositeInput>
var _root_wf: WeakRef


## get_bind_state is a FuncRef of the type (string) -> InputState
func is_pressed(device: int) -> bool:
	return _is_pressed_impl(device)


## Adds a component to this input
func add_component(component: FrayCompositeInput) -> void:
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

	if component.is_virtual:
		push_warning("Enabling virtual on a child component has no effect.")

	component._root_wf = weakref(get_root())
	_components.append(component)


## Returns the number of components.
func get_component_count() -> int:
	return _components.size()


## Decomposes composite input into binds
func decompose(device: int) -> Array[StringName]:
	return _decompose_impl(device)


## Returns true if the composite input can decompose into the given binds
## If [kbd]is_exact[/kbd] is true then the given binds need to exactly match the input's decomposition
func can_decompose_into(device: int, binds: Array[StringName], is_exact := true) -> bool:
	var my_components := decompose(device)

	if binds.is_empty() or my_components.is_empty():
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


## Returns the root of this composite input if it exists.
func get_root() -> FrayCompositeInput:
	var ref = _root_wf.get_ref() if _root_wf else null
	return ref


## Returns the time in milliseconds that this composite was considered pressed.
func get_time_pressed(device: int) -> int:
	for component in _components:
		var binds := decompose(device)

		if not binds.is_empty():
			var most_recent_press := get_bind_state(binds[0], device).time_pressed
			for bind in binds:
				var bind_state := get_bind_state(bind, device)
				if bind_state.time_pressed < most_recent_press:
					most_recent_press = bind_state.time_pressed
			return most_recent_press
	return -1


## Returns the state of a [kbd]bind[/kbd] on a given [kbd]device[/kbd]
func get_bind_state(bind: StringName, device: int) -> FrayInputState:
	return FrayInput._get_bind_state(bind, device)


## Abstract method used to define press check procedure.
func _is_pressed_impl(device: int) -> bool:
	assert(false, "Method not implemented")
	return false


## Abstract method used to define decomposition procedure.
func _decompose_impl(device: int) -> Array[StringName]:
	assert(false, "Method not implemented")
	return []

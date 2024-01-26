@tool
class_name FrayCombinationInput
extends FrayCompositeInput
## A composite input used to create combination inputs
##
## A combination will be considered as press when
## all components are pressed according to the mode.

enum Mode {
	SYNC,  ## Components must all be pressed at the same time.
	ASYNC,  ## Components can be pressed at any time so long as they are all pressed.
	ORDERED,  ## Like asynchronous but the presses must occur in order.
}

## Determines press condition necessary to trigger combination
var mode: Mode = Mode.SYNC

## Returns a builder instance
static func builder() -> Builder:
	return Builder.new()

func _is_pressed_impl(device: int) -> bool:
	match mode:
		Mode.SYNC:
			return _is_combination_quick_enough(device)
		Mode.ASYNC:
			return _is_all_components_pressed(device)
		Mode.ORDERED:
			return _is_combination_in_order(device)
		_:
			push_error("Failed to check combination. Unknown mode '%d'" % mode)

	return false


func _decompose_impl(device: int) -> Array[StringName]:
	# Returns all components decomposed and joined
	var binds: Array[StringName]
	for component in _components:
		binds.append_array(component.decompose(device))
	return binds


# Returns: InputState[]
func _get_decomposed_states(device: int) -> Array:
	var decomposed_states := []
	for bind in decompose(device):
		decomposed_states.append(get_bind_state(bind, device))
	return decomposed_states


func _is_all_components_pressed(device: int) -> bool:
	for component in _components:
		if not component.is_pressed(device):
			return false
	return true


func _is_combination_quick_enough(device: int, tolerance: float = 10) -> bool:
	var decomposed_states := _get_decomposed_states(device)
	var avg_difference := 0

	for i in len(decomposed_states):
		if i > 0:
			var input1: FrayInputState = decomposed_states[i]
			var input2: FrayInputState = decomposed_states[i - 1]

			if not input1.is_pressed or not input2.is_pressed:
				return false

			avg_difference += abs(input1.time_pressed - input2.time_pressed)

	avg_difference /= float(decomposed_states.size())
	return avg_difference <= tolerance


func _is_combination_in_order(device: int, tolerance: float = 10) -> bool:
	var decomposed_states := _get_decomposed_states(device)

	for i in len(decomposed_states):
		if i > 0:
			var input1: FrayInputState = decomposed_states[i]
			var input2: FrayInputState = decomposed_states[i - 1]

			if not input1.is_pressed or not input2.is_pressed:
				return false

			if input2.time_pressed - tolerance > input1.time_pressed:
				return false

	return true


class Builder:
	extends FrayCompositeInput.Builder

	func _init() -> void:
		_composite_input = FrayCombinationInput.new()
	
	## Builds the composite input.
	## [br]
	## Returns a reference to the newly built combination input.
	func build() -> FrayCombinationInput:
		return _composite_input
	
	## Sets the combination to async mode.
	## [br]
	## Returns a reference to the newly built combination input.
	func mode_async() -> Builder:
		_composite_input.mode = FrayCombinationInput.Mode.ASYNC
		return self

	## Sets the combination to sync mode.
	## [br]
	## Returns a reference to the newly built combination input.
	func mode_sync() -> Builder:
		_composite_input.mode = FrayCombinationInput.Mode.SYNC
		return self

	## Sets the combination to ordered mode.
	## [br]
	## Returns a reference to the newly built combination input.
	func mode_ordered() -> Builder:
		_composite_input.mode = FrayCombinationInput.Mode.ORDERED
		return self

	func add_component(composite_input: FrayCompositeInput) -> Builder:
		return super(composite_input)
	
	func add_component_simple(bind: StringName) -> Builder:
		return super(bind)

	func is_virtual(value: bool = true) -> Builder:
		return super(value)

	func priority(value: int) -> Builder:
		return super(value)
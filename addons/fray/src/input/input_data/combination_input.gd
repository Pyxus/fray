tool
extends "complex_input.gd"
## A complex input used to create combination inputs
##
## @desc:
## 		A combination will be considered as press when
##      all components are pressed according to the mode.

enum Mode {
	SYNC, ## Components must all be pressed at the same time
	ASYNC, ## Components can be pressed at any time so long as they are all pressed.
	ORDERED, ## Like asynchronous but the presses must occur in order
}

## Determines press condition necessary to trigger combination
var mode: int = Mode.SYNC


func _is_pressed(device: int, input_interface: InputInterface) -> bool:
	match mode:
		Mode.SYNC: 
			return _is_combination_quick_enough(device, input_interface)
		Mode.ASYNC: 
			return _is_all_components_pressed(device, input_interface)
		Mode.ORDERED: 
			return _is_combination_in_order(device, input_interface)
		_:
			push_error("Failed to check combination. Unknown mode '%d'" % mode)

	return false


func _decompose_components(device: int, input_interface: InputInterface) -> Array:
	var decomposed_states := []
	for component in _components:
		var binds: PoolStringArray = component.get_binds()
		var most_recent_bind: InputState

		for bind in binds:
			var bind_state: InputState = input_interface.get_bind_state(bind, device)

			if most_recent_bind != null:
				if most_recent_bind.time_pressed < bind_state.time_pressed:
					most_recent_bind = bind_state
			else:
				most_recent_bind = bind_state
		
		if most_recent_bind != null:
			decomposed_states.append(most_recent_bind)
	return decomposed_states


func _is_all_components_pressed(device: int, input_interface: InputInterface) -> bool:
	for component in _components:
		if not component.is_pressed(device, input_interface):
			return false
	return true


func _is_combination_quick_enough(device: int, input_interface: InputInterface, tolerance: float = 10) -> bool:
	var decomposed_states := _decompose_components(device, input_interface)
	var avg_difference := 0

	for i in len(decomposed_states):
		if i > 0:
			var input1: InputState = decomposed_states[i]
			var input2: InputState = decomposed_states[i - 1]

			if not input1.pressed or not input2.pressed:
				return false

			avg_difference += abs(input1.time_pressed - input2.time_pressed)

	avg_difference /= float(decomposed_states.size())
	return avg_difference <= tolerance


func _is_combination_in_order(device: int, input_interface: InputInterface, tolerance: float = 10) -> bool:
	var decomposed_states := _decompose_components(device, input_interface)

	for i in len(decomposed_states):
		if i > 0:
			var input1: InputState = decomposed_states[i]
			var input2: InputState = decomposed_states[i - 1]

			if not input1.pressed or not input2.pressed:
				return false

			if input2.time_pressed - tolerance > input1.time_pressed:
				return false

	return true

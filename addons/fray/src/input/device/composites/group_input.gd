extends FrayCompositeInput

enum Mode{
	ANY, ## Any component must be pressed.
	ANY_N ## An 'n' amount of any components  must be pressed.
}

@export var mode: Mode
@export var n: int

# Type: Dictionary<int, PackedStringArray>
var _last_inputs_by_device: Dictionary

func _is_pressed_impl(device: int, input_interface: FrayInputInterface) -> bool:
	
	match mode:
		Mode.ANY:
			for component in _components:
				if component.is_pressed(device, input_interface):
					
					_last_inputs_by_device[device] = component.decompose(device, input_interface)
					return true
		Mode.ANY_N:
			var press_count := 0
			var _last_inputs := PackedStringArray()
			for component in _components:
				if component.is_pressed(device, input_interface):
					_last_inputs += component.decompose(device, input_interface)
					press_count += 1

			if press_count >= n:
				_last_inputs_by_device[device] = _last_inputs
				return true

	return false


func _decompose_impl(device: int, input_interface: FrayInputInterface) -> PackedStringArray:

	return _last_inputs_by_device[device] if _last_inputs_by_device.has(device) else PackedStringArray()

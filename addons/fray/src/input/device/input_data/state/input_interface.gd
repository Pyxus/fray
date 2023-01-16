extends RefCounted
## Helper class for input nodes to safely interface with the FrayInput singleton.
## Used to fetch the state of certain data in the singleton.

const InputState = preload("input_state.gd")

var _fray_input: WeakRef


func _init(fray_input_ref: WeakRef) -> void:
	_fray_input = fray_input_ref


func get_bind_state(bind: String, device: int) -> InputState:
	return _fray_input.get_ref()._get_bind_state(bind, device)


func is_condition_true(condition: String, device: int) -> bool:
	return _fray_input.get_ref().is_condition_true(condition, device)
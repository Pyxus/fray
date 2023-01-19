class_name FrayFrayInputInterface
extends RefCounted
## Helper class for composite inputs to safely interface with the FrayInput singleton.
## Used to fetch the state of certain data in the fray input singleton.


var _fray_input: WeakRef

func _init(fray_input_ref: WeakRef) -> void:
	_fray_input = fray_input_ref


func get_bind_state(bind: String, device: int) -> FrayInputState:
	return _fray_input.get_ref()._get_bind_state(bind, device)


func is_condition_true(condition: String, device: int) -> bool:
	return _fray_input.get_ref().is_condition_true(condition, device)

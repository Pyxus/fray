extends "condition.gd"
## Condition that is satisfied by string parameter

var param: String

## Type: (String) -> bool
var func_is_param_true: FuncRef

func _init(func_is_param_true: FuncRef) -> void:
    self.func_is_param_true = func_is_param_true

func _equals_impl(condition: Reference) -> bool:
    return param == condition.param
        

func _is_param_true() -> bool:
    if func_is_param_true.is_valid():
        return func_is_param_true.call_func(param)
    else:
        push_error("Failed to evaluate parameter. 'func_is_param_true' FuncRef is no longer valid.")
        return false


func _is_satisfied_impl() -> bool:
    return _is_param_true()
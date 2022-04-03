extends "input_bind.gd"
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

#public variables

var _bind_by_condition: Dictionary # Dictionary<string, InputBind>
var _current_bind: Resource # InputBind
var _default_bind: Resource # InputBind
var _condition_evaluator_func: FuncRef

#onready variables


#optional built-in virtual _init method

func _init(default_bind: Resource = null) -> void:
    set_default_bind(default_bind)
    
#remaining built-in virtual methods

func set_condition_evaluator(evaluator_func: FuncRef) -> void:
    _condition_evaluator_func = evaluator_func

    
func set_default_bind(default_bind: Resource):
    if default_bind == self:
        push_error("Failed to set defailt bind. A conditional bind can not have it self as a bind.")
        return

    _default_bind = default_bind


func add_bind(condition: String, input_bind: Resource) -> void:
    _bind_by_condition[condition] = input_bind


func poll() -> void:
    _current_bind = _default_bind
    for condition in _bind_by_condition:
        if _condition_evaluator_func.call_func(condition):
            _current_bind = _bind_by_condition[condition]
            break
    .poll()

func is_pressed() -> bool:
	return _current_bind != null and _current_bind.is_pressed()

#private methods

#signal methods

#inner classes

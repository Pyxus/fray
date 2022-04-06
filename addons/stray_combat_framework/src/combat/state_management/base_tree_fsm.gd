extends "res://addons/stray_combat_framework/lib/state_machine/state_machine.gd"
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

#public variables

var _condition_evaluator_func: FuncRef # func(string) -> bool

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func set_condition_evaluator(evaluation_func: FuncRef) -> void:
	_condition_evaluator_func = evaluation_func

	
func get_combat_fsm() -> Resource: # CombatFSM
    return null


func _is_condition_true(condition: String) -> bool:
	if _condition_evaluator_func == null or not _condition_evaluator_func.is_valid():
		push_error("Failed to evaluate condition '%s'. Condition evaluator function is either nor set or no longer valid." % condition)
		return false
		
	return _condition_evaluator_func.call_func(condition)

#signal methods

#inner classes

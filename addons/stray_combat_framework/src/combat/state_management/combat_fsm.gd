extends "res://addons/stray_combat_framework/lib/state_machine/state_machine.gd"
## Base class for finite state machine used by CombatTree


var _condition_evaluator_func: FuncRef # func(string) -> bool

## Sets the condition evaluator function used by the finite state machine
func set_condition_evaluator(evaluation_func: FuncRef) -> void:
	_condition_evaluator_func = evaluation_func

#TODO: Remove this... Why is a parent class dependent on a child class?
## Abstract method which returns the current combat fsm
func get_action_fsm() -> Resource: # CombatFSM
	push_error("No get_action_fsm implementation provided.")
	return null


func _is_condition_true(condition: String) -> bool:
	if _condition_evaluator_func == null or not _condition_evaluator_func.is_valid():
		push_error("Failed to evaluate condition '%s'. Condition evaluator function is either nor set or no longer valid." % condition)
		return false
		
	return _condition_evaluator_func.call_func(condition)
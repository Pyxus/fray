extends "base_tree_fsm.gd"
## docstring

#signals

#enums

const AutoAdvanceTransition = preload("transitions/auto_advance_transition.gd")
const CombatSituationState = preload("combat_situation_state.gd")

#preloaded scripts and scenes

#exported variables

#public variables

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func set_condition_evaluator(evaluation_func: FuncRef) -> void:
	.set_condition_evaluator(evaluation_func)

	for state in get_all_states_obj():
		if state is CombatSituationState:
			state.combat_fsm.set_condition_evaluator(evaluation_func)


func get_combat_fsm() -> Resource: # CombatFSM
	var current_state = get_current_state_obj()
	if current_state is CombatSituationState:
		return current_state.combat_fsm
	return null



func _get_next_state(input: Object = null) -> String:
	var next_transitions := get_next_transitions(current_state)

	for transition_data in next_transitions:
		var transition := transition_data.transition as AutoAdvanceTransition
		if transition == null:
			continue
		
		if _is_condition_true(transition.advance_condition.condition):
			return transition_data.to

	return ""

#signal methods

#inner classes

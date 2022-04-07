extends "combat_fsm.gd"
## A Hierarchical state machine that controls a fighter's situation
##
## @desc:
##		Contains multiple states, each holding a ActionFSM, representing a fighter's situation, connected in a graph.
##		State transitions occur automatically based on the advance condition.
##		A situtation can be thought of as the actions available to a fighter based on their circumstances.
##		For instance you can distinguish what actions a fighter can take on ground, from the actions they can take in the air.

# Import
const AutoAdvanceTransition = preload("transitions/auto_advance_transition.gd")
const SituationState = preload("situation_state.gd")


func set_condition_evaluator(evaluation_func: FuncRef) -> void:
	.set_condition_evaluator(evaluation_func)

	for state in get_all_states_obj():
		if state is SituationState:
			state.action_fsm.set_condition_evaluator(evaluation_func)


func get_action_fsm() -> Resource: # ActionFSM
	var current_state = get_current_state_obj()
	if current_state is SituationState:
		return current_state.action_fsm
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
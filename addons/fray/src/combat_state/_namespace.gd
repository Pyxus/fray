class_name FrayCombatState
extends Object

func _init() -> void:
	assert(false, "The 'FrayCombatState' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")
	free()

const ActionGraph = preload("action_graph.gd")
const CombatFSM = preload("combat_fsm.gd")
const ActionFSM = preload("action_fsm.gd")
const ActionState = preload("action_state.gd")
const InputTransition = preload("transitions/input_transition.gd")
const EvaluatedCondition = preload("transitions/conditions/evaluated_condition.gd")
const InputCondition = preload("transitions/conditions/input_condition.gd")
const InputSequenceCondition = preload("transitions/conditions/input_sequence_condition.gd")
const InputButtonCondition = preload("transitions/conditions/input_button_condition.gd")

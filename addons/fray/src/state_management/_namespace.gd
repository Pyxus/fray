extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instanced")
	free()

const CombatStateMachine = preload("combat_state_machine.gd")
const CombatSituation = preload("combat_situation.gd")
const CombatState = preload("combat_state.gd")
const InputTransition = preload("transitions/input_transition.gd")
const EvaluatedCondition = preload("transitions/conditions/evaluated_condition.gd")
const InputCondition = preload("transitions/conditions/input_condition.gd")
const InputSequenceCondition = preload("transitions/conditions/input_sequence_condition.gd")
const InputButtonCondition = preload("transitions/conditions/input_button_condition.gd")
const CombatSituationBuilder = preload("combat_situation_builder.gd")
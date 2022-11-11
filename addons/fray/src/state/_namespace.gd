extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instantiated")
	free()


const CombatStateMachine = preload("combat_state_machine.gd")
const StateMachine = preload("state_machine.gd")
const StateNode = preload("node/state_node.gd")
const StateNodeStateMachine = preload("node/state_node_state_machine.gd")
const StateNodeStateMachineGlobal = preload("node/state_node_state_machine_global.gd")
const Condition = preload("node/transition/condition.gd")
const InputTransition = preload("node/transition/input_transition.gd")
const InputTransitionButton = preload("node/transition/input_transition_button.gd")
const InputTransitionSequence = preload("node/transition/input_transition_sequence.gd")
const StateMachineTransition = preload("node/transition/state_machine_transition.gd")
const CombatSituationBuilder = preload("builder/combat_situation_builder.gd")
const StateMachineBuilder = preload("builder/state_machine_builder.gd")
const StateMachineGlobalBuilder = preload("builder/state_machine_global_builder.gd")

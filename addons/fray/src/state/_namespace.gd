extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instantiated")
	free()


const CombatStateMachine = preload("combat_state_machine.gd")
const StateMachine = preload("state_machine.gd")
const GraphNodeBase = preload("graph_node/graph_node_base.gd")
const GraphNodeStateMachine = preload("graph_node/graph_node_state_machine.gd")
const GraphNodeStateMachineGlobal = preload("graph_node/graph_node_state_machine_global.gd")
const Condition = preload("graph_node/transition/condition.gd")
const InputTransition = preload("graph_node/transition/input_transition.gd")
const InputTransitionButton = preload("graph_node/transition/input_transition_button.gd")
const InputTransitionSequence = preload("graph_node/transition/input_transition_sequence.gd")
const StateMachineTransition = preload("graph_node/transition/state_machine_transition.gd")
const CombatSituationBuilder = preload("builder/combat_situation_builder.gd")
const StateMachineBuilder = preload("builder/state_machine_builder.gd")
const StateMachineGlobalBuilder = preload("builder/state_machine_global_builder.gd")

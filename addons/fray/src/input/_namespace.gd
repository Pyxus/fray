class_name FrayInputNS
extends Object

func _init() -> void:
	assert(false, "The 'FrayInputNS' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")

const FrayInputMap = preload("mapping/fray_input_map.gd")
const SequenceAnalyzer = preload("sequence_analysis/sequence_analyzer.gd")
const SequenceAnalyzerTree = preload("sequence_analysis/sequence_analyzer_tree.gd")
const Sequence = preload("sequence_analysis/sequence.gd")
const InputBind = preload("mapping/binds/input_bind.gd")
const ActionInputBind = preload("mapping/binds/action_input_bind.gd")
const JoystickInputBind = preload("mapping/binds/joystick_input_bind.gd")
const JoystickAxisInputBind = preload("mapping/binds/joystick_input_bind.gd")
const KeyboardInputBind = preload("mapping/binds/keyboard_input_bind.gd")
const MouseInputBind = preload("mapping/binds/mouse_input_bind.gd")
const ConditionalInput = preload("mapping/conditional_input.gd")
const CombinationInput = preload("mapping/combination_input.gd")

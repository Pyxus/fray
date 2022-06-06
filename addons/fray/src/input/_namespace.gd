class_name FrayInput
extends Object

func _init() -> void:
	assert(false, "The 'FrayInput' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")

const InputDetector = preload("input_detector.gd")
const InputSet = preload("input_data/input_set.gd")
const SequenceAnalyzer = preload("sequence_analysis/sequence_analyzer.gd")
const SequenceAnalyzerTree = preload("sequence_analysis/sequence_analyzer_tree.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")
const DetectedInputSequence = preload("detected_inputs/detected_input_sequence.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")
const SequenceData = preload("sequence_analysis/sequence_data.gd")
const InputBind = preload("input_data/binds/input_bind.gd")
const ActionInputBind = preload("input_data/binds/action_input_bind.gd")
const JoystickInputBind = preload("input_data/binds/joystick_input_bind.gd")
const JoystickAxisInputBind = preload("input_data/binds/joystick_input_bind.gd")
const KeyboardInputBind = preload("input_data/binds/keyboard_input_bind.gd")
const MouseInputBind = preload("input_data/binds/mouse_input_bind.gd")
const ConditionalInput = preload("input_data/conditional_input.gd")
const CombinationInput = preload("input_data/combination_input.gd")

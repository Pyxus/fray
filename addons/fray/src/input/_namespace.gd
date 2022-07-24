class_name FrayInputNS
extends Object

func _init() -> void:
	assert(false, "The 'FrayInputNS' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")

const FrayInput = preload("fray_input.gd")
const FrayInputMap = preload("fray_input_map.gd")
const FrayInputEvent = preload("events/fray_input_event.gd")
const FrayInputEventCombination = preload("events/fray_input_event_combination.gd")
const FrayInputEventConditional = preload("events/fray_input_event_conditional.gd")
const SequenceAnalyzer = preload("sequence_analyzer.gd")
const SequenceAnalyzerTree = preload("sequence_analyzer_tree.gd")
const Sequence = preload("sequence_data/sequence.gd")
const SequenceCollection = preload("sequence_data/sequence_collection.gd")
const FrayInputData = preload("input_data/fray_input_data.gd")
const InputBind = preload("input_data/input_bind.gd")
const ActionInputBind = preload("input_data/action_input_bind.gd")
const JoyButtonInputBind = preload("input_data/joy_button_input_bind.gd")
const JoyAxisInputBind = preload("input_data/joy_axis_input_bind.gd")
const KeyInputBind = preload("input_data/key_input_bind.gd")
const MouseInputBind = preload("input_data/mouse_button_input_bind.gd")
const ConditionalInput = preload("input_data/conditional_input.gd")
const CombinationInput = preload("input_data/combination_input.gd")

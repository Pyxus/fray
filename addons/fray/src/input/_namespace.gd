extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instanced")
	free()

const FrayInputEvent = preload("fray_input_event.gd")
const SequenceAnalyzer = preload("sequence_analyzer.gd")
const SequenceList = preload("sequence/sequence_list.gd")
const SequencePath = preload("sequence/sequence_path.gd")
const ComplexInputFactory = preload("input_data/complex_input_factory.gd")
const CombinationInput = preload("input_data/combination_input.gd")
const InputBind = preload("input_data/binds/input_bind.gd")
const InputBindAction = preload("input_data/binds/input_bind_action.gd")
const InputBindFrayAction = preload("input_data/binds/input_bind_fray_action.gd")
const InputBindJoyAxis = preload("input_data/binds/input_bind_joy_axis.gd")
const InputBindJoyButton = preload("input_data/binds/input_bind_joy_button.gd")
const InputBindKey = preload("input_data/binds/input_bind_key.gd")
const InputBindMouseButton = preload("input_data/binds/input_bind_mouse_button.gd")
const InputBindSimple = preload("input_data/binds/input_bind_simple.gd")
const VirtualDevice = preload("virtual_device.gd")

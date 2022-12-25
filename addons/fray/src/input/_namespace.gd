extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instantiated")
	free()

const Controller = preload("controller.gd")
const FrayInputEvent = preload("events/fray_input_event.gd")
const SequenceAnalyzer = preload("sequence_analyzer.gd")
const SequenceList = preload("sequence/sequence_list.gd")
const SequencePath = preload("sequence/sequence_path.gd")
const CompositeInputFactory = preload("device/input_data/composite_input_factory.gd")
const CombinationInput = preload("device/input_data/combination_input.gd")
const InputBind = preload("device/input_data/binds/input_bind.gd")
const InputBindAction = preload("device/input_data/binds/input_bind_action.gd")
const InputBindFrayAction = preload("device/input_data/binds/input_bind_fray_action.gd")
const InputBindJoyAxis = preload("device/input_data/binds/input_bind_joy_axis.gd")
const InputBindJoyButton = preload("device/input_data/binds/input_bind_joy_button.gd")
const InputBindKey = preload("device/input_data/binds/input_bind_key.gd")
const InputBindMouseButton = preload("device/input_data/binds/input_bind_mouse_button.gd")
const InputBindSimple = preload("device/input_data/binds/input_bind_simple.gd")
const VirtualDevice = preload("device/virtual_device.gd")

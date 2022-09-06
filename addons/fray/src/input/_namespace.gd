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

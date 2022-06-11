extends Reference
## Abstract class used by input detector to detect input sequences.

# Imports
const FrayInputEvent = preload("../fray_input_event.gd")
const InputRequirement = preload("input_requirement.gd")
const SequenceCollection = preload("sequence_collection.gd")

## Emmited when a sequence match is found.
##
## sequence_name is the name of the sequence.
##
## inputs is an array of input ids that was used to match the sequence.
signal match_found(sequence_name, inputs)

## Used to feed next inputs to analyzer.
func read(input_event: FrayInputEvent) -> void:
	_read(input_event)

## Returns true if the given sequence of FrayInputEvents meets the input requirements of the sequence data.
func is_match(fray_input_events: Array, input_requirements: Array) -> bool:
	if fray_input_events.size() != input_requirements.size():
		return false
	
	for i in len(input_requirements):
		var input_event: FrayInputEvent = fray_input_events[i]
		var input_requirement: InputRequirement = input_requirements[i]
		
		if input_event.id != input_requirement.input_id:
			return false

		if not input_event.pressed and input_event.get_time_held() < input_requirement.min_time_held:
			return false
		
		if i > 0:
			var time_since_last_input := input_event.get_time_between(fray_input_events[i - 1])
			if input_requirement.max_delay >= 0 and time_since_last_input > input_requirement.max_delay:
				return false

	return true

## Abstract method used to initialize scanner with given SequenceCollection
func initialize(sequence_collection: SequenceCollection) -> void:
	push_error("Method not implemented.")

## Virtual method used to implement analyzer's read behavior
func _read(input_event: FrayInputEvent) -> void:
	push_error("Method not implemented.")

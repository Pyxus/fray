extends Resource
## Abstract class used by input detector to detect input sequences.

# Imports
const DetectedInputButton = preload("../detected_inputs/detected_input_button.gd")
const SequenceData = preload("sequence_data.gd")
const InputRequirement = preload("input_requirement.gd")

## Emmited when a sequence match is found.
##
## sequence_name is the name of the sequence.
##
## sequence is an array of input ids that was used to match the sequence.
signal match_found(sequence_name, sequence)

## Abstract method used to read next input.
func read(input_button: DetectedInputButton) -> void:
	push_error("No read implementation provided.")

## Abstract method used to add sequence for scanner to recognize.
func add_sequence(sequence_data: SequenceData) -> void:
	push_error("No add implementation provided.")

## Returns true if the given sequence of DetectedInputs meets the input requirements of the sequence data.
func is_match(detected_input_buttons: Array, input_requirements: Array) -> bool:
	if detected_input_buttons.size() != input_requirements.size():
		return false
	
	for i in len(input_requirements):
		var detected_input: DetectedInputButton = detected_input_buttons[i]
		var input_requirement: InputRequirement = input_requirements[i]
		
		if detected_input.id != input_requirement.input_id:
			return false

		if not detected_input.is_pressed and detected_input.time_held < input_requirement.min_time_held:
			return false
		
		if i > 0:
			var time_since_last_input := detected_input.get_time_between(detected_input_buttons[i - 1]) / 1000.0
			if input_requirement.max_delay >= 0 and time_since_last_input > input_requirement.max_delay:
				return false

	return true

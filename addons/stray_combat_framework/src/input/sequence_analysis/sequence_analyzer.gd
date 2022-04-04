extends Resource
## Abstract class used by input detector to detect input sequences.

signal match_found(sequence_name, sequence)

#enums

const SequenceData = preload("sequence_data.gd")
const DetectedInputButton = preload("../detected_inputs/detected_input_button.gd")

#preloaded scripts and scenes

#exported variables

#public variables

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

## Abstract class used to read next input.
func read(input_button: DetectedInputButton) -> void:
	push_error("No read implementation provided.")

## Abstract class used to add sequence for scanner to recognize.
func add_sequence(sequence_data: SequenceData) -> void:
	push_error("No add implementation provided.")

#private methods
	
#signal methods

#inner class

extends Resource
## docstring

signal match_found(sequence_name)

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

func read(input_button: DetectedInputButton) -> void:
	push_error("No read implementation provided.")


func add_sequence(sequence_data: SequenceData) -> void:
	push_error("No add implementation provided.")

#private methods
	
#signal methods

#inner class

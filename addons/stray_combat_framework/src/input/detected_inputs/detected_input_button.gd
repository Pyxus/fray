extends "detected_input.gd"
## Detected input button.
## Bind, combination, and conditional inputs are all considered to be input buttons.

#signals

#enums

const InputBind = preload("../binds/input_bind.gd")

#preloaded scripts and scenes

#exported variables

## Id of the detected input
var id: int
## Amount of time the input was held. Will only be non-zero for released inputs.
var time_held: float
## If true the input button is pressed. If false, the detected button is released.
var is_pressed: bool
## Contains the bind used in this input
var bind: InputBind #TODO: Replace with binds array for combination inputs

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

#public methods

#private methods

#signal methods

#inner classes

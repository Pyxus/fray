extends "detected_input.gd"
## Detected input button.
##
## @desc:
##      Bind, combination, and conditional inputs are all considered to be input buttons.


## Id of the detected input
var id: int

## Amount of time in miliseconds the input was held. Will only be non-zero for released inputs.
var time_held: float

## If true the input button is pressed. If false, the detected button is released.
var is_pressed: bool

## Contains the input bind ids that triggered this input
var bind_ids: PoolIntArray

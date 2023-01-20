class_name FrayInputRequirement
extends Resource
## Used by SequencePath to describe an input sequence.

## The name of the input
var input: StringName

## The minimum amount of time that the input must be held.
var min_time_held: float

## The max delay between this input and the last.
var max_delay: float

## Returns [code]true[/code] if the is a charge input.[br]
##
## An input is considered a charge input if its [member min_time_held] is greater than 0.
func is_charge_input() -> bool:
	return min_time_held > 0

extends Resource
## Used by SequencePath to describe an input sequence.

var input: String
var min_time_held: float
var max_delay: float

func is_charge_input() -> bool:
    return min_time_held > 0
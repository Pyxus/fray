extends Resource
## Input which changes what bind input it represents based on string conditions.
##
## @desc:
##      Useful for creating motion inputs which change based on what side a combatant is in 2D fighting games.

var input_by_condition: Dictionary # Dictionary<string, int>
var default_input: int

extends "fray_input_data.gd"
## Input which changes what bind input it represents based on string conditions.
##
## @desc:
##      Useful for creating motion inputs which change based on what side a combatant is in 2D fighting games.

var input_by_condition: Dictionary # Dictionary<string, string>
var default_input: String

extends Resource
## Class representing condition

# Imports
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

## Returns true if the detected input satisfies this condition
func is_satisfied_by(detected_input: DetectedInput) -> bool:
	return false

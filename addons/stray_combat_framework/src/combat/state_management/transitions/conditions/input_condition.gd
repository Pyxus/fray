extends Resource

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

var InputCondition = load("res://addons/stray_combat_framework/src/combat/state_management/input_data/input_condition.gd")


func is_satisfied_by(detected_input: DetectedInput) -> bool:
	return false

	
func equals(input_condition: Reference) -> bool:
	assert(input_condition is InputCondition, "The passed argument needs to be of type InputCondition")
	return false

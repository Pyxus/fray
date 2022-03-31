extends Resource

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

func is_satisfied_by(detected_input: DetectedInput) -> bool:
	return false

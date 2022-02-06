extends Resource

var InputData = load("res://addons/stray_combat_framework/src/combat/state_management/transitions/input_data/input_data.gd")

func equals(input_data: Reference) -> bool:
	assert(input_data is InputData, "The passed argument needs to be of type InputData")
	return false

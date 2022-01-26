extends "fighter_state.gd"

var _condition_dict: Dictionary

func extend(fighter_state: Reference) -> void:
	push_warning("RootFighterState is unable to extend another state.")


func is_condition_true(condition: String) -> bool:
	if _condition_dict.has(condition):
		return _condition_dict[condition]
	
	return false
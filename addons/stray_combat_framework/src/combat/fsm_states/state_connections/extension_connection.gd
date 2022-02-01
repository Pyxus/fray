extends "state_connection.gd"


func is_identical_to(state_connection: Reference) -> bool:
	.is_identical_to(state_connection)
	
	if state_connection.to != null:
		return state_connection.to.active_condition == to.active_condition
		
	return false

extends "res://addons/fray/lib/state_machine/state.gd"
## State representing a fighter's action

## Array of tags assigned to this state
var tags: PoolStringArray


func _init(state_tags: PoolStringArray = []) -> void:
	tags = state_tags

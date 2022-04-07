extends "res://addons/stray_combat_framework/lib/state_machine/state.gd"
## State representing a fighter's situation

# Imports
const ActionFSM = preload("action_fsm.gd")

## ActionFSM contained by this state
var action_fsm: ActionFSM

func _init(state_action_fsm: ActionFSM = null) -> void:
    action_fsm = state_action_fsm
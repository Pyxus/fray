extends "idle_state.gd"

func extend(fighter_state: Reference) -> void:
    push_warning("RootIdleState is unable to extend another state.")
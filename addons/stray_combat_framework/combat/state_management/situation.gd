extends Reference

signal state_advanced(new_state, transition_animation)
signal state_reverted(new_state, transition_animation)

const DetectedInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_input.gd")
const DetectedSequence = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_sequence.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/input/detected_inputs/detected_virtual_input.gd")

const FighterState = preload("states/fighter_state.gd")
const RootFighterState = preload("states/root_fighter_state.gd")

var _root := RootFighterState.new()
var _current_state: FighterState = _root
var _advancement_route: Array


func update(detected_input: DetectedInput = null) -> void:
    var next_state := _current_state.get_next_state(detected_input)

    if next_state != null:
        advance_to(next_state)

    if _current_state.animation.empty() and not _root.is_condition_true(_current_state.active_condition):
        revert_to_active_state()


func get_root() -> RootFighterState:
    return _root


func get_current_state() -> FighterState:
    return _current_state

    
func advance_to(fighter_state: FighterState) -> void:
    if not _current_state.has_connection_to(fighter_state):
        push_warning("Failed to advance to state '%s'. State has no connection to the current state.")
        return

    var connection := _current_state.get_connection(fighter_state)
    _current_state = fighter_state
    
    if _advancement_route.empty():
        _advancement_route.append(_root)

    _advancement_route.append(fighter_state)
    emit_signal("state_advanced", fighter_state, connection.transition_animation)


func revert_to_active_state() -> void:
    if not _advancement_route.empty():
        var most_recent_state: FighterState = _advancement_route.back()
        var transition_animation := ""

        while not _advancement_route.empty() and not _root.is_condition_true(most_recent_state.active_condition):
            most_recent_state = _advancement_route.pop_back()

            if not _advancement_route.empty():
                var state_before_most_recent: FighterState = _advancement_route.back()
                var connection := state_before_most_recent.get_connection(most_recent_state)
                transition_animation = connection.transition_animation
        _current_state = most_recent_state

        emit_signal("state_reverted", _current_state, transition_animation)


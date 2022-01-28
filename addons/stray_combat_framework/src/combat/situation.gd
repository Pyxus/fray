extends Reference

signal state_advanced(new_state, transition_animation)
signal state_reverted(new_state, transition_animation)

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const DetectedVirtualInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_virtual_input.gd")
const InputDetector = preload("res://addons/stray_combat_framework/src/input/input_detector.gd")

const FighterState = preload("states/fighter_state.gd")
const RootFighterState = preload("states/root_fighter_state.gd")
const InputData = preload("states/input_data/input_data.gd")

var _root: RootFighterState
var _current_state: FighterState
var _advancement_route: Array


func _init() -> void:
	_root = RootFighterState.new(self)
	_current_state = _root


func update(detected_input: DetectedInput = null) -> void:
	var next_state := _current_state.get_next_chained_state(detected_input)

	if next_state == null:
		next_state = _current_state.get_next_global_state(detected_input)
		if next_state != null:
			_advancement_route.clear()
			_advancement_route.append(_root)
			_advancement_route.append(next_state)
			_current_state = next_state
			emit_signal("state_advanced", next_state, "")

	if next_state == null:
		next_state = _current_state.get_next_extender_state(detected_input)

	if next_state == null:
		next_state = _current_state.get_extended_state_next_state(detected_input)
	
	if next_state != null:
		advance_to(next_state)

	var extending_state: FighterState = _current_state.get_extending_state()

	if extending_state != null:
		if not _root.is_condition_true(extending_state.active_condition):
			revert_to_active_state()

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

				if connection != null:
					transition_animation = connection.transition_animation
		_current_state = most_recent_state

		emit_signal("state_reverted", _current_state, transition_animation)

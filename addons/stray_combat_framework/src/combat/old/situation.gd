extends Reference

signal state_advanced(new_state, transition_animation)
signal state_reverted(new_state, transition_animation)

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

const StateConnection = preload("fsm_states/state_connections/state_connection.gd")
const ChainConnection = preload("fsm_states/state_connections/chain_connection.gd")
const ExtensionConnection = preload("fsm_states/state_connections/extension_connection.gd")
const FighterState = preload("fsm_states/fighter_state.gd")
const RootFighterState = preload("fsm_states/root_fighter_state.gd")
const InputData = preload("fsm_states/state_connections/input_data/input_data.gd")

var _root: RootFighterState
var _current_state: FighterState
var _advancement_route: Array


func _init(root_animation: String) -> void:
	_root = RootFighterState.new(self, root_animation)
	_current_state = _root


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_root._associated_states.clear()


func advance(detected_input: DetectedInput = null) -> void:
	var next_connection: StateConnection = _current_state.get_next_connection(detected_input)
	if next_connection != null:
		if next_connection is ChainConnection and _root.has_global_chain(next_connection):
			_advancement_route.clear()
			_advancement_route.append(next_connection)

		_current_state = next_connection.to
		
		if next_connection is ExtensionConnection:
			emit_signal("state_advanced", _current_state, next_connection.transition_animation_to)
		else:
			emit_signal("state_advanced", _current_state, "")
	
	if _current_state.is_extender():
		var extended_state: FighterState = _current_state.get_extended_state()
		if not _root.is_condition_true(extended_state.active_condition):
			revert_to_active_state()
	elif _current_state.animation.empty():
		revert_to_active_state()


func revert_to_active_state() -> void:
	if not _advancement_route.empty():
		var recent_connection: StateConnection = _advancement_route.back()
		var recent_state: FighterState = recent_connection.to
		var transition_animation: String = ""
		
		while not _advancement_route.empty() and not _root.is_condition_true(recent_state.active_condition):
			recent_connection = _advancement_route.pop_back()
			recent_state = recent_connection.to
			
			if recent_connection is ExtensionConnection:
				transition_animation = recent_connection.transition_animation_from
		
		_current_state = recent_state
		emit_signal("state_reverted", _current_state, transition_animation)


func reset() -> void:
	_current_state = _root
	_advancement_route.clear()


func get_root() -> RootFighterState:
	return _root


func get_current_state() -> FighterState:
	return _current_state

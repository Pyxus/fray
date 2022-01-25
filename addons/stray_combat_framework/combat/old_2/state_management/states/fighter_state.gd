extends Node

var animation: String
var transition_animation: String
var extending_state: Reference setget extend
var previous_state: Reference

var _next_states: Array


func extend(fighter_state: Reference) -> void:
	if fighter_state == self:
		push_warning("FighterState can not extend it self.")
		return

	if fighter_state.extending_state == self:
		push_warning("Failed to extend state. FighterState '%s' already extends state '%s'. Cylical extensions are not allowed." % [fighter_state, self])
		return

	extending_state = fighter_state


func add_next_state(fighter_state: Reference) -> void:
	if _next_states.has(fighter_state):
		push_warning("FighterState '%s' has already been added" % fighter_state)
		return

	for next_state in _next_states:
		"""
		if _is_same_input_data(action_state.input, chained_action_state.input):
			push_warning("ActionState with identical input is already chained")
			return
		"""
		pass
	
	_next_states.append(fighter_state)

	if fighter_state != self:
		fighter_state.previous_state = self


func remove_next_state(fighter_state: Reference) -> void:
	if _next_states.has(fighter_state):
		_next_states.erase(fighter_state)


func get_next_action() -> void:
	pass
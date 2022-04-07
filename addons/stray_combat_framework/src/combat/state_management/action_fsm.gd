extends "combat_fsm.gd"
## State machine that controls fighter's actions
##
## @desc:
##		Contains multiple states representing a fighter's actions, connected in a graph. 
##		State transitions occur based on states reachable using the given input.
##
##		ActionFSM has API for creating global transitions within the state machine.
##		Global transitions is a convinience feature that allows you to automatically connect states based on transition rules.
##		Transition rules make use of the tags defined in an action state.
##		States with a given from_tag will automatically have a transition setup for gobal states with a given to_tag.
##		This is useful for setting up actions that need to be available from multiple states in the state machine without needing to manually connect them.
##		For example, many fighting games all all moves tagged as "normal" to transition into moves tagged as "special".

# Imports
const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")
const InputTransition = preload("transitions/input_transition.gd")
const ActionState = preload("action_state.gd")

## Time since the last detected input in seconds
var time_since_last_input: float

var _global_transitions: Dictionary # Dictionary<String, Transition>
var _global_transition_rules: Dictionary # Dictionary<String, String[]>

## Adds global transition rule based on tags.
func add_global_transition_rule(from_tag: String, to_tag: String) -> void:
	if not _global_transition_rules.has(from_tag):
		_global_transition_rules[from_tag] = []

	_global_transition_rules[from_tag].append(to_tag)

## Returns true if global transition rule exists
func has_global_transition_rule(from_tag: String, to_tag: String) -> bool:
	return _global_transition_rules.has(from_tag) and _global_transition_rules[from_tag].has(to_tag)

## Removes specifc global transition rule from one tag to another
func remove_global_transition_rule(from_tag: String, to_tag: String) -> void:
	if has_global_transition_rule(from_tag, to_tag):
		_global_transition_rules.erase(to_tag)

## Removes all global transitions from given tag
func delete_global_transition_rule(from_tag: String) -> void:
	if _global_transition_rules.has(from_tag):
		_global_transition_rules.erase(from_tag)

## Adds global transition to a state
func add_global_transition(to_state: String, input_transition: InputTransition) -> void:
	if not has_state(to_state):
		push_warning("Failed to add global transition. State '%s' does not exist." % to_state)
		return
	
	_global_transitions[to_state] = input_transition

## Returns true if a state has a global transition
func has_global_transition(to_state: String) -> bool:
	return _global_transitions.has(to_state)

## Removes a state's global transition
func remove_global_transition(to_state: String) -> void:
	if not has_global_transition(to_state):
		push_warning("Failed to remove global transition. State '%s' does not have a global transition")
		return

	if has_global_transition(to_state):
		_global_transitions.erase(to_state)


func remove_state(name: String) -> bool:
	if not .remove_state(name):
		return false

	if has_global_transition(name):
		_global_transitions.erase(name)

	return true


func rename_state(name: String, new_name: String) -> bool:
	if not .rename_state(name, new_name):
		return false
	
	if has_global_transition(name):
		var transition: InputTransition = _global_transitions[name]
		remove_global_transition(name)
		add_global_transition(new_name, transition)

	return true

## Returns an array of transition data containing the next global transitions avaiable to a state based on the transition rules.
func get_next_global_transitions(from: String) -> Array: # TransitionData[]
	var transitions: Array
	var from_state := get_state(from) as ActionState
	
	if from_state == null:
		return transitions
	
	for from_tag in from_state.tags:
		if _global_transition_rules.has(from_tag):
			var to_tag_rules: Array = _global_transition_rules[from_tag]
			
			for to_state_name in _global_transitions:
				var to_state := get_state(to_state_name) as ActionState
				
				if to_state == null:
					continue

				for to_tag in to_state.tags:
					if to_tag in to_tag_rules:
						var td := TransitionData.new()
						td.from = from
						td.to = to_state_name
						td.transition = _global_transitions[to_state_name]
						transitions.append(td)					
						break
	return transitions


func get_action_fsm() -> Resource: # ActionFSM
	return self


func _get_next_state(input: Object = null) -> String:
	if input is DetectedInput:
		var next_global_transitions := get_next_global_transitions(current_state)
		var next_transitions := get_next_transitions(current_state)
		
		for transition_data in next_global_transitions + next_transitions:
			var transition := transition_data.transition as InputTransition
			if transition == null:
				continue

			if transition.input_condition.is_satisfied_by(input) and time_since_last_input >= transition.min_input_delay:
				for transition_condition in transition.prerequisites:
					if not _is_condition_true(transition_condition):
						return ""

				return transition_data.to

	return "";

#signal methods

#inner classes

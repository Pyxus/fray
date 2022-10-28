extends "state_compound.gd"
## State machine whose states represent the set of actions available to a combatant
## In a given situation.
##
## @desc:
##		Contains multiple states representing a combatant's actions, and
##		the states available to them from a given state. 
##		State transitions occur based on user defined inputs and conditions.
##
##		Global transitions are a convinience feature that allows you to automatically 
##		connect states based on global transition rules.
##		Transition rules make use of the tags defined in a combat state.
##		States with a given 'from_tag' will automatically have a transition 
##		setup for gobal states with a given 'to_tag'.
##		This is useful for setting up actions that need to be available from 
##		multiple states in the state machine without needing to manually connect them.
##		For example, in many fighting games all moves tagged as "normal" may 
##		transition into moves tagged as "special".

## Type: Dictionary<String, Transition>
## Hint: <from state, >
var _global_transitions: Dictionary

## Type: Dictionary<String, String[]>
## Hint: <from tag, to tags
var _global_transition_rules: Dictionary

## Type: Dictionary<String, String[]>
## Hint: <state name, tags>
var _tags_by_state: Dictionary

func _init() -> void:
    connect("state_removed", self, "_on_state_removed")
    connect("state_renamed", self, "_on_state_renamed")

## Sets the tags associated with a state if the state exists.
func set_state_tags(state: String, tags: PoolStringArray) -> void:
    if _err_state_does_not_exist(state, "Failed to set tags. "):
        return
    
    _tags_by_state[state] = tags

## Gets the tags associated with a state if the state exists.
func get_state_tags(state: String) -> PoolStringArray:
    if _err_state_does_not_exist(state, "Failed to get tags. "):
        return PoolStringArray([])

    if not _tags_by_state.has(state):
        return PoolStringArray([])
    
    return _tags_by_state[state]

## Adds global transition rule based on tags.
func add_global_transition_rule(from_tag: String, to_tag: String) -> void:
	if not _global_transition_rules.has(from_tag):
		_global_transition_rules[from_tag] = []

	_global_transition_rules[from_tag].append(to_tag)

## Removes a state's global transition
func remove_global_transition(to_state: String) -> void:
	if not has_global_transition(to_state):
		push_warning("Failed to remove global transition. State '%s' does not have a global transition")
		return

	if has_global_transition(to_state):
		_global_transitions.erase(to_state)

## Returns true if a state has a global transition
func has_global_transition(to_state: String) -> bool:
	return _global_transitions.has(to_state)

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


func _get_next_global_transitions(from: String) -> Array:
    if _err_state_does_not_exist(from, "Failed to get next transition. "):
        return []
    
    var transitions: Array
    
    for from_tag in get_state_tags(from):
        if _global_transition_rules.has(from_tag):
            var to_tag_rules: Array = _global_transition_rules[from_tag]

            for to_state in _global_transitions:
                if get_state_tags(from) in to_tag_rules:
                    transitions.append(_global_transitions[to_state])

    return transitions


func get_next_transitions(from: String) -> Array:
    return .get_next_transitions(from) + _get_next_global_transitions(from)


func _on_state_removed(state: String) -> void:
    if _tags_by_state.has(state):
        _tags_by_state.erase(state)


func _on_state_renamed(old_name: String, new_name: String) -> void:
    if _tags_by_state.has(old_name):
        var tags: PoolStringArray = _tags_by_state[old_name]
        _tags_by_state.erase(old_name)
        _tags_by_state[new_name] = tags
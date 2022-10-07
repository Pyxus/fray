extends "res://addons/fray/lib/state_machine/state_machine.gd"
## State machine that represents the set of actions available to a combatant
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

const BufferedInput = preload("buffered_input/buffered_input.gd")
const InputTransition = preload("transitions/input_transition.gd")
const InputCondition = preload("transitions/conditions/input_condition.gd")
const CombatState = preload("combat_state.gd")
const CombatSituationBehavior = preload("combat_situation_behavior.gd")

## Time since the last detected input in seconds
var time_since_last_input: float

## Type: Dictionary<String, Transition>
var _global_transitions: Dictionary

## Type: Dictionary<String, String[]>
var _global_transition_rules: Dictionary

## Type: func(string) -> bool
var _condition_evaluator_func: FuncRef


func _init() -> void:
	connect("state_changed", self, "_on_state_changed")



## Adds combat state to situation
func add_combat_state(name: String, tags: PoolStringArray = []) -> void:
	add_state(name, CombatState.new(tags))
	
## Sets the condition evaluator function used by the finite state machine
func set_condition_evaluator(evaluation_func: FuncRef) -> void:
	_condition_evaluator_func = evaluation_func

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

## Adds global input transition to a state
func add_global_input_transition(to_state: String, input_condition: InputCondition, prereqs: Array = [], min_input_delay: float = 0) -> void:
	if not has_state(to_state):
		push_warning("Failed to add global transition. State '%s' does not exist." % to_state)
		return
	
	_global_transitions[to_state] = InputTransition.new(input_condition, prereqs, min_input_delay)

## Adds transition from state to state based on input
func add_input_transition(from: String, to: String, input_condition: InputCondition, prereqs: Array = [], min_input_delay: float = 0) -> void:
	add_transition(
		from, 
		to, 
		InputTransition.new(input_condition, prereqs, min_input_delay))

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
		_global_transitions[new_name] = transition

	return true

## Returns an array of transition data containing the next global transitions avaiable to a state based on the transition rules.
func get_next_global_transitions(from: String) -> Array: # TransitionData[]
	var transitions: Array
	
	if not has_state(from):
		return transitions
		
	var from_state := get_state(from) as CombatState
	
	if from_state == null:
		return transitions
	
	for from_tag in from_state.tags:
		if _global_transition_rules.has(from_tag):
			var to_tag_rules: Array = _global_transition_rules[from_tag]
			
			for to_state_name in _global_transitions:
				var to_state := get_state(to_state_name) as CombatState
				
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


func _get_next_state_impl(input = null) -> String:
	if input is BufferedInput:
		var next_global_transitions := get_next_global_transitions(get_current_state_name())
		var next_transitions := get_next_transitions(get_current_state_name())
		
		for transition_data in next_global_transitions + next_transitions:
			var transition := transition_data.transition as InputTransition
			if transition == null:
				continue

			if transition.input_condition.is_satisfied_by(input) and time_since_last_input >= transition.min_input_delay:
				for prereq in transition.prerequisites:
					if not _is_condition_true(prereq.condition):
						return ""

				return transition_data.to
	else:
		push_error("Failed to get next input. Expect input of type 'BufferedInput' instead got '%s'" % input)

	return "";


func _is_condition_true(condition: String) -> bool:
	if _condition_evaluator_func == null or not _condition_evaluator_func.is_valid():
		push_error("Failed to evaluate condition '%s'. Condition evaluator function is either nor set or no longer valid." % condition)
		return false
		
	return _condition_evaluator_func.call_func(condition)
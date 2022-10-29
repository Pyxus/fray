extends "state.gd"
## Generic compound state class
##
## @desc:
##		This state is it self a state machine containing multiple sub states.

## Emitted when a state is added to the state machine
##
## `state: String` is the name of the state
signal state_added(state)

## Emitted when a state is removed from the state machine
##
## `state: String` is the name of the state
signal state_removed(state)

## Emitted when a state is renamed
##
## `old_name: String` is the state's previous name
##
## `new_name: String` is the state's new name
signal state_renamed(old_name, new_name)

## Emitted when the state object asscited with a state is replaced
##
## `state: String` is the name of the state
signal state_replaced(state)

## Emitted when a transition is added to the state machine
##
## `from: String` is the state the transition starts from
##
## `to: String` is the state the transition goes to
signal transition_added(from, to)

## Emitted when a transition is added to the state machine
##
## `from: String` is the state the transition starts from
##
## `to: String` is the state the transition goes to
signal transition_removed(from, to)

## Emitted when the current state is changes
##
## `from: String` is the previous state
##
## `to: String` is the current state
signal transitioned(from, to)

const Transition = preload("transition/transition.gd")

## Type: Dictionary<String, bool>
## Hint: <condition name, condition status>
var _conditions: Dictionary

var start_state: String setget set_start_state
var end_state: String setget set_end_state

## Type: Dictionary<String, State>
## Hint: <state name, state obj>
var _states_by_name: Dictionary

## Type: Transition[]
var _transitions: Array

var _current_state: String


func _enter_impl(args: Dictionary) -> void:
	start(args)


func _process_impl(delta: float) -> void:
	var current_state := get_current_state()
	if current_state != null:
		current_state._process_impl(delta)


func _physics_process_impl(delta: float):
	var current_state := get_current_state()
	if current_state != null:
		current_state._physics_process_impl(delta)

## Alias for 'go_to(start_state, args)'
func start(args: Dictionary = {}) -> void:
	if start_state.empty():
		push_error("Failed to start. No start state set")
		return
	go_to(start_state, args)

## Adds a child state to this compound state
func add_state(name: String, state: Reference) -> void:
	if name.empty():
		push_error("failed to add state. State name can not be empty.")
		return

	if _states_by_name.has(name):
		push_error("Failed to add state. State with name %s already exists" % name)
		return
	
	if state.has_parent():
		push_error("Failed to add state. State object already belongs to parent state %s" % _states_by_name._parent_ref.get_ref())
		return
	
	_states_by_name[name] = state

	if _states_by_name.size() == 1:
		start_state = name
	
	emit_signal("state_added", name)

## Remove child state from this compound state if it exists.
func remove_state(name: String) -> void:
	if _err_state_does_not_exist(name, "Failed to remove state. "):
		return

	if name == start_state:
		start_state = ""
	
	for transition in _transitions:
		if transition.from == name or transition.to == name:
			_transitions.erase(transition)
	
	_states_by_name.erase(name)
	emit_signal("state_removed", name)

## Rename child state if it exists.
func rename_state(name: String, new_name: String) -> void:
	if new_name.empty():
		push_warning("failed to rename state. State's new name can not be empty.")
		return

	if _err_state_does_not_exist(name, "Failed to rename state. "):
		return
	
	if has_state(name):
		push_warning("Failed to rename state. State with name %s already exists." % new_name)
		return

	for transition in _transitions:
		if transition.from == name:
			transition.from == new_name
		
		if transition.to == name:
			transition.to == new_name

	var state: Reference = _states_by_name[name]
	_states_by_name.erase(name)
	_states_by_name[new_name] = state
	emit_signal("state_renamed", name, new_name)

## Replaces a child state's state instance.
func replace_state(name: String, state: Reference) -> void:
	if _err_state_does_not_exist(name, "Failed to replace state. "):
		return

	if state.has_parent():
		push_error("Failed to replace state. Replacement state already belongs to parent state %s" % state.get_parent())
		return
	
	_states_by_name[name] = state
	emit_signal("state_replaced", name)

## Adds a transition from one child state to another.
func add_transition(transition: Transition) -> void:
	if (_err_state_does_not_exist(transition.from, "Failed to add transition. ") 
		or _err_state_does_not_exist(transition.to, "Failed to add transition. ")):
		return
	
	_transitions.append(transition)
	_transitions.sort_custom(self, "_sort_transitions")

	for condition in transition.prereqs + transition.advance_conditions:
		if not has_condition(condition.name):
			_conditions[condition.name] = false
	
	emit_signal("transition_added", transition.from, transition.to)

## Remove transition between two child states.
func remove_transition(from: String, to: String) -> void:
	if (_err_state_does_not_exist(from, "Failed to remove transition. ") 
		or _err_state_does_not_exist(to, "Failed to remove transition. ")):
		return
	
	if not has_transition(from, to):
		push_warning("Failed to remove transition. Transition from '%s' to '%s' does not exist" % [from, to])
		return
	
	var transition := get_transition(from, to)
	_transitions.erase(transition)

	for condition in transition.prereqs + transition.advance_conditions:
		var is_condition_still_used := false
		for t in _transitions:
			if condition.name in (t.prereqs + t.advance_conditions):
				is_condition_still_used = true
				break
		
		if not is_condition_still_used and has_condition(condition.name):
			_conditions.erase(condition.name)

	emit_signal("transition_removed", from, to)

## Returns true if a transtion from state to state exists
func has_transition(from: String, to: String) -> bool:
	if _err_state_does_not_exist(from) or _err_state_does_not_exist(to):
		return false
	
	for transition in _transitions:
		if transition.is_transition_of(from, to):
			return true

	return false

## Returns transition from state to state if it exists
func get_transition(from: String, to: String) -> Transition:
	if not has_transition(from, to):
		return null

	for transition in _transitions:
		if transition.is_transition_of(from, to):
			return transition

	return null

## Returns Transition[]
func get_next_transitions(from: String) -> Array:
	var transitions: Array
	for transition in _transitions:
		if transition.from == from:
			transitions.append(transition)
	return transitions

## Advances to next state reachable.
## The '_get_next_state_impl' virtual method determines if the input is accept or not.
##
## Returns true if the input was accepted and state advanced.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	var next_state := get_next_state(input)
	if not next_state.empty():
		var current_state := _current_state
		go_to(next_state, args)
		emit_signal("transitioned", current_state, _current_state)
	return false

## Returns the next state reachable
func get_next_state(input: Dictionary = {}) -> String:
	for obj in get_next_transitions(_current_state):
		var transition := obj as Transition
		if _can_switch(transition) and _can_transition(transition) and _accept_input_impl(transition, input):
			return transition.to 
	return ""

## Goes directly to the given state if it exists.
func go_to(to_state: String, args: Dictionary = {}) -> void:
	if not has_state(to_state):
		push_warning("Failed advance to state. Given state '%s' does not exist")
		return

	var prev_state_name := _current_state
	var prev_state := get_state(prev_state_name)
	if prev_state != null:
		prev_state._exit_impl()
	
	_current_state = to_state
	get_state(to_state)._enter_impl(args)

## Returns true if a condition exists in this compound state.
func has_condition(name: String) -> bool:
	return _conditions.has(name)

## Returns the status of a condition in this compound state if it exists.
func check_condition(name: String) -> bool:
	if not has_condition(name):
		push_warning("Failed to check condition. Condition with name '%s' does not exist" % name)
		return false
	return _conditions[name]

## Sets the value of a condition if it exists.
func set_condition(name: String, value: bool) -> void:
	if not has_condition(name):
		push_warning("Failed to set condition. Condition with name '%s' does not exist" % name)
		return
	_conditions[name] = value
	
## Prints this state machine in adjacency list form.
## '| c--' indicates the current state.
## '| -s-' indicates the start state.
## '| --e' indicates the end state.
func print_adj() -> void:
	var string := ""

	for state in get_state_names():
		var next_transitions := get_next_transitions(state)
		var modifiers := "%s%s%s" % [
			"c" if state == _current_state else "-",
			"s" if state == start_state else "-",
			"e" if state == end_state else "-",
		]

		if modifiers == "---":
			modifiers = ""
		else:
			modifiers = " | " + modifiers

		string += "[%s%s]" % [state, modifiers]
		
		string += " -> ["
		
		for transition in next_transitions:
			string += transition.to

			if next_transitions.back() != transition:
				string += ", "
			pass
		string += "]\n"
	
	print(string)

## Returns true if given state exists.
func has_state(name: String) -> bool:
	return _states_by_name.has(name)

## Returns an array containing the names of all states beloning to this state machine.
func get_state_names() -> PoolStringArray:
	return PoolStringArray(_states_by_name.keys())

## Returns state object based on name if it exists
func get_state(name: String) -> Reference:
	if not _states_by_name.has(name):
		return null
	return _states_by_name[name]

## Returns the name of the current state
func get_current_state_name() -> String:
	return _current_state

## Returns the state object of the current state
func get_current_state() -> Reference:
	return get_state(_current_state)

## setter for `start_state` property
func set_start_state(name: String) -> void:
	if not has_state(name):
		push_warning("Failed to set initial state. State '%s' does not exist." % name)
		start_state = ""
		return

	start_state = name

## setter for `end_state` property
func set_end_state(name: String) -> void:
	if not has_state(name):
		push_warning("Failed to set initial state. State '%s' does not exist." % name)
		start_state = ""
		return
	
	end_state = name


func _can_switch(transition: Transition) -> bool:
	return ( 
		transition.switch_mode == Transition.SwitchMode.IMMEDIATE
		and end_state == ""
		or transition.switch_mode == Transition.SwitchMode.AT_END 
		and _current_state == end_state
		)


func _can_transition(transition: Transition) -> bool:
	for prereq in transition.prereqs:
		if not has_condition(prereq.name):
			push_warning("Condition '%s' was never set" % prereq.name)
			return false

		if not check_condition(prereq.name) and not prereq.invert:
			return false
	return true


func _sort_transitions(t1: Transition, t2: Transition) -> bool:
	if t1.priority < t2.priority:
		return true
	return false


func _accept_input_impl(transition: Transition, input: Dictionary) -> bool:
	return true


func _err_state_does_not_exist(state: String, err_msg: String = "") -> bool:
	if not has_state(state):
		push_error(err_msg + "State %s does not exist." % state)
		return true
	return false
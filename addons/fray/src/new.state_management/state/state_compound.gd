extends "state.gd"
## Generic compound state class
##
## @desc:
##		This state is it self a state machine capable of housing multiple sub states.

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

const Transition = preload("../transition/transition.gd")
const TransitionConfig = preload("../transition/transition_config.gd")

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


func replace_state(name: String, state: Reference) -> void:
	if _err_state_does_not_exist(name, "Failed to replace state. "):
		return

	if state.has_parent():
		push_error("Failed to replace state. Replacement state already belongs to parent state %s" % state.get_parent())
		return
	
	_states_by_name[name] = state
	emit_signal("state_replaced", name)


func add_transition(from: String, to: String, transition_config: TransitionConfig) -> void:
	if (_err_state_does_not_exist(from, "Failed to add transition. ") 
		or _err_state_does_not_exist(to, "Failed to add transition. ")):
		return
	
	var transition := Transition.new()
	transition.from = from
	transition.to = to
	transition.config = transition_config

	_transitions.append(transition)
	_transitions.sort_custom(self, "_sort_transitions")
	emit_signal("transition_added", from, to)


func remove_transition(from: String, to: String) -> void:
	if (_err_state_does_not_exist(from, "Failed to remove transition. ") 
		or _err_state_does_not_exist(to, "Failed to remove transition. ")):
		return
	
	if not has_transition(from, to):
		push_warning("Failed to remove transition. Transition from '%s' to '%s' does not exist" % [from, to])
		return

	_transitions.erase(get_transition(from, to))
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
func advance(args: Dictionary = {}) -> bool:
	var next_state := get_next_state()
	if not next_state.empty():
		var current_state := _current_state
		go_to(next_state, args)
		emit_signal("transitioned", current_state, _current_state)
	return false

## Returns the next state reachable
func get_next_state() -> String:
	for transition in get_next_transitions(_current_state):
		if end_state != "" and _current_state != end_state and transition.config.switch_mode == TransitionConfig.SwitchMode.AT_END:
			return ""
		if transition.can_transition():
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

func _sort_transitions(a: Transition, b: Transition) -> bool:
	if a.config.priority < b.config.priority:
		return true
	return false


func _err_state_does_not_exist(state: String, err_msg: String = "") -> bool:
	if not has_state(state):
		push_error(err_msg + "State %s does not exist." % state)
		return true
	return false
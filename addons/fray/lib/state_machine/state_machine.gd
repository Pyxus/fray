extends Resource
## Generic state machine class

signal state_changed(from, to)
signal state_added(state)
signal state_removed(state)
signal state_renamed(old_name, new_name)

const ReverseableDictionary = preload("res://addons/fray/lib/data_structures/reversable_dictionary.gd")

const State = preload("state.gd")
const Transition = preload("transition.gd")
const TransitionData = preload("transition_data.gd")

var initial_state: String setget set_initial_state

var _current_state: String

## Type: Dictionary<String, State>
var _states := ReverseableDictionary.new()

## Type: TransitionData[]
var _transitions: Array

## Used to invoke current state's update procedure
func update(delta: float) -> void:
	var current_state := get_current_state()
	if current_state != null:
		current_state._update_impl(delta)

## Used to invoke current state's physics update procedure
func physics_update(delta: float) -> void:
	var current_state := get_current_state()
	if current_state != null:
		current_state._physics_update_impl(delta)


func add_state(name: String, state: State) -> void:
	if name.empty():
		push_warning("failed to add state. State name can not be empty.")
		return

	if _states.has_key(name):
		push_warning("Failed to add state. State with name %s already exists" % name)
		return
	
	if _states.has_value(state):
		push_warning("Failed to add state. State already added with name %s" % _states.get_key(state))
		return
	
	_states.add(name, state)
	
	if _states.size() == 1:
		set_initial_state(name)
		
	emit_signal("state_added", name)


func remove_state(name: String) -> bool:
	if not _states.has_key(name):
		push_warning("Failed to remove state. State %s does not exist." % name)
		return false

	if name == initial_state:
		initial_state = ""

	for transition_data in _transitions:
		if transition_data.from == name or transition_data.to == name:
			_transitions.erase(transition_data)
	
	_states.erase_key(name)
	emit_signal("state_removed", name)
	return true


func rename_state(name: String, new_name: String) -> bool:
	if new_name.empty():
		push_warning("failed to add state. State new name can not be empty.")
		return false


	if not has_state(name):
		push_error("Failed to rename state. State %s does not exist" % name)
		return false
	
	if has_state(name):
		push_error("Failed to rename state. State %s already exists." % new_name)
		return false 

	for transition_data in _transitions:
		if transition_data.from == name:
			transition_data.from == new_name
		
		if transition_data.to == name:
			transition_data.to == new_name

	var state: State = _states.get_value(name)
	_states.erase_key(name)
	_states.add(new_name, state)
	emit_signal("state_renamed", name, new_name)
	return true


func replace_state(name: String, state: State) -> void:
	if not _states.has_key(name):
		push_error("Failed to replace state. State %s does not exist" % name)
		return

	if _states.has_value(state):
		push_error("Failed to replace state. Replacement state already exists with name %s" % _states.get_key(state))
		return
	
	_states.add(name, state)


func get_all_states() -> Array: # State[]
	return _states.values()


func get_all_state_names() -> Array: # String[]
	return _states.keys()

	
func get_state(name: String) -> State:
	if not _states.has_key(name):
		push_warning("Failed to get state. State '%s' does not exist" % name)
		return null
	return _states.get_value(name)


func set_initial_state(name: String) -> void:
	if not has_state(name):
		push_warning("Failed to set initial state. State '%s' does not exist." % name)
		initial_state = ""
		return

	initial_state = name


func get_current_state_name() -> String:
	return _current_state


func get_current_state() -> State:
	if not _current_state.empty():
		return _states.get_value(_current_state)
	
	return null


func has_state(name: String) -> bool:
	return _states.has_key(name)


func add_transition(from: String, to: String, transition: Transition) -> void:
	var non_existant_states := []
	if not has_state(from):
		non_existant_states.append(from)
	
	if not has_state(to):
		non_existant_states.append(to)
		
	if not non_existant_states.empty():
		if non_existant_states.size() == 2:
			push_warning("Failed to add transition. States %s and %s do not exist." % non_existant_states)
		else:
			push_warning("Failed to add transition. State %s does not exist." % non_existant_states)
		return
		
	var transition_data := TransitionData.new()
	transition_data.from = from
	transition_data.to = to
	transition_data.transition = transition

	_transitions.append(transition_data)


func remove_transition(from: String, to: String) -> void:
	var non_existant_states := []
	if not _states.has_key(from):
		non_existant_states.append(from)
	
	if not _states.has_key(to):
		non_existant_states.append(to)
		
	if not non_existant_states.empty():
		if non_existant_states.size() == 2:
			push_warning("Failed to remove transition. States %s and %s do not exist." % non_existant_states)
		else:
			push_warning("Failed to remove transition. State %s does not exist." % non_existant_states)
		return
	
	for i in len(_transitions):
		var transition_data: TransitionData = _transitions[i]
		if transition_data.from == from and transition_data.to == to:
			_transitions.remove(i)
			break


func has_transition(from: String, to: String) -> bool:
	for transition_data in _transitions:
		if transition_data.from == from and transition_data.to == to:
			return true
	return false


func has_next_transition(input: Object = null) -> bool:
	return not get_next_state(input).empty()


func get_transition(from: String, to: String) -> Transition:
	for transition_data in _transitions:
		if transition_data.from == from and transition_data.to == to:
			return transition_data.transition
	return null


func get_next_transitions(from: String) -> Array: # TransitionData[]
	var transitions: Array
	for tranistion_data in _transitions:
		if tranistion_data.from == from:
			var td := TransitionData.new()
			td.from = from
			td.to = tranistion_data.to
			td.transition = tranistion_data.transition
			transitions.append(td)

	return transitions

## Initializes the state machine.
## 'state' is an optional parameter which will set the initial state if an empty string is not passed.
func initialize(state: String = "", arg = null) -> void:
	if not state.empty():
		set_initial_state(state)

	go_to(initial_state, arg)


## Advances to next state reachable based on given input.
## The '_get_next_state_impl' virtual method determines if the input is accept or not.
##
## Returns true if the input was accepted and state advanced.
func advance(input = null, arg = null) -> bool:
	var next_state: String = get_next_state(input)
	if not next_state.empty():
		go_to(next_state, arg)
		return true
	return false

## Goes to the given state if it exists.
func go_to(to_state: String, arg = null) -> void:
	if not has_state(to_state):
		push_warning("Failed advance to state. Given state '%s' does not exist")
		return
	
	var prev_state_name := _current_state
	var prev_state := get_state(prev_state_name)
	if prev_state != null:
		prev_state._exit_impl()
		
	get_state(to_state)._enter_impl(arg)
	
	_current_state = to_state
	emit_signal("state_changed", prev_state_name, _current_state)

## Returns the next state reachable with the given input
func get_next_state(input = null) -> String:
	return _get_next_state_impl(input)

## Virtual method used to determine the next reachable using given input
func _get_next_state_impl(input = null) -> String:
	return "";
	
#signal methods

#inner classes

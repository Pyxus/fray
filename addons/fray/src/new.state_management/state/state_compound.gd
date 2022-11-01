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
const AStarGraph = preload("a_star_graph.gd")


var start_state: String setget set_start_state
var end_state: String setget set_end_state

## Type: Dictionary<String, bool>
## Hint: <condition name, condition status>
var _conditions: Dictionary

## Type: Dictionary<String, StateData>
## Hint: <state name, >
var _states_data_by_state: Dictionary

## Type: Dictionary<String, int>
## Hint: <state name, point id>
var _point_id_by_state: Dictionary

var _travel_args: Dictionary
var _current_state: String
var _astar := AStarGraph.new(funcref(self, "get_transition"))


func _enter_impl(args: Dictionary) -> void:
	start(args)


func _is_done_processing_impl() -> bool:
	return _current_state == end_state or end_state.empty()

## Adds a child state to this compound state
##
## `name` is the name of the state
##
## `state: State` is the state instance associated with this state name.
func add_state(name: String, state: Reference) -> void:
	if name.empty():
		push_error("failed to add state. State name can not be empty.")
		return

	if has_state(name):
		push_error("Failed to add state. State with name %s already exists" % name)
		return
	
	if state.has_parent():
		push_error("Failed to add state. State object already belongs to parent state %s" % state.get_parent())
		return
	
	_states_data_by_state[name] = StateData.new(state)
	_astar.add_point(name)

	if _states_data_by_state.size() == 1:
		start_state = name
	
	emit_signal("state_added", name)

## Remove child state from this compound state if it exists.
func remove_state(name: String) -> void:
	if _err_state_does_not_exist(name, "Failed to remove state. "):
		return

	if name == start_state:
		start_state = ""
	
	if name == end_state:
		end_state = ""
	
	_states_data_by_state.erase(name)

	for state in _states_data_by_state:
		if has_transition(state, name):
			remove_transition(state, name)
	
	_astar.remove_point(name)
	
	emit_signal("state_removed", name)

## Rename child state if it exists.
func rename_state(old_name: String, new_name: String) -> void:
	if new_name.empty():
		push_warning("failed to rename state. State's new name can not be empty.")
		return

	if _err_state_does_not_exist(old_name, "Failed to rename state. "):
		return
	
	if has_state(old_name):
		push_warning("Failed to rename state. State with name %s already exists." % old_name)
		return

	for state in _states_data_by_state:
		var data: StateData = _states_data_by_state[state]
		data.rename_transition_to(old_name, new_name)

	var state: Reference = _states_data_by_state[old_name].inst
	_states_data_by_state.erase(old_name)
	_states_data_by_state[new_name] = StateData
	
	emit_signal("state_renamed", old_name, new_name)

## Replaces a child state's state instance.
##
## `state: State` is the new state instance to replace the previous instance.
func replace_state(name: String, state: Reference) -> void:
	if _err_state_does_not_exist(name, "Failed to replace state. "):
		return

	if state.has_parent():
		push_error("Failed to replace state. Replacement state already belongs to parent state %s" % state.get_parent())
		return
	
	_states_data_by_state[name].inst = state
	emit_signal("state_replaced", name)

## Adds a transition from one child state to another.
##
## `from` name of the state the transition stems from.
##
## `transition` transition object cotaning information on the transition such as where it goes too.
func add_transition(from: String, transition: Transition) -> void:
	if (_err_state_does_not_exist(from, "Failed to add transition. ") 
		or _err_state_does_not_exist(transition.to, "Failed to add transition. ")):
		return
	
	if has_transition(from, transition.to):
		push_warning("A transition already exists from '%s to '%s'" % [from, transition.to])
		return
	
	for condition in transition.prereqs + transition.advance_conditions:
		if not has_condition(condition.name):
			_conditions[condition.name] = false

	_states_data_by_state[from].add_transition(transition)

	_astar.connect_points(from, transition.to, has_transition(transition.to, from))
	emit_signal("transition_added", from, transition.to)

## Remove transition between two child states.
func remove_transition(from: String, to: String) -> void:
	if (_err_state_does_not_exist(from, "Failed to remove transition. ") 
		or _err_state_does_not_exist(to, "Failed to remove transition. ")):
		return
	
	if not has_transition(from, to):
		push_warning("Failed to remove transition. Transition from '%s' to '%s' does not exist" % [from, to])
		return
	
	var from_data: StateData = _states_data_by_state[from]
	
	from_data.remove_transition_to(to)
	_astar.disconnect_points(from, to, not has_transition(to, from))

	var transition := from_data.get_transition(to)
	for condition in transition.prereqs + transition.advance_conditions:
		var is_condition_still_used := false
		for t in from_data.adjacency_list:
			if condition.name in (t.prereqs + t.advance_conditions):
				is_condition_still_used = true
				break
		
		if not is_condition_still_used and has_condition(condition.name):
			_conditions.erase(condition.name)

	emit_signal("transition_removed", from, to)

## Returns true if a given transiton exists.
func has_transition(from: String, to: String) -> bool:
	if _err_state_does_not_exist(from) or _err_state_does_not_exist(to):
		return false

	return _states_data_by_state[from].get_transition(to) != null

## Returns transition from state to state if it exists.
func get_transition(from: String, to: String) -> Transition:
	if _err_state_does_not_exist(from, "Failed to get transition.") or _err_state_does_not_exist(to, "Failed to get transition."):
		return null

	return _states_data_by_state[from].get_transition(to)

##  Returns an array of transitions traversable from the given state.
## Return Type: Transition[].
func get_next_transitions(from: String) -> Array:
	if _err_state_does_not_exist(from, "Failed to get next trantions."):
		return []

	return _states_data_by_state[from].adjacency_list

## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the `to` state will be visted directly.
func travel(to: String, args: Dictionary = {}) -> void:
	if _err_state_does_not_exist(to, "Failed to travel."):
		return
	
	if not _current_state.empty():
		_astar.compute_travel_path(_current_state, to)
		_travel_args = args

		if not _astar.has_next_travel_state():
			go_to(to, _travel_args)


## Advances to next reachable state.
##
## `input` is optional user-defined data used to determine if a transition can occur.
##	The `_accept_input_impl()` virtual method can be overidden to determine what input is accepted.
##
## `args` is user-defined data which is passed to the advanced state on enter.
##	If a state advances due to traveling the args provided to the initial travel call will be used instead.
##
## Returns true if the input was accepted and state advanced.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	var current_state := get_current_state()
	if current_state != null:
		if current_state is get_script():
			current_state.advance(input, args)

		if current_state.is_done_processing() and _astar.has_next_travel_state():
			while current_state.is_done_processing() and _astar.has_next_travel_state():
				_go_to(_astar.get_next_travel_state(), _travel_args)
		else:
			var next_state := get_next_state(input, true)
			if not next_state.empty():
				go_to(next_state, args)

	return current_state != null and current_state != get_current_state()

## Returns the next state reachable
##
## If `auto_only` is true then only transitions with auto_advance enabled will be considered. 
##
## Returns the name of the next state
func get_next_state(input: Dictionary = {}, auto_only: bool = false) -> String:
	if _current_state.empty():
		push_warning("No current state set. This compound state may have never been started.")
		return ""
	
	for obj in get_next_transitions(_current_state):
		var transition := obj as Transition

		if auto_only:
			if _can_transition(transition, input) and _can_auto_advance(transition):
				return transition.to
		elif _can_transition(transition, input):
			return transition.to 
	return ""


## Goes directly to the given state if it exists.
##
## If a travel is still being performed it will be interupted
##
## `to_state` is the name of the state to transition to
##
## `args` is user-defined data which is passed to the advanced state on enter. 
func go_to(to_state: String, args: Dictionary = {}) -> void:
	if _astar.has_next_travel_state():
		_astar.clear_travel_path()
		_travel_args.clear()
	_go_to(to_state, args)


## Alias for 'go_to(start_state, args)'
func start(args: Dictionary = {}) -> void:
	if start_state.empty():
		push_error("Failed to start. No start state set")
		return
	go_to(start_state, args)

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
## ... -> [state_name : state_priority, ...] indicates the adjacent states
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
			string += "%s:%s" % [transition.to, transition.priority]

			if next_transitions.back() != transition:
				string += ", "
			pass
		string += "]\n"
	
	print(string)

## Returns true if given state exists.
func has_state(name: String) -> bool:
	return _states_data_by_state.has(name)

## Returns an array containing the names of all states beloning to this state machine.
func get_state_names() -> PoolStringArray:
	return PoolStringArray(_states_data_by_state.keys())

## Returns state object based on name if it exists
func get_state(name: String) -> Reference:
	var data: StateData = _states_data_by_state.get(name, null)
	return data.inst if data else null

## Returns the name of the current state
func get_current_state_name() -> String:
	return _current_state

## Returns the state instance of the current state
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

## Process child states then this state.
## Intended to be called by `StateMachine` node 
func process(delta: float) -> void:
	var current_state := get_current_state()
	if current_state != null:
		current_state._process_impl(delta)
	_process_impl(delta)

## Physics process child states then this state.
## Intended to be called by `StateMachine` node 
func physics_process(delta: float) -> void:
	var current_state := get_current_state()
	if current_state != null:
		current_state._physics_process_impl(delta)
	_physics_process_impl(delta)


func _go_to(to_state: String, args: Dictionary) -> void:
	if not has_state(to_state):
		push_warning("Failed advance to state. Given state '%s' does not exist")
		return

	var prev_state_name := _current_state
	var prev_state := get_state(prev_state_name)
	if prev_state != null:
		prev_state._exit_impl()
	
	_current_state = to_state
	get_state(to_state)._enter_impl(args)
	emit_signal("transitioned", prev_state_name, _current_state)


func _can_switch(transition: Transition) -> bool:
	return ( 
		transition.switch_mode == Transition.SwitchMode.IMMEDIATE
		or transition.switch_mode == Transition.SwitchMode.AT_END 
		and is_done_processing()
		)

func _is_conditions_satisfied(conditions: Array) -> bool:
	for condition in conditions:
		if not has_condition(condition.name):
			push_warning("Condition '%s' was never set" % condition.name)
			return false

		if not check_condition(condition.name) and not condition.invert:
			return false
	return true


func _can_transition(transition: Transition, input: Dictionary) -> bool:
	return (
		_is_conditions_satisfied(transition.prereqs) 
		and _can_switch(transition) 
		and _accept_input_impl(transition, input)
		)


func _can_auto_advance(transition: Transition) -> bool:
	if not transition.auto_advance:
		return false

	return _is_conditions_satisfied(transition.advance_conditions)


func _accept_input_impl(transition: Transition, input: Dictionary) -> bool:
	return true


func _err_state_does_not_exist(state: String, err_msg: String = "") -> bool:
	if not has_state(state):
		push_error(err_msg + "State %s does not exist." % state)
		return true
	return false


class StateData:
	extends Reference

	const Transition = preload("transition/transition.gd")

	var inst: Reference
	var adjacency_list: Array

	func _init(state_inst: Reference) -> void:
		inst = state_inst

	func remove_tranisitons_to(to: String) -> void:
		for transition in adjacency_list:
			if transition.to == to:
				adjacency_list.erase(transition)
	

	func rename_transition_to(old_name: String, new_name: String) -> void:
		for transition in adjacency_list:
			if transition.to == old_name:
				transition.to = new_name
	

	func add_transition(transition: Transition) -> void:
		adjacency_list.append(transition)
		adjacency_list.sort_custom(self, "_sort_transitions")
	

	func get_transition(to: String) -> Transition:
		for transition in adjacency_list:
			if transition.to == to:
				return transition
		return null
	

	func remove_transition_to(to: String) -> void:
		for transition in adjacency_list:
			if transition.to == to:
				adjacency_list.erase(transition)

	func _sort_transitions(t1: Transition, t2: Transition) -> bool:
		if t1.priority < t2.priority:
			return true
		return false


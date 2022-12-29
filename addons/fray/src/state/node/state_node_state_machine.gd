extends "state_node.gd"
## State node that behaves like a state machine
##
## @desc:
##		Contains multiple multiple state nodes connected through `StateMachineTransitions`.
##		It is recommended to construct this state machine with a `StateMachineBuilder`.

## Emitted when the current state is changes
##
## `from: String` is the previous state
##
## `to: String` is the current state
signal transitioned(from, to)

const Condition = preload("transition/condition.gd")
const AStarGraph = preload("a_star_graph.gd")
const StateMachineTransition = preload("transition/state_machine_transition.gd")
var StateNodeStateMachine: GDScript = load("res://addons/fray/src/state/node/state_node_state_machine.gd")

var start_node: String setget set_start_node
var end_node: String setget set_end_node
var current_node: String setget set_current_node

var _astar := AStarGraph.new(funcref(self, "_get_transition_priority"))
var _travel_args: Dictionary

## Type: Dictionary<String, StateNode>
var _states: Dictionary

## Type: Transition[]
var _transitions: Array


func _enter_impl(args: Dictionary) -> void:
	goto_start(args)


func _is_done_processing_impl() -> bool:
	return end_node.empty() or current_node == end_node

## Adds a new `StateNodeBase` under the given `name`.
func add_node(name: String, node: Reference) -> void:
	if _ERR_FAILED_TO_ADD_NODE(name, node): return
	
	if _states.empty():
		start_node = name

	_states[name] = node
	_astar.add_point(name)
	_on_node_added(name, node)

## Removes the specified node.
func remove_node(name: String) -> void:
	if _ERR_INVALID_NODE(name): return
	
	var node: Reference = get_node(name)
	_states.erase(name)
	_astar.remove_point(name)
	_on_node_removed(name, node)

## Renames the specified node.
func rename_node(old_name: String, new_name: String) -> void:
	if _ERR_INVALID_NODE(old_name): return
	
	if has_node(new_name):
		push_warning("Failed to rename node. Node with name %s already exists." % new_name)
		return
	
	_states[new_name] = _states[old_name]
	_states.erase(old_name)
	_astar.rename_point(old_name, new_name)
	_on_node_renamed(old_name, new_name)

## Replaces the specified node's `StateNodeBase` object.
func replace_node(name: String, replacement_node: Reference) -> void:
	if _ERR_INVALID_NODE(name): return
	
	if replacement_node.has_parent():
		push_warning("Failed to replace node. Replacement node already belongs to parent node %s" % replacement_node.get_parent())
		return
	
	_states[name] = replacement_node

## Returns true if the machine contains the specified node.
func has_node(name: String) -> bool:
	return _states.has(name)

## Returns the sub-node with the specified name.
## Return Type: StateNodeBase
func get_node(name: String) -> Reference:
	if _ERR_INVALID_NODE(name): return null
	return _states[name]

## Returns the current node if it is set.
## Return Type: StateNodeBase
func get_node_current() -> Reference:
	return _states.get(current_node)
	
## Adds a transition between specified nodes.
func add_transition(from: String, to: String, transition: StateMachineTransition) -> void:
	if _ERR_INVALID_NODE(from): return
	if _ERR_INVALID_NODE(to): return
	
	var tr := Transition.new()
	tr.from = from
	tr.to = to
	tr.transition = transition

	_add_conditions(transition.prereqs + transition.advance_conditions)
	_astar.connect_points(from, to, has_transition(from, to))
	_transitions.append(tr)

## Removes transition between the two specified nodes if one exists.
func remove_transition(from: String, to: String) -> void:
	if _ERR_INVALID_NODE(from): return
	if _ERR_INVALID_NODE(to): return
	
	_astar.disconnect_points(from, to, not has_transition(from, to))

	for transition in _transitions:
		if transition.from == from and transition.to == to:
			_transitions.erase(transition)
			_remove_conditions(transition.prereqs + transition.advance_conditions)
			return

## Returns true if transition between specified nodes exists.
func has_transition(from: String, to: String) -> bool:
	return get_transition(from, to) != null

## Returns `StateMachineTransition` between given states if it exists.
func get_transition(from: String, to: String) -> StateMachineTransition:
	for transition in _transitions:
		if transition.from == from and transition.to == to:
			return transition

	return null

## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the `to` state will be visted directly.
func travel(to: String, args: Dictionary = {}) -> void:
	if _ERR_INVALID_NODE(to): return
	
	if not current_node.empty():
		_astar.compute_travel_path(current_node, to)
		_travel_args = args

		if not _astar.has_next_travel_node():
			goto(to, args)

## Advances to next reachable state.
## Will only transition if a travel was initiated. 
## Or if a travel was not initiated and a reachable transition has `auto_advance` enabled
##
## `input` is optional user-defined data used to determine if a transition can occur.
##	The `_accept_input_impl()` virtual method can be overidden to determine what input is accepted.
##
## `args` is user-defined data which is passed to the advanced state on enter.
##	If a state advances due to traveling the args provided to the initial travel call will be used instead.
##
## Returns true if the input was accepted and state advanced.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	var cur_node: Reference = get_node_current()

	if cur_node != null:
		if cur_node is StateNodeStateMachine:
			cur_node.advance(input, args)
		
		if _astar.has_next_travel_node():
			var travel_node = cur_node
			while travel_node.is_done_processing() and _astar.has_next_travel_node():
				_goto(_astar.get_next_travel_node(), _travel_args)
				travel_node = get_node(current_node)
		else:
			var next_node := get_next_node(input)
			if not next_node.empty():
				goto(next_node, args)

	return cur_node != null and cur_node != _states.get(current_node, null)


## Returns the next reachable node
func get_next_node(input: Dictionary = {}) -> String:
	if current_node.empty():
		push_warning("No current state is set.")
		return ""

	for tr in _transitions:
		if tr.from == current_node:
			var transition: StateMachineTransition = tr.transition
			if _can_transition(transition) and _can_advance(transition, input):
				return tr.to

	return ""

## Goes directly to the given state if it exists.
##
## If a travel is being performed it will be interupted
##
## `args` is user-defined data which is passed to the advanced state on enter. 
func goto(to_node: String, args: Dictionary = {}) -> void:
	if _astar.has_next_travel_node():
		_astar.clear_travel_path()
	
	_goto(to_node, args)

## Short hand for 'node.goto(node.start_node, args)'
func goto_start(args: Dictionary = {}) -> void:
	if start_node.empty():
		push_warning("Failed to go to start. Start node not set.")
		return
	
	goto(start_node)

## Short hand for 'node.goto(node.end_node, args)'
func goto_end(args: Dictionary = {}) -> void:
	if end_node.empty():
		push_warning("Failed to go to end. End node not set.")
		return
	
	goto(end_node)
## Returns an array of transitions traversable from the given state.
## Return Type: Transition[].
func get_next_transitions(from: String) -> Array:
	if _ERR_INVALID_NODE(from): return []

	var transitions: Array

	for transition in _transitions:
		if transition.from == from:
			transitions.append(transition)

	return transitions

## Setter for `start_node` property
func set_start_node(name: String) -> void:
	if _ERR_INVALID_NODE(name): return
	start_node = name

## Setter for `end_node` property
func set_end_node(name: String) -> void:
	if _ERR_INVALID_NODE(name): return
	end_node = name

## Setter for `current_node` property
## Will call `goto()` when changed
func set_current_node(name: String) -> void:
	if _ERR_INVALID_NODE(name): return
	goto(name)

## Process child states then this state.
## Intended to be called by `StateMachine` node 
func process(delta: float) -> void:
	var cur_state: Reference = _states.get(current_node)
	if cur_state != null:
		cur_state._process_impl(delta)
	_process_impl(delta)

## Physics process child states then this state.
## Intended to be called by `StateMachine` node 
func physics_process(delta: float) -> void:
	var cur_state: Reference = _states.get(current_node)
	if cur_state != null:
		cur_state._physics_process_impl(delta)
	_physics_process_impl(delta)

## Prints this state machine in adjacency list form.
## '| c--' indicates the current state.
## '| -s-' indicates the start state.
## '| --e' indicates the end state.
## ... -> [state_name : state_priority, ...] indicates the adjacent states
func print_adj() -> void:
	var string := ""

	for state in _states.keys():
		var next_transitions := get_next_transitions(state)
		var modifiers := "%s%s%s" % [
			"c" if state == current_node else "-",
			"s" if state == start_node else "-",
			"e" if state == end_node else "-",
		]

		if modifiers == "---":
			modifiers = ""
		else:
			modifiers = " | " + modifiers

		string += "[%s%s]" % [state, modifiers]
		
		string += " -> ["
		
		for tr in next_transitions:
			var transition = tr.transition
			string += "%s:%s" % [tr.to, transition.priority]

			if next_transitions.back() != tr:
				string += ", "
			pass
		string += "]\n"
	
	print(string)


func _get_transition_priority(from: String, to: String) -> float:
	var tr := get_transition(from, to)
	return float(tr.transition.priority) if tr else 0.0


func _goto(to_node: String, args: Dictionary) -> void:
	if _ERR_INVALID_NODE(to_node): return

	var prev_node_name := current_node
	var prev_node: Reference = get_node(to_node)

	if prev_node != null:
		prev_node._exit_impl()
	
	current_node = to_node
	get_node(current_node)._enter_impl(args)
	emit_signal("transitioned", prev_node_name, current_node)


func _can_transition(transition: StateMachineTransition) -> bool:
	return (
		_is_conditions_satisfied(transition.prereqs) 
		and _can_switch(transition) 
		)


func _can_switch(transition: StateMachineTransition) -> bool:
	return ( 
		transition.switch_mode == StateMachineTransition.SwitchMode.IMMEDIATE
		or transition.switch_mode == StateMachineTransition.SwitchMode.AT_END 
		and is_done_processing()
		)


func _can_advance(transition: StateMachineTransition, input: Dictionary) -> bool:
	return (
		transition.auto_advance
		or _is_conditions_satisfied(transition.advance_conditions)
			and not transition.advance_conditions.empty()
		or transition.accepts(input)
		)

## `conditions: Condition[]`
func _is_conditions_satisfied(conditions: Array) -> bool:
	for condition in conditions:
		if not has_condition(condition.name):
			push_warning("Condition '%s' was never set" % condition.name)
			return false
		
		if not _is_condition_true(condition):
			return false
	return true


func _is_condition_true(condition: Condition) -> bool:
	return (
			check_condition(condition.name) and not condition.invert 
			or not check_condition(condition.name) and condition.invert
			)


func _on_node_added(name: String, node: Reference) -> void:
	pass


func _on_node_removed(name: String, node: Reference) -> void:
	pass


func _on_node_renamed(old_name: String, new_name: String) -> void:
	pass


func _ERR_FAILED_TO_ADD_NODE(name: String, state: Reference) -> bool:
	if name.empty():
		push_error("Failed to add node. Node name can not be empty.")
		return true

	if has_node(name):
		push_error("Failed to add node. Node with name %s already exists" % name)
		return true
	
	if state.has_parent():
		push_error("Failed to add node. Node object already belongs to parent %s" % state.get_parent())
		return true
	
	return false

func _ERR_INVALID_NODE(name: String) -> bool:
	if name.empty():
		push_error("Invalid node name, name can not be empty")
		return true
	
	if not has_node(name):
		push_error("Invalid node name '%s', node does not exist." % name)
		return true

	return false


class Transition:
	extends Reference
	
	const StateMachineTransition = preload("transition/state_machine_transition.gd")

	var from: String
	var to: String
	var transition: StateMachineTransition

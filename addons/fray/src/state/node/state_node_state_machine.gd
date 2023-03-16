class_name FrayStateNodeStateMachine
extends FrayStateNode
## State machine state node
##
## Contains multiple multiple [FrayStateNode]s connected through [FrayStateMachineTransition]s.
## It is recommended to construct this state machine with a [FrayStateMachineBuilder].

## Emitted when the current state is changes
signal transitioned(from: StringName, to: StringName)

const _AStarGraph = preload("a_star_graph.gd")

## The state machine's staring node.
var start_node: StringName = "":
	set(node):
		if _ERR_INVALID_NODE(node): return
		start_node = node

## The state machine's end node.
var end_node: StringName = "":
	set(node):
		if _ERR_INVALID_NODE(node): return
		end_node = node

## The state machine's current node.
var current_node: StringName = "":
	set(node):
		if _ERR_INVALID_NODE(node): return
		goto(node)

var _astar := _AStarGraph.new(_get_transition_priority)
var _travel_args: Dictionary

# Type: Dictionary<StringName, StateNode>
var _states: Dictionary

var _transitions: Array[Transition]


func _enter_impl(args: Dictionary) -> void:
	goto_start(args)


func _is_done_processing_impl() -> bool:
	return end_node.is_empty() or current_node == end_node

## Adds a new [kbd]node[/kbd] under a given [kbd]name[/kbd].
func add_node(name: StringName, node: FrayStateNode) -> void:
	if _ERR_FAILED_TO_ADD_NODE(name, node): return
	
	if _states.is_empty():
		start_node = name

	_states[name] = node
	_astar.add_point(name)
	_on_node_added(name, node)

## Removes the specified node.
func remove_node(name: StringName) -> void:
	if _ERR_INVALID_NODE(name): return
	
	var node: RefCounted = get_node(name)
	_states.erase(name)
	_astar.remove_point(name)
	_on_node_removed(name, node)

## Renames the specified node.
func rename_node(old_name: StringName, new_name: StringName) -> void:
	if _ERR_INVALID_NODE(old_name): return
	
	if has_node(new_name):
		push_warning("Failed to rename node. Node with name %s already exists." % new_name)
		return
	
	_states[new_name] = _states[old_name]
	_states.erase(old_name)
	_astar.rename_point(old_name, new_name)
	_on_node_renamed(old_name, new_name)

## Replaces the specified node's object.
func replace_node(name: StringName, replacement_node: FrayStateNode) -> void:
	if _ERR_INVALID_NODE(name): return
	
	if replacement_node.has_parent():
		push_warning("Failed to replace node. Replacement node already belongs to parent node %s" % replacement_node.get_parent())
		return
	
	_states[name] = replacement_node

## Returns [code]true[/code] if the machine contains the specified node.
func has_node(name: StringName) -> bool:
	return _states.has(name)

## Returns the sub-node with the specified name.
func get_node(name: StringName) -> FrayStateNode:
	if _ERR_INVALID_NODE(name): return null
	return _states[name]

## Returns the current node if it is set.
func get_node_current() -> FrayStateNode:
	return _states.get(current_node)
	
## Adds a transition between specified nodes.
func add_transition(from: StringName, to: StringName, transition: FrayStateMachineTransition) -> void:
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
func remove_transition(from: StringName, to: StringName) -> void:
	if _ERR_INVALID_NODE(from): return
	if _ERR_INVALID_NODE(to): return
	
	_astar.disconnect_points(from, to, not has_transition(from, to))

	for transition in _transitions:
		if transition.from == from and transition.to == to:
			_transitions.erase(transition)
			_remove_conditions(transition.prereqs + transition.advance_conditions)
			return

## Returns [code]true[/code] if transition between specified nodes exists.
func has_transition(from: StringName, to: StringName) -> bool:
	return get_transition(from, to) != null

## Returns transition between given states if it exists.
func get_transition(from: StringName, to: StringName) -> FrayStateMachineTransition:
	for transition in _transitions:
		if transition.from == from and transition.to == to:
			return transition.transition

	return null

## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the [kbd]to[/kbd] state will be visted directly.
func travel(to: StringName, args: Dictionary = {}) -> void:
	if _ERR_INVALID_NODE(to): return
	
	if not current_node.is_empty():
		_astar.compute_travel_path(current_node, to)
		_travel_args = args

		if not _astar.has_next_travel_node():
			goto(to, args)

## Advances to next reachable state.
## Will only transition if a travel was initiated. 
## Or if a travel was not initiated and a reachable transition has `auto_advance` enabled
## [br][br]
## [kbd]input[/kbd] is optional user-defined data used to determine if a transition can occur.
##	The [method _accept_input_impl] virtual method can be overidden to determine what input is accepted.
## [br][br]
## [kbd]args[/kbd] is user-defined data which is passed to the advanced state on enter.
## If a state advances due to traveling the args provided to the initial travel call will be used instead.
##
## Returns true if the input was accepted and state advanced.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	var cur_node: RefCounted = get_node_current()

	if cur_node != null:
		if cur_node is FrayStateNodeStateMachine:
			cur_node.advance(input, args)
		
		if _astar.has_next_travel_node():
			var travel_node = cur_node
			while travel_node.is_done_processing() and _astar.has_next_travel_node():
				_goto(_astar.get_next_travel_node(), _travel_args)
				travel_node = get_node(current_node)
		else:
			var next_node := get_next_node(input)
			if not next_node.is_empty():
				goto(next_node, args)

	return cur_node != null and cur_node != _states.get(current_node, null)


## Returns the name of the next reachable node.
func get_next_node(input: Dictionary = {}) -> StringName:
	
	if current_node.is_empty():
		push_warning("No current state is set.")
		return ""

	for tr in get_next_transitions(current_node):
		var transition: FrayStateMachineTransition = tr.transition
		if _can_transition(transition) and _can_advance(transition, input):
			return tr.to

	return ""

## Goes directly to the given state if it exists.
## If a travel is being performed it will be interupted.
func goto(to_node: StringName, args: Dictionary = {}) -> void:
	if _astar.has_next_travel_node():
		_astar.clear_travel_path()
	
	_goto(to_node, args)

## Short hand for 'node.goto(node.start_node, args)'.
func goto_start(args: Dictionary = {}) -> void:
	if start_node.is_empty():
		push_warning("Failed to go to start. Start node not set.")
		return
	
	goto(start_node)

## Short hand for 'node.goto(node.end_node, args)'.
func goto_end(args: Dictionary = {}) -> void:
	if end_node.is_empty():
		push_warning("Failed to go to end. End node not set.")
		return
	
	goto(end_node)

## Returns an array of transitions traversable from the given state.
func get_next_transitions(from: StringName) -> Array[Transition]:
	if _ERR_INVALID_NODE(from): return []

	var transitions: Array[Transition]

	for transition in _transitions:
		if transition.from == from:
			transitions.append(transition)

	return transitions

## Process child states then this state.
func process(delta: float) -> void:
	var cur_state: RefCounted = _states.get(current_node)
	if cur_state != null:
		cur_state._process_impl(delta)
	_process_impl(delta)

## Physics process child states then this state.
func physics_process(delta: float) -> void:
	var cur_state: RefCounted = _states.get(current_node)
	if cur_state != null:
		cur_state._physics_process_impl(delta)
	_physics_process_impl(delta)

## Prints this state machine in adjacency list form.
## [br]
## c-- indicates the current state.[br]
## -s- indicates the start state.[br]
## --e indicates the end state.[br]
## ... -> [state_name : state_priority, ...] indicates the adjacent states[br]
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


func _get_transition_priority(from: StringName, to: StringName) -> float:
	var tr := get_transition(from, to)
	return float(tr.transition.priority) if tr else 0.0


func _goto(to_node: StringName, args: Dictionary) -> void:
	if _ERR_INVALID_NODE(to_node): return

	var prev_node_name := current_node
	var prev_node: RefCounted = get_node(to_node)

	if prev_node != null:
		prev_node._exit_impl()
	
	current_node = to_node
	get_node(current_node)._enter_impl(args)
	emit_signal("transitioned", prev_node_name, current_node)


func _can_transition(transition: FrayStateMachineTransition) -> bool:
	return (
		_is_conditions_satisfied(transition.prereqs) 
		and _can_switch(transition) 
		)


func _can_switch(transition: FrayStateMachineTransition) -> bool:
	return ( 
		transition.switch_mode == FrayStateMachineTransition.SwitchMode.IMMEDIATE
		or transition.switch_mode == FrayStateMachineTransition.SwitchMode.AT_END
		and is_done_processing()
		)


func _can_advance(transition: FrayStateMachineTransition, input: Dictionary) -> bool:
	return (
		transition.auto_advance
		or (
			not transition.advance_conditions.is_empty()
			and _is_conditions_satisfied(transition.advance_conditions)
			)
		or transition.accepts(input)
		)


func _is_conditions_satisfied(conditions: Array[FrayCondition]) -> bool:
	for condition in conditions:
		if not has_condition(condition.name):
			push_warning("Condition '%s' was never set" % condition.name)
			return false
		
		if not _is_condition_true(condition):
			return false
	return true


func _is_condition_true(condition: FrayCondition) -> bool:
	return (
			is_condition_true(condition.name) and not condition.invert 
			or not is_condition_true(condition.name) and condition.invert
			)


func _on_node_added(name: StringName, node: RefCounted) -> void:
	pass


func _on_node_removed(name: StringName, node: RefCounted) -> void:
	pass


func _on_node_renamed(old_name: StringName, new_name: StringName) -> void:
	pass


func _ERR_FAILED_TO_ADD_NODE(name: StringName, state: RefCounted) -> bool:
	if name.is_empty():
		push_error("Failed to add node. Node name can not be empty.")
		return true

	if has_node(name):
		push_error("Failed to add node. Node with name %s already exists" % name)
		return true
	
	if state.has_parent():
		push_error("Failed to add node. Node object already belongs to parent %s" % state.get_parent())
		return true
	
	return false

func _ERR_INVALID_NODE(name: StringName) -> bool:
	if name.is_empty():
		push_error("Invalid node name, name can not be empty")
		return true
	
	if not has_node(name):
		push_error("Invalid node name '%s', node does not exist." % name)
		return true

	return false


class Transition:
	extends RefCounted
	
	var from: StringName
	var to: StringName
	var transition: FrayStateMachineTransition
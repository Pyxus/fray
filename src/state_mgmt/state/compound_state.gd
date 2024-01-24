class_name FrayCompoundState
extends FrayState
## Compound state
##
## Contains multiple [FrayState]s connected through [FrayStateMachineTransition]s.
## It is recommended to construct this state machine with a [FrayCompoundState.Builder].
## [br][br]
## Global transitions are a convinience feature that allows you to automatically connect states based on global transition rules.
## States within this state machine can be assigned tags, transition rules can then be set from one tag to another tag.
## States with a given 'from_tag' will automatically have a transition setup to global states with a given 'to_tag'.
## A state is considered global if it is used as the 'to' state in a global transition.
## [br][br]
## This is useful for setting up transitions which need to be available from multiple states without needing to manually connect them.
## For example, in many fighting games you could say all attacks tagged as 'normal' may transition into attacks tagged as 'special'

## Emitted when a state is added.
signal state_added(name: StringName, state: FrayState)

## Emitted when a state is removed.
signal state_removed(name: StringName, state: FrayState)

## Emitted when a state is renamed.
signal state_renamed(name: StringName, state: FrayState)

## Emitted when the current state is changes.
signal transitioned(from: StringName, to: StringName)

const _SYMBOL_NEGATION = "!"
const _SYMBOL_STRICTLY_GLOBAL = "$"

const _AStarGraph = preload("a_star_graph.gd")


## Returns a new builder instance.
static func builder() -> Builder:
	return Builder.new()


## The state machine's staring state.
var start_state: StringName = "":
	get:
		return _start_state
	set(state):
		if _ERR_INVALID_STATE(state):
			return
		_start_state = state

## The state machine's end state.
var end_state: StringName = "":
	get:
		return _end_state
	set(state):
		if _ERR_INVALID_STATE(state):
			return
		_end_state = state

## If [code]true[/code] this state does not reset to its start state on enter.
var is_persistent := false

# Type: Dictionary<StringName, FrayState>
var _states: Dictionary

# Type: Dictionary<StringName, StringName[]>
# Hint: <from tag, to tags>
var _global_transition_rules: Dictionary

# Type: Dictionary<StringName, StringName[]>
# Hint: <state name, tags>
var _tags_by_state: Dictionary

# Type: Dictionary<StringName, func() -> bool>
var _condition_func_by_name: Dictionary

# Type: func(NodePath) -> Node
# Note: Must be set externally, typically by the state machine node
var _fn_get_node: Callable

# Type: func(GDScript | GDScriptNativeClass) -> Node
# Note: Must be set externally, typically by the state machine node
var _fn_get_node_of_type: Callable

# Type: func(GDScript | GDScriptNativeClass) -> Array[Node]
# Note: Must be set externally, typically by the state machine node
var _fn_get_nodes_of_type: Callable

var _astar := _AStarGraph.new(_get_transition_priority)
var _travel_args: Dictionary
var _transitions: Array[_Transition]
var _global_transitions: Array[_Transition]
var _current_state: StringName
var _start_state: StringName
var _end_state: StringName


func _enter_impl(args: Dictionary) -> void:
	super(args)

	if not is_persistent or _current_state.is_empty():
		_current_state = start_state

	var cur_state := get_current_state()
	if cur_state is FrayCompoundState:
		cur_state._enter_impl(args)


func _exit_impl() -> void:
	super()

	if not is_persistent:
		_current_state = ""


func _is_done_processing_impl() -> bool:
	super()
	return _end_state.is_empty() or _current_state == _end_state


func get_node(path: NodePath) -> Node:
	return get_root()._fn_get_node.call(path)


func get_node_of_type(type: Variant) -> Node:
	return get_root()._fn_get_node_of_type.call(type)


func get_nodes_of_type(type: Variant) -> Array[Node]:
	return get_root()._fn_get_nodes_of_type.call(type)


## Returns the root of of this state's hierarchy.
## If this state is the root it will return its self.
func get_root() -> FrayCompoundState:
	var root := super.get_root()
	return root if root else self


## Returns [code]true[/code] if this state is the root of a hierarchy.
func is_root() -> bool:
	return super.get_root() == null


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
	var cur_state: FrayState = get_current_state()
	var has_substate_advanced := false

	if cur_state != null:
		if _astar.has_next_travel_point():
			#TODO: Traveling may need to be reapproach due to the _goto changes
			# further testing is required.
			var travel_state = cur_state
			while travel_state.is_done_processing() and _astar.has_next_travel_point():
				_goto(_astar.get_next_travel_point(), _travel_args)
				travel_state = get_state(_current_state)
		else:
			var next_state := get_next_state(input)

			if not next_state.is_empty():
				goto(next_state, args)
				return true

		if cur_state is FrayCompoundState:
			return cur_state.advance(input, args)

	return false


## Transitions from the current state to another state, following the shortest path.
## This transition ignores prerequisites and advance conditions, but waits until the current state finishes processing.
## If no valid travel path can be established, the [kbd]to[/kbd] state will be visited directly.
func travel(to: StringName, args: Dictionary = {}) -> void:
	if _ERR_INVALID_STATE(to):
		return

	if not _current_state.is_empty():
		_astar.compute_travel_path(_current_state, to)
		_travel_args = args

		if not _astar.has_next_travel_point():
			goto(to, args)


## Transitions from the current state to the target state by navigating the state hierarchy vertically.
## This method exits states leading up to the most common ancestor of the current state and the target state,
## and then enters states leading towards the target state.
## In a non-hierarchical system, it exits the current state and directly enters the specified state.
## If a travel is being performed it will be interupted.
func goto(path: StringName, args: Dictionary = {}) -> void:
	if not has_state(path):
		return

	if _astar.has_next_travel_point():
		_astar.clear_travel_path()

	_goto(path, args)


## Short hand for 'state.goto(state.start_state, args)'.
func goto_start(args: Dictionary = {}) -> void:
	if _start_state.is_empty():
		push_warning("Failed to go to start. Start state not set.")
		return

	goto(_start_state, args)


## Short hand for 'state.goto(state.end_state, args)'.
func goto_end(args: Dictionary = {}) -> void:
	if _end_state.is_empty():
		push_warning("Failed to go to end. End state not set.")
		return

	goto(_end_state, args)


## Adds a new [kbd]state[/kbd] under a given [kbd]name[/kbd].
func add_state(name: StringName, state: FrayState) -> void:
	if _ERR_FAILED_TO_ADD_STATE(name, state):
		return

	state._root_ref = _root_ref if _root_ref else weakref(self)
	state._parent_ref = weakref(self)
	_states[name] = state
	_astar.add_point(name)

	if _states.size() == 1:
		_start_state = name

	state._enter_tree_impl()
	state_added.emit(name, state)


## Removes the specified state.
func remove_state(name: StringName) -> void:
	if _ERR_INVALID_STATE(name):
		return

	var state: RefCounted = get_state(name)
	_states.erase(name)
	_astar.remove_point(name)

	if _tags_by_state.has(name):
		_tags_by_state.erase(name)

	_transitions = _transitions.filter(
		func(transition: _Transition): return transition.from != name and transition.to != name
	)

	_global_transitions = _global_transitions.filter(
		func(transition: _Transition): return transition.from != name and transition.to != name
	)

	state_removed.emit(name, state)


## Renames the specified state.
func rename_state(old_name: StringName, new_name: StringName) -> void:
	if _ERR_INVALID_STATE(old_name):
		return

	if has_state(new_name):
		push_warning("Failed to rename state. State with name %s already exists." % new_name)
		return

	_states[new_name] = _states[old_name]
	_states.erase(old_name)
	_astar.rename_point(old_name, new_name)

	if _tags_by_state.has(old_name):
		var tags: PackedStringArray = _tags_by_state[old_name]
		_tags_by_state.erase(old_name)
		_tags_by_state[new_name] = tags

	state_renamed.emit(old_name, new_name)


## Replaces the specified state's object.
func replace_state(name: StringName, replacement_state: FrayState) -> void:
	if _ERR_INVALID_STATE(name):
		return

	if replacement_state.has_parent():
		push_warning(
			(
				"Failed to replace state. Replacement state already belongs to parent state %s"
				% replacement_state.get_parent()
			)
		)
		return

	replacement_state._parent_ref = weakref(self)
	_states[name] = replacement_state


## Returns [code]true[/code] if the machine contains the specified state.
func has_state(path: StringName) -> bool:
	return get_state_or_null(path) != null


## Returns the sub-state object with the specified name if it exists.
func get_state(path: StringName) -> FrayState:
	return _get_state(path)


## Similar to [method get_state], but does not log an error if the state does not exist.
func get_state_or_null(path: StringName) -> FrayState:
	return _get_state(path, false)


## Returns the current state object if it is set.
## This is equivalent to calling [code]root.get_state_or_null(root.current_state)[/code].
func get_current_state() -> FrayState:
	return get_state_or_null(_current_state)


## Returns the name of the current state
func get_current_state_name() -> StringName:
	return _current_state


## Sets condition in this compound state.
## [br]
## [kbd]condition_name[/kbd] may contain only letters, digits, and underscores, and the first character may not be a digit.
## [br]
## [kbd]function[/kbd] is a parameterless function which returns a bool.
func set_condition(condition_name: String, function: Callable) -> void:
	if not condition_name.is_valid_identifier():
		push_error(
			"Failed to register condition named '%s'. Names may contain only letters, digits, and underscores, and the first character may not be a digit."
		)
		return

	if not function.is_valid():
		push_error("Failed to register function. Function is invalid.")
		return

	_condition_func_by_name[condition_name] = function


## Returns the value of a [kbd]condition[/kbd] if it exists.
## [br]
## The [code]![/code] prefix can be appended to the condition string to check for the inverted condition.
## [codeblock]
## # Suppose condition "on_hit" returns true
## is_condition_true("on_hit") -> true
## is_condition_true("!on_hit") -> false
## [/codeblock]
func is_condition_true(condition: String) -> bool:
	var root := get_root()

	# region Strictly check global
	var is_checking_global := condition.begins_with(_SYMBOL_STRICTLY_GLOBAL)
	condition = StringName(condition.trim_prefix(_SYMBOL_STRICTLY_GLOBAL))

	if is_checking_global:
		return root.is_condition_true(condition)
	# endregion

	# region Check local, then check global if it doesn't exist locally
	var is_inverted := condition.begins_with(_SYMBOL_NEGATION)
	condition = StringName(condition.trim_prefix(_SYMBOL_NEGATION))

	if not condition.is_valid_identifier():
		push_error(
			"Failed to check condition. Excluding the '$' and '!' prefix, names can only contain letters, digits, and underscores, and the first character may not be a digit."
		)
		return false

	if has_condition(condition):
		var function: Callable = _condition_func_by_name[condition]

		if not function.is_valid():
			push_error("Failed to check condition. Condition function is no longer valid.")
			return false

		var condition_status: bool = function.call()
		return condition_status and not is_inverted or not condition_status and is_inverted
	elif not is_root():
		return root.is_condition_true(condition)
	else:
		push_warning(
			(
				"Failed to check condition. Condition with name '%s' does not exist locally or globally"
				% condition
			)
		)
		return false
	# endregion


## Returns [code]true[/code] if the condition exists within the hiearchy.
func has_condition(condition: String) -> bool:
	return _condition_func_by_name.has(condition)


## Adds a transition between specified states.
func add_transition(
	from: StringName, to: StringName, transition: FrayStateMachineTransition
) -> void:
	if _ERR_INVALID_STATE(from):
		return
	if _ERR_INVALID_STATE(to):
		return

	var tr := _Transition.new()
	tr.from = from
	tr.to = to
	tr.transition = transition

	_astar.connect_points(from, to, has_transition(from, to))
	_transitions.append(tr)


## Removes transition between the two specified states if one exists.
func remove_transition(from: StringName, to: StringName) -> void:
	if _ERR_INVALID_STATE(from):
		return
	if _ERR_INVALID_STATE(to):
		return

	_astar.disconnect_points(from, to, not has_transition(from, to))

	for transition in _transitions:
		if transition.from == from and transition.to == to:
			_transitions.erase(transition)
			return


## Returns [code]true[/code] if transition between specified states exists.
func has_transition(from: StringName, to: StringName) -> bool:
	return get_transition(from, to) != null


## Returns transition between given states if it exists.
func get_transition(from: StringName, to: StringName) -> FrayStateMachineTransition:
	for transition in _transitions:
		if transition.from == from and transition.to == to:
			return transition.transition

	return null


## Returns the name of the next reachable state.
func get_next_state(input: Dictionary = {}) -> StringName:
	if _current_state.is_empty():
		push_warning("No current state is set.")
		return ""

	for tr in get_next_transitions(_current_state):
		var transition: FrayStateMachineTransition = tr.transition
		if _can_transition(transition) and _can_advance(transition, input):
			return tr.to
	return ""


## Returns an array of transitions traversable from the given state.
func get_next_transitions(from: StringName) -> Array[_Transition]:
	if _ERR_INVALID_STATE(from):
		return []

	var transitions: Array[_Transition]

	for transition in _transitions:
		if transition.from == from:
			transitions.append(transition)

	transitions.append_array(get_next_global_transitions(from))
	return transitions


## Sets the [kbd]tags[/kbd] associated with a [kbd]state[/kbd] if the state exists.
func set_state_tags(state: StringName, tags: PackedStringArray) -> void:
	if _ERR_INVALID_STATE(state):
		return

	_tags_by_state[state] = tags


## Gets the tags associated with a [kbd]state[/kbd] if the state exists.
func get_state_tags(state: StringName) -> PackedStringArray:
	if _ERR_INVALID_STATE(state) or not _tags_by_state.has(state):
		return PackedStringArray([])

	return _tags_by_state[state]


## Returns [code]true[/code] if the given state is considered global.
## [br]
## A state is considered global if a global transition to the state exists.
func is_state_global(state: StringName) -> bool:
	if _ERR_INVALID_STATE(state):
		return false

	for transition in _global_transitions:
		if transition.to == state:
			return true

	return false


## Adds global input transition to a state.
func add_global_transition(to: StringName, transition: FrayStateMachineTransition) -> void:
	if _ERR_INVALID_STATE(to):
		return

	var tr := _Transition.new()
	tr.to = to
	tr.transition = transition

	_global_transitions.append(tr)


## Adds global transition rule based on tags.
func add_global_transition_rule(from_tag: StringName, to_tag: StringName) -> void:
	if not _global_transition_rules.has(from_tag):
		_global_transition_rules[from_tag] = []

	_global_transition_rules[from_tag].append(to_tag)


## Removes a state's global transition.
func remove_global_transition(to_state: StringName) -> void:
	if not has_global_transition(to_state):
		push_warning(
			"Failed to remove global transition. State '%s' does not have a global transition"
		)
		return

	for transition in _global_transitions:
		if transition.to == to_state:
			_global_transitions.erase(transition)
			return


## Returns [code]true[/code] if a state has a global transition.
func has_global_transition(to_state: StringName) -> bool:
	for transition in _global_transitions:
		if transition.to == to_state:
			return true
	return false


## Returns [code]true[/code] if global transition rule exists.
func has_global_transition_rule(from_tag: StringName, to_tag: StringName) -> bool:
	return _global_transition_rules.has(from_tag) and _global_transition_rules[from_tag].has(to_tag)


## Removes specifc global transition rule from one tag to another.
func remove_global_transition_rule(from_tag: StringName, to_tag: StringName) -> void:
	if has_global_transition_rule(from_tag, to_tag):
		_global_transition_rules.erase(to_tag)


## Removes all global transitions from given tag.
func remove_all_global_transition_rule(from_tag: StringName) -> void:
	if _global_transition_rules.has(from_tag):
		_global_transition_rules.erase(from_tag)


## Returns array of next global transitions accessible from this state.
func get_next_global_transitions(from: StringName) -> Array[_Transition]:
	if _ERR_INVALID_STATE(from):
		return []

	var transitions: Array[_Transition]

	for from_tag in get_state_tags(from):
		if _global_transition_rules.has(from_tag):
			var to_tags: Array[StringName] = []
			to_tags.assign(_global_transition_rules[from_tag])

			for transition in _global_transitions:
				for to_tag in to_tags:
					if to_tag in get_state_tags(transition.to):
						transitions.append(transition)
	return transitions


## Retrieve the active state path from root to leaf and state object references.
## [br]
## Returns a dictionary with the following entries:
## [br] [br]
## - [code]path[/code] is a [String] path;
## [br] [br]
## - [code]states[/code] is an [Array] of [FrayState] containing a reference to every state object along the path;
func get_active_states_info() -> Dictionary:
	var active_state_names: PackedStringArray = []
	var active_state_objects: Array[FrayState] = []
	var active_state: FrayState = self

	while active_state != null:
		active_state_objects.append(active_state)

		if active_state is FrayCompoundState:
			active_state_names.append(active_state.get_current_state_name())
			active_state = active_state.get_current_state()
		else:
			break

	return {path = "/".join(active_state_names), states = active_state_objects}


## Readies child states then this state.
## This method is intended to only be used by the [FrayStateMachine].
## [br]
## [b]WARN:[/b] The dictionary provided to the context argument will be made read-only.
func ready(context: Dictionary) -> void:
	if not context.is_read_only():
		context.make_read_only()

	for state_name in _states:
		var state: FrayState = _states[state_name]

		if state is FrayCompoundState:
			state.ready(context)
		else:
			state._ready_impl(context)

	_ready_impl(context)


## Propogates input to this state then child states.
func input(event: InputEvent) -> void:
	_input_impl(event)

	if not _states.is_empty():
		var cur_state: FrayState = get_current_state()
		if cur_state != null:
			if cur_state is FrayCompoundState:
				cur_state.input(event)
			elif cur_state != null:
				cur_state._input_impl(event)


## Propogates unhandled input to this state then child states.
func unhandled_input(event: InputEvent) -> void:
	_unhandled_input_impl(event)

	if not _states.is_empty():
		var cur_state: FrayState = get_current_state()
		if cur_state != null:
			if cur_state is FrayCompoundState:
				cur_state.unhandled_input(event)
			elif cur_state != null:
				cur_state._unhandled_input_impl(event)


## Process child states then this state.
## This method is intended to only be used by the [FrayStateMachine].
func process(delta: float) -> void:
	if not _states.is_empty():
		var cur_state: FrayState = get_current_state()
		if cur_state is FrayCompoundState:
			cur_state.process(delta)
		elif cur_state != null:
			cur_state._process_impl(delta)

	_process_impl(delta)


## Physics process child states then this state.
## This method is intended to only be used by the [FrayStateMachine].
func physics_process(delta: float) -> void:
	if not _states.is_empty():
		var cur_state: FrayState = get_current_state()
		if cur_state != null:
			if cur_state is FrayCompoundState:
				cur_state.physics_process(delta)
			elif cur_state != null:
				cur_state._physics_process_impl(delta)

	_physics_process_impl(delta)


## Clears all states, transitions, rules, and conditions on this root state.
func clear() -> void:
	_states.clear()
	_global_transition_rules.clear()
	_tags_by_state.clear()
	_condition_func_by_name.clear()
	_travel_args.clear()
	_transitions.clear()
	_global_transitions.clear()
	_current_state = ""
	_start_state = ""
	_end_state = ""


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
		var modifiers := (
			"%s%s%s"
			% [
				"c" if state == _current_state else "-",
				"s" if state == _start_state else "-",
				"e" if state == _end_state else "-",
			]
		)

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


func _get_state(path: StringName, can_push_errors: bool = true) -> FrayState:
	var state_path := path.split("/")

	if state_path.is_empty():
		if can_push_errors:
			push_error("Invalid state path. Path can not be empty")
		return null

	if state_path.size() == 1:
		if _ERR_INVALID_STATE(state_path[0], can_push_errors):
			return null
		return _states[state_path[0]]

	var traversed_path: String = ""
	var next_state: FrayState = self
	for i in len(state_path):
		var state_name := state_path[i]
		var state: FrayState = next_state._states.get(state_name)
		traversed_path += state_name

		if state == null:
			if can_push_errors:
				push_error("Invalid state '%s'. State does not exist." % traversed_path)
			return null

		if not state is FrayCompoundState and i < len(state_path) - 1:
			push_warning("State '%s' is atomic and can not have sub-states" % traversed_path)
			return null

		next_state = state
		traversed_path += "/"

	return next_state


func _get_transition_priority(from: StringName, to: StringName) -> float:
	var tr := get_transition(from, to)
	return float(tr.transition.priority) if tr else 0.0


func _goto(path: StringName, args: Dictionary = {}) -> void:
	var target_state := get_state(path)

	if target_state == null:
		push_error("Failed to go to target state. State not found.")
		return

	# Find most common active ancestor of target and current active state.
	var active_path_info := get_active_states_info()
	var active_states: Array[FrayState] = active_path_info.states
	var common_active_ancestor: FrayState = target_state

	while common_active_ancestor != null and not common_active_ancestor in active_states:
		common_active_ancestor = common_active_ancestor.get_parent()

	# Exit all active states leading up to common ancestor excluding common ancestor
	for i in range(active_states.size() - 1, -1, -1):
		var state: FrayState = active_states[i]
		if state == common_active_ancestor:
			break

		state.exit()

	# Enter all states leading to target state excluding common ancestor
	var ancestor_path_index := active_states.find(common_active_ancestor)
	var new_active_state: FrayState = common_active_ancestor
	var state_paths := path.split("/")

	for i in range(ancestor_path_index, state_paths.size()):
		var next_state_name := state_paths[i]
		new_active_state._current_state = next_state_name
		new_active_state = new_active_state.get_state(next_state_name)
		new_active_state._enter_impl(args)

	transitioned.emit(active_path_info.path, path)


func _can_transition(transition: FrayStateMachineTransition) -> bool:
	return _is_all_conditions_true(transition.prereqs) and _can_switch(transition)


func _can_switch(transition: FrayStateMachineTransition) -> bool:
	return (
		transition.switch_mode == FrayStateMachineTransition.SwitchMode.IMMEDIATE
		or (
			transition.switch_mode == FrayStateMachineTransition.SwitchMode.AT_END
			and get_current_state()._is_done_processing_impl()
		)
	)


func _can_advance(transition: FrayStateMachineTransition, input: Dictionary) -> bool:
	return (
		transition.accepts(input)
		and (not transition.auto_advance or _is_all_conditions_true(transition.advance_conditions))
	)


func _is_all_conditions_true(conditions: PackedStringArray) -> bool:
	for condition in conditions:
		if not is_condition_true(condition):
			return false
	return true


func _ERR_FAILED_TO_ADD_STATE(name: StringName, state: FrayState) -> bool:
	if name.is_empty():
		push_error("Failed to add state. State name can not be empty.")
		return true

	if _states.has(name):
		push_error("Failed to add state. State with name %s already exists" % name)
		return true

	if state.has_parent():
		push_error(
			"Failed to add state. State object already belongs to parent %s" % state.get_parent()
		)
		return true

	return false


func _ERR_INVALID_STATE(name: StringName, can_push_errors: bool = true) -> bool:
	if name.is_empty():
		if can_push_errors:
			push_error("Invalid state name, name can not be empty")
		return true

	if not _states.has(name):
		if can_push_errors:
			push_error("Invalid state name '%s', state does not exist." % name)
		return true

	return false


class _Transition:
	extends RefCounted

	var from: StringName
	var to: StringName
	var transition: FrayStateMachineTransition


class Builder:
	extends RefCounted
	## Compound state builder
	##
	## The state machine builder can be used to create state machines programatically.
	## The builder supports using optional method chaining for the construction.
	## [br]
	## Example:
	##
	## [codeblock]
	## var sm = builder\
	## .transition("a", "b")\
	## .transition("b", "c")\
	## .build()
	## [/codeblock]
	##
	##	[br]Note:[/b] '\' is necessary for GDScript to read the next line when multi-line method chaning.

	# Type: Dictionary<StringName, FrayState>
	var _state_by_name: Dictionary

	# Type: Dictionary<StringName, StringName[]>
	# Hint: <from tag, to tags>
	var _transition_rules: Dictionary

	# Type: Dictionary<StringName, StringName[]>
	var _tags_by_state: Dictionary

	# Type: Dictionary<StringName, func() -> bool>
	var _condition_func_by_name: Dictionary

	var _global_transitions: Array[_Transition]
	var _transitions: Array[_Transition]
	var _start_state: StringName
	var _end_state: StringName
	var _is_persistent: bool = false
	var _first_state_added: StringName
	var _root := FrayCompoundState.new()
	var _default_state := FrayState.new()
	var _default_transition := FrayStateMachineTransition.new()

	## Returns a newly constructed state machine state.
	## [br]
	## Constructs a state machine using the current build configuration.
	## After building the builder is reset and can be used again.
	## Keep in mind that the condition cache does not reset autoatmically.
	func build() -> FrayCompoundState:
		return _build_impl()

	## Sets the root object that this builder will use. Root will be cleared before use.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	func set_root(root: FrayCompoundState) -> Builder:
		_root = root
		return self

	## Forces the builder to instatiate states with duplicates of the given [kdb]state[/kdb] for every state added after this call.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	func set_default_state(state: FrayState) -> Builder:
		_default_state = state
		return self

	## Forces the builder to instatiate transitions with duplicates of the given [kdb]transition[/kdb] for every transition added after this call.
	## This includes both local and global transitions.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	func set_default_transition(sm_transition: FrayStateMachineTransition) -> Builder:
		_default_transition = sm_transition
		return self

	## Adds a new state to the state machine.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [b]Note[/b]:
	## States are added automatically when making transitions.
	## So unless you need to provide a specific state object
	## or add a state with no transitions
	## calling this method is unncessary.
	func add_state(name: StringName, state: FrayState = _default_state.duplicate()) -> Builder:
		if name.is_empty():
			push_error("State name can not be empty")
		else:
			_state_by_name[name] = state

			if _first_state_added.is_empty():
				_first_state_added = name
		return self

	## Creates a new transition from one state to another.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [kbd]config[/kbd] is an optional dictionary used to configure [FrayStateMachineTransition] properties.
	func transition(
		from: StringName,
		to: StringName,
		config: Dictionary = {},
		sm_transition: FrayStateMachineTransition = _default_transition.duplicate()
	) -> Builder:
		var tr := _create_transition(from, to, sm_transition)
		_configure_transition(tr.transition, config)
		return self

	## Creates a new global transtion to the specified state.
	func transition_global(
		to: StringName,
		config: Dictionary = {},
		sm_transition: FrayStateMachineTransition = _default_transition.duplicate()
	) -> Builder:
		var tr := _create_global_transition(to, sm_transition)
		_configure_transition(tr.transition, config)
		return self

	## Creates a new input press transition from one state to another.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionPress] properties.
	func transition_press(from: StringName, to: StringName, config: Dictionary = {}) -> Builder:
		var transition := _create_transition(from, to, FrayInputTransitionPress.new()).transition
		_configure_transition(transition, config)
		return self

	## Creates a new inupt sequence transition from one state to another.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
	func transition_sequence(from: StringName, to: StringName, config: Dictionary = {}) -> Builder:
		var transition := _create_transition(from, to, FrayInputTransitionSequence.new()).transition
		_configure_transition(transition, config)
		return self

	## Creates a new global input button transition from one state to another.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionPress] properties.
	func transition_press_global(to: StringName, config: Dictionary = {}) -> Builder:
		var tr := _create_global_transition(to, FrayInputTransitionPress.new())
		_configure_transition(tr.transition, config)
		return self

	## Creates a new global input sequence transition from one state to another.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	## [br][br]
	## [kbd]config[/kbd] is an optional dictionary used to configure [FrayInputTransitionSequence] properties.
	func transition_sequence_global(to: StringName, config: Dictionary = {}) -> Builder:
		var tr := _create_global_transition(to, FrayInputTransitionSequence.new())
		_configure_transition(tr.transition, config)
		return self

	## Sets the starting state.
	## State used will automatically be added.
	## [br]
	## Returns a reference to this builder
	func start_at(state: StringName) -> Builder:
		_add_state_once(state)
		_start_state = state
		return self

	## Sets the end state.
	## State used will automatically be added.
	## [br]
	## Returns a reference to this builder
	func end_at(state: StringName) -> Builder:
		_add_state_once(state)
		_end_state = state
		return self

	## Enables persistence.
	## [br]
	## Returns a reference to this builder.
	func is_persistent() -> Builder:
		_is_persistent = true
		return self

	## Adds a new transition rule to be used by global transitions.
	## [br]
	## Returns a reference to this builder.
	func add_rule(from_tag: StringName, to_tag: StringName) -> Builder:
		if not _transition_rules.has(from_tag):
			_transition_rules[from_tag] = []
		_transition_rules[from_tag].append(to_tag)
		return self

	## Appends given tags onto all given states.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	func tag_multi(states: PackedStringArray, tags: PackedStringArray) -> Builder:
		for state in states:
			tag(state, tags)
		return self

	## Appends given tags onto given state.
	## States used will automatically be added.
	## [br]
	## Returns a reference to this builder
	func tag(state: StringName, tags: PackedStringArray) -> Builder:
		_add_state_once(state)

		if not _tags_by_state.has(state):
			_tags_by_state[state] = []

		for tag in tags:
			if not _tags_by_state[state].has(tag):
				_tags_by_state[state].append(tag)
		return self

	## Registers conditions for use within this compound state.
	## A condition is a string name mapped to a parameterless function that returns a bool.
	## All composite stats within a hiearchy reference the root's conditions.
	## Conditions should only be declared once on the root.
	## [br]
	## Returns a reference to this builder
	## [br]
	## [kbd]func_by_name[/kbd] is a dictioanry of type <StringName, func() -> bool>.
	func register_conditions(func_by_name: Dictionary) -> Builder:
		_condition_func_by_name = func_by_name
		return self

	## Clears builder state not including cache
	func clear() -> void:
		_clear_impl()

	func _create_transition(
		from: StringName, to: StringName, transition: FrayStateMachineTransition
	) -> _Transition:
		var tr := _Transition.new()
		tr.from = from
		tr.to = to
		tr.transition = transition

		_add_state_once(from)
		_add_state_once(to)
		_transitions.append(tr)
		return tr

	func _create_global_transition(
		to: StringName, transition: FrayStateMachineTransition
	) -> _Transition:
		var tr := _Transition.new()
		tr.to = to
		tr.transition = transition
		_add_state_once(to)
		_global_transitions.append(tr)
		return tr

	func _add_state_once(state: StringName) -> void:
		if not _state_by_name.has(state):
			add_state(state)

	func _configure_transition(transition: FrayStateMachineTransition, config: Dictionary) -> void:
		for property in config:
			if transition.get(property) != null:
				var data = config[property]

				if data is Array and data.is_typed():
					transition[property].assign(data)
				else:
					transition[property] = data
			else:
				var transition_properties: Array = transition.get_property_list().map(
					func(prop): return prop.name
				)
				var most_similar_prop := ""

				if not transition_properties.is_empty():
					var greatest_sim_index := 0.0

					for prop in transition_properties:
						var sim_index: float = property.similarity(prop)

						if sim_index > greatest_sim_index and sim_index >= .4:
							most_similar_prop = prop
							greatest_sim_index = sim_index

				var warning: String = ""

				warning += "Failed to set transition property."
				warning += "\nTransition does not contain a property named: '%s'" % property

				if not most_similar_prop.is_empty():
					warning += "\nDid you mean: '%s'" % most_similar_prop

				push_warning(warning)

	func _configure_state_machine_impl(root: FrayCompoundState) -> void:
		for state_name in _state_by_name:
			root.add_state(state_name, _state_by_name[state_name])

		for tr in _transitions:
			root.add_transition(tr.from, tr.to, tr.transition)

		if not _start_state.is_empty():
			root.start_state = _start_state
		else:
			root.start_state = _first_state_added

		if not _end_state.is_empty():
			root.end_state = _end_state

		for state in _tags_by_state:
			root.set_state_tags(state, _tags_by_state[state])

		for from_tag in _transition_rules:
			for to_tag in _transition_rules[from_tag]:
				root.add_global_transition_rule(from_tag, to_tag)

		for g_tr in _global_transitions:
			root.add_global_transition(g_tr.to, g_tr.transition)

		for condition_name in _condition_func_by_name:
			var function: Callable = _condition_func_by_name[condition_name]
			root.set_condition(condition_name, function)

		root.is_persistent = _is_persistent

	func _build_impl() -> FrayCompoundState:
		_root.clear()
		_configure_state_machine_impl(_root)
		return _root

	func _clear_impl() -> void:
		_state_by_name.clear()
		_transitions.clear()
		_transition_rules.clear()
		_tags_by_state.clear()
		_global_transitions.clear()

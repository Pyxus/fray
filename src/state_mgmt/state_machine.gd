@icon("res://addons/fray/assets/icons/state_machine.svg")
class_name FrayStateMachine
extends Node
## General purpose hierarchical state machine
##
## This class wraps around the [FrayCompoundState] and uses the [SceneTree] to
## process state nodes.

## Emitted when the current state within the root changes.
signal state_changed(from: StringName, to: StringName)

enum AdvanceMode {
	IDLE,  ## Advance during the idle process
	PHYSICS,  ## Advance during the physics process
	MANUAL,  ## Advance manually
}

## If true the [FrayStateMachine] will be processing.
@export var active: bool = false

## Determines the process during which the state machine can advance.
## Advancing only relates to transitions.
## If the state machine is active then the current state is still processed
## during both idle and physics frames regardless of advance mode.
@export var advance_mode: AdvanceMode = AdvanceMode.IDLE

var _root: FrayCompoundState

func _input(event: InputEvent) -> void:
	if _can_process():
		_root.input(event)


func _unhandled_input(event: InputEvent):
	if _can_process():
		_root.unhandled_input(event)


func _process(delta: float) -> void:
	if _can_process():
		_root.process(delta)

		if advance_mode == AdvanceMode.IDLE:
			advance()


func _physics_process(delta: float) -> void:
	if _can_process():
		_root.physics_process(delta)

		if advance_mode == AdvanceMode.PHYSICS:
			advance()

## Used to initialize the root of the state machine.
## [br]
## [kbd]context[/kbd] is an optional dictionary which can pass read-only data to all states within the hierarchy. 
## This data is accessible within a state's [method FrayState._ready_impl] method when it is invoked.
## [br]
## [b]WARN:[/b] The dictionary provided to the context argument will be made read-only. 
func initialize(context: Dictionary, root: FrayCompoundState) -> void:
	_root = root
	_root.ready(context)
	_root._enter_impl({})
	_root.transitioned.connect(_on_RootState_transitioned)

## Returns the state machine root.
func get_root() -> FrayCompoundState:
	return _root

## Used to manually advance the state machine.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	if _can_process():
		return _advance_impl(input, args)
	return false


## Returns the name of the root's current state.
## [br]
## Shorthand for root.get_current_state_name()
func get_current_state_name() -> StringName:
	if _ERR_ROOT_NOT_SET("Failed to travel"):
		return ""
	return _root.get_current_state_name()


## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the [kbd]to[/kbd] state will be visted directly.
## [br]
## Shorthand for root.travel(input, args)
func travel(to: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to travel"):
		return

	_root.travel(to, args)


## Goes directly to the given state if it exists.
## If a travel is being performed it will be interupted.
## [br]
## Shorthand for root.goto(path, args)
func goto(path: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to state"):
		return

	_root.goto(path, args)


## Goes directly to the start state.
## [br]
## Shorthand for root.goto_start()
func goto_start(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to start state"):
		return

	_root.goto_start(args)


## Goes directly to the end state.
## [br]
## Shorthand for root.goto_start()
func goto_end(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to end state"):
		return

	_root.goto_end(args)


## [code]Virtual method[/code] used to implement [method advance] method.
func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> bool:
	if get_current_state_name().is_empty():
		push_warning("Failed to advance. Current state not set.")
		return false

	return _root.advance(input, args)


func _can_process() -> bool:
	return _root != null and active


func _ERR_ROOT_NOT_SET(msg: String = "") -> bool:
	if _root == null:
		push_error("%s. Current state not set." % msg)
		return true

	return false


func _on_RootState_transitioned(from: StringName, to: StringName) -> void:
	state_changed.emit(from, to)

@icon("res://addons/fray/assets/icons/state_machine.svg")
class_name FrayStateMachine
extends Node
## General purpose hierarchical state machine
##
## This class wraps around the [FrayCompositeState] and uses the [SceneTree] to
## process state nodes.

## Emitted when the current state within the root changes.
signal state_changed(from: StringName, to: StringName)

enum AdvanceMode{
	IDLE, ## Advance during the idle process
	PHYSICS, ## Advance during the physics process
	MANUAL, ## Advance manually
}

## If true the combat state machine will be processing.
@export var active: bool = false

## Determines the process during which the state machine can advance.
## Advancing only relates to transitions. 
## If the state machine is active then the current state is still processed
## during both idle and physics frames regardless of advance mode.
@export var advance_mode: AdvanceMode = AdvanceMode.IDLE
 
## The root of this state machine.
var root: FrayCompositeState:
	get: return _root
	set(value): _set_root(value)

## The state machine's current state.
## Updating this value is the equivalent to calling [code]goto(state)[/code].
var current_state: StringName = "":
	get: 
		if _ERR_ROOT_NOT_SET("Failed to get current state"): return ""
		return _root.current_state
	set(value):
		if _ERR_ROOT_NOT_SET("Failed to set current state"): return

		root.current_state = value

var _root: FrayCompositeState

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

## Used to manually advance the state machine.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if _can_process():
		_advance_impl()

## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the [kbd]to[/kbd] state will be visted directly.
func travel(to: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to travel"): return

	_root.travel(to, args)

## Goes directly to the given state if it exists.
## If a travel is being performed it will be interupted.
## [br]
## Shorthand for _root.goto_start()
func goto(path: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to state"): return

	_root.goto(path, args)
		

## Goes directly to the start state.
## [br]
## Shorthand for _root.goto_start()
func goto_start(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to start state"): return
	
	_root.goto_start(args)


## Goes directly to the end state.
## [br]
## Shorthand for _root.goto_start()
func goto_end(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to end state"): return

	_root.goto_end(args)


## [code]Virtual method[/code] used to implement [method advance] method.
func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if _root.current_state.is_empty():
		push_warning("Failed to advance. Current state not set.")
		return
	
	_root.advance(input, args)


func _can_process() -> bool:
	return _root != null and active


func _set_root(value: FrayCompositeState):
	if _root != null and _root.transitioned.is_connected(_on_RootState_transitioned):
		_root.transitioned.disconnect(_on_RootState_transitioned)
	
	_root = value
	_root._enter_impl({})
	_root.transitioned.connect(_on_RootState_transitioned)


func _ERR_ROOT_NOT_SET(msg: String = "") -> bool:
	if _root == null:
		push_error("%s. Current state not set." % msg)
		return true
	
	return false

func _on_RootState_transitioned(from: StringName, to: StringName) -> void:
	state_changed.emit(from, to)

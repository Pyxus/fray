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

## If true the [FrayStateMachine] will be processing.
@export var active: bool = false

## Determines the process during which the state machine can advance.
## Advancing only relates to transitions. 
## If the state machine is active then the current state is still processed
## during both idle and physics frames regardless of advance mode.
@export var advance_mode: AdvanceMode = AdvanceMode.IDLE
 
## The root of this state machine.
var root: FrayCompositeState:
	get: return root
	set(value):
		if root != null and root.transitioned.is_connected(_on_RootState_transitioned):
			root.transitioned.disconnect(_on_RootState_transitioned)
		
		root = value
		root._enter_impl({})
		root.transitioned.connect(_on_RootState_transitioned)


func _process(delta: float) -> void:
	if _can_process():
		root.process(delta)
		
		if advance_mode == AdvanceMode.IDLE:
			advance()


func _physics_process(delta: float) -> void:
	if _can_process():
		root.physics_process(delta)

		if advance_mode == AdvanceMode.PHYSICS:
			advance()

## Used to manually advance the state machine.
func advance(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if _can_process():
		_advance_impl()

## Returns the name of the root's current state.
## [br]
## Shorthand for root.get_current_state_name()
func get_current_state_name() -> StringName:
	if _ERR_ROOT_NOT_SET("Failed to travel"): return ""
	return root.get_current_state_name()

## Transitions from the current state to another one, following the shortest path.
## Transitions will ignore prerequisites and advance conditions, but will wait until a state is done processing.
## If no travel path can be formed then the [kbd]to[/kbd] state will be visted directly.
## [br]
## Shorthand for root.travel(input, args)
func travel(to: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to travel"): return

	root.travel(to, args)

## Goes directly to the given state if it exists.
## If a travel is being performed it will be interupted.
## [br]
## Shorthand for root.goto(path, args)
func goto(path: StringName, args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to state"): return

	root.goto(path, args)
		

## Goes directly to the start state.
## [br]
## Shorthand for root.goto_start()
func goto_start(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to start state"): return
	
	root.goto_start(args)


## Goes directly to the end state.
## [br]
## Shorthand for root.goto_start()
func goto_end(args: Dictionary = {}) -> void:
	if _ERR_ROOT_NOT_SET("Failed to go to end state"): return

	root.goto_end(args)


## [code]Virtual method[/code] used to implement [method advance] method.
func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if root.current_state.is_empty():
		push_warning("Failed to advance. Current state not set.")
		return
	
	root.advance(input, args)


func _can_process() -> bool:
	return root != null and active


func _ERR_ROOT_NOT_SET(msg: String = "") -> bool:
	if root == null:
		push_error("%s. Current state not set." % msg)
		return true
	
	return false

func _on_RootState_transitioned(from: StringName, to: StringName) -> void:
	state_changed.emit(from, to)

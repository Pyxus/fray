class_name FrayStateMachine
extends Node
## Base Hierarchical State Machine

const StateNodeStateMachine = preload("node/state_node_state_machine.gd")

enum AdvanceMode{
	PROCESS, ## Advance during the physics process
	PHYSICS, ## Advance during the idle process
	MANUAL, ## Advance manually
}

## The process mode of this state machine.
@export var advance_mode: AdvanceMode = AdvanceMode.PROCESS

## If true the combat state machine will be processing.
@export var active: bool

## The root state machine node.
var root: StateNodeStateMachine:
	set(value):
		set_root(value)

func _process(delta: float) -> void:
	if _can_process():
		root.process(delta)
		
		if advance_mode == AdvanceMode.PROCESS:
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
		

## Setter for [member root] property.
func set_root(value: StateNodeStateMachine) -> void:
	root = value


func _can_process() -> bool:
	return root != null and active

## [code]Virtual method[/code] used to implement [method advance] method
func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if root.current_node.is_empty():
		push_warning("Failed to advance. Current state not set.")
		return
	
	root.advance(input, args)

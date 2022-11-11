extends Node
## Base Hierarchical State Machine

const StateNodeStateMachine = preload("node/state_node_state_machine.gd")

enum AdvanceMode{
	IDLE,
	PHYSICS,
	MANUAL,
}

## The process mode of this state machine.
export(AdvanceMode) var advance_mode: int = AdvanceMode.IDLE

## If true the combat state machine will be processing.
export var active: bool

## The root state machine node.
var root: StateNodeStateMachine setget set_root

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
		

## Setter for `root` property.
func set_root(value: StateNodeStateMachine) -> void:
	root = value


func _can_process() -> bool:
	return root != null and active

## Virtual method used to implement advance procedure
func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
	if root.current_node.empty():
		push_warning("Failed to advance. Current state not set.")
		return
	
	root.advance(input, args)

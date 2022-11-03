extends Node
## Base Hierarchical State Machine

const GraphNode = preload("graph_node/graph_node.gd")
const GraphNodeStateMachine = preload("graph_node/graph_node_state_machine.gd")

enum AdvanceMode{
	IDLE,
	PHYSICS,
	MANUAL,
}

## If true the combat state machine will be processing.
export var active: bool

## The process mode of this state machine.
export(AdvanceMode) var advance_mode: int = AdvanceMode.IDLE


func _process(delta: float) -> void:
    if _can_process():
        var root := _get_root_impl()

        root.process(delta)
        
        if advance_mode == AdvanceMode.IDLE:
            root.advance()


func _physics_process(delta: float) -> void:
    if _can_process():
        var root := _get_root_impl()

        root.physics_process(delta)

        if advance_mode == AdvanceMode.PHYSICS:
            root.advance()


func advance(input: Dictionary = {}, args: Dictionary = {}) -> void:
    if _can_process() and advance_mode == AdvanceMode.MANUAL:
        _advance_impl()
        

func _can_process() -> bool:
    return _get_root_impl() != null and active


func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
    if _can_process():
        _get_root_impl().advance(input, args)


func _get_root_impl() -> GraphNodeStateMachine:
    push_error("Method not implemented.")
    return null
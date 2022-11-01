extends Node
## Hierarchical State Machine

const State = preload("state/state.gd")
const StateCompound = preload("state/state_compound.gd")

enum AdvanceMode{
	IDLE,
	PHYSICS,
	MANUAL,
}

## If true the combat state machine will be processing.
export var active: bool

## The process mode of this state machine.
export(AdvanceMode) var advance_mode: int = AdvanceMode.IDLE

var root := StateCompound.new() setget set_root


func _process(delta: float) -> void:
    if _can_process():
        root.process(delta)
        
        if advance_mode == AdvanceMode.IDLE:
            root.advance()


func _physics_process(delta: float) -> void:
    if _can_process():
        root.physics_process(delta)

        if advance_mode == AdvanceMode.PHYSICS:
            root.advance()


func set_root(root_state: StateCompound) -> void:
    root = root_state
    root.start()


func advance(input: Dictionary = {}, args: Dictionary = {}) -> void:
    if _can_process() and advance_mode == AdvanceMode.MANUAL:
        _advance_impl()
        

func _can_process() -> bool:
    return root != null and active


func _advance_impl(input: Dictionary = {}, args: Dictionary = {}) -> void:
    root.advance(input, args)

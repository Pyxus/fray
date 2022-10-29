extends Node
## Hierarchical State Machine

const State = preload("state/state.gd")
const StateCompound = preload("state/state_compound.gd")

enum ProcessMode{
	IDLE,
	PHYSICS,
	MANUAL,
}

## If true the combat state machine will be processing.
export var active: bool

## The process mode of this state machine.
export(ProcessMode) var process_mode: int = ProcessMode.IDLE

var root := StateCompound.new()


func _process(delta: float) -> void:
    if _can_process() and process_mode == ProcessMode.IDLE:
        _physics_mode_impl(delta)
        root.process(delta)
        root.advance()


func _physics_process(delta: float) -> void:
    if _can_process() and process_mode == ProcessMode.IDLE:
        _idle_mode_impl(delta)
        root.physics_process(delta)
        root.advance()


func advance() -> void:
    if _can_process() and process_mode == ProcessMode.MANUAL:
        _advance_impl()
        

func _can_process() -> bool:
    return root != null and active


func _advance_impl() -> void:
    pass


func _physics_mode_impl(_delta: float) -> void:
    pass


func _idle_mode_impl(_delta: float) -> void:
    pass
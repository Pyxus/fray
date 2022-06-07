extends "res://addons/fray/lib/state_machine/transition.gd"
## Used to represent an input based transition

# Imports
const InputCondition = preload("conditions/input_condition.gd")

## Input condition corresponding to this transition
var input_condition: InputCondition

## Array of evaluated conditions that need to be true for this transition to occur.
var prerequisites: Array # EvaluatedCondition[]

## The minimum amount of time that must occur between inputs
var min_input_delay: float


func _init(t_input_condition: InputCondition = null, t_prerequisites: Array = [], t_min_input_delay: float = 0) -> void:
	input_condition = t_input_condition
	prerequisites = t_prerequisites
	min_input_delay = t_min_input_delay

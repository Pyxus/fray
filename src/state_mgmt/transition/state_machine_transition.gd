class_name FrayStateMachineTransition
extends Resource
## Represents transition from one state to another.

enum SwitchMode{
	IMMEDIATE, ## Switch to the next state immediately.
	AT_END, ## Wait for the current state to finish processing, then switch to the beginning of the next state.
}

## If [member auto_advance] is enabled then the transition will occur automatically when all advance conditions are true.
@export var advance_conditions: PackedStringArray

## Prevents transition from occuring unless all prerequisite conditions are true.
@export var prereqs: PackedStringArray

## If true then the transition can advance automatically.
@export var auto_advance: bool = false

## Lower priority transitions are be preffered when determining next transitions.
@export var priority: int = 0

## The transition type.
@export var switch_mode: SwitchMode = SwitchMode.AT_END

## Returns true if the transition accepts the given input.
func accepts(input: Dictionary) -> bool:
	return _accepts_impl(input)

## [code]Virtual method[/code] used to implement [method accepts] method.
func _accepts_impl(input: Dictionary) -> bool:
	return true

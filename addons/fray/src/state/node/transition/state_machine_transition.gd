class_name FrayStateMachineTransition
extends RefCounted
## Represents transition from one state to another

enum SwitchMode{
	IMMEDIATE, ## Switch to the next state immediately.
	AT_END, ## Wait for the current state to end, then switch to the beginning of the next state.
}

## If [member auto_advance] is enabled then the transition will occur automatically when all advance conditions are true.
var advance_conditions: Array[FrayCondition]

## Prevents transition from occuring unless all prerequisite conditions are true.
var prereqs: Array[FrayCondition]

## If true then the transition can advance automatically
var auto_advance: bool

## Lower priority transitions are be preffered when determining next transitions
var priority: int

## The transition type
var switch_mode: int = SwitchMode.IMMEDIATE

## Returns true if the transition accepts the given input
func accepts(input: Dictionary) -> bool:
	return _accepts_impl(input)

## [code]Virtual method[/code] used to implement [method accepts] method
func _accepts_impl(input: Dictionary) -> bool:
	return true

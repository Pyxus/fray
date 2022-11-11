extends Reference
## Represents transition from one state to another

enum SwitchMode{
	IMMEDIATE,
	AT_END,
}

## If 'auto_advance' is enabled then transition will occur automatically when all advance conditions are true.
## Type: Condition[]
var advance_conditions: Array

## Prevents transition from occuring unless all prerequisite conditions are true.
## Type: Condition[]
var prereqs: Array

## If true then the transition can advance automatically
var auto_advance: bool

## A lower priotiy transitions are be preffered when determining next transitions
var priority: int

## The transition type
var switch_mode: int = SwitchMode.IMMEDIATE

## Returns true if the transition accepts the given input
func accepts(input: Dictionary) -> bool:
	return _accepts_impl(input)

## Virtual method used to implement `accepts`
func _accepts_impl(input: Dictionary) -> bool:
	return true

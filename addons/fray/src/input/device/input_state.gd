class_name FrayInputState
extends RefCounted
## Used by FrayInput to track state of individual inputs

## Set of composites this input is used in
# Type: Peudo-HashSet
var composites_used_in: Dictionary

## Name of this input
var input: StringName

## Physics frame this input was pressed
var physics_frame: int = -1

## Process frame this input was pressed
var process_frame: int = -1

## Time in miliseconds this input was pressed
var time_pressed: int = -1

## Press intensity of this input.
## [br]
## Will be 0 or 1 for inputs with boolean state.
var strength: float

## If [code]true[/code] then the input was pressed.
var is_pressed: bool

## If [code]true[/code] then the input was pressed virtually.
var is_virtually_pressed: bool

## If [code]true[/code] then the input is considered pressed without any overlapping inputs.
var is_distinct: bool = true


func _init(input_name: StringName) -> void:
	input = input_name

## Presses the input and records the new input state.
func press(is_virtual_press: bool = false) -> void:
	is_pressed = true
	physics_frame = Engine.get_physics_frames()
	process_frame = Engine.get_process_frames()
	time_pressed = Time.get_ticks_msec()
	is_virtually_pressed = is_virtual_press

	if strength <= 0:
		strength = 1

## Unpresses the input and records the new input state.
func unpress() -> void:
	is_pressed = false
	physics_frame = Engine.get_physics_frames()
	process_frame = Engine.get_process_frames()
	strength = 0
	composites_used_in.clear()
	is_distinct = true

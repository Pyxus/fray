extends RefCounted
## Used by FrayInput to track state of individual inputs

## Type: Peudo-HashSet
var composites_used_in: Dictionary

var input: String
var pressed: bool
var virtually_pressed: bool
var physics_frame: int = -1
var idle_frame: int = -1
var time_pressed: int = -1
var strength: float
var is_distinct: bool = true

func _init(input_name: String) -> void:
	input = input_name


func press(is_virtual_press: bool = false) -> void:
	pressed = true
	physics_frame = Engine.get_physics_frames()
	idle_frame = Engine.get_process_frames()
	time_pressed = Time.get_ticks_msec()
	virtually_pressed = is_virtual_press

	if strength <= 0:
		strength = 1


func unpress() -> void:
	pressed = false
	physics_frame = Engine.get_physics_frames()
	idle_frame = Engine.get_process_frames()
	strength = 0
	composites_used_in.clear()
	is_distinct = true

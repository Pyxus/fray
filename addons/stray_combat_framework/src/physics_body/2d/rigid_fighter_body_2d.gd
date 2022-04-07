tool
extends "character_body_2d.gd"

## docstring

#inner classes

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var max_motion: Vector2 = Vector2(1000, 1000)
var speed_on_slope: float = 600

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	pass


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	._integrate_forces(state)
	
	_handle_movement(state)
	
	state.linear_velocity.y += 3000 * state.step
	
	if not is_force_resolution_allowed() and is_on_slope():
		var floor_normal := get_floor_normal()

		if not is_zero_approx(state.linear_velocity.x) and not floor_normal.is_equal_approx(Vector2.ZERO):
			var slide_vec := state.linear_velocity.slide(floor_normal).normalized() * speed_on_slope
			state.linear_velocity = slide_vec
		else:
			state.linear_velocity.y = 0
			state.linear_velocity.x = 0

	state.linear_velocity.x = clamp(state.linear_velocity.x, -max_motion.x, max_motion.x)
	state.linear_velocity.y = clamp(state.linear_velocity.y, -max_motion.y, max_motion.y)


func _handle_movement(state: Physics2DDirectBodyState) -> void:
	pass


#signal methods

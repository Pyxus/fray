extends "character_body_2d.gd"
## docstring

#inner classes

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var gravity: float = 4000
var speed_on_slope: float = 600

var _float_timer: Timer
var _jump_reset_timer: Timer

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	_float_timer =  Timer.new()
	_jump_reset_timer = Timer.new()

	add_child(_jump_reset_timer)
	add_child(_float_timer)
	
	_float_timer.one_shot = true
	_jump_reset_timer.one_shot = true


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	._integrate_forces(state)
	
	state.linear_velocity.y += gravity * state.step
	state.linear_velocity.y = clamp(state.linear_velocity.y, -2000, 2000)
	
	_handle_movement(state)
	
	if is_on_slope() and _jump_reset_timer.is_stopped():
		update_contacts()
		var floor_normal := get_floor_normal()
		if state.linear_velocity.x != 0 and floor_normal != Vector2.ZERO:
			var slide_vec := state.linear_velocity.slide(floor_normal).normalized() * speed_on_slope
			state.linear_velocity = slide_vec
		else:
			state.linear_velocity.y = 0
	
func jump(state: Physics2DDirectBodyState, jump_speed: float):
	if _jump_reset_timer.is_stopped():
		state.linear_velocity.y = -abs(jump_speed)
		_jump_reset_timer.start(.1)

func _handle_movement(state: Physics2DDirectBodyState) -> void:
	pass

#signal methods

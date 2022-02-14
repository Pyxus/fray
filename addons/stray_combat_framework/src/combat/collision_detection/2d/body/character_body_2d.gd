tool
extends RigidBody2D
## docstring

#inner classes

#signals

enum Contact{
	FLOOR,
	SLOPE,
	CEILING,
	WALL_L,
	WALL_R,
}

#constants

#preloaded scripts and scenes

#exported variables

var contact_update_interval: float = .06

var _contact_timer: Timer = Timer.new()
var _force_resolution_timer: Timer = Timer.new()

var _last_contact_count: int = 0
var _floor_normal: Vector2 = Vector2.ZERO
var _contacts: Dictionary = {
	Contact.FLOOR : false,
	Contact.CEILING : false,
	Contact.WALL_L : false,
	Contact.WALL_R : false,
	Contact.SLOPE : false,
}

onready var _body_state: Physics2DDirectBodyState = Physics2DServer.body_get_direct_state(get_rid())


func _init() -> void:
	mode = MODE_CHARACTER

func _ready() -> void:
	add_child(_contact_timer)
	add_child(_force_resolution_timer)
	_force_resolution_timer.autostart = false
	_force_resolution_timer.one_shot = true
	_contact_timer.autostart = false
	_contact_timer.one_shot = true

func _physics_process(delta: float) -> void:
	pass

func _get_configuration_warning() -> String:
	if not contact_monitor:
		return "Contact monitor needs to be enabled."
	
	if contacts_reported == 0:
		return "At least 1 contacts reported is required. 3 is recommended."
	return ""

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	_body_state = state
	var contact_count := state.get_contact_count()
	
	if contact_count > 0:
		_contact_timer.stop()
	
	update_contacts()
		
	_last_contact_count = contact_count


func allow_force_resolution(force_resolution_duration: float = 0.1) -> void:
	_force_resolution_timer.start(force_resolution_duration)


func halt_force_resolution() -> void:
	_force_resolution_timer.stop()
	
	
func is_force_resolution_allowed() -> bool:
	return not _force_resolution_timer.is_stopped()
	

func apply_impulse(offset: Vector2, impulse: Vector2) -> void:
	.apply_impulse(offset, impulse)
	allow_force_resolution()
	
# TODO: So I think the original idea of this was some kind of performancing saving measure... Maybe?
# Can't remmeber and im not sure if this is useful. Consider removing.
func update_contacts() -> void:
	if _contact_timer.is_stopped():
		var contact_count := _body_state.get_contact_count()
		if contact_count == 0 and contact_count != _last_contact_count:
			_contact_timer.start(contact_update_interval)
		else:
			_contacts[Contact.CEILING] = is_on_ceiling(true)
			_contacts[Contact.FLOOR] = is_on_floor(true)
			_contacts[Contact.WALL_L] = is_on_wall_left(true)
			_contacts[Contact.WALL_R] = is_on_wall_right(true)
			_contacts[Contact.SLOPE] = is_on_slope(true)
			_floor_normal = get_floor_normal(true)

func calc_jump_motion(apex: float, time_until_apex: float, time_until_land: float) -> Dictionary:
	var jump_veloicty := (-2.0 * apex) / time_until_apex
	var jump_gravity := (2.0 * apex) / (time_until_apex * time_until_apex)
	var fall_gravity := (2.0 * apex) / (time_until_land * time_until_land)
	return {"jump_velocity" : jump_veloicty, "jump_gravity" : jump_gravity, "fall_gravity" : fall_gravity}

func is_on_surface(surface_normal: Vector2, tolerance: float = .6) -> bool:
	for i in _body_state.get_contact_count():
		var contact_normal := _body_state.get_contact_local_normal(i)
		if contact_normal.dot(surface_normal) > tolerance:
			return true
	return false

func get_floor_normal(find_immediate: bool = false) -> Vector2:
	if find_immediate:
		if _body_state.get_contact_count() == 0:
			return Vector2.ZERO
		
		var floor_normal_indicies := []
		for i in _body_state.get_contact_count():
			var contact_normal := _body_state.get_contact_local_normal(i)
			var slope_angle = rad2deg(acos(contact_normal.dot(Vector2.UP)))

			if slope_angle <= 45.1 and slope_angle >= 0:
				floor_normal_indicies.append(i)

		if not floor_normal_indicies.empty():
			var left_most_normal_index: int = floor_normal_indicies[0]
			var right_most_normal_index: int = floor_normal_indicies[0]
			
			for i in floor_normal_indicies.size():
				var left_most_normal_position =  _body_state.get_contact_local_position(left_most_normal_index)
				var right_most_normal_position =  _body_state.get_contact_local_position(right_most_normal_index)
				var normal_position: Vector2 = _body_state.get_contact_local_position(floor_normal_indicies[i])
				
				if normal_position.x < left_most_normal_position.x:
					left_most_normal_index = i
				elif normal_position.x > right_most_normal_position.x:
					right_most_normal_index = i
				
			if _body_state.linear_velocity.x < 0:
				return _body_state.get_contact_local_normal(left_most_normal_index)
			if _body_state.linear_velocity.x > 0:
				return _body_state.get_contact_local_normal(right_most_normal_index)
	return _floor_normal


func is_on_slope(find_immediate: bool = false) -> bool:
	if find_immediate:
		for i in _body_state.get_contact_count():
			var contact_normal := _body_state.get_contact_local_normal(i)
			var contact_position := _body_state.get_contact_local_position(i)
			var slope_angle = rad2deg(acos(contact_normal.dot(Vector2.UP)))
			
			if slope_angle < 45.1 and slope_angle > 0.1:
				return true
		return false

	return _contacts[Contact.SLOPE]

func is_on_floor(find_immediate: bool = false) -> bool:
	if find_immediate:
		return is_on_surface(Vector2.UP)
	else:
		return _contacts[Contact.FLOOR]
	
func is_on_ceiling(find_immediate: bool = false)  -> bool:
	if find_immediate:
		return is_on_surface(Vector2.DOWN)
	else:
		return _contacts[Contact.CEILING]

func is_on_wall(find_immediate: bool = false)  -> bool:
	if find_immediate:
		return is_on_surface(Vector2.LEFT) or is_on_surface(Vector2.RIGHT)
	else:
		return _contacts[Contact.WALL_L] or _contacts[Contact.WALL_R]

func is_on_wall_left(find_immediate: bool = false)  -> bool:
	if find_immediate:
		return is_on_surface(Vector2.RIGHT)
	else:
		return _contacts[Contact.WALL_L]
	
func is_on_wall_right(find_immediate: bool = false)  -> bool:
	if find_immediate:
		return is_on_surface(Vector2.LEFT)
	else:
		return _contacts[Contact.WALL_L]

#private methods

#signal methods

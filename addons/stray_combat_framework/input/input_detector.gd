extends Node

const BufferedInput = preload("buffered_input.gd")
const InputSequence = preload("input_sequence.gd")
const CombinationInput = preload("buttons/combination_input.gd")
const SimpleInput = preload("buttons/simple_input.gd")
const ActionInput = preload("buttons/action_input.gd")
const JoystickInput = preload("buttons/joystick_input.gd")
const KeyboardInput = preload("buttons/keyboard_input.gd")
const MouseInput = preload("buttons/mouse_input.gd")

var buffer_duration: float = 2

var _time_since_first_input: float
var _input_by_id: Dictionary
var _sequence_by_name: Dictionary
var _input_buffer: Array


func _process(delta: float) -> void:
	_check_for_inputs()
	_increment_held_input_time(delta)
	_check_for_sequence_matches()
	_handle_buffer_clearing(delta)


func feed_input(id: int, time_held: float = 0.0) -> void:
	var buffered_input := BufferedInput.new()
	buffered_input.id = id
	buffered_input.time_stamp = OS.get_ticks_msec()
	buffered_input.time_held = time_held
	buffered_input.was_released = true
	_input_buffer.append(buffered_input)
		

func register_sequence(name: String, input_sequence: InputSequence) -> void:
	if name.empty():
		push_warning("A sequence name must be given")
		return

	if _sequence_by_name.has(name):
		push_warning("A sequence with name '%s' already exists." % name)
		return

	_sequence_by_name[name] = input_sequence


func register_combination(id: int, input_ids: PoolIntArray) -> void:
	if id in input_ids:
		push_warning("Combination id can not be included in input ids")
		return
	
	if input_ids.size() < 2:
		push_warning("Combination must contain 2 or more inputs.")
		return

	var combination_input := CombinationInput.new()
	combination_input.input_map = _input_by_id
	combination_input.input_ids = input_ids

	bind_simple_input(id, combination_input)


func bind_simple_input(id: int, simple_input: SimpleInput) -> void:
	_input_by_id[id] = simple_input


func bind_action_input(id: int, action: String) -> void:
	var action_input := ActionInput.new()
	action_input.action = action
	bind_simple_input(id, action_input)


func bind_joystick_input(id: int, device: int, button: int) -> void:
	var joystick_input := JoystickInput.new()
	joystick_input.device = device
	joystick_input.button = button
	bind_simple_input(id, joystick_input)


func bind_keyboard_input(id: int, key: int) -> void:
	var keyboard_input := KeyboardInput.new()
	keyboard_input.key = key
	bind_simple_input(id, keyboard_input)


func bind_mouse_input(id: int, button: int) -> void:
	var mouse_input := MouseInput.new()
	mouse_input.button = button
	_input_by_id[id] = mouse_input
	bind_simple_input(id, mouse_input)


func _check_for_inputs() -> void:
	for id in _input_by_id:
		var input := _input_by_id[id] as SimpleInput

		if input.is_just_pressed():
			var buffered_input := BufferedInput.new()
			buffered_input.id = id
			buffered_input.time_stamp = OS.get_ticks_msec()

			if input is CombinationInput:
				if not _input_buffer.empty():
					for i in len(input.input_ids):
						var most_recent_input: BufferedInput = _input_buffer.back()
						var is_inputted_quick_enough := buffered_input.calc_time_between(most_recent_input) < 0.1
						if input.is_component(most_recent_input.id):
							if is_inputted_quick_enough:
								_input_buffer.pop_back()
						else:
							break
			_input_buffer.append(buffered_input)
		elif input.is_just_released():
			if input is CombinationInput:
				input.release_components()

		input.poll()


func _increment_held_input_time(delta: float) -> void:
	for buffered_input in _input_buffer:
		buffered_input = buffered_input as BufferedInput
		
		if not buffered_input.was_released:
			var input: SimpleInput = _input_by_id[buffered_input.id]
			if input.is_pressed():
				buffered_input.time_held += delta
			else:
				buffered_input.was_released = true


func _check_for_sequence_matches() -> void:
	for sequence_name in _sequence_by_name:
		var sequence = _sequence_by_name[sequence_name] as InputSequence
		if sequence.is_match(_input_buffer):
			pass


func _handle_buffer_clearing(delta: float) -> void:
	if not _input_buffer.empty():
		_time_since_first_input += delta

		if _time_since_first_input >= buffer_duration:
			# Keep most recently pressed inputs in buffer if they're still being pressed
			var carry_over_buffer: Array
			var buffered_combinations: Array

			for i in range(_input_buffer.size() - 1, -1, -1):
				var buffered_input: BufferedInput = _input_buffer[i]
				if not buffered_input.was_released:
					for input in carry_over_buffer:
						if buffered_input.id == input.id:
							continue	

					if _input_by_id[buffered_input.id] is CombinationInput:
						buffered_combinations.append(buffered_input)

					carry_over_buffer.push_front(buffered_input)

			# Remove combination component inputs from carry over
			if not carry_over_buffer.empty():
				var temp_buffer: Array

				for buffered_input in carry_over_buffer:
					var is_featured_in_combination: bool = false
					if not buffered_input in buffered_combinations:
						for buffered_combination in buffered_combinations:
							var combination_input: CombinationInput = _input_by_id[buffered_combination.id]
							if buffered_input.id in combination_input.input_ids:
								is_featured_in_combination = true
								break

					if not is_featured_in_combination:
						temp_buffer.append(buffered_input)

				carry_over_buffer = temp_buffer


			_input_buffer.clear()

			for buffered_input in carry_over_buffer:
				_input_buffer.append(buffered_input)
			
			_time_since_first_input = 0

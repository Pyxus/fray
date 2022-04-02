extends Node
## docstring

#TODO: Implement support for charged inputs

signal input_detected(detected_input)

#enums

#constants

const SequenceAnalyzer = preload("sequence_analyzer.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")
const DetectedInputSequence = preload("detected_inputs/detected_input_sequence.gd")
const InputBind = preload("binds/input_bind.gd")
const ActionInput = preload("binds/action_input.gd")
const JoystickInput = preload("binds/joystick_input.gd")
const JoystickAxisInput = preload("binds/joystick_input.gd")
const KeyboardInput = preload("binds/keyboard_input.gd")
const MouseInput = preload("binds/mouse_input.gd")
const CombinationInput = preload("binds/combination_input.gd")

#exported variables

#public variables

var _input_by_id: Dictionary # Dictionary<int, InputBind>
var _sequence_analyzer := SequenceAnalyzer.new()
var _detected_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	_sequence_analyzer.connect("match_found", self, "_on_SequenceTree_match_found")


func _process(delta: float) -> void:
	for id in _input_by_id:
		var input_bind := _input_by_id[id] as InputBind
		var time_stamp := OS.get_ticks_msec()

		if input_bind.is_just_pressed():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			detected_input.bind = input_bind.duplicate()
			_detected_input_button_by_id[id] = detected_input
			_sequence_analyzer.advance(detected_input)
		elif input_bind.is_just_released():
			var detected_input: DetectedInputButton = _detected_input_button_by_id[id]
			detected_input.is_pressed = false
			_sequence_analyzer.advance(detected_input)
			_detected_input_button_by_id.erase(id)
			pass
		
		input_bind.poll()
	
	for id in _detected_input_button_by_id:
		_detected_input_button_by_id[id].time_held += delta


func is_input_pressed(id: int) -> bool:
	if not _input_by_id.has(id):
		push_warning("No input with id '%d' binded." % id)
		return false
	return _input_by_id[id].is_pressed()


func is_input_just_pressed(id: int) -> bool:
	if not _input_by_id.has(id):
		push_warning("Input with id %d does not exist" % id)
		return false
	return _input_by_id[id].is_just_pressed()


func is_input_just_released(id: int) -> bool:
	if not _input_by_id.has(id):
		push_warning("Input with id %d does not exist" % id)
		return false
	return _input_by_id[id].is_just_released()


func bind_input(id: int, input_bind: InputBind) -> void:
	_input_by_id[id] = input_bind


func bind_action_input(id: int, action: String) -> void:
	var action_input := ActionInput.new()
	action_input.action = action
	bind_input(id, action_input)


func bind_joystick_input(id: int, device: int, button: int) -> void:
	var joystick_input := JoystickInput.new()
	joystick_input.device = device
	joystick_input.button = button
	bind_input(id, joystick_input)


func bind_joystick_axis(id: int, device: int, axis: int, deadzone: float) -> void:
	var joystick_axis_input := JoystickAxisInput.new()
	joystick_axis_input.device = device
	joystick_axis_input.axis = axis
	joystick_axis_input.deadzone = deadzone
	bind_input(id, joystick_axis_input)


func bind_keyboard_input(id: int, key: int) -> void:
	var keyboard_input := KeyboardInput.new()
	keyboard_input.key = key
	bind_input(id, keyboard_input)


func bind_mouse_input(id: int, button: int) -> void:
	var mouse_input := MouseInput.new()
	mouse_input.button = button
	bind_input(id, mouse_input)


func bind_combination_input(id: int, combined_ids: PoolIntArray) -> void:
	if id in combined_ids:
		push_error("Failed to bind.Combination input id can not be included in input ids")
		return
	
	if combined_ids.size() < 2:
		push_error("Failed to bind. Combination must contain 2 or more inputs.")
		return

	for comb_id in combined_ids:
		if not _input_by_id.has(comb_id):
			push_warning("Combined ids contain unbinded input '%d'" % comb_id)

	var combination_input := CombinationInput.new()
	#TODO: Plan out combination input implementation

#private methods

func _on_SequenceTree_match_found(sequence_name: String) -> void:
	var detected_input := DetectedInputSequence.new()
	detected_input.name = sequence_name
	emit_signal("input_detected", detected_input)

"""
class CircularBuffer:
	extends Reference

	const BufferedInput = preload("sequence/buffered_input.gd")

	var capacity: int = 1 setget set_capacity
	var count: int setget set_count, get_count

	var _read_index: int
	var _write_index: int
	var _buffer: Array

	func _init() -> void:
		for i in capacity:
			_buffer.append(null)


	func set_capacity(value: int) -> void:
		if value < 1:
			push_error("Circular buffer capacity can not be smaller than 1")

		capacity = max(1, value)
		_buffer.resize(value)
		_read_index = 0
		_write_index = 0


	func set_count(value) -> void:
		pass


	func get_count() -> int:
		return -1


	func add(buffered_input: BufferedInput) -> void:
		_buffer[_write_index % capacity] = buffered_input
		_write_index += 1


	func peek() -> BufferedInput:
		return _buffer[_read_index % capacity]


	func pop() -> BufferedInput:
		var buffered_input := peek()
		_read_index += 1
		return buffered_input
"""

extends Node
## Class that deals with command inputs, where a command input is a unique
## sequence of buttons pressed within a certain time frame.

#signals

#enums

const MAX_INPUT_READ = 3

const CInput = preload("cinput.gd")
const InputSequence = preload("input_sequence.gd")
const BufferedInput = preload("buffered_input.gd")

#exported variables

var buffer_duration: float = 2

var _time_since_input: float = 0.0
var _last_buffered_input: BufferedInput
var _input_buffer: Array
var _inputted_sequences: Array
var _registered_sequences: Array
var _registered_inputs: Array
var _registered_aggregate_inputs: Array
var _created_input_sequences: Array

#onready variables


#optional built-in virtual _init method

func _process(delta: float) -> void:
	# sequences cant be held so remove them the frame after they're detected
	_inputted_sequences.clear()

	if _time_since_input >= buffer_duration:
		_reset_buffer()

	for obj in _registered_aggregate_inputs:
		var input := obj as CInput
		if input.is_just_pressed():
			_add_input_to_buffer(input)
		input.poll()

	for obj in _registered_inputs:
		var input := obj as CInput

		if _last_buffered_input != null:
			var last_input_contains_this_input = _last_buffered_input.input.actions.has(input.actions[0])
			var last_input_is_aggregate = _last_buffered_input.input.is_aggregate()

			if last_input_is_aggregate and last_input_contains_this_input and _last_buffered_input.input.is_pressed():
				continue

		if input.is_just_pressed():
			_add_input_to_buffer(input)
		input.poll()

	if _last_buffered_input != null and _last_buffered_input.input.is_pressed():
		_last_buffered_input.time_held += delta

	_parse_inputs()

	if not _input_buffer.empty():
		_time_since_input += delta

func register_created_sequences() -> void:
	if _created_input_sequences.empty():
		push_warning("No sequences created in input reader")
		return

	for sequence in _created_input_sequences:
		_register_sequence(sequence)

func register_input_aggregate(actions: Array) -> void:
	var input := CInput.new()
	for action in actions:
		if InputMap.has_action(action):
			input.actions.append(action)
		else:
			push_warning("Input map does not contain action [%s]" % action)
			return
	_registered_aggregate_inputs.append(input)

func register_input(action: String) -> void:
	if InputMap.has_action(action):
		var input := CInput.new()
		input.actions.append(action)
		_registered_inputs.append(input)
	else:
		push_warning("Input map does not contain action [%s]" % action)


func create_input_sequence(sequence_name: String) -> InputSequence:
	var input_sequence := InputSequence.new()
	input_sequence.name = sequence_name
	_created_input_sequences.append(input_sequence)
	return input_sequence

func has_equivalent_sequence(sequence: InputSequence) -> bool:
	for registered_sequence in _registered_sequences:
		if registered_sequence.is_equal_to(sequence):
			return true
	return false

func has_sequence(sequence_name: String) -> bool:
	for registered_sequence in _registered_sequences:
		if registered_sequence.name == sequence_name:
			return true
	return false

func is_sequence_inputed(sequence_name: String) -> bool:
	for sequence in _inputted_sequences:
		if sequence.name == sequence_name:
			return true
	return false

func print_input_buffer() -> void:
	print(get_input_buffer_string())

func get_input_buffer_string() -> String:
	var string := "["

	for i in len(_input_buffer):
		var buffered_input = _input_buffer[i] as BufferedInput
		string += "%s" % buffered_input.input

		if i != len(_input_buffer) - 1:
			string += " - "

	string += "]"
	return string

func _reset_buffer() -> void:
	_time_since_input = 0
	_input_buffer.clear()

	# If the most recent input it still being held add it back to the buffer
	# This is to transfer the held_time to allow support for "chrage" inputs.
	if _last_buffered_input != null and _last_buffered_input.input.is_pressed():
		_input_buffer.push_back(_last_buffered_input)
	else:
		_last_buffered_input = null

func _parse_inputs() -> void:
	var discovered_sequence := []
	for i in len(_input_buffer):
		var input := _input_buffer[i] as BufferedInput
		discovered_sequence.push_back(input)

		for sequence in _registered_sequences:
			if sequence.is_valid_input(discovered_sequence):
				_inputted_sequences.append(sequence)

				for buffered_inputs in discovered_sequence:
					_input_buffer.erase(buffered_inputs)
				return

func _register_sequence(sequence: InputSequence) -> void:
	if has_sequence(sequence.name):
		push_warning("Sequence name already exists in reader")
		return

	if has_equivalent_sequence(sequence):
		push_warning("Attempt to register duplicate sequence")
		return

	_registered_sequences.append(sequence)

func _add_input_to_buffer(input: CInput) -> void:
	var buffered_input = BufferedInput.new()
	buffered_input.input = input
	buffered_input.is_held = true

	if _last_buffered_input != null:
		_last_buffered_input.is_held = false

	_input_buffer.push_back(buffered_input)
	_last_buffered_input = buffered_input

#signal methods

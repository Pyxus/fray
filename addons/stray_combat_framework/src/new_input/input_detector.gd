extends Node
## docstring

#TODO: Implement support for charged inputs
	# Right now only pressed inputs are fed to the sequence analyzer.
	# This is because if released inputs were also fed the analyzer would always fail to find a match.
	# Since charged inputs by necessity must be released this means there is no support for them at the moment.
	# Maybe I could feed released inputs to the analyzer and have it ignore them if there is no path for them?
#TODO: Implement support for motion inputs
	# Motion inputs change their directional buttons based on a fighters position
	# Right now this is not easy to set up...
	# 1 way to do this is add a new directional_input_bind and override the pressed methods
	# to change their return based on the current direction.
	# Maybe consider making it generic as a 'conditional_input_bind' to allow support any number of changes

signal input_detected(detected_input)

#enums

#constants

const SequenceAnalyzer = preload("sequence_analyzer.gd")
const SequenceData = preload("sequence_data.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")
const DetectedInputSequence = preload("detected_inputs/detected_input_sequence.gd")
const InputBind = preload("binds/input_bind.gd")
const ActionInput = preload("binds/action_input.gd")
const JoystickInput = preload("binds/joystick_input.gd")
const JoystickAxisInput = preload("binds/joystick_input.gd")
const KeyboardInput = preload("binds/keyboard_input.gd")
const MouseInput = preload("binds/mouse_input.gd")
const CombinationInput = preload("combination_input.gd")

#exported variables

#public variables

var _sequence_analyzer := SequenceAnalyzer.new()
var _combination_input_by_id: Dictionary # Dictionary<int, InputCombination>
var _input_by_id: Dictionary # Dictionary<int, InputBind>
var _detected_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>
var _ignored_input_hash_set: Dictionary # Dictionary<int, bool>

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	_sequence_analyzer.connect("match_found", self, "_on_SequenceTree_match_found")


func _process(delta: float) -> void:
	var time_stamp := OS.get_ticks_msec()

	# Check individual inputs
	for id in _input_by_id:
		var input_bind := _input_by_id[id] as InputBind
		
		if input_bind.is_just_pressed():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			detected_input.bind = input_bind.duplicate()
			_detected_input_button_by_id[id] = detected_input
		elif input_bind.is_just_released():
			var detected_input: DetectedInputButton = _detected_input_button_by_id[id]
			detected_input.is_pressed = false
			_detected_input_button_by_id.erase(id)
			emit_signal("input_detected", detected_input)
			_unignore_input(id)
		
		input_bind.poll()
	
	# Check combined inputs
	var detected_input_ids := _detected_input_button_by_id.keys()
	for id in _combination_input_by_id:
		var combination_input: CombinationInput = _combination_input_by_id[id]
		if combination_input.has_ids(detected_input_ids):
			if  _detected_input_button_by_id.has(id):
				continue

			if combination_input.is_simeultaneous and not _is_inputed_quick_enough(combination_input.combined_ids):
				continue

			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			_detected_input_button_by_id[id] = detected_input
			
			combination_input.is_pressed = true

			for cid in combination_input.combined_ids:
				_ignore_input(cid)

		elif _detected_input_button_by_id.has(id):
			if combination_input.press_held_components_on_release:
				for cid in combination_input.combined_ids:
					if is_input_pressed(cid):
						_detected_input_button_by_id[cid].time_stamp = time_stamp
						_unignore_input(cid)
						
			var detected_input: DetectedInputButton = _detected_input_button_by_id[id]
			detected_input.is_pressed = false
			combination_input.is_pressed = false
			_detected_input_button_by_id.erase(id)
			
			_unignore_input(id)
			emit_signal("input_detected", detected_input)
		
		combination_input.poll()

	# Feed detected inputs to sequence analyzer and emit detection signals
	for id in _detected_input_button_by_id:
		var detected_input: DetectedInput = _detected_input_button_by_id[id]
		if not _ignored_input_hash_set.has(id):
			_sequence_analyzer.advance(detected_input)
			emit_signal("input_detected", detected_input)
			_ignore_input(id)
		detected_input.time_held += delta


func is_input_pressed(id: int) -> bool:
	if _input_by_id.has(id):
		return _input_by_id[id].is_pressed()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_pressed
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


func is_input_just_pressed(id: int) -> bool:
	if _input_by_id.has(id):
		return _input_by_id[id].is_just_pressed()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_just_pressed()
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


func is_input_just_released(id: int) -> bool:
	if _input_by_id.has(id):
		return _input_by_id[id].is_just_released()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_just_released()
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


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


func register_input_combination(id: int, combined_ids: PoolIntArray, press_held_components_on_release: bool = false, is_simeultaneous: bool = false) -> void:
	if _input_by_id.has(id):
		push_error("Failed to register combination input. Combination id is already used by binded input")
		return

	if id in combined_ids:
		push_error("Failed to register combination input. Combination id can not be included in input ids")
		return
	
	if combined_ids.size() < 2:
		push_error("Failed to register combination input. Combination must contain 2 or more inputs.")
		return

	for comb_id in combined_ids:
		if not _input_by_id.has(comb_id):
			push_error("Failed to register combination input. Combined ids contain unbinded input '%d'" % comb_id)
			return

	var combination_input := CombinationInput.new()
	combination_input.combined_ids = combined_ids
	combination_input.is_simeultaneous = is_simeultaneous
	combination_input.press_held_components_on_release = press_held_components_on_release
	_combination_input_by_id[id] = combination_input

	#TODO: Plan out combination input implementation


func register_sequence(sequence_data: SequenceData) -> void:
	_sequence_analyzer.register_sequence(sequence_data)


func _ignore_input(input_id: int) -> void:
	_ignored_input_hash_set[input_id] = true


func _unignore_input(input_id: int) -> void:
	if _ignored_input_hash_set.has(input_id):
		_ignored_input_hash_set.erase(input_id)


func _is_inputed_quick_enough(combined_ids: PoolIntArray, tolerance: float = 30) -> bool:
	var avg_difference := 0
	for i in len(combined_ids):
		if i > 0:
			avg_difference += _detected_input_button_by_id[combined_ids[i]].get_time_between(_detected_input_button_by_id[combined_ids[i - 1]])

	avg_difference /= float(combined_ids.size())
	if avg_difference <= tolerance:
		return true
	
	return false


func _on_SequenceTree_match_found(sequence_name: String) -> void:
	var detected_input := DetectedInputSequence.new()
	detected_input.name = sequence_name
	emit_signal("input_detected", detected_input)

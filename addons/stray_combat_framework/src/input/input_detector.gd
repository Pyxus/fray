extends Node
## docstring

#TODO: Add support for charged inputs
	# Right now only pressed inputs are fed to the sequence analyzer.
	# This is because if released inputs were also fed the analyzer would always fail to find a match.
	# Since charged inputs by necessity must be released this means there is no support for them at the moment.
	# Maybe I could feed released inputs to the analyzer and have it ignore them if there is no path for them?
	# Idea: Feed released inputs, have them ingored if no path. Perform a sub check from root to see if a path is open
	# if a path is open keep track of the sub match until a mismatch is detected or a sequence is found. 
	# If found accept this sub match and switch to this path. This will mean released inputs have priority in this case but I think that is alright.
#TODO: Test conditional inputs
#TODO: Add methods to remove inputs
	# If an input used in another input is removed then so should that input
#TODO: Make sure sequences support infinite time between inputs
#TODO: Make SequenceAnalyzer override friendly
	# Worst case scenario if the default sequence analyzer doesn't do what a user wants allow them to implement their own without hassle.
	# This means the sequence analyzer should not be dependent on the input detector beyond the fact that the detector feeds to the analyzer.

signal input_detected(detected_input)

#enums

#constants

const SequenceAnalyzer = preload("sequence_analysis/sequence_analyzer.gd")
const SequenceAnalyzerTree = preload("sequence_analysis/sequence_analyzer_tree.gd")
const SequenceData = preload("sequence_analysis/sequence_data.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")
const DetectedInputSequence = preload("detected_inputs/detected_input_sequence.gd")
const InputBind = preload("binds/input_bind.gd")
const ActionInputBind = preload("binds/action_input_bind.gd")
const JoystickInputBind = preload("binds/joystick_input_bind.gd")
const JoystickAxisInputBind = preload("binds/joystick_input_bind.gd")
const KeyboardInputBind = preload("binds/keyboard_input_bind.gd")
const MouseInputBind = preload("binds/mouse_input_bind.gd")
const CombinationInput = preload("bind_dependent_input/combination_input.gd")
const ConditionalInput = preload("bind_dependent_input/conditional_input.gd")

#exported variables

var sequence_analyzer := SequenceAnalyzerTree.new()

var _input_bind_by_id: Dictionary # Dictionary<int, InputBind>
var _combination_input_by_id: Dictionary # Dictionary<int, CombinationInput>
var _conditional_input_by_id: Dictionary # Dictionary<int, ConditionalInput>
var _detected_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>
var _released_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>
var _ignored_input_hash_set: Dictionary # Dictionary<int, bool>
var _conditions: Dictionary # Dictionary<String, bool>

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	sequence_analyzer.connect("match_found", self, "_on_SequenceTree_match_found")


func _process(delta: float) -> void:
	_check_input_binds()
	_check_combined_inputs()
	_check_conditional_inputs()
	_detect_inputs()


func is_condition_true(condition: String) -> bool:
	if _conditions.has(condition):
		return _conditions[condition]
	return false


func clear_conditions() -> void:
	_conditions.clear()


func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value


func is_input_pressed(id: int) -> bool:
	if _input_bind_by_id.has(id):
		return _input_bind_by_id[id].is_pressed()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_pressed
	elif _conditional_input_by_id.has(id):
		return _input_bind_by_id[id].is_pressed(_conditional_input_by_id[id].current_input)
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


func is_input_just_pressed(id: int) -> bool:
	if _input_bind_by_id.has(id):
		return _input_bind_by_id[id].is_just_pressed()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_just_pressed()
	elif _conditional_input_by_id.has(id):
		return _input_bind_by_id[id].is_just_pressed(_conditional_input_by_id[id].current_input)
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


func is_input_just_released(id: int) -> bool:
	if _input_bind_by_id.has(id):
		return _input_bind_by_id[id].is_just_released()
	elif _combination_input_by_id.has(id):
		return _combination_input_by_id[id].is_just_released()
	elif _conditional_input_by_id.has(id):
		return _input_bind_by_id[id].is_just_released(_conditional_input_by_id[id].current_input)
	else:
		push_warning("No input with id '%d' binded." % id)
		return false


func bind_input(id: int, input_bind: InputBind) -> void:
	_input_bind_by_id[id] = input_bind


func bind_action_input(id: int, action: String) -> void:
	var action_input := ActionInputBind.new()
	action_input.action = action
	bind_input(id, action_input)


func bind_joystick_input(id: int, device: int, button: int) -> void:
	var joystick_input := JoystickInputBind.new()
	joystick_input.device = device
	joystick_input.button = button
	bind_input(id, joystick_input)


func bind_joystick_axis(id: int, device: int, axis: int, deadzone: float) -> void:
	var joystick_axis_input := JoystickAxisInputBind.new()
	joystick_axis_input.device = device
	joystick_axis_input.axis = axis
	joystick_axis_input.deadzone = deadzone
	bind_input(id, joystick_axis_input)


func bind_keyboard_input(id: int, key: int) -> void:
	var keyboard_input := KeyboardInputBind.new()
	keyboard_input.key = key
	bind_input(id, keyboard_input)


func bind_mouse_input(id: int, button: int) -> void:
	var mouse_input := MouseInputBind.new()
	mouse_input.button = button
	bind_input(id, mouse_input)


func register_conditional_input(id: int, default_input: int, input_by_condition: Dictionary) -> void:
	for cid in input_by_condition.values():
		if not _input_bind_by_id.has(cid) and not _combination_input_by_id.has(cid):
			push_error("Failed to register conditional input. Input dictionary contains unregistered and unbinded input '%d'" % cid)
			return
		
		if cid == id:
			push_error("Failed to register conditional input. Conditional input id can not be included in input dictioanry.")
			return
	
	if not _input_bind_by_id.has(default_input) and not _combination_input_by_id.has(default_input):
		push_error("Failed to register conditional input. Default input '%d' is not binded or a registered combination" % default_input)
		return

	if default_input == id:
		push_error("Failed to register conditional input. Conditional input id can not be used as a default input.")
		return

	var conditional_input := ConditionalInput.new()
	conditional_input.default_input = default_input
	conditional_input.input_by_condition = input_by_condition
	_conditional_input_by_id[id] = conditional_input


func register_combination_input(id: int, components: PoolIntArray, is_ordered: bool = false, press_held_components_on_release: bool = false, is_simeultaneous: bool = false) -> void:
	if _input_bind_by_id.has(id) or _conditional_input_by_id.has(id):
		push_error("Failed to register combination input. Combination id is already used by binded or registered input")
		return

	if id in components:
		push_error("Failed to register combination input. Combination id can not be included in components")
		return
	
	if components.size() <= 1:
		push_error("Failed to register combination input. Combination must contain 2 or more components.")
		return

	if _conditional_input_by_id.has(id):
		push_error("Failed to register combination input. Combination components can not include conditional input")
		return

	for cid in components:
		if not _input_bind_by_id.has(cid):
			push_error("Failed to register combination input. Combined ids contain unbinded input '%d'" % cid)
			return
		
		if _conditional_input_by_id.has(cid):
			push_error("Failed to register combination input. Combination components can not include a conditional input")
			return

	var combination_input := CombinationInput.new()
	combination_input.components = components
	combination_input.is_ordered = is_ordered
	combination_input.is_simeultaneous = is_simeultaneous
	combination_input.press_held_components_on_release = press_held_components_on_release
	
	if is_simeultaneous and is_ordered:
		push_warning("Combination input can not be strictly simeultaneous if an order is given.")
		combination_input.is_simeultaneous = false

	_combination_input_by_id[id] = combination_input


func _check_input_binds() -> void:
	var time_stamp := OS.get_ticks_msec()
	for id in _input_bind_by_id:
		var input_bind := _input_bind_by_id[id] as InputBind
		
		if input_bind.is_just_pressed():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			detected_input.bind = input_bind.duplicate()
			_detected_input_button_by_id[id] = detected_input
		elif input_bind.is_just_released():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp
			_released_input_button_by_id[id] = detected_input
			#_detected_input_button_by_id.erase(id)
			emit_signal("input_detected", detected_input)
			_unignore_input(id)
		
		input_bind.poll()


func _check_combined_inputs() -> void:
	var time_stamp := OS.get_ticks_msec()
	var detected_input_ids := _detected_input_button_by_id.keys()
	for id in _combination_input_by_id:
		var combination_input: CombinationInput = _combination_input_by_id[id]
		if combination_input.has_ids(detected_input_ids):
			if  _detected_input_button_by_id.has(id):
				continue

			if combination_input.is_ordered and not _is_inputed_in_order(combination_input.components):
				continue
			elif combination_input.is_simeultaneous and not _is_inputed_quick_enough(combination_input.components):
				continue

			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			combination_input.is_pressed = true
			_detected_input_button_by_id[id] = detected_input

			for cid in combination_input.components:
				_ignore_input(cid)

		elif _detected_input_button_by_id.has(id):
			if combination_input.press_held_components_on_release:
				for cid in combination_input.components:
					if is_input_pressed(cid):
						_detected_input_button_by_id[cid].time_stamp = time_stamp
						_unignore_input(cid)
						
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp
			combination_input.is_pressed = false
			_released_input_button_by_id[id] = detected_input
			#_detected_input_button_by_id.erase(id)
			
			_unignore_input(id)
			emit_signal("input_detected", detected_input)
		
		combination_input.poll()


func _check_conditional_inputs() -> void:
	var time_stamp := OS.get_ticks_msec()
	for id in _conditional_input_by_id:
		var conditional_input := _conditional_input_by_id[id] as ConditionalInput

		if is_input_just_pressed(conditional_input.current_input):
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			_detected_input_button_by_id[id] = detected_input
		elif is_input_just_released(conditional_input.current_input):
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp
			_released_input_button_by_id[id] = detected_input
			#_detected_input_button_by_id.erase(id)
			emit_signal("input_detected", detected_input)
			_unignore_input(id)

		# Update current condition
		conditional_input.current_input = conditional_input.default_input
		for condition in conditional_input.input_by_condition:
			if is_condition_true(condition):
				conditional_input.current_input = conditional_input.input_by_condition[condition]
				break


func _detect_inputs() -> void:
	for id in _released_input_button_by_id:
		var detected_input: DetectedInput = _released_input_button_by_id[id]
		sequence_analyzer.read(detected_input)
		emit_signal("input_detected", detected_input)
		_detected_input_button_by_id.erase(id)

	for id in _detected_input_button_by_id:
		var detected_input: DetectedInput = _detected_input_button_by_id[id]
		if not _ignored_input_hash_set.has(id):
			sequence_analyzer.read(detected_input)
			emit_signal("input_detected", detected_input)
			_ignore_input(id)

	_released_input_button_by_id.clear()


func _ignore_input(input_id: int) -> void:
	_ignored_input_hash_set[input_id] = true


func _unignore_input(input_id: int) -> void:
	if _ignored_input_hash_set.has(input_id):
		_ignored_input_hash_set.erase(input_id)


func _is_inputed_quick_enough(components: PoolIntArray, tolerance: float = 30) -> bool:
	var avg_difference := 0
	for i in len(components):
		if i > 0:
			avg_difference += _detected_input_button_by_id[components[i]].get_time_between(_detected_input_button_by_id[components[i - 1]])

	avg_difference /= float(components.size())
	if avg_difference <= tolerance:
		return true
	
	return false


func _is_inputed_in_order(components: PoolIntArray, tolerance: float = 30) -> bool:
	if components.size() <= 1:
		return false

	for i in range(1, components.size()):
		var input1: DetectedInput = _detected_input_button_by_id[components[i - 1]]
		var input2: DetectedInput = _detected_input_button_by_id[components[i]]

		if input1.time_stamp - tolerance > input2.time_stamp:
			return false

	return true


func _on_SequenceTree_match_found(sequence_name: String) -> void:
	var detected_input := DetectedInputSequence.new()
	detected_input.name = sequence_name
	emit_signal("input_detected", detected_input)

tool
extends Node
##
## A node used to detect inputs and input sequences.
##
## @desc:
##		Before use inputs must first be bound through the bind methods provided.
## 		Bound inputs can be used to register combination and conditional inputs.
## 		Sequences must be added by directly accessing the sequence analyzer property.
##

# Imports
const SequenceAnalyzer = preload("sequence_analysis/sequence_analyzer.gd")
const SequenceAnalyzerTree = preload("sequence_analysis/sequence_analyzer_tree.gd")
const SequenceData = preload("sequence_analysis/sequence_data.gd")
const DetectedInput = preload("detected_inputs/detected_input.gd")
const DetectedInputButton = preload("detected_inputs/detected_input_button.gd")
const DetectedInputSequence = preload("detected_inputs/detected_input_sequence.gd")
const InputSet = preload("input_data/input_set.gd")
const InputBind = preload("input_data/binds/input_bind.gd")
const CombinationInput = preload("input_data/combination_input.gd")
const ConditionalInput = preload("input_data/conditional_input.gd")

## Emitted when a bound, registered, or sequence input is detected.
signal input_detected(detected_input)

export var input_set: Resource = InputSet.new()

## The sequence analyzer used to detect sequence inputs.
export var sequence_analyzer: Resource = SequenceAnalyzerTree.new()

var _detected_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>
var _released_input_button_by_id: Dictionary # Dictionary<int, DetectedInputButton>
var _ignored_input_hash_set: Dictionary # Dictionary<int, bool>
var _conditions: Dictionary # Dictionary<String, bool>


func _ready() -> void:
	if Engine.editor_hint:
		return

	sequence_analyzer.connect("match_found", self, "_on_SequenceTree_match_found")


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return

	_check_input_binds()
	_check_combined_inputs()
	_check_conditional_inputs()
	_detect_inputs()
	_poll_inputs()

## Returns true if an input is being pressed.
func is_input_pressed(id: int) -> bool:
	var input: Reference = input_set.get_input(id)

	if input is InputBind:
		return input.is_pressed()
	elif input is CombinationInput:
		return input.is_pressed
	elif input is ConditionalInput:
		var current_input: Reference = input_set.get_input(input.current_input)

		if current_input is InputBind:
			return current_input.is_pressed()
		elif current_input is CombinationInput:
			return current_input.is_pressed;
		else:
			push_warning("Conditional input '%d' contains input '%d' that doesn't map to any bind or combination" % [id, current_input.current_input])
			return false
	else:
		push_warning("No input with id '%d' bound." % id)

	return false

## Returns true when a user starts pressing the input, meaning it's true only on the frame the user pressed down the input.
func is_input_just_pressed(id: int) -> bool:
	var input: Reference = input_set.get_input(id)

	if input is InputBind:
		return input.is_just_pressed()
	elif input is CombinationInput:
		return input.is_just_pressed()
	elif input is ConditionalInput:
		var current_input: Reference = input_set.get_input(input.current_input)

		if current_input is InputBind:
			return current_input.is_just_pressed()
		elif current_input is CombinationInput:
			return current_input.is_just_pressed();
		else:
			push_warning("Conditional input '%d' contains input '%d' that doesn't map to any bind or combination" % [id, current_input.current_input])
			return false
	else:
		push_warning("No input with id '%d' bound." % id)

	return false

## Returns true when the user stops pressing the input, meaning it's true only on the frame that the user released the button.
func is_input_just_released(id: int) -> bool:
	var input: Reference = input_set.get_input(id)

	if input is InputBind:
		return input.is_just_released()
	elif input is CombinationInput:
		return input.is_just_released()
	elif input is ConditionalInput:
		var current_input: Reference = input_set.get_input(input.current_input)

		if current_input is InputBind:
			return current_input.is_just_released()
		elif current_input is CombinationInput:
			return input.is_just_released();
		else:
			push_warning("Conditional input '%d' contains input '%d' that doesn't map to any bind or combination" % [id, current_input.current_input])
			return false
	else:
		push_warning("No input with id '%d' bound." % id)

	return false

## Sets condition to given value. Used for checking conditional inputs.
func set_condition(condition: String, value: bool) -> void:
	_conditions[condition] = value

## Returns the value of a condition set with set_condition.
func is_condition_true(condition: String) -> bool:
	if _conditions.has(condition):
		return _conditions[condition]
	return false

## Clears the condition dict
func clear_conditions() -> void:
	_conditions.clear()


func _check_input_binds() -> void:
	var time_stamp := OS.get_ticks_msec()
	for id in input_set.get_input_bind_ids():
		var input_bind: InputBind = input_set.get_input_bind(id)
		
		if input_bind.is_just_pressed():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			detected_input.bind_ids.append(id)
			_detected_input_button_by_id[id] = detected_input
		elif input_bind.is_just_released():
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.bind_ids.append(id)
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp
			_released_input_button_by_id[id] = detected_input
			_unignore_input(id)


func _check_combined_inputs() -> void:
	var time_stamp := OS.get_ticks_msec()
	var detected_input_ids := _detected_input_button_by_id.keys()
	for id in input_set.get_combination_input_ids():
		var combination_input: CombinationInput = input_set.get_combination_input(id)
		if combination_input.has_ids(detected_input_ids):
			if  _detected_input_button_by_id.has(id):
				continue

			match combination_input.type:
				CombinationInput.Type.SYNC:
					if not _is_inputed_quick_enough(combination_input.components):
						continue
				CombinationInput.Type.ORDERED:
					if not _is_inputed_in_order(combination_input.components):
						continue

			combination_input.is_pressed = true

			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			_detected_input_button_by_id[id] = detected_input

			for cid in combination_input.components:
				detected_input.bind_ids.append(cid)
				_ignore_input(cid)

		elif _detected_input_button_by_id.has(id):
			if combination_input.press_held_components_on_release:
				for cid in combination_input.components:
					if is_input_pressed(cid):
						_detected_input_button_by_id[cid].time_stamp = time_stamp
						_unignore_input(cid)
			
			combination_input.is_pressed = false

			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp

			for cid in combination_input.components:
				detected_input.bind_ids.append(cid)

			_released_input_button_by_id[id] = detected_input
			_unignore_input(id)


func _check_conditional_inputs() -> void:
	var time_stamp := OS.get_ticks_msec()
	for id in input_set.get_conditional_input_ids():
		var conditional_input: ConditionalInput = input_set.get_conditional_input(id)
		
		if is_input_just_pressed(id):
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = true
			detected_input.bind_ids.append(conditional_input.current_input)
			_detected_input_button_by_id[id] = detected_input
		elif is_input_just_released(conditional_input.current_input):
			var detected_input := DetectedInputButton.new()
			detected_input.id = id
			detected_input.time_stamp = time_stamp
			detected_input.is_pressed = false
			detected_input.time_held = time_stamp - _detected_input_button_by_id[id].time_stamp
			detected_input.bind_ids.append(conditional_input.current_input)
			_released_input_button_by_id[id] = detected_input
			_unignore_input(id)

		# Update current condition
		conditional_input.current_input = conditional_input.default_input
		for condition in conditional_input.input_by_condition:
			if is_condition_true(condition):
				conditional_input.current_input = conditional_input.input_by_condition[condition]
				break


func _poll_inputs() -> void:
	for id in input_set.get_input_bind_ids():
		var input_bind: InputBind = input_set.get_input_bind(id)
		input_bind.poll()

	for id in input_set.get_combination_input_ids():
		var combination_input: CombinationInput = input_set.get_combination_input(id)
		combination_input.poll()

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


func _on_SequenceTree_match_found(sequence_name: String, sequence: PoolIntArray) -> void:
	var detected_input := DetectedInputSequence.new()
	detected_input.name = sequence_name
	detected_input.sequence = sequence
	emit_signal("input_detected", detected_input)

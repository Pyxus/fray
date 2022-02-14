extends Node

signal tree_changed(from, to)
signal state_changed(from, to) 

#TODO: Consider just going with UNCHAINABLE and CHAINABLE or something similar for frame data
# Neutral/Recovery just means chaining is allowed
# START_UP/ACTIVE/ACTIVE_GAP just means chaining is not allowed
# At the moment they're redundant.
# Better yet since its boolean just use a can_chain property
enum FrameData {
	NEUTRAL,
	START_UP,
	ACTIVE,
	ACTIVE_GAP,
	RECOVERY,
}

enum ProcessMode {
	IDLE,
	PHYSICS,
	MANUAL
}

const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

const Condition = preload("conditions/condition.gd")
const StringCondition = preload("conditions/string_condition.gd")
const CombatTree = preload("combat_tree.gd")
const CombatState = preload("combat_state.gd")

export(FrameData) var frame_data: int
export var input_buffer_max_size: int = 3
export var input_max_time_in_buffer: float = 0.1
export var active: bool
export(ProcessMode) var process_mode: int 

var condition_by_name: Dictionary

var _input_buffer: Array
var _combat_trees: Array
var _current_tree: CombatTree
var _current_state: CombatState
var _condition_by_name: Dictionary
var _my_states: Array
var _time_since_last_input: float


func _process(delta: float) -> void:
	if process_mode == ProcessMode.IDLE:
		advance(delta)
		

func _physics_process(delta: float) -> void:
	if process_mode == ProcessMode.PHYSICS:
		advance(delta)

		
func advance(delta: float) -> void:
	if active and _current_tree != null:
		var next_transition := _current_tree.get_next_transition(_condition_by_name)
		if next_transition != null:
			var prev_tree: CombatTree = _current_tree
			set_current_tree(next_transition.to)
			emit_signal("tree_changed", prev_tree, _current_tree)

		if not _input_buffer.empty():
			if frame_data == FrameData.RECOVERY or frame_data == FrameData.NEUTRAL:
				var buffered_detected_input: BufferedDetectedInput = _input_buffer.front()
				var next_chain = _current_state.get_next_chain(_condition_by_name, buffered_detected_input.detected_input, _time_since_last_input)

				if next_chain != null:
					var prev_state: CombatState = _current_state
					_current_state = next_chain.to
					_time_since_last_input = OS.get_ticks_msec() / 1000.0
					_input_buffer.pop_front()
					emit_signal("state_changed", prev_state, _current_state)

			for buffered_input in _input_buffer:
				if buffered_input.time_in_buffer >= input_max_time_in_buffer:
					_input_buffer.erase(buffered_input)
				buffered_input.time_in_buffer += delta


func buffer_input(detected_input: DetectedInput) -> void:
	var buffered_detected_input := BufferedDetectedInput.new()
	var current_buffer_size: int = _input_buffer.size()
	
	buffered_detected_input.detected_input = detected_input
	
	if current_buffer_size + 1 > input_buffer_max_size:
		_input_buffer[current_buffer_size - 1] = buffered_detected_input
	else:
		_input_buffer.append(buffered_detected_input)


func revert_to_root() -> void:
	if _current_tree == null:
		push_warning("Failed to revert to root. Current combat tree is not set")
		return

	_current_state = _current_tree.get_root()


func add_tree(combat_tree: CombatTree) -> void:
	if _combat_trees.has(combat_tree):
		push_warning("Combat tree has already been added.")
		return
	
	_combat_trees.append(combat_tree)


func set_current_tree(combat_tree: CombatTree) -> void:
	if not _combat_trees.has(combat_tree):
		push_warning("The given combat tree does not exist within this CombatFSM.")
		return
	
	_current_tree = combat_tree
	_current_state = combat_tree.get_root()


func set_condition(condition_name: String, value: bool) -> void:
	_condition_by_name[condition_name] = value


func set_all_conditions(value: bool) -> void:
	for condition_name in _condition_by_name:
		_condition_by_name[condition_name] = value


func get_current_tree() -> CombatTree:
	return _current_tree


func get_current_state() -> CombatState:
	return _current_state

	
func is_current_state_root() -> bool:
	if _current_tree == null:
		push_error("Failed to check current state. Current combat tree is not set.")
		return false
	
	return _current_state == _current_tree.get_root()
	pass


func is_condition_true(condition: Condition) -> bool:
	if condition is StringCondition:
		if not _condition_by_name.has(condition.condition_name):
			return false

		if not _condition_by_name[condition.condition_name]:
			return false
		
		return _condition_by_name[condition.condition_name]
	return true


class BufferedDetectedInput:
	extends Reference

	const DetectedInput = preload("res://addons/stray_combat_framework/src/input/detected_inputs/detected_input.gd")

	var detected_input: DetectedInput
	var time_in_buffer: float

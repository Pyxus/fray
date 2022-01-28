tool
extends Node2D
## docstring

#inner classes

#signals

#enums

const NONE = -1

const HitState2D = preload("hit_state_2d.gd")

export var switch_on_state_activated: bool = true
export var belongs_to: NodePath setget set_belongs_to

var _thread: Thread
var _current_hit_state: int setget _set_current_hit_state
var _hit_states: Array = []
var _hit_state_by_id: Dictionary

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	if Engine.editor_hint:
		_thread = Thread.new()
		get_tree().connect("tree_changed", self, "_on_SceneTree_changed")
	
	_detect_hit_states()

	if not _hit_state_by_id.empty():
		_set_current_hit_state(0)

func _get_configuration_warning() -> String:
	if _hit_states.empty():
		return "This node is expected to have HitState2D children."
	return ""


func _exit_tree() -> void:
	if _thread != null and _thread.is_alive():
		_thread.wait_to_finish()


func get_current_hit_state() -> HitState2D:
	if _current_hit_state != NONE:
		return _hit_state_by_id[_current_hit_state]
	return null


func deactivate_all_hit_states_except(exception: HitState2D = null) -> void:
	for hit_state in _hit_states:
		if hit_state != exception:
			hit_state.is_active = false


func set_belongs_to(value: NodePath) -> void:
	belongs_to = value
	_detect_hit_states()

func _set_current_hit_state(value: int) -> void:
	_current_hit_state = value

	if is_inside_tree():
		if _current_hit_state != NONE:
			if _hit_state_by_id.has(_current_hit_state):
				_hit_state_by_id[_current_hit_state].is_active = true
			else:
				push_error("Current hit state value does not correspond to dictionary.")

func get_current_hit_state_obj() -> HitState2D:
	return null if not _hit_state_by_id.has(_current_hit_state) else _hit_state_by_id[_current_hit_state]


func _detect_hit_states() -> void:
	_hit_states.clear()
	_hit_state_by_id.clear()
	
	var i: int = 0
	for child in get_children():
		if child is HitState2D:
			_hit_states.append(child)
			child.set_boxes_belong_to(get_node_or_null(belongs_to))
			_hit_state_by_id[i] = child
			i += 1

			if not child.is_connected("activated", self, "_on_HitState_activated"):
				child.connect("activated", self, "_on_HitState_activated", [child])
		
	if _hit_states.empty():
		_set_current_hit_state(NONE)
		
	if _thread != null and _thread.is_alive():
		_thread.call_deferred("wait_to_finish")


func _on_SceneTree_changed() -> void:
	if Engine.editor_hint:
		if not _thread.is_active():
			_thread.start(self, "_detect_hit_states")
		pass

func _on_HitState_activated(hit_state: HitState2D) -> void:
	if switch_on_state_activated:
		deactivate_all_hit_states_except(hit_state)
	elif hit_state != get_current_hit_state_obj():
		hit_state.is_active = false
	pass

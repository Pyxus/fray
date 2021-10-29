tool
extends Node2D
## docstring

#inner classes

#signals

#enums

const EMPTY = -1

const HitState2D = preload("hit_state_2d.gd")

export var belongs_to: NodePath setget set_belongs_to
export var animation_player: NodePath setget set_animation_player

var current_hit_state: int setget set_current_hit_state
var assigned_animation: String

var _anim_player: AnimationPlayer
var _hit_states: Array = []
var _hit_state_by_id: Dictionary

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	var tree := get_tree()
	tree.connect("tree_changed", self, "_on_SceneTree_changed")
	_detect_hit_states()

func _get_configuration_warning() -> String:
	if _hit_states.empty():
		return "This node is expected to have HitState2D children."
	return ""

func deactivate_all_hit_states_except(exception: HitState2D = null) -> void:
	for hit_state in _hit_states:
		if hit_state != exception:
			hit_state.is_active = false
			
func set_belongs_to(value: NodePath) -> void:
	belongs_to = value
	_detect_hit_states()

func set_current_hit_state(value: int) -> void:
	current_hit_state = value

	if is_inside_tree():
		if current_hit_state != EMPTY:
			if _hit_state_by_id.has(current_hit_state):
				_hit_state_by_id[current_hit_state].is_active = true
			else:
				push_error("Current hit state value does not correspond to dictionary.")

func get_current_hit_state_obj() -> HitState2D:
	return null if not _hit_state_by_id.has(current_hit_state) else _hit_state_by_id[current_hit_state]


func set_animation_player(value: NodePath) -> void:
	animation_player = value
	_anim_player = null

	var anim_player = get_node_or_null(animation_player)
	if anim_player is AnimationPlayer:
		_anim_player = anim_player

func _detect_hit_states() -> void:
	set_animation_player(animation_player)
	
	_hit_states.clear()
	_hit_state_by_id.clear()
	
	
	var i: int = 0
	for child in get_children():
		if child is HitState2D:
			_hit_states.append(child)
			child.set_animation_player(_anim_player)
			child.set_boxes_belong_to(get_node_or_null(belongs_to))
			_hit_state_by_id[i] = child
			i += 1

			if not child.is_connected("activated", self, "_on_HitState_activated"):
				child.connect("activated", self, "_on_HitState_activated", [child])
	
	if _hit_states.empty():
		set_current_hit_state(EMPTY)
	
	#property_list_changed_notify() # I guess the act of trying to set am exported nodepath changes the tree so this will get changed and prevent the property from being updated.
	#update_configuration_warning() # Seems to cause this error 'Timer was not added to SceneTree. Either add it or set autostart to true.'
	return


func _on_SceneTree_changed() -> void:
	if Engine.editor_hint:
		_detect_hit_states()
		pass

func _on_HitState_activated(hit_state: HitState2D) -> void:
	deactivate_all_hit_states_except(hit_state)
	pass

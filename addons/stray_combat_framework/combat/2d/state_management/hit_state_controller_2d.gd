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
var _prev_state_count: int = 0

#onready variables


#optional built-in virtual _init method

func _init() -> void:
	if is_inside_tree():
		_detect_hit_states()

func _ready() -> void:
	_detect_hit_states()

func _process(delta: float) -> void:
	if _anim_player != null:
		if _anim_player.assigned_animation != assigned_animation:
			assigned_animation = _anim_player.assigned_animation

			for key in _hit_state_by_id:
				var hit_state: HitState2D = _hit_state_by_id[key]
				if hit_state.animation == assigned_animation:
					set_current_hit_state(key)
					break
				else:
					deactivate_hit_states()

	if Engine.editor_hint:
		if get_child_count() != 0:
			var state_count: int = _get_state_count()
			if _hit_states.empty() or _prev_state_count != _get_state_count():
				_detect_hit_states()
			else:
				for hit_state in _hit_states:
					if not hit_state is HitState2D:
						_detect_hit_states()
						break
			_prev_state_count = state_count
			return

func _get_configuration_warning() -> String:
	if _hit_states.empty():
		return "This node is expected to have HitState2D children."
	return ""

func deactivate_hit_states(exception: HitState2D = null) -> void:
	for hit_state in _hit_states:
		if hit_state != exception:
			hit_state.deactivate_boxes()
			hit_state.hide()
			
func set_belongs_to(value: NodePath) -> void:
	belongs_to = value
	_detect_hit_states()

func set_current_hit_state(value: int) -> void:
	current_hit_state = value

	if is_inside_tree():
		if current_hit_state != EMPTY:
			if _hit_state_by_id.has(current_hit_state):
				var _current_hit_state: HitState2D = _hit_state_by_id[current_hit_state]
				_current_hit_state.show()
				deactivate_hit_states(_current_hit_state)
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

"""func _get_property_list() -> Array:
	var properties: Array = []

	var state_names: PoolStringArray
	for state in _hit_states:
		state_names.append(state.name)
	
	if state_names.empty():
		state_names.append("[Empty]")
	
	properties.append({
	"name": "current_hit_state",
	"type": TYPE_INT,
	"usage": PROPERTY_USAGE_DEFAULT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": state_names.join(",")
	})
		
	return properties"""

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

			if not child.is_connected("active_box_set", self, "_on_HitState_active_box_set"):
				child.connect("active_box_set", self, "_on_HitState_active_box_set", [child])
			if not child.is_connected("animation_set", self, "_on_HitState_animation_set"):
				child.connect("animation_set", self, "_on_HitState_animation_set", [child])
	
	if _hit_states.empty():
		set_current_hit_state(EMPTY)

	property_list_changed_notify()
	update_configuration_warning()

func _get_state_count() -> int:
	var count := 0
	for child in get_children():
		if child is HitState2D:
			count += 1
	return count

func _on_HitState_animation_set(hit_state: HitState2D) -> void:
	if hit_state.animation != HitState2D.NO_ANIMATION:
		for state in _hit_states:
			if state != hit_state and state.animation == hit_state.animation:
				hit_state.animation = HitState2D.NO_ANIMATION
				push_warning("Animation '%s' is already associated with the '%s' hit state" % [state.animation, state.name])
				return

func _on_HitState_active_box_set(hit_state: HitState2D) -> void:
	if _anim_player != null and _anim_player.assigned_animation != hit_state.animation:
		hit_state.deactivate_boxes()
		push_warning("Attempt to activate hitbox in %s outside of associated animation" % [hit_state.name])
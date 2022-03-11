extends Resource

const Condition = preload("conditions/condition.gd")
const StringCondition = preload("conditions/string_condition.gd")

var AnimationTransition: GDScript = load("res://addons/stray_combat_framework/src/combat/state_management/animation_transition.gd")

var animation: String
var active_condition: Condition
var combat_animation: Resource setget set_combat_animation, get_combat_animation

var _transitions: Array
var _combat_animation := WeakRef.new()

func _init(animation: String = "", active_condition: Condition = null) -> void:
	self.animation = animation
	self.active_condition = active_condition
	

func transition_to(to_animation_state: Resource, switch_mode: int = 0, advance_condition: Condition = null) -> void:
	var transition = AnimationTransition.new()

	if to_animation_state == self:
		push_error("Failed to set transition. animation state can not transition to self.")
		return

	transition.to = to_animation_state
	transition.switch_mode = switch_mode
	transition.advance_condition = advance_condition if advance_condition != null else to_animation_state.active_condition
	_transitions.append(transition)

	if get_combat_animation() != null:
		get_combat_animation().associate_state(to_animation_state)

func get_next_transition(condition_dict: Dictionary) -> Resource:
	for transition in _transitions:
		if _is_condition_true(transition.advance_condition, condition_dict):
			return transition
	return null


func set_combat_animation(value) -> void:
	_combat_animation = weakref(value)

	for transition in _transitions:
		if transition.to.combat_animation != value:
			transition.to.combat_animation = value


func get_combat_animation() -> Resource:
	return _combat_animation.get_ref()


func _is_condition_true(condition: Condition, condition_dict: Dictionary) -> bool:
	if condition is StringCondition:
		if condition_dict.has(condition.condition_name):
			return condition_dict[condition.condition_name]
	return false

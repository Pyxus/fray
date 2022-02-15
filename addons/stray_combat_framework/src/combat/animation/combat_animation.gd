extends Resource

# TODO: Consider replacing conditinal animations with 'advance_conditon' transitions that support transition animations
# Really I just want to support animations like turning, and unblocking.
# Maybe leaving it to the user to the user to switch between conditions will be good enough?

var default_animation_queue: Array
var conditional_animations: Array


func _init(default_animation_queue: Array = []) -> void:
	self.default_animation_queue = default_animation_queue


func add_conditional_animation(condition: Resource, animation_queue: Array) -> void:
	var conditional_animation := ConditionalAnimation.new()
	conditional_animation.condition = condition
	conditional_animation.animation_queue = animation_queue
	conditional_animations.append(conditional_animation)


func has_animation(animation: String) -> bool:
	if default_animation_queue.has(animation):
		return true
		
	for cond_anim in conditional_animations:
		if cond_anim.animation_queue.has(animation):
			return true

	return false


class ConditionalAnimation:
	extends Reference

	var animation_queue: Array
	var condition: Resource
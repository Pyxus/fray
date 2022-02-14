extends Resource

# TODO: Consider replacing conditinal animations with 'advance_conditon' transitions that support transition animations
# Really I just want to support animations like turning, and unblocking.
# Maybe leaving it to the user to the user to switch between conditions will be good enough?

const ConditionalAnimation = preload("conditional_animation.gd")

var default_animation: String
var conditional_animations: Array

func _init(default_animation: String = "") -> void:
	self.default_animation = default_animation


func add_conditional_animation(conditional_animation: ConditionalAnimation) -> void:
	if conditional_animation.activation_condition == null:
		push_warning("Failed to add conditional animation. Animation data '%s' does not contain a activation_condition")
		return
		
	conditional_animations.append(conditional_animation)


func has_animation(animation: String) -> bool:
	if default_animation == animation:
		return true
		
	for cond_anim in conditional_animations:
		if cond_anim.animation == animation:
			return true
	return false

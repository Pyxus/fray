tool
extends Resource
## Abstract data class that holds the attributes of a hitbox

## Returns the color a hitbox with this attribute should be.
func get_color() -> Color:
	return _get_color_impl()

## Returns true if a hitbox with this attribute can interact with given hitbox.
func can_interact_with(hitbox: Area2D) -> bool:
	return can_interact_with_impl(hitbox)

## Virtual method used to define hitbox color.
## Currently this does nothing as godot does not provide
## an easy way to change the area colors in 2d and 3d.
func _get_color_impl() -> Color:
	return Color.black

## Virtual method used to define what hitboxes a hitbox with this attribute can interact with.
func can_interact_with_impl(hitbox: Area2D) -> bool:
	return true

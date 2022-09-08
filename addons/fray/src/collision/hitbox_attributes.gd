tool
extends Resource
## Abstract data class that holds the attributes of a hitbox

## Returns the color a hitbox with this attribute should be.
func get_color() -> Color:
	return _get_color_impl()

## Returns true if a hitbox with this attribute should allow detection of a given hitbox.
func allows_detection_of(hitbox: Area2D) -> bool:
	return allows_detection_of(hitbox)

## Virtual method used implement 'get_color'.
## Currently this does nothing as godot does not provide
## an easy way to change the area colors in 2d and 3d.
func _get_color_impl() -> Color:
	return Color.black

## Virtual method used to implement 'allows_detection_of'.
func allows_detection_of_impl(hitbox: Area2D) -> bool:
	return true

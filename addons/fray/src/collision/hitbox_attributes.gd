tool
extends Resource
## Abstract data class that holds the attributes of a hitbox

## Returns the color of this hitbox.
func get_color() -> Color:
	return _get_color_impl()

## Virtual method used to define hitbox color.
## Currently this does nothing as godot does not provide
## an easy way to change the area colors in 2d and 3d.
func _get_color_impl() -> Color:
	return Color.black

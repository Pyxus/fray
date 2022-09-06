tool
extends Resource
## Abstract data class that holds the attributes of a hitbox

## Used by Hitboxes to determine their color
## Currently this does nothing as godot does not provide
## an easy way to change the area colors in 2d and 3d.
func get_color() -> Color:
	return Color.black

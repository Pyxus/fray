tool
extends Resource
## Abstract data class used to hold the properties of a hitbox

func _init() -> void:
	push_warning("Deprecated Class")

## Returns the color of the attribute. Used by Hitboxes to determine their color
## For this to work correctly in Project Settings
## debug/shapes/collision/shape_color must be set to white.
# Current this only works for 2D as I don't know a way to change 3D Area colors
func get_color() -> Color:
	return Color.black

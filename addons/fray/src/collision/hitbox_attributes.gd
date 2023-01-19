@tool
@icon("res://addons/fray/assets/icons/hit_attributes.svg")
class_name FrayHitboxAttributes
extends Resource

## Abstract data class used to define hitbox attributes.

## Returns the color a hitbox with this attribute should be.
func get_color() -> Color:
	return _get_color_impl()

## Returns true if a hitbox with this attribute should allow detection of a given hitbox.
func allows_detection_of(attributes: Resource) -> bool:
	return _allows_detection_of_impl(attributes)

## Virtual method used implement 'get_color'.
## Currently this does nothing as godot does not provide
## an easy way to change the area colors in 2d and 3d.
func _get_color_impl() -> Color:
	return Color(0, 0, 0, .5)

## Virtual method used to implement 'allows_detection_of'.
func _allows_detection_of_impl(attributes: Resource) -> bool:
	return true

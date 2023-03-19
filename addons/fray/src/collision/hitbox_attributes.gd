@tool
@icon("res://addons/fray/assets/icons/hit_attributes.svg")
class_name FrayHitboxAttributes
extends Resource
## Abstract data class used to define hitbox attributes.

## Returns the color a hitbox with this attribute should be.
func get_color() -> Color:
	return _get_color_impl()

## Returns true if a hitbox with this attribute should allow detection of the given attributes.
func allows_detection_of(attributes: FrayHitboxAttributes) -> bool:
	return _allows_detection_of_impl(attributes)

## [code]Virtual method[/code] used to implement [method get_color].
## Currently this does nothing for [FrayHitbox3D].
func _get_color_impl() -> Color:
	return Color(0, 0, 0, .5)

## [code]Virtual method[/code] used to implement [method allows_detection_of] method
func _allows_detection_of_impl(attributes: FrayHitboxAttributes) -> bool:
	return true

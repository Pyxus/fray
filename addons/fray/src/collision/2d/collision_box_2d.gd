extends KinematicBody2D

## Source of the hitbox. 
## Can be used to prevent hitboxes produced by the same object from interacting
var source: Object setget set_source

func _init() -> void:
	FrayInterface.assert_implements(self, "IHitbox")

## Activates this hitbox allowing it to monitor and be monitored.
func activate() -> void:
	pass

## Deactivates this hitobx preventing it from monitoring and being monitored.
func deactivate() -> void:
	pass


func set_source(value: Object) -> void:
	source = value

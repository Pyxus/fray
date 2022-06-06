class_name FrayHitDetection
extends Object

func _init() -> void:
	assert(false, "The 'FrayHitDetection' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")

const HitBox2D = preload("2d/hitbox_2d.gd")
const HitboxSwitcher2D = preload("2d/hitbox_switcher_2d.gd")
const HitState2D = preload("2d/hit_state_2d.gd")
const HitStateCoordinator2D = preload("2d/hit_state_coordinator_2d.gd")
const HitAttributes = preload("hit_attributes.gd")

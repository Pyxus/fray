extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instantiated")
	free()

const HitboxAttributes = preload("hitbox_attributes.gd")
const Hitbox2D = preload("2d/hitbox_2d.gd")
const HitState2D = preload("2d/hit_state_2d.gd")
const HitStateManager2D = preload("2d/hit_state_manager_2d.gd")
const Hitbox3D = preload("3d/hitbox_3d.gd")
const HitState3D = preload("3d/hit_state_3d.gd")
const HitStateManager3D = preload("3d/hit_state_manager_3d.gd")

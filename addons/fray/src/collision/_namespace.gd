extends Object

func _init() -> void:
	assert(false, "This class provides a pseudo-namespace to other fray classes and is not intended to be instanced")
	free()

const HitboxAttributes = preload("hitbox_attributes.gd")
const Hitbox2D = preload("2d/hitbox_2d.gd")
const HitState2D = preload("2d/hit_state_2d.gd")
const HitStateSwitcher2D = preload("2d/hit_state_switcher_2d.gd")

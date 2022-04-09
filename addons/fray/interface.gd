class_name FrayInterface
extends Object

func _init() -> void:
    push_warning("The 'FrayInterface' class only provides pseudo-interface membership test and is not intended to be instanced")
    free()


static func implements_IHitbox(obj: Object) -> bool:
    if obj == null:
        return false

    return obj.has_method("deactivate") and obj.has_method("set_source") and obj.has_signal("activated")
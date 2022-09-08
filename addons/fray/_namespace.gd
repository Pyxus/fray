class_name Fray
extends Object

func _init() -> void:
	assert(false, "The 'Fray' class provides a pseudo-namespace to other fray classes and is not intended to be instanced")
	free()

const LIB_DIR = "res://addons/fray/lib/"
const ASSETS_DIR = "res://addons/fray/assets/"

const Collision = preload("src/collision/_namespace.gd")
const StateMgmt = preload("src/state_management/_namespace.gd")
const Input = preload("src/input/_namespace.gd")
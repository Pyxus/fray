tool
extends RigidBody2D
## A body intended to provide collision between FighterBody2Ds.
##
## FighterBodies are expected to use two kinds of bodies for collision. 
## their base body for environmental collision with the floor and walls, 
## and a collisionbox exclusively for collision with other FighterBodies.
## This is to accomadate dynamic collision shape changes to match a Fighter's animation.
## while maintaining a static collision shape with the environment.
## At this moment this seperation must be manually done by the user through collision layers/mask.

#inner classes

signal activated()

const COLLISION_BOX_COLOR = Color("fdff00")

#constants

#preloaded scripts and scenes

export var is_active: bool setget set_is_active

var belongs_to: Object
var pin_joint: PinJoint2D = PinJoint2D.new()

#private variables

#onready variables


func _init() -> void:
	mode = MODE_CHARACTER
	if Engine.editor_hint:
		set_process(true)
		return

func _ready() -> void:
	if Engine.editor_hint:
		return

	add_child(pin_joint)
	pin_joint.node_a = get_path()

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		modulate = COLLISION_BOX_COLOR
		_set_collision_shapes_disabled(is_active)
		return

#remaining built-in virtual methods

func join_with_body(body_path: NodePath) -> void:
	if get_node_or_null(body_path) is RigidBody2D:
		pin_joint.node_b = body_path

func set_is_active(value: bool) -> void:
	is_active = value

	if is_active:
		show()
		_set_collision_shapes_disabled(false)
		emit_signal("activated")
	else:
		hide()
		_set_collision_shapes_disabled(true)

func _set_collision_shapes_disabled(value: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = value
		

#signal methods

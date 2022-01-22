class_name StrayCF

# Combat
const CombatFSM = preload("combat/combat_fsm.gd")

# Combat2D
const CharacterBody2D = preload("combat/2d/body/character_body_2d.gd")
const FighterBody2D = preload("combat/2d/body/fighter_body_2d.gd")
const PushBox2D = preload("combat/2d/body/push_box_2d.gd")

const DetectionBox2D = preload("combat/2d/hit_detection/detection_box_2d.gd")
const HitBox2D = preload("combat/2d/hit_detection/hit_box_2d.gd")
const HurtBox2D = preload("combat/2d/hit_detection/hurt_box_2d.gd")

const BoxSwitcher2D = preload("combat/2d/box_switcher_2d.gd")
const HitState2D = preload("combat/2d/hit_state_2d.gd")
const HitStateController2D = preload("combat/2d/hit_state_controller_2d.gd")

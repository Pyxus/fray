class_name StrayCF

# Combat - Collision Detection
const CharacterBody2D = preload("src/combat/collision_detection/2d/body/character_body_2d.gd")
const RigidFighterBody2D = preload("res://addons/stray_combat_framework/src/combat/collision_detection/2d/body/rigid_fighter_body_2d.gd")
const RigidPushBox2D = preload("res://addons/stray_combat_framework/src/combat/collision_detection/2d/body/rigid_push_box_2d.gd")
const HitBox2D = preload("src/combat/collision_detection/2d/hit_box_2d.gd")
const BoxSwitcher2D = preload("src/combat/collision_detection/2d/box_switcher_2d.gd")
const HitState2D = preload("src/combat/collision_detection/2d/hit_state_2d.gd")
const HitStateController2D = preload("src/combat/collision_detection/2d/hit_state_controller_2d.gd")
const HitAttributes = preload("src/combat/collision_detection/hit_attributes/hit_attributes.gd")
const AttackAttributes = preload("src/combat/collision_detection/hit_attributes/attack_attributes.gd")
const HurtAttributes = preload("src/combat/collision_detection/hit_attributes/hurt_attributes.gd")

# Combat - State Management
const CombatState = preload("src/combat/state_management/combat_state.gd")
const CombatFSM = preload("src/combat/state_management/combat_fsm.gd")
const CombatTree = preload("src/combat/state_management/combat_tree.gd")
const InputData = preload("src/combat/state_management/transitions/input_data/input_data.gd")
const SequenceInputData = preload("src/combat/state_management/transitions/input_data/sequence_input_data.gd")
const VirtualInputData = preload("src/combat/state_management/transitions/input_data/virtual_input_data.gd")
const StringCondition = preload("res://addons/stray_combat_framework/src/combat/state_management/conditions/string_condition.gd")

# Combat - Animation
const CombatAnimationPlayer = preload("res://addons/stray_combat_framework/src/combat/animation/combat_animation_player.gd")
const CombatAnimation = preload("res://addons/stray_combat_framework/src/combat/animation/combat_animation.gd")
const ConditionalAnimation = preload("res://addons/stray_combat_framework/src/combat/animation/conditional_animation.gd")

# Input
const InputDetector = preload("src/input/input_detector.gd")
const DetectedInput = preload("src/input/detected_inputs/detected_input.gd")
const DetectedSequence = preload("src/input/detected_inputs/detected_sequence.gd")
const DetectedVirtualInput = preload("src/input/detected_inputs/detected_virtual_input.gd")
const SequenceData = preload("res://addons/stray_combat_framework/src/input/sequence/sequence_data.gd")

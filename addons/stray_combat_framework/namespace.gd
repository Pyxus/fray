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
const CombatTree = preload("src/combat/combat_tree.gd")
const CombatFSM = preload("src/combat/state_management/combat_fsm.gd")
const CombatState = preload("src/combat/state_management/combat_state.gd")
const CombatSituationFSM = preload("src/combat/state_management/combat_situation_fsm.gd")
const CombatSituationState = preload("src/combat/state_management/combat_situation_state.gd")
const CombatTransition = preload("src/combat/state_management/transitions/combat_transition.gd")
const EvaluatedCondition = preload("src/combat/state_management/transitions/conditions/evaluated_condition.gd")
const InputCondition = preload("src/combat/state_management/transitions/conditions/input_condition.gd")
const InputSequenceCondition = preload("src/combat/state_management/transitions/conditions/input_sequence_condition.gd")
const InputButtonCondition = preload("src/combat/state_management/transitions/conditions/input_button_condition.gd")

# Input
const InputDetector = preload("src/input/input_detector.gd")
const DetectedInput = preload("src/input/detected_inputs/detected_input.gd")
const DetectedInputSequence = preload("src/input/detected_inputs/detected_input_sequence.gd")
const DetectedInputButton = preload("src/input/detected_inputs/detected_input_button.gd")
const SequenceData = preload("src/input/sequence_data.gd")

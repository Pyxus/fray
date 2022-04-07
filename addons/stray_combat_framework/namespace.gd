class_name StrayCF

# Physics Body
const CharacterBody2D = preload("src/physics_body/2d/character_body_2d.gd")
const RigidFighterBody2D = preload("src/physics_body/2d/rigid_fighter_body_2d.gd")
const RigidPushBox2D = preload("src/physics_body/2d/rigid_push_box_2d.gd")

# Hit Detection
const HitBox2D = preload("src/hit_detection/2d/hit_box_2d.gd")
const BoxSwitcher2D = preload("src/hit_detection/2d/box_switcher_2d.gd")
const HitState2D = preload("src/hit_detection/2d/hit_state_2d.gd")
const HitStateController2D = preload("src/hit_detection/2d/hit_state_controller_2d.gd")
const HitAttributes = preload("src/hit_detection/hit_attributes/hit_attributes.gd")
const AttackAttributes = preload("src/hit_detection/hit_attributes/attack_attributes.gd")
const HurtAttributes = preload("src/hit_detection/hit_attributes/hurt_attributes.gd")

# Combat - State Management
const CombatGraph = preload("src/state_management/combat_graph.gd")
const CombatFSM = preload("src/state_management/combat_fsm.gd")
const ActionFSM = preload("src/state_management/action_fsm.gd")
const ActionState = preload("src/state_management/action_state.gd")
const SituationFSM = preload("src/state_management/situation_fsm.gd")
const SituationState = preload("src/state_management/situation_state.gd")
const InputTransition = preload("src/state_management/transitions/input_transition.gd")
const EvaluatedCondition = preload("src/state_management/transitions/conditions/evaluated_condition.gd")
const InputCondition = preload("src/state_management/transitions/conditions/input_condition.gd")
const InputSequenceCondition = preload("src/state_management/transitions/conditions/input_sequence_condition.gd")
const InputButtonCondition = preload("src/state_management/transitions/conditions/input_button_condition.gd")

# Input
const InputDetector = preload("src/input/input_detector.gd")
const DetectedInput = preload("src/input/detected_inputs/detected_input.gd")
const DetectedInputSequence = preload("src/input/detected_inputs/detected_input_sequence.gd")
const DetectedInputButton = preload("src/input/detected_inputs/detected_input_button.gd")
const SequenceData = preload("src/input/sequence_analysis/sequence_data.gd")
const InputBind = preload("src/input/input_data/binds/input_bind.gd")
const ActionInputBind = preload("src/input/input_data/binds/action_input_bind.gd")
const JoystickInputBind = preload("src/input/input_data/binds/joystick_input_bind.gd")
const JoystickAxisInputBind = preload("src/input/input_data/binds/joystick_input_bind.gd")
const KeyboardInputBind = preload("src/input/input_data/binds/keyboard_input_bind.gd")
const MouseInputBind = preload("src/input/input_data/binds/mouse_input_bind.gd")
const ConditionalInput = preload("src/input/input_data/conditional_input.gd")
const CombinationInput = preload("src/input/input_data/combination_input.gd")

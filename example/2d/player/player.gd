extends StrayCF.RigidFighterBody2D

const VirtualInputCondition = StrayCF.VirtualInputCondition
const CombatFSM = StrayCF.CombatFSM
const CombatState = StrayCF.CombatState
const CombatSituationFSM = StrayCF.CombatSituationFSM
const CombatSituationState = StrayCF.CombatSituationState
const CombatTransition = StrayCF.CombatTransition

enum VInput {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT,
	KICK,
	PUNCH,
	SLASH,
	HEAVY_SLASH,
}

onready var input_detector: StrayCF.InputDetector = get_node("InputDetector")
onready var combat_tree: StrayCF.CombatTree = get_node("CombatTree")
onready var ground_cast: RayCast2D = get_node("GroundCast")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

var max_jump_count: int = 1
var jump_count: int = 0

func _ready() -> void:
	Engine.time_scale = .8

	# Set up inputs
	input_detector.bind_action_input(VInput.UP, "up")
	input_detector.bind_action_input(VInput.DOWN, "down")
	input_detector.bind_action_input(VInput.LEFT, "left")
	input_detector.bind_action_input(VInput.RIGHT, "right")
	input_detector.bind_action_input(VInput.KICK, "kick")
	input_detector.bind_action_input(VInput.PUNCH, "punch")
	input_detector.bind_action_input(VInput.SLASH, "slash")
	input_detector.bind_action_input(VInput.HEAVY_SLASH, "heavy_slash")
	input_detector.register_combination(VInput.UP_LEFT, [VInput.UP, VInput.LEFT])
	input_detector.register_combination(VInput.UP_RIGHT, [VInput.UP, VInput.RIGHT])
	input_detector.register_combination(VInput.DOWN_LEFT, [VInput.DOWN, VInput.LEFT])
	input_detector.register_combination(VInput.DOWN_RIGHT, [VInput.DOWN, VInput.RIGHT])
	
	var qcb_p_sequence := StrayCF.SequenceData.new()
	qcb_p_sequence.append_inputs([VInput.DOWN, VInput.DOWN_LEFT, VInput.LEFT, VInput.PUNCH])
	input_detector.register_sequence_from_data("214P", qcb_p_sequence)
	
	# Input Conditions
	var punch_input_condition := VirtualInputCondition.new(VInput.PUNCH)
	var slash_input_condition := VirtualInputCondition.new(VInput.SLASH)
	var heavy_input_condition := VirtualInputCondition.new(VInput.HEAVY_SLASH)
	var kick_input_condition := VirtualInputCondition.new(VInput.KICK)
	
	var on_ground_fsm := CombatFSM.new()
	on_ground_fsm.add_state("Idle", CombatState.new())
	on_ground_fsm.add_state("5P", CombatState.new())
	on_ground_fsm.add_state("5S", CombatState.new())
	on_ground_fsm.add_state("5K", CombatState.new())
	on_ground_fsm.add_state("5H", CombatState.new())
	on_ground_fsm.add_state("5S-5S", CombatState.new())
	on_ground_fsm.add_transition("Idle", "5P", CombatTransition.new(punch_input_condition))
	on_ground_fsm.add_transition("Idle", "5S", CombatTransition.new(slash_input_condition))
	on_ground_fsm.add_transition("Idle", "5K", CombatTransition.new(kick_input_condition))
	on_ground_fsm.add_transition("Idle", "5H", CombatTransition.new(heavy_input_condition))
	on_ground_fsm.add_transition("5S", "5S-5S", CombatTransition.new(slash_input_condition))

	var state_machine := CombatSituationFSM.new()
	state_machine.add_state("OnGround", CombatSituationState.new(on_ground_fsm))

	combat_tree.state_machine = state_machine


func is_on_floor(find_immediate: bool = false):
	if ground_cast.is_colliding():
		return true
	return .is_on_floor(find_immediate)

"""
func _handle_movement(state: Physics2DDirectBodyState) -> void:
	._handle_movement(state)
	
	combat_fsm.set_all_conditions(false)
	input_detector.press_checks_enabled = true
	speed_on_slope = 300

	if jump_count < max_jump_count:
		if input_detector.is_input_just_pressed(VInput.UP_RIGHT):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(300, -1200))
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP_LEFT):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(-300, -1200))
			jump_count += 1
		elif input_detector.is_input_just_pressed(VInput.UP):
			state.linear_velocity = Vector2.ZERO
			apply_impulse(Vector2.ZERO, Vector2(0, -1200))
			jump_count += 1

	if is_on_floor(true):
		combat_fsm.set_condition("is_on_ground", true)
		jump_count = 0
		
		if not combat_fsm.is_current_state_root():
			input_detector.press_checks_enabled = false
		
		if not is_force_resolution_allowed():
			if input_detector.is_input_pressed(VInput.RIGHT):
				state.linear_velocity.x = 300
				combat_fsm.set_condition("is_walking_forward", true)
			elif input_detector.is_input_pressed(VInput.LEFT):
				state.linear_velocity.x = -300
				combat_fsm.set_condition("is_walking_backward", true)
			else:
				state.linear_velocity.x = 0
				pass
	else:
		combat_fsm.set_condition("is_in_air", true)
		
		if state.linear_velocity.y > 0:
			if state.linear_velocity.x < -0.1:
				combat_fsm.set_condition("is_falling_backward", true)
			elif state.linear_velocity.x > 0.1:
				combat_fsm.set_condition("is_falling_forward", true)
		else:
			if state.linear_velocity.x < -0.1:
				combat_fsm.set_condition("is_jumping_backward", true)
			elif state.linear_velocity.x > 0.1:
				combat_fsm.set_condition("is_jumping_forward", true)
				
			if input_detector.is_input_just_pressed(VInput.UP_LEFT):
				combat_animation_player.reset()
			elif input_detector.is_input_just_pressed(VInput.UP_RIGHT):
				combat_animation_player.reset()
"""

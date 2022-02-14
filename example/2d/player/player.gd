extends StrayCF.RigidFighterBody2D

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
onready var combat_fsm: StrayCF.CombatFSM = get_node("CombatFSM")
onready var ground_cast: RayCast2D = get_node("GroundCast")
onready var combat_animation_player: StrayCF.CombatAnimationPlayer = get_node("AnimationPlayer")

var max_jump_count: int = 1
var jump_count: int = 0

func _ready() -> void:
	Engine.time_scale = .2
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
	
	# Input Data
	var punch_input_data := StrayCF.VirtualInputData.new(VInput.PUNCH)
	var slash_input_data := StrayCF.VirtualInputData.new(VInput.SLASH)
	var heavy_input_data := StrayCF.VirtualInputData.new(VInput.HEAVY_SLASH)
	var kick_input_data := StrayCF.VirtualInputData.new(VInput.KICK)
	var up_input_data := StrayCF.VirtualInputData.new(VInput.UP)
	var up_right_data := StrayCF.VirtualInputData.new(VInput.UP_RIGHT)
	var up_left_data := StrayCF.VirtualInputData.new(VInput.UP_LEFT)
	
	# Standing States
	var sitch_standing := StrayCF.CombatTree.new()
	combat_fsm.add_tree(sitch_standing)

	var standing_root := sitch_standing.get_root()
	var standing_animation := StrayCF.CombatAnimation.new("idle")
	standing_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("walk_forward", StrayCF.StringCondition.new("is_walking_forward")))
	standing_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("walk_backward", StrayCF.StringCondition.new("is_walking_backward")))
	combat_animation_player.associate_state_with_animation(standing_root, standing_animation)
	
	var standing_punch := StrayCF.CombatState.new("normal")
	combat_animation_player.associate_state_with_animation(standing_punch, StrayCF.CombatAnimation.new("5p"))
	
	var standing_slash := StrayCF.CombatState.new("normal")
	combat_animation_player.associate_state_with_animation(standing_slash, StrayCF.CombatAnimation.new("5s"))
	
	var standing_heavy := StrayCF.CombatState.new("normal")
	combat_animation_player.associate_state_with_animation(standing_heavy, StrayCF.CombatAnimation.new("5h"))
	
	var standing_kick := StrayCF.CombatState.new("normal")
	combat_animation_player.associate_state_with_animation(standing_kick, StrayCF.CombatAnimation.new("5k"))
	
	var jump_neutral_start := StrayCF.CombatState.new("jump")
	combat_animation_player.associate_state_with_animation(jump_neutral_start, StrayCF.CombatAnimation.new("jump_neutral_start"))
	
	var jump_forward_start := StrayCF.CombatState.new("jump")
	combat_animation_player.associate_state_with_animation(jump_forward_start, StrayCF.CombatAnimation.new("jump_forward_start"))
	
	var jump_backward_start := StrayCF.CombatState.new("jump")
	combat_animation_player.associate_state_with_animation(jump_backward_start, StrayCF.CombatAnimation.new("jump_backward_start"))
	
	# Air States
	var sitch_in_air := StrayCF.CombatTree.new()
	combat_fsm.add_tree(sitch_in_air)
	
	var in_air_root := sitch_in_air.get_root()
	var in_air_animation := StrayCF.CombatAnimation.new("fall_neutral")
	in_air_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("fall_forward", StrayCF.StringCondition.new("is_falling_forward")))
	in_air_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("fall_backward", StrayCF.StringCondition.new("is_falling_backward")))
	in_air_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("jump_forward", StrayCF.StringCondition.new("is_jumping_forward")))
	in_air_animation.add_conditional_animation(StrayCF.ConditionalAnimation.new("jump_backward", StrayCF.StringCondition.new("is_jumping_backward")))
	combat_animation_player.associate_state_with_animation(in_air_root, in_air_animation)
	
	# Chaining
	#sitch_standing.add_global_chain_to(jump_neutral_start, up_input_data)
	#sitch_standing.add_global_chain_to(jump_forward_start, up_right_data)
	#sitch_standing.add_global_chain_to(jump_backward_start, up_left_data)
	
	#standing_punch.chain_to(standing_punch, punch_input_data)

	#standing_punch.chain_to(standing_kick, kick_input_data)

	standing_root.chain_to_global("jump")
	standing_root.chain_to(standing_punch, punch_input_data)
	standing_root.chain_to(standing_slash, slash_input_data)
	standing_root.chain_to(standing_heavy, heavy_input_data)
	standing_root.chain_to(standing_kick, kick_input_data)
	
	# Situation Transitions
	sitch_standing.add_transition_to(sitch_in_air, StrayCF.StringCondition.new("is_in_air"))
	sitch_in_air.add_transition_to(sitch_standing, StrayCF.StringCondition.new("is_on_ground"))

	combat_fsm.set_current_tree(sitch_standing)
	combat_fsm.revert_to_root()
	
	input_detector.press_checks_enabled = true



func is_on_floor(find_immediate: bool = false):
	if ground_cast.is_colliding():
		return true
	return .is_on_floor(find_immediate)


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
			if state.linear_velocity.x < 0:
				combat_fsm.set_condition("is_falling_backward", true)
			elif state.linear_velocity.x > 0:
				combat_fsm.set_condition("is_falling_forward", true)
		else:
			if state.linear_velocity.x < 0:
				combat_fsm.set_condition("is_jumping_backward", true)
			elif state.linear_velocity.x > 0:
				combat_fsm.set_condition("is_jumping_forward", true)

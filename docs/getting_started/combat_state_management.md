# Combat State Management

This module contains tools for managing a changes in a combatant's state

## Combat Situation

A combat siutation is a state machine which represents the set of actions available to a combatant during a given situation. State transitions occur based on user defined conditions such as the input (what button or sequence), prerequisites (can only transition on hit, on block, etc.), and minimum input delay (Useful for actions that require waiting such as square -> wait -> triangle).

### Combat State

A state within the combat situation which can be added with the `add_combat_state()` method. The first state added to a situation will be considered the initial state however the initial state can be changed when desired.
    const CombatSituation := FrayCombatState.CombatSituation

    var sitch_on_ground := CombatSituation.new()
    sitch_on_ground.add_combat_state("idle")

### Transitions

A transition determines what states are accessible from one another and on what conditions
    const CombatSituation := FrayCombatState.CombatSituation
    const InputButtonCondition := FrayCombatState.InputButtonCondition
    const InputSequenceCondition := FrayCombatState.InputSequenceCondition

    var sitch_on_ground := CombatSituation.new()
    sitch_on_ground.add_combat_state("idle")
    sitch_on_ground.add_combat_state("attack")
    sitch_on_ground.add_combat_state("special")
    sitch_on_ground.add_input_transition("idle", "attack", InputButtonCondition.new(Btn.PUNCH))
    sitch_on_ground.add_input_transition("idle", "special", InputSequenceCondition.new("236p"))
    # Button inputs and sequences are indentified with integers and strings respectively.
    # Now if the combatant is in their idle state pressing the attack button will cause them to move to the attack state.

### Global Transitions and Transition Rules

Combat states have optional tags, a global transition can be made to a state and a rule can then be added which allows states with a given tag to automatically transition to that global along the configured transition. This is a convinience feature as the same result could be acheived by manually adding transitions to each and every state. This is useful for adding states which are reachable from multiple states, for example in many fighting games "special" moves are reachable from all "normal" moves.
    const CombatSituation := FrayCombatState.CombatSituation
    const InputButtonCondition := FrayCombatState.InputButtonCondition
    const InputSequenceCondition := FrayCombatState.InputSequenceCondition

    var sitch_on_ground := CombatSituation.new()
    sitch_on_ground.add_combat_state("idle", ["neutral"])
    sitch_on_ground.add_combat_state("attack", ["normal"])
    sitch_on_ground.add_combat_state("special, ["special"])
    sitch_on_ground.add_input_transition("idle", "attack", InputButtonCondition.new(Btn.PUNCH))
    sitch_on_ground.add_global_transition("236p", InputTransition.new(InputSequenceCondition.new("236p")))
    sitch_on_ground.add_global_transition_rule("neutral", "special")
    sitch_on_ground.add_global_transition_rule("normal", "special")

## Combat Graph

The combat graph is a node used to navigate between states in a combat situation based on buffered inputs. Buffering allows a player to queue up a combatant's next action towards the end of the current action which makes for a smoother experience as otherwise frame perfect inputs would be required. The graph can also set when transitions are allowed to occur to control when a player can and can not 'cancel' their current state into the next; this is done by setting the `allow_transitions` property which can be done in an animation player to pair the 'cancel window' with the animation. The `goto_initial_state()` can be used at the end of an attack animation to return the combatant to an neutral state.
    onready var combat_graph: FrayCombatState.CombatGraph = $CombatGraph
    ...
    combat_graph.buffer_button(Btn.PUNCH)
    # If using Fray's input detection this can be done through the FrayInput singleton like so...
    
    FrayInput.connect("input_detected", self, "_on_FrayInput_input_detected")
    
    func _on_FrayInput_input_detected(input_event: FrayInputNS.FrayInputEvent)
        # This is done to only send pressed inputs without overlaps, it is not a requirement as the CombatSituation state machine
        # Also supports released inputs.
        # Note: If a large amount of inputs are fed the input buffer capacity will need to be increased to property detect the appropriate ones
        # In the future the buffer may be made to not have a fixed size.
        if input_event.is_just_pressed(true):
            combat_graph.buffer_button(Btn.PUNCH)

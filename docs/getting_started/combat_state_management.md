# Combat State Management

This module contains tools for managing a changes in a combatant's state.

Location: `fray/src/combat_state_management`

## Combat Situation

A combat siutation is a state machine which represents the set of actions available to a combatant during a given situation. State transitions occur based on user defined conditions such as the input (what button or sequence), prerequisites (can only transition on hit, on block, etc.), and minimum input delay (Useful for actions that require waiting between button presses such as square -> wait -> triangle).

### Combat Situation Builder

The combat situation builder is a helper class which uses the builder pattern to construct situations in a more user-friendly manner. Using the builder you can avoid needing to directly refference several of Fray's state management classes and also ignore some boilerplate such as needing to add all the state to a graph before setting up transitions. I recommend using this class instead of manually building a situation.

Note all builder methods returns a reference to the builder itself to allow for optional chaning; This is purely a stylistic choice. Another note, the builder is reset after build is called and can be used again. Builders by default cache identical resources it generates so reusing a builder can save a small amount of unnecessary memory use.

Example Usage:

    var graph_data := FrayCombatMgmt.CombatGraphData.new()
    var sb := FrayCombatMgmt.CombatSituationBuilder.new()

    # Making direct calls on the original builder reference
    sb.tag(["idle", "punch", "kick"], ["neutral"])
    sb.tag(["super_attack"], ["special"])
    sb.add_rule("neutral", "special")
    sb.transition("idle", "punch").on_button("square")
    sb.transition("idle", "kick").on_button("triangle")
    sb.global_transition("super_attacl").on_button("circle")
    graph_data.add_situation("on_ground", builder.build())

    # Optional Chaining method calls (My preffered approach)
    # In case you're unaware the \ is needed for godot to read the next line
    graph_data.add_situation("in_air", builder\
        .transition("idle", "air_punch").on_button("square")\
        .transition("idle", "air_kick").on_button("triangle")\
        .build()
    )

### Combat State

A state within the combat situation which can be added with the `add_state()` method. The first state added to a situation will be considered the initial state however the initial state can be changed when desired.
    const CombatSituation := FrayStateMgmt.CombatSituation

    var sitch_on_ground := CombatSituation.new()
    sitch_on_ground.add_combat_state("idle")

### Transitions

A transition defines what states are accessible from one another and on what conditions.

### Global Transitions and Transition Rules

All Combat states have an optional `tags` property. A global transition can be made to a state and a rule can then be added which allows states with a given tag to automatically transition to that global along the configured transition. This is a convinience feature as the same result could be acheived by manually adding transitions to each and every state. This is useful for adding states which are reachable from multiple states, for example in many fighting games "special" moves are reachable from all "normal" moves.

## Combat Graph

The combat graph is a node used to navigate between states in a combat situation based on buffered inputs. Buffering allows a player to queue up a combatant's next action towards the end of the current action which makes for a smoother experience as otherwise frame perfect inputs would be required. The graph can also set when transitions are allowed to occur to control when a player can and can not 'cancel' their current state into the next; this is done by setting the `allow_transitions` property which can be done in an animation player to pair the 'cancel window' with the animation. The `goto_initial_state()` can be used at the end of an attack animation to return the combatant to an neutral state.

Before you can use a combat graph you need to set it's 'graph_data'. `CombatGraphData` is just a collection of named situations.

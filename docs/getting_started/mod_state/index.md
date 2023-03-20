# State Management Module

## Introduction

The state management module includes two hierarchical state machines: a combat state machine intended for combatants which has built-in support for buffered input transitions, and a general-purpose state machine for capturing more general state flows. State management is an essential part of designing complex game mechanics, as it helps define the different states that a game entity can be in and the actions that can be performed in those states. For fighting games, this means defining which buttons transition into which attacks and what attacks are available during any given state.

## Using the CombatStateMachine

For this demonstration we will be using the `FrayCombatStateMachine`. However, all the information regarding building the states and transitions apply to the general-purpose `FrayGeneralStateMachine` as well. To get started, first add a `FrayCombatStateMachine` to the scene tree from the node creation dialog.

Once the state machine is added to the scene, you can begin adding situations. A situation is a name-to-`FrayRootState` mapping which represents the set of actions available to a combatant in a given circumstance. To add a new situation call the `add_situation()` method on the combat state machine. It accepts 2 arguments: a string name and a `FrayRootState`, which is what actually contains all the information related to states and transitions.

Using the root state builder the state machine can be assembled inline like so:

```gdscript

@onready var combat_state_machine: FrayCombatStateMachine = $CombatStateMachine

func _ready() -> void:
    combat_state_machine.add_situation("on_ground", FrayRootState.builder()
        .transition_button("idle", "attack_1", {input="btn_punch"})
        .transition_sequence("idle", "attack_2", {sequence="seq_236p"})
        .start_at("idle")
        .build()
    )
```

- The `transition_button()` and `transition_sequence()` methods both take 3 arguments. A 'from' state string, a 'to' state string, and a config dictionary. Note: the input name is an arbitrary string name and does not inherently reference anything related to the input module.
- There is also an `add_state()` method, but it is generally unnecessary unless you need to provide a custom `FrayState` object. By default, a state will automatically be created the first time the state name is referenced. Additionally, the first state added to the state machine will be used as the start state. Alternatively, you can use the builder's `start_at()` method to set the start state.

The above situation could be visualized like this:

![Visulization of described situation](images/situation_visualization.svg)

### Transition configs

The optional config dictionary allows for additional customization of the transition. Each key in the config dict corresponds to a property on the `FrayStateMachineTransition` object it uses.

Below demonstrates usage of the `prereqs` config. Prereqs take an array of conditions and only allow the transition to occur when all are true. To update the value of the condition the `set_condition()` method can be called on the `GraphNodeStateMachine`.

```gdscript
    combat_state_machine.add_situation("on_ground", FrayRootState.builder()
        .transition_button("idle", "attack_1", {input="btn_punch"})
        .transition_button("idle", "attack_2", {sequence="btn_punch", prereqs=FrayCondition.new("on_hit")})
        .build("idle")
    )

combat_state_machine.get_root().set_condition("on_hit", true)
```

The above situation could be interpreted as the subsequent attack only being performable if the previous attack hit.

### Global transitions

Global transitions are a convenience feature that allows you to automatically connect states based on global transition rules. If a rule exists. States with a given 'from_tag' will automatically have a transition setup to global states with a given 'to_tag'. This is useful for setting up transitions which need to be available from multiple states without needing to manually connect them. For example, in many fighting games you could say all attacks tagged as 'normal' may transition into attacks tagged as 'special'


```gdscript
var builder := Fray.State.CombatSituationBuilder.new()
combat_state_machine.add_situation("on_ground", FrayRootState.builder()
    .transition_button("idle", "attack_1", {input="btn_punch"})
    .transition_button("idle", "attack_2", {input="btn_punch"})
    .transition_sequence_global("special_attack", {sequence="seq_236p"})
    .multi_tag(["idle", "attack_1", "attack_2"], ["normal"])
    .tag("special_attack", ["special"])
    .add_rule("normal", "special")
    .build("idle")
)
```

The above situation could be interpreted as all normal attacks can transition into a special attack.

### Changing situations

To change situations you just need to update the `current_situation` property on the combat state machine.

```gdscript
combat_state_machine.current_situation = "on_ground"
```

## Restricting transitions

The combat state machine has an `allow_transitions` property. Enabling and disabling this property allows you to control when a combatant is allowed to switch states. For example, if this property is set to false for the entire duration of an attack animation and set to true at the end, the player is functionally unable to interrupt or cancel into another combat state. Conversely, if the property is set to true during the attack, the player could cancel into another combat state. This property can be keyed in the animation player allowing for easy syncing with animations.
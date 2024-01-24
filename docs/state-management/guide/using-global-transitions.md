# Using Global Transitions

## What Are Global Transitions?

Global transitions are a feature designed for convenience, enabling automatic connections between states based on transition rules. Within the state machine, states can be assigned tags, and transition rules can be established between tags. States with a specified 'from_tag' will automatically have transitions set up to states with a corresponding 'to_tag.' This simplifies the process of managing common transitions and reduces the need for repetitive code.

## How To Use Global Transitions

To leverage global transitions, start by assigning tags to relevant states using the builder's `tag()` method. A state can be assigned multiple tags as needed. Next, specify rules using the `add_rule()` method. Finally, make a state global by supplying it with a global transition. A state can have multiple global transitions, and when a rule is matched, a transition will be attempted for each specified global transition.

```gdscript
state_machine.initialize({}, FrayCompoundState.builder()
    .tag("idle", "normal")
    .tag("attack", "normal")
    .tag("sp_attack", "special")
    .add_rule("normal", "special")
    .transition_global("sp_attack")
    .transition("idle", "attack")
    .build()
)
```

Global versions also exist for the builder's `transition_press()` and `transition_sequence()` methods.

```gdscript
state_machine.initialize({}, FrayCompoundState.builder()
    .tag("idle", "normal")
    .tag("attack", "normal")
    .tag("sp_attack", "special")
    .add_rule("normal", "special")
    .transition_sequence_global("sp_attack", {sequence="214K"})
    .transition_press("idle", "attack", {input="punch_button"})
    .build()
)
```

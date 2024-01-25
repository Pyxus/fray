---
layout: doc
outline: [2, 6]
---

# Controlling State Transitions

## What Is A Transition?

When visualizing the state machine as a graph, a transition represents the connecting line from one state to another. The ability of the state machine to access another state depends on the conditions specified within these transitions. In Fray, only deterministic transitions are permitted, meaning that there can be only one connecting line between any two states.

[comment]: <Show picture depicting transition allowing one flow and not another>

## When Do Transitions Occur?

Transitions can only occur under the following conditions:

1. All transition prerequisites are true.
2. Auto advance is disabled, or if it is enabled, all advance conditions are true.
3. The transition accepts the given input.
4. And the transition switch mode is SwitchMode.Immediate, or the switch mode is SwitchMode.AtEnd and the current state is done processing.

Given these conditions, there are four ways to control the flow from one state to another.

## Defining Prerequisite and Advance Conditions

### What Are Conditions?

In Fray, a condition is a parameterless function that returns a boolean mapped to a string name. These conditions are utilized to define the prerequisite and advance conditions of a transition. Prerequisites consist of conditions that must be satisfied before a transition is allowed to occur. On the other hand, advance conditions are conditions that, if satisfied and with auto-advance enabled, trigger a transition. You can imagine prerequisites as stating "this must be true before you are allowed to transition," and advance conditions as declaring "if this is true, then try to transition."

### How Are Conditions Used?

To utilize conditions, they must first be registered within the state machine. This can be accomplished using the builder's `register_conditions()` method. Once registered, conditions can be accessed using the string name assigned to them.

```gdscript
state_machine.initialize({},FrayCompositeState.builder()
    .register_conditions({
        is_hungry = func(): return true,
        has_food = func(): return true,
    })
    .transition("idle", "eating", {
        prereqs=["has_food"],
        advance_conditions=["is_hungry"],
        auto_advance=true
    })
    .build()
)
```

In this example, the conditions "is_hungry" and "has_food" are registered and later applied to control the transition from the "idle" state to the "eating" state based on specified prerequisites and advance conditions.

### Condition Scope

Conditions defined at the root of a state machine hierarchy are available globally to the entire system. Conditions defined within a nested state machine will be treated as local to that state machine and will shadow any globally defined condition. However, the `$` symbol can be used to explicitly refer to the global definition of a condition.

In the provided example, 'a' would be allowed to transition into 'b'. Additionally, 'b/1' would be allowed to transition into 'b/2' even though the local condition returns false, as the global condition is being referenced using the $ symbol.

```gdscript
state_machine.initialize({},FrayCompoundState.builder()
    .register_conditions({
        can_transition = func(): return true,
    })
    .add_state("b", FrayCompoundState.builder()
        .register_conditions({
            can_transition = func(): return false
        })
        .transition("1", "2", {prereqs=["$can_transition"]})
        .build()
    )
    .transition("a", "b", {
        prereqs=["can_transition"]
    })
)
```

### Inverse Conditions

It is possible to check for the inverse of a condition by using the `!` symbol.

```gdscript
state_machine.initialize({},FrayCompositeState.builder()
    .register_conditions({
        is_hungry = func(): return true,
        has_food = func(): return true,
    })
    .transition("idle", "eating", {
        prereqs=["has_food"],
        advance_conditions=["is_hungry"],
        auto_advance=true
    })
    .transition("eating", "idle", {
        advance_conditions=["!is_hungry"],
        auto_advance=true
    })
    .build()
)
```

In this example, the transition from "eating" to "idle" occurs when the inverse condition of "is_hungry" is satisfied. The !is_hungry condition signifies the opposite state, allowing for control over state transitions based on the absence of a specified condition.

## Define Accepted Input (Custom Transitions)

::: tip Note
Input can be thought of as a transition-specific prerequisite.
:::

Input is an optional dictionary provided to the `FrayCompoundState`'s `advance()` method. The base `FrayStateMachineTransition` class accepts any input by default. Input is only relevant when attempting to manually advance the state machine along a custom transition.

To define the input that a transition accepts, first, extend `FrayStateMachineTransition` and override `_accepts_impl()` to return true when the desired input is supplied. Below is a transition that can only occur when an `is_jumping` input is supplied to the system.

```gdscript
class_name CustomTransition
extends FrayStateMachineTransition

func _accepts_impl(input: Dictionary) -> bool:
    return input.get("is_jumping", false)
```

To use a custom transition within your state machine, you must pass in an instance of the transition when adding a new transition like so:

```gdscript
state_machine.initialize({},FrayStateCompound.builder()
    .transition("on_floor", "in_air", {}, CustomTransition.new())
    .build()
)

state_machine.advance({is_jumping=true})
```

## Define When State Is Done Processing (Custom State)

If a transition's switch is set to `SwitchMode.AtEnd`, then the transition will only advance when the current state is done processing. By default, `FrayCompoundState` is considered done processing when its current state is equal to its end state, whereas the base `FrayState` is always considered done processing.

To define when a state is considered done processing, first extend `FrayState` and override `_is_done_processing_impl()` to return true when the state is considered to be done processing.

```gdscript
class_name CustomState
extends FrayState

func _is_done_processing_impl() -> bool:
    return ...
```

To use a custom state within your state machine, you must add an instance of the state when defining your state machine like so:

```gdscript
const SwitchMode = FrayStateMachineTransition.SwitchMode

...

state_machine.initialize({}, FrayStateCompound.builder()
    .add_state("a", CustomState.new())
    .transition("a", "b", {switch_mode=SwitchMode.AtEnd})
    .build()
)
```

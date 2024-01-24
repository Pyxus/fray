---
layout: doc
outline: [2, 6]
---

# Controlling State Transitions

## What Is A Transition?

Visualizing the state machine as a graph, a transition is the connecting line from one state to another. Whether or not the state machine can access another state is dependent on the conditions defined within these transitions. Within fray only deterministic transitions are allowed, meaning there can only be one connecting line btween any two states.

[comment]: <Show picture depicting transition allowing one flow and not another>

## When Do Transitions Occur?

State transitions can only occur under the following conditions:

1. All transition prerequisites are true.
2. Auto advance is disabled, or if it is enabled all advance conditions are true.
3. The transition accepts the given input.
4. And the transition swtich mode is `SwitchMode.Immediate`, or switch mode is `SwitchMode.AtEnd` and the current state is done processing.

This being the case there are 4 ways to control the flow from one state to another.

## Defining Prerequisite and Advance Conditions

### What Are Conditions?

In fray a condition is a parameterless function which returns a boolean mapped to a string name. These conditions are used to define the prerequisites and advance conditions of a transition. Prerequisites are a set of conditions which must be satisfied before a transition is allowed to occur. In contrast advance conditions are a set of conditions which if satisfied, and auto-advance is enabled, will cause a transition to occur. You can think of prerequisites as declaring "this must before true before you are allowed to transition", and advance conditions declaring "if this is true then try to transition."

### How Are Conditions Used?

In order to use conditions they must first be registered within the state machine which can be done using the builders `register_conditions()` method. Once registered the condition can be used through the string name you give to it.

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

### Condition Scope

Conditions defined on the root of a state machine hierarchy are available globally to the entire system. Conditions defined within a nested state machine will be treated as local to that state machine and will shadow any globally defined state machine. However, the `$` symbol can be used to strictly refer to the global definition of a condition.

In the example provided below 'a' would be allowed to transition into 'b'. And 'b/1' would be allowed to transition into 'b/2' even though the local condition returns false since the global condition is being referenced.

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

## Define Accepted Input (Custom Transitions)

::: tip Note
Input can be thought of as a transition specific prerequisite.
:::

Input is an optional dictionary provided to the `FrayCompoundState`'s `advance()` method. The base `FrayStateMachineTransition` class accepts any input by default. Input is only relevant when attempting to manually advance the state machine along a custom transition.

To define the input that a transition accepts first extend `FrayStateMachineTransition` and override `_accepts_impl()` to return true when the desired input is supplied. Below is a transition which can only occur when a `is_jumping` input is supplied to the system.

```gdscript
class_name CustomTransition
extends FrayStateMachineTransition

func _accepts_impl(input: Dictionary) -> bool:
    return input.get("is_jumping", false)
```

To use a custom transition within your state machine you must pass in an instance of the transition when adding a new transition like so:

```gdscript
state_machine.initialize({},FrayStateCompound.builder()
    .transition("on_floor", "in_air", {}, CustomTransition.new())
    .build()
)

state_machine.advance({is_jumping=true})
```

## Define When State Is Done Processing (Custom State)

If a transition's switch is set to `SwitchMode.AtEnd` then the transition will only advance when the current state is done processing. By default `FrayCompoundState` is considered to be done processing when its current state is equal to its end state, whereas the base `FrayState` is always considered to be done processing.

To define when a state is considered done processing. First extend `FrayState` and ovveride `_is_done_processing_impl()` to return true when the state is considered to be done processing.

```gdscript
class_name CustomState
extends FrayState

func _is_done_processing_impl() -> bool:
    return ...
```

To use a custom state within your state machine you must add an instance of the state when defining your state machine like so:

```gdscript
const SwitchMode = FrayStateMachineTransition.SwitchMode

...

state_machine.initialize({}, FrayStateCompound.builder()
    .add_state("a", CustomState.new())
    .transition("a", "b", {switch_mode=SwitchMode.AtEnd})
    .build()
)
```

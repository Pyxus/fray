# Using Input Transitions

## What Is An Input Transition?

Input transitions, distinct from [state machine transition inputs](/state-management/controlling-state-transitions#define-accepted-input-custom-transitions), are `FrayStateMachineTransition` implementations used to describe transitions based on input from devices such as a controller. Fray offers two types of input transitions: `FrayInputTransitionPress` and `FrayInputTransitionSequence`.

## How Do Input Transitions Work?

Input transitions do not automatically respond to device-inputs. All an input transition does is check if the provided state machine input contains specific entires satisfying the transition's configuration. Meaning the actual device-input must be checked for externally and then fed to the state machine though the `advance()` method.

```gdscript
state_machine.advance({
    input="jump",
    is_pressed=true,
    time_since_last_input=0, time_held=0
})

state_machine.advance({
    sequence="hadoken",
    time_since_last_input=0
})
```

::: tip Note
In a previous guide the state machine's advance mode was set to 'Manual' before calling `advance()`. However, advance can be called regardless of advance mode. There is no issue with having the state machine automatically advance while trying to advance manually, especially when supplying input data.
:::

## Using Press Transitions

`FrayInputTransitionPress` is used to define a transition triggered by a single press, like a button on a controller or a key on a keyboard. Press transitions can be created using the builder's `transition_press()` method, with the input name provided in the transition configuration.

```gdscript
state_machine.initialize({}, FrayCompoundState.builder()
    .transition_press("idle", "attack", {input="punch_button"})
    .build()
)
```

## Using Sequence Transitions

`FrayInputTransitionSequence` describes a transition triggered by a sequence of presses. Sequence transitions can be created using the builder's `transition_sequence()` method, with the sequence name provided in the transition configuration.

```gdscript
state_machine.initialize({}, FrayCompoundState.builder()
    .transition_sequence("idle", "hadoken", {sequence="236P"})
    .build()
)
```

## Taking Advantage of The Input Advancer

Fray provides a `BufferedInputAdvancer`, a node designed to automatically feed buffered input data to a state machine. If an input is accepted by the state machine, the advancer will stop processing new inputs for the current frame. 

To use the advancer, first add it as a child of the desired state machine. Then, buffer the desired inputs using the included `buffer_press()` and `buffer_sequence()` methods.

![](/assets/guides/input-advancer-in-scene.png)

```gdscript
if Input.is_action_just_pressed("ui_select"):
    advancer.buffer_press("jump_button")
```

Additionally, the advancer can be paused to control the timing of input feeding. Note that pausing doesn't stop the advancer; inputs can still be buffered during pauses, and they will expire if they exceed the maximum buffer time. This behavior allows the timeframe during which device inputs have the opportunity to trigger state transitions to be defined. Even if input buffering is not required, the advancer offers a friendly interface for feeding device inputs to a state machine.

```gdscript
advancer.paused = false
```
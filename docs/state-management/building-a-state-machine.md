---
layout: doc
outline: [2, 6]
---

# Building A State Machine

## What is a Hierarchical State Machine?

A state machine is a model that represents an entity's various states and the transitions between them in a finite and structured way. You can visualize a state machine as a graph where each point is a state and the connecting lines are transitions. To be hierarchical means that within each state there can exist entire state machines, which is useful when modeling more complex behaviors.

## 1. Add State Machine To Scene

Before you can begin building your state machine you will need to add a `FrayStateMachine` node to your scene. For this guide the node will be named 'StateMachine'

[comment]: <Show screenshot / gif of adding state machine to tree>

## 2. Build State Machine Root

All state machines require a `FrayCompoundState` root in order to function. Compound states are responsible for describing the set of states and transitions present within the state machine.

[comment]: <Show visual aid of state machine containing root which contains the states and transitions>

The compound state can be configured directly through methods such as `add_state()` and `add_transition()`. However, it is recommended to construct states using the included `FrayCompoundState.Builder`class. An instance of the class can be obtained through the static `FrayCompoundState.builder()` method.

```gdscript
# Explicit Configuration
var root := FrayCompoundstate.new()
root.add_state("a", FrayState.new())
root.add_state("b", FrayState.new())
root.add_state("c", FrayState.new())
root.add_transition("a", "b", FrayTransition.new())
root.add_transition("b", "c", FrayTransition.new())
root.add_transition("c", "a", FrayTransition.new())
root.start_state = "a"
root.end_state = "c"

# Builder Configuration
var root := (FrayCompoundState.builder()
    .start_at("a")
    .end_at("c")
    .transition("a", "b")
    .transition("b", "c")
    .transition("c", "a")
    .build()
)
```

[comment]: <Show visualization of this state machine>

With the exception of `build()`, all builder methods return an instance of the builder, allowing for chain method calls. Additionally, the builder will create a state instance whenever a state is mentioned, meaning it is not required to add a state before using it in a transition. However, the builder's `add_state()` is required if you wish to add a custom state.

## 3. Initialize State Machine

Before a state machine can be used it needs to be initialized. The `initialize()` method takes 2 arguments. First a context, which is a dictionary that can be used to provide read-only data to custom states added to the system. Second, a `FrayCompoundState`, which serves as the root of the state machine.

```gdscript
state_machine.initialize({}, FrayCompoundState.builder()
    .transition("a", "b", {auto_advance=true})
    .transition("b", "c", {auto_advance=true})
    .transition("c", "a", {auto_advance=true})
    .build()
)
```

Notice `transition()` takes an optional 3rd argument which allows you to configure properties belonging to `FrayStateMachineTransition`. For this example auto advance is enabled as a simple way to see the state machine in action.

## Conclusion

In order to observe your newly created state machine first select the state machine node in the tree and then from the inspector set the `active` property to true. Additionally, set `advance_mode` to manual. At the moment the state machine has nothing to limit its transitions so allowing it to advance automatically will result in the state machine cycling to the next avaialble state every frame.

[comment]: <Screenshot of properties in requested state>

Next in the root node of the scene you added the state machine to paste the following code:

```gdscript
var state_machine: FrayStateMachine = $StateMachine

func _ready() -> void:
    state_machine.state_changed.connect()

func _process():
    if Input.is_action_just_pressed("ui_select"):
        state_machine.advance()

func _on_StateMachine_state_changed(from: StringName, to: StringName) -> void:
    print("State transitioned from '%s' to '%s'" % [from, to])
```

Now whenever you press space the state will change and print a message informing that the current state has changed.

[comment]: <Photo or gif of print>

Alternatively the `print_adj()` method can be used to quickly print the state of a state machine for debug purposes.

```gdscript
func _process():
    if Input.is_action_just_pressed("ui_select"):
        state_machine.advance()
        state_machine.print_adj()
```

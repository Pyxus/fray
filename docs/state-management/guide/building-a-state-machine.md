---
layout: doc
outline: [1, 6]
---

# Building A State Machine

This guide will walk you through the creation of a basic state machine using the tools provided by Fray.

## 1. Add State Machine To Scene

Before you can begin building your state machine you will need to add a `FrayStateMachine` node to your scene.

[comment]: <Show screenshot / gift of adding state machine to tree>

## 2. Build State Machine Root

All state machines require a `FrayCompoundState` root in order to function. Compound states are responsible for describing the set of states and transitions present within the state machine.

[comment]: <Show visual aid of state machine containing root which contains the states and transitions>

The compound state can be configured directly through methods such as `add_state()` and `add_transition()`. However, it is recommended to construct states using the included `FrayCompoundState.Builder`class. An instance of the class can be obtained through the static `FrayCompoundState.builder()` method.

```gdscript
# Explicit Configuration
var root := FrayCompoundstate.new()
root.add_state("green", FrayState.new())
root.add_state("yellow", FrayState.new())
root.add_state("red", FrayState.new())
root.add_transition("green", "yellow", FrayTransition.new())
root.add_transition("yellow", "red", FrayTransition.new())
root.add_transition("red", "green", FrayTransition.new())
root.start_state = "green"
root.end_state = "red"

# Builder Configuration
var root := (FrayCompoundState.builder()
    .start_at("green")
    .end_at("red")
    .transition("green", "yellow")
    .transition("yellow", "red")
    .transition("red", "green")
    .build()
)
```

[comment]: <Show visualization of this state machine>

With the exception of `build()` all builder methods return an instance of the builder allowing for chain methods calls. Additionally, the builder will create a state instance whenever a state is mentioned, meaning it is not required to add a state before using it in a transition.

## 3. Initialize State Machine

Before a state machine can be used it needs to be initialized. The `initialize()` method takes 2 arguments. First a context, which is a dictionary that can be used to provide read-only data to custom states added to the system. Second, a `FrayCompoundState`, which serves as the root of the state machine.

```gdscript
state_machine.initialize({
    # This is just for demonstration.
    # There are no custom states in this example using the value.
    light_duration = 30
}, FrayCompoundState.builder()
    .transition("green", "yellow")
    .transition("yellow", "red")
    .transition("red", "green")
    .build()
)
```

## Conclusion

In order to see your newly created state machine in action first select the state machine node in the tree and then from the inspector set the `active` property to true and `advance_mode` to manual. At the moment the state machine has nothing to limit its transitions and so allowing it to advance automatically will result in the state machine cycling to the next avaialble state every frame.

[comment]: <Screenshot of properties in requested state>

Then in the root node of the scene you added the state machine to paste the following code. Now whenever you press space an adjacency list representing the 'state' of the state machine after each transition.

```gdscript
func _process():
    if Input.is_action_just_pressed("ui_select"):
        state_machine.advance()
        state_machine.get_root().print_adj()

```

---
layout: doc
outline: [2, 6]
---

# Providing Data To States

## Context

Context is read-only data provided on initialization, accessible to all states during the initialization process. It can be used to provide states with initial values and objects for them to observe or command. While it's technically possible to share an object with mutable data across states within the context, it's recommended to avoid communicating between states using mutable data. Ideally, a state machine models well-defined states and transitions. When states rely on mutable data, it can become challenging to reason about the system, as states are no longer independent.

```gdscript
state_machine.initialize({
    player_max_health=100
}, ...)
```

```gdscript
class_name CustomState

var player_max_health: float

func _ready(context: Dictionary) -> void:
    player_max_health = context.get("player_max_health", 0.0)
```

## Node Referencing

Nodes, like any other objects, can be provided to a state machine within the context. However, it is also possible for states to fetch node references using their `get_node()`, `get_node_of_type()`, and `get_nodes_of_type()` methods. `get_node()` will fetch a node relative to the state machine, while the 'type' variants will fetch nodes that are direct children of the state machine.

```gdscript
class_name CustomState

var anim_player: AnimationPlayer

func _ready(context: Dictionary) -> void:
    anim_player = get_node_of_type(AnimationPlayer)
```

This allows states to interact with and observe nodes within the scene providing the ability to encapsulate control of the game's behavior within different states.

## Object Constructor

When essential data is required for a state to function, it is recommended to provide this data through the state's constructor.

```gdscript
class_name CustomState
extends FrayState

var dep

func _init(dependency) -> void:
    dep = dependency
```

This ensures that the state receives the necessary information during its initialization.

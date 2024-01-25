---
layout: doc
outline: [2, 6]
---

# Registering Inputs

To utilize most features offered by the input module, you must first register inputs to the input map. These inputs can take the form of either binds or composites. Binds wrap around Godot's native input detection.

## Registering Input Binds

To register a bind, call one of the `add_bind` methods included with the `FrayInputMap` singleton. There are several types of binds available, but for this demonstration, we'll be using `FrayInputMap.add_bind_action()`, which utilizes Godot actions. The method requires two arguments: a unique name for the bind **(which must be unique between both composites and binds)**, and the name of the action you wish to bind.

```gdscript
FrayInputMap.add_bind_action("attack", "your_custom_godot_action")
FrayInputMap.add_bind_action("right", "ui_right")
FrayInputMap.add_bind_action("left", "ui_left")
FrayInputMap.add_bind_action("up", "ui_up")
FrayInputMap.add_bind_action("down", "ui_down")
```

## Registering Composite Inputs

To register composite inputs, the `FrayInputMap.add_composite_input()` method can be used, similar to how binds are registered. The method requires two arguments: a unique name for the bind **(which must be unique between both composites and binds)**, and a `FrayCompositeInput` instance, which can be composed using the included builder classes. Fray includes four composite inputs: Simple, Combinations, Conditions, and Groups.

### Simple Inputs

Simple inputs are essentially a composite input wrapper around binds since binds cannot be components of a composite input directly.

```gdscript
FrayInputMap.add_composite_input(
    "redundant_right",
    FraySimpleInput.from_bind("right")
)
```

The above example is just for demonstration; doing this would be redundant as the bind could be checked directly.

### Combination Inputs

Combination inputs are composed of two or more composite inputs and are triggered when their components are pressed.

Combinations can be set to one of three modes:

- Sync: which requires all components to be pressed at the same time.
- Async: which requires all components to be pressed regardless of time.
- Ordered: which requires all components to be pressed in the order they were added as components.

```gdscript
# This describes a synchronous combination.
# All buttons must be pressed at the same time.
# The example models Street Fighter 6's grab input.
FrayInputMap.add_composite_input("grab", FrayCombinationInput.builder()
    .add_component_simple("light_punch")
    .add_component_simple("light_kick")
    .mode_sync()
    .build()
)

# This describes an asynchronous combination.
# Both 'down' and 'right' must be pressed,
# but the order and timing of the presses do not matter.
# Many fighting games make use of motion inputs
# that rely on treating combinations of directional buttons
# as diagonal buttons.
FrayInputMap.add_composite_input("down_right", FrayCombinationInput.builder()
    .add_component_simple("down")
    .add_component_simple("right")
    .mode_async()
	# A virtual input will cause held binds to be repressed upon release.
	# This is useful for motion inputs:
	# For example, if you press [down] then [down + right],
    # and then release [down] but continue to hold [right]
	# you want [right] to trigger a press even though you technically
    # never pressed it again.
	# Otherwise, you would have to manually release [right] and press it again,
    # which would interrupt the "motion" of the motion input.
    .is_virtual()
    .build()
)

# This describes an ordered combination.
# 'right' must be pressed first, and then 'attack' must be pressed.
# Order matters, pressing them in reverse order will not work.
# However, timing does not matter.
# This is the behavior of the directional inputs present in fighting games.
FrayInputMap.add_composite_input("forward_punch", FrayCombinationInput.builder()
    .add_component_simple("right")
    .add_component_simple("attack")
	.mode_ordered()
	.build()
)
```

### Conditional Inputs

Conditional inputs change the input they represent based on callable conditions. The callable used for conditions must be of type `func(device: int) -> bool`. In the context of fighting games, conditional inputs can be used to add inputs that change depending on the side of the player. For example, if the player is on the left side of the opponent, an attack may be activated with [right + attack_button]. If the player is on the right side, the same attack can then be activated with [left + attack_button]. With conditional inputs, this can be generalized as [forward + attack_button], and the 'player side' condition updates to change the physical button 'forward' uses.

```gdscript
# This uses a conditional input to describe a combination input that
# changes based on what side the player is on.
FrayInputMap.add_composite_input("down_forward", FrayConditionalInput.builder()
    .add_component(FrayCombinationInput.builder()
        .add_component_simple("down")
        .add_component_simple("right")
        .mode_async()
        .build()
    )
    .add_component(FrayCombinationInput.builder()
        .add_component_simple("down")
        .add_component_simple("left")
        .mode_async()
        .build()
    ).use_condition(is_on_right)
    .is_virtual()
    .build()
)

func is_on_right(device: int) -> bool:
    return ...
```

### Group Inputs

Group inputs are considered pressed when a minimum number of components in the group is pressed. This is useful for flexible inputs that require any of a certain set of buttons to be pressed.

```gdscript
# This is registering a roman cancel input from the Guilty Gear series.
# It can be triggered by pressing any 3 attack buttons,
# which is the behavior this group input describes.
FrayInputMap.add_composite_input("roman_cancel", FrayGroupInput.builder()
    .add_component_simple("attack1")
    .add_component_simple("attack2")
    .add_component_simple("attack3")
    .add_component_simple("attack4")
	.min_pressed(3)
	.build()
)
```

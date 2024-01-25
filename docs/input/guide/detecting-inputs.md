---
layout: doc
outline: [2, 6]
---

# Detecting Inputs

`FrayInput` is a singleton similar to Godot's `Input` singleton. After configuring the input map, this manager can be used to check if binds and composites are pressed using their assigned names. While inputs can be checked per-device, the default behavior is to use device 0, which typically corresponds to the keyboard/mouse and the 'player1' controller. The input manager also contains an input_detected signal, which can be used to detect inputs in a similar manner to Godot's built-in `_input()` virtual method.

```gdscript
FrayInput.is_pressed("input_name")
FrayInput.is_just_pressed("input_name")
FrayInput.is_just_released("input_name")
FrayInput.get_axis("negative_input_name", "positive_input_name")
FrayInput.get_strength("input_name")

...

func _ready() -> void:
    FrayInput.input_detected.connect(_on_FrayInput_input_dected)

func _on_FrayInput_input_dected(event: FrayInputEvent) -> void:
	if event.input == "input_name" and event.is_pressed():
		do_something()

```

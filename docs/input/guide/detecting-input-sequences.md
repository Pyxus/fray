---
layout: doc
outline: [2, 6]
---

# Detecting Input Sequences

## Input Sequence Matching

Fray provides a sequence matcher that can be used to detect input sequences. To use this feature, you first need to create a `FraySequenceTree` object, which contains a mapping of sequence names to branch objects. Each sequence name can be associated with multiple `FraySequenceBranch` objects, which allow for alternative inputs. Alternative inputs are useful for creating leniency in a sequence by adding multiple matches for a given sequence name.

Example Usage:

```gdscript
var sequence_tree := FraySequenceTree.new()
var sequence_matcher := FraySequenceMatcher.new()

func _ready() -> void:
    # The following sequence describes the input for Ryu's famous 'Hadouken' attack.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
        .first("down").then("down_right").then("right").then("attack")
        .build()
    )

    # It can be frustating as a player for an attack to not be performed because of overly strict inputs.
    # This is an alternative input for the 'Hadoken' which can match even if the 'down_right' is skipped.
    # This supports leniency by catching the case where a player accidently releases 'down' before pressing 'right'.
    sequence_tree.add("hadouken", FraySequenceBranch.builder()
	    .first("down").then("right").then("attack")
	    .build()
    )

    # This sequence describes Guile's Sonic Boom attack.
    # This type of sequence is known as a "charge input" since it requires 'left' to be held for a certain amount of time, 200ms in this example, before the rest of the sequence is performed.
    sequence_tree.add("sonic_boom", FraySequenceBranch.builder()
	    .first("left", 200).then("right").then("attack")
	    .build()
    )

    sequence_matcher.initialize(sequence_tree)
```

In this example, I've named the sequences after the moves for the sake of clarity. However, while sequences generally stay the same, moves and their names are subject to change. For this reason it's recommend to choose names which describe the sequences rather than the move. A recommended naming convention is the Numpad Notation used in fighting games, which provides a clear and concise way to describe inputs using numbers that correspond to directions on a numeric keypad. You can find more information about Numpad Notation at https://www.dustloop.com/w/Notation.

## Understanding Negative Edge

In some fighting games, there is a special input behavior known as negative edge. Typically, an input sequence is considered valid only when every input is pressed in succession. However, for sequences that support negative edge, the last input in the sequence can be triggered by either a input press or a input release. This means that you can hold the last input in the sequence down, enter the rest of the sequence, and then release it to complete the sequence and trigger the attack. Fray supports this feature, and you can enable it by calling the `enable_negative_edge()` method when building your `FraySequenceBranch` objects.

Example Usage:

```gdscript
# The following sequence describes the input for Ryu's famous 'Hadouken' attack.
sequence_tree.add("hadouken", FraySequenceBranch.builder()
	.first("down").then("down_right").then("right").then("attack")
	.enable_negative_edge()
	.build()
)
```

## Using Sequence Matcher

To perform the match procedure, the sequence matcher uses `FrayInputEvent`s. You can feed events to the matcher using the `FrayInput` singleton's `input_detected` signal. If a matching sequence is found, the matcher will emit a `match_found` signal.

Example Usage:

```gdscript
var sequence_matcher := SequenceMatcher.new()

func _ready() -> void:
	FrayInput.input_detected.connect(_on_FrayInput_input_detected)
	sequence_matcher.match_found(_on_SequenceMatcher_match_found)

func _on_FrayInput_input_detected(input_event: Fray.Input.FrayInputEvent) -> void:
	sequence_matcher.read(input_event)

func _on_SequenceMatcher_match_found(sequence_name: String) -> void:
	do_something_with_sequence(sequence_name)

```

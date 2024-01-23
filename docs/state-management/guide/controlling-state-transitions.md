---
layout: doc
outline: [2, 6]
---

# Controlling State Transitions

State transitions can only occur under the following conditions:

1. The transition accepts the given input.
2. All transition prerequisites are true.
3. Auto advance is disabled, or if it is enabled all advance conditions are true.
4. And the transition swtich mode is immediate, or switch mode is at end and the current state is done processing.

This being the case there are 4 ways to control the flow from one state to another.

## Overriding Transition Accept Method

## Defining Transition Prerequisites

## Defining Transition Advance Conditions

## Overriving State Done Processing Method

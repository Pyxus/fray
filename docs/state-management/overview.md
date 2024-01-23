---
layout: doc
outline: [2, 6]
---

# State Management Module

## Purpose of Module

State management is vital when designing complex game mechanics. It involves defining the set of states a game entity can occupy and specifying the corresponding transitions to other states. In the context of action games, this encompasses mapping buttons to actions and determining which actions are accessible from any given state.

Fray provides an extendable general purpose hierarchical state machine which can be used to define state for entities such as combatants.

## What is a State Machine?

A state machine is a model that represents an entity's various states and the transitions between them in a finite and structured way. You can visualize a state machine as a graph where each point is a state and the connecting lines are transitions. To be hierarchical means that within each state there can exist entire state machines, which is useful when modeling more complex behaviors.

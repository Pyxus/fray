---
layout: doc
outline: [1, 6]
---

# State Management

State management is vital when designing complex game mechanics. It involves defining the set of states a game entity can occupy and specifying the corresponding transitions to other states. In the context of action games, this encompasses mapping buttons to actions and determining which actions are accessible from any given state.

Fray provides an extendable general purpose hierarchical state machine which can be used to define state for entities such as combatants.

# What is a State Machine?

A state machine is a model that represents an entity's various states and the transitions between them in a finite and structured away. You can visualize a state machine as a graph where each point is a state and the connecting lines transitions. To be hierarchical means that each state _can_ contain within it an entire state machine which is useful to model more complex behaviors.

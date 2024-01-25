---
layout: doc
outline: [2, 6]
---

# Hit Module

## Purpose Of Module

While Godot natively provides the necessary tools for hit detection through `Area` nodes, the hitbox configurations in fighting games frequently change. For example, a character's hitboxes when standing may differ from the configuration when crouching, attacking, or getting hit. Hitboxes can also possess various properties and interactions, such as hyper armor, which requires being hit a specific number of times before a character is interrupted, unless the attack is a grab. Managing multiple hitboxes with varying properties can be a tedious task. Therefore, the hit module is designed to simplify this process.

## What Is A Hitbox

In the context of this documentation, the term 'hitbox' refers to all forms of overlap detections, regardless of their purpose within the game. This includes both hitboxes that deal damage (often referred to as attack boxes) and hitboxes that detect damage (sometimes referred to as hurtboxes). It's important to note that Fray does not provide pre-defined implementations for attack or hurt boxes. However, Fray offers all that you need to define and manage your own hitboxes according to your game's requirements.

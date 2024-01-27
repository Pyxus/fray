---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Fray"
  text: "Documentation"
  tagline: 🐱‍👤 A modular combat framework for Godot 4.2+
  image: 
    light: /assets/icons/fray-logo-light.svg
    dark: /assets/icons/fray-logo-dark.svg
  actions:
    - theme: brand
      text: Get Started
      link: /introduction/what-is-fray
    - theme: alt
      text: View on GitHub
      link: https://github.com/Pyxus/fray

features:
  - title: State  Management
    details: Flexible hierarchical state machine useful for combatant and general state management.
  - title: Complex Input Detection
    details: Easily detect the complex inputs featured in many fighting games such as directional inputs, motion inputs, charged inputs, and sequence inputs.
  - title: Hitbox Organization
    details: Organize hitboxes into discrete hit states which can be keyed in the animation player.
---

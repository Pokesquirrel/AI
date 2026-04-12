# Roblox Dual AI System

This project implements a two-tier AI architecture for Roblox, inspired by the systems used in Alien: Isolation. It balances high-level game pacing with realistic, sensory-driven NPC behavior.

## Core Architecture

The system is split into two distinct layers:

1. **The Director (OmniVision)**: A global server-side system that monitors all players. It tracks a "Menace Gauge" (stress level) for each player and issues high-level "Jobs" to NPCs. This ensures players get moments of tension followed by necessary breathing room.
2. **The Hunter (Agent)**: The physical presence in the world (the Hero/Alien). It does not have access to the Director's global knowledge. It must use simulated sight and hearing to find the player, following a modular Behavior Tree to decide its actions.

## Folder Structure

- **src/Server**: Contains the Director AI, the AIManager for initialization, and specific logic for different NPC types (Hero, Guard, Drone, Dave).
- **src/Shared**: Contains core logic used by both scripts and modules, including the Behavior Tree framework, Sensory perception (sight/hearing), and the Memory system.
- **src/Client**: Contains the scalable HUD manager and visual feedback systems like noise ripples.

## Getting Started

1. **NPC Setup**: Place models in the Workspace named `Hero`, `Guard`, `Drone`, or `Dave`. 
2. **Patrol Paths**: For Guards, create Parts in the Workspace and give them the `GuardPath` tag using Roblox's Tag Editor.
3. **Initialization**: Call the AI Manager from a server-side script:
```lua
local AIManager = require(game.ServerScriptService.AI.Server.AIManager)
AIManager:Init()
```

## Technical Features

- **Behavior Trees**: NPCs use a hierarchy of tasks to prioritize behaviors like chasing, searching, and patrolling.
- **Realistic Senses**: Sight is calculated using field-of-view and raycasts. Hearing is calculated based on sound intensity and distance, accounting for wall obstructions.
- **Dynamic Pacing**: The Director automatically scales NPC aggression based on how much "Stress" the player has accumulated.
- **Scalable HUD**: UI components use aspect ratio constraints to maintain a premium look across different screen resolutions.

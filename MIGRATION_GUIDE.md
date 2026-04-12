# AI System Migration & Improvement Guide

This document explains the transition from the legacy files (in the `old/` directory) to the new structured system (in the `src/` directory).

## Component Mapping

| Legacy File (`old/`) | New Implementation (`src/`) | Improvements & Changes |
| :--- | :--- | :--- |
| `AIManager.lua` | `src/Server/AIManager.lua` | Centralized registration. Now handles complex initialization for distinct NPC classes (Hero, Drone, Guard, Dave). |
| `BaseAI` | `src/Shared/BaseAI.lua` | Added `.lua` extension for compatibility. Implements robust pathfinding with timeout/retry logic and distinct state tracking (`Idle`, `Searching`, etc.). |
| `DirectorAI.lua` | `src/Server/DirectorAI.lua` | **Major Upgrade**: Shifted from simple player tracking to a "Pacing Manager." It now manages player Stress/Menace and issues "Jobs" to NPCs to control game tension. |
| `GuardAI` | `src/Server/NPCs/GuardAI.lua` | Integrated with the new **Behavior Tree** and **Sensory Module**. Improved patrol logic using `CollectionService` tags. |
| `HunterAI.lua` | `src/Server/NPCs/HeroAI.lua` | **Complete Rewrite**: The "Hero" (Big AI) no longer "cheats" by knowing player locations. It uses simulated sight/hearing and follows a complex Behavior Tree. |
| `NoiseSystem.lua` | `src/Server/Systems/ThreatSystem.lua` | Decoupled into a dedicated **Threat System** that calculates real-time stress for the Director to act upon. |
| `Main.server.lua` | N/A | Entry logic is now handled via a modular call to `AIManager:Init()`, allowing for cleaner startup. |

## New Core Systems (Found in `src/`)

These systems did not exist in the legacy files and provide the backbone for the "Alien: Isolation" feel:

### 1. Behavior Tree (`src/Shared/BehaviorTree/`)
A modular decision-making framework. It allows NPCs to have complex, prioritized states (e.g., "Chase if seen" > "Search Job if assigned" > "Patrol if idle") without messy `if/else` ladders.

### 2. Sensory Module (`src/Shared/SensoryModule.lua`)
A unified physics-based perception engine. It handles:
- **Vision**: Field-of-View (FOV) calculations combined with Raycast checks for obstructions.
- **Hearing**: Sound intensity vs. distance checks with attenuation through walls.

### 3. Memory System (`src/Shared/MemorySystem.lua`)
Allows NPCs to "remember" locations. When the Hunter loses sight of a player, it now searches the "Last Known Position" stored in memory rather than simply stopping.

### 4. Scalable HUD (`src/Client/HUDManager.lua`)
A premium UI system designed for multi-resolution support. It uses `UIAspectRatioConstraint` to ensure the layout looks consistent on everything from mobile phones to ultrawide monitors.

## System Linkage & Data Flow

1. **Player Actions**: Create noise or presence.
2. **Threat System**: Monitors player activity and updates the **Director AI**.
3. **Director AI**: Evaluates the "Menace Gauge." If tension is too low, it selects a player and issues a **Search Job** near them.
4. **Hero AI (Hunter)**: Checks the Director's "Blackboard" for jobs. It travels to the assigned location and uses its **Sensory Module** to hunt locally.
5. **NPC Interaction**: If a **Drone** spots a player, it alerts the Director, which instantly increases the Hunter's aggression level.

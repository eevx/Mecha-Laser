# Manual Rotation Lever (Author: SG)

A Godot 4 script that creates an interactive lever mechanism. This script allows a player to "possess" the lever and manually rotate a target object (like a bridge, crane, or cannon) continuously between minimum and maximum angles.

## Features
- **Proximity Detection:** Only works when the player is inside the Area2D.
- **Activation System:** Player must press interaction key (`E`) to grab/release the lever.
- **Continuous Rotation:** Holding `A` or `D` rotates the target object smoothly over time.
- **Angle Clamping:** Prevents the object from rotating past defined min/max limits.
- **Visual Feedback:** Animated sprite changes based on the rotation direction (Left, Right, or Center).

## Scene Setup

1.  **Root Node:** Create an `Area2D` node.
2.  **Collision:** Add a `CollisionShape2D` child to define the interaction zone.
3.  **Visuals:** Add an `AnimatedSprite2D` child node named exactly `AnimatedSprite2D`.
4.  **Script:** Attach this script to the root `Area2D`.
5.  **Target Object:** Ensure the object you want to rotate (e.g., a platform) is in the scene.

### Animation Requirements
The `AnimatedSprite2D` must have a SpriteFrames resource with the following three animations:
* `"Left"` (Visual for tilting left)
* `"Right"` (Visual for tilting right)
* `"Center"` (Visual for neutral/idle state)

## Configuration (Inspector)

Once the script is attached, the following variables will appear in the Inspector dock:

| Property | Type | Description |
| :--- | :--- | :--- |
| **Object To Rotate** | `Node2D` | **Required.** Assign the node you want this lever to move. |
| **Min Angle** | `Float` | The furthest angle (in degrees) the object can rotate counter-clockwise (e.g., `-90`). |
| **Max Angle** | `Float` | The furthest angle (in degrees) the object can rotate clockwise (e.g., `90`). |
| **Rotation Speed** | `Float` | How fast the object spins in degrees per second. |

## Controls

| Key | Action |
| :--- | :--- |
| **E** | **Interact:** Toggles control of the lever on/off (must be close to lever). |
| **A** | **Rotate Left:** Decreases the angle (Counter-Clockwise). |
| **D** | **Rotate Right:** Increases the angle (Clockwise). |

## Logic Overview

1.  **Interaction:** When the player enters the area, `is_player_near` becomes true. Pressing `E` toggles `is_active`.
2.  **Physics Process:** While `is_active` is true, the script listens for `A` and `D` inputs.
3.  **Rotation:** - Input sets the `direction` (-1 or 1).
    - The `current_angle` is updated by `speed * delta`.
    - The angle is clamped so it never exceeds `Min Angle` or `Max Angle`.
4.  **Visuals:** The sprite animation plays based on the last input direction. 
    - *Note: If the player walks away, the lever automatically deactivates and the visual resets to center.*

## Example Usage
* **Drawbridges:** Rotate a bridge from 0° (flat) to -90° (upright).
* **Cannons:** Aim a cannon barrel before firing.
* **Cranes:** Move a hanging platform to a specific spot.

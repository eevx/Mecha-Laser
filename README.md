## 🎮 Mechanics Implemented (Author: SG)

### 1. Timed Button (`TimedButton`)
A pressure plate/button that activates when the player steps on it and automatically resets after a set duration.

* **Behavior:** * Detects `CharacterBody2D` entering the `Area2D`.
    * Plays "Press Down" animation immediately.
    * Starts a customized `Timer`.
    * Resets to "Press Up" animation upon timeout or if the player leaves the area early (logic configurable).
* **Key Nodes:** `Area2D`, `AnimatedSprite2D`, `Timer`.

### 2. 3-Way Control Lever (`3_way_lever`)
A complex interactive lever with three distinct states (Left, Center, Right) controlled by player input.

* **Behavior:**
    * **Proximity Detection:** Detects when the player is near using `Area2D` signals.
    * **Engagement:** Press **`E`** to grab/release the lever control.
    * **Toggle:** While engaged, press **`A`** (Left) or **`D`** (Right) to switch the lever's position.
    * **Visuals:** Updates `AnimatedSprite2D` based on a state machine (`enum Position`).

### 3. Player Controller
* Basic 2D platformer movement using `CharacterBody2D`.
* Implements `move_and_slide()` for proper collision handling with `StaticBody2D` floors.

## 🕹️ Controls

| Key            | Action                             |
|----------------|------------------------------------|
| **Arrow Keys** | Move Player                        |
| **E**          | Interact (Engage/Disengage Lever)  |
| **A / D**      | Move Lever Left/Right (if engaged) |

## 🛠️ Setup & Installation

1.  **Prerequisites:** Ensure you have [Godot Engine 4.x](https://godotengine.org/) installed.
2.  **Clone/Download:** Download this repository.
3.  **Import:** Open Godot, click "Import," and select the `project.godot` file in the root directory.
4.  **Run:** Press `F5` to play the main scene.

## 📂 Project Structure
```
SG
├── Assets/
│   ├── Sprites/       # Pixel art for Button, Lever, and Knight
├── Scenes/
│   ├── player.tscn        # CharacterBody2D prefab
│   ├── timed_button.tscn  # Area2D button logic
│   ├── 3_way_lever.tscn   # Lever logic
├── Scripts/
│   ├── player.gd
│   ├── timed_button.gd
│   ├── 3_way_lever.gd

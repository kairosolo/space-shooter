# Space Shooter

A 2D arcade space shooter built in Godot 4. Starts as a simple asteroid dodger/shooter and adds tweened VFX, a combo system, and scaling difficulty.

## Features

- **Auto-fire**: Hold Space to shoot with a short cooldown and ship recoil.
- **Combo system**: Destroying meteors builds a score multiplier. Getting hit resets the streak.
- **Scaling difficulty**: Asteroids gradually speed up the longer a run lasts.
- **Hit feedback**: Directional knockback away from impacts, screen shake, red hit-flash, and 1s of blinking i-frames.
- **Tweened UI**: Pop animations for score/combos, shattering health icons, and a hold-to-restart charge effect on the game over screen.

## Controls

- **Move**: WASD / Arrow Keys
- **Shoot**: Hold Space
- **Restart**: Hold Space (on Game Over)

## Running the Project

1. Open Godot 4.x and import `project.godot`.
2. Make sure `global.gd` is set as an Autoload named `Global` in Project Settings.
3. Press `F5` to play.

## Credits

Art and UI assets from [Kenney's Space Shooter Redux](https://kenney.nl/assets/space-shooter-redux) (CC0).
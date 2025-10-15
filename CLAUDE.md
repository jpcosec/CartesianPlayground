# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CartesianPlayground is a Pygame-based interactive educational tool for visualizing and manipulating geometric figures on a Cartesian coordinate plane. It includes real-time camera-based stress level detection to potentially adapt the learning experience based on user state.

## Running the Application

```bash
python app.py
```

The application requires:
- Python with pygame-ce, pygame_gui, and opencv-python (see requirements.txt)
- A webcam for the face detection/stress monitoring feature
- The Haar Cascade XML file at `camera/haarcascade_frontalface_default.xml`

## Core Architecture

### Main Application Flow (app.py)

The `App` class orchestrates three concurrent systems:
1. **Pygame rendering loop** (60 FPS main thread) - handles UI, user input, and figure manipulation
2. **Camera thread** (background) - captures frames every `CAPTURE_TIME` seconds (default: 5s) and processes stress levels
3. **UI management** (pygame_gui) - handles modal windows and text input

**Threading coordination**: The camera thread is controlled via `self.stop_event` (threading.Event). Always ensure proper cleanup by calling `stop_event.set()` and `camera_thread.join()` before exit.

### Module Architecture

**interface/** - UI and geometry rendering
- `cartesian_plane.py`: Main coordinator that inherits from Grid, manages figure lifecycle
- `grid.py`: Base class handling coordinate system transformations between screen pixels and Cartesian coordinates
- `figures.py`: Three figure types (Figure/rectangle, Point/circle, Line) with shared hover/selection/movement behavior
- `header.py`: Top toolbar with buttons and instruction window system
- `user.py`: Event processing wrapper that normalizes pygame events into application state

**camera/** - Computer vision integration
- `face_detector.py`: StressLevelDetector class using Haar Cascades, saves frames/CSV data to timestamped folders in `frames/` and `output/`
- `camera.py`: Currently just imports (minimal implementation)

**Coordinate System**: The Grid class provides bidirectional conversion:
- `get_cartesian_coordinates(mouse_pos)`: Screen pixels → Cartesian (x,y)
- `get_game_coordinates(cartesian_pos)`: Cartesian (x,y) → Screen pixels

### Figure State Management

All figures (Figure, Point, Line) share a three-state system:
- **pasive** (gray): Default state
- **hover** (red): Mouse is over the figure
- **selected** (dark gray): Figure is clicked and being manipulated

**Line-specific behavior**: Lines have two interaction modes controlled by `setting_slope`:
1. When `setting_slope=True`: Dragging adjusts the line's slope (rotates around initial point)
2. When `setting_slope=False`: Dragging translates the entire line (triggered by clicking near the origin point shown in cyan)

The line must be initialized (clicked once) before the origin point becomes interactive.

## Configuration (config.py)

All constants are centralized here:
- Display dimensions, colors, font sizes
- Camera capture interval and output paths
- Button visual states

**To modify**: Edit config.py rather than hardcoding values in modules.

## Current Limitations & TODOs

From code comments:
- Thread cleanup may not work properly in all exit scenarios (app.py:93)
- Line coordinate system needs better handling of division by zero (figures.py:145)
- Message system class is planned but not implemented (app.py:90)
- Problem/exercise class system is planned (app.py:91)
- Colinearity detection is planned (app.py:92)

## Development Notes

**When adding new figure types**:
1. Inherit from `Figure` base class in `interface/figures.py`
2. Override `draw()`, `check_hover()`, and `move()` methods
3. Add figure type handling in `Cartesian_plane.new_figure()` (interface/cartesian_plane.py:51)
4. Add corresponding button to `Header.__init__()` buttons dict (interface/header.py:60)

**Camera/stress detection**: Currently uses placeholder random logic (`get_stress_level()` in face_detector.py:28). Actual stress detection algorithm needs implementation - the Haar Cascade face detection is working, but stress classification is stubbed out.

**Output data**: The StressLevelDetector saves:
- Raw frames to `frames/{timestamp}/{count}.jpg`
- Face bounding boxes to `output/{timestamp}/{count}.csv`

Data format per CSV: Each line is `x,y,w,h` for detected face rectangles.

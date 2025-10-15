# CartesianPlayground

An interactive educational tool for visualizing and manipulating geometric figures on a Cartesian coordinate plane.

## Overview

CartesianPlayground is designed to help students learn about Cartesian coordinates, geometry, and basic transformations through an interactive visual interface. Users can create points, lines, and other geometric figures, then manipulate them to understand their mathematical properties.

## Available Implementations

This repository contains two implementations of the same application:

### 1. Pygame Version (`pygame/`)
- **Language**: Python
- **Dependencies**: pygame-ce, pygame_gui, opencv-python (for face detection)
- **Features**: Full feature set including camera-based stress detection
- **Best for**: Development, Python environments, research features

**Run:**
```bash
cd pygame
conda activate cartesian_playground  # or your environment
python app.py
```

### 2. LOVE2D Version (`love2d/`)
- **Language**: Lua
- **Dependencies**: LOVE2D 11.4+
- **Features**: Core geometric playground (no camera features)
- **Best for**: Distribution, cross-platform deployment, simpler setup

**Run:**
```bash
cd love2d
love .
```

See individual README files in each folder for detailed instructions.

## Features

- **Interactive Grid**: Visual Cartesian coordinate system with labeled axes
- **Geometric Figures**:
  - Points (draggable circles)
  - Lines (adjustable slope and position)
  - Rectangles (basic figures)
- **Real-time Coordinate Display**: Shows position in Cartesian coordinates
- **Intuitive Controls**: Mouse-based interaction for all operations

### Line Manipulation (Special Feature)
Lines have two interaction modes:
1. **Slope adjustment**: Drag the line to rotate it around the origin point
2. **Translation**: After initialization, click the origin (cyan circle) to move the entire line

## Documentation

- **CLAUDE.md**: Guidance for AI assistants working on this codebase
- **docs/MIGRATION_LOVE2D.md**: Complete migration guide from Pygame to LOVE2D
- **docs/MIGRATION_GODOT.md**: Migration guide for Godot Engine (future)

## Project Structure

```
CartesianPlayground/
├── pygame/              # Original Python/Pygame implementation
│   ├── app.py          # Main application
│   ├── config.py       # Configuration constants
│   ├── interface/      # UI components
│   └── camera/         # Face detection module
├── love2d/             # LOVE2D/Lua implementation
│   ├── main.lua        # Entry point
│   ├── config.lua      # Configuration
│   ├── interface/      # UI components (ported)
│   └── lib/            # Third-party libraries
├── docs/               # Documentation
│   ├── MIGRATION_LOVE2D.md
│   └── MIGRATION_GODOT.md
├── CLAUDE.md          # AI assistant guidance
└── README.md          # This file
```

## Getting Started

### Quick Start (LOVE2D - Recommended for first-time users)

1. Install LOVE2D: https://love2d.org/
2. Run the application:
   ```bash
   cd love2d
   love .
   ```

### Development Setup (Pygame)

1. Create conda environment:
   ```bash
   conda create -n cartesian_playground python=3.9
   conda activate cartesian_playground
   ```

2. Install dependencies:
   ```bash
   cd pygame
   pip install -r requirements.txt
   ```

3. Run:
   ```bash
   python app.py
   ```

## Usage

1. **Creating Figures**:
   - Click a button in the header (point, line)
   - Click on the grid to create the figure

2. **Moving Figures**:
   - Click and drag any figure
   - Figures turn red when hovered, dark gray when selected

3. **Instructions**:
   - Click the "intro" button for in-app help

## Planned Features (TODOs)

From the codebase:
- [ ] Message class for displaying instructions/hints
- [ ] Problem class system for educational exercises
- [ ] Colinearity detection for multiple points
- [ ] Improved thread cleanup (Pygame version)

## Contributing

When contributing, please:
1. Read `CLAUDE.md` for architecture guidance
2. Choose the appropriate implementation (Pygame for new features, LOVE2D for polish)
3. Update documentation in `docs/` if adding major features
4. Test in both implementations if modifying core logic

## WezTerm Integration

This project includes WezTerm auto-activation for conda environments. See `.wezterm-init.sh` and the global CLAUDE.md for details.

## License

[To be added - specify your license]

## Changelog

See git history for detailed changes. Major milestones:
- Initial Pygame implementation with figures and grid
- Added independent camera module
- Threading integration
- LOVE2D migration (complete port)

## Credits

- Original concept and Pygame implementation: [Your name]
- LOVE2D migration: Claude Code
- Middleclass (LOVE2D OOP): Enrique García Cota

## Support

For issues or questions:
- Check the README in the specific implementation folder
- Review migration guides in `docs/`
- See `CLAUDE.md` for architecture details

# CartesianPlayground - LOVE2D Version

This is a LOVE2D port of the CartesianPlayground educational application, originally written in Pygame.

## Requirements

- LOVE2D 11.4 or higher: https://love2d.org/

## Running the Application

### Option 1: From the command line
```bash
cd /path/to/CartesianPlayground/love2d
love .
```

### Option 2: Drag and drop
Drag the `love2d/` folder onto the LOVE executable.

### Option 3: Create a .love file (for distribution)
```bash
cd love2d
zip -r ../CartesianPlayground.love .
love ../CartesianPlayground.love
```

## Controls

- **ESC**: Exit the application
- **Mouse**: Interact with the UI and figures

## Features

### Header Buttons
- **intro**: Toggle instruction window
- **point**: Create a point (circle) on the grid
- **line**: Create a line on the grid

### Figure Interaction
1. **Point**: Click and drag to move
2. **Line**:
   - Initial drag: Set the slope (rotate the line)
   - After first click: A cyan circle appears at the origin
   - Click and drag the cyan circle: Translate the entire line
3. **Hover**: Figures turn red when hovered
4. **Selected**: Figures turn dark gray when selected/dragged

### Grid
- Shows Cartesian coordinates with labeled axes
- Displays mouse position in Cartesian coordinates when hovering over the grid
- Shows figure position in Cartesian coordinates when hovering over a figure

## Project Structure

```
love2d/
├── main.lua                 # Entry point
├── conf.lua                 # LOVE configuration
├── config.lua               # Constants and colors
├── lib/
│   └── class.lua           # Middleclass OOP library
└── interface/
    ├── grid.lua            # Grid base class
    ├── cartesian_plane.lua # Main coordinate plane (inherits Grid)
    ├── figures.lua         # Figure, Point, Line classes
    ├── header.lua          # Header and Button classes
    └── user.lua            # User input handler
```

## Differences from Pygame Version

### Advantages
- Simpler dependency management (only LOVE2D required)
- Cross-platform distribution via .love files
- Slightly better performance on some systems
- Anti-aliased lines by default

### Limitations
- No camera/face detection (removed from this version)
- Instruction window is simpler (no pygame_gui dependency)

## Development

### Adding New Figure Types

1. Open `interface/figures.lua`
2. Create a new class that inherits from `Figure`:
   ```lua
   local MyFigure = class('MyFigure', Figure)

   function MyFigure:initialize(pos)
       MyFigure.super.initialize(self, pos, nil, {size_x, size_y})
       -- Your initialization
   end

   function MyFigure:draw()
       -- Your drawing code
   end
   ```
3. Add to exports at bottom of `figures.lua`
4. Update `cartesian_plane.lua` `new_figure()` method
5. Add button to `header.lua` if needed

### Debugging

Enable debug output:
```lua
-- In main.lua, add to love.draw():
love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
```

## Known Issues

- Line hover detection may be imprecise for very steep slopes
- Window close button requires clicking the X (no click-outside-to-close)

## License

Same license as the original CartesianPlayground project.

## Credits

- Original Pygame implementation: CartesianPlayground
- LOVE2D port: 2025
- Middleclass library: Enrique García Cota (kikito)

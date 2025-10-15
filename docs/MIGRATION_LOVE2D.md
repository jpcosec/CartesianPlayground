# LOVE2D Migration Plan

## Overview
This document provides a step-by-step plan to migrate CartesianPlayground from Pygame to LOVE2D (Lua). The migration preserves the immediate-mode rendering paradigm and similar code structure.

**Estimated Time**: 2-3 days
**Difficulty**: Easy-Medium (5/10)
**Language**: Python → Lua

---

## Prerequisites

1. Install LOVE2D 11.4+: https://love2d.org/
2. Install Lua 5.1 (comes with LOVE)
3. Optional: Install ZeroBrane Studio or VS Code with Lua extension for debugging

---

## Phase 1: Project Structure Setup (2 hours)

### Directory Layout
```
CartesianPlayground/
├── main.lua                 # Entry point (replaces app.py)
├── conf.lua                 # LOVE configuration
├── config.lua               # Constants (replaces config.py)
├── interface/
│   ├── grid.lua             # Grid class
│   ├── cartesian_plane.lua  # CartesianPlane class
│   ├── figures.lua          # Figure, Point, Line classes
│   ├── header.lua           # Header and Button classes
│   └── user.lua             # User input handler
└── lib/                     # Third-party libraries
    └── class.lua            # Class system (e.g., middleclass)
```

### Step 1.1: Create conf.lua
```lua
function love.conf(t)
    t.title = "Playground Cartesiano"
    t.version = "11.4"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = 1
    t.modules.joystick = false
    t.modules.physics = false
end
```

### Step 1.2: Install class library
Download middleclass: https://github.com/kikito/middleclass
Place in `lib/class.lua`

---

## Phase 2: Port Configuration (30 minutes)

### config.lua
```lua
-- config.lua
local config = {}

-- Colors (RGB normalized 0-1 in LOVE, not 0-255)
config.COLOR_WHITE = {1, 1, 1}
config.COLOR_BLACK = {0, 0, 0}
config.COLOR_DARK_GRAY = {0.27, 0.27, 0.27}
config.COLOR_LIGHT_GRAY = {0.78, 0.78, 0.78}
config.COLOR_BLUE = {0, 0, 1}
config.COLOR_RED = {1, 0, 0}
config.COLOR_CYAN = {0, 1, 1}

config.COLOR_FONT = {0, 0, 0}
config.SIZE_DISPLAY = {800, 600}
config.SCREEN_WIDTH = 800
config.SCREEN_HEIGHT = 600

-- Header
config.COLOR_BACKGROUND = {1, 1, 1}
config.COLOR_HEADER = {0.08, 0.08, 0.08}
config.HEADER_SIZE = 40
config.COLOR_BUTTON_HOVERED = config.COLOR_RED
config.COLOR_BUTTON_ACTIVE = config.COLOR_DARK_GRAY
config.COLOR_BUTTON_PASIVE = config.COLOR_LIGHT_GRAY

-- Grid
config.FONT_SIZE = 25
config.CELL_SIZE = 20

return config
```

**Key difference**: LOVE uses normalized colors (0-1) instead of (0-255).

---

## Phase 3: Port Grid System (3 hours)

### interface/grid.lua

```lua
-- interface/grid.lua
local class = require 'lib.class'
local config = require 'config'

local Grid = class('Grid')

function Grid:initialize(width, height, cell_size, header_height, font)
    self.width = width
    self.height = height
    self.cell_size = cell_size
    self.header_height = header_height

    self.screen_center = {
        self.width / 2,
        (self.height + self.header_height) / 2
    }

    self.cartesian_center = {0, 0}
    self.cartesian_range = {
        self.width / (self.cell_size * 2),
        (self.height + self.header_height) / (self.cell_size * 2)
    }

    self.font = font
end

function Grid:draw_grid()
    -- Draw vertical lines
    for x = 0, self.width, self.cell_size do
        local color = (x == self.screen_center[1]) and config.COLOR_BLACK or {0.86, 0.86, 0.86}
        love.graphics.setColor(color)
        love.graphics.line(x, self.header_height, x, self.height + self.header_height)
    end

    -- Draw horizontal lines
    for y = self.header_height, self.header_height + self.height, self.cell_size do
        local color = (y == self.screen_center[2]) and config.COLOR_BLACK or {0.86, 0.86, 0.86}
        love.graphics.setColor(color)
        love.graphics.line(0, y, self.width, y)
    end

    -- Draw X-axis labels
    local x_start = -self.cartesian_range[1]
    local x_count = 0
    for x = 0, self.width, self.cell_size do
        local n = x_start + x_count
        if n % 5 == 0 then
            love.graphics.setColor(config.COLOR_DARK_GRAY)
            love.graphics.print(tostring(math.floor(n)), x + 2, self.screen_center[2] + 2)
            love.graphics.setColor(config.COLOR_BLACK)
            love.graphics.line(x, self.screen_center[2] - 5, x, self.screen_center[2] + 5)
        end
        x_count = x_count + 1
    end

    -- Draw Y-axis labels
    local y_start = -self.cartesian_range[2]
    local y_count = 0
    for y = self.height, self.header_height, -self.cell_size do
        local n = y_start + y_count
        if (n % 5 == 0) and (n ~= self.cartesian_range[2]) and (n ~= 0) then
            love.graphics.setColor(config.COLOR_DARK_GRAY)
            love.graphics.print(tostring(math.floor(n)),
                               self.screen_center[1] + 2,
                               y + self.cell_size * 2 + 2)
            love.graphics.setColor(config.COLOR_BLACK)
            love.graphics.line(self.screen_center[1] - 5, y + self.cell_size * 2,
                             self.screen_center[1] + 5, y + self.cell_size * 2)
        end
        y_count = y_count + 1
    end
end

function Grid:get_cartesian_coordinates(mouse_x, mouse_y)
    local grid_x = math.floor((mouse_x / self.cell_size) - self.cartesian_range[1] + 0.5)
    local grid_y = math.floor(((self.height - mouse_y + self.header_height) / self.cell_size) -
                              self.cartesian_range[2] + 0.5)
    return grid_x, grid_y
end

return Grid
```

**Migration notes:**
- Replace `numpy.array` with Lua tables `{x, y}`
- Replace `pygame.draw.line()` with `love.graphics.line()`
- Replace `font.render()` with `love.graphics.print()`
- No direct equivalent to Pygame's `Rect` - implement AABB collision manually

---

## Phase 4: Port Figure Classes (4 hours)

### interface/figures.lua

```lua
-- interface/figures.lua
local class = require 'lib.class'
local config = require 'config'

-- ========== Figure Base Class ==========
local Figure = class('Figure')

function Figure:initialize(pos, text, size)
    self.pos = pos or {0, 0}
    self.size = size or {10, 10}
    self.text = text
    self.selected = false
    self.is_hovered = false

    self.colors = {
        hover = config.COLOR_BUTTON_HOVERED,
        selected = config.COLOR_BUTTON_ACTIVE,
        pasive = config.COLOR_BUTTON_PASIVE
    }
end

function Figure:check_hover(mouse_x, mouse_y)
    -- AABB collision detection
    local in_x = mouse_x >= self.pos[1] and mouse_x <= (self.pos[1] + self.size[1])
    local in_y = mouse_y >= self.pos[2] and mouse_y <= (self.pos[2] + self.size[2])
    self.is_hovered = in_x and in_y
    return self.is_hovered
end

function Figure:move(rel, pos)
    if pos then
        self.pos[1], self.pos[2] = pos[1], pos[2]
    elseif rel then
        self.pos[1] = self.pos[1] + rel[1]
        self.pos[2] = self.pos[2] + rel[2]
    end
end

function Figure:set_state(value)
    self.selected = value
end

function Figure:draw(font)
    local color = self.is_hovered and self.colors.hover or
                  (self.selected and self.colors.selected or self.colors.pasive)

    love.graphics.setColor(color)
    love.graphics.rectangle('fill', self.pos[1], self.pos[2], self.size[1], self.size[2])

    if self.text and font then
        love.graphics.setColor(config.COLOR_BLACK)
        local text_width = font:getWidth(self.text)
        local text_height = font:getHeight()
        love.graphics.print(self.text,
                          self.pos[1] + (self.size[1] - text_width) / 2,
                          self.pos[2] + (self.size[2] - text_height) / 2)
    end
end

function Figure:__tostring()
    return "figure"
end


-- ========== Point Class ==========
local Point = class('Point', Figure)

function Point:initialize(pos, radius)
    Point.super.initialize(self, pos, nil, {radius * 2, radius * 2})
    self.radius = radius or 4
end

function Point:check_hover(mouse_x, mouse_y)
    -- Circle collision detection
    local dx = mouse_x - self.pos[1]
    local dy = mouse_y - self.pos[2]
    local distance = math.sqrt(dx * dx + dy * dy)
    self.is_hovered = distance <= self.radius
    return self.is_hovered
end

function Point:draw()
    local color = self.is_hovered and self.colors.hover or
                  (self.selected and self.colors.selected or self.colors.pasive)

    love.graphics.setColor(color)
    love.graphics.circle('fill', self.pos[1], self.pos[2], self.radius)
end

function Point:__tostring()
    return "point"
end


-- ========== Line Class ==========
local Line = class('Line', Figure)

function Line:initialize(pos)
    Line.super.initialize(self, pos, nil, {0, 0})
    self.range = 1000
    self.width = 2
    self.proximity_range = 4

    self.slope = 0
    self.b = nil
    self.coords = {{0, 0}, {0, 0}}

    self.setting_slope = true
    self.initialized = false

    self:set_b()
    self:set_coords()
end

function Line:set_slope(end_x, end_y)
    if end_x == self.pos[1] then
        self.slope = math.huge  -- Infinity
    else
        self.slope = (end_y - self.pos[2]) / (end_x - self.pos[1])
    end
end

function Line:set_b()
    if self.slope == math.huge then
        self.b = self.pos[1]  -- Vertical line: x = constant
    else
        self.b = self.pos[2] - (self.slope * self.pos[1])
    end
end

function Line:set_coords()
    local s_x = self.pos[1] - self.range
    local s_y = (s_x * self.slope) + self.b
    local e_x = self.pos[1] + self.range
    local e_y = (e_x * self.slope) + self.b
    self.coords = {{s_x, s_y}, {e_x, e_y}}
end

function Line:move(rel, pos)
    if self.setting_slope then
        self:set_slope(pos[1], pos[2])
    else
        if pos then
            self.pos[1], self.pos[2] = pos[1], pos[2]
        elseif rel then
            self.pos[1] = self.pos[1] + rel[1]
            self.pos[2] = self.pos[2] + rel[2]
        end
    end

    self:set_b()
    self:set_coords()
end

function Line:distance_to_line(pos_x, pos_y)
    if self.slope == math.huge then
        return math.abs(pos_x - self.b)  -- Distance to vertical line
    else
        return math.abs((-1 * pos_y) + (self.slope * pos_x) + self.b) /
               math.sqrt(1 + (self.slope * self.slope))
    end
end

function Line:check_hover(mouse_x, mouse_y)
    self.initialized = self.selected or self.initialized

    if self.slope then
        local dist = self:distance_to_line(mouse_x, mouse_y)
        if dist < self.proximity_range then
            self.is_hovered = true

            -- Check if hovering over origin point
            local dx = mouse_x - self.pos[1]
            local dy = mouse_y - self.pos[2]
            local dist_to_origin = math.sqrt(dx * dx + dy * dy)

            if dist_to_origin < self.proximity_range and self.initialized then
                self.setting_slope = false
            else
                self.setting_slope = true
            end
        else
            self.is_hovered = false
        end
    end

    return self.is_hovered
end

function Line:draw()
    local color = self.is_hovered and self.colors.hover or
                  (self.selected and self.colors.selected or self.colors.pasive)

    love.graphics.setColor(color)
    love.graphics.setLineWidth(self.width)
    love.graphics.line(self.coords[1][1], self.coords[1][2],
                      self.coords[2][1], self.coords[2][2])

    -- Draw origin indicator when hovered
    if self.is_hovered then
        if self.setting_slope then
            love.graphics.setColor(color)
        else
            love.graphics.setColor(config.COLOR_CYAN)
        end
        love.graphics.circle('fill', self.pos[1], self.pos[2], self.proximity_range)
    end

    love.graphics.setLineWidth(1)  -- Reset
end

function Line:__tostring()
    return "line"
end

return {
    Figure = Figure,
    Point = Point,
    Line = Line
}
```

---

## Phase 5: Port User Input (2 hours)

### interface/user.lua

```lua
-- interface/user.lua
local class = require 'lib.class'

local User = class('User')

function User:initialize()
    self.mouse_x = 0
    self.mouse_y = 0
    self.mouse_button_pressed = false
    self.mouse_motion = false
    self.mouse_dx = 0  -- Delta movement
    self.mouse_dy = 0
    self.prev_mouse_x = 0
    self.prev_mouse_y = 0
end

function User:update()
    -- Get current mouse position
    local mx, my = love.mouse.getPosition()

    -- Calculate delta
    self.mouse_dx = mx - self.prev_mouse_x
    self.mouse_dy = my - self.prev_mouse_y

    -- Check if mouse moved
    self.mouse_motion = (self.mouse_dx ~= 0 or self.mouse_dy ~= 0)

    -- Update position
    self.mouse_x = mx
    self.mouse_y = my
    self.prev_mouse_x = mx
    self.prev_mouse_y = my

    -- Check button state
    self.mouse_button_pressed = love.mouse.isDown(1)  -- Left button
end

function User:get_pos()
    return self.mouse_x, self.mouse_y
end

function User:get_rel()
    return self.mouse_dx, self.mouse_dy
end

return User
```

---

## Phase 6: Port Header & Buttons (3 hours)

### interface/header.lua

```lua
-- interface/header.lua
local class = require 'lib.class'
local config = require 'config'

-- ========== Button Class ==========
local Button = class('Button')

function Button:initialize(text, pos, size)
    self.text = text
    self.pos = pos or {0, 0}
    self.size = size or {config.HEADER_SIZE * 2.6, config.HEADER_SIZE - 4}
    self.selected = false
    self.is_hovered = false
end

function Button:check_hover(mouse_x, mouse_y)
    local in_x = mouse_x >= self.pos[1] and mouse_x <= (self.pos[1] + self.size[1])
    local in_y = mouse_y >= self.pos[2] and mouse_y <= (self.pos[2] + self.size[2])
    self.is_hovered = in_x and in_y
end

function Button:set_state(value)
    self.selected = value
end

function Button:draw(font)
    local color = self.is_hovered and config.COLOR_BUTTON_HOVERED or
                  (self.selected and config.COLOR_BUTTON_ACTIVE or config.COLOR_BUTTON_PASIVE)

    love.graphics.setColor(color)
    love.graphics.rectangle('fill', self.pos[1], self.pos[2], self.size[1], self.size[2])

    love.graphics.setColor(config.COLOR_BLACK)
    local text_width = font:getWidth(self.text)
    local text_height = font:getHeight()
    love.graphics.print(self.text,
                       self.pos[1] + (self.size[1] - text_width) / 2,
                       self.pos[2] + (self.size[2] - text_height) / 2)
end


-- ========== Header Class ==========
local Header = class('Header')

function Header:initialize(height, color, font)
    self.height = height
    self.color = color
    self.font = font

    -- Create buttons
    self.buttons = {
        intro = Button('intro', {300, 2}),
        line = Button('line', {400, 2}),
        point = Button('point', {500, 2})
    }

    self.selected_button = ""

    -- Instruction window state
    self.show_intro = false
    self.intro_text = "Welcome to Playground Cartesiano!\n\nClick buttons to create geometric figures.\nDrag figures to move them.\nFor lines: drag to set slope, click origin to translate."
end

function Header:is_mouse_inside(mouse_y)
    return mouse_y < self.height or self.show_intro
end

function Header:clear_buttons_state()
    for _, button in pairs(self.buttons) do
        button:set_state(false)
    end
    self.selected_button = ""
end

function Header:check_buttons(user)
    local out = ""
    for key, button in pairs(self.buttons) do
        button:check_hover(user.mouse_x, user.mouse_y)

        if button.is_hovered and user.mouse_button_pressed then
            self:clear_buttons_state()

            if key == "intro" then
                self.show_intro = not self.show_intro  -- Toggle
                return out
            end

            button:set_state(true)
            self.selected_button = key
            out = key
        end
    end
    return out
end

function Header:draw(text)
    -- Draw header background
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', 0, 0, config.SCREEN_WIDTH, self.height)

    -- Draw header text
    love.graphics.setColor(config.COLOR_WHITE)
    love.graphics.print(text, 10, (self.height - self.font:getHeight()) / 2)

    -- Draw buttons
    for _, button in pairs(self.buttons) do
        button:draw(self.font)
    end

    -- Draw instruction window if active
    if self.show_intro then
        local win_x, win_y = 200, 100
        local win_w, win_h = 400, 300

        -- Background
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle('fill', win_x, win_y, win_w, win_h)

        -- Border
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.rectangle('line', win_x, win_y, win_w, win_h)

        -- Title bar
        love.graphics.setColor(config.COLOR_HEADER)
        love.graphics.rectangle('fill', win_x, win_y, win_w, 30)
        love.graphics.setColor(config.COLOR_WHITE)
        love.graphics.print("Instructions", win_x + 10, win_y + 7)

        -- Content
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.printf(self.intro_text, win_x + 10, win_y + 40, win_w - 20)
    end
end

return {
    Button = Button,
    Header = Header
}
```

---

## Phase 7: Port CartesianPlane (2 hours)

### interface/cartesian_plane.lua

```lua
-- interface/cartesian_plane.lua
local class = require 'lib.class'
local Grid = require 'interface.grid'
local figures = require 'interface.figures'

local CartesianPlane = class('CartesianPlane', Grid)

function CartesianPlane:initialize(width, height, header_height, font)
    CartesianPlane.super.initialize(self, width, height - header_height, 20, header_height, font)

    self.figures = {}
    self.selected_figure = nil
    self.hovered_figure = nil
end

function CartesianPlane:draw(mouse_x, mouse_y)
    self:draw_grid()

    -- Draw all figures
    for _, figure in ipairs(self.figures) do
        figure:draw(self.font)
    end

    -- Draw mouse coordinates
    if mouse_x and mouse_y then
        local grid_x, grid_y = self:get_cartesian_coordinates(mouse_x, mouse_y)
        local text = string.format("    %d, %d", grid_x, grid_y)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(text, mouse_x, mouse_y)
    end
end

function CartesianPlane:move_figure(pos_x, pos_y)
    if self.selected_figure then
        self.selected_figure:move(nil, {pos_x, pos_y})
    end
end

function CartesianPlane:clear_figures_state()
    for _, figure in ipairs(self.figures) do
        figure:set_state(false)
    end
end

function CartesianPlane:new_figure(user, type)
    if type == "figure" then
        table.insert(self.figures, figures.Figure({user.mouse_x, user.mouse_y}, nil, {10, 10}))
    elseif type == "point" then
        table.insert(self.figures, figures.Point({user.mouse_x, user.mouse_y}, 4))
    elseif type == "line" then
        table.insert(self.figures, figures.Line({user.mouse_x, user.mouse_y}))
    end
end

function CartesianPlane:check_movement(moving, user)
    if not self.selected_figure then
        return false
    end

    if user.mouse_button_pressed then
        if self.selected_figure:check_hover(user.mouse_x, user.mouse_y) and user.mouse_motion then
            moving = true
        end
    else
        moving = false
    end

    return moving
end

function CartesianPlane:check_figures(user)
    -- Clear selected if mouse released
    if not user.mouse_button_pressed then
        self.selected_figure = nil
    end

    if user.mouse_button_pressed then
        self:clear_figures_state()
    end

    -- Check hover and selection
    self.hovered_figure = nil
    for _, figure in ipairs(self.figures) do
        if figure:check_hover(user.mouse_x, user.mouse_y) then
            self.hovered_figure = figure
            if user.mouse_button_pressed then
                figure:set_state(true)
                self.selected_figure = figure
            end
        end
    end
end

function CartesianPlane:run(user)
    self:check_figures(user)
    return user.mouse_x, user.mouse_y
end

function CartesianPlane:get_hovered_text()
    if self.hovered_figure then
        local grid_x, grid_y = self:get_cartesian_coordinates(
            self.hovered_figure.pos[1],
            self.hovered_figure.pos[2]
        )
        return string.format("%s in (%d, %d)", tostring(self.hovered_figure), grid_x, grid_y)
    end
    return ""
end

return CartesianPlane
```

---

## Phase 8: Create Main Application (2 hours)

### main.lua

```lua
-- main.lua
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local header_module = require 'interface.header'
local User = require 'interface.user'

-- Global state
local app = {}

function love.load()
    -- Set window title (already done in conf.lua, but can override)
    love.window.setTitle("Playground Cartesiano")

    -- Create font
    app.font = love.graphics.newFont(config.FONT_SIZE)

    -- Initialize components
    app.user = User()
    app.header = header_module.Header(config.HEADER_SIZE, config.COLOR_HEADER, app.font)
    app.grid = CartesianPlane(
        config.SCREEN_WIDTH,
        config.SCREEN_HEIGHT,
        config.HEADER_SIZE,
        app.font
    )

    app.running = true
    app.moving = false
end

function love.update(dt)
    -- Update user input
    app.user:update()

    -- Check movement
    app.moving = app.grid:check_movement(app.moving, app.user)
    if app.moving then
        app.grid:move_figure(app.user.mouse_x, app.user.mouse_y)
    end

    -- Check header buttons
    app.header:check_buttons(app.user)

    -- Handle figure creation or grid interaction
    if not app.header:is_mouse_inside(app.user.mouse_y) then
        if app.header.selected_button ~= "" and app.user.mouse_button_pressed then
            app.grid:new_figure(app.user, app.header.selected_button)
            app.header:clear_buttons_state()
        else
            app.grid:run(app.user)
        end
    end
end

function love.draw()
    -- Clear screen
    love.graphics.clear(config.COLOR_BACKGROUND)

    -- Get header text
    local header_text
    if app.header:is_mouse_inside(app.user.mouse_y) then
        header_text = app.header.selected_button
    else
        header_text = app.grid:get_hovered_text()
    end

    -- Draw grid and figures
    local mouse_x, mouse_y = nil, nil
    if not app.header:is_mouse_inside(app.user.mouse_y) then
        mouse_x, mouse_y = app.user:get_pos()
    end
    app.grid:draw(mouse_x, mouse_y)

    -- Draw header
    app.header:draw(header_text)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
```

---

## Phase 9: Testing & Refinement (3 hours)

### Test Cases

1. **Grid rendering**
   - Verify coordinate labels appear correctly
   - Check axis lines are bold

2. **Figure creation**
   - Click "point" button → click on grid → point appears
   - Click "line" button → click on grid → line appears

3. **Figure interaction**
   - Hover over figure → color changes to red
   - Click and drag → figure moves with mouse
   - Release → figure stays in place

4. **Line special behavior**
   - Create line → drag to set slope
   - Click line → small circle appears at origin
   - Drag origin circle → translate entire line

5. **Header buttons**
   - Hover → color changes
   - Click → button stays highlighted
   - Click "intro" → instruction window appears

### Common Issues & Fixes

**Issue**: Colors look wrong
**Fix**: Ensure colors in config.lua are 0-1, not 0-255

**Issue**: Mouse coordinates feel off
**Fix**: Check header_height offset in collision detection

**Issue**: Figures don't respond to clicks
**Fix**: Verify z-order (draw order = interaction order in LOVE)

**Issue**: Line hover detection inaccurate
**Fix**: Increase `proximity_range` in Line class

---

## Phase 10: Polish & Optimization (2 hours)

### Performance Tips

1. **Avoid recreating fonts**: Create once in `love.load()`
2. **Batch draw calls**: Use `love.graphics.setCanvas()` for grid if static
3. **Profile with**:
   ```lua
   local start = love.timer.getTime()
   -- code
   print("Time:", love.timer.getTime() - start)
   ```

### Optional Enhancements

1. **Anti-aliased lines**: Already default in LOVE
2. **Smooth colors**: Use `love.graphics.setBlendMode('alpha')`
3. **Keyboard shortcuts**:
   ```lua
   function love.keypressed(key)
       if key == "p" then
           -- Quick point mode
       end
   end
   ```

---

## Running the Application

```bash
cd CartesianPlayground
love .
```

Or drag the folder onto the LOVE executable.

---

## Distribution

### Create standalone executable:
1. **Windows**: `love.exe` + zip your files → rename to `.love`
2. **macOS**: Copy into LOVE.app bundle
3. **Linux**: `love CartesianPlayground.love`

See: https://love2d.org/wiki/Game_Distribution

---

## Remaining Work

- Add undo/redo (not in original)
- Serialize figures to JSON for save/load (not in original)
- Implement "problem class" system from TODOs
- Add colinearity detection

---

## Troubleshooting

**"module not found" errors**: Check `require` paths match file structure

**Nothing draws**: Verify you're calling `:draw()` methods in `love.draw()`

**Input doesn't work**: Ensure `user:update()` is called in `love.update()`

**Buttons not clickable**: Check if `header:check_buttons()` is called BEFORE grid interaction logic

---

## Resources

- LOVE2D Wiki: https://love2d.org/wiki/
- Lua 5.1 Reference: https://www.lua.org/manual/5.1/
- Middleclass: https://github.com/kikito/middleclass
- LOVE Forums: https://love2d.org/forums/

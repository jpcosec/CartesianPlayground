# Godot Migration Plan

## Overview
This document provides a comprehensive plan to migrate CartesianPlayground from Pygame to Godot 4.x. The migration involves a paradigm shift from immediate-mode rendering to scene-based architecture.

**Estimated Time**: 5-7 days
**Difficulty**: Medium-Hard (7/10)
**Language**: Python → GDScript

---

## Prerequisites

1. Install Godot 4.2+ from https://godotengine.org/
2. Familiarize yourself with:
   - Node system and scene tree
   - GDScript basics
   - Signals (event system)
   - Control nodes for UI

**Recommended tutorials**:
- Official Godot docs: https://docs.godotengine.org/
- "Your First 2D Game" tutorial
- Understanding the scene system

---

## Phase 1: Learning & Setup (1 day)

### Day 1: Godot Fundamentals

**Morning (4 hours)**: Complete tutorials
1. Create a simple project
2. Understand Node2D vs Control nodes
3. Learn signal system
4. Practice GDScript syntax

**Afternoon (4 hours)**: Architecture planning
1. Map Pygame classes to Godot nodes
2. Design scene hierarchy
3. Plan coordinate system changes

### Project Structure
```
CartesianPlayground/
├── project.godot              # Project settings
├── scenes/
│   ├── main.tscn             # Main scene (App)
│   ├── cartesian_plane.tscn  # Grid + figures container
│   ├── header.tscn           # Header UI
│   ├── figures/
│   │   ├── figure_rect.tscn  # Rectangle figure
│   │   ├── figure_point.tscn # Circle figure
│   │   └── figure_line.tscn  # Line figure
│   └── ui/
│       ├── button.tscn       # Custom button
│       └── intro_window.tscn # Instruction popup
├── scripts/
│   ├── main.gd
│   ├── cartesian_plane.gd
│   ├── grid.gd
│   ├── header.gd
│   ├── figure_base.gd
│   ├── figure_point.gd
│   └── figure_line.gd
└── resources/
    └── config.gd             # Global configuration
```

---

## Phase 2: Configuration & Globals (2 hours)

### Project Settings (project.godot)

Set display size and window properties:
1. Project → Project Settings → Display → Window
2. Width: 800, Height: 600
3. Stretch Mode: canvas_items

### resources/config.gd (AutoLoad singleton)

```gdscript
# config.gd
extends Node

# Colors
const COLOR_WHITE = Color(1, 1, 1)
const COLOR_BLACK = Color(0, 0, 0)
const COLOR_DARK_GRAY = Color(0.27, 0.27, 0.27)
const COLOR_LIGHT_GRAY = Color(0.78, 0.78, 0.78)
const COLOR_BLUE = Color(0, 0, 1)
const COLOR_RED = Color(1, 0, 0)
const COLOR_CYAN = Color(0, 1, 1)

const COLOR_BACKGROUND = Color(1, 1, 1)
const COLOR_HEADER = Color(0.08, 0.08, 0.08)

# UI Colors
const COLOR_BUTTON_HOVERED = COLOR_RED
const COLOR_BUTTON_ACTIVE = COLOR_DARK_GRAY
const COLOR_BUTTON_PASIVE = COLOR_LIGHT_GRAY

# Dimensions
const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 600
const HEADER_SIZE = 40
const FONT_SIZE = 25
const CELL_SIZE = 20

# Helper function: Convert RGB (0-255) to Godot Color (0-1)
static func rgb_to_color(r: int, g: int, b: int) -> Color:
    return Color(r / 255.0, g / 255.0, b / 255.0)
```

**Setup AutoLoad**:
1. Project → Project Settings → Globals → AutoLoad
2. Add `config.gd` with name "Config"

---

## Phase 3: Grid System (4 hours)

### Scene: cartesian_plane.tscn

Node hierarchy:
```
CartesianPlane (Node2D)
├── Grid (Node2D)
│   └── Script: grid.gd
└── Figures (Node2D)
    └── (dynamically added Area2D figures)
```

### scripts/grid.gd

```gdscript
# grid.gd
extends Node2D

var width: int
var height: int
var cell_size: int = Config.CELL_SIZE
var header_height: int = Config.HEADER_SIZE

var screen_center: Vector2
var cartesian_center: Vector2 = Vector2.ZERO
var cartesian_range: Vector2

func _init():
    width = Config.SCREEN_WIDTH
    height = Config.SCREEN_HEIGHT - header_height

    screen_center = Vector2(width / 2, (height + header_height) / 2)
    cartesian_range = Vector2(
        width / (cell_size * 2),
        (height + header_height) / (cell_size * 2)
    )

func _draw():
    draw_grid()

func draw_grid():
    # Draw vertical lines
    for x in range(0, width + 1, cell_size):
        var color = Config.COLOR_BLACK if x == screen_center.x else Color(0.86, 0.86, 0.86)
        draw_line(
            Vector2(x, header_height),
            Vector2(x, height + header_height),
            color,
            1
        )

    # Draw horizontal lines
    for y in range(header_height, header_height + height + 1, cell_size):
        var color = Config.COLOR_BLACK if y == screen_center.y else Color(0.86, 0.86, 0.86)
        draw_line(
            Vector2(0, y),
            Vector2(width, y),
            color,
            1
        )

    # Draw X-axis labels
    var x_start = -cartesian_range.x
    var x_count = 0
    for x in range(0, width + 1, cell_size):
        var n = int(x_start + x_count)
        if n % 5 == 0:
            draw_string(
                ThemeDB.fallback_font,
                Vector2(x + 2, screen_center.y + 20),
                str(n),
                HORIZONTAL_ALIGNMENT_LEFT,
                -1,
                Config.FONT_SIZE,
                Config.COLOR_DARK_GRAY
            )
            draw_line(
                Vector2(x, screen_center.y - 5),
                Vector2(x, screen_center.y + 5),
                Config.COLOR_BLACK,
                2
            )
        x_count += 1

    # Draw Y-axis labels
    var y_start = -cartesian_range.y
    var y_count = 0
    for y in range(int(height), header_height, -cell_size):
        var n = int(y_start + y_count)
        if (n % 5 == 0) and (n != cartesian_range.y) and (n != 0):
            draw_string(
                ThemeDB.fallback_font,
                Vector2(screen_center.x + 10, y + cell_size * 2),
                str(n),
                HORIZONTAL_ALIGNMENT_LEFT,
                -1,
                Config.FONT_SIZE,
                Config.COLOR_DARK_GRAY
            )
            draw_line(
                Vector2(screen_center.x - 5, y + cell_size * 2),
                Vector2(screen_center.x + 5, y + cell_size * 2),
                Config.COLOR_BLACK,
                2
            )
        y_count += 1

func get_cartesian_coordinates(screen_pos: Vector2) -> Vector2i:
    var grid_x = round((screen_pos.x / cell_size) - cartesian_range.x)
    var grid_y = round(((height - screen_pos.y + header_height) / cell_size) - cartesian_range.y)
    return Vector2i(int(grid_x), int(grid_y))

func get_screen_coordinates(cartesian_pos: Vector2) -> Vector2:
    var screen_x = (cartesian_pos.x + cartesian_range.x) * cell_size
    var screen_y = height + header_height - ((cartesian_pos.y + cartesian_range.y) * cell_size)
    return Vector2(screen_x, screen_y)
```

---

## Phase 4: Figure Base Classes (5 hours)

### scripts/figure_base.gd

```gdscript
# figure_base.gd
extends Area2D
class_name FigureBase

enum State { PASIVE, HOVERED, SELECTED }

var current_state: State = State.PASIVE
var is_dragging: bool = false

signal clicked(figure: FigureBase)
signal hover_changed(is_hovered: bool, figure: FigureBase)

func _ready():
    # Connect mouse signals
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    input_event.connect(_on_input_event)

func _on_mouse_entered():
    if current_state != State.SELECTED:
        current_state = State.HOVERED
        update_visual()
    hover_changed.emit(true, self)

func _on_mouse_exited():
    if current_state != State.SELECTED:
        current_state = State.PASIVE
        update_visual()
    hover_changed.emit(false, self)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            current_state = State.SELECTED
            is_dragging = true
            update_visual()
            clicked.emit(self)

func _input(event: InputEvent):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            is_dragging = false
            if current_state == State.SELECTED:
                current_state = State.HOVERED if get_global_mouse_position().distance_to(global_position) < 20 else State.PASIVE
                update_visual()

func move_to(new_pos: Vector2):
    global_position = new_pos

func set_state(state: State):
    current_state = state
    update_visual()

func get_color() -> Color:
    match current_state:
        State.HOVERED:
            return Config.COLOR_BUTTON_HOVERED
        State.SELECTED:
            return Config.COLOR_BUTTON_ACTIVE
        _:
            return Config.COLOR_BUTTON_PASIVE

func update_visual():
    queue_redraw()  # Override in subclasses

func get_description() -> String:
    return "figure"
```

### Scene: figures/figure_rect.tscn + scripts/figure_rect.gd

**Scene structure:**
```
FigureRect (Area2D)
├── Script: figure_rect.gd
├── CollisionShape2D
│   └── Shape: RectangleShape2D (10x10)
└── (visual drawn in _draw())
```

**Script:**
```gdscript
# figure_rect.gd
extends FigureBase

var size: Vector2 = Vector2(10, 10)

func _ready():
    super._ready()

    # Setup collision shape
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = size
    collision.shape = shape
    add_child(collision)

func _draw():
    var color = get_color()
    draw_rect(Rect2(-size / 2, size), color, true)

func update_visual():
    queue_redraw()

func get_description() -> String:
    return "figure"
```

### Scene: figures/figure_point.tscn + scripts/figure_point.gd

```gdscript
# figure_point.gd
extends FigureBase

var radius: float = 4.0

func _ready():
    super._ready()

    # Setup collision shape
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = radius
    collision.shape = shape
    add_child(collision)

func _draw():
    var color = get_color()
    draw_circle(Vector2.ZERO, radius, color)

func update_visual():
    queue_redraw()

func get_description() -> String:
    return "point"
```

### scripts/figure_line.gd (Complex)

```gdscript
# figure_line.gd
extends FigureBase

var line_range: float = 1000.0
var line_width: float = 2.0
var proximity_range: float = 4.0

var slope: float = 0.0
var b: float = 0.0
var line_coords: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]

var setting_slope: bool = true
var initialized: bool = false

var origin_area: Area2D  # Separate area for origin point interaction

func _ready():
    super._ready()

    # Create origin interaction area
    origin_area = Area2D.new()
    var origin_collision = CollisionShape2D.new()
    var origin_shape = CircleShape2D.new()
    origin_shape.radius = proximity_range
    origin_collision.shape = origin_shape
    origin_area.add_child(origin_collision)
    add_child(origin_area)

    origin_area.mouse_entered.connect(_on_origin_mouse_entered)
    origin_area.mouse_exited.connect(_on_origin_mouse_exited)

    # Setup main collision (line proximity)
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(line_range * 2, proximity_range * 2)
    collision.shape = shape
    add_child(collision)

    _update_line()

func _on_origin_mouse_entered():
    if initialized:
        setting_slope = false
        queue_redraw()

func _on_origin_mouse_exited():
    setting_slope = true
    queue_redraw()

func _process(_delta):
    if is_dragging:
        var mouse_pos = get_global_mouse_position()
        move_to_position(mouse_pos)

func move_to_position(pos: Vector2):
    if setting_slope:
        set_slope(pos)
    else:
        global_position = pos

    _update_line()

func set_slope(end_pos: Vector2):
    var start = global_position
    if is_equal_approx(end_pos.x, start.x):
        slope = INF
    else:
        slope = (end_pos.y - start.y) / (end_pos.x - start.x)

func _update_line():
    if is_inf(slope):
        b = global_position.x
        line_coords = [
            Vector2(0, -line_range),
            Vector2(0, line_range)
        ]
    else:
        b = global_position.y - (slope * global_position.x)
        var start_x = global_position.x - line_range
        var start_y = (start_x * slope) + b
        var end_x = global_position.x + line_range
        var end_y = (end_x * slope) + b

        line_coords = [
            to_local(Vector2(start_x, start_y)),
            to_local(Vector2(end_x, end_y))
        ]

    queue_redraw()

func _draw():
    var color = get_color()

    # Draw line
    draw_line(line_coords[0], line_coords[1], color, line_width, true)

    # Draw origin indicator
    if current_state != State.PASIVE:
        var origin_color = Config.COLOR_CYAN if not setting_slope else color
        draw_circle(Vector2.ZERO, proximity_range, origin_color)

func distance_to_line(pos: Vector2) -> float:
    if is_inf(slope):
        return abs(pos.x - b)
    else:
        return abs((-1 * pos.y) + (slope * pos.x) + b) / sqrt(1 + (slope * slope))

func update_visual():
    queue_redraw()

func get_description() -> String:
    return "line"
```

**Note**: Line collision is complex in Godot. Consider using custom `_input()` handling for proximity detection instead of Area2D.

---

## Phase 5: CartesianPlane Manager (3 hours)

### scripts/cartesian_plane.gd

```gdscript
# cartesian_plane.gd
extends Node2D

@onready var grid = $Grid
@onready var figures_container = $Figures

var selected_figure: FigureBase = null
var hovered_figure: FigureBase = null

# Preload figure scenes
var FigureRect = preload("res://scenes/figures/figure_rect.tscn")
var FigurePoint = preload("res://scenes/figures/figure_point.tscn")
var FigureLine = preload("res://scenes/figures/figure_line.tscn")

signal figure_hovered(text: String)

func _ready():
    pass

func create_figure(type: String, pos: Vector2):
    var figure: FigureBase

    match type:
        "figure":
            figure = FigureRect.instantiate()
        "point":
            figure = FigurePoint.instantiate()
        "line":
            figure = FigureLine.instantiate()
        _:
            return

    figure.global_position = pos
    figure.clicked.connect(_on_figure_clicked)
    figure.hover_changed.connect(_on_figure_hover_changed)
    figures_container.add_child(figure)

func _on_figure_clicked(figure: FigureBase):
    if selected_figure and selected_figure != figure:
        selected_figure.set_state(FigureBase.State.PASIVE)

    selected_figure = figure

func _on_figure_hover_changed(is_hovered: bool, figure: FigureBase):
    if is_hovered:
        hovered_figure = figure
        var cart_pos = grid.get_cartesian_coordinates(figure.global_position)
        figure_hovered.emit("%s in (%d, %d)" % [figure.get_description(), cart_pos.x, cart_pos.y])
    else:
        if hovered_figure == figure:
            hovered_figure = null
            figure_hovered.emit("")

func _process(_delta):
    if selected_figure and selected_figure.is_dragging:
        selected_figure.move_to(get_global_mouse_position())

func clear_selection():
    if selected_figure:
        selected_figure.set_state(FigureBase.State.PASIVE)
        selected_figure = null

func get_hovered_text() -> String:
    if hovered_figure:
        var cart_pos = grid.get_cartesian_coordinates(hovered_figure.global_position)
        return "%s in (%d, %d)" % [hovered_figure.get_description(), cart_pos.x, cart_pos.y]
    return ""
```

---

## Phase 6: Header UI (4 hours)

### Scene: header.tscn

```
Header (Control)
├── Script: header.gd
├── Background (ColorRect)
├── HeaderText (Label)
└── Buttons (HBoxContainer)
    ├── IntroButton (Button)
    ├── LineButton (Button)
    └── PointButton (Button)
```

### scripts/header.gd

```gdscript
# header.gd
extends Control

@onready var header_bg = $Background
@onready var header_text = $HeaderText
@onready var intro_button = $Buttons/IntroButton
@onready var line_button = $Buttons/LineButton
@onready var point_button = $Buttons/PointButton

var selected_button: String = ""
var show_intro: bool = false

signal button_clicked(button_name: String)
signal intro_toggled(visible: bool)

func _ready():
    # Setup background
    header_bg.color = Config.COLOR_HEADER
    header_bg.size = Vector2(Config.SCREEN_WIDTH, Config.HEADER_SIZE)

    # Setup buttons
    intro_button.pressed.connect(_on_intro_pressed)
    line_button.pressed.connect(_on_line_pressed)
    point_button.pressed.connect(_on_point_pressed)

    # Style buttons
    _style_button(intro_button)
    _style_button(line_button)
    _style_button(point_button)

func _style_button(button: Button):
    # Create custom theme for buttons
    var style_normal = StyleBoxFlat.new()
    style_normal.bg_color = Config.COLOR_BUTTON_PASIVE

    var style_hover = StyleBoxFlat.new()
    style_hover.bg_color = Config.COLOR_BUTTON_HOVERED

    var style_pressed = StyleBoxFlat.new()
    style_pressed.bg_color = Config.COLOR_BUTTON_ACTIVE

    button.add_theme_stylebox_override("normal", style_normal)
    button.add_theme_stylebox_override("hover", style_hover)
    button.add_theme_stylebox_override("pressed", style_pressed)

func _on_intro_pressed():
    show_intro = not show_intro
    intro_toggled.emit(show_intro)

func _on_line_pressed():
    clear_selection()
    selected_button = "line"
    line_button.button_pressed = true
    button_clicked.emit("line")

func _on_point_pressed():
    clear_selection()
    selected_button = "point"
    point_button.button_pressed = true
    button_clicked.emit("point")

func clear_selection():
    selected_button = ""
    line_button.button_pressed = false
    point_button.button_pressed = false

func set_header_text(text: String):
    header_text.text = text

func is_mouse_inside() -> bool:
    var mouse_pos = get_viewport().get_mouse_position()
    return mouse_pos.y < Config.HEADER_SIZE or show_intro
```

### Scene: ui/intro_window.tscn

Create a Window node with:
- Title: "Instructions"
- RichTextLabel with introduction text
- Close button

---

## Phase 7: Main Application (3 hours)

### Scene: main.tscn

```
Main (Node2D)
├── Script: main.gd
├── Background (ColorRect)
├── CartesianPlane
├── Header
├── IntroWindow
└── MouseCoordinates (Label)
```

### scripts/main.gd

```gdscript
# main.gd
extends Node2D

@onready var background = $Background
@onready var cartesian_plane = $CartesianPlane
@onready var header = $Header
@onready var intro_window = $IntroWindow
@onready var mouse_coords = $MouseCoordinates

var pending_figure_type: String = ""

func _ready():
    # Setup background
    background.color = Config.COLOR_BACKGROUND
    background.size = Vector2(Config.SCREEN_WIDTH, Config.SCREEN_HEIGHT)

    # Connect signals
    header.button_clicked.connect(_on_header_button_clicked)
    header.intro_toggled.connect(_on_intro_toggled)
    cartesian_plane.figure_hovered.connect(_on_figure_hovered)

    # Hide intro initially
    intro_window.visible = false

func _on_header_button_clicked(button_name: String):
    pending_figure_type = button_name

func _on_intro_toggled(visible: bool):
    intro_window.visible = visible

func _on_figure_hovered(text: String):
    header.set_header_text(text)

func _input(event: InputEvent):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            var mouse_pos = get_viewport().get_mouse_position()

            # Check if click is below header
            if not header.is_mouse_inside():
                if pending_figure_type != "":
                    cartesian_plane.create_figure(pending_figure_type, mouse_pos)
                    header.clear_selection()
                    pending_figure_type = ""

func _process(_delta):
    # Update mouse coordinates display
    var mouse_pos = get_viewport().get_mouse_position()
    if not header.is_mouse_inside():
        var cart_pos = cartesian_plane.grid.get_cartesian_coordinates(mouse_pos)
        mouse_coords.text = "    %d, %d" % [cart_pos.x, cart_pos.y]
        mouse_coords.position = mouse_pos
        mouse_coords.visible = true
    else:
        mouse_coords.visible = false
```

---

## Phase 8: Testing & Debugging (1 day)

### Test Checklist

- [ ] Grid renders with correct coordinates
- [ ] Can create rectangles/points/lines
- [ ] Hover changes color
- [ ] Drag moves figures
- [ ] Line slope adjustment works
- [ ] Line translation works
- [ ] Header buttons respond
- [ ] Intro window opens/closes
- [ ] Mouse coordinates display correctly

### Common Godot Issues

**Issue**: Signals not connecting
**Fix**: Use `@onready` for node references, check node paths

**Issue**: Figures don't respond to mouse
**Fix**: Ensure Area2D has `input_pickable = true`, CollisionShape2D is setup

**Issue**: Coordinate system inverted
**Fix**: Godot's Y-axis points down, adjust conversion functions

**Issue**: Line collision inaccurate
**Fix**: Implement custom `_input()` handling instead of Area2D

---

## Phase 9: Polish & Optimization (4 hours)

### Performance

1. **Use CanvasLayer** for UI (Header) to separate from game world
2. **Disable processing** when not needed: `set_process(false)`
3. **Pool figures** instead of frequent instantiate/free
4. **Use StaticBody2D** for non-interactive grid elements

### Visual Improvements

1. **Anti-aliasing**: Enable in Project Settings → Rendering → Anti-Aliasing
2. **Smooth movement**: Use `lerp()` for dragging
   ```gdscript
   global_position = global_position.lerp(target_pos, 0.3)
   ```
3. **Drop shadows**: Add CanvasLayer with modulate for figures

---

## Phase 10: Advanced Features (Optional)

### Save/Load System

```gdscript
func save_state():
    var save_data = {
        "figures": []
    }

    for figure in figures_container.get_children():
        save_data.figures.append({
            "type": figure.get_description(),
            "position": [figure.global_position.x, figure.global_position.y]
        })

    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_state():
    if not FileAccess.file_exists("user://save.json"):
        return

    var file = FileAccess.open("user://save.json", FileAccess.READ)
    var save_data = JSON.parse_string(file.get_as_text())
    file.close()

    for fig_data in save_data.figures:
        var pos = Vector2(fig_data.position[0], fig_data.position[1])
        create_figure(fig_data.type, pos)
```

### Undo/Redo

Use Godot's built-in `UndoRedo` class:

```gdscript
var undo_redo = UndoRedo.new()

func move_figure_with_undo(figure: FigureBase, old_pos: Vector2, new_pos: Vector2):
    undo_redo.create_action("Move Figure")
    undo_redo.add_do_method(figure, "move_to", new_pos)
    undo_redo.add_undo_method(figure, "move_to", old_pos)
    undo_redo.commit_action()

func _input(event: InputEvent):
    if event.is_action_pressed("ui_undo"):
        undo_redo.undo()
    if event.is_action_pressed("ui_redo"):
        undo_redo.redo()
```

---

## Architecture Comparison: Pygame vs Godot

| Aspect | Pygame (Current) | Godot (Migrated) |
|--------|-----------------|------------------|
| Rendering | Immediate mode (redraw each frame) | Retained mode (scene graph) |
| Figures | Python class instances in list | Area2D nodes in tree |
| Input | Event loop processing | Signals + built-in input |
| Collision | Manual rect.collidepoint() | Area2D with CollisionShape2D |
| UI | pygame_gui external library | Built-in Control nodes |
| Lifecycle | Manual manage/delete | Automatic via scene tree |
| State | Object properties | Node properties + scenes |

---

## Key Differences to Remember

1. **No direct screen access**: Can't pass `screen` around
2. **Signals replace callbacks**: Use `.connect()` for events
3. **Scenes are templates**: Instantiate with `.instantiate()`
4. **Tree order matters**: Children drawn after parents
5. **Input is global**: Use `_input()` or `_unhandled_input()`
6. **Coordinates**: Position is relative to parent by default

---

## Troubleshooting

### "Invalid get index" errors
- Check node is ready: use `@onready` or null checks
- Verify node path in scene tree

### Figures not dragging smoothly
- Move logic to `_process()` instead of signal
- Use delta time for frame-independent movement

### Collision not working
- Ensure Area2D has `input_pickable = true`
- Check collision layer/mask settings
- Verify shape size matches visual

### Performance issues
- Profile with Debugger → Monitors
- Reduce `queue_redraw()` calls
- Use object pooling for many figures

---

## Resources

- **Godot Docs**: https://docs.godotengine.org/en/stable/
- **GDScript Reference**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **Area2D Tutorial**: https://docs.godotengine.org/en/stable/classes/class_area2d.html
- **Signals Guide**: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Community**: https://godotengine.org/community

---

## Next Steps After Migration

1. Implement "Messages" class from TODOs
2. Create "Problem" class system for exercises
3. Add colinearity detection
4. Build level/problem editor
5. Export to web with Godot HTML5

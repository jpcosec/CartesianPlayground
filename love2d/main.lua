-- main.lua
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local header_module = require 'interface.header'
local Sidebar = require 'interface.sidebar'
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
    app.header = header_module.Header(
        config.HEADER_SIZE,
        config.COLOR_HEADER,
        app.font,
        config.SCREEN_WIDTH
    )
    app.sidebar = Sidebar(
        config.SCREEN_WIDTH - config.SIDEBAR_WIDTH,
        config.HEADER_SIZE,
        config.SIDEBAR_WIDTH,
        config.SCREEN_HEIGHT - config.HEADER_SIZE,
        app.font
    )
    app.grid = CartesianPlane(
        config.SCREEN_WIDTH,
        config.SCREEN_HEIGHT,
        config.HEADER_SIZE,
        app.font,
        config.SIDEBAR_WIDTH
    )

    app.running = true
    app.moving = false
end

function love.update(dt)
    -- Update user input
    app.user:update()

    -- Check if instruction window close button was clicked
    app.header:check_window_close(app.user)

    -- Check movement
    app.moving = app.grid:check_movement(app.moving, app.user)
    if app.moving then
        app.grid:move_figure(app.user.mouse_x, app.user.mouse_y)
    end

    -- Check header buttons
    app.header:check_buttons(app.user)

    -- Handle figure creation or grid interaction
    -- Check if mouse is in sidebar
    local in_sidebar = app.user.mouse_x >= (config.SCREEN_WIDTH - config.SIDEBAR_WIDTH) and
                       app.user.mouse_y >= config.HEADER_SIZE

    if not app.header:is_mouse_inside(app.user.mouse_y) and not in_sidebar then
        if app.header.selected_button ~= "" and app.user.mouse_just_pressed then
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

    -- Draw sidebar
    app.sidebar:draw(app.grid.figures, app.grid)

    -- Draw header (this should be drawn last so it appears on top)
    app.header:draw(header_text)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

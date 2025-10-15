-- main.lua
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local header_module = require 'interface.header'
local Sidebar = require 'interface.sidebar'
local User = require 'interface.user'
local ProblemMenu = require 'activities.problem_menu'
local ProblemSolver = require 'activities.problem_solver'

-- Global state
local app = {}
app.mode = "playground"  -- "playground", "problem_menu", or "problem_solving"

function love.load()
    -- Set window title (already done in conf.lua, but can override)
    love.window.setTitle("Playground Cartesiano")

    -- Create font
    app.font = love.graphics.newFont(config.FONT_SIZE)

    -- Get current window dimensions
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    -- Initialize components
    app.user = User()
    app.header = header_module.Header(
        config.HEADER_SIZE,
        config.COLOR_HEADER,
        app.font,
        screen_width
    )
    app.sidebar = Sidebar(
        screen_width - config.SIDEBAR_WIDTH,
        config.HEADER_SIZE,
        config.SIDEBAR_WIDTH,
        screen_height - config.HEADER_SIZE,
        app.font
    )
    app.grid = CartesianPlane(
        screen_width,
        screen_height,
        config.HEADER_SIZE,
        app.font,
        config.SIDEBAR_WIDTH
    )

    -- Initialize problem system activities
    app.problem_menu = ProblemMenu(
        screen_width,
        screen_height,
        config.HEADER_SIZE,
        app.font
    )
    app.problem_solver = nil  -- Created when problem is selected

    app.running = true
    app.moving = false
end

function love.update(dt)
    -- Update user input
    app.user:update()

    -- Update header button animations
    app.header:update(dt)

    -- Check if instruction window close button was clicked
    app.header:check_window_close(app.user)

    -- Handle mode switching via header buttons
    local button_clicked = app.header:check_buttons(app.user)

    -- Switching to problems mode
    if button_clicked == "problems" and app.mode ~= "problem_menu" then
        app.mode = "problem_menu"
        app.header:clear_buttons_state()
        return
    end

    -- Switching to playground mode (via line, point, or intro buttons)
    if (button_clicked == "line" or button_clicked == "point" or button_clicked == "intro") and app.mode ~= "playground" then
        app.mode = "playground"
        -- Don't clear button state - let it be used for creating figure
        -- app.header:clear_buttons_state()
        return
    end

    -- Mode-specific updates
    if app.mode == "playground" then
        -- Check movement
        app.moving = app.grid:check_movement(app.moving, app.user)
        if app.moving then
            app.grid:move_figure(app.user.mouse_x, app.user.mouse_y)
        end

        -- Handle figure creation or grid interaction
        local screen_width = love.graphics.getWidth()
        local in_sidebar = app.user.mouse_x >= (screen_width - config.SIDEBAR_WIDTH) and
                           app.user.mouse_y >= config.HEADER_SIZE

        if not app.header:is_mouse_inside(app.user.mouse_y) and not in_sidebar then
            if app.header.selected_button ~= "" and app.user.mouse_just_pressed then
                app.grid:new_figure(app.user, app.header.selected_button)
                app.header:clear_buttons_state()
            else
                app.grid:run(app.user)
            end
        end

    elseif app.mode == "problem_menu" then
        -- Update problem menu
        app.problem_menu:check_hover(app.user.mouse_x, app.user.mouse_y)

        if app.user.mouse_just_pressed then
            local action = app.problem_menu:handle_click(app.user.mouse_x, app.user.mouse_y)
            if action == 'back' then
                app.mode = "playground"
            elseif action == 'start_problem' then
                -- Create problem solver with selected problem
                local screen_width = love.graphics.getWidth()
                local screen_height = love.graphics.getHeight()
                app.problem_solver = ProblemSolver(
                    screen_width,
                    screen_height,
                    config.HEADER_SIZE,
                    app.font,
                    app.problem_menu.selected_problem
                )
                app.mode = "problem_solving"
            end
        end

    elseif app.mode == "problem_solving" then
        -- Update problem solver
        local mouse_x, mouse_y = app.user.mouse_x, app.user.mouse_y
        if app.header:is_mouse_inside(mouse_y) then
            mouse_x, mouse_y = nil, nil
        end

        local ui_hovered = app.problem_solver:check_hover(app.user.mouse_x, app.user.mouse_y)

        -- Handle movement
        app.moving = app.problem_solver.grid:check_movement(app.moving, app.user)
        if app.moving then
            app.problem_solver.grid:move_figure(app.user.mouse_x, app.user.mouse_y)
        end

        if app.user.mouse_just_pressed then
            -- Check feedback close first
            if app.problem_solver:handle_feedback_click(app.user.mouse_x, app.user.mouse_y) then
                -- Feedback was closed, do nothing else
            else
                local action = app.problem_solver:handle_click(app.user.mouse_x, app.user.mouse_y, app.user)
                if action == 'back' then
                    app.mode = "problem_menu"
                    app.problem_solver = nil
                end
            end
        end

        -- Handle grid interaction if not hovering UI
        if mouse_x and mouse_y and not ui_hovered and not app.moving then
            app.problem_solver.grid:run(app.user)
        end
    end
end

function love.draw()
    -- Clear screen
    love.graphics.clear(config.COLOR_BACKGROUND)

    -- Get header text
    local header_text = ""

    -- Mode-specific drawing
    if app.mode == "playground" then
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

    elseif app.mode == "problem_menu" then
        header_text = "Problems"
        app.problem_menu:draw()

    elseif app.mode == "problem_solving" then
        header_text = "Solving Problem"
        local mouse_x, mouse_y = nil, nil
        if not app.header:is_mouse_inside(app.user.mouse_y) then
            mouse_x, mouse_y = app.user:get_pos()
        end
        app.problem_solver:draw(mouse_x, mouse_y)
    end

    -- Draw header (this should be drawn last so it appears on top)
    app.header:draw(header_text)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "backspace" and app.mode == "problem_solving" and app.problem_solver then
        app.problem_solver:handle_backspace()
    end
end

function love.textinput(text)
    if app.mode == "problem_solving" and app.problem_solver then
        app.problem_solver:handle_text_input(text)
    end
end

function love.wheelmoved(x, y)
    if app.mode == "problem_menu" then
        app.problem_menu:handle_scroll(y)
    end
end

function love.resize(w, h)
    -- Recreate UI components with new dimensions
    app.header.screen_width = w

    app.sidebar = Sidebar(
        w - config.SIDEBAR_WIDTH,
        config.HEADER_SIZE,
        config.SIDEBAR_WIDTH,
        h - config.HEADER_SIZE,
        app.font
    )

    app.grid = CartesianPlane(
        w,
        h,
        config.HEADER_SIZE,
        app.font,
        config.SIDEBAR_WIDTH
    )

    app.problem_menu = ProblemMenu(
        w,
        h,
        config.HEADER_SIZE,
        app.font
    )

    -- If currently solving a problem, recreate the solver
    if app.mode == "problem_solving" and app.problem_solver then
        local current_problem = app.problem_solver.problem
        app.problem_solver = ProblemSolver(
            w,
            h,
            config.HEADER_SIZE,
            app.font,
            current_problem
        )
    end
end

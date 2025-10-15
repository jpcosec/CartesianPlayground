-- states/playground.lua
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local Sidebar = require 'interface.sidebar'
local User = require 'interface.user'
local Slab = require 'lib.Slab'

local playground = {}

function playground:enter()
    -- Get current window dimensions
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    -- Initialize components
    self.user = User()
    self.sidebar = Sidebar(
        screen_width - config.SIDEBAR_WIDTH,
        config.HEADER_SIZE,
        config.SIDEBAR_WIDTH,
        screen_height - config.HEADER_SIZE,
        love.graphics.getFont()
    )
    self.grid = CartesianPlane(
        screen_width,
        screen_height,
        config.HEADER_SIZE,
        love.graphics.getFont(),
        config.SIDEBAR_WIDTH
    )

    self.moving = false
    self.selected_button = ""
end

function playground:update(dt)
    -- Update user input
    self.user:update()

    -- Check movement
    self.moving = self.grid:check_movement(self.moving, self.user)
    if self.moving then
        self.grid:move_figure(self.user.mouse_x, self.user.mouse_y)
    end

    -- Handle figure creation or grid interaction
    local screen_width = love.graphics.getWidth()
    local in_sidebar = self.user.mouse_x >= (screen_width - config.SIDEBAR_WIDTH) and
                       self.user.mouse_y >= config.HEADER_SIZE

    if self.user.mouse_y >= config.HEADER_SIZE and not in_sidebar then
        if self.selected_button ~= "" and self.user.mouse_just_pressed then
            self.grid:new_figure(self.user, self.selected_button)
            self.selected_button = ""
        elseif not self.moving then
            self.grid:run(self.user)
        end
    end
end

function playground:draw()
    -- Draw grid and figures
    local mouse_x, mouse_y = nil, nil
    if self.user.mouse_y >= config.HEADER_SIZE then
        mouse_x, mouse_y = self.user:get_pos()
    end
    self.grid:draw(mouse_x, mouse_y)

    -- Draw sidebar
    self.sidebar:draw(self.grid.figures, self.grid)
end

function playground:resize(w, h)
    self.sidebar = Sidebar(
        w - config.SIDEBAR_WIDTH,
        config.HEADER_SIZE,
        config.SIDEBAR_WIDTH,
        h - config.HEADER_SIZE,
        love.graphics.getFont()
    )

    self.grid = CartesianPlane(
        w,
        h,
        config.HEADER_SIZE,
        love.graphics.getFont(),
        config.SIDEBAR_WIDTH
    )
end

return playground

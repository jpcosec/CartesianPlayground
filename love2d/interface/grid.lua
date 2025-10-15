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
        math.floor(self.width / 2),
        math.floor((self.height + self.header_height) / 2)
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

    -- Draw X-axis labels and tick marks
    local x_start = -self.cartesian_range[1]
    local x_count = 0
    for x = 0, self.width, self.cell_size do
        local n = math.floor(x_start + x_count)
        if n % 5 == 0 then
            love.graphics.setColor(config.COLOR_DARK_GRAY)
            love.graphics.print(tostring(n), x + 2, self.screen_center[2] + 2)
            love.graphics.setColor(config.COLOR_BLACK)
            love.graphics.line(x, self.screen_center[2] - 5, x, self.screen_center[2] + 5)
        end
        x_count = x_count + 1
    end

    -- Draw Y-axis labels and tick marks
    local y_start = -self.cartesian_range[2]
    local y_count = 0
    for y = self.height, self.header_height, -self.cell_size do
        local n = math.floor(y_start + y_count)
        if (n % 5 == 0) and (n ~= self.cartesian_range[2]) and (n ~= 0) then
            love.graphics.setColor(config.COLOR_DARK_GRAY)
            love.graphics.print(tostring(n),
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
    local grid_x = (mouse_x / self.cell_size) - self.cartesian_range[1]
    local grid_y = ((self.height - mouse_y + self.header_height) / self.cell_size) - self.cartesian_range[2]
    return math.floor(grid_x + 0.5), math.floor(grid_y + 0.5)
end

function Grid:get_game_coordinates(cartesian_x, cartesian_y)
    local screen_x = ((cartesian_x - self.cartesian_center[1]) * self.cell_size) + self.screen_center[1]
    local screen_y = ((cartesian_y - self.cartesian_center[2]) * self.cell_size) + self.screen_center[2]
    return math.floor(screen_x), math.floor(screen_y)
end

return Grid

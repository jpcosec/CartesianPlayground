-- interface/sidebar.lua
local class = require 'lib.class'
local config = require 'config'

local Sidebar = class('Sidebar')

function Sidebar:initialize(x, y, width, height, font)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.font = font
    self.small_font = love.graphics.newFont(16)

    self.title = "Figures"
    self.padding = 10
end

function Sidebar:draw(figures, grid)
    -- Background
    love.graphics.setColor(config.SIDEBAR_COLOR)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    -- Border
    love.graphics.setColor(config.SIDEBAR_BORDER_COLOR)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setColor(config.COLOR_BLACK)
    love.graphics.setFont(self.font)
    love.graphics.print(self.title, self.x + self.padding, self.y + self.padding)

    -- Draw figure list
    love.graphics.setFont(self.small_font)
    local y_offset = self.y + self.padding + 30
    local line_height = 18

    if #figures == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("No figures yet", self.x + self.padding, y_offset)
    else
        for i, figure in ipairs(figures) do
            local text = self:get_figure_text(figure, i, grid)

            -- Highlight if selected
            if figure.selected then
                love.graphics.setColor(config.COLOR_BUTTON_ACTIVE)
                love.graphics.rectangle('fill',
                    self.x + 5,
                    y_offset - 2,
                    self.width - 10,
                    line_height)
            end

            love.graphics.setColor(config.COLOR_BLACK)
            love.graphics.printf(text,
                self.x + self.padding,
                y_offset,
                self.width - self.padding * 2)

            y_offset = y_offset + line_height

            -- Add equation if it's a line
            if tostring(figure) == "line" then
                local equation = self:get_line_equation(figure)
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.printf(equation,
                    self.x + self.padding + 10,
                    y_offset,
                    self.width - self.padding * 2 - 10)
                y_offset = y_offset + line_height
            end

            -- Stop if we run out of space
            if y_offset > self.y + self.height - 20 then
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.print("...", self.x + self.padding, y_offset)
                break
            end
        end
    end

    -- Reset font
    love.graphics.setFont(self.font)
end

function Sidebar:get_figure_text(figure, index, grid)
    local fig_type = tostring(figure)

    if fig_type == "point" then
        local cart_x, cart_y = grid:get_cartesian_coordinates(figure.pos[1], figure.pos[2])
        return string.format("P%d: (%d, %d)", index, cart_x, cart_y)
    elseif fig_type == "line" then
        return string.format("L%d:", index)
    else
        return string.format("F%d", index)
    end
end

function Sidebar:get_line_equation(line)
    if line.slope == math.huge then
        -- Vertical line
        return string.format("  x = %.1f", line.b)
    elseif math.abs(line.slope) < 0.01 then
        -- Horizontal line (slope near zero)
        return string.format("  y = %.1f", line.b)
    else
        -- Regular line: y = mx + b
        local m = line.slope
        local b = line.b

        if b >= 0 then
            return string.format("  y = %.2fx + %.2f", m, b)
        else
            return string.format("  y = %.2fx - %.2f", m, math.abs(b))
        end
    end
end

return Sidebar

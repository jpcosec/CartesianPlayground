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
    self.pos = {pos[1], pos[2]}  -- Ensure pos is a table
end

function Point:check_hover(mouse_x, mouse_y)
    -- Circle collision detection
    local dx = mouse_x - self.pos[1]
    local dy = mouse_y - self.pos[2]
    local distance = math.sqrt(dx * dx + dy * dy)
    self.is_hovered = distance <= self.radius
    return self.is_hovered
end

function Point:move(rel, pos)
    if pos then
        self.pos[1], self.pos[2] = pos[1], pos[2]
    elseif rel then
        self.pos[1] = self.pos[1] + rel[1]
        self.pos[2] = self.pos[2] + rel[2]
    end
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
    self.pos = {pos[1], pos[2]}  -- Ensure pos is a table
    self.range = 1000
    self.width = 2
    self.proximity_range = 4

    self.slope = 0
    self.b = nil
    self.coords = {{0, 0}, {0, 0}}

    self.setting_slope = true
    self.initialized = false
    self.first_release = false  -- Track if mouse has been released at least once

    self:set_b()
    self:set_coords()
end

function Line:set_slope(end_pos)
    if end_pos[1] == self.pos[1] then
        self.slope = math.huge  -- Infinity in Lua
    else
        self.slope = (end_pos[2] - self.pos[2]) / (end_pos[1] - self.pos[1])
    end
end

function Line:set_b()
    if self.slope == math.huge then
        -- For vertical lines, b represents the x-coordinate
        self.b = self.pos[1]
    else
        self.b = self.pos[2] - (self.slope * self.pos[1])
    end
end

function Line:set_coords()
    if self.slope == math.huge then
        -- Vertical line
        self.coords = {
            {self.pos[1], self.pos[2] - self.range},
            {self.pos[1], self.pos[2] + self.range}
        }
    else
        local s_x = self.pos[1] - self.range
        local s_y = (s_x * self.slope) + self.b
        local e_x = self.pos[1] + self.range
        local e_y = (e_x * self.slope) + self.b
        self.coords = {{s_x, s_y}, {e_x, e_y}}
    end
end

function Line:move(rel, pos)
    if self.setting_slope then
        if pos then
            self:set_slope(pos)
        end
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

function Line:distance_to_line(pos)
    if self.slope == math.huge then
        -- Distance to vertical line
        return math.abs(pos[1] - self.b)
    else
        -- Distance to non-vertical line: |ax + by + c| / sqrt(a^2 + b^2)
        -- For y = mx + b, we have: -mx + y - b = 0, so a=-m, b=1, c=-b
        return math.abs((-1 * pos[2]) + (self.slope * pos[1]) + self.b) /
               math.sqrt(1 + (self.slope * self.slope))
    end
end

function Line:check_hover(mouse_x, mouse_y)
    -- Become initialized after first mouse release
    if self.first_release then
        self.initialized = true
    end

    if self.slope then
        local dist = self:distance_to_line({mouse_x, mouse_y})
        if dist < self.proximity_range then
            self.is_hovered = true

            -- Check if hovering over origin point (only after initialized)
            if self.initialized then
                local dx = mouse_x - self.pos[1]
                local dy = mouse_y - self.pos[2]
                local dist_to_origin = math.sqrt(dx * dx + dy * dy)

                if dist_to_origin < self.proximity_range then
                    self.setting_slope = false
                else
                    self.setting_slope = true
                end
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

    love.graphics.setLineWidth(1)  -- Reset line width
end

function Line:__tostring()
    return "line"
end

return {
    Figure = Figure,
    Point = Point,
    Line = Line
}

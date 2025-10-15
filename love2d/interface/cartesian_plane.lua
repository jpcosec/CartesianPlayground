-- interface/cartesian_plane.lua
local class = require 'lib.class'
local Grid = require 'interface.grid'
local figures = require 'interface.figures'
local config = require 'config'

local CartesianPlane = class('CartesianPlane', Grid)

function CartesianPlane:initialize(width, height, header_height, font, sidebar_width)
    sidebar_width = sidebar_width or 0
    CartesianPlane.super.initialize(self, width - sidebar_width, height - header_height, 20, header_height, font)

    self.figures = {}
    self.selected_figure = nil
    self.hovered_figure = nil
    self.sidebar_width = sidebar_width
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
        love.graphics.setColor(config.COLOR_RED)
        love.graphics.print(text, mouse_x, mouse_y)
    end
end

function CartesianPlane:move_figure(pos_x, pos_y, rel_x, rel_y)
    if self.selected_figure then
        if pos_x and pos_y then
            self.selected_figure:move(nil, {pos_x, pos_y})
        elseif rel_x and rel_y then
            self.selected_figure:move({rel_x, rel_y}, nil)
        end
    end
end

function CartesianPlane:clear_figures_state()
    for _, figure in ipairs(self.figures) do
        figure:set_state(false)
    end
end

function CartesianPlane:new_figure(user, type)
    local pos = {user.mouse_x, user.mouse_y}
    local new_fig = nil

    if type == "figure" then
        new_fig = figures.Figure(pos, nil, {10, 10})
        table.insert(self.figures, new_fig)
    elseif type == "point" then
        new_fig = figures.Point(pos, 4)
        table.insert(self.figures, new_fig)
    elseif type == "line" then
        new_fig = figures.Line(pos)
        table.insert(self.figures, new_fig)
    end

    -- Automatically select the newly created figure
    if new_fig then
        self:clear_figures_state()
        new_fig:set_state(true)
        self.selected_figure = new_fig
    end
end

function CartesianPlane:check_movement(moving, user)
    if not self.selected_figure then
        return false
    end

    if user.mouse_button_pressed then
        -- Once a figure is selected, you can drag it even if mouse moves away from it
        if user.mouse_motion then
            moving = true
        end
    else
        moving = false
    end

    return moving
end

function CartesianPlane:check_figures(user)
    -- Clear selected if mouse released
    if self.selected_figure and not user.mouse_button_pressed then
        -- Mark that mouse was released (for Line first_release tracking)
        if self.selected_figure.first_release ~= nil then
            self.selected_figure.first_release = true
        end
        self.selected_figure = nil
    end

    -- Clear all states on new click
    if user.mouse_just_pressed then
        self:clear_figures_state()
    end

    -- Check hover and selection
    self.hovered_figure = nil
    for _, figure in ipairs(self.figures) do
        if figure:check_hover(user.mouse_x, user.mouse_y) then
            self.hovered_figure = figure
            if user.mouse_just_pressed then
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

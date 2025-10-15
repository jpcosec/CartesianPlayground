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

    -- Animation properties
    self.hover_scale = 1.0
    self.target_scale = 1.0
    self.hover_opacity = 1.0
    self.corner_radius = 8
end

function Button:check_hover(mouse_x, mouse_y)
    local in_x = mouse_x >= self.pos[1] and mouse_x <= (self.pos[1] + self.size[1])
    local in_y = mouse_y >= self.pos[2] and mouse_y <= (self.pos[2] + self.size[2])
    local was_hovered = self.is_hovered
    self.is_hovered = in_x and in_y

    -- Update target scale based on hover state
    if self.is_hovered and not was_hovered then
        self.target_scale = 1.05
    elseif not self.is_hovered and was_hovered then
        self.target_scale = 1.0
    end
end

function Button:update(dt)
    -- Smooth scale animation
    local lerp_speed = 10
    self.hover_scale = self.hover_scale + (self.target_scale - self.hover_scale) * lerp_speed * dt

    -- Keep scale in reasonable bounds
    self.hover_scale = math.max(1.0, math.min(1.1, self.hover_scale))
end

function Button:set_state(value)
    self.selected = value
end

-- Helper function to draw rounded rectangle
function Button:draw_rounded_rect(mode, x, y, w, h, radius)
    local segments = 10

    -- Draw four corner arcs
    love.graphics.arc(mode, x + radius, y + radius, radius, math.pi, 3 * math.pi / 2, segments)
    love.graphics.arc(mode, x + w - radius, y + radius, radius, 3 * math.pi / 2, 2 * math.pi, segments)
    love.graphics.arc(mode, x + w - radius, y + h - radius, radius, 0, math.pi / 2, segments)
    love.graphics.arc(mode, x + radius, y + h - radius, radius, math.pi / 2, math.pi, segments)

    -- Draw rectangles to fill the middle
    love.graphics.rectangle(mode, x + radius, y, w - 2 * radius, h)
    love.graphics.rectangle(mode, x, y + radius, w, h - 2 * radius)
end

function Button:draw(font)
    -- Calculate animated position and size
    local scale = self.hover_scale
    local scaled_w = self.size[1] * scale
    local scaled_h = self.size[2] * scale
    local scaled_x = self.pos[1] - (scaled_w - self.size[1]) / 2
    local scaled_y = self.pos[2] - (scaled_h - self.size[2]) / 2

    -- Select color based on state
    local color = self.is_hovered and config.COLOR_BUTTON_HOVERED or
                  (self.selected and config.COLOR_BUTTON_ACTIVE or config.COLOR_BUTTON_PASIVE)

    -- Draw button background with rounded corners
    love.graphics.setColor(color)
    self:draw_rounded_rect('fill', scaled_x, scaled_y, scaled_w, scaled_h, self.corner_radius)

    -- Draw subtle border
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.setLineWidth(1)
    self:draw_rounded_rect('line', scaled_x, scaled_y, scaled_w, scaled_h, self.corner_radius)

    -- Draw text
    love.graphics.setColor(config.COLOR_BLACK)
    local text_width = font:getWidth(self.text)
    local text_height = font:getHeight()
    love.graphics.print(self.text,
                       scaled_x + (scaled_w - text_width) / 2,
                       scaled_y + (scaled_h - text_height) / 2)
end


-- ========== Header Class ==========
local Header = class('Header')

function Header:initialize(height, color, font, screen_width)
    self.height = height
    self.color = color
    self.font = font
    self.screen_width = screen_width

    -- Create buttons
    self.buttons = {
        intro = Button('intro', {300, 2}),
        line = Button('line', {400, 2}),
        point = Button('point', {500, 2}),
        problems = Button('problems', {600, 2})
    }

    self.selected_button = ""

    -- Instruction window state
    self.show_intro = false
    self.intro_text = [[Welcome to Playground Cartesiano!

Click buttons to create geometric figures:
- Point: Creates a draggable point
- Line: Creates a line (drag to set slope,
  click origin to translate)

Drag figures to move them around.
Click away to deselect.]]

    -- Window dimensions
    self.window_x = 200
    self.window_y = 100
    self.window_width = 400
    self.window_height = 300
    self.window_padding = 10
end

function Header:is_mouse_inside(mouse_y)
    return mouse_y < self.height or self.show_intro
end

function Header:update(dt)
    -- Update button animations
    for _, button in pairs(self.buttons) do
        button:update(dt)
    end
end

function Header:clear_buttons_state()
    for _, button in pairs(self.buttons) do
        button:set_state(false)
    end
    self.selected_button = ""
end

function Header:check_buttons(user)
    local out = ""

    -- Only process button clicks if mouse was just pressed
    if not user.mouse_just_pressed then
        -- Still update hover states
        for _, button in pairs(self.buttons) do
            button:check_hover(user.mouse_x, user.mouse_y)
        end
        return out
    end

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
    love.graphics.rectangle('fill', 0, 0, self.screen_width, self.height)

    -- Draw header text
    love.graphics.setColor(config.COLOR_WHITE)
    love.graphics.print(text, 10, (self.height - self.font:getHeight()) / 2)

    -- Draw buttons
    for _, button in pairs(self.buttons) do
        button:draw(self.font)
    end

    -- Draw instruction window if active
    if self.show_intro then
        local wx, wy = self.window_x, self.window_y
        local ww, wh = self.window_width, self.window_height
        local pad = self.window_padding

        -- Background
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle('fill', wx, wy, ww, wh)

        -- Border
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', wx, wy, ww, wh)
        love.graphics.setLineWidth(1)

        -- Title bar
        love.graphics.setColor(config.COLOR_HEADER)
        love.graphics.rectangle('fill', wx, wy, ww, 30)
        love.graphics.setColor(config.COLOR_WHITE)
        love.graphics.print("Instructions", wx + 10, wy + 7)

        -- Content (word-wrapped text)
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.printf(self.intro_text, wx + pad, wy + 40, ww - (pad * 2))

        -- Close button (X in top-right corner)
        local close_x, close_y = wx + ww - 25, wy + 5
        local close_size = 20
        love.graphics.setColor(config.COLOR_WHITE)
        love.graphics.rectangle('fill', close_x, close_y, close_size, close_size)
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.rectangle('line', close_x, close_y, close_size, close_size)
        love.graphics.line(close_x + 5, close_y + 5, close_x + 15, close_y + 15)
        love.graphics.line(close_x + 15, close_y + 5, close_x + 5, close_y + 15)
    end
end

function Header:check_window_close(user)
    if not self.show_intro then
        return
    end

    if user.mouse_just_pressed then
        -- Check if clicked on close button
        local close_x = self.window_x + self.window_width - 25
        local close_y = self.window_y + 5
        local close_size = 20

        if user.mouse_x >= close_x and user.mouse_x <= close_x + close_size and
           user.mouse_y >= close_y and user.mouse_y <= close_y + close_size then
            self.show_intro = false
        end
    end
end

return {
    Button = Button,
    Header = Header
}

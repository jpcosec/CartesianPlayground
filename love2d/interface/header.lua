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

function Header:initialize(height, color, font, screen_width)
    self.height = height
    self.color = color
    self.font = font
    self.screen_width = screen_width

    -- Create buttons
    self.buttons = {
        intro = Button('intro', {300, 2}),
        line = Button('line', {400, 2}),
        point = Button('point', {500, 2})
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

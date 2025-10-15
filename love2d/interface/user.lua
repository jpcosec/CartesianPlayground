-- interface/user.lua
local class = require 'lib.class'

local User = class('User')

function User:initialize()
    self.mouse_x = 0
    self.mouse_y = 0
    self.mouse_button_pressed = false
    self.mouse_motion = false
    self.mouse_dx = 0  -- Delta movement
    self.mouse_dy = 0
    self.prev_mouse_x = 0
    self.prev_mouse_y = 0

    -- Track if we just pressed (for detecting new clicks)
    self.mouse_just_pressed = false
end

function User:update()
    -- Get current mouse position
    local mx, my = love.mouse.getPosition()

    -- Calculate delta
    self.mouse_dx = mx - self.prev_mouse_x
    self.mouse_dy = my - self.prev_mouse_y

    -- Check if mouse moved
    self.mouse_motion = (self.mouse_dx ~= 0 or self.mouse_dy ~= 0)

    -- Update position
    self.mouse_x = mx
    self.mouse_y = my

    -- Update button state
    local currently_pressed = love.mouse.isDown(1)  -- Left button
    self.mouse_just_pressed = currently_pressed and not self.mouse_button_pressed
    self.mouse_button_pressed = currently_pressed

    -- Store previous position for next frame
    self.prev_mouse_x = mx
    self.prev_mouse_y = my
end

function User:get_pos()
    return self.mouse_x, self.mouse_y
end

function User:get_rel()
    return self.mouse_dx, self.mouse_dy
end

return User

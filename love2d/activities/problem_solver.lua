-- activities/problem_solver.lua
local class = require 'lib.class'
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local i18n = require 'lib.i18n'
local validator = require 'lib.validator'

local ProblemSolver = class('ProblemSolver')

function ProblemSolver:initialize(screen_width, screen_height, header_height, font, problem)
    self.screen_width = screen_width
    self.screen_height = screen_height
    self.header_height = header_height
    self.font = font
    self.problem = problem

    -- Create grid for problem solving
    self.grid = CartesianPlane(
        screen_width,
        screen_height,
        header_height,
        font,
        0  -- No sidebar in problem mode
    )

    -- Setup initial state if problem has setup
    if problem.setup then
        if problem.setup.point1 or problem.setup.point2 then
            -- For distance/slope problems, draw the points
            if problem.setup.point1 then
                local px, py = self.grid:get_game_coordinates(problem.setup.point1.x, problem.setup.point1.y)
                local Point = require('interface.figures').Point
                local p1 = Point({px, py})
                p1.state = 'passive'  -- Non-interactive
                table.insert(self.grid.figures, p1)
            end
            if problem.setup.point2 then
                local px, py = self.grid:get_game_coordinates(problem.setup.point2.x, problem.setup.point2.y)
                local Point = require('interface.figures').Point
                local p2 = Point({px, py})
                p2.state = 'passive'
                table.insert(self.grid.figures, p2)
            end
        end
        if problem.setup.line then
            -- For slope problems, draw the line
            local Line = require('interface.figures').Line
            local p1 = problem.setup.line.point1
            local p2 = problem.setup.line.point2
            local px1, py1 = self.grid:get_game_coordinates(p1.x, p1.y)
            local line = Line({px1, py1})
            -- Set slope based on second point
            local px2, py2 = self.grid:get_game_coordinates(p2.x, p2.y)
            line.slope = (py2 - py1) / (px2 - px1)
            line.b = py1 - line.slope * px1
            line.initialized = true
            line.setting_slope = false
            line.state = 'passive'
            table.insert(self.grid.figures, line)
        end
    end

    -- UI state
    self.current_hint = 0
    self.show_feedback = false
    self.feedback_message = ""
    self.feedback_correct = false
    self.answer_input = ""
    self.input_active = false

    -- Button layout
    local button_y = screen_height - 60
    local button_width = 120
    local button_height = 40
    local button_spacing = 20

    -- Determine what tool students need
    self.tool_needed = nil
    if problem.validation.type == "point_at_coordinates" then
        self.tool_needed = "point"
    elseif problem.validation.type == "line_properties" then
        self.tool_needed = "line"
    end

    self.buttons = {
        back = {
            x = 20,
            y = header_height + 10,
            width = 100,
            height = 40,
            text = i18n.t('common.back'),
            hovered = false
        },
        add_figure = {
            x = 150,
            y = header_height + 10,
            width = 120,
            height = 40,
            text = self.tool_needed and ("Add " .. self.tool_needed) or "",
            hovered = false,
            enabled = self.tool_needed ~= nil
        },
        hint = {
            x = 20,
            y = button_y,
            width = button_width,
            height = button_height,
            text = i18n.t('problems.hint'),
            hovered = false,
            enabled = #(problem.hints or {}) > 0
        },
        check = {
            x = 20 + button_width + button_spacing,
            y = button_y,
            width = button_width,
            height = button_height,
            text = i18n.t('problems.check'),
            hovered = false,
            enabled = true
        }
    }

    -- Problem panel (shows title and instructions)
    self.panel = {
        x = screen_width - 320,
        y = header_height + 20,
        width = 300,
        height = 200
    }
end

function ProblemSolver:check_hover(mouse_x, mouse_y)
    local any_hovered = false

    for _, button in pairs(self.buttons) do
        button.hovered = button.enabled and
                        mouse_x >= button.x and mouse_x <= button.x + button.width and
                        mouse_y >= button.y and mouse_y <= button.y + button.height
        any_hovered = any_hovered or button.hovered
    end

    -- Check if hovering over input field
    if self:requires_text_input() then
        local input_box = self:get_input_box()
        self.input_active = mouse_x >= input_box.x and mouse_x <= input_box.x + input_box.width and
                           mouse_y >= input_box.y and mouse_y <= input_box.y + input_box.height
        any_hovered = any_hovered or self.input_active
    end

    return any_hovered
end

function ProblemSolver:requires_text_input()
    local v_type = self.problem.validation.type
    return v_type == "numeric_answer" or v_type == "boolean_answer"
end

function ProblemSolver:get_input_box()
    return {
        x = 20,
        y = self.screen_height - 120,
        width = 200,
        height = 40
    }
end

function ProblemSolver:handle_click(mouse_x, mouse_y, user)
    if self.buttons.back.hovered then
        return 'back'
    end

    if self.buttons.add_figure.hovered and self.buttons.add_figure.enabled then
        -- Add the appropriate figure type at the center of the grid
        local User = require 'interface.user'
        local temp_user = User()
        temp_user.mouse_x = self.screen_width / 2
        temp_user.mouse_y = self.screen_height / 2
        self.grid:new_figure(temp_user, self.tool_needed)
        return nil
    end

    if self.buttons.hint.hovered then
        self:show_hint()
        return nil
    end

    if self.buttons.check.hovered then
        return self:check_answer()
    end

    return nil
end

function ProblemSolver:show_hint()
    if not self.problem.hints or #self.problem.hints == 0 then
        return
    end

    self.current_hint = self.current_hint + 1
    if self.current_hint > #self.problem.hints then
        self.current_hint = 1  -- Loop back
    end
end

function ProblemSolver:check_answer()
    local answer = self:get_student_answer()

    if not answer then
        self.feedback_message = i18n.t('problems.feedback.no_answer')
        self.feedback_correct = false
        self.show_feedback = true
        return nil
    end

    local is_correct = validator.validate_answer(self.problem, answer)

    if is_correct then
        self.feedback_message = i18n.get_translation(self.problem.success_message or {
            en = "Correct! Well done!",
            es = "¡Correcto! ¡Bien hecho!"
        })
        self.feedback_correct = true
    else
        self.feedback_message = i18n.t('problems.feedback.incorrect')
        self.feedback_correct = false
    end

    self.show_feedback = true
    return nil
end

function ProblemSolver:get_student_answer()
    local v_type = self.problem.validation.type

    if v_type == "point_at_coordinates" then
        -- Find the student's point
        for _, figure in ipairs(self.grid.figures) do
            if tostring(figure) == "point" and figure.state ~= 'passive' then
                local cart_x, cart_y = self.grid:get_cartesian_coordinates(figure.pos[1], figure.pos[2])
                return {x = cart_x, y = cart_y}
            end
        end
        return nil
    elseif v_type == "numeric_answer" then
        local num = tonumber(self.answer_input)
        return num
    elseif v_type == "boolean_answer" then
        local lower = string.lower(self.answer_input)
        if lower == "true" or lower == "yes" or lower == "si" or lower == "sí" then
            return true
        elseif lower == "false" or lower == "no" then
            return false
        end
        return nil
    elseif v_type == "line_properties" then
        -- Find the student's line
        for _, figure in ipairs(self.grid.figures) do
            if tostring(figure) == "line" and figure.state ~= 'passive' then
                return {slope = figure.slope, y_intercept = figure.b}
            end
        end
        return nil
    end

    return nil
end

function ProblemSolver:handle_text_input(text)
    if self.input_active and self:requires_text_input() then
        self.answer_input = self.answer_input .. text
    end
end

function ProblemSolver:handle_backspace()
    if self.input_active and self:requires_text_input() then
        self.answer_input = self.answer_input:sub(1, -2)
    end
end

function ProblemSolver:draw(mouse_x, mouse_y)
    -- Draw grid
    self.grid:draw(mouse_x, mouse_y)

    -- Draw problem panel
    local p = self.panel
    love.graphics.setColor(0.95, 0.95, 0.95, 0.95)
    love.graphics.rectangle('fill', p.x, p.y, p.width, p.height, 8, 8)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', p.x, p.y, p.width, p.height, 8, 8)
    love.graphics.setLineWidth(1)

    -- Problem title
    love.graphics.setColor(config.COLOR_BLACK)
    local title = i18n.get_translation(self.problem.title)
    love.graphics.printf(title, p.x + 10, p.y + 10, p.width - 20)

    -- Instructions
    love.graphics.setColor(0.3, 0.3, 0.3)
    local instructions = i18n.get_translation(self.problem.instructions)
    love.graphics.printf(instructions, p.x + 10, p.y + 50, p.width - 20)

    -- Current hint
    if self.current_hint > 0 and self.problem.hints then
        love.graphics.setColor(0.2, 0.4, 0.7)
        local hint = i18n.get_translation(self.problem.hints[self.current_hint])
        love.graphics.printf(i18n.t('problems.hint') .. ": " .. hint, p.x + 10, p.y + 130, p.width - 20)
    end

    -- Draw buttons
    for _, button in pairs(self.buttons) do
        local color
        if not button.enabled then
            color = {0.7, 0.7, 0.7}
        elseif button.hovered then
            color = config.COLOR_BUTTON_HOVERED
        else
            color = config.COLOR_BUTTON_PASIVE
        end

        love.graphics.setColor(color)
        love.graphics.rectangle('fill', button.x, button.y, button.width, button.height, 5, 5)
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.rectangle('line', button.x, button.y, button.width, button.height, 5, 5)

        local text_width = self.font:getWidth(button.text)
        local text_height = self.font:getHeight()
        love.graphics.print(button.text,
            button.x + (button.width - text_width) / 2,
            button.y + (button.height - text_height) / 2)
    end

    -- Draw input field if needed
    if self:requires_text_input() then
        local input = self:get_input_box()
        local color = self.input_active and {1, 1, 0.8} or {1, 1, 1}
        love.graphics.setColor(color)
        love.graphics.rectangle('fill', input.x, input.y, input.width, input.height, 5, 5)
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.rectangle('line', input.x, input.y, input.width, input.height, 5, 5)

        -- Label
        love.graphics.print(i18n.t('problems.your_answer') .. ":", input.x, input.y - 25)

        -- Answer text
        love.graphics.print(self.answer_input, input.x + 10, input.y + 10)

        -- Cursor
        if self.input_active and math.floor(love.timer.getTime() * 2) % 2 == 0 then
            local cursor_x = input.x + 10 + self.font:getWidth(self.answer_input)
            love.graphics.line(cursor_x, input.y + 5, cursor_x, input.y + input.height - 5)
        end
    end

    -- Draw feedback
    if self.show_feedback then
        local feedback_box = {
            x = (self.screen_width - 400) / 2,
            y = (self.screen_height - 150) / 2,
            width = 400,
            height = 150
        }

        -- Background
        local bg_color = self.feedback_correct and {0.7, 1, 0.7, 0.95} or {1, 0.7, 0.7, 0.95}
        love.graphics.setColor(bg_color)
        love.graphics.rectangle('fill', feedback_box.x, feedback_box.y, feedback_box.width, feedback_box.height, 10, 10)

        -- Border
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle('line', feedback_box.x, feedback_box.y, feedback_box.width, feedback_box.height, 10, 10)
        love.graphics.setLineWidth(1)

        -- Message
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.printf(self.feedback_message, feedback_box.x + 20, feedback_box.y + 40, feedback_box.width - 40, 'center')

        -- Close button
        local close_text = i18n.t('common.close')
        local close_width = 100
        local close_height = 35
        local close_x = feedback_box.x + (feedback_box.width - close_width) / 2
        local close_y = feedback_box.y + feedback_box.height - close_height - 15

        love.graphics.setColor(config.COLOR_BUTTON_PASIVE)
        love.graphics.rectangle('fill', close_x, close_y, close_width, close_height, 5, 5)
        love.graphics.setColor(config.COLOR_BLACK)
        love.graphics.rectangle('line', close_x, close_y, close_width, close_height, 5, 5)

        local text_width = self.font:getWidth(close_text)
        local text_height = self.font:getHeight()
        love.graphics.print(close_text, close_x + (close_width - text_width) / 2, close_y + (close_height - text_height) / 2)

        -- Store close button position for click detection
        self.close_button = {x = close_x, y = close_y, width = close_width, height = close_height}
    end
end

function ProblemSolver:handle_feedback_click(mouse_x, mouse_y)
    if self.show_feedback and self.close_button then
        local cb = self.close_button
        if mouse_x >= cb.x and mouse_x <= cb.x + cb.width and
           mouse_y >= cb.y and mouse_y <= cb.y + cb.height then
            self.show_feedback = false
            return true
        end
    end
    return false
end

return ProblemSolver

-- states/problem_solver_state.lua
local config = require 'config'
local CartesianPlane = require 'interface.cartesian_plane'
local i18n = require 'lib.i18n'
local validator = require 'lib.validator'
local Slab = require 'lib.Slab'
local User = require 'interface.user'

local problem_solver = {}

function problem_solver:enter(from, problem)
    self.problem = problem
    self.user = User()

    -- Get current window dimensions
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    -- Create grid for problem solving
    self.grid = CartesianPlane(
        screen_width,
        screen_height,
        config.HEADER_SIZE,
        love.graphics.getFont(),
        0  -- No sidebar in problem mode
    )

    -- Setup initial state if problem has setup
    if problem.setup then
        if problem.setup.point1 or problem.setup.point2 then
            if problem.setup.point1 then
                local px, py = self.grid:get_game_coordinates(problem.setup.point1.x, problem.setup.point1.y)
                local Point = require('interface.figures').Point
                local p1 = Point({px, py})
                p1.state = 'passive'
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
            local Line = require('interface.figures').Line
            local p1 = problem.setup.line.point1
            local p2 = problem.setup.line.point2
            local px1, py1 = self.grid:get_game_coordinates(p1.x, p1.y)
            local line = Line({px1, py1})
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

    -- Determine what tool students need
    self.tool_needed = nil
    if problem.validation.type == "point_at_coordinates" then
        self.tool_needed = "point"
    elseif problem.validation.type == "line_properties" then
        self.tool_needed = "line"
    end

    self.moving = false
end

function problem_solver:requires_text_input()
    local v_type = self.problem.validation.type
    return v_type == "numeric_answer" or v_type == "boolean_answer"
end

function problem_solver:get_student_answer()
    local v_type = self.problem.validation.type

    if v_type == "point_at_coordinates" then
        for _, figure in ipairs(self.grid.figures) do
            if tostring(figure) == "point" and figure.state ~= 'passive' then
                local cart_x, cart_y = self.grid:get_cartesian_coordinates(figure.pos[1], figure.pos[2])
                return {x = cart_x, y = cart_y}
            end
        end
        return nil
    elseif v_type == "numeric_answer" then
        return tonumber(self.answer_input)
    elseif v_type == "boolean_answer" then
        local lower = string.lower(self.answer_input)
        if lower == "true" or lower == "yes" or lower == "si" or lower == "sí" then
            return true
        elseif lower == "false" or lower == "no" then
            return false
        end
        return nil
    elseif v_type == "line_properties" then
        for _, figure in ipairs(self.grid.figures) do
            if tostring(figure) == "line" and figure.state ~= 'passive' then
                return {slope = figure.slope, y_intercept = figure.b}
            end
        end
        return nil
    end

    return nil
end

function problem_solver:check_answer()
    local answer = self:get_student_answer()

    if not answer then
        self.feedback_message = i18n.t('problems.feedback.no_answer')
        self.feedback_correct = false
        self.show_feedback = true
        return
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
end

function problem_solver:update(dt)
    Slab.Update(dt)

    -- Update user input
    self.user:update()

    -- Handle movement
    self.moving = self.grid:check_movement(self.moving, self.user)
    if self.moving then
        self.grid:move_figure(self.user.mouse_x, self.user.mouse_y)
    end

    -- Handle grid interaction
    if self.user.mouse_y >= config.HEADER_SIZE and not self.moving then
        self.grid:run(self.user)
    end

    -- Problem UI Panel
    Slab.BeginWindow('ProblemPanel', {
        Title = i18n.get_translation(self.problem.title),
        X = love.graphics.getWidth() - 320,
        Y = config.HEADER_SIZE + 20,
        W = 300,
        H = 250,
        AllowResize = false
    })

    Slab.Text(i18n.get_translation(self.problem.instructions))
    Slab.Separator()

    -- Current hint
    if self.current_hint > 0 and self.problem.hints then
        Slab.Text(i18n.t('problems.hint') .. ":", {Color = {0.2, 0.4, 0.7}})
        Slab.Text(i18n.get_translation(self.problem.hints[self.current_hint]), {Color = {0.2, 0.4, 0.7}})
    end

    Slab.EndWindow()

    -- Control Panel
    Slab.BeginWindow('ControlPanel', {
        Title = "Controls",
        X = 20,
        Y = love.graphics.getHeight() - 120,
        W = 400,
        H = 100,
        AllowResize = false,
        AllowMove = false
    })

    -- Back button
    if Slab.Button(i18n.t('common.back')) then
        local Gamestate = require 'lib.gamestate'
        Gamestate.switch(require 'states.problem_menu_state')
    end

    Slab.SameLine()

    -- Add figure button
    if self.tool_needed then
        if Slab.Button("Add " .. self.tool_needed) then
            local temp_user = User()
            temp_user.mouse_x = love.graphics.getWidth() / 2
            temp_user.mouse_y = love.graphics.getHeight() / 2
            self.grid:new_figure(temp_user, self.tool_needed)
        end
        Slab.SameLine()
    end

    -- Hint button
    if #(self.problem.hints or {}) > 0 then
        if Slab.Button(i18n.t('problems.hint')) then
            self.current_hint = self.current_hint + 1
            if self.current_hint > #self.problem.hints then
                self.current_hint = 1
            end
        end
        Slab.SameLine()
    end

    -- Check answer button
    if Slab.Button(i18n.t('problems.check')) then
        self:check_answer()
    end

    -- Text input for numeric/boolean answers
    if self:requires_text_input() then
        Slab.NewLine()
        Slab.Text(i18n.t('problems.your_answer') .. ":")
        Slab.SameLine()
        if Slab.Input('answer_input', {Text = self.answer_input, ReturnOnText = false}) then
            self.answer_input = Slab.GetInputText()
        end
    end

    Slab.EndWindow()

    -- Feedback dialog
    if self.show_feedback then
        local result = Slab.MessageBox("Feedback", self.feedback_message)
        if result ~= "" then
            self.show_feedback = false
        end
    end
end

function problem_solver:draw()
    -- Draw grid
    local mouse_x, mouse_y = nil, nil
    if self.user.mouse_y >= config.HEADER_SIZE then
        mouse_x, mouse_y = self.user:get_pos()
    end
    self.grid:draw(mouse_x, mouse_y)

    -- Draw UI
    Slab.Draw()
end

function problem_solver:resize(w, h)
    self.grid = CartesianPlane(
        w,
        h,
        config.HEADER_SIZE,
        love.graphics.getFont(),
        0
    )
end

return problem_solver

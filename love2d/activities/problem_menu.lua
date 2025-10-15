-- activities/problem_menu.lua
local class = require 'lib.class'
local config = require 'config'
local problem_loader = require 'lib.problem_loader'
local i18n = require 'lib.i18n'

local ProblemMenu = class('ProblemMenu')

function ProblemMenu:initialize(screen_width, screen_height, header_height, font)
    self.screen_width = screen_width
    self.screen_height = screen_height
    self.header_height = header_height
    self.font = font

    -- Load all problems
    self.problems = {}
    self.problems.plot_points = problem_loader.load_problems_from_directory('problems/plot_points')
    self.problems.distance = problem_loader.load_problems_from_directory('problems/distance')
    self.problems.slope = problem_loader.load_problems_from_directory('problems/slope')

    -- Load lessons
    self.lessons = problem_loader.load_problems_from_directory('problems/lessons')

    -- UI state
    self.scroll_offset = 0
    self.selected_problem = nil
    self.selected_lesson = nil

    -- Layout
    self.padding = 20
    self.item_height = 60
    self.item_spacing = 10

    -- Back button
    self.back_button = {
        x = 20,
        y = header_height + 10,
        width = 100,
        height = 40,
        text = i18n.t('common.back'),
        hovered = false
    }
end

function ProblemMenu:get_all_problems()
    local all = {}

    -- Add problems from each category
    for category, problems in pairs(self.problems) do
        for _, problem in ipairs(problems) do
            problem.category = category
            table.insert(all, problem)
        end
    end

    return all
end

function ProblemMenu:check_hover(mouse_x, mouse_y)
    -- Check back button
    local bb = self.back_button
    bb.hovered = mouse_x >= bb.x and mouse_x <= bb.x + bb.width and
                 mouse_y >= bb.y and mouse_y <= bb.y + bb.height

    return bb.hovered
end

function ProblemMenu:handle_click(mouse_x, mouse_y)
    -- Check back button
    if self.back_button.hovered then
        return 'back'
    end

    -- Check problem items
    local all_problems = self:get_all_problems()
    local content_y = self.header_height + 80 - self.scroll_offset

    for i, problem in ipairs(all_problems) do
        local item_y = content_y + (i - 1) * (self.item_height + self.item_spacing)
        local item_x = self.padding
        local item_width = self.screen_width - self.padding * 2

        if mouse_x >= item_x and mouse_x <= item_x + item_width and
           mouse_y >= item_y and mouse_y <= item_y + self.item_height then
            self.selected_problem = problem
            return 'start_problem'
        end
    end

    return nil
end

function ProblemMenu:draw()
    -- Background
    love.graphics.setColor(config.COLOR_BACKGROUND)
    love.graphics.rectangle('fill', 0, self.header_height, self.screen_width, self.screen_height - self.header_height)

    -- Title
    love.graphics.setColor(config.COLOR_BLACK)
    love.graphics.setFont(self.font)
    local title = i18n.t('problems.title')
    local title_x = (self.screen_width - self.font:getWidth(title)) / 2
    love.graphics.print(title, title_x, self.header_height + 20)

    -- Back button
    local bb = self.back_button
    local button_color = bb.hovered and config.COLOR_BUTTON_HOVERED or config.COLOR_BUTTON_PASIVE
    love.graphics.setColor(button_color)
    love.graphics.rectangle('fill', bb.x, bb.y, bb.width, bb.height, 5, 5)
    love.graphics.setColor(config.COLOR_BLACK)
    love.graphics.rectangle('line', bb.x, bb.y, bb.width, bb.height, 5, 5)
    local text_width = self.font:getWidth(bb.text)
    local text_height = self.font:getHeight()
    love.graphics.print(bb.text, bb.x + (bb.width - text_width) / 2, bb.y + (bb.height - text_height) / 2)

    -- Problem list
    local all_problems = self:get_all_problems()
    local content_y = self.header_height + 80 - self.scroll_offset

    -- Enable scissor to clip content
    love.graphics.setScissor(0, self.header_height + 70, self.screen_width, self.screen_height - self.header_height - 70)

    for i, problem in ipairs(all_problems) do
        local item_y = content_y + (i - 1) * (self.item_height + self.item_spacing)
        local item_x = self.padding
        local item_width = self.screen_width - self.padding * 2

        -- Problem card background
        love.graphics.setColor(0.95, 0.95, 0.95)
        love.graphics.rectangle('fill', item_x, item_y, item_width, self.item_height, 5, 5)

        -- Border
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', item_x, item_y, item_width, self.item_height, 5, 5)
        love.graphics.setLineWidth(1)

        -- Problem title
        love.graphics.setColor(config.COLOR_BLACK)
        local title = i18n.get_translation(problem.title)
        love.graphics.print(title, item_x + 10, item_y + 10)

        -- Problem type and difficulty
        local info = string.format("%s - %s %d",
            i18n.t('problems.types.' .. problem.type),
            i18n.t('problems.difficulty'),
            problem.difficulty)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.print(info, item_x + 10, item_y + 35)
    end

    -- Disable scissor
    love.graphics.setScissor()

    -- Instructions
    if #all_problems == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        local msg = "No problems found. Add JSON files to love2d/problems/"
        local msg_x = (self.screen_width - self.font:getWidth(msg)) / 2
        love.graphics.print(msg, msg_x, self.screen_height / 2)
    end
end

function ProblemMenu:handle_scroll(dy)
    self.scroll_offset = self.scroll_offset - dy * 20

    -- Clamp scroll
    local all_problems = self:get_all_problems()
    local max_scroll = math.max(0, (#all_problems * (self.item_height + self.item_spacing)) - (self.screen_height - self.header_height - 100))
    self.scroll_offset = math.max(0, math.min(self.scroll_offset, max_scroll))
end

return ProblemMenu

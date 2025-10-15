-- states/problem_menu_state.lua
local config = require 'config'
local problem_loader = require 'lib.problem_loader'
local i18n = require 'lib.i18n'
local Slab = require 'lib.Slab'

local problem_menu = {}

function problem_menu:enter()
    -- Load all problems
    self.problems = {}
    self.problems.plot_points = problem_loader.load_problems_from_directory('problems/plot_points')
    self.problems.distance = problem_loader.load_problems_from_directory('problems/distance')
    self.problems.slope = problem_loader.load_problems_from_directory('problems/slope')

    -- Load lessons
    self.lessons = problem_loader.load_problems_from_directory('problems/lessons')

    self.selected_problem = nil
end

function problem_menu:get_all_problems()
    local all = {}
    for category, problems in pairs(self.problems) do
        for _, problem in ipairs(problems) do
            problem.category = category
            table.insert(all, problem)
        end
    end
    return all
end

function problem_menu:update(dt)
    Slab.Update(dt)

    Slab.BeginWindow('ProblemMenuWindow', {
        Title = i18n.t('problems.title'),
        X = 0,
        Y = config.HEADER_SIZE,
        W = love.graphics.getWidth(),
        H = love.graphics.getHeight() - config.HEADER_SIZE,
        AllowResize = false,
        AllowMove = false,
        AutoSizeWindow = false,
        ShowTitle = false,
        Border = 0
    })

    -- Back button
    if Slab.Button(i18n.t('common.back')) then
        local Gamestate = require 'lib.gamestate'
        Gamestate.switch(require 'states.playground')
    end

    Slab.Separator()

    -- Title
    Slab.Text(i18n.t('problems.title'), {IsSelectable = false})
    Slab.Separator()

    -- Problem list
    local all_problems = self:get_all_problems()

    if #all_problems == 0 then
        Slab.Text("No problems found. Add JSON files to love2d/problems/")
    else
        for i, problem in ipairs(all_problems) do
            Slab.BeginTree(string.format("problem_%d", i), {Label = i18n.get_translation(problem.title), IsLeaf = true})

            if Slab.IsControlClicked() then
                self.selected_problem = problem
                local Gamestate = require 'lib.gamestate'
                Gamestate.switch(require 'states.problem_solver_state', problem)
            end

            Slab.Text(string.format("%s - %s %d",
                i18n.t('problems.types.' .. problem.type),
                i18n.t('problems.difficulty'),
                problem.difficulty))

            Slab.EndTree()
        end
    end

    Slab.EndWindow()
end

function problem_menu:draw()
    Slab.Draw()
end

return problem_menu

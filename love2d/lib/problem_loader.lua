-- lib/problem_loader.lua
-- Load and parse problem JSON files

local json = require 'lib.json'

local problem_loader = {}

-- Load a single problem from file
function problem_loader.load_problem(filepath)
    local info = love.filesystem.getInfo(filepath)
    if not info then
        print("Problem file not found: " .. filepath)
        return nil
    end

    local contents, err = love.filesystem.read(filepath)
    if not contents then
        print("Error reading problem file: " .. err)
        return nil
    end

    local success, problem = pcall(json.decode, contents)
    if not success then
        print("Error parsing JSON: " .. tostring(problem))
        return nil
    end

    return problem
end

-- Load all problems from a directory
function problem_loader.load_problems_from_directory(directory)
    local problems = {}
    local files = love.filesystem.getDirectoryItems(directory)

    for _, filename in ipairs(files) do
        if filename:match("%.json$") then
            local filepath = directory .. "/" .. filename
            local problem = problem_loader.load_problem(filepath)
            if problem then
                table.insert(problems, problem)
            end
        end
    end

    return problems
end

-- Load a lesson (collection of problems)
function problem_loader.load_lesson(filepath)
    local lesson = problem_loader.load_problem(filepath)
    if not lesson then
        return nil
    end

    -- Load referenced problems if they're just IDs
    if lesson.problems and #lesson.problems > 0 then
        local loaded_problems = {}
        for _, problem_ref in ipairs(lesson.problems) do
            if type(problem_ref) == "string" then
                -- It's a problem ID, need to find and load it
                local problem = problem_loader.find_problem_by_id(problem_ref)
                if problem then
                    table.insert(loaded_problems, problem)
                end
            elseif type(problem_ref) == "table" then
                -- It's an embedded problem
                table.insert(loaded_problems, problem_ref)
            end
        end
        lesson.problems = loaded_problems
    end

    return lesson
end

-- Find a problem by ID (searches all problem directories)
function problem_loader.find_problem_by_id(problem_id)
    local directories = {
        "problems/plot_points",
        "problems/distance",
        "problems/slope"
    }

    for _, dir in ipairs(directories) do
        local files = love.filesystem.getDirectoryItems(dir)
        for _, filename in ipairs(files) do
            if filename:match("%.json$") then
                local problem = problem_loader.load_problem(dir .. "/" .. filename)
                if problem and problem.id == problem_id then
                    return problem
                end
            end
        end
    end

    return nil
end

-- Get all available problem types
function problem_loader.get_problem_types()
    return {
        "plot_points",
        "measure_distance",
        "find_slope",
        "draw_line_with_slope",
        "check_colinearity",
        "find_equation"
    }
end

-- Get all available lessons
function problem_loader.get_all_lessons()
    local lessons = {}
    local lesson_dir = "problems/lessons"

    local files = love.filesystem.getDirectoryItems(lesson_dir)
    for _, filename in ipairs(files) do
        if filename:match("%.json$") then
            local lesson = problem_loader.load_lesson(lesson_dir .. "/" .. filename)
            if lesson then
                table.insert(lessons, lesson)
            end
        end
    end

    return lessons
end

-- Validate problem structure
function problem_loader.validate_problem(problem)
    if not problem then return false, "Problem is nil" end
    if not problem.type then return false, "Missing 'type' field" end
    if not problem.instructions then return false, "Missing 'instructions' field" end
    if not problem.validation then return false, "Missing 'validation' field" end

    return true
end

return problem_loader

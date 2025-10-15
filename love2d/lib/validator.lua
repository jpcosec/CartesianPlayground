-- lib/validator.lua
-- Validate student answers for problems

local geometry = require 'lib.geometry'

local validator = {}

-- Validate a student's answer based on problem validation rules
function validator.validate_answer(problem, student_answer)
    if not problem or not problem.validation then
        return false, "Invalid problem"
    end

    local validation = problem.validation
    local v_type = validation.type

    -- Point placement validation
    if v_type == "point_at_coordinates" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.5

        if not student_answer or not student_answer.x or not student_answer.y then
            return false, "No point placed"
        end

        local distance = geometry.distance(
            student_answer.x, student_answer.y,
            expected.x, expected.y
        )

        if distance <= tolerance then
            return true, "Correct! Point placed at (" .. expected.x .. ", " .. expected.y .. ")"
        else
            return false, "Not quite. The point should be at (" .. expected.x .. ", " .. expected.y .. ")"
        end
    end

    -- Numeric answer validation (distance, slope, etc.)
    if v_type == "numeric_answer" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.1

        if not student_answer or type(student_answer) ~= "number" then
            return false, "Invalid numeric answer"
        end

        local diff = math.abs(student_answer - expected)

        if diff <= tolerance then
            return true, "Correct! The answer is " .. string.format("%.2f", expected)
        elseif diff <= tolerance * 3 then
            return false, "Close! Check your calculation."
        else
            return false, "That's not correct. Try again!"
        end
    end

    -- Boolean answer validation
    if v_type == "boolean_answer" then
        local expected = validation.expected

        if student_answer == expected then
            return true, "Correct!"
        else
            return false, "That's not correct. Try again!"
        end
    end

    -- Line properties validation
    if v_type == "line_properties" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.1

        if not student_answer or not student_answer.slope then
            return false, "No line created"
        end

        -- Check slope
        local slope_diff = math.abs((student_answer.slope or 0) - (expected.slope or 0))
        if slope_diff > tolerance then
            return false, "The slope is not correct. Expected: " .. string.format("%.2f", expected.slope)
        end

        -- Check if line passes through required point
        if expected.passes_through then
            local pt = expected.passes_through
            if not geometry.line_passes_through_point(
                student_answer.slope,
                student_answer.y_intercept or 0,
                pt.x, pt.y,
                tolerance
            ) then
                return false, "The line doesn't pass through (" .. pt.x .. ", " .. pt.y .. ")"
            end
        end

        return true, "Correct! Good job!"
    end

    -- Equation validation (y = mx + b)
    if v_type == "equation" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.01

        if not student_answer then
            return false, "No equation provided"
        end

        -- Check slope
        local slope_diff = math.abs((student_answer.slope or 0) - (expected.slope or 0))
        if slope_diff > tolerance then
            return false, "The slope is not correct"
        end

        -- Check y-intercept
        local intercept_diff = math.abs((student_answer.y_intercept or 0) - (expected.y_intercept or 0))
        if intercept_diff > tolerance then
            return false, "The y-intercept is not correct"
        end

        return true, string.format("Correct! y = %.2fx + %.2f", expected.slope, expected.y_intercept)
    end

    -- Multiple points validation
    if v_type == "multiple_points" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.5

        if not student_answer or #student_answer ~= #expected then
            return false, "Incorrect number of points"
        end

        -- Check each point
        for i, expected_pt in ipairs(expected) do
            local student_pt = student_answer[i]
            if not student_pt then
                return false, "Missing point " .. i
            end

            local distance = geometry.distance(
                student_pt.x, student_pt.y,
                expected_pt.x, expected_pt.y
            )

            if distance > tolerance then
                return false, "Point " .. i .. " is not in the correct position"
            end
        end

        return true, "Correct! All points placed correctly!"
    end

    return false, "Unknown validation type: " .. tostring(v_type)
end

-- Helper: Check if student answer is close to correct (for hints)
function validator.is_close(problem, student_answer)
    if not problem or not problem.validation then
        return false
    end

    local validation = problem.validation

    if validation.type == "numeric_answer" then
        local expected = validation.expected
        local tolerance = validation.tolerance or 0.1
        local diff = math.abs((student_answer or 0) - expected)
        return diff <= tolerance * 3
    end

    return false
end

return validator

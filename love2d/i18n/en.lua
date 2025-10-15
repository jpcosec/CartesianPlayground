-- i18n/en.lua
-- English translations for CartesianPlayground

return {
    _language_name = "English",
    _language_code = "en",

    -- Menu and UI
    menu = {
        title = "Cartesian Playground",
        sandbox_mode = "Sandbox Mode",
        problems_mode = "Problems",
        settings = "Settings",
        quit = "Quit"
    },

    -- Header buttons
    header = {
        intro = "intro",
        line = "line",
        point = "point",
        problems = "problems"
    },

    -- Instructions window
    instructions = {
        title = "Instructions",
        welcome = "Welcome to Playground Cartesiano!",
        create_figures = "Click buttons to create geometric figures:",
        point_help = "Point: Creates a draggable point",
        line_help = "Line: Creates a line (drag to set slope, click origin to translate)",
        drag_help = "Drag figures to move them around.",
        deselect_help = "Click away to deselect.",
        close = "Close"
    },

    -- Sidebar
    sidebar = {
        title = "Figures",
        no_figures = "No figures yet",
        point_label = "P{index}: ({x}, {y})",
        line_label = "L{index}:",
        figure_label = "F{index}"
    },

    -- Problem system
    problems = {
        title = "Problems",
        select_activity = "Select an activity:",
        difficulty = "Difficulty",
        easy = "Easy",
        medium = "Medium",
        hard = "Hard",
        start = "Start",
        next = "Next Problem",
        check = "Check Answer",
        hint = "Hint",
        your_answer = "Your Answer",
        correct = "Correct!",
        incorrect = "Not quite. Try again!",
        completed = "Activity completed!",
        score = "Score: {score}%",
        back = "Back to Menu",

        -- Feedback messages
        feedback = {
            no_answer = "Please provide an answer first!",
            incorrect = "Not quite. Try again!",
            correct = "Correct! Well done!"
        },

        -- Problem types
        types = {
            plot_points = "Plot Points",
            measure_distance = "Measure Distance",
            find_slope = "Find Slope",
            draw_line_with_slope = "Draw Line with Slope",
            check_colinearity = "Check Colinearity",
            find_equation = "Find Equation",
            find_midpoint = "Find Midpoint",
            parallel_lines = "Parallel Lines",
            perpendicular_lines = "Perpendicular Lines"
        }
    },

    -- Problem types
    problem_types = {
        plot_points = "Plot Points",
        measure_distance = "Measure Distance",
        find_slope = "Find Slope",
        draw_line_with_slope = "Draw Line with Slope",
        check_colinearity = "Check Colinearity",
        find_equation = "Find Equation",
        find_midpoint = "Find Midpoint",
        parallel_lines = "Parallel Lines",
        perpendicular_lines = "Perpendicular Lines"
    },

    -- Validation messages
    validation = {
        point_placed = "Point placed at ({x}, {y})",
        distance_is = "The distance is {distance}",
        slope_is = "The slope is {slope}",
        equation_is = "The equation is y = {slope}x + {intercept}",
        points_are_colinear = "The points are colinear",
        points_not_colinear = "The points are not colinear",
        correct_answer = "Correct! Great job!",
        wrong_answer = "That's not correct. Try again!",
        close_answer = "You're close! Check your calculation."
    },

    -- Geometric terms
    geometry = {
        point = "point",
        line = "line",
        slope = "slope",
        y_intercept = "y-intercept",
        distance = "distance",
        midpoint = "midpoint",
        coordinates = "coordinates",
        equation = "equation",
        parallel = "parallel",
        perpendicular = "perpendicular",
        colinear = "colinear",
        horizontal = "horizontal",
        vertical = "vertical"
    },

    -- Common words
    common = {
        yes = "Yes",
        no = "No",
        ok = "OK",
        cancel = "Cancel",
        save = "Save",
        load = "Load",
        delete = "Delete",
        edit = "Edit",
        create = "Create",
        clear = "Clear",
        reset = "Reset",
        back = "Back",
        close = "Close"
    }
}

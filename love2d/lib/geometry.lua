-- lib/geometry.lua
-- Geometry utility functions ported from eduactiv8-mobile
-- and enhanced for CartesianPlayground

local geometry = {}

-- Calculate Euclidean distance between two points
function geometry.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Calculate angle (in radians) formed by three points
-- Returns angle at point 2 (the middle point)
function geometry.angle(x1, y1, x2, y2, x3, y3)
    local a = geometry.distance(x2, y2, x3, y3)
    local b = geometry.distance(x1, y1, x3, y3)
    local c = geometry.distance(x1, y1, x2, y2)

    if a == 0 or c == 0 then
        return 0
    end

    local cos_angle = (a^2 + c^2 - b^2) / (2 * a * c)
    -- Clamp to [-1, 1] to avoid domain errors from floating point imprecision
    cos_angle = math.max(-1, math.min(1, cos_angle))

    return math.acos(cos_angle)
end

-- Calculate clockwise angle from point 1 to point 3, centered at point 2
function geometry.angle_clock(x1, y1, x2, y2, x3, y3)
    local angle1 = math.atan2(y1 - y2, x1 - x2)
    local angle3 = math.atan2(y3 - y2, x3 - x2)
    local angle = angle1 - angle3

    if angle < 0 then
        angle = angle + 2 * math.pi
    end

    return angle
end

-- Calculate the smallest difference between two angles
function geometry.angle_difference(angle1, angle2)
    local diff = angle1 - angle2
    while diff > math.pi do
        diff = diff - 2 * math.pi
    end
    while diff < -math.pi do
        diff = diff + 2 * math.pi
    end
    return math.abs(diff)
end

-- Calculate orientation of three ordered points
-- Returns:
--   0: Colinear
--   1: Clockwise
--   2: Counter-clockwise
function geometry.orientation(x1, y1, x2, y2, x3, y3)
    local val = (y2 - y1) * (x3 - x2) - (x2 - x1) * (y3 - y2)

    if math.abs(val) < 1e-10 then
        return 0  -- Colinear
    end

    return (val > 0) and 1 or 2  -- Clockwise or Counter-clockwise
end

-- Check if point (x2, y2) lies on line segment from (x1, y1) to (x3, y3)
-- Assumes the three points are colinear
function geometry.on_segment(x1, y1, x2, y2, x3, y3)
    return x2 <= math.max(x1, x3) and x2 >= math.min(x1, x3) and
           y2 <= math.max(y1, y3) and y2 >= math.min(y1, y3)
end

-- Check if two line segments intersect
-- Segment 1: from (x1, y1) to (x2, y2)
-- Segment 2: from (x3, y3) to (x4, y4)
function geometry.do_intersect(x1, y1, x2, y2, x3, y3, x4, y4)
    local o1 = geometry.orientation(x1, y1, x2, y2, x3, y3)
    local o2 = geometry.orientation(x1, y1, x2, y2, x4, y4)
    local o3 = geometry.orientation(x3, y3, x4, y4, x1, y1)
    local o4 = geometry.orientation(x3, y3, x4, y4, x2, y2)

    -- General case
    if o1 ~= o2 and o3 ~= o4 then
        return true
    end

    -- Special cases: colinear points
    if o1 == 0 and geometry.on_segment(x1, y1, x3, y3, x2, y2) then return true end
    if o2 == 0 and geometry.on_segment(x1, y1, x4, y4, x2, y2) then return true end
    if o3 == 0 and geometry.on_segment(x3, y3, x1, y1, x4, y4) then return true end
    if o4 == 0 and geometry.on_segment(x3, y3, x2, y2, x4, y4) then return true end

    return false
end

-- Check if two line segments are parallel
-- Segment 1: from (x1, y1) to (x2, y2)
-- Segment 2: from (x3, y3) to (x4, y4)
function geometry.are_parallel(x1, y1, x2, y2, x3, y3, x4, y4, tolerance)
    tolerance = tolerance or 1e-10

    local dx1 = x2 - x1
    local dy1 = y2 - y1
    local dx2 = x4 - x3
    local dy2 = y4 - y3

    -- Cross product of direction vectors
    -- If cross product is 0, lines are parallel
    local cross = dx1 * dy2 - dy1 * dx2

    return math.abs(cross) < tolerance
end

-- ========== Additional utility functions for CartesianPlayground ==========

-- Check if three points are colinear (lie on the same line)
function geometry.are_colinear(x1, y1, x2, y2, x3, y3, tolerance)
    tolerance = tolerance or 0.01
    -- Use orientation function: if orientation is 0, they're colinear
    return geometry.orientation(x1, y1, x2, y2, x3, y3) == 0
end

-- Calculate the slope between two points
-- Returns math.huge for vertical lines
function geometry.slope(x1, y1, x2, y2)
    if math.abs(x2 - x1) < 1e-10 then
        return math.huge  -- Vertical line
    end
    return (y2 - y1) / (x2 - x1)
end

-- Calculate y-intercept of a line passing through (x, y) with given slope
function geometry.y_intercept(x, y, slope)
    if slope == math.huge then
        return nil  -- Vertical line has no y-intercept
    end
    return y - slope * x
end

-- Calculate midpoint between two points
function geometry.midpoint(x1, y1, x2, y2)
    return (x1 + x2) / 2, (y1 + y2) / 2
end

-- Check if a point is within tolerance of target coordinates
function geometry.point_near(x, y, target_x, target_y, tolerance)
    tolerance = tolerance or 0.5
    return geometry.distance(x, y, target_x, target_y) <= tolerance
end

-- Check if a line (defined by slope and y-intercept) passes through a point
function geometry.line_passes_through_point(slope, y_intercept, x, y, tolerance)
    tolerance = tolerance or 0.1

    if slope == math.huge then
        -- Vertical line: x = y_intercept (misnamed for vertical lines)
        return math.abs(x - y_intercept) < tolerance
    end

    -- Calculate expected y for given x
    local expected_y = slope * x + y_intercept
    return math.abs(y - expected_y) < tolerance
end

-- Calculate perpendicular distance from point to line
-- Line defined by two points: (x1, y1) and (x2, y2)
function geometry.point_to_line_distance(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1

    if dx == 0 and dy == 0 then
        -- Line is actually a point
        return geometry.distance(px, py, x1, y1)
    end

    -- Calculate perpendicular distance using cross product formula
    local num = math.abs(dy * px - dx * py + x2 * y1 - y2 * x1)
    local den = math.sqrt(dx * dx + dy * dy)

    return num / den
end

-- Convert radians to degrees
function geometry.rad_to_deg(rad)
    return rad * 180 / math.pi
end

-- Convert degrees to radians
function geometry.deg_to_rad(deg)
    return deg * math.pi / 180
end

return geometry

-- lib/json.lua
-- Simple JSON parser for LOVE2D (using rxi/json.lua)
-- This is a minimal implementation - for production, use a library like dkjson or rxi/json.lua

local json = {}

-- Simple JSON decoder (handles basic JSON for our problem files)
function json.decode(str)
    -- Remove whitespace
    str = str:gsub("^%s*(.-)%s*$", "%1")

    -- Parse value
    local function parse_value(s, pos)
        pos = pos or 1

        -- Skip whitespace
        while pos <= #s and s:sub(pos, pos):match("%s") do
            pos = pos + 1
        end

        if pos > #s then return nil, pos end

        local char = s:sub(pos, pos)

        -- null
        if s:sub(pos, pos + 3) == "null" then
            return nil, pos + 4
        end

        -- true
        if s:sub(pos, pos + 3) == "true" then
            return true, pos + 4
        end

        -- false
        if s:sub(pos, pos + 4) == "false" then
            return false, pos + 5
        end

        -- number
        if char:match("[%-0-9]") then
            local num_str = s:match("^[%-]?[0-9]+%.?[0-9]*", pos)
            if num_str then
                return tonumber(num_str), pos + #num_str
            end
        end

        -- string
        if char == '"' then
            local str_end = pos + 1
            while str_end <= #s do
                if s:sub(str_end, str_end) == '"' and s:sub(str_end - 1, str_end - 1) ~= "\\" then
                    local str_val = s:sub(pos + 1, str_end - 1)
                    -- Unescape basic sequences
                    str_val = str_val:gsub("\\n", "\n")
                    str_val = str_val:gsub("\\t", "\t")
                    str_val = str_val:gsub('\\"', '"')
                    str_val = str_val:gsub("\\\\", "\\")
                    return str_val, str_end + 1
                end
                str_end = str_end + 1
            end
            error("Unterminated string")
        end

        -- array
        if char == "[" then
            local arr = {}
            pos = pos + 1

            while pos <= #s do
                -- Skip whitespace
                while pos <= #s and s:sub(pos, pos):match("%s") do
                    pos = pos + 1
                end

                if s:sub(pos, pos) == "]" then
                    return arr, pos + 1
                end

                local val, new_pos = parse_value(s, pos)
                table.insert(arr, val)
                pos = new_pos

                -- Skip whitespace
                while pos <= #s and s:sub(pos, pos):match("%s") do
                    pos = pos + 1
                end

                if s:sub(pos, pos) == "," then
                    pos = pos + 1
                elseif s:sub(pos, pos) == "]" then
                    return arr, pos + 1
                end
            end
            error("Unterminated array")
        end

        -- object
        if char == "{" then
            local obj = {}
            pos = pos + 1

            while pos <= #s do
                -- Skip whitespace
                while pos <= #s and s:sub(pos, pos):match("%s") do
                    pos = pos + 1
                end

                if s:sub(pos, pos) == "}" then
                    return obj, pos + 1
                end

                -- Parse key
                if s:sub(pos, pos) ~= '"' then
                    error("Expected string key")
                end
                local key, new_pos = parse_value(s, pos)
                pos = new_pos

                -- Skip whitespace and colon
                while pos <= #s and s:sub(pos, pos):match("%s") do
                    pos = pos + 1
                end
                if s:sub(pos, pos) ~= ":" then
                    error("Expected colon")
                end
                pos = pos + 1

                -- Parse value
                local val
                val, pos = parse_value(s, pos)
                obj[key] = val

                -- Skip whitespace
                while pos <= #s and s:sub(pos, pos):match("%s") do
                    pos = pos + 1
                end

                if s:sub(pos, pos) == "," then
                    pos = pos + 1
                elseif s:sub(pos, pos) == "}" then
                    return obj, pos + 1
                end
            end
            error("Unterminated object")
        end

        error("Unexpected character: " .. char)
    end

    local result, _ = parse_value(str)
    return result
end

return json

-- lib/i18n.lua
-- Internationalization system for CartesianPlayground
-- Supports multiple languages with simple key-value translations

local i18n = {}

-- Current language (default: English)
i18n.current_language = "en"

-- Available languages
i18n.languages = {"en", "es"}

-- Translation dictionaries
i18n.translations = {}

-- Load a language dictionary
function i18n.load_language(lang_code)
    local lang_file = "i18n/" .. lang_code
    local success, lang_module = pcall(require, lang_file)

    if success then
        i18n.translations[lang_code] = lang_module
        print("Loaded language: " .. lang_code)
        return true
    else
        print("Failed to load language: " .. lang_code)
        print("Error: " .. tostring(lang_module))
        return false
    end
end

-- Set the current language
function i18n.set_language(lang_code)
    if not i18n.translations[lang_code] then
        -- Try to load the language if not already loaded
        if not i18n.load_language(lang_code) then
            print("Language not available: " .. lang_code)
            return false
        end
    end

    i18n.current_language = lang_code
    print("Language set to: " .. lang_code)
    return true
end

-- Translate a key to the current language
-- Supports nested keys with dot notation: "menu.start"
-- Supports variable substitution: translate("greeting", {name = "Alice"})
function i18n.translate(key, vars)
    local lang = i18n.current_language
    local dict = i18n.translations[lang]

    if not dict then
        return "[" .. key .. "]"  -- Return key in brackets if language not loaded
    end

    -- Navigate nested keys
    local value = dict
    for part in string.gmatch(key, "[^%.]+") do
        value = value[part]
        if not value then
            -- Fallback to English if key not found
            if lang ~= "en" then
                dict = i18n.translations["en"]
                if dict then
                    value = dict
                    for fallback_part in string.gmatch(key, "[^%.]+") do
                        value = value[fallback_part]
                        if not value then break end
                    end
                end
            end

            if not value then
                return "[" .. key .. "]"  -- Key not found
            end
            break
        end
    end

    -- Convert to string if it's a function (for dynamic translations)
    if type(value) == "function" then
        value = value(vars or {})
    end

    -- Perform variable substitution
    if type(value) == "string" and vars then
        for k, v in pairs(vars) do
            value = string.gsub(value, "{" .. k .. "}", tostring(v))
        end
    end

    return value
end

-- Shorthand function
function i18n.t(key, vars)
    return i18n.translate(key, vars)
end

-- Get translation from a multi-language table
-- Takes a table like {en = "Hello", es = "Hola"} and returns the value for current language
function i18n.get_translation(translation_table)
    if type(translation_table) ~= "table" then
        return tostring(translation_table)
    end

    -- Try current language
    local value = translation_table[i18n.current_language]
    if value then
        return value
    end

    -- Fallback to English
    if i18n.current_language ~= "en" and translation_table.en then
        return translation_table.en
    end

    -- Return first available translation
    for _, v in pairs(translation_table) do
        if type(v) == "string" then
            return v
        end
    end

    return "[translation missing]"
end

-- Get available languages
function i18n.get_languages()
    return i18n.languages
end

-- Get current language name
function i18n.get_current_language_name()
    local dict = i18n.translations[i18n.current_language]
    if dict and dict._language_name then
        return dict._language_name
    end
    return i18n.current_language
end

-- Initialize: load default language
i18n.load_language("en")

return i18n

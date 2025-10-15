-- main.lua
local config = require 'config'
local Slab = require 'lib.Slab'
local Gamestate = require 'lib.gamestate'
local i18n = require 'lib.i18n'

-- Load states
local playground = require 'states.playground'
local problem_menu = require 'states.problem_menu_state'

function love.load()
    -- Set window title
    love.window.setTitle("Playground Cartesiano")

    -- Initialize Slab
    Slab.Initialize({})

    -- Load default language
    i18n.load_language("en")

    -- Start with playground state
    Gamestate.registerEvents()
    Gamestate.switch(playground)
end

function love.update(dt)
    -- Update Slab first
    Slab.Update(dt)

    -- Header menu bar
    Slab.BeginWindow('HeaderMenu', {
        Title = "",
        X = 0,
        Y = 0,
        W = love.graphics.getWidth(),
        H = config.HEADER_SIZE,
        AllowResize = false,
        AllowMove = false,
        AutoSizeWindow = false,
        ShowTitle = false,
        BgColor = {0.08, 0.08, 0.08, 1.0},
        Border = 0
    })

    -- Menu buttons
    if Slab.Button("intro") then
        Gamestate.switch(playground)
    end

    Slab.SameLine()

    if Slab.Button("point") then
        if Gamestate.current() ~= playground then
            Gamestate.switch(playground)
        end
        playground.selected_button = "point"
    end

    Slab.SameLine()

    if Slab.Button("line") then
        if Gamestate.current() ~= playground then
            Gamestate.switch(playground)
        end
        playground.selected_button = "line"
    end

    Slab.SameLine()

    if Slab.Button("problems") then
        Gamestate.switch(problem_menu)
    end

    Slab.EndWindow()
end

function love.draw()
    -- Gamestate handles drawing current state
    -- This is already handled by Gamestate.registerEvents()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

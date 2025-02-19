--[[
    CensuraDev Components Module
    Version: 4.1
    
    Modern military-tech inspired UI components
]]

local Components = {}

-- Load UI Elements
local function LoadElement(name)
    local success, module = pcall(function()
        return loadstring(game:HttpGet(string.format(
            "https://raw.githubusercontent.com/LxckStxp/Censura/main/UIElements/%s.lua",
            name
        )))()
    end)
    
    if not success then
        warn(string.format("Failed to load %s: %s", name, module))
        return nil
    end
    
    return module
end

-- Initialize UI Elements
local Button = LoadElement("Button")
local Switch = LoadElement("Switch")
local Slider = LoadElement("Slider")

-- Verify Elements Loaded
assert(Button, "Button module failed to load")
assert(Switch, "Switch module failed to load")
assert(Slider, "Slider module failed to load")

-- Public Interface
function Components.createButton(parent, text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    return Button.new(parent, text, callback)
end

function Components.createToggle(parent, text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    return Switch.new(parent, text, default, callback)
end

function Components.createSlider(parent, text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    return Slider.new(parent, text, min, max, default, callback)
end

return Components

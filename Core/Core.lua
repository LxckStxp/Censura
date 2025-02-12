-- Core/Core.lua
local Core = {}
Core.__index = Core

function Core.new()
    local self = setmetatable({}, Core)
    
    -- Create ScreenGui container with high display order
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "Censura"
    self.gui.ResetOnSpawn = false
    self.gui.DisplayOrder = 999 -- Ensures UI appears above other GUIs
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Proper Z-index handling
    
    -- Handle CoreGui parenting
    local success, result = pcall(function()
        self.gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        _G.Censura.System.Oratio:Warn("Failed to parent to CoreGui, falling back to PlayerGui")
        self.gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.windows = {}
    
    return self
end

function Core:CreateWindow(options)
    local window = _G.Censura.Modules.Window.new(self.gui, options)
    table.insert(self.windows, window)
    return window
end

-- Example method to demonstrate high Z-index functionality
function Core:BringToFront(window)
    local highestIndex = 1
    for _, otherWindow in ipairs(self.windows) do
        if otherWindow.frame.ZIndex >= highestIndex then
            highestIndex = otherWindow.frame.ZIndex + 1
        end
    end
    window.frame.ZIndex = highestIndex
end

return Core

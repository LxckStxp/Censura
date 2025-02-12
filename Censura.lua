-- Check If Censura Exists
if _G.Censura then
    print(string.rep("\n", 30))
    print("Censura Detected. Removing existing instance.")
    _G.Censura = nil
end

-- Establish Global Censura Table
_G.Censura = {
    Version = "1.0.0",
    Git = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
    System = {},      -- System Functions Storage
    Modules = {},     -- Core Module Storage (non-elements)
    Elements = {}     -- UI Elements Storage (subtable for UI elements)
}

local Cens = _G.Censura
local Sys = Cens.System

-- Initialize logging (using Oratio)
Sys.Oratio = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua", true))()
Ora = Sys.Oratio.Logger.new({
    moduleName = "Censura"
})

Cens.Messages = {
    Clear = string.rep("\n", 30),
    Splash = [[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      a88888b.                                                       
      d8'   `88                                                       
      88        .d8888b. 88d888b. .d8888b. dP    dP 88d888b. .d8888b. 
      88        88ooood8 88'  `88 Y8ooooo. 88    88 88'  `88 88'  `88 
      Y8.   .88 88.  ... 88    88       88 88.  .88 88       88.  .88 
       Y88888P' `88888P' dP    dP `88888P' `88888P' dP       `88888P8  v%s

By LxckStxp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
}

-- Function to Load Modules
Sys.LoadModule = function(module)
    local url = Cens.Git .. module .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not success then
        Ora:Error("Failed to load module from " .. url .. ": " .. tostring(result))
    else
        Ora:Info("Loaded " .. module)
    end
    return result
end

-- System Initialization: Load All Core Modules and UI Element Modules
Sys.Init = function()
    print(string.format(Cens.Messages.Clear .. Cens.Messages.Splash .. "\n", Cens.Version))
    Ora:Info("Loading Core Modules\n")

    -- Define module load order in dependency order
    local moduleLoadOrder = {
        -- Base modules (loaded into Cens.Modules)
        "Core/Utils",
        "Core/Styles",

        -- UI Elements (loaded into Cens.Elements)
        "Core/Elements/Window",
        "Core/Elements/Button",
        "Core/Elements/Label",
        "Core/Elements/Toggle",
        "Core/Elements/Slider",
        "Core/Elements/Input",
        "Core/Elements/ColorPicker",
        "Core/Elements/Keybind",
        "Core/Elements/List",
        "Core/Elements/Section",
        "Core/Elements/TabSystem",
        "Core/Elements/Notification"
    }

    for _, modulePath in ipairs(moduleLoadOrder) do
        local moduleName = modulePath:match("[^/]+$")  -- extract filename (module name)
        local result = Sys.LoadModule(modulePath)
        if result then
            if modulePath:find("Elements/") then
                Cens.Elements[moduleName] = result
                Ora:Info(string.format("Loaded UI Element: %s", moduleName))
            else
                Cens.Modules[moduleName] = result
                Ora:Info(string.format("Loaded Core Module: %s", moduleName))
            end
        else
            Ora:Error(string.format("Failed to load module: %s", modulePath))
        end
    end

    -- Create a main GUI container for any notifications or floating UI elements.
    Cens.GUI = Instance.new("ScreenGui")
    Cens.GUI.Name = "CensuraGUI"
    Cens.GUI.ResetOnSpawn = false
    Cens.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Cens.GUI.DisplayOrder = 999

    local success, result = pcall(function()
        Cens.GUI.Parent = game:GetService("CoreGui")
    end)
    if not success then
        Ora:Warn("Failed to parent to CoreGui, falling back to PlayerGui")
        Cens.GUI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    Ora:Info("Initialization Complete!")
end

-- Run our initialization function
Sys.Init()

--[[
    Censura UI System
    Author: LxckStxp
    Version: 2.0.0
    
    Example Usage:
    
    local Censura = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/Censura.lua"))()
    
    local window = Censura:CreateWindow("Example")
    
    -- Create a section
    local section = window:AddSection("Controls")
    
    -- Add elements
    section:AddButton("Click Me", function()
        print("Button clicked!")
    end)
    
    section:AddToggle("Enable ESP", false, function(enabled)
        print("ESP:", enabled)
    end)
    
    section:AddSlider("Speed", 0, 100, 50, function(value)
        print("Speed:", value)
    end)
--]]

-- Check for existing instance
if _G.Censura then
    _G.Censura = nil
end

-- Initialize Censura
local Censura = {
    Version = "2.0.0",
    Windows = {},
    Git = {
        Base = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
        Components = "https://raw.githubusercontent.com/LxckStxp/Censura/main/Components.lua",
        Styles = "https://raw.githubusercontent.com/LxckStxp/Censura/main/Styles.lua",
        Oratio = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua"
    },
    System = {},
    Messages = {
        Clear = string.rep("\n", 30),
        Splash = [[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      a88888b.                                                       
      d8'   `88                                                       
      88        .d8888b. 88d888b. .d8888b. dP    dP 88d888b. .d8888b. 
      88        88ooood8 88'  `88 Y8ooooo. 88    88 88'  `88 88'  `88 
      Y8.   .88 88.  ... 88    88       88 88.  .88 88       88.  .88 
       Y88888P' `88888P' dP    dP `88888P' `88888P' dP       `88888P8  v%s

                            - By LxckStxp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
    }
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Load Dependencies
local function LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("Failed to load module from", url, "Error:", result)
        return nil
    end
    
    return result
end

-- Initialize Core Systems
Censura.System.Oratio = LoadModule(Censura.Git.Oratio)
Censura.System.Styles = LoadModule(Censura.Git.Styles)
Censura.System.Components = LoadModule(Censura.Git.Components)

local Logger = Censura.System.Oratio.Logger.new({
    moduleName = "Censura"
})

-- Display Splash
print(string.format(Censura.Messages.Clear .. Censura.Messages.Splash .. "\n", Censura.Version))
Logger:Info("Initializing Censura UI System...")

-- Window Creation
function Censura:CreateWindow(title)
    Logger:Info("Creating window: " .. title)
    
    local window = {
        Elements = {},
        Visible = true
    }
    
    -- Create main window frame using Components
    window.Frame = self.System.Components.Window({
        title = title,
        parent = self.GUI
    })
    
    -- Add window methods
    function window:AddSection(title)
        local section, content = Censura.System.Components.Section({
            title = title,
            parent = window.Frame.Content
        })
        
        -- Add element creation methods to section
        function section:AddButton(text, callback)
            return Censura.System.Components.Button({
                text = text,
                callback = callback,
                parent = content
            })
        end
        
        function section:AddToggle(text, default, callback)
            return Censura.System.Components.Toggle({
                text = text,
                default = default,
                callback = callback,
                parent = content
            })
        end
        
        function section:AddSlider(text, min, max, default, callback)
            return Censura.System.Components.Slider({
                text = text,
                min = min,
                max = max,
                default = default,
                callback = callback,
                parent = content
            })
        end
        
        function section:AddLabel(text, options)
            return Censura.System.Components.Label({
                text = text,
                parent = content,
                ...options
            })
        end
        
        return section
    end
    
    -- Window visibility methods
    function window:Show()
        window.Frame.Visible = true
        window.Visible = true
        Logger:Debug("Window shown: " .. title)
    end
    
    function window:Hide()
        window.Frame.Visible = false
        window.Visible = false
        Logger:Debug("Window hidden: " .. title)
    end
    
    function window:Toggle()
        window.Visible = not window.Visible
        window.Frame.Visible = window.Visible
        Logger:Debug("Window toggled: " .. title)
    end
    
    table.insert(self.Windows, window)
    return window
end

-- Initialize Censura
function Censura:Initialize()
    Logger:Info("Initializing Censura UI System...")
    
    -- Create GUI Container
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "CensuraGUI"
    self.GUI.ResetOnSpawn = false
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.DisplayOrder = 999
    
    -- Try to parent to CoreGui
    local success = pcall(function()
        self.GUI.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        Logger:Warn("Failed to parent to CoreGui, falling back to PlayerGui")
        self.GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup global toggle
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            for _, window in ipairs(self.Windows) do
                window:Toggle()
            end
        end
    end)
    
    Logger:Info("Initialization Complete!")
    return self
end

-- Example Usage Demonstration
--[[
local UI = Censura:Initialize()

-- Create a window
local window = UI:CreateWindow("Example Window")

-- Create a section
local section = window:AddSection("Controls")

-- Add various elements
section:AddButton("Click Me", function()
    print("Button clicked!")
end)

section:AddToggle("Enable Feature", false, function(enabled)
    print("Feature:", enabled)
end)

section:AddSlider("Speed", 0, 100, 50, function(value)
    print("Speed:", value)
end)

section:AddLabel("This is a label")

-- Create another section
local settings = window:AddSection("Settings")

settings:AddToggle("Auto Save", true, function(enabled)
    print("Auto Save:", enabled)
end)
--]]

_G.Censura = Censura
return Censura:Initialize()

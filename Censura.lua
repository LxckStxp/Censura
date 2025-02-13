--[[
    Censura UI System
    Author: LxckStxp
    Version: 2.0.0
--]]

-- Reset existing instance
if _G.Censura then
    pcall(function() _G.Censura.GUI:Destroy() end)
    _G.Censura = nil
end

-- Core Censura Framework
local Censura = {
    Version = "2.0.0",
    Windows = {},
    Config = {
        DefaultTheme = "Dark",
        ToggleKey = Enum.KeyCode.RightControl,
        DisplayOrder = 999,
        Debug = true
    },
    Git = {
        Base = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
        Core = {
            Components = "Components.lua",
            Styles = "Styles.lua",
            Oratio = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua"
        }
    },
    System = {
        Cache = {},
        Events = {},
        Active = {
            Elements = {},
            Connections = {}
        }
    },
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
local Services = {
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService")
}

-- Utility Functions
local Utility = {
    LoadModule = function(url)
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        return success and result or nil
    end,
    
    SafeDestroy = function(instance)
        if instance and typeof(instance) == "Instance" then
            instance:Destroy()
        end
    end,
    
    Connect = function(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(Censura.System.Active.Connections, connection)
        return connection
    end,
    
    DisconnectAll = function()
        for _, connection in ipairs(Censura.System.Active.Connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
        Censura.System.Active.Connections = {}
    end
}

-- Core System Initialization
local function InitializeCore()
    -- Load Dependencies
    Censura.System.Oratio = Utility.LoadModule(Censura.Git.Core.Oratio)
    if not Censura.System.Oratio then
        error("Failed to load Oratio logging system")
    end
    
    Censura.Logger = Censura.System.Oratio.Logger.new({
        moduleName = "Censura",
        debug = Censura.Config.Debug
    })
    
    -- Load Core Modules
    for name, path in pairs(Censura.Git.Core) do
        if name ~= "Oratio" then
            local url = Censura.Git.Base .. path
            local module = Utility.LoadModule(url)
            
            if module then
                Censura.System[name] = module
                Censura.Logger:Info(string.format("Loaded %s module", name))
            else
                Censura.Logger:Error(string.format("Failed to load %s module", name))
                return false
            end
        end
    end
    
    return true
end

-- Window Creation
local function CreateWindow(options)
    options = type(options) == "table" and options or {title = options}
    local window = {
        Elements = {},
        Visible = true,
        Options = options
    }
    
    window.Frame = Censura.System.Components.Window({
        title = options.title,
        parent = Censura.GUI,
        theme = options.theme or Censura.Config.DefaultTheme,
        position = options.position,
        size = options.size
    })
    
    -- Add Section
    local function AddSection(title)
        local section, content = Censura.System.Components.Section({
            title = title,
            parent = window.Frame.Content
        })
        
        -- Element Types
        local elementTypes = {
            Button = "Button",
            Toggle = "Toggle",
            Slider = "Slider",
            Label = "Label",
            Dropdown = "Dropdown",
            ColorPicker = "ColorPicker",
            KeyBind = "KeyBind",
            TextBox = "TextBox"
        }
        
        -- Add Element Creation Functions
        for name, componentType in pairs(elementTypes) do
            section["Add" .. name] = function(options)
                local element = Censura.System.Components[componentType](options)
                table.insert(window.Elements, element)
                return element
            end
        end
        
        return section
    end
    
    -- Visibility Functions
    window.Show = function()
        window.Frame.Visible = true
        window.Visible = true
    end
    
    window.Hide = function()
        window.Frame.Visible = false
        window.Visible = false
    end
    
    window.Toggle = function()
        window.Visible = not window.Visible
        window.Frame.Visible = window.Visible
    end
    
    window.AddSection = AddSection
    
    table.insert(Censura.Windows, window)
    return window
end

-- Initialize Framework
local function Initialize()
    Censura.Logger:Info("Initializing Censura UI System...")
    print(string.format(Censura.Messages.Clear .. Censura.Messages.Splash, Censura.Version))
    
    if not InitializeCore() then
        Censura.Logger:Error("Failed to initialize core systems")
        return false
    end
    
    -- Create GUI Container
    Censura.GUI = Instance.new("ScreenGui")
    Censura.GUI.Name = "CensuraGUI"
    Censura.GUI.ResetOnSpawn = false
    Censura.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Censura.GUI.DisplayOrder = Censura.Config.DisplayOrder
    
    -- Parent GUI
    local success = pcall(function()
        Censura.GUI.Parent = Services.CoreGui
    end)
    
    if not success then
        Censura.Logger:Warn("Failed to parent to CoreGui, using PlayerGui")
        Censura.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup Global Toggle
    Utility.Connect(Services.UserInput.InputBegan, function(input)
        if input.KeyCode == Censura.Config.ToggleKey then
            for _, window in ipairs(Censura.Windows) do
                window.Toggle()
            end
        end
    end)
    
    Censura.Logger:Info("Initialization Complete!")
    return true
end

-- Cleanup
local function Destroy()
    Utility.DisconnectAll()
    Utility.SafeDestroy(Censura.GUI)
    _G.Censura = nil
end

-- API
Censura.CreateWindow = CreateWindow
Censura.Initialize = Initialize
Censura.Destroy = Destroy

-- Set Global Reference
_G.Censura = Censura

-- Initialize and Return
return Initialize() and Censura

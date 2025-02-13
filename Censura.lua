--[[
    Censura UI System
    Author: LxckStxp
    Version: 2.0.0
]]

-- Load Oratio Logger
local Oratio = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua"))()
local Logger = Oratio.Logger.new({
    moduleName = "Censura",
    formatter = function(moduleName, level, message)
        return string.format("[ %s ] [ %s ] %s", moduleName, level, message)
    end
})

-- Reset existing instance
if _G.Censura then
    Logger:Info("Cleaning up existing Censura instance...")
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
            Components = "Core/Components.lua",
            Styles = "Core/Styles.lua"
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
        Logger:Debug("Loading module from: " .. url)
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if not success then
            Logger:Error("Failed to load module: " .. tostring(result))
            return nil
        end
        
        Logger:Info("Successfully loaded module")
        return result
    end,
    
    SafeDestroy = function(instance)
        if instance and typeof(instance) == "Instance" then
            Logger:Debug("Destroying instance: " .. instance.Name)
            instance:Destroy()
        end
    end,
    
    Connect = function(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(Censura.System.Active.Connections, connection)
        return connection
    end,
    
    DisconnectAll = function()
        Logger:Debug("Disconnecting all active connections")
        for _, connection in ipairs(Censura.System.Active.Connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
        Censura.System.Active.Connections = {}
    end
}

-- Module Loading
local function LoadCoreModules()
    Logger:Info("Loading core modules...")
    
    -- Load Styles first
    local stylesUrl = Censura.Git.Base .. Censura.Git.Core.Styles
    local styles = Utility.LoadModule(stylesUrl)
    if not styles then
        Logger:Error("Failed to load Styles module")
        return false
    end
    Censura.System.Styles = styles
    Logger:Info("Loaded Styles module")

    -- Then load Components
    local componentsUrl = Censura.Git.Base .. Censura.Git.Core.Components
    local components = Utility.LoadModule(componentsUrl)
    if not components then
        Logger:Error("Failed to load Components module")
        return false
    end
    Censura.System.Components = components
    Logger:Info("Loaded Components module")
    
    return true
end

-- Window Creation
local function CreateWindow(options)
    Logger:Debug("Creating new window with options: " .. game:GetService("HttpService"):JSONEncode(options))
    
    options = type(options) == "table" and options or {title = options}
    local window = {
        Elements = {},
        Visible = true,
        Options = options
    }
    
    -- Create window frame
    window.Frame = Censura.System.Components.Window({
        title = options.title,
        parent = Censura.GUI,
        theme = options.theme or Censura.Config.DefaultTheme,
        position = options.position,
        size = options.size
    })
    
    -- Section Creation
    window.AddSection = function(title)
        Logger:Debug("Adding section: " .. title)
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
                Logger:Debug("Adding " .. name .. " element")
                local element = Censura.System.Components[componentType](options)
                table.insert(window.Elements, element)
                return element
            end
        end
        
        return section
    end
    
    -- Window Controls
    window.Show = function()
        Logger:Debug("Showing window: " .. options.title)
        window.Frame.Visible = true
        window.Visible = true
    end
    
    window.Hide = function()
        Logger:Debug("Hiding window: " .. options.title)
        window.Frame.Visible = false
        window.Visible = false
    end
    
    window.Toggle = function()
        window.Visible = not window.Visible
        window.Frame.Visible = window.Visible
        Logger:Debug("Toggled window: " .. options.title .. " (" .. tostring(window.Visible) .. ")")
    end
    
    table.insert(Censura.Windows, window)
    return window
end

-- Initialize Framework
local function Initialize()
    Logger:Info("Initializing Censura UI System v" .. Censura.Version)
    print(string.format(Censura.Messages.Clear .. Censura.Messages.Splash, Censura.Version))
    
    if not LoadCoreModules() then
        Logger:Error("Failed to initialize core systems")
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
        Logger:Warn("Failed to parent to CoreGui, using PlayerGui")
        Censura.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup Global Toggle
    Utility.Connect(Services.UserInput.InputBegan, function(input)
        if input.KeyCode == Censura.Config.ToggleKey then
            Logger:Debug("Global toggle activated")
            for _, window in ipairs(Censura.Windows) do
                window.Toggle()
            end
        end
    end)
    
    Logger:Info("Initialization Complete!")
    return true
end

-- Cleanup
local function Destroy()
    Logger:Info("Cleaning up Censura...")
    Utility.DisconnectAll()
    Utility.SafeDestroy(Censura.GUI)
    _G.Censura = nil
    Logger:Info("Cleanup complete")
end

-- API
Censura.CreateWindow = CreateWindow
Censura.Initialize = Initialize
Censura.Destroy = Destroy

-- Set Global Reference
_G.Censura = Censura

-- Initialize and Return
return Initialize() and Censura

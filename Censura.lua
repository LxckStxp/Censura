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
    
    local Logger = Censura.System.Oratio.Logger.new({
        moduleName = "Censura",
        debug = Censura.Config.Debug
    })
    Censura.Logger = Logger
    
    -- Load Core Modules
    for name, path in pairs(Censura.Git.Core) do
        if name ~= "Oratio" then
            local url = Censura.Git.Base .. path
            local module = Utility.LoadModule(url)
            
            if module then
                Censura.System[name] = module
                Logger:Info(string.format("Loaded %s module", name))
            else
                Logger:Error(string.format("Failed to load %s module", name))
                return false
            end
        end
    end
    
    return true
end

-- Window Factory
function Censura:CreateWindow(options)
    options = type(options) == "table" and options or {title = options}
    local window = {
        Elements = {},
        Visible = true,
        Options = options
    }
    
    -- Create window instance
    window.Frame = self.System.Components.Window({
        title = options.title,
        parent = self.GUI,
        theme = options.theme or self.Config.DefaultTheme,
        position = options.position,
        size = options.size
    })
    
    -- Window Methods
    function window:AddSection(title)
        local section, content = Censura.System.Components.Section({
            title = title,
            parent = window.Frame.Content
        })
        
        -- Element Creation Methods
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
        
        for name, componentType in pairs(elementTypes) do
            section["Add" .. name] = function(self, ...)
                local element = Censura.System.Components[componentType](...)
                table.insert(window.Elements, element)
                return element
            end
        end
        
        return section
    end
    
    -- Visibility Methods
    local visibilityMethods = {
        Show = function(self) self.Frame.Visible = true; self.Visible = true end,
        Hide = function(self) self.Frame.Visible = false; self.Visible = false end,
        Toggle = function(self) self.Visible = not self.Visible; self.Frame.Visible = self.Visible end
    }
    
    for name, func in pairs(visibilityMethods) do
        window[name] = func
    end
    
    table.insert(self.Windows, window)
    return window
end

-- Initialize Framework
function Censura:Initialize()
    self.Logger:Info("Initializing Censura UI System...")
    print(string.format(self.Messages.Clear .. self.Messages.Splash, self.Version))
    
    -- Initialize Core Systems
    if not InitializeCore() then
        self.Logger:Error("Failed to initialize core systems")
        return false
    end
    
    -- Create GUI Container
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "CensuraGUI"
    self.GUI.ResetOnSpawn = false
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.DisplayOrder = self.Config.DisplayOrder
    
    -- Parent GUI
    local success = pcall(function()
        self.GUI.Parent = Services.CoreGui
    end)
    
    if not success then
        self.Logger:Warn("Failed to parent to CoreGui, using PlayerGui")
        self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup Global Toggle
    Utility.Connect(Services.UserInput.InputBegan, function(input)
        if input.KeyCode == self.Config.ToggleKey then
            for _, window in ipairs(self.Windows) do
                window:Toggle()
            end
        end
    end)
    
    self.Logger:Info("Initialization Complete!")
    return self
end

-- Cleanup Method
function Censura:Destroy()
    Utility.DisconnectAll()
    Utility.SafeDestroy(self.GUI)
    _G.Censura = nil
end

-- Set Global Reference
_G.Censura = Censura

-- Initialize and Return
return Censura:Initialize()

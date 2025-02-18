--[[
    CensuraDev UI Library
    Version: 4.2
    Author: LxckStxp
    
    A modern, lightweight UI library for Roblox
    with optimized performance and enhanced features
]]

-- Initialize Logger
local Oratio = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua", true))()
local logger = Oratio.Logger.new({
    moduleName = "CensuraDev",
    minLevel = 1
})

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
}

-- Global Configuration
getgenv().CensuraSystem = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(35, 35, 50),
        Text = Color3.fromRGB(240, 240, 245),
        Highlight = Color3.fromRGB(50, 50, 70),
        Enabled = Color3.fromRGB(98, 150, 255),
        Disabled = Color3.fromRGB(255, 75, 95),
        Border = Color3.fromRGB(60, 60, 80),
        SecondaryText = Color3.fromRGB(180, 180, 190)
    },
    UI = {
        WindowSize = UDim2.new(0, 300, 0, 400),
        TitleBarSize = UDim2.new(1, 0, 0, 40),
        ContentPadding = UDim2.new(0, 5, 0, 45),
        ButtonSize = UDim2.new(1, -16, 0, 36),
        ToggleSize = UDim2.new(0, 26, 0, 26),
        SliderSize = UDim2.new(1, -16, 0, 50),
        CornerRadius = UDim.new(0, 6),
        Padding = UDim.new(0, 8),
        ElementSpacing = UDim.new(0, 8),
        Transparency = {
            Background = 0.05,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        }
    },
    Animation = {
        TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        DragSmoothing = 0.05
    },
    Settings = {
        DefaultTitle = "Censura",
        ToggleKey = Enum.KeyCode.RightAlt,
        Version = "4.2"
    }
}

-- Load External Modules
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Main Constructor
function CensuraDev.new(title, options)
    local self = setmetatable({}, CensuraDev)
    
    self.Elements = {}
    self.Connections = {}
    self.Visible = true
    self.Title = title or CensuraSystem.Settings.DefaultTitle
    self.Options = options or {}
    
    local success, err = pcall(function()
        self:Initialize()
    end)
    
    if not success then
        logger:Error("Failed to initialize UI: " .. tostring(err))
        return nil
    end
    
    logger:Info(string.format("UI initialized: %s", self.Title))
    return self
end

function CensuraDev:Initialize()
    self:CreateBaseGUI()
    self:SetupWindowBehavior()
    self:ApplyCustomOptions()
end

function CensuraDev:CreateBaseGUI()
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Services.CoreGui
    })
    
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = CensuraSystem.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = CensuraSystem.Colors.Background,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Background,
        Parent = self.GUI
    })
    
    Functions.setupWindow(self.MainFrame, {
        gradient = true,
        stroke = true,
        shadow = self.Options.shadow ~= false
    })
    
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = CensuraSystem.UI.TitleBarSize,
        BackgroundColor3 = CensuraSystem.Colors.Accent,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Accent,
        Parent = self.MainFrame
    })
    
    Create("UICorner", {
        Parent = self.TitleBar,
        CornerRadius = CensuraSystem.UI.CornerRadius
    })
    
    self.TitleText = Create("TextLabel", {
        Text = self.Title,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CensuraSystem.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = self.TitleBar
    })
    
    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Position = CensuraSystem.UI.ContentPadding,
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CensuraSystem.Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    
    Create("UIListLayout", {
        Parent = self.ContentFrame,
        Padding = CensuraSystem.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
end

function CensuraDev:SetupWindowBehavior()
    local dragHandler = Functions.setupDragging(self.TitleBar, self.MainFrame, {
        smoothing = CensuraSystem.Animation.DragSmoothing,
        bounds = true
    })
    table.insert(self.Connections, dragHandler)
    
    local keybindHandler = Functions.setupKeybind(function()
        self:Toggle()
    end, self.Options.toggleKey or CensuraSystem.Settings.ToggleKey)
    table.insert(self.Connections, keybindHandler)
    
    local cleanupConnection = self.GUI.Parent.ChildRemoved:Connect(function(child)
        if child == self.GUI then
            self:Cleanup()
        end
    end)
    table.insert(self.Connections, {Disconnect = function() cleanupConnection:Disconnect() end})
end

function CensuraDev:ApplyCustomOptions()
    if self.Options.position then
        Functions.setWindowPosition(self.MainFrame, self.Options.position)
    end
    
    if self.Options.scale then
        Functions.scaleUI(self.MainFrame, self.Options.scale, {smooth = true})
    end
end

function CensuraDev:CreateButton(text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    
    local button = Components.createButton(self.ContentFrame, text, callback)
    table.insert(self.Elements, {Type = "Button", Instance = button})
    logger:Debug(string.format("Created button: %s", text))
    return button
end

function CensuraDev:CreateToggle(text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    
    local toggle = Components.createToggle(self.ContentFrame, text, default, callback)
    table.insert(self.Elements, {Type = "Toggle", Instance = toggle})
    logger:Debug(string.format("Created toggle: %s", text))
    return toggle
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    
    local slider = Components.createSlider(self.ContentFrame, text, min, max, default, callback)
    table.insert(self.Elements, {Type = "Slider", Instance = slider})
    logger:Debug(string.format("Created slider: %s", text))
    return slider
end

function CensuraDev:Show()
    if not self.Visible then
        self.Visible = true
        self.GUI.Enabled = true
        logger:Debug("UI shown")
    end
end

function CensuraDev:Hide()
    if self.Visible then
        self.Visible = false
        self.GUI.Enabled = false
        logger:Debug("UI hidden")
    end
end

function CensuraDev:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function CensuraDev:Cleanup()
    logger:Info("Cleaning up UI...")
    
    for _, connection in ipairs(self.Connections) do
        if typeof(connection) == "table" and connection.Disconnect then
            connection:Disconnect()
        end
    end
    
    for _, element in ipairs(self.Elements) do
        if element.Instance then
            element.Instance:Destroy()
        end
    end
    
    self.Elements = {}
    self.Connections = {}
    self.GUI:Destroy()
    
    logger:Info("UI cleanup complete")
end

return CensuraDev

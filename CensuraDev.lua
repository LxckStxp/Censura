--[[
    CensuraDev UI Library
    Version: 4.3
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

-- Core Setup
local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService")
}

-- Load External Modules
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()

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
    Settings = {
        DefaultTitle = "Censura",
        ToggleKey = Enum.KeyCode.RightAlt,
        Version = "4.3"
    }
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Element Queue System
local ElementQueue = {
    items = {},
    processing = false,
    
    add = function(self, element)
        table.insert(self.items, element)
        if not self.processing then
            self:process()
        end
    end,
    
    process = function(self)
        self.processing = true
        task.spawn(function()
            while #self.items > 0 do
                local element = table.remove(self.items, 1)
                if element.create then
                    element:create()
                end
                task.wait(0.03)
            end
            self.processing = false
        end)
    end
}

-- Main Constructor
function CensuraDev.new(title, options)
    local self = setmetatable({}, CensuraDev)
    
    self.Elements = {}
    self.Connections = {}
    self.Visible = true
    self.Title = title or CensuraSystem.Settings.DefaultTitle
    self.Options = options or {}
    self.Queue = setmetatable({}, {__index = ElementQueue})
    
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
end

function CensuraDev:CreateBaseGUI()
    -- Create ScreenGui
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Services.CoreGui
    })
    
    -- Create Main Frame
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = CensuraSystem.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = CensuraSystem.Colors.Background,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Background,
        Parent = self.GUI
    })
    
    -- Setup window decorations
    Functions.setupWindow(self.MainFrame, {
        gradient = true,
        stroke = true,
        shadow = self.Options.shadow ~= false
    })
    
    -- Create Title Bar
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
    
    -- Create Title Text
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
    
    -- Create Content Frame
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
    
    -- Add Layout
    Create("UIListLayout", {
        Parent = self.ContentFrame,
        Padding = CensuraSystem.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    -- Add Padding
    Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
end

function CensuraDev:SetupWindowBehavior()
    -- Dragging with bounds checking
    local dragHandler = Functions.setupDragging(self.TitleBar, self.MainFrame, {
        smoothing = 0.05,
        bounds = true
    })
    table.insert(self.Connections, dragHandler)
    
    -- Toggle visibility keybind
    local keybindHandler = Functions.setupKeybind(function()
        self:Toggle()
    end, self.Options.toggleKey or CensuraSystem.Settings.ToggleKey)
    table.insert(self.Connections, keybindHandler)
    
    -- Position handler
    if self.Options.position then
        Functions.setWindowPosition(self.MainFrame, self.Options.position)
    end
    
    -- Scale handler
    if self.Options.scale then
        Functions.scaleUI(self.MainFrame, self.Options.scale, {smooth = true})
    end
end

-- Element Creation Methods
function CensuraDev:CreateButton(text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    
    -- Create button through queue system
    self.Queue:add({
        create = function()
            local button = Components.createButton(self.ContentFrame, text, callback)
            if button then
                table.insert(self.Elements, {
                    Type = "Button",
                    Instance = button,
                    Text = text
                })
                logger:Debug(string.format("Created button: %s", text))
            end
            return button
        end
    })
    
    return true
end

function CensuraDev:CreateToggle(text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    
    -- Create toggle through queue system
    self.Queue:add({
        create = function()
            local toggle = Components.createToggle(self.ContentFrame, text, default, callback)
            if toggle then
                table.insert(self.Elements, {
                    Type = "Toggle",
                    Instance = toggle,
                    Text = text,
                    State = default
                })
                logger:Debug(string.format("Created toggle: %s", text))
            end
            return toggle
        end
    })
    
    return true
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    
    -- Create slider through queue system
    self.Queue:add({
        create = function()
            local slider = Components.createSlider(
                self.ContentFrame,
                text,
                min,
                max,
                default,
                callback
            )
            if slider then
                table.insert(self.Elements, {
                    Type = "Slider",
                    Instance = slider,
                    Text = text,
                    Value = default
                })
                logger:Debug(string.format("Created slider: %s", text))
            end
            return slider
        end
    })
    
    return true
end

-- Visibility Methods
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

-- Enhanced Cleanup Method
function CensuraDev:Cleanup()
    logger:Info("Starting UI cleanup...")
    
    -- Clear element queue
    self.Queue.items = {}
    self.Queue.processing = false
    
    -- Cleanup connections
    for _, connection in ipairs(self.Connections) do
        pcall(function()
            if typeof(connection) == "table" and connection.Disconnect then
                connection:Disconnect()
            end
        end)
    end
    
    -- Cleanup elements
    for _, element in ipairs(self.Elements) do
        pcall(function()
            if element.Instance then
                if element.Instance.Parent then
                    element.Instance.Parent = nil
                end
                element.Instance:Destroy()
            end
        end)
    end
    
    -- Clear tables
    self.Elements = {}
    self.Connections = {}
    
    -- Remove GUI
    pcall(function()
        if self.GUI and self.GUI.Parent then
            self.GUI:Destroy()
        end
    end)
    
    logger:Info("UI cleanup completed successfully")
end

return CensuraDev

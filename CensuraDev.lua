--[[
    CensuraDev UI Library
    Version: 3.1
    Author: LxckStxp
    
    A lightweight, modern UI library for Roblox exploits
    featuring smooth animations and customizable elements.
--]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Service Initialization
local Services = {
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService")
}

-- Load Components Module
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()

-- UI Configuration
local Config = {
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
    
    Window = {
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        Padding = UDim2.new(0, 10),
        ToggleKey = Enum.KeyCode.RightAlt,
        Animation = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    },
    
    Elements = {
        CornerRadius = UDim.new(0, 6),
        ButtonSize = UDim2.new(1, -16, 0, 36),
        ToggleSize = UDim2.new(0, 26, 0, 26),
        SliderSize = UDim2.new(1, -16, 0, 50),
        Spacing = UDim.new(0, 8),
        
        Transparency = {
            Background = 0.15,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        }
    },
    
    Text = {
        Font = {
            Title = Enum.Font.GothamBold,
            Element = Enum.Font.GothamMedium
        },
        Size = {
            Title = 18,
            Element = 14
        }
    }
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Main UI Creation
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Create Main Container
    self.GUI = CreateInstance("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false
    })
    
    self.MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = Config.Window.Size,
        Position = Config.Window.Position,
        BackgroundColor3 = Config.Colors.Background,
        BackgroundTransparency = Config.Elements.Transparency.Background,
        Parent = self.GUI
    })
    
    -- Apply Styling
    CreateInstance("UICorner", {
        CornerRadius = Config.Elements.CornerRadius,
        Parent = self.MainFrame
    })
    
    CreateInstance("UIStroke", {
        Color = Config.Colors.Border,
        Transparency = 0.7,
        Thickness = 1.5,
        Parent = self.MainFrame
    })
    
    -- Create Title Bar
    self.TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = Config.Elements.Transparency.Accent,
        Parent = self.MainFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = Config.Elements.CornerRadius,
        Parent = self.TitleBar
    })
    
    CreateInstance("TextLabel", {
        Text = "Censura",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Config.Colors.Text,
        Font = Config.Text.Font.Title,
        TextSize = Config.Text.Size.Title,
        Parent = self.TitleBar
    })
    
    -- Create Content Container
    self.ContentFrame = CreateInstance("ScrollingFrame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -10, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    
    CreateInstance("UIListLayout", {
        Padding = Config.Elements.Spacing,
        Parent = self.ContentFrame
    })
    
    -- Initialize Dragging
    Components.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Setup Toggle Functionality
    self.Visible = true
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Config.Window.ToggleKey then
            self:Toggle()
        end
    end)
    
    return self
end

-- UI Element Creation Methods
function CensuraDev:CreateButton(text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    
    return Components.createButton(
        self.ContentFrame,
        text,
        callback,
        Config.Colors,
        Config.Elements,
        Services.TweenService
    )
end

function CensuraDev:CreateToggle(text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    
    return Components.createToggle(
        self.ContentFrame,
        text,
        default,
        callback,
        Config.Colors,
        Config.Elements,
        Services.TweenService
    )
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    
    return Components.createSlider(
        self.ContentFrame,
        text,
        min,
        max,
        default,
        callback,
        Config.Colors,
        Config.Elements,
        Services.TweenService,
        Services.UserInputService,
        Services.RunService
    )
end

-- Visibility Methods
function CensuraDev:Show()
    self.GUI.Parent = Services.CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
    
    Services.TweenService:Create(
        self.MainFrame, 
        Config.Window.Animation,
        {BackgroundTransparency = Config.Elements.Transparency.Background}
    ):Play()
end

function CensuraDev:Hide()
    Services.TweenService:Create(
        self.MainFrame,
        Config.Window.Animation,
        {BackgroundTransparency = 1}
    ):Play()
    
    task.wait(Config.Window.Animation.Time)
    self.Visible = false
    self.MainFrame.Visible = false
end

function CensuraDev:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

return CensuraDev

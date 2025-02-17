--[[
    CensuraDev UI Library
    Modern, Semi-Transparent Theme
    Version 2.0
--]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Load Components
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()

-- Modern Color Scheme
local COLORS = {
    BACKGROUND = Color3.fromRGB(15, 15, 25),
    ACCENT = Color3.fromRGB(30, 30, 45),
    TEXT = Color3.fromRGB(255, 255, 255),
    HIGHLIGHT = Color3.fromRGB(45, 45, 65),
    ENABLED = Color3.fromRGB(126, 131, 255),
    DISABLED = Color3.fromRGB(255, 85, 85),
    GRADIENT_START = Color3.fromRGB(20, 20, 35),
    GRADIENT_END = Color3.fromRGB(30, 30, 45)
}

-- UI Configuration
local UI_SETTINGS = {
    CORNER_RADIUS = UDim.new(0, 8),
    PADDING = UDim.new(0, 6),
    BUTTON_SIZE = UDim2.new(1, -12, 0, 32),
    TOGGLE_SIZE = UDim2.new(0, 24, 0, 24),
    SLIDER_SIZE = UDim2.new(1, -12, 0, 45),
    TRANSPARENCY = {
        BACKGROUND = 0.2,
        ACCENT = 0.1,
        TEXT = 0,
        ELEMENTS = 0.05
    }
}

-- Create New UI Instance
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CensuraUI"
    self.ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 300, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    self.MainFrame.BackgroundColor3 = COLORS.BACKGROUND
    self.MainFrame.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.BACKGROUND
    self.MainFrame.Parent = self.ScreenGui
    
    -- Main Frame Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.GRADIENT_START),
        ColorSequenceKeypoint.new(1, COLORS.GRADIENT_END)
    })
    gradient.Rotation = 45
    gradient.Parent = self.MainFrame
    
    -- Main Frame Corner and Stroke
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = self.MainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.ACCENT
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 32)
    self.TitleBar.BackgroundColor3 = COLORS.ACCENT
    self.TitleBar.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ACCENT
    self.TitleBar.Parent = self.MainFrame
    
    -- Title Bar Gradient
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.ACCENT),
        ColorSequenceKeypoint.new(1, COLORS.HIGHLIGHT)
    })
    titleGradient.Rotation = 90
    titleGradient.Parent = self.TitleBar
    
    -- Title Bar Corner
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    titleCorner.Parent = self.TitleBar
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Text = "Censura"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = self.TitleBar
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -45)
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 35)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ScrollBarThickness = 2
    self.ContentFrame.ScrollBarImageColor3 = COLORS.ACCENT
    self.ContentFrame.Parent = self.MainFrame
    
    -- Content Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UI_SETTINGS.PADDING
    listLayout.Parent = self.ContentFrame
    
    -- Initialize Dragging
    Components.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Visibility Toggle
    self.Visible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end)
    
    return self
end

-- Create Button using Components
function CensuraDev:CreateButton(text, callback)
    return Components.createButton(
        self.ContentFrame,
        text,
        callback,
        COLORS,
        UI_SETTINGS,
        TweenService
    )
end

-- Create Toggle using Components
function CensuraDev:CreateToggle(text, default, callback)
    return Components.createToggle(
        self.ContentFrame,
        text,
        default,
        callback,
        COLORS,
        UI_SETTINGS,
        TweenService
    )
end

-- Create Slider using Components
function CensuraDev:CreateSlider(text, min, max, default, callback)
    return Components.createSlider(
        self.ContentFrame,
        text,
        min,
        max,
        default,
        callback,
        COLORS,
        UI_SETTINGS,
        TweenService,
        UserInputService,
        RunService
    )
end

-- Show/Hide Methods
function CensuraDev:Show()
    self.ScreenGui.Parent = CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
    
    self.MainFrame.BackgroundTransparency = 1
    TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.BACKGROUND
    }):Play()
end

function CensuraDev:Hide()
    TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.2)
    self.Visible = false
    self.MainFrame.Visible = false
end

return CensuraDev

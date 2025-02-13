--[[
    Censura UI System
    Author: LxckStxp
    Version: 2.0.0
    
    A lightweight, modular UI system for Roblox exploits
    with integrated logging through Oratio
--]]

-- Check for existing instance and clean up
if _G.Censura then
    _G.Censura = nil
end

-- Main Censura table
local Censura = {
    Version = "2.0.0",
    Windows = {},
    Git = {
        Censura = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
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
    },
    Settings = {
        Colors = {
            Background = Color3.fromRGB(25, 25, 25),
            TitleBar = Color3.fromRGB(30, 30, 30),
            Text = Color3.fromRGB(255, 255, 255),
            TextDim = Color3.fromRGB(200, 200, 200),
            Accent = Color3.fromRGB(90, 90, 255),
            Button = Color3.fromRGB(45, 45, 45),
            ButtonHover = Color3.fromRGB(55, 55, 55),
            Toggle = Color3.fromRGB(40, 40, 40),
            ToggleEnabled = Color3.fromRGB(90, 90, 255),
            Slider = Color3.fromRGB(40, 40, 40),
            SliderFill = Color3.fromRGB(90, 90, 255)
        },
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Padding = 5
    }
}

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Initialize Oratio Logger
local function InitializeOratio()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(Censura.Git.Oratio))()
    end)
    
    if not success then
        warn("Failed to load Oratio:", result)
        return nil
    end
    
    return result
end

Censura.System.Oratio = InitializeOratio()
local Logger = Censura.System.Oratio.Logger.new({
    moduleName = "Censura"
})

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function ApplyRounding(instance, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance
    })
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Window Creation
function Censura:CreateWindow(title)
    Logger:Info("Creating window: " .. title)
    
    local window = {
        Elements = {},
        Visible = true
    }
    
    -- Main Frame
    window.Frame = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = self.Settings.Colors.Background,
        Parent = self.GUI
    })
    ApplyRounding(window.Frame)
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Settings.Colors.TitleBar,
        Parent = window.Frame
    })
    ApplyRounding(titleBar)
    MakeDraggable(titleBar)
    
    -- Title Text
    Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Window",
        TextColor3 = self.Settings.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = self.Settings.Font,
        TextSize = self.Settings.TextSize,
        Parent = titleBar
    })
    
    -- Content Container
    local content = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        Parent = window.Frame
    })
    
    -- Auto-size Layout
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        Parent = content
    })
    
    -- Button Creation
    function window:AddButton(text, callback)
        local button = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Censura.Settings.Colors.Button,
            Text = text,
            TextColor3 = Censura.Settings.Colors.Text,
            Font = Censura.Settings.Font,
            TextSize = Censura.Settings.TextSize,
            Parent = content
        })
        ApplyRounding(button)
        
        -- Hover Effects
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Censura.Settings.Colors.ButtonHover
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Censura.Settings.Colors.Button
        end)
        
        if callback then
            button.MouseButton1Click:Connect(function()
                Logger:Debug("Button clicked: " .. text)
                callback()
            end)
        end
        
        return button
    end
    
    -- Toggle Creation
    function window:AddToggle(text, default, callback)
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = content
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Censura.Settings.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Settings.Font,
            TextSize = Censura.Settings.TextSize,
            Parent = container
        })
        
        local toggle = Create("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = default and 
                Censura.Settings.Colors.ToggleEnabled or 
                Censura.Settings.Colors.Toggle,
            Parent = container
        })
        ApplyRounding(toggle)
        
        local enabled = default or false
        toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                toggle.BackgroundColor3 = enabled and 
                    Censura.Settings.Colors.ToggleEnabled or 
                    Censura.Settings.Colors.Toggle
                    
                Logger:Debug(string.format("Toggle '%s' set to: %s", text, tostring(enabled)))
                
                if callback then 
                    callback(enabled)
                end
            end
        end)
        
        return container
    end
    
    -- Slider Creation
    function window:AddSlider(text, min, max, default, callback)
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundTransparency = 1,
            Parent = content
        })
        
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Censura.Settings.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Settings.Font,
            TextSize = Censura.Settings.TextSize,
            Parent = container
        })
        
        local sliderBar = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0.7, 0),
            BackgroundColor3 = Censura.Settings.Colors.Slider,
            Parent = container
        })
        ApplyRounding(sliderBar)
        
        local fill = Create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Censura.Settings.Colors.SliderFill,
            Parent = sliderBar
        })
        ApplyRounding(fill)
        
        local function update(input)
            local pos = math.clamp(
                (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
                0, 1
            )
            local value = math.floor(min + (pos * (max - min)))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            Logger:Debug(string.format("Slider '%s' value: %d", text, value))
            
            if callback then 
                callback(value)
            end
        end
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                update(input)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                    else
                        update(input)
                    end
                end)
            end
        end)
        
        return container
    end
    
    -- Window Methods
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
        self.GUI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Display splash
    print(string.format(self.Messages.Clear .. self.Messages.Splash .. "\n", self.Version))
    Logger:Info("Initialization Complete!")
    
    return self
end

-- Set global reference and initialize
_G.Censura = Censura
return Censura:Initialize()

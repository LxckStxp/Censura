--[[
    Censura UI System - Components Module
    Author: LxckStxp
    Version: 2.0.0
    
    This module contains all UI component definitions for the Censura UI system.
    Each component is a function that returns a new instance of that UI element.
]]

local Components = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Load dependencies
local function LoadModule(url)
    return loadstring(game:HttpGet(url))()
end

-- Get Styles module
local Styles = LoadModule("https://raw.githubusercontent.com/LxckStxp/Censura/main/Styles.lua")

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
        CornerRadius = UDim.new(0, radius or Styles.Layout.Window.CornerRadius),
        Parent = instance
    })
end

-- Component Definitions
function Components.Button(options)
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.ButtonHeight),
        BackgroundColor3 = Styles.Theme.Elements.Button.Default,
        Text = options.text or "Button",
        TextColor3 = Styles.Theme.Text.Primary,
        Font = Styles.Font.Default.Family,
        TextSize = Styles.Font.Default.Size,
        Parent = options.parent
    })
    ApplyRounding(button)
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, Styles.Animation.Short, {
            BackgroundColor3 = Styles.Theme.Elements.Button.Hover
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, Styles.Animation.Short, {
            BackgroundColor3 = Styles.Theme.Elements.Button.Default
        }):Play()
    end)
    
    if options.callback then
        button.MouseButton1Click:Connect(options.callback)
    end
    
    return button
end

function Components.Toggle(options)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.ButtonHeight),
        BackgroundTransparency = 1,
        Parent = options.parent
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Toggle",
        TextColor3 = Styles.Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Styles.Font.Default.Family,
        TextSize = Styles.Font.Default.Size,
        Parent = container
    })
    
    local toggle = Create("Frame", {
        Size = UDim2.new(0, Styles.Layout.Elements.ToggleWidth, 
                        0, Styles.Layout.Elements.ToggleHeight),
        Position = UDim2.new(1, -Styles.Layout.Elements.ToggleWidth, 
                            0.5, -Styles.Layout.Elements.ToggleHeight/2),
        BackgroundColor3 = options.default and 
            Styles.Theme.Elements.Toggle.BackgroundEnabled or 
            Styles.Theme.Elements.Toggle.Background,
        Parent = container
    })
    ApplyRounding(toggle, Styles.Layout.Elements.ToggleHeight/2)
    
    local enabled = options.default or false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            TweenService:Create(toggle, Styles.Animation.Short, {
                BackgroundColor3 = enabled and 
                    Styles.Theme.Elements.Toggle.BackgroundEnabled or 
                    Styles.Theme.Elements.Toggle.Background
            }):Play()
            
            if options.callback then 
                options.callback(enabled)
            end
        end
    end)
    
    return container
end

function Components.Slider(options)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.ButtonHeight * 1.5),
        BackgroundTransparency = 1,
        Parent = options.parent
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.ButtonHeight/2),
        BackgroundTransparency = 1,
        Text = options.text or "Slider",
        TextColor3 = Styles.Theme.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Styles.Font.Default.Family,
        TextSize = Styles.Font.Default.Size,
        Parent = container
    })
    
    local sliderBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.SliderHeight),
        Position = UDim2.new(0, 0, 0.7, 0),
        BackgroundColor3 = Styles.Theme.Elements.Slider.Background,
        Parent = container
    })
    ApplyRounding(sliderBar)
    
    local fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Styles.Theme.Elements.Slider.Fill,
        Parent = sliderBar
    })
    ApplyRounding(fill)
    
    local valueLabel = Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, Styles.Layout.Elements.ButtonHeight/2),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(options.default or options.min or 0),
        TextColor3 = Styles.Theme.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Styles.Font.Default.Family,
        TextSize = Styles.Font.Default.Size,
        Parent = container
    })
    
    local function update(input)
        local pos = math.clamp(
            (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
            0, 1
        )
        local value = math.floor(options.min + (pos * (options.max - options.min)))
        
        TweenService:Create(fill, Styles.Animation.Short, {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        valueLabel.Text = tostring(value)
        
        if options.callback then 
            options.callback(value)
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

function Components.Label(options)
    return Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, options.height or Styles.Layout.Elements.ButtonHeight),
        BackgroundTransparency = 1,
        Text = options.text or "Label",
        TextColor3 = options.color or Styles.Theme.Text.Primary,
        TextXAlignment = options.alignment or Enum.TextXAlignment.Left,
        Font = options.font or Styles.Font.Default.Family,
        TextSize = options.textSize or Styles.Font.Default.Size,
        Parent = options.parent
    })
end

function Components.Section(options)
    local section = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- Auto-size
        BackgroundColor3 = Styles.Theme.Background.Light,
        Parent = options.parent
    })
    ApplyRounding(section)
    
    if options.title then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, Styles.Layout.Elements.ButtonHeight),
            BackgroundTransparency = 1,
            Text = options.title,
            TextColor3 = Styles.Theme.Text.Primary,
            Font = Styles.Font.Title.Family,
            TextSize = Styles.Font.Title.Size,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
    end
    
    local content = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, options.title and Styles.Layout.Elements.ButtonHeight or 0),
        BackgroundTransparency = 1,
        Parent = section
    })
    
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, Styles.Layout.Spacing.Small),
        Parent = content
    })
    
    -- Auto-size handling
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        section.Size = UDim2.new(1, 0, 0, content.Size.Y.Offset + 
            (options.title and Styles.Layout.Elements.ButtonHeight or 0))
    end)
    
    return section, content
end

-- Example Usage:
--[[
local button = Components.Button({
    text = "Click Me",
    parent = frame,
    callback = function()
        print("Button clicked!")
    end
})

local toggle = Components.Toggle({
    text = "Enable Feature",
    parent = frame,
    default = false,
    callback = function(enabled)
        print("Toggle:", enabled)
    end
})

local slider = Components.Slider({
    text = "Speed",
    parent = frame,
    min = 0,
    max = 100,
    default = 50,
    callback = function(value)
        print("Speed:", value)
    end
})
--]]

return Components

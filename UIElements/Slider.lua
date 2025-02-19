--[[
    Slider Module
    Part of Censura UI Library
    Version: 1.2
]]

local Slider = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Load Styles Module
local Styles = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua"))()

-- Constants
local KNOB_SIZE = {
    DEFAULT = UDim2.new(0, 12, 0, 12),
    HOVER = UDim2.new(0, 14, 0, 14)
}

local TRACK = {
    HEIGHT = 2,
    PADDING = 10
}

local VALUE_DISPLAY = {
    WIDTH = 50,
    HEIGHT = 20
}

local ANIMATION_INFO = {
    HOVER = TweenInfo.new(0.2),
    DRAG = TweenInfo.new(0.1),
    UPDATE = TweenInfo.new(0.1)
}

-- Utility Function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Slider.new(parent, text, min, max, default, callback)
    -- Input validation
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(min) == "number", "Min must be a number")
    assert(type(max) == "number", "Max must be a number")
    assert(type(callback) == "function", "Callback must be a function")
    assert(min < max, "Min must be less than max")
    assert(default >= min and default <= max, "Default must be between min and max")
    
    local System = getgenv().CensuraSystem
    assert(System, "CensuraSystem not initialized")
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    local containerStroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        0.5
    )
    containerStroke.Parent = container
    
    -- Label and Value Display
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, TRACK.PADDING, 0, 0),
        Size = UDim2.new(1, -(VALUE_DISPLAY.WIDTH + 20), 0, VALUE_DISPLAY.HEIGHT),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = container
    })
    
    local valueFrame = Create("Frame", {
        Name = "ValueFrame",
        Position = UDim2.new(1, -VALUE_DISPLAY.WIDTH - TRACK.PADDING, 0, 0),
        Size = UDim2.new(0, VALUE_DISPLAY.WIDTH, 0, VALUE_DISPLAY.HEIGHT),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.8,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = valueFrame
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = valueFrame
    })
    
    -- Track System
    local track = Create("Frame", {
        Name = "Track",
        Position = UDim2.new(0, TRACK.PADDING, 0.7, 0),
        Size = UDim2.new(1, -TRACK.PADDING * 2, 0, TRACK.HEIGHT),
        BackgroundColor3 = System.Colors.Border,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = track
    })
    
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled,
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = fill
    })
    
    local knob = Create("Frame", {
        Name = "Knob",
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        Size = KNOB_SIZE.DEFAULT,
        BackgroundColor3 = System.Colors.Text,
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local knobStroke = Styles.createStroke(
        System.Colors.Accent,
        0.8,
        1
    )
    knobStroke.Parent = knob
    
    -- State Management
    local state = {
        value = default,
        dragging = false,
        locked = false,
        precision = 0,
        hovered = false
    }
    
    -- Update Functions
    local function updateVisuals(pos)
        Services.Tween:Create(fill, ANIMATION_INFO.UPDATE, {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        Services.Tween:Create(knob, ANIMATION_INFO.UPDATE, {
            Position = UDim2.new(pos, -6, 0.5, -6)
        }):Play()
    end
    
    local function updateValue(pos, skipCallback)
        if state.locked then return end
        
        local newValue = min + ((max - min) * pos)
        if state.precision > 0 then
            newValue = math.floor(newValue * (10 ^ state.precision)) / (10 ^ state.precision)
        else
            newValue = math.floor(newValue)
        end
        
        if newValue ~= state.value then
            state.value = newValue
            valueLabel.Text = tostring(state.value)
            updateVisuals(pos)
            
            if not skipCallback then
                callback(state.value)
            end
        end
    end
    
    -- Input Handling
    local function handleDrag(input)
        if state.locked then return end
        
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mousePos = input.Position.X
        
        local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
        updateValue(pos)
    end
    
    -- Input Connections
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not state.locked then
            state.dragging = true
            Services.Tween:Create(knob, ANIMATION_INFO.DRAG, {
                Size = KNOB_SIZE.HOVER
            }):Play()
        end
    end)
    
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.dragging = false
            Services.Tween:Create(knob, ANIMATION_INFO.DRAG, {
                Size = KNOB_SIZE.DEFAULT
            }):Play()
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleDrag(input)
        end
    end)
    
    Services.Run.RenderStepped:Connect(function()
        if state.dragging then
            handleDrag({Position = Services.Input:GetMouseLocation()})
        end
    end)
    
    -- Hover Effects
    container.MouseEnter:Connect(function()
        if not state.locked then
            state.hovered = true
            Services.Tween:Create(containerStroke, ANIMATION_INFO.HOVER, {
                Transparency = 0.2
            }):Play()
            
            Services.Tween:Create(valueFrame, ANIMATION_INFO.HOVER, {
                BackgroundTransparency = 0.6
            }):Play()
        end
    end)
    
    container.MouseLeave:Connect(function()
        state.hovered = false
        if not state.dragging then
            Services.Tween:Create(containerStroke, ANIMATION_INFO.HOVER, {
                Transparency = System.UI.Transparency.Elements
            }):Play()
            
            Services.Tween:Create(valueFrame, ANIMATION_INFO.HOVER, {
                BackgroundTransparency = 0.8
            }):Play()
        end
    end)
    
    -- Public Interface
    local interface = {
        SetValue = function(self, newValue, skipCallback)
            local pos = math.clamp((newValue - min) / (max - min), 0, 1)
            updateValue(pos, skipCallback)
        end,
        
        GetValue = function(self)
            return state.value
        end,
        
        SetLocked = function(self, locked)
            state.locked = locked
            container.BackgroundTransparency = locked and 0.7 or System.UI.Transparency.Elements
            label.TextColor3 = locked and System.Colors.SecondaryText or System.Colors.Text
            valueLabel.TextColor3 = locked and System.Colors.SecondaryText or System.Colors.Text
            track.BackgroundTransparency = locked and 0.7 or 0.5
            fill.BackgroundTransparency = locked and 0.7 or 0
        end,
        
        SetPrecision = function(self, decimals)
            state.precision = math.clamp(decimals or 0, 0, 10)
            self:SetValue(state.value, true)
        end,
        
        SetText = function(self, newText)
            label.Text = newText
        end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    return setmetatable(interface, {
        __index = container
    })
end

return Slider

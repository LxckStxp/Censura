--[[
    Switch Module
    Part of Censura UI Library
    Version: 1.2
]]

local Switch = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService")
}

-- Load Styles Module
local Styles = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua"))()

-- Constants
local KNOB_POSITIONS = {
    OFF = UDim2.new(0, 2, 0.5, -6),
    ON = UDim2.new(1, -14, 0.5, -6)
}

local KNOB_SIZE = {
    DEFAULT = UDim2.new(0, 12, 0, 12),
    PRESSED = UDim2.new(0, 10, 0, 10)
}

-- Utility Function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Switch.new(parent, text, default, callback)
    -- Input validation
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    local System = getgenv().CensuraSystem
    assert(System, "CensuraSystem not initialized")
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SwitchContainer",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    -- Container stroke
    local containerStroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    containerStroke.Parent = container
    
    -- Text Label
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = container
    })
    
    -- Track
    local track = Create("Frame", {
        Name = "Track",
        Position = UDim2.new(1, -34, 0.5, -8),
        Size = UDim2.new(0, 24, 0, 16),
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Background,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    -- Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Position = default and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF,
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
    local enabled = default or false
    local isLocked = false
    local isHovered = false
    
    -- Switch Logic
    local function updateSwitch(newState, skipCallback)
        if isLocked then return end
        
        enabled = newState
        
        -- Animate knob position
        Services.Tween:Create(knob, TweenInfo.new(0.2), {
            Position = enabled and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF
        }):Play()
        
        -- Update track color
        Services.Tween:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Background
        }):Play()
        
        if not skipCallback then
            callback(enabled)
        end
    end
    
    -- Input Handling
    local function handleClick()
        if isLocked then return end
        
        -- Click feedback
        Services.Tween:Create(knob, TweenInfo.new(0.1), {
            Size = KNOB_SIZE.PRESSED
        }):Play()
        
        task.delay(0.1, function()
            Services.Tween:Create(knob, TweenInfo.new(0.1), {
                Size = KNOB_SIZE.DEFAULT
            }):Play()
        end)
        
        updateSwitch(not enabled)
    end
    
    -- Input Connections
    local function connectInput(instance)
        instance.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                handleClick()
            end
        end)
    end
    
    connectInput(track)
    connectInput(container)
    
    -- Hover Effects
    container.MouseEnter:Connect(function()
        if not isLocked then
            isHovered = true
            Services.Tween:Create(containerStroke, TweenInfo.new(0.2), {
                Transparency = 0.2
            }):Play()
            
            Services.Tween:Create(track, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
    
    container.MouseLeave:Connect(function()
        isHovered = false
        Services.Tween:Create(containerStroke, TweenInfo.new(0.2), {
            Transparency = System.UI.Transparency.Elements
        }):Play()
        
        Services.Tween:Create(track, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5
        }):Play()
    end)
    
    -- Public Interface
    local interface = {
        SetState = function(self, state, skipCallback)
            updateSwitch(state, skipCallback)
        end,
        
        GetState = function(self)
            return enabled
        end,
        
        SetLocked = function(self, locked)
            isLocked = locked
            container.BackgroundTransparency = locked and 0.7 or System.UI.Transparency.Elements
            label.TextColor3 = locked and System.Colors.SecondaryText or System.Colors.Text
            track.BackgroundTransparency = locked and 0.7 or (isHovered and 0.3 or 0.5)
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

return Switch

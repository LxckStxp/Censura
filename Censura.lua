-- Simplified Censura UI System
if _G.Censura then
    _G.Censura = nil
end

local Censura = {
    Version = "2.0.0",
    Windows = {},
    Git = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
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

-- Initialize Oratio
local function InitializeOratio()
    local success, Oratio = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua", true))()
    end)
    
    if not success then
        warn("Failed to load Oratio:", Oratio)
        return nil
    end
    
    return Oratio
end

-- Setup logging
Censura.System.Oratio = InitializeOratio()
local Logger = Censura.System.Oratio.Logger.new({
    moduleName = "Censura"
})

-- Display splash screen
print(string.format(Censura.Messages.Clear .. Censura.Messages.Splash .. "\n", Censura.Version))
Logger:Info("Initializing Censura UI System...")

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function ApplyRounding(instance, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance
    })
end

local function MakeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Censura:CreateWindow(title)
    local window = {
        Elements = {},
        Visible = true
    }

    -- Create main window frame
    window.Frame = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = self.Settings.Colors.Background,
        Parent = self.GUI
    })
    ApplyRounding(window.Frame)

    -- Create title bar
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Settings.Colors.TitleBar,
        Parent = window.Frame
    })
    ApplyRounding(titleBar)
    MakeDraggable(titleBar)

    -- Title text
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

    -- Content container
    local content = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        Parent = window.Frame
    })

    -- Auto-size layout
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        Parent = content
    })

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

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Censura.Settings.Colors.ButtonHover
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Censura.Settings.Colors.Button
        end)

        if callback then
            button.MouseButton1Click:Connect(callback)
        end
        return button
    end

    function window:AddToggle(text, default, callback)
        local container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = content
        })

        local label = Create("TextLabel", {
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
            BackgroundColor3 = default and Censura.Settings.Colors.ToggleEnabled or Censura.Settings.Colors.Toggle,
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
                if callback then callback(enabled) end
            end
        end)

        return container
    end

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
            local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            fill.Size = UDim2.new(pos, 0, 1, 0)
            if callback then callback(value) end
        end

        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                update(input)
                local connection
                connection = game:GetService("RunService").RenderStepped:Connect(function()
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

    function window:Show()
        window.Frame.Visible = true
        window.Visible = true
    end

    function window:Hide()
        window.Frame.Visible = false
        window.Visible = false
    end

    function window:Toggle()
        window.Visible = not window.Visible
        window.Frame.Visible = window.Visible
    end

    table.insert(self.Windows, window)
    return window
end

function Censura:Initialize()
    Logger:Info("Setting up GUI container...")
    
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "CensuraGUI"
    self.GUI.ResetOnSpawn = false
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.DisplayOrder = 999

    local success, result = pcall(function()
        self.GUI.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        Logger:Warn("Failed to parent to CoreGui, falling back to PlayerGui")
        self.GUI.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    Logger:Info("Initialization Complete!")
    return self
end

_G.Censura = Censura
return Censura:Initialize()

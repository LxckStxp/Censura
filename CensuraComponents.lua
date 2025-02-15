--[[
    CensuraComponents.lua
    Part of Censura UI System v2.0.0
]]

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInput = game:GetService("UserInputService")
}

local Components = {}

function Components:Init(censura, utility)
    self.Censura = censura
    self.Utility = utility
    
    -- Return the component creation functions
    return {
        CreateToggle = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundTransparency = 1
            container.Parent = options.parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = options.label
            label.TextColor3 = self.Censura.Config.Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = self.Censura.Config.Fonts.Text
            label.TextSize = self.Censura.Config.Fonts.Size.Text
            label.Parent = container
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 40, 0, 20)
            button.Position = UDim2.new(1, -40, 0.5, -10)
            button.BackgroundColor3 = self.Censura.Config.Theme.Error
            button.Text = ""
            button.Parent = container
            self.Utility.CreateCorner(button, UDim.new(1, 0))
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 16, 0, 16)
            circle.Position = UDim2.new(0, 2, 0.5, -8)
            circle.BackgroundColor3 = self.Censura.Config.Theme.Highlight
            circle.Parent = button
            self.Utility.CreateCorner(circle, UDim.new(1, 0))
            
            local toggled = false
            button.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                Services.TweenService:Create(button, 
                    self.Censura.Config.Animation.Short,
                    {BackgroundColor3 = toggled and self.Censura.Config.Theme.Success or self.Censura.Config.Theme.Error}
                ):Play()
                
                Services.TweenService:Create(circle,
                    self.Censura.Config.Animation.Short,
                    {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
                ):Play()
                
                if options.callback then
                    options.callback(toggled)
                end
            end)
            
            return {
                Instance = container,
                SetValue = function(value)
                    toggled = value
                    button.BackgroundColor3 = value and self.Censura.Config.Theme.Success or self.Censura.Config.Theme.Error
                    circle.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                end
            }
        end,
        
        CreateSlider = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = options.parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = options.label
            label.TextColor3 = self.Censura.Config.Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = self.Censura.Config.Fonts.Text
            label.TextSize = self.Censura.Config.Fonts.Size.Text
            label.Parent = container
            
            local interactionFrame = Instance.new("TextButton")
            interactionFrame.Position = UDim2.new(0, 0, 0, 25)
            interactionFrame.Size = UDim2.new(1, 0, 0, 20)
            interactionFrame.BackgroundTransparency = 1
            interactionFrame.Text = ""
            interactionFrame.Parent = container
            
            local sliderBG = Instance.new("Frame")
            sliderBG.Position = UDim2.new(0, 0, 0.5, -2)
            sliderBG.Size = UDim2.new(1, 0, 0, 4)
            sliderBG.BackgroundColor3 = self.Censura.Config.Theme.Background
            sliderBG.Parent = interactionFrame
            self.Utility.CreateCorner(sliderBG, UDim.new(1, 0))
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = self.Censura.Config.Theme.Primary
            fill.Parent = sliderBG
            self.Utility.CreateCorner(fill, UDim.new(1, 0))
            
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, -8, 0.5, -8)
            knob.BackgroundColor3 = self.Censura.Config.Theme.Primary
            knob.Parent = fill
            self.Utility.CreateCorner(knob, UDim.new(1, 0))
            
            local value = Instance.new("TextLabel")
            value.Position = UDim2.new(1, -45, 0, 0)
            value.Size = UDim2.new(0, 45, 0, 20)
            value.BackgroundTransparency = 1
            value.Text = tostring(options.default or 0)
            value.TextColor3 = self.Censura.Config.Theme.Text
            value.Font = self.Censura.Config.Fonts.Text
            value.TextSize = self.Censura.Config.Fonts.Size.Text
            value.Parent = container
            
            local dragging = false
            local function updateValue(input)
                local pos = input.Position.X
                local sliderPos = sliderBG.AbsolutePosition.X
                local sliderSize = sliderBG.AbsoluteSize.X
                
                local relative = math.clamp((pos - sliderPos) / sliderSize, 0, 1)
                local newValue = math.floor(options.min + (options.max - options.min) * relative)
                
                value.Text = tostring(newValue)
                fill.Size = UDim2.new(relative, 0, 1, 0)
                
                if options.callback then
                    options.callback(newValue)
                end
            end
            
            self.Utility.Connect(interactionFrame.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateValue(input)
                end
            end)
            
            self.Utility.Connect(Services.UserInput.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)
            
            self.Utility.Connect(Services.UserInput.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            if options.default then
                local relative = (options.default - options.min) / (options.max - options.min)
                fill.Size = UDim2.new(relative, 0, 1, 0)
                value.Text = tostring(options.default)
            end
            
            return {
                Instance = container,
                SetValue = function(newValue)
                    local relative = (newValue - options.min) / (options.max - options.min)
                    value.Text = tostring(math.floor(newValue))
                    fill.Size = UDim2.new(relative, 0, 1, 0)
                end
            }
        end,
        
        CreateButton = function(options)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 32)
            button.BackgroundColor3 = self.Censura.Config.Theme.Primary
            button.Text = options.label
            button.TextColor3 = self.Censura.Config.Theme.Text
            button.Font = self.Censura.Config.Fonts.Text
            button.TextSize = self.Censura.Config.Fonts.Size.Text
            button.Parent = options.parent
            self.Utility.CreateCorner(button)
            
            button.MouseButton1Click:Connect(function()
                Services.TweenService:Create(button,
                    self.Censura.Config.Animation.Short,
                    {BackgroundColor3 = self.Censura.Config.Theme.Highlight}
                ):Play()
                
                if options.callback then
                    options.callback()
                end
                
                task.wait(0.2)
                Services.TweenService:Create(button,
                    self.Censura.Config.Animation.Short,
                    {BackgroundColor3 = self.Censura.Config.Theme.Primary}
                ):Play()
            end)
            
            return {
                Instance = button
            }
        end
    }
end

return Components

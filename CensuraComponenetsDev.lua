--[[
    CensuraComponents.lua
    Part of Censura UI System v2.0.0
]]

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInput = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

local Components = {}

-- Utility Functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

function Components:Init(censura, utility)
    self.Censura = censura
    self.Utility = utility
    
    -- Component Creation Functions
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
            
            -- Optional icon support
            if options.icon then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 16, 0, 16)
                icon.Position = UDim2.new(0, 5, 0.5, -8)
                icon.BackgroundTransparency = 1
                icon.Image = options.icon
                icon.Parent = button
                
                button.TextXAlignment = Enum.TextXAlignment.Center
                button.UIPadding = Instance.new("UIPadding")
                button.UIPadding.PaddingLeft = UDim.new(0, 25)
            end
            
            -- Ripple effect
            local ripple = Instance.new("Frame")
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.8
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 2
            ripple.Visible = false
            ripple.Parent = button
            self.Utility.CreateCorner(ripple)
            
            button.MouseButton1Down:Connect(function(x, y)
                local relativeX = x - button.AbsolutePosition.X
                local relativeY = y - button.AbsolutePosition.Y
                
                ripple.Position = UDim2.new(0, relativeX - 50, 0, relativeY - 50)
                ripple.Size = UDim2.new(0, 100, 0, 100)
                ripple.Visible = true
                
                local tween = Services.TweenService:Create(ripple,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1}
                )
                tween:Play()
                
                tween.Completed:Connect(function()
                    ripple.Visible = false
                    ripple.Size = UDim2.new(0, 100, 0, 100)
                    ripple.BackgroundTransparency = 0.8
                end)
                
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
                Instance = button,
                SetEnabled = function(enabled)
                    button.AutoButtonColor = enabled
                    button.TextTransparency = enabled and 0 or 0.5
                end,
                SetText = function(text)
                    button.Text = text
                end
            }
        end,

        CreateDropdown = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundTransparency = 1
            container.ClipsDescendants = true
            container.Parent = options.parent
            
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 30)
            header.BackgroundColor3 = self.Censura.Config.Theme.Background
            header.Text = options.label
            header.TextColor3 = self.Censura.Config.Theme.Text
            header.Font = self.Censura.Config.Fonts.Text
            header.TextSize = self.Censura.Config.Fonts.Size.Text
            header.Parent = container
            self.Utility.CreateCorner(header)
            
            local arrow = Instance.new("ImageLabel")
            arrow.Size = UDim2.new(0, 12, 0, 12)
            arrow.Position = UDim2.new(1, -20, 0.5, -6)
            arrow.BackgroundTransparency = 1
            arrow.Image = "rbxassetid://6034818372"
            arrow.ImageColor3 = self.Censura.Config.Theme.Text
            arrow.Parent = header
            
            local content = Instance.new("Frame")
            content.Position = UDim2.new(0, 0, 0, 35)
            content.Size = UDim2.new(1, 0, 0, 0)
            content.BackgroundColor3 = self.Censura.Config.Theme.Background
            content.BackgroundTransparency = 0.5
            content.ClipsDescendants = true
            content.Parent = container
            self.Utility.CreateCorner(content)
            
            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 2)
            list.Parent = content
            
            local padding = Instance.new("UIPadding")
            padding.PaddingTop = UDim.new(0, 2)
            padding.PaddingBottom = UDim.new(0, 2)
            padding.Parent = content
            
            local selected = options.default
            local isOpen = false
            
            local function createOption(text)
                local option = Instance.new("TextButton")
                option.Size = UDim2.new(1, -4, 0, 25)
                option.Position = UDim2.new(0, 2, 0, 0)
                option.BackgroundColor3 = self.Censura.Config.Theme.Primary
                option.BackgroundTransparency = 1
                option.Text = text
                option.TextColor3 = self.Censura.Config.Theme.Text
                option.Font = self.Censura.Config.Fonts.Text
                option.TextSize = self.Censura.Config.Fonts.Size.Text
                option.Parent = content
                self.Utility.CreateCorner(option)
                
                option.MouseEnter:Connect(function()
                    Services.TweenService:Create(option,
                        self.Censura.Config.Animation.Short,
                        {BackgroundTransparency = 0.8}
                    ):Play()
                end)
                
                option.MouseLeave:Connect(function()
                    Services.TweenService:Create(option,
                        self.Censura.Config.Animation.Short,
                        {BackgroundTransparency = 1}
                    ):Play()
                end)
                
                option.MouseButton1Click:Connect(function()
                    selected = text
                    header.Text = options.label .. ": " .. text
                    
                    Services.TweenService:Create(container,
                        self.Censura.Config.Animation.Short,
                        {Size = UDim2.new(1, 0, 0, 30)}
                    ):Play()
                    
                    Services.TweenService:Create(arrow,
                        self.Censura.Config.Animation.Short,
                        {Rotation = 0}
                    ):Play()
                    
                    isOpen = false
                    
                    if options.callback then
                        options.callback(text)
                    end
                end)
                
                return option
            end
            
            -- Create initial options
            for _, item in ipairs(options.items or {}) do
                createOption(item)
            end
            
            header.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local contentSize = list.AbsoluteContentSize.Y + 4
                
                Services.TweenService:Create(container,
                    self.Censura.Config.Animation.Short,
                    {Size = UDim2.new(1, 0, 0, isOpen and (35 + contentSize) or 30)}
                ):Play()
                
                Services.TweenService:Create(arrow,
                    self.Censura.Config.Animation.Short,
                    {Rotation = isOpen and 180 or 0}
                ):Play()
            end)
            
            return {
                Instance = container,
                GetSelected = function()
                    return selected
                end,
                SetSelected = function(text)
                    selected = text
                    header.Text = options.label .. ": " .. text
                end,
                AddOption = function(text)
                    createOption(text)
                    if isOpen then
                        local contentSize = list.AbsoluteContentSize.Y + 4
                        container.Size = UDim2.new(1, 0, 0, 35 + contentSize)
                    end
                end,
                RemoveOption = function(text)
                    for _, child in ipairs(content:GetChildren()) do
                        if child:IsA("TextButton") and child.Text == text then
                            child:Destroy()
                            if isOpen then
                                local contentSize = list.AbsoluteContentSize.Y + 4
                                container.Size = UDim2.new(1, 0, 0, 35 + contentSize)
                            end
                            break
                        end
                    end
                end
            }
        end,
            CreateInput = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = options.parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = options.label
            label.TextColor3 = self.Censura.Config.Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = self.Censura.Config.Fonts.Text
            label.TextSize = self.Censura.Config.Fonts.Size.Text
            label.Parent = container
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Position = UDim2.new(0, 0, 0, 25)
            inputFrame.Size = UDim2.new(1, 0, 0, 20)
            inputFrame.BackgroundColor3 = self.Censura.Config.Theme.Background
            inputFrame.Parent = container
            self.Utility.CreateCorner(inputFrame)
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1, -10, 1, 0)
            input.Position = UDim2.new(0, 5, 0, 0)
            input.BackgroundTransparency = 1
            input.Text = options.default or ""
            input.PlaceholderText = options.placeholder or ""
            input.TextColor3 = self.Censura.Config.Theme.Text
            input.PlaceholderColor3 = self.Censura.Config.Theme.Disabled
            input.Font = self.Censura.Config.Fonts.Text
            input.TextSize = self.Censura.Config.Fonts.Size.Text
            input.ClearTextOnFocus = options.clearOnFocus ~= false
            input.Parent = inputFrame
            
            -- Validation handling
            local function validate(text)
                if options.validation then
                    local success, result = pcall(function()
                        return options.validation(text)
                    end)
                    
                    if success then
                        Services.TweenService:Create(inputFrame,
                            self.Censura.Config.Animation.Short,
                            {BackgroundColor3 = result and self.Censura.Config.Theme.Background or self.Censura.Config.Theme.Error}
                        ):Play()
                        return result
                    end
                end
                return true
            end
            
            input.FocusLost:Connect(function(enterPressed)
                local text = input.Text
                local isValid = validate(text)
                
                if isValid and options.callback then
                    options.callback(text, enterPressed)
                end
            end)
            
            -- Character limit
            if options.maxLength then
                input:GetPropertyChangedSignal("Text"):Connect(function()
                    if #input.Text > options.maxLength then
                        input.Text = input.Text:sub(1, options.maxLength)
                    end
                end)
            end
            
            return {
                Instance = container,
                GetText = function()
                    return input.Text
                end,
                SetText = function(text)
                    input.Text = text
                    validate(text)
                end,
                Clear = function()
                    input.Text = ""
                end
            }
        end,

        CreateKeybind = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundTransparency = 1
            container.Parent = options.parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = options.label
            label.TextColor3 = self.Censura.Config.Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = self.Censura.Config.Fonts.Text
            label.TextSize = self.Censura.Config.Fonts.Size.Text
            label.Parent = container
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 60, 0, 24)
            button.Position = UDim2.new(1, -60, 0.5, -12)
            button.BackgroundColor3 = self.Censura.Config.Theme.Background
            button.Text = options.default and options.default.Name or "None"
            button.TextColor3 = self.Censura.Config.Theme.Text
            button.Font = self.Censura.Config.Fonts.Text
            button.TextSize = self.Censura.Config.Fonts.Size.Text
            button.Parent = container
            self.Utility.CreateCorner(button)
            
            local listening = false
            local currentKey = options.default
            local connection
            
            local function startListening()
                button.Text = "..."
                button.TextColor3 = self.Censura.Config.Theme.Primary
                listening = true
                
                if connection then
                    connection:Disconnect()
                end
                
                connection = Services.UserInput.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Escape then
                            button.Text = currentKey and currentKey.Name or "None"
                            button.TextColor3 = self.Censura.Config.Theme.Text
                            listening = false
                            connection:Disconnect()
                            return
                        end
                        
                        currentKey = input.KeyCode
                        button.Text = input.KeyCode.Name
                        button.TextColor3 = self.Censura.Config.Theme.Text
                        listening = false
                        
                        if options.callback then
                            options.callback(input.KeyCode)
                        end
                        
                        connection:Disconnect()
                    end
                end)
            end
            
            button.MouseButton1Click:Connect(function()
                if not listening then
                    startListening()
                end
            end)
            
            return {
                Instance = container,
                GetKey = function()
                    return currentKey
                end,
                SetKey = function(key)
                    currentKey = key
                    button.Text = key and key.Name or "None"
                end,
                Reset = function()
                    currentKey = options.default
                    button.Text = options.default and options.default.Name or "None"
                end
            }
        end,

        CreateProgressBar = function(options)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 45)
            container.BackgroundTransparency = 1
            container.Parent = options.parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = options.label
            label.TextColor3 = self.Censura.Config.Theme.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = self.Censura.Config.Fonts.Text
            label.TextSize = self.Censura.Config.Fonts.Size.Text
            label.Parent = container
            
            local progressFrame = Instance.new("Frame")
            progressFrame.Position = UDim2.new(0, 0, 0, 25)
            progressFrame.Size = UDim2.new(1, 0, 0, 20)
            progressFrame.BackgroundColor3 = self.Censura.Config.Theme.Background
            progressFrame.Parent = container
            self.Utility.CreateCorner(progressFrame)
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(options.default or 0, 0, 1, 0)
            fill.BackgroundColor3 = self.Censura.Config.Theme.Primary
            fill.Parent = progressFrame
            self.Utility.CreateCorner(fill)
            
            local percentageLabel = Instance.new("TextLabel")
            percentageLabel.Size = UDim2.new(1, 0, 1, 0)
            percentageLabel.BackgroundTransparency = 1
            percentageLabel.Text = tostring(math.floor((options.default or 0) * 100)) .. "%"
            percentageLabel.TextColor3 = self.Censura.Config.Theme.Text
            percentageLabel.Font = self.Censura.Config.Fonts.Text
            percentageLabel.TextSize = self.Censura.Config.Fonts.Size.Text
            percentageLabel.Parent = progressFrame
            
            -- Optional loading animation
            local loading = false
            local loadingTween
            
            return {
                Instance = container,
                SetProgress = function(progress, animate)
                    local targetProgress = math.clamp(progress, 0, 1)
                    
                    if animate then
                        Services.TweenService:Create(fill,
                            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                            {Size = UDim2.new(targetProgress, 0, 1, 0)}
                        ):Play()
                    else
                        fill.Size = UDim2.new(targetProgress, 0, 1, 0)
                    end
                    
                    percentageLabel.Text = tostring(math.floor(targetProgress * 100)) .. "%"
                    
                    if options.callback then
                        options.callback(targetProgress)
                    end
                end,
                StartLoading = function()
                    if loading then return end
                    loading = true
                    
                    loadingTween = Services.TweenService:Create(fill,
                        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                        {Size = UDim2.new(1, 0, 1, 0)}
                    )
                    loadingTween:Play()
                    
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    percentageLabel.Text = "Loading..."
                end,
                StopLoading = function()
                    if not loading then return end
                    loading = false
                    
                    if loadingTween then
                        loadingTween:Cancel()
                        loadingTween = nil
                    end
                    
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    percentageLabel.Text = "0%"
                end
            }
        end,
       
    -- Final utility functions for the components system
        GetComponents = function()
            return {
                Toggle = self.CreateToggle,
                Slider = self.CreateSlider,
                Button = self.CreateButton,
                Dropdown = self.CreateDropdown,
                Input = self.CreateInput,
                Keybind = self.CreateKeybind,
                ProgressBar = self.CreateProgressBar
            }
        end,
        
        Destroy = function()
            -- Cleanup function for removing all connections and instances
            for _, connection in pairs(self.connections or {}) do
                connection:Disconnect()
            end
            self.connections = {}
        end
    }
end

return Components

  

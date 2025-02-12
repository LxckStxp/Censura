-- Core/Elements/Keybind.lua
local Keybind = {}

local UserInputService = game:GetService("UserInputService")
local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Keybind.new(options)
    options = options or {}
    local currentKey = options.default or Enum.KeyCode.Unknown
    local listening = false
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create label
    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Keybind",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Create keybind button
    local button = Utils.Create("TextButton", {
        Size = UDim2.new(0, 90, 1, -4),
        Position = UDim2.new(1, -90, 0, 2),
        BackgroundColor3 = Styles.Colors.Controls.Button.Default,
        Text = currentKey.Name,
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        AutoButtonColor = false,
        Parent = container
    })
    Utils.ApplyCorners(button)
    Utils.ApplyHoverEffect(button)
    
    -- Keybind functionality
    local function updateButton(key)
        currentKey = key
        button.Text = key.Name
        if options.onBind then
            options.onBind(key)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        button.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    button.Text = currentKey.Name
                else
                    updateButton(input.KeyCode)
                end
                listening = false
                connection:Disconnect()
            end
        end)
    end)
    
    return container
end

return Keybind

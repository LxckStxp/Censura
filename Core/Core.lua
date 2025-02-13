-- Core/Core.lua
local Core = {}
Core.__index = Core

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Constants
local CORE_CONFIG = {
    GUI_NAME = "Censura",
    BASE_DISPLAY_ORDER = 999,
    MIN_WINDOW_SPACING = 10,
    DEFAULT_WINDOW_SIZE = UDim2.new(0, 300, 0, 400),
    DEFAULT_WINDOW_POSITION = UDim2.new(0.5, -150, 0.5, -200)
}

function Core.new()
    local self = setmetatable({}, Core)
    
    self.windows = {}
    self.activeWindow = nil
    self.isDragging = false
    
    -- Initialize ScreenGui with enhanced properties
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = CORE_CONFIG.GUI_NAME
    self.gui.ResetOnSpawn = false
    self.gui.DisplayOrder = CORE_CONFIG.BASE_DISPLAY_ORDER
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.IgnoreGuiInset = true
    
    -- Try to parent to CoreGui with fallback
    self:setupGuiParent()
    
    -- Setup global input handling
    self:setupInputHandling()
    
    return self
end

function Core:setupGuiParent()
    local success = pcall(function()
        self.gui.Parent = CoreGui
    end)
    
    if not success then
        local player = Players.LocalPlayer
        if player then
            self.gui.Parent = player:WaitForChild("PlayerGui")
            _G.Censura.System.Oratio:Warn("CoreGui parenting failed - using PlayerGui")
        else
            error("Failed to parent GUI - neither CoreGui nor PlayerGui available")
        end
    end
end

function Core:setupInputHandling()
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            self:handleWindowFocus(mousePos)
        end
    end)
end

function Core:CreateWindow(options)
    options = options or {}
    options.size = options.size or CORE_CONFIG.DEFAULT_WINDOW_SIZE
    
    -- Calculate position for new window with auto-spacing
    if not options.position then
        options.position = self:calculateNextWindowPosition()
    end
    
    -- Create window instance
    local window = _G.Censura.Elements.Window.new(options)
    window.Container.Parent = self.gui
    
    -- Add to windows table with metadata
    table.insert(self.windows, {
        instance = window,
        zIndex = #self.windows + CORE_CONFIG.BASE_DISPLAY_ORDER,
        created = tick()
    })
    
    -- Set as active window
    self:BringToFront(window)
    
    return window
end

function Core:calculateNextWindowPosition()
    if #self.windows == 0 then
        return CORE_CONFIG.DEFAULT_WINDOW_POSITION
    end
    
    -- Cascade windows
    local lastWindow = self.windows[#self.windows].instance
    local offset = CORE_CONFIG.MIN_WINDOW_SPACING
    
    return UDim2.new(
        lastWindow.Position.X.Scale,
        lastWindow.Position.X.Offset + offset,
        lastWindow.Position.Y.Scale,
        lastWindow.Position.Y.Offset + offset
    )
end

function Core:BringToFront(window)
    if not window then return end
    
    -- Update z-indices
    local topIndex = CORE_CONFIG.BASE_DISPLAY_ORDER + #self.windows
    
    for _, win in ipairs(self.windows) do
        if win.instance == window then
            win.zIndex = topIndex
            win.instance.Container.ZIndex = topIndex
        else
            win.zIndex = win.zIndex - 1
            win.instance.Container.ZIndex = win.zIndex
        end
    end
    
    self.activeWindow = window
    
    -- Sort windows table by z-index
    table.sort(self.windows, function(a, b)
        return a.zIndex < b.zIndex
    end)
end

function Core:handleWindowFocus(mousePos)
    -- Find clicked window
    for i = #self.windows, 1, -1 do
        local win = self.windows[i].instance
        if win.Container.Visible and self:isPositionInWindow(mousePos, win) then
            self:BringToFront(win)
            break
        end
    end
end

function Core:isPositionInWindow(position, window)
    local abs = window.Container.AbsolutePosition
    local size = window.Container.AbsoluteSize
    
    return position.X >= abs.X and
           position.X <= abs.X + size.X and
           position.Y >= abs.Y and
           position.Y <= abs.Y + size.Y
end

function Core:DestroyWindow(window)
    for i, win in ipairs(self.windows) do
        if win.instance == window then
            win.instance.Container:Destroy()
            table.remove(self.windows, i)
            break
        end
    end
end

function Core:GetActiveWindow()
    return self.activeWindow
end

function Core:Destroy()
    for _, window in ipairs(self.windows) do
        if window.instance then
            window.instance.Container:Destroy()
        end
    end
    self.gui:Destroy()
end

return Core

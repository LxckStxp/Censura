# CensuraDev UI Library

A lightweight Lua library for creating customizable menus in Roblox games.

## How to Use the CensuraDev API

### 1. Load the Library
Add the library to your script:
```lua
local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()
```

###2. Create a Menu
Initialize a new UI window with a title:
```lua
local UI = CensuraDev.new("Your Menu Title")
```
###3. Add Elements
Button: Create an interactive button:
```lua
local button = UI:CreateButton("Click Me", function()
    print("Button clicked!")
end)
```
###Toggle: Add an on/off switch:
```lua
UI:CreateToggle("Toggle Me", false, function(state)
    print("Toggled to: " .. tostring(state))
end)
```
###Slider: Add a value slider:
```lua
UI:CreateSlider("Value", 0, 100, 50, function(value)
    print("Slider value: " .. value)
end)
```
###4. Customize Elements
Disable a button (make it non-clickable):
```lua
button:SetEnabled(false)
```
Update button text:
```lua
button.Text = "New Text"
```
5. Show the Menu
Display the UI:
```lua
UI:Show()
```
6. Return the UI
Optionally return the UI object for further manipulation:
```lua
return UI
```

Notes
All elements are automatically added to the menu window.
Customize the look by adjusting the script’s internal styles (if accessible).
Ensure the library URL is valid to avoid loading errors.
That’s it! Use CensuraDev to quickly build interactive menus for your Roblox projects.


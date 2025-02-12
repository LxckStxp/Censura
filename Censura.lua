-- Welcome To Censura

-- Check If Censura Exists

if _G.Censura then
  print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
  print("Censura Detected. Removing existing instance.")
  _G.Censura = nil
end

-- Establish Global Censura Table

_G.Censura = {

  Version = "1.0.0",

  Git = "https://raw.githubusercontent.com/LxckStxp/Censura/main/",
  
  System = {}, -- System Functions Table
  Modules = {}, -- Core Module Storage    

  Messages = {  -- Storage for Formatable Strings

    Clear = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    
  } 

}

local Cens = _G.Censura
local Sys = Cens.System

Sys.Oratio = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/Oratio.lua", true))()
Ora = Sys.Oratio.Logger.new({
    moduleName = "Censura"
})

Cens.Messages.Splash = [[
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
-- Function to Load Modules
Sys.LoadModule = function(module)

    local url = Cens.Git..module..".lua"
  
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
  
    if not success then
        Ora:Error("Failed to load module from " .. url .. ": " .. tostring(result))
    else  
        Ora:Info("Loaded "..module)
    end
  
    return result
  
end

-- System Initialization.lua
Sys.Init = function()
  
  print(string.format( Cens.Messages.Clear..Cens.Messages.Splash.."\n", Cens.Version ))

  Ora:Info("Loading Core Modules\n")

end

Sys.Init()

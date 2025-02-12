-- Welcome To Censura

-- Check If Censura Exists

if _G.Censura then
  print("Censura Detected. Removing existing instance.")
  _G.Censura = nil
end

-- Establish Global Censura Table

_G.Censura = {

  Version = "1.0.0",
  
  System = {}, -- System Functions Table
  Modules = {}, -- Core Module Storage    

  Messages = {} -- Storage for Formatable Strings

}

local Cens = _G.Censura
local Sys = Cens.System

Cens.Messages.Splash = [[
\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      a88888b.                                                       
      d8'   `88                                                       
      88        .d8888b. 88d888b. .d8888b. dP    dP 88d888b. .d8888b. 
      88        88ooood8 88'  `88 Y8ooooo. 88    88 88'  `88 88'  `88 
      Y8.   .88 88.  ... 88    88       88 88.  .88 88       88.  .88 
       Y88888P' `88888P' dP    dP `88888P' `88888P' dP       `88888P8 v%s

                            - By LxckStxp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
\n
]]

Sys.Init = function()

  print(string.format( Cens.Messages.Splash, Cens.Version ))
  
end

Sys.Init()

local PLUGIN = Plugin("HUD", {})

function PLUGIN:OnEnable()
	local dir = SA.Folder:sub(11).."/gamemode/plugins/client/_hud/"
	include(dir.."DSAHealthIndicator.lua")
	include(dir.."DSAWeaponIndicator.lua")
	include(dir.."DSAEnviromentIndicator.lua")

	hook.Add("HUDShouldDraw", "SAHUD", function(elem)
		if(elem == "CHudHealth" or
		elem == "CHudBattery" or
		elem == "CHudCrosshair" or
		elem == "CHudAmmo" or
		elem == "CHudSecondaryAmmo") then
			return false
		end
	end)

	local healthIndicator = vgui.Create("DSAHealthIndicator")
	healthIndicator:SetSize(250, 150)
	healthIndicator.y = 75
	healthIndicator:AlignRight(-20)		
	
	local envIndicator = vgui.Create("DSAEnviromentIndicator")
	envIndicator:SetSize(300, 400)
	envIndicator.x = -150
	envIndicator.y = 100
	envIndicator:InvalidateLayout(true)
	envIndicator:Hide()
	
	SA:AddEventListener("EnviromentChanged", "HUD", function(oldEnv, newEnv)
		if(SA.Plugins.Enviroments.IsAtmosSphereHabitat(newEnv)) then
			envIndicator:Hide()
		else
			envIndicator:Show()
		end
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)

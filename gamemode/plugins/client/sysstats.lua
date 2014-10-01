local PLUGIN = Plugin("Sysstats", {"Playerdata"})

function PLUGIN:OnEnable()
	SA:AddEventListener("PlayerLoaded", "SysStats", function()
		timer.Simple(4, function()--delayed we don't send too much shit
			net.Start("SASysStats")
				net.WriteUInt(system.IsWindows() and 1 or 0, 1)
				net.WriteUInt(system.IsOSX() and 1 or 0, 1)
				net.WriteUInt(system.IsLinux() and 1 or 0, 1)
				net.WriteUInt((system.BatteryPower() ~= 255) and 1 or 0, 1)
				net.WriteUInt(ScrW(), 16)
				net.WriteUInt(ScrH(), 16)
			net.SendToServer()
		end)
	end)
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("PlayerLoaded", "SysStats")
end

SA:RegisterPlugin(PLUGIN)
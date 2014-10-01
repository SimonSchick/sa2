local PLUGIN = Plugin("Playerdata", {})

function PLUGIN:OnEnable()
	net.Receive("SAPlayerDataStatus", function(len)
		local ply = LocalPlayer()
		ply.__SAPID = net.ReadUInt(32)
		ply.__SAUniqueToken = net.ReadString()
		SA:CallEvent("PlayerLoaded", LocalPlayer())
	end)
	
	net.Receive("SAPlayerDataSaved", function(len)
		SA:CallEvent("PlayerSaved", LocalPlayer())
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAPlayerDataStatus", nil)
	net.Receive("SAPlayerDataSaved", nil)
end

SA:RegisterPlugin(PLUGIN)
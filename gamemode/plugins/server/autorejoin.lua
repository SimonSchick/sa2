local PLUGIN = Plugin("Autorejoin")
function PLUGIN:OnEnable()
	util.AddNetworkString("SAHeartBeat")
	timer.Create("SAHeartBeat", 3, 0, function()
		net.Start("SAHeartBeat")
		net.Broadcast()
	end)
end

function PLUGIN:OnDisable()
	timer.Remove("SAHeartBeat")
end

SA:RegisterPlugin(PLUGIN)
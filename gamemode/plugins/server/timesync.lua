local PLUGIN = Plugin("Timesync")

function PLUGIN:OnEnable()
	util.AddNetworkString("SATimeSync")
	timer.Create("SATimeSync", 60, 0, function()
		net.Start("SATimeSync")
			net.WriteUInt(os.time(), 32)
		net.Broadcast()
	end)
end

function PLUGIN:OnDisable()
	timer.Remove("SATimeSync")
end

SA:RegisterPlugin(PLUGIN)
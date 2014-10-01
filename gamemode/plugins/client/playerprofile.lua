local PLUGIN = Plugin("Playerprofile", {"Playerdata"})
PLUGIN._callbacks = {}

function PLUGIN:QueryPlayerProfile(ply, callback)
	self._callbacks[ply] = callback
	net.Start("SAPlayerPlayerQuery")
		net.WriteEntity(ply)
	net.SendToServer()
end

function PLUGIN:OnEnable()
	net.Receive("SAPlayerPlayerQueryResponse", function()
		local ply = net.ReadEntity()
		if(not self._callbacks[ply]) then
			return
		end
		self._callbacks[ply](ply, net.ReadString())
		self._callbacks[ply] = nil
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAPlayerPlayerQueryResponse", nil)
end

SA:RegisterPlugin(PLUGIN)
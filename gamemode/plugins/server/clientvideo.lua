local PLUGIN = {
	Name = "ClientVideo",
	Dependencies = {
		--stuff
	}
}

function PLUGIN:OnEnable()
	function _R.Player:SAQueryVideoHTTP(time, scaleFactor)
		net.Start("SAClientVideo")
			net.WriteUInt(time, 8)
			net.WriteFloat(scaleFactor)
			net.WriteString(
				util.CRC(tostring(self:Ping()+SysTime()) .. self:IPAddress() .. self:SteamID())
			)
		net.Send(self)
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)
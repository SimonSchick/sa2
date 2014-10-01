local PLUGIN = Plugin("Clientscreenshot")

function PLUGIN:OnEnable()
	util.AddNetworkString("SAScreenshotPacket")
	util.AddNetworkString("SAClientScreenshot")
	util.AddNetworkString("SAClientScreenshotAbort")
	util.AddNetworkString("SAClientScreenshotHTTP")
	local meta = _R.Player
	
	function meta:SAQueryScreenshot()
		if(not ply.__SAScreenshot) then
			ply.__SAScreenshot = 0
		end
		ply.__SAScreenshot = ply.__SAScreenshot + 1
		net.Start("SAClientScreenshot")
			net.WriteUInt(ply.__SAScreenshot, 32)
			net.WriteString(
				util.CRC(tostring(self:Ping()+SysTime()) .. self:IPAddress() .. self:SteamID())
			)
		net.Send(self)
		return ply.__SAScreenshot
	end
	
	function meta:SAQueryScreenshotHTTP()
		if(not ply.__SAScreenshot) then
			ply.__SAScreenshot = 0
		end
		ply.__SAScreenshot = ply.__SAScreenshot + 1
		net.Start("SAClientScreenshotHTTP")
			net.WriteUInt(ply.__SAScreenshot, 32)
			net.WriteString(util.CRC(tostring(self:Ping())+SysTime()) .. self:IPAddress())
		net.Send(self)
		return ply.__SAScreenshot
	end
	
	function meta:SAAbortScreenShot(id)
		net.Start("SAClientScreenshotAbort")
			net.WriteUInt(id)
		net.Send(self)
	end
	
	net.Receive("SAScreenshotSendStart", function()
		local w = net.ReadUInt(16)
		local h = net.ReadUInt(16)
		local compressedLength = net.ReadUInt(32)
		local token = net.ReadString()
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAScreenshotSendStart", nil)
end

SA:RegisterPlugin(PLUGIN)